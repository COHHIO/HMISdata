#' Upload Data Frame to S3 in Various Formats
#'
#' @param data \code{(data.frame)} Data frame to upload
#' @param file_name \code{(character)} Base name for the uploaded file (without extension)
#' @param format \code{(character)} Format to save data in: "csv", "parquet", or "feather"
#' @param bucket \code{(character)} Name of the S3 bucket for upload
#' @param folder \code{(character)} Folder within the bucket where file will be stored
#' @param region \code{(character)} AWS region
#' @param overwrite \code{(logical)} Whether to overwrite if file exists
#' @return \code{(logical)} TRUE if successful, FALSE otherwise
#' @export
upload_hmis_data <- function(
    data,
    file_name,
    format = c("parquet", "feather", "csv"),
    bucket = "hud.csv-daily",
    folder = "hmis_output",
    region = "us-east-2",
    overwrite = TRUE
) {
  format <- match.arg(format)

  # Determine file extension based on format
  extension <- switch(format,
                      "csv" = ".csv",
                      "parquet" = ".parquet",
                      "feather" = ".feather"
  )

  # Add extension to file name if not already present
  if (!grepl(paste0(extension, "$"), file_name, ignore.case = TRUE)) {
    file_name <- paste0(file_name, extension)
  }

  tryCatch({
    # Generate local temporary filename
    local_file <- fs::path(
      fs::path_temp(),
      paste0("hmis_upload_", file_name)
    )

    # Construct the full S3 key (path)
    s3_key <- fs::path(folder, file_name)

    cli::cli_alert_info("Writing data to temporary {format} file...")

    # Write data frame in the specified format
    switch(format,
           "csv" = {
             vroom::vroom_write(data, local_file, delim = ",")
           },
           "parquet" = {
             arrow::write_parquet(data, local_file)
           },
           "feather" = {
             arrow::write_feather(data, local_file)
           }
    )

    # Check if file exists and respect overwrite parameter
    if (!overwrite) {
      file_exists <- aws.s3::object_exists(
        object = s3_key,
        bucket = bucket,
        region = region
      )

      if (file_exists) {
        cli::cli_alert_warning("File {file_name} already exists and overwrite=FALSE. Skipping upload.")
        fs::file_delete(local_file)
        return(FALSE)
      }
    }

    cli::cli_alert_info("Uploading {file_name} to S3...")
    # Upload file to S3
    result <- aws.s3::put_object(
      file = local_file,
      object = s3_key,
      bucket = bucket,
      region = region
    )

    # Delete the temporary file
    fs::file_delete(local_file)

    # Return result status
    if (result) {
      cli::cli_alert_success("Successfully uploaded {file_name} to S3")
    } else {
      cli::cli_alert_danger("Failed to upload {file_name} to S3")
    }
    return(result)
  }, error = function(e) {
    cli::cli_alert_danger("Error uploading {file_name}: {e$message}")
    return(FALSE)
  })
}
