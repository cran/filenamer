#' Utilities for managing file names.
#'
#' \code{filenamer} provides a S3 class to represent file names, which is 
#' inter-convertible with \code{character}.
#'
#' Users either construct a \code{filename} object with the \code{\link{filename}}
#' constructor or convert an existing file name from \code{character} to
#' \code{filename} using \code{\link{as.filename}}.
#' Then, users can manage the tags and extensions of the \code{filename} object with
#' \code{\link{insert}}.
#'
#' The functions \code{\link{set_fpath}}, \code{\link{set_fext}}, 
#' \code{\link{set_fdate}}, and \code{\link{set_ftime}} can be used
#' on both \code{character} or \code{filename} to modify file names.
#'
#' Use \code{\link{tag}} to quickly add or replace a tag on a file name (as a
#' \code{character} or \code{filename} and coerce into a \code{character}.
#'
#' @keywords internal
"_PACKAGE"

#' @importFrom methods is
NULL
