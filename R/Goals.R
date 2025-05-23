#' Create Regions dataset for HMISdata package
#' This script creates the Regions dataset containing Ohio homeless planning regions

# Load required packages
library(tibble)
library(usethis)

Goals <- tibble::tribble(
                                         ~SummaryMeasure,                                                                        ~Measure, ~Operator, ~`1`, ~`2`, ~`8`, ~`4`, ~`3`, ~`13`, ~`12`, ~`9`,
           "Obtaining and Maintaining Permanent Housing",                                                    "Exits to Permanent Housing",      ">=",  0.4, 0.83, 0.75,  0.3,   NA,  0.83,    NA,   NA,
           "Obtaining and Maintaining Permanent Housing",                                        "Remain in or Exit To Permanent Housing",      ">=",   NA,   NA,   NA,   NA,  0.9,    NA,   0.9,  0.9,
           "Obtaining and Maintaining Permanent Housing",                                       "Exits to Temporary or Permanent Housing",      ">=",   NA,   NA,   NA,  0.6,   NA,    NA,    NA,   NA,
  "Accessing Mainstream Resources and Employment Income",                                                       "Gain or Increase Income",      ">=", 0.18, 0.28,  0.2,   NA,  0.3,  0.18,    NA,  0.3,
  "Accessing Mainstream Resources and Employment Income",                                                             "Non-cash Benefits",      ">=",  0.5, 0.75, 0.75,   NA, 0.75,   0.7,    NA, 0.75,
  "Accessing Mainstream Resources and Employment Income",                                                      "Health Insurance at Exit",      ">=", 0.75, 0.85, 0.85,   NA, 0.85,  0.85,    NA, 0.85,
                                        "Length of Stay",                                                        "Average Length of Stay",      "<=",   40,  240,  300,   NA,   NA,   150,    NA,   NA,
                                        "Length of Stay",                                                         "Median Length of Stay",      "<=",   40,  240,  300,   NA,   NA,   150,    NA,   NA,
                                       "Rapid Placement",                                       "Days from Project Entry to Move In Date",      "<=",   NA,   NA,   NA,   NA,   NA,    21,    NA,   NA,
                      "Entries into the Homeless System",                                                    "Recurrence from Prevention",      "<=",   NA,   NA,   NA,   NA,   NA,    NA,  0.25,   NA,
                               "Returns to Homelessness",                   "Recurrence from Exits to Permanent Destinations within 6 mo",      "<=", 0.15, 0.07, 0.15,   NA, 0.02,  0.07,    NA, 0.02,
                               "Returns to Homelessness",                  "Recurrence from Exits to Permanent Destinations within 2 yrs",      "<=",  0.2, 0.12,  0.2,   NA, 0.05,  0.12,    NA, 0.05,
                               "Average VI SPDAT Scores", "County-level Literally Homeless VISPDAT Scores Compared to Average PH Entries",        NA,   NA,   NA,   NA,   NA,   NA,    NA,    NA,   NA,
         "Provision of HP Assistance and RRH Assistance",                                             "RRH Spending vs HP Spending Ratio",      ">=",   NA,   NA,   NA,   NA,   NA,  0.75,    NA,   NA
  )

usethis::use_data(Goals, overwrite = TRUE)
