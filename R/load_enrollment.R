#' @title Load Enrollment as Enrollment_extra_Client_Exit_HH_CL_AaE
#' @param Enrollment_extras From Clarity Looker API Extras
#'
#' @export
#'

load_enrollment <- function(Enrollment,
                            EnrollmentCoC,
                            Enrollment_extras,
                            Exit,
                            Client,
                            Project,
                            Referrals,
                            rm_dates,
                            app_env = get_app_env(e = rlang::caller_env())) {

  if (is_app_env(app_env))
    app_env$set_parent(missing_fmls())

  Enrollment <- load_hmis_csv("Enrollment.csv")

  # getting EE-related data, joining both to Enrollment
  Enrollment_extra_Client_Exit_HH_CL_AaE <- dplyr::left_join(Enrollment, Enrollment_extras, by = UU::common_names(Enrollment, Enrollment_extras)) |>
    # Add Exit
    Enrollment_add_Exit(Exit) |>
    # Add Households
    Enrollment_add_Household(Project, rm_dates = rm_dates) |>
    # Add Veteran Coordinated Entry
    Enrollment_add_VeteranCE(VeteranCE = VeteranCE) |>
    # # Add Client Location from EnrollmentCoC
    # Enrollment_add_ClientLocation(EnrollmentCoC) |>
    # # Add Client AgeAtEntry
    Enrollment_add_AgeAtEntry_UniqueID(Client) |>
    dplyr::left_join(dplyr::select(Client,-dplyr::any_of(
      c(
        "DateCreated",
        "DateUpdated",
        "UserID",
        "DateDeleted",
        "ExportID"
      )
    )),
    by = c("PersonalID", "UniqueID")) |>
    Enrollment_add_HousingStatus()

  UU::join_check(Enrollment, Enrollment_extra_Client_Exit_HH_CL_AaE)

  app_env$gather_deps(Enrollment_extra_Client_Exit_HH_CL_AaE)

}
