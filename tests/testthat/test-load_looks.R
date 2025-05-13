#' #' @title Test Looker Data Loading Functions
#' #' @description Unit tests for load_looker_data.R functions
#' #' @author Trevin Flickinger
#' #' @date 2025-02-19
#'
#' library(testthat)
#' library(mockery)
#' library(aws.s3)
#'
#' # Mock data for S3 objects
#' mock_s3_objects <- list(
#'   list(
#'     Key = "Client_extras_2025-02-19T0743_VWvyGt.csv",
#'     LastModified = "2025-02-19T07:43:00",
#'     Size = 1234
#'   ),
#'   list(
#'     Key = "Client_extras_2025-02-18T0743_ABC123.csv",
#'     LastModified = "2025-02-18T07:43:00",
#'     Size = 1234
#'   ),
#'   list(
#'     Key = "Referrals_extras_2025-02-19T0738_XYZ789.csv",
#'     LastModified = "2025-02-19T07:38:00",
#'     Size = 1234
#'   ),
#'   list(
#'     Key = "invalid_file.txt",
#'     LastModified = "2025-02-19T07:38:00",
#'     Size = 1234
#'   )
#' )
#'
#' #' @title Test Looker Data Loading Functions
#' #' @description Unit tests for load_looker_data.R functions
#' #' @author Your Name
#' #' @date 2025-02-19
#'
#' library(testthat)
#' library(mockery)
#' library(aws.s3)
#'
#' # Mock data for S3 objects
#' mock_s3_objects <- list(
#'   list(
#'     Key = "Client_extras_2025-02-19T0743_VWvyGt.csv",
#'     LastModified = "2025-02-19T07:43:00",
#'     Size = 1234
#'   ),
#'   list(
#'     Key = "Client_extras_2025-02-18T0743_ABC123.csv",
#'     LastModified = "2025-02-18T07:43:00",
#'     Size = 1234
#'   ),
#'   list(
#'     Key = "Referrals_extras_2025-02-19T0738_XYZ789.csv",
#'     LastModified = "2025-02-19T07:38:00",
#'     Size = 1234
#'   ),
#'   list(
#'     Key = "invalid_file.txt",
#'     LastModified = "2025-02-19T07:38:00",
#'     Size = 1234
#'   )
#' )
#'
#' # Test find_latest_looker_files function
#' test_that("find_latest_looker_files identifies latest files correctly", {
#'   # Create mock for aws.s3::get_bucket
#'   mock_get_bucket <- mock(mock_s3_objects)
#'
#'   # Mock the function with proper namespace
#'   local_mocked_bindings(
#'     get_bucket = mock_get_bucket,
#'     .package = "aws.s3"
#'   )
#'
#'   result <- find_latest_looker_files("test-bucket")
#'
#'   # Check number of unique looks found
#'   expect_equal(length(result), 2)  # Client and Referrals
#'
#'   # Check that latest Client file was selected
#'   client_file <- result[[which(sapply(result, function(x) x$look_name == "Client"))]]
#'   expect_equal(client_file$filename, "Client_extras_2025-02-19T0743_VWvyGt.csv")
#'
#'   # Verify look names were extracted correctly
#'   look_names <- sort(sapply(result, function(x) x$look_name))
#'   expect_equal(look_names, c("Client", "Referrals"))
#' })
#'
#' test_that("find_latest_looker_files handles empty bucket", {
#'   mock_get_bucket <- mock(list())
#'
#'   local_mocked_bindings(
#'     get_bucket = mock_get_bucket,
#'     .package = "aws.s3"
#'   )
#'
#'   expect_error(
#'     find_latest_looker_files("test-bucket"),
#'     "No valid Looker files found in bucket"
#'   )
#' })
#'
#' #' @title Test Looker Data Loading Functions
#' #' @description Unit tests for load_looker_data.R functions
#' #' @author Your Name
#' #' @date 2025-02-19
#'
#' library(testthat)
#' library(mockery)
#' library(aws.s3)
#'
#' # Mock data for S3 objects
#' mock_s3_objects <- list(
#'   list(
#'     Key = "Client_extras_2025-02-19T0743_VWvyGt.csv",
#'     LastModified = "2025-02-19T07:43:00",
#'     Size = 1234
#'   ),
#'   list(
#'     Key = "Client_extras_2025-02-18T0743_ABC123.csv",
#'     LastModified = "2025-02-18T07:43:00",
#'     Size = 1234
#'   ),
#'   list(
#'     Key = "Referrals_extras_2025-02-19T0738_XYZ789.csv",
#'     LastModified = "2025-02-19T07:38:00",
#'     Size = 1234
#'   ),
#'   list(
#'     Key = "invalid_file.txt",
#'     LastModified = "2025-02-19T07:38:00",
#'     Size = 1234
#'   )
#' )
#'
#' # Test find_latest_looker_files function
#' test_that("find_latest_looker_files identifies latest files correctly", {
#'   mock_get_bucket <- mock(mock_s3_objects)
#'
#'   local_mocked_bindings(
#'     get_bucket = mock_get_bucket,
#'     .package = "aws.s3"
#'   )
#'
#'   result <- find_latest_looker_files("test-bucket")
#'
#'   # Check number of unique looks found
#'   expect_equal(length(result), 2)  # Client and Referrals
#'
#'   # Check that latest Client file was selected
#'   client_file <- result[[which(sapply(result, function(x) x$look_name == "Client"))]]
#'   expect_equal(client_file$filename, "Client_extras_2025-02-19T0743_VWvyGt.csv")
#'
#'   # Verify look names were extracted correctly
#'   look_names <- sort(sapply(result, function(x) x$look_name))
#'   expect_equal(look_names, c("Client", "Referrals"))
#' })
#'
#' test_that("find_latest_looker_files handles empty bucket", {
#'   mock_get_bucket <- mock(list())
#'
#'   local_mocked_bindings(
#'     get_bucket = mock_get_bucket,
#'     .package = "aws.s3"
#'   )
#'
#'   expect_error(
#'     find_latest_looker_files("test-bucket"),
#'     "No valid Looker files found in bucket"
#'   )
#' })
#'
#' # Test load_looker_data function
#' test_that("load_looker_data loads and processes files correctly", {
#'   # Create temporary directory for test files
#'   temp_dir <- tempfile()
#'   dir.create(temp_dir)
#'   on.exit(unlink(temp_dir, recursive = TRUE))
#'
#'   # Create mock CSV content
#'   mock_csv_content <- "column1,column2\n1,2\n3,4"
#'   mock_csv_file <- file.path(temp_dir, "test.csv")
#'   writeLines(mock_csv_content, mock_csv_file)
#'
#'   # Create mock functions
#'   mock_find_latest <- mock(list(
#'     list(
#'       key = "Client_extras_2025-02-19T0743_VWvyGt.csv",
#'       look_name = "Client",
#'       last_modified = as.POSIXct("2025-02-19 07:43:00"),
#'       filename = "Client_extras_2025-02-19T0743_VWvyGt.csv"
#'     )
#'   ))
#'
#'   mock_save_object <- function(object, bucket, file) {
#'     file.copy(mock_csv_file, file)
#'   }
#'
#'   # Use mockery to stub both functions
#'   stub(load_looker_data, "find_latest_looker_files", mock_find_latest)
#'
#'   local_mocked_bindings(
#'     save_object = mock_save_object,
#'     .package = "aws.s3"
#'   )
#'
#'   result <- load_looker_data(
#'     bucket = "test-bucket",
#'     local_path = temp_dir
#'   )
#'
#'   # Check that data was loaded
#'   expect_type(result, "list")
#'   expect_named(result, "Client")
#'   expect_s3_class(result$Client, "data.frame")
#'   expect_equal(nrow(result$Client), 2)
#'   expect_equal(ncol(result$Client), 2)
#' })
#'
#' test_that("load_looker_data handles errors gracefully", {
#'   # Create mock that throws an error
#'   mock_error <- mock(stop("S3 connection error"))
#'
#'   # Use mockery to stub the function
#'   stub(load_looker_data, "find_latest_looker_files", mock_error)
#'
#'   expect_null(load_looker_data("test-bucket"))
#' })
#'
#' test_that("file pattern matching works correctly", {
#'   # Test various filename patterns
#'   valid_files <- c(
#'     "Client_extras_2025-02-19T0743_VWvyGt.csv",
#'     "Complex_Look_Name_extras_2025-02-19T0743_ABC123.csv"
#'   )
#'
#'   invalid_files <- c(
#'     "invalid_file.csv",
#'     "Client_2025-02-19.csv",
#'     "Client_extras_2025-02-19.csv"
#'   )
#'
#'   pattern <- "^(.+)_extras_\\d{4}-\\d{2}-\\d{2}T\\d{4}_.+\\.csv$"
#'
#'   # Check valid files
#'   for (file in valid_files) {
#'     expect_true(grepl(pattern, file))
#'     expect_match(
#'       sub(pattern, "\\1", file),
#'       "^[^_]+(_[^_]+)*$"
#'     )
#'   }
#'
#'   # Check invalid files
#'   for (file in invalid_files) {
#'     expect_false(grepl(pattern, file))
#'   }
#' })
#'
#' test_that("date parsing works correctly", {
#'   test_date <- "2025-02-19T07:43:00"
#'   parsed_date <- as.POSIXct(test_date, format = "%Y-%m-%dT%H:%M:%S", tz = "GMT")
#'
#'   expect_s3_class(parsed_date, "POSIXct")
#'   expect_equal(
#'     format(parsed_date, "%Y-%m-%d %H:%M:%S"),
#'     "2025-02-19 07:43:00"
#'   )
#' })
