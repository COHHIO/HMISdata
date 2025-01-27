# Create mock data for testing
create_mock_client_data <- function() {
  data.frame(
    PersonalID = c("1", "2", "3", "4", "5"),
    UniqueID = c("A", "B", "C", "D", "E"),
    FirstName = c("John", "Jane", "Anonymous", "Bob", "Alice"),
    LastName = c("Doe", "Smith", "Unknown", "Jones", "Brown"),
    MiddleName = c("A", "B", "C", "D", "E"),
    NameSuffix = c("Jr", "Sr", "", "III", ""),
    NameDataQuality = c(1, 2, 99, 8, NA),
    SSN = c("123456789", "00000####", "000666000", "999887777", NA),
    SSNDataQuality = c(1, 1, 8, 9, 99),
    stringsAsFactors = FALSE
  )
}

# Tests for Client_redact function
test_that("Client_redact handles PII redaction correctly", {
  test_data <- create_mock_client_data()
  result <- Client_redact(test_data)

  # Test FirstName redaction
  expect_equal(result$FirstName[1], "ok")  # Normal name
  expect_equal(result$FirstName[2], "Partial")  # NameDataQuality = 2
  expect_equal(result$FirstName[3], "Missing")  # Anonymous
  expect_equal(result$FirstName[4], "DKR")  # NameDataQuality = 8
  expect_equal(result$FirstName[5], "Missing")  # NA NameDataQuality

  # Test removal of name fields
  expect_false("LastName" %in% names(result))
  expect_false("MiddleName" %in% names(result))
  expect_false("NameSuffix" %in% names(result))

  # Test SSN redaction
  expect_equal(result$SSN[1], "Invalid")  # Invalid SSN pattern
  expect_equal(result$SSN[2], "Four Digits Provided")  # 00000#### pattern
  expect_equal(result$SSN[3], "DKR")  # SSNDataQuality = 8
  expect_equal(result$SSN[4], "DKR")  # SSNDataQuality = 9
  expect_equal(result$SSN[5], "Missing")  # SSNDataQuality = 99
})

test_that("Client_redact handles client filtering correctly", {
  test_data <- create_mock_client_data()
  clients_to_filter <- c("1", "2")
  names(clients_to_filter) <- c("A", "B")

  result <- Client_redact(test_data, clients_to_filter)

  # Test filtering by PersonalID
  expect_false("1" %in% result$PersonalID)
  expect_false("2" %in% result$PersonalID)

  # Test filtering by UniqueID
  expect_false("A" %in% result$UniqueID)
  expect_false("B" %in% result$UniqueID)

  # Test remaining records
  expect_equal(nrow(result), 3)
})

# Tests for load_client function
test_that("load_client handles missing file correctly", {
  temp_dir <- tempdir()
  expect_error(
    load_client(temp_dir),
    "Client.csv not found in extract path"
  )
})

test_that("load_client loads and processes data correctly", {
  # Create temporary directory and save mock data
  temp_dir <- tempdir()
  test_data <- create_mock_client_data()
  write.csv(test_data, file.path(temp_dir, "Client.csv"), row.names = FALSE)

  # Test loading and processing
  result <- load_client(temp_dir)

  # Basic checks
  expect_s3_class(result, "data.frame")
  expect_true("FirstName" %in% names(result))
  expect_false("LastName" %in% names(result))

  # Clean up
  file.remove(file.path(temp_dir, "Client.csv"))
})

test_that("Client_redact handles empty or invalid input", {
  # Test with empty data frame
  empty_df <- data.frame()
  result <- Client_redact(empty_df)
  expect_equal(nrow(result), 0)

  # Test with NULL input
  expect_error(Client_redact(NULL), "Input data frame cannot be NULL")

  # Test with non-data frame input
  expect_error(Client_redact(list()), "Input must be a data frame")

  # Test with missing required columns
  incomplete_df <- data.frame(
    PersonalID = c("1", "2"),
    FirstName = c("John", "Jane")
  )
  result <- Client_redact(incomplete_df)
  expect_true("FirstName" %in% names(result))
  expect_false("LastName" %in% names(result))
  expect_equal(result$FirstName[1], "Missing")  # Should be "Missing" due to missing NameDataQuality

  # Test with completely minimal data frame
  minimal_df <- data.frame(OtherColumn = c("a", "b"))
  result <- Client_redact(minimal_df)
  expect_true("FirstName" %in% names(result))
  expect_true("SSN" %in% names(result))
  expect_equal(result$FirstName[1], "Missing")
  expect_equal(result$SSN[1], "Missing")
})
