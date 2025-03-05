# Alternative Approach with Explanation

#' @title Load Referrals with Flexible Data Source
#' @description Loads and processes referral data with support for multiple input methods
#' @param data data.frame. Optional pre-loaded referrals data
#' @param app_env environment. Optional environment for storing results
#' @param log_level character. Level of logging detail
#' @return Updated app_env or list of processed data
#' @export

load_referrals <- function(data = NULL,
                           use_s3 = TRUE,
                           bucket = "looker-daily",
                           prefix = "CE_Referrals_extras",
                           region = "us-east-2",
                           local_path = fs::path("data", "looker"),
                           delete_s3_object = FALSE,
                           app_env = NULL,
                           log_level = "INFO") {

  cli::cli_alert_info("Loading referral data...")

  # 1. Load Data (Either from S3 or Provided Data)
  if (use_s3) {
    cli::cli_alert_info("Fetching referrals data from S3...")
    s3_data <- load_looker_data(bucket, prefix, region, local_path, delete_s3_object)

    if (!is.null(s3_data) && "CE_Referrals_extras" %in% names(s3_data)) {
      data <- s3_data[["CE_Referrals_extras"]]
      cli::cli_alert_success("Referral data loaded from S3.")
    } else {
      cli::cli_alert_warning("No referral data found in S3.")
      return(NULL)
    }
  }

  if (is.null(data)) {
    cli::cli_alert_warning("No data provided for processing.")
    return(NULL)
  }

  # 2. Data Processing Pipeline
  cli::cli_alert_info("Processing referrals data")

  # Process data
  processed_data <- tryCatch({
    # Rename columns
    Referrals <- referrals_data |>
      dplyr::rename_with(
        .cols = -dplyr::matches("(?:^PersonalID)|^(?:^UniqueID)"),
        ~ paste0("R_", .x)
      )

    # Clean and transform
    Referrals <- Referrals |>
      dplyr::mutate(
        R_ReferringPTC = stringr::str_remove(
          R_ReferringPTC,
          "\\s\\(disability required(?: for entry)?\\)$"
        ),
        R_ReferringPTC = dplyr::if_else(
          R_ReferringPTC == "Homeless Prevention",
          "Homelessness Prevention",
          R_ReferringPTC
        ),
        R_ReferringPTC = dplyr::if_else(
          R_ReferringPTC == "",
          NA_character_,
          R_ReferringPTC
        ),
        R_ReferringPTC = HMIS::hud_translations$`2.02.6 ProjectType`(R_ReferringPTC)
      )

    # Save unfiltered version
    Referrals_full <- Referrals

    # Define filtering expressions
    referrals_expr <- rlang::exprs(
      housed = R_ExitHoused == "Housed",
      is_last = R_IsLastReferral == "Yes",
      is_last_enroll = R_IsLastEnrollment == "Yes",
      is_active = R_ActiveInProject == "Yes",
      accepted = stringr::str_detect(R_ReferralResult, "accepted$"),
      coq = R_ReferralCurrentlyOnQueue == "Yes"
    )

    # Create summary expressions
    referral_result_summarize <- purrr::map(
      referrals_expr,
      ~ rlang::expr(isTRUE(any(!!.x, na.rm = TRUE)))
    )

    # Apply filters
    Referrals <- Referrals |>
      filter_dupe_soft(
        !!!referrals_expr,
        key = PersonalID
      )

    # Return as list
    list(
      Referrals = Referrals,
      Referrals_full = Referrals_full,
      referral_result_summarize = referral_result_summarize
    )
  }, error = function(e) {
    log_processing("Failed to process referrals", "ERROR")
    stop(e$message)
  })

  # 3. Handle Results
  if (!is.null(app_env)) {
    # Update app_env if provided
    app_env$Referrals <- processed_data$Referrals
    app_env$Referrals_full <- processed_data$Referrals_full
    app_env$referral_result_summarize <- processed_data$referral_result_summarize
    return(app_env)
  } else {
    # Return processed data directly
    return(processed_data)
  }
}

#### Helper functions

#' @title Filter duplicates without losing any values from `key`
#'
#' @param .data \code{(data.frame)} Data with duplicates
#' @param ... \code{(expressions)} filter expressions with which to filter
#' @param key \code{(name)} of the column key that will be grouped by and for which at least one observation will be preserved.
#'
#' @return \code{(data.frame)} without duplicates
#' @export

filter_dupe_soft <- function(.data, ..., key) {
  .key <- rlang::enexpr(key)
  out <- .data
  x <- janitor::get_dupes(.data, !!.key) |>
    dplyr::arrange(PersonalID)

  clients <- dplyr::pull(x, !!.key) |> unique()
  .exprs <- rlang::enquos(...)
  to_add <- list()
  for (ex in .exprs) {
    new <- dplyr::filter(x, !!ex)

    new_n <- dplyr::summarise(dplyr::group_by(new, !!.key), n = dplyr::n())
    .to_merge <- dplyr::filter(new_n, n == 1) |> dplyr::pull(!!.key)

    # if some were reduced but not to one
    .reduced <- dplyr::left_join(new_n,
                                 dplyr::summarise(dplyr::group_by(x, !!.key), n = dplyr::n()), by = rlang::expr_deparse(.key), suffix = c("_new", "_old")) |>
      dplyr::filter(n_new < n_old & n_new > 1) |>
      dplyr::pull(!!.key)

    if (UU::is_legit(.to_merge)) {
      # remove rows where key is reduced to one, bind the deduplicated rows
      to_add <- append(to_add, list(dplyr::select(new, -dupe_count) |>
                                      dplyr::filter(!!.key %in% .to_merge)))
      # filter to_merge from dupes
      x <- dplyr::filter(x, !((!!.key) %in% .to_merge))
    }

    if (UU::is_legit(.reduced)) {
      # filter reduced from dupes
      x <- dplyr::filter(x, !((!!.key) %in% .reduced ) # is not one that was reduced
                         | (!!.key %in% .reduced & !!ex) # or matched the filter
      )

    }
  }
  to_add <- dplyr::bind_rows(to_add)
  out <- dplyr::filter(out, !(!!.key %in% c(to_add[[.key]], x[[.key]]))) |>
    dplyr::bind_rows(to_add, x) |>
    dplyr::select(-dplyr::any_of("dupe_count"))

  if (anyDuplicated(out[[.key]])) {
    rlang::warn("Duplicates still exist.")
  }
  out
}
