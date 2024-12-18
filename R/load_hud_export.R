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
    s3_key = NULL,
    extract_path = file.path("inst", "extdata", "export"),
    delete_archive = TRUE,
    delete_s3_object = FALSE,
    moment = Sys.Date()
) {
  # If no s3_key provided, find the latest HUD export
  if (is.null(s3_key)) {
    s3_key <- tryCatch({
      find_latest_hud_export(bucket)
    }, error = function(e) {
      warning("Could not find HUD export in bucket: ", e$message)
      return(NULL)
    })

    # If no key found, return FALSE
    if (is.null(s3_key)) {
      return(FALSE)
    }
  }

  # Ensure local directories exist using fs
  fs::dir_create(extract_path)

  # Generate a consistent filename
  local_filename <- file.path(
    paste0("hud_export_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".zip")
  )

  # Download from S3
  tryCatch({
    # Attempt to download the file
    aws.s3::save_object(
      object = s3_key$Contents$Key,
      bucket = bucket,
      file = local_filename
    )
    # If download successful, use existing extraction function
    extraction_result <- hud_export_extract()

    # Delete S3 object if requested and extraction was successful
    if (delete_s3_object && extraction_result) {
      aws.s3::delete_object(
        object = s3_key,
        bucket = bucket
      )
    }

    # Return extraction result
    return(extraction_result)

  }, error = function(e) {
    # Simplified error handling
    warning("S3 Download failed: ", e$message)
    return(FALSE)
  }, finally = {
    # Clean up temporary files if they exist and weren't already deleted
    if (delete_archive && file.exists(local_filename)) {
      file.remove(local_filename)
    }
  })
}
