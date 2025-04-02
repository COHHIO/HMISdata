#' Ohio Homeless Geocodes
#'
#' A dataset containing the mapping of Ohio counties to their respective
#' Geocodes
#'
#' @format A data frame with 88 rows and 3 variables:
#' \describe{
#'   \item{GeographicCode}{Code for the geography}
#'   \item{State}{State abbreviation}
#'   \item{Name}{City or county name}
#'   \item{Type}{Type for name (City or County)}
#'   \item{County}{County for the geography}
#' }
#' @source Ohio Balance of State Continuum of Care
"Geocodes"

#' Ohio Homeless Planning Regions
#'
#' A dataset containing the mapping of Ohio counties to their respective
#' Homeless Planning Regions
#'
#' @format A data frame with 88 rows and 3 variables:
#' \describe{
#'   \item{County}{Name of the Ohio county}
#'   \item{Region}{Region number (0-17)}
#'   \item{RegionName}{Full name of the homeless planning region}
#' }
#' @source Ohio Balance of State Continuum of Care
"Regions"

#' Ohio Homeless Service Areas
#'
#' A dataset containing the mapping of Ohio counties to their respective
#' SSVF service
#'
#' @format A data frame with 88 rows and 2 variables:
#' \describe{
#'   \item{ssvf_service_area}{Name of the SSVF service}
#'   \item{county}{County Name}
#' }
#' @source Ohio Balance of State Continuum of Care
"ServiceAreas"
