#' Download and Extract HUD Export from S3
#'
#' @param bucket \code{(character)} Name of the S3 bucket
#' @param s3_key \code{(character)} S3 object key (path) for the HUD export zip (optional)
#' @param extract_path \code{(character)} Path where the archive will be extracted
#' @param delete_archive \code{(logical)} Whether to delete the downloaded archive after extraction
#' @param delete_s3_object \code{(logical)} Whether to delete the object from S3 after download
#' @param moment \code{(POSIXct/Date)} Time point to validate archive recency
#' @return \code{(logical)} Success of download and extraction
#' @export
load_hud_export <- function(
    bucket = "hud.csv-daily",
    prefix = "HMIS",
    region = "us-east-2",
    s3_key = NULL,
    extract_path = fs::path("data", "hmis"),
    delete_archive = TRUE,
    delete_s3_object = FALSE,
    moment = Sys.Date()
) {

  tryCatch({
    # Find latest export
    cli::cli_alert_info("Finding latest HUD export...")
    s3_key <- find_latest_hud_export(bucket, prefix, region)

    # Generate local filename
    local_file <- fs::path(
      fs::path_temp(),
      paste0("hud_export_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".zip")
    )

    # Download file
    cli::cli_alert_info("Downloading from S3...")
    aws.s3::save_object(
      object = s3_key,  # Now using just the key string
      bucket = bucket,
      file = local_file
    )

    # Extract files
    cli::cli_alert_info("Extracting files...")
    success <- extract_hud_export(
      archive_path = local_file,
      extract_path = extract_path,
      delete_archive = delete_archive
    )

    if (!success) {
      stop("Extraction failed")
    }

    # Clean up S3 if requested
    if (delete_s3_object) {
      cli::cli_alert_info("Cleaning up S3 object...")
      aws.s3::delete_object(
        object = s3_key,  # Now using just the key string
        bucket = bucket
      )
    }

    # Load extracted files
    cli::cli_alert_success("Loading data...")
    files <- fs::dir_ls(extract_path, glob = "*.csv")
    data <- lapply(files, read.csv)
    names(data) <- tools::file_path_sans_ext(basename(files))

  }, error = function(e) {
    cli::cli_alert_error("Error: {e$message}")
    NULL
  })
}
