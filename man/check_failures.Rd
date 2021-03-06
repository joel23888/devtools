% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/revdep-summarise.R
\name{check_failures}
\alias{check_failures}
\title{Parses R CMD check log file for ERRORs, WARNINGs and NOTEs}
\usage{
check_failures(path, error = TRUE, warning = TRUE, note = TRUE)
}
\arguments{
\item{path}{check path, e.g., value of the \code{check_dir} argument in a
call to \code{\link{check}}}

\item{error, warning, note}{logical, indicates if errors, warnings and/or
notes should be returned}
}
\value{
a character vector with the relevant messages, can have length zero
  if no messages are found
}
\description{
Extracts check messages from the \code{00check.log} file generated by
\code{R CMD check}.
}
\seealso{
\code{\link{check}}, \code{\link{revdep_check}}
}

