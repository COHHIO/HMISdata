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

# Get the location of the downloads folder
os_download_folder <- function() {
  switch(Sys.info()["sysname"],
         Windows = "~/../Downloads",
         Darwin = "~/Downloads")
}



#' @title Extract a previously downloaded HUD Export archive
#'
#' @param extract_path \code{(character)} path to the folder where the archive is to be extracted
#' @param delete_archive \code{(logical)} Delete the archive after extracting?
#' @param moment \code{(POSIXct/Date)} The time point which the archive creation time should be greater than to ensure it's recent.
#' @param wait \code{(Duration)} to wait for the file to appear in the download directory. Relevant when using browser automation.
#' @return \code{(logical)} as to whether the extraction was successful
#' @export

hud_export_extract <- function(extract_path = fs::path("inst", "extdata", "export"),
                               delete_archive = TRUE, moment = Sys.Date(),
                               wait = lubridate::minutes(2)) {
  # Use the current working directory to look for the file
  downloads <- fs::path_expand(".")

  # Check if the provided path is a single archive file
  if (!(stringr::str_detect(downloads, "(?:7z$)|(?:zip$)") && fs::file_exists(downloads))) {
    # List HUD files in the current directory
    dls <- fs::dir_ls(downloads, regexp = "^hud", type = "file")
    dl_times <- purrr::map_dbl(dls, ~ fs::file_info(.x)$modification_time)

    if (length(dl_times) == 0) {
      cli::cli_alert(paste0("No HUD Export found in ", downloads, ". Waiting ", wait, " minutes."))
    }

    wait_until <- Sys.time() + wait
    .recent <- dl_times > as.numeric(moment)

    # Wait for a recent file to appear
    while (!any(.recent) && Sys.time() < wait_until) {
      Sys.sleep(5)
      dls <- fs::dir_ls(downloads, regexp = "^hudx", type = "file")
      dl_times <- purrr::map_dbl(dls, ~ fs::file_info(.x)$modification_time)
      .recent <- dl_times > as.numeric(moment)
    }
  } else {
    f <- downloads
  }

  if (exists(".recent") && any(.recent)) {
    f <- dls[.recent]
  }

  if (length(f) > 0 && fs::file_exists(f)) {
    fs::dir_create(extract_path)
    # Calculate last update time in the extraction directory
    extracted_files <- fs::dir_ls(extract_path, type = "file")
    if (length(extracted_files) > 0) {
      .last_update <- mean(purrr::map_dbl(extracted_files, ~ fs::file_info(.x)$modification_time), na.rm = TRUE)
    } else {
      .last_update <- NA
      cli::cli_warn("No files detected in the extraction path.")
    }

    # Calculate the update time for the archive
    zip_metadata <- tryCatch(unzip(f, list = TRUE), error = function(e) NULL)
    if (!is.null(zip_metadata) && "Date" %in% names(zip_metadata)) {
      # Assuming you want the date and time of the most recent file in the archive
      .zip_update <- max(as.POSIXct(zip_metadata$Date, tz = "UTC"), na.rm = TRUE)
    } else {
      .zip_update <- NA
      cli::cli_warn("Failed to calculate zip update time.")
    }

    # Extract if needed
    if (is.na(.last_update) || .last_update < .zip_update) {
      utils::unzip(f, exdir = extract_path)
    } else if (!is.na(.last_update) && .last_update > .zip_update) {
      cli::cli_inform("Current export is already up to date. No extraction performed.")
    }

    # Delete the archive if specified
    if (delete_archive) {
      fs::file_delete(f)
    }
  } else {
    cli::cli_alert("No HUD Export found in {.path {downloads}} with creation time greater than ", moment)
  }
}

