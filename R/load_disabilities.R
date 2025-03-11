#' @title Load Disabilities Data
#' @description Loads Disabilities data from CSV
#' @param extract_path Path where the HUD export files are located
#' @return Disabilities data
#' @export
load_disabilities <- function() {
  Disabilities <- load_hmis_csv("Disabilities.csv")

  return(Disabilities)
}
