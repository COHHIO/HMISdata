
library(testthat)
library(dplyr)
library(fs)

# Create temporary test directory and files
setup <- function() {
  # Create temp directory
  tmp_dir <- fs::path(tempdir(), "test_hmis")
  fs::dir_create(tmp_dir)

  # Create sample Disabilities.csv
  disabilities_data <- data.frame(
    DisabilitiesID = c("A_1", "B_2", "C_3"),
    EnrollmentID = c("E1", "E2", "E3"),
    PersonalID = c("P1", "P2", "P3"),
    InformationDate = c("2024-01-01", "2024-01-02", "2024-01-03"),
    DisabilityType = c(1, 2, 3),
    DisabilityResponse = c(1, 0, 1),
    stringsAsFactors = FALSE
  )
  write.csv(disabilities_data, fs::path(tmp_dir, "Disabilities.csv"), row.names = FALSE)

  list(
    tmp_dir = tmp_dir,
    disabilities_data = disabilities_data
  )
}

# Clean up test files
cleanup <- function(tmp_dir) {
  fs::dir_delete(tmp_dir)
}

test_that("load_disabilities loads data correctly", {
  test_env <- setup()

  # Load the disabilities data
  result <- load_disabilities(test_env$tmp_dir)

  # Test the structure of the loaded data
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), nrow(test_env$disabilities_data))
  expect_equal(ncol(result), ncol(test_env$disabilities_data))

  # Test that all expected columns are present
  expected_columns <- c("DisabilitiesID", "EnrollmentID", "PersonalID",
                        "InformationDate", "DisabilityType", "DisabilityResponse")
  expect_true(all(expected_columns %in% names(result)))

  # Test that sample data matches
  expect_equal(result$DisabilitiesID[1], "A_1")
  expect_equal(result$EnrollmentID[1], "E1")
  expect_equal(result$DisabilityType[1], 1)

  cleanup(test_env$tmp_dir)
})

test_that("load_disabilities handles missing file correctly", {
  # Test with non-existent directory
  expect_error(
    load_disabilities("nonexistent_directory"),
    "Disabilities.csv not found in extract path"
  )

  # Test with empty directory
  tmp_dir <- fs::path(tempdir(), "empty_test_dir")
  fs::dir_create(tmp_dir)

  expect_error(
    load_disabilities(tmp_dir),
    "Disabilities.csv not found in extract path"
  )

  fs::dir_delete(tmp_dir)
})

test_that("load_disabilities handles empty file", {
  tmp_dir <- fs::path(tempdir(), "test_hmis_empty")
  fs::dir_create(tmp_dir)

  # Create empty Disabilities.csv with only headers
  empty_disabilities_data <- data.frame(
    DisabilitiesID = character(),
    EnrollmentID = character(),
    PersonalID = character(),
    InformationDate = character(),
    DisabilityType = numeric(),
    DisabilityResponse = numeric(),
    stringsAsFactors = FALSE
  )
  write.csv(empty_disabilities_data, fs::path(tmp_dir, "Disabilities.csv"), row.names = FALSE)

  # Load the empty disabilities data
  result <- load_disabilities(tmp_dir)

  # Test the structure of the loaded data
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
  expect_equal(ncol(result), ncol(empty_disabilities_data))

  # Test that all expected columns are present
  expected_columns <- c("DisabilitiesID", "EnrollmentID", "PersonalID",
                        "InformationDate", "DisabilityType", "DisabilityResponse")
  expect_true(all(expected_columns %in% names(result)))

  cleanup(tmp_dir)
})

test_that("load_disabilities preserves data types", {
  test_env <- setup()

  result <- load_disabilities(test_env$tmp_dir)

  # Test data types of key columns
  expect_type(result$DisabilitiesID, "character")
  expect_type(result$EnrollmentID, "character")
  expect_type(result$PersonalID, "character")
  expect_type(result$DisabilityType, "integer")
  expect_type(result$DisabilityResponse, "integer")

  cleanup(test_env$tmp_dir)
})
