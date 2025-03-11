#' @title Load Services Data
#' @description Loads Services data from CSV
#' @param extract_path Path where the HUD export files are located
#' @return Services data
#' @export
load_services <- function() {
  Services <- load_hmis_csv("Services.csv")

  return(Services)
}
