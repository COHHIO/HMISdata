#' @title Load and Process Project Data
#' @description Loads Project data from CSV and processes it with related CoC data
#' @param extract_path Path where the HUD export files are located
#' @param regions Optional data frame containing region definitions
#' @return Processed Project data with CoC information
#' @export
load_project <- function(regions = NULL) {

  # Read data
  Project <- load_hmis_csv("Project.csv")

}

#' @title Load Project CoC Data
#' @description Loads Project CoC data from CSV
#' @param extract_path Path where the HUD export files are located
#' @return Project CoC data
#' @export
load_project_coc <- function() {
  ProjectCoC <- load_hmis_csv("ProjectCoC.csv")

  return(ProjectCoC)
}
