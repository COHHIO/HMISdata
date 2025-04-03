#' Download Latest Looker CSV Files from S3
#'
#' @param bucket Character. Name of the S3 bucket (default: "looker-daily")
#' @param prefix Character. Prefix to filter S3 objects
#' @param region Character. AWS region (default: "us-east-2")
#' @param local_path Character. Path where CSV files will be saved
#' @param delete_s3_object Logical. Whether to delete the object from S3 after download
#' @return List of data frames containing the loaded CSV data
#' @export
load_looker_data <- function(
    bucket = "looker-daily",
    prefix = NULL,
    region = "us-east-2",
    delete_s3_object = FALSE,
    filename = NULL,
    col_types = NULL
) {
  tryCatch({
    # Find latest files for each Look
    cli::cli_alert_info("Finding latest Looker exports...")
    latest_files <- find_latest_looker_files(bucket, prefix, region)

    # Filter only the requested filename (if provided)
    if (!is.null(filename)) {
      latest_files <- Filter(function(f) {
        matched <- f$look_name == filename
        return(matched)
      }, latest_files)

      if (length(latest_files) == 0) {
        cli::cli_alert_warning("No data found matching: {filename}")
        return(NULL)
      }
    }

    # Load each file directly into environment
    cli::cli_alert_info("Loading files directly from S3...")
    data <- list()

    for (file_info in latest_files) {
      # If no column specs provided, use character as default
      if (is.null(col_types)) {
        col_types <- readr::cols(.default = readr::col_character())
      }

      # Read the CSV directly from S3
      data[[file_info$look_name]] <- aws.s3::s3read_using(
        FUN = vroom::vroom,
        object = file_info$key,
        bucket = bucket,
        col_types = col_types
      )

      # Clean up S3 if requested
      if (delete_s3_object) {
        aws.s3::delete_object(
          object = file_info$key,
          bucket = bucket
        )
      }
    }

    # Return a single data frame if filename was specified, otherwise return the list
    if (!is.null(filename) && length(data) == 1) {
      # Return the first (and only) data frame in the list
      return(data[[1]])
    }

    cli::cli_alert_success("Data loaded successfully")
    return(data)
  }, error = function(e) {
    cli::cli_abort("Error: {e$message}")
    return(NULL)
  })
}

#' Find the Most Recent Looker Files in S3
#'
#' @param bucket Character. Name of the S3 bucket
#' @param prefix Character. Prefix to filter S3 objects
#' @param region Character. AWS region
#' @return List of information about the most recent files
#' @keywords internal
find_latest_looker_files <- function(bucket, prefix = NULL, region = "us-east-2") {
  tryCatch({
    # List objects in the bucket
    objects <- aws.s3::get_bucket(
      bucket = bucket,
      prefix = prefix,
      region = region
    )

    # Regular expression to match Looker file pattern and extract Look name
    pattern <- "^(.+)_extras_\\d{4}-\\d{2}-\\d{2}T\\d{4}_.+\\.csv$"

    # Filter and extract file information
    file_info <- lapply(objects, function(obj) {
      filename <- basename(obj$Key)
      if (grepl(pattern, filename)) {
        look_name <- sub(pattern, "\\1", filename)
        list(
          key = obj$Key,
          look_name = look_name,
          last_modified = as.POSIXct(obj$LastModified, format = "%Y-%m-%dT%H:%M:%S", tz = "GMT"),
          filename = filename
        )
      } else {
        NULL
      }
    })

    # Remove NULL entries (files that didn't match pattern)
    file_info <- file_info[!sapply(file_info, is.null)]

    if (length(file_info) == 0) {
      stop("No valid Looker files found in bucket")
    }

    # Group by Look name and find most recent for each
    look_names <- unique(sapply(file_info, function(x) x$look_name))

    latest_files <- lapply(look_names, function(ln) {
      ln_files <- file_info[sapply(file_info, function(x) x$look_name == ln)]
      mod_times <- sapply(ln_files, function(x) x$last_modified)
      ln_files[[which.max(mod_times)]]
    })

    return(latest_files)

  }, error = function(e) {
    stop("Error finding latest Looker files: ", e$message)
  })
}
