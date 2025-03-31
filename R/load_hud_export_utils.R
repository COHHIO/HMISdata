#' Find the Most Recent HUD Export in S3
#'
#' @param bucket Character. Name of the S3 bucket (default: "hud.csv-daily")
#' @param prefix Character. Prefix to filter S3 objects (default: "HMIS")
#' @param region Character. AWS region (default: "us-east-2")
#' @return List containing the key and metadata of the most recent export
#' @keywords internal
find_latest_hud_export <- function(bucket = "hud.csv-daily",
                                   prefix = "HMIS",
                                   region = "us-east-2") {
  tryCatch({
    # List objects in the bucket
    objects <- aws.s3::get_bucket(
      bucket = bucket,
      prefix = prefix,
      region = region
    )

    # Filter for HUD export files and extract keys
    hud_files <- objects[grep("cohhio.*\\.zip$", sapply(objects, "[[", "Key"))]

    if (length(hud_files) == 0) {
      stop("No HUD export files found in bucket")
    }

    # Extract modification times and convert to POSIXct
    mod_times <- lapply(hud_files, function(x) {
      as.POSIXct(x$LastModified, format = "%Y-%m-%dT%H:%M:%S", tz = "GMT")
    })

    # Find the most recent file
    latest_index <- which.max(unlist(mod_times))
    latest_file <- hud_files[[latest_index]]

    if (is.null(latest_file)) {
      stop("Could not determine latest file")
    }

    # Return the key of the most recent file
    latest_file$Key

  }, error = function(e) {
    stop("Error finding latest HUD export: ", e$message)
  })
}


#' Extract HUD Export Archive
#'
#' @param archive_path Character. Path to the zip archive
#' @param extract_path Character. Directory where files should be extracted
#' @param delete_archive Logical. Whether to delete the archive after extraction
#' @param moment POSIXct/Date. Minimum acceptable file timestamp
#' @param wait Duration. Maximum time to wait for file
#' @return Logical indicating success
#' @keywords internal
extract_hud_export <- function(archive_path,
                               extract_path = fs::path("data", "hmis"),
                               delete_archive = TRUE,
                               moment = Sys.Date(),
                               wait = lubridate::minutes(2)) {
  tryCatch({
    # Create extraction directory if it doesn't exist
    fs::dir_create(extract_path)
    # Verify archive exists
    if (!fs::file_exists(archive_path)) {
      stop("Archive file not found: ", archive_path)
    }
    # Get archive metadata
    zip_contents <- utils::unzip(archive_path, list = TRUE)
    newest_file_date <- max(as.POSIXct(zip_contents$Date))

    # Check if files need updating
    needs_update <- TRUE
    existing_files <- fs::dir_ls(extract_path, type = "file")
    if (length(existing_files) > 0) {
      existing_newest <- max(fs::file_info(existing_files)$modification_time)
      if (existing_newest >= newest_file_date) {
        cli::cli_inform("Extracted files are up to date")
        needs_update <- FALSE
      }
    }

    # Extract files if needed
    if (needs_update) {
      utils::unzip(archive_path, exdir = extract_path)
    }

    # Clean up if requested (do this regardless of whether files needed updating)
    if (delete_archive) {
      fs::file_delete(archive_path)
    }

    TRUE
  }, error = function(e) {
    cli::cli_alert_danger("Extraction failed: {e$message}")
    FALSE
  })
}
