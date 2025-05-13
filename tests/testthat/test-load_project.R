# library(testthat)
# library(dplyr)
# library(fs)
#
# # Create temporary test directory and files
# setup <- function() {
#   # Create temp directory
#   tmp_dir <- fs::path(tempdir(), "test_hmis")
#   fs::dir_create(tmp_dir)
#
#   # Create sample Project.csv
#   project_data <- data.frame(
#     ProjectID = c("1", "2", "3", "zzTest"),
#     ProjectName = c("Project A", "Project B", "Project C", "zzTraining"),
#     ProjectTypeCode = c(1, 2, 3, 4)
#   )
#   write.csv(project_data, fs::path(tmp_dir, "Project.csv"), row.names = FALSE)
#
#   # Create sample ProjectCoC.csv
#   project_coc_data <- data.frame(
#     ProjectID = c("1", "2", "3", "zzTest"),
#     CoCCode = c("OH-504", "OH-504", "OH-505", "OH-504")
#   )
#   write.csv(project_coc_data, fs::path(tmp_dir, "ProjectCoC.csv"), row.names = FALSE)
#
#   # Create sample regions data
#   regions <- data.frame(
#     ProjectID = c("1", "2", "3"),
#     RegionName = c("North", "South", "East")
#   )
#
#   list(
#     tmp_dir = tmp_dir,
#     regions = regions,
#     project_data = project_data
#   )
# }
#
# # Clean up test files
# cleanup <- function(tmp_dir) {
#   fs::dir_delete(tmp_dir)
# }
#
# test_that("load_project handles basic case correctly", {
#   test_env <- setup()
#
#   result <- load_project(test_env$tmp_dir)
#
#   # Test basic structure
#   expect_type(result, "list")
#   expect_named(result, c("Project", "mahoning_projects"))
#
#   # Test filtering of test/training projects
#   expect_false(any(grepl("^zz", result$Project$ProjectName, ignore.case = TRUE)))
#
#   # Test ProjectID is character
#   expect_type(result$Project$ProjectID, "character")
#
#   # Test mahoning_projects
#   expect_type(result$mahoning_projects, "character")
#   expect_named(result$mahoning_projects)
#
#   cleanup(test_env$tmp_dir)
# })
#
# test_that("load_project handles regions correctly", {
#   test_env <- setup()
#
#   result <- load_project(test_env$tmp_dir, regions = test_env$regions)
#
#   # Test region information is added
#   expect_true("RegionName" %in% names(result$Project))
#   expect_equal(
#     result$Project %>%
#       filter(ProjectID == "1") %>%
#       pull(RegionName),
#     "North"
#   )
#
#   cleanup(test_env$tmp_dir)
# })
#
# test_that("load_project handles missing files correctly", {
#   tmp_dir <- fs::path(tempdir(), "empty_test_dir")
#   fs::dir_create(tmp_dir)
#
#   # Test missing directory
#   expect_error(
#     load_project("nonexistent_directory"),
#     "Extract path not found"
#   )
#
#   # Test missing Project.csv
#   expect_error(
#     load_project(tmp_dir),
#     "Project.csv not found in extract path"
#   )
#
#   # Create Project.csv but not ProjectCoC.csv
#   write.csv(
#     data.frame(ProjectID = "1", ProjectName = "Test"),
#     fs::path(tmp_dir, "Project.csv"),
#     row.names = FALSE
#   )
#
#   expect_error(
#     load_project(tmp_dir),
#     "ProjectCoC.csv not found in extract path"
#   )
#
#   fs::dir_delete(tmp_dir)
# })
#
# test_that("load_project handles regions correctly", {
#   test_env <- setup()
#
#   # Verify regions data frame structure before passing to function
#   expect_true("ProjectID" %in% names(test_env$regions))
#   expect_true("RegionName" %in% names(test_env$regions))
#
#   # Try loading the data
#   result <- load_project(test_env$tmp_dir, regions = test_env$regions)
#
#   # Test region information is added
#   expect_true("RegionName" %in% names(result$Project))
#   expect_equal(
#     result$Project %>%
#       filter(ProjectID == "1") %>%
#       pull(RegionName),
#     "North"
#   )
#
#   cleanup(test_env$tmp_dir)
# })
