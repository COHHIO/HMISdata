#' @title Load and Process Client Data
#' @description Loads Client data from CSV and applies PII redaction
#' @param extract_path Path where the HUD export files are located
#' @return Processed Client data with redacted PII
#' @export
load_client <- function(extract_path = fs::path("data", "hmis")) {
  client_path <- fs::path(extract_path, "Client.csv")
  if (!fs::file_exists(client_path)) {
    stop("Client.csv not found in extract path: ", extract_path)
  }

  # Read and redact - we know it's raw data from CSV
  Client <- read.csv(client_path) |>
    Client_redact()

  return(Client)
}

#' @title Redact PII from Client Data
#' @description Redacts personally identifiable information while applying data quality rules
#' @param Client Client data frame
#' @param clients_to_filter Optional list of client IDs to filter out
#' @return Redacted Client data
#' @export
Client_redact <- function(Client, clients_to_filter = NULL) {
  # Apply client filtering if needed
  if (!is.null(clients_to_filter)) {
    id_cols <- intersect(colnames(Client), c("PersonalID", "UniqueID"))
    if (length(id_cols) > 0) {
      for (col in id_cols) {
        if (col == "PersonalID") {
          Client <- dplyr::filter(Client, !PersonalID %in% clients_to_filter)
        } else {
          Client <- dplyr::filter(Client, !UniqueID %in% names(clients_to_filter))
        }
      }
    }
  }

  # Apply PII redaction
  Client |>
    dplyr::mutate(
      FirstName = dplyr::case_when(
        NameDataQuality %in% c(8, 9) ~ "DKR",
        NameDataQuality == 2 ~ "Partial",
        NameDataQuality == 99 |
          is.na(NameDataQuality) |
          FirstName == "Anonymous" ~ "Missing",
        TRUE ~ "ok"
      ),
      LastName = NULL,
      MiddleName = NULL,
      NameSuffix = NULL,
      SSN = dplyr::case_when(
        substr(SSN, 1, 5) == "00000" ~ "Four Digits Provided",
        (is.na(SSN) & !SSNDataQuality %in% c(8, 9)) |
          is.na(SSNDataQuality) | SSNDataQuality == 99 ~ "Missing",
        SSNDataQuality %in% c(8, 9) ~ "DKR",
        substr(SSN, 1, 3) %in% c("000", "666") |
          substr(SSN, 1, 1) == 9 |
          substr(SSN, 4, 5) == "00" |
          substr(SSN, 6, 9) == "0000" |
          SSN %in% c(
            111111111,
            222222222,
            333333333,
            444444444,
            555555555,
            777777777,
            888888888,
            123456789
          ) ~ "Invalid",
        TRUE ~ "ok"
      ))
}
