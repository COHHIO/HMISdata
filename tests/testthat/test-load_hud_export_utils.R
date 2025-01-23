# tests/testthat/test-load_hud_export_utils.R

library(testthat)
library(mockery)
library(lubridate)
library(withr)

describe("find_latest_hud_export", {
  # Mock S3 objects
  mock_s3_objects <- list(
    list(
      Key = "HMIS/cohhio_20240101.zip",
      LastModified = "2024-01-01T10:00:00"
    ),
    list(
      Key = "HMIS/cohhio_20240115.zip",
      LastModified = "2024-01-15T10:00:00"
    ),
    list(
      Key = "HMIS/other_file.txt",
      LastModified = "2024-01-16T10:00:00"
    )
  )

  it("finds the most recent HUD export file", {
    # Mock aws.s3::get_bucket
    mock_get_bucket <- mock(mock_s3_objects)
    stub(find_latest_hud_export, "aws.s3::get_bucket", mock_get_bucket)

    result <- find_latest_hud_export()
    expect_equal(result, "HMIS/cohhio_20240115.zip")
  })

  it("throws error when no HUD files found", {
    # Mock empty bucket
    mock_get_bucket <- mock(list())
    stub(find_latest_hud_export, "aws.s3::get_bucket", mock_get_bucket)

    expect_error(
      find_latest_hud_export(),
      "No HUD export files found in bucket"
    )
  })

  it("uses custom bucket and prefix", {
    mock_get_bucket <- mock(mock_s3_objects)
    stub(find_latest_hud_export, "aws.s3::get_bucket", mock_get_bucket)

    result <- find_latest_hud_export(
      bucket = "custom-bucket",
      prefix = "custom-prefix",
      region = "us-west-2"
    )

    expect_called(mock_get_bucket, 1)
    expect_args(
      mock_get_bucket, 1,
      bucket = "custom-bucket",
      prefix = "custom-prefix",
      region = "us-west-2"
    )
  })
})

# Test environment setup for extract_hud_export tests
temp_dir <- tempdir()
test_extract_path <- file.path(temp_dir, "extract")

test_that("extract_hud_export successfully extracts files", {
  # Setup
  dir.create(test_extract_path, showWarnings = FALSE)
  test_files <- c("file1.csv", "file2.csv")

  # Create test files in the extract path
  sapply(test_files, function(f) {
    write.csv(data.frame(x = 1), file = file.path(test_extract_path, f))
  })

  # Create zip file in temp directory
  test_archive <- file.path(test_extract_path, "test.zip")
  withr::with_dir(test_extract_path, {
    zip(test_archive, test_files)
  })

  # Test
  result <- extract_hud_export(
    archive_path = test_archive,
    extract_path = test_extract_path,
    delete_archive = FALSE
  )

  expect_true(result)
  expect_true(file.exists(file.path(test_extract_path, "file1.csv")))
  expect_true(file.exists(file.path(test_extract_path, "file2.csv")))

  # Cleanup
  unlink(test_extract_path, recursive = TRUE)
})

test_that("extract_hud_export handles missing archive gracefully", {
  # Mock cli::cli_alert_error to avoid the export issue
  mock_alert_error <- mock()
  stub(extract_hud_export, "cli::cli_alert_error", mock_alert_error)

  result <- extract_hud_export(
    archive_path = "nonexistent.zip",
    extract_path = test_extract_path
  )

  expect_false(result)
  expect_called(mock_alert_error, 1)
})

test_that("extract_hud_export deletes archive when requested", {
  # Setup
  dir.create(test_extract_path, showWarnings = FALSE)
  test_files <- c("file1.csv", "file2.csv")

  # Create test files in the extract path with old timestamp
  Sys.sleep(1) # Ensure time difference
  sapply(test_files, function(f) {
    write.csv(data.frame(x = 1), file = file.path(test_extract_path, f))
  })

  # Create zip file in extract path
  test_archive <- file.path(test_extract_path, "test.zip")
  withr::with_dir(test_extract_path, {
    # Use newer data to force update
    sapply(test_files, function(f) {
      write.csv(data.frame(x = 2), file = f)
    })
    zip(basename(test_archive), test_files)
  })

  # Remove the newer files to ensure clean test
  sapply(test_files, function(f) {
    unlink(file.path(test_extract_path, f))
  })

  # Verify archive exists before test
  expect_true(file.exists(test_archive))

  # Test
  result <- extract_hud_export(
    archive_path = test_archive,
    extract_path = test_extract_path,
    delete_archive = TRUE
  )

  # Verify results
  expect_true(result)
  expect_false(file.exists(test_archive))

  # Cleanup
  unlink(test_extract_path, recursive = TRUE)
})

test_that("extract_hud_export skips extraction if files are up to date", {
  # Setup
  dir.create(test_extract_path, showWarnings = FALSE)
  test_files <- c("file1.csv", "file2.csv")

  # Create test files in the extract path with old timestamp
  sapply(test_files, function(f) {
    write.csv(data.frame(x = 1), file = file.path(test_extract_path, f))
  })

  Sys.sleep(1)  # Ensure time difference

  # Create zip file in extract path with new files (to force newer timestamps)
  test_archive <- file.path(test_extract_path, "test.zip")
  withr::with_dir(test_extract_path, {
    # Create files with newer timestamp
    sapply(test_files, function(f) {
      write.csv(data.frame(x = 1), file = f)
    })
    zip(basename(test_archive), test_files)
  })

  # First extraction
  extract_hud_export(
    archive_path = test_archive,
    extract_path = test_extract_path,
    delete_archive = FALSE
  )

  # Mock function
  mock_inform <- mockery::mock()

  # Second extraction with mocked cli_inform
  with_mocked_bindings(
    cli_inform = mock_inform,  # Pass mocked function as a named argument
    {
      result <- extract_hud_export(
        archive_path = test_archive,
        extract_path = test_extract_path,
        delete_archive = FALSE
      )
    },
    .package = "cli"
  )

  # Assertions
  expect_true(result)
  expect_args(mock_inform, 1, "Extracted files are up to date")

  # Cleanup
  unlink(test_extract_path, recursive = TRUE)
})

