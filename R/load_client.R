#' @title Load and Process Client Data
#' @description Loads Client data from CSV and applies PII redaction
#' @param extract_path Path where the HUD export files are located
#' @return Processed Client data with redacted PII
#' @export
load_client <- function(extract_path = fs::path("data", "hmis")) {
  # Read and redact - we know it's raw data from CSV
  Client <- load_hmis_csv("Client.csv") |>
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
  # Input validation
  if (is.null(Client)) stop("Input data frame cannot be NULL")
  if (!is.data.frame(Client)) stop("Input must be a data frame")

  # Handle empty data frame
  if (nrow(Client) == 0) return(Client)

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

  # Create safe versions of columns if they don't exist
  if (!"NameDataQuality" %in% names(Client)) Client$NameDataQuality <- NA
  if (!"FirstName" %in% names(Client)) Client$FirstName <- NA
  if (!"SSN" %in% names(Client)) Client$SSN <- NA
  if (!"SSNDataQuality" %in% names(Client)) Client$SSNDataQuality <- NA

  # Apply PII redaction
  Client <- Client |>
    dplyr::mutate(
      FirstName = dplyr::case_when(
        NameDataQuality %in% c(8, 9) ~ "DKR",
        NameDataQuality == 2 ~ "Partial",
        NameDataQuality == 99 |
          is.na(NameDataQuality) |
          FirstName == "Anonymous" ~ "Missing",
        TRUE ~ "ok"
      ),
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

  # Remove PII columns if they exist
  pii_cols <- c("LastName", "MiddleName", "NameSuffix")
  Client[pii_cols] <- NULL

  return(Client)
}
