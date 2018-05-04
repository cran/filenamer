#' Create directory structure for a file path
#'
#' This function creates directories recursively (as necessary) to the 
#' specified file.
#'
#' @param x    file name (\code{character} or \code{filename})
#' @param ...  other arguments passed to \code{\link{dir.create}}
#' @export
#'
#' @examples
#' \dontrun{
#' # CRAN policy forbids package example to write to current directory,
#' # even inside \dontrun because the user may copy-and-paste and 
#' # polute his/her current directory;
#' # in real-world setting, the `tempdir` path prefix is unnecessary
#' x <- file.path(tempdir(), "path/to/file.txt")
#'
#' fn <- as.filename(x)
#' make_path(fn)
#' }
#'
make_path <- function(x, ...) UseMethod("make_path");

#' @rdname make_path
#' @param showWarnings  whether to show warnings
#' @param recursive     whether to recursively create all parent directories
#' @export
make_path.filename <- function(x, showWarnings=FALSE, recursive=TRUE, ...) {
	path <- paste(x$path, collapse=.Platform$file.sep);
	dir.create(path, showWarnings=showWarnings, recursive=recursive, ...);
}

#' @rdname make_path
#' @export
make_path.character <- function(x, ...) {
	make_path(as.filename(x), ...);
}
