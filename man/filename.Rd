% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/filename.R
\name{filename}
\alias{filename}
\title{Create a filename.}
\usage{
filename(
  x,
  path = NULL,
  tag = NULL,
  ext = NULL,
  date = NULL,
  time = NULL,
  subdir = TRUE
)
}
\arguments{
\item{x}{file name stem}

\item{path}{path to the file}

\item{tag}{tags for the file name}

\item{ext}{file extension}

\item{date}{date stamp (\code{character} or \code{Date})}

\item{time}{time stamp (\code{character} or \code{POSIXct})}

\item{subdir}{whether to append a date/time stamped subdirectory to path}
}
\value{
a \code{filename} object
}
\description{
This function creates a \code{filename} object with a file path, tags, 
extensions, date stamp or date-time stamp.
}
\details{
The \code{date} and \code{time} parameters can be specified as
\code{character} vectors or date/time objects. If \code{time}
is given as a \code{POSIXct}, it will override \code{date}.
If these parameters are both \code{NULL}, automated date and time stamping 
may be done and is controlled by \code{getOption("filenamer.timestamp")}.
If this option is \code{NULL}, 0, or less,
no date or time stamping will be done;
if it is 1, only date stamping will be done;
if it is 2 or greater, date-time stamping will be done (default).
Set \code{date} or \code{time} to \code{NA} to suppress date or 
time stamping for a particular \code{filename}.
Stamps are shown in ISO 8601 date format (%Y-%m-%d) or date-time format
(%Y%m%dT%H%M%S). Colons are not a legal file name character across
platforms and are thus omitted; hyphens are omitted from date-time stamps
for brevity.

By default, a date stamped subdirectory is appended to the file path.
To disable this behaviour, set \code{subdir} to \code{FALSE} or disable
path stamping globally by \code{options(filenamer.path.timestamp = 0)}.
This option is similar to \code{filenamer.timestamp} above.
}
\examples{
# file name is date-time stamped and put in subdirectory by default
fn <- filename("data", tag="qc", ext="txt")
print(as.character(fn))

# disable date-time stamping and subdirectory insertion
fn2 <- filename("data", tag="qc", date=NA, time=NA, subdir=FALSE)
print(as.character(fn2))

# creating a new file name from an existing one yields a new time stamp
fn3 <- filename(fn)
print(as.character(fn3))

}
