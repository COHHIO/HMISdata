#' @title Load and Process Project Data
#' @description Loads Project data from CSV and processes it with related CoC data
#' @param extract_path Path where the HUD export files are located
#' @param regions Optional data frame containing region definitions
#' @return Processed Project data with CoC information
#' @export
load_project <- function(extract_path = fs::path("data", "hmis"), regions = NULL) {
  # Validate inputs
  if (!fs::dir_exists(extract_path)) {
    stop("Extract path not found: ", extract_path)
  }

  # Load Project and ProjectCoC data
  project_path <- fs::path(extract_path, "Project.csv")
  project_coc_path <- fs::path(extract_path, "ProjectCoC.csv")

  if (!fs::file_exists(project_path)) {
    stop("Project.csv not found in extract path")
  }
  if (!fs::file_exists(project_coc_path)) {
    stop("ProjectCoC.csv not found in extract path")
  }

  # Read data
  Project <- read.csv(project_path)
  ProjectCoC <- read.csv(project_coc_path)

  # Process Project data
  Project <- Project |>
    # Remove any test/training projects
    dplyr::filter(!grepl("^zz", ProjectName, ignore.case = TRUE)) |>
    # Ensure ProjectID is character
    dplyr::mutate(ProjectID = as.character(ProjectID))

  # Add region information if provided
  if (!is.null(regions)) {
    Project <- add_regions(Project, regions)
  }

  # Join with ProjectCoC data
  Project <- Project |>
    dplyr::left_join(
      ProjectCoC |>
        dplyr::select(ProjectID, CoCCode) |>
        dplyr::distinct(),
      by = "ProjectID"
    )

  # Create Mahoning projects subset if OH-504 exists in data
  mahoning_projects <- NULL
  if (any(ProjectCoC$CoCCode == "OH-504")) {
    mahoning_projects <- ProjectCoC |>
      dplyr::filter(CoCCode == "OH-504") |>
      dplyr::left_join(
        Project |> dplyr::select(ProjectID, ProjectTypeCode, ProjectName),
        by = "ProjectID"
      ) |>
      dplyr::filter(!grepl("^zz", ProjectName, ignore.case = TRUE)) |>
      dplyr::distinct(ProjectID, .keep_all = TRUE)

    mahoning_projects <- stats::setNames(
      mahoning_projects$ProjectID,
      mahoning_projects$ProjectTypeCode
    )
  }

  return(list(
    Project = Project,
    mahoning_projects = mahoning_projects
  ))
}

#' @title Add Region Information to Project Data
#' @description Helper function to add region information to Project data
#' @param Project Project data frame
#' @param regions Regions data frame
#' @return Project data frame with added region information
#' @keywords internal
add_regions <- function(Project, regions) {
  if (!("RegionName" %in% names(regions))) {
    stop("Regions data frame must contain RegionName column")
  }

  Project |>
    dplyr::left_join(
      regions |> dplyr::select(ProjectID, RegionName),
      by = "ProjectID"
    )
}
