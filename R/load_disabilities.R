#' @title Load Disabilities Data
#' @description Loads Disabilities data from CSV
#' @param extract_path Path where the HUD export files are located
#' @return Disabilities data
#' @export
load_disabilities <- function(extract_path = fs::path("data", "hmis")) {
  disabilities_path <- fs::path(extract_path, "Disabilities.csv")
  if (!fs::file_exists(disabilities_path)) {
    stop("Disabilities.csv not found in extract path: ", extract_path)
  }

  # Read and redact - we know it's raw data from CSV
  Disabilities <- read.csv(disabilities_path)

  return(Disabilities)
}
