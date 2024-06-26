% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/set.R
\name{set_fpath}
\alias{set_fpath}
\title{Set path in a file name}
\usage{
set_fpath(x, path)
}
\arguments{
\item{x}{a \code{character} or a \code{filename}}

\item{path}{new path to file}
}
\value{
modified object of the original type
}
\description{
This function sets the path in a file name.
}
\examples{
x <- "path/data_norm.txt"
print(set_fpath(x, "new_path"))

}
