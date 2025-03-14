% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/load_client.R
\name{load_client}
\alias{load_client}
\title{Load and Process Client Data}
\usage{
load_client(extract_path = fs::path("data", "hmis"))
}
\arguments{
\item{extract_path}{Path where the HUD export files are located}
}
\value{
Processed Client data with redacted PII
}
\description{
Loads Client data from CSV and applies PII redaction
}
