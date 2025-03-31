#' Load Specific HMIS CSV File from S3
#'
#' @param file_name \code{(character)} Name of the CSV file to load (without path)
#' @param bucket \code{(character)} Name of the S3 bucket
#' @param folder \code{(character)} Folder within the bucket where CSV files are stored
#' @param region \code{(character)} AWS region
#' @return \code{(data.frame)} Data frame containing the loaded CSV data
#' @export
load_hmis_csv <- function(
    file_name,
    bucket = "hud.csv-daily",
    folder = "hmis_files",
    region = "us-east-2",
    col_types = NULL
) {
  tryCatch({
    # Construct the full S3 key (path)
    s3_key <- fs::path(folder, file_name)

    # Generate local temporary filename
    local_file <- fs::path(
      fs::path_temp(),
      paste0("hmis_", file_name)
    )

    cli::cli_alert_info("Downloading {file_name} from S3...")
    # Download file
    aws.s3::save_object(
      object = s3_key,
      bucket = bucket,
      file = local_file,
      region = region
    )

    # Load the CSV file

    # If no column specs provided, use character as default
    if (is.null(col_types)) {
      col_types <- readr::cols(.default = readr::col_character())
    }

    cli::cli_alert_info("Loading data...")
    data <- vroom::vroom(local_file, col_types = col_types)

    # Delete the temporary file
    fs::file_delete(local_file)

    # Return the loaded data
    return(data)

  }, error = function(e) {
    cli::cli_alert_danger("Error loading {file_name}: {e$message}")
    NULL
  })
}
