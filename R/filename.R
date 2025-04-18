#' Create a filename.
#'
#' This function creates a \code{filename} object with a file path, tags, 
#' extensions, date stamp or date-time stamp.
#' 
#' The \code{date} and \code{time} parameters can be specified as
#' \code{character} vectors or date/time objects. If \code{time}
#' is given as a \code{POSIXct}, it will override \code{date}.
#' If these parameters are both \code{NULL}, automated date and time stamping 
#' may be done and is controlled by \code{getOption("filenamer.timestamp")}.
#' If this option is \code{NULL}, 0, or less,
#' no date or time stamping will be done;
#' if it is 1, only date stamping will be done;
#' if it is 2 or greater, date-time stamping will be done (default).
#' Set \code{date} or \code{time} to \code{NA} to suppress date or 
#' time stamping for a particular \code{filename}.
#' Stamps are shown in ISO 8601 date format (%Y-%m-%d) or date-time format
#' (%Y%m%dT%H%M%S). Colons are not a legal file name character across
#' platforms and are thus omitted; hyphens are omitted from date-time stamps
#' for brevity.
#'
#' By default, a date stamped subdirectory is appended to the file path.
#' To disable this behaviour, set \code{subdir} to \code{FALSE} or disable
#' path stamping globally by \code{options(filenamer.path.timestamp = 0)}.
#' This option is similar to \code{filenamer.timestamp} above.
#' 
#' @param x     file name stem
#' @param path  path to the file
#' @param tag   tags for the file name
#' @param ext   file extension
#' @param date  date stamp (\code{character} or \code{Date})
#' @param time  time stamp (\code{character} or \code{POSIXct})
#' @param subdir  whether to append a date/time stamped subdirectory to path
#' @return a \code{filename} object
#' @export
#' 
#' @examples
#' # file name is date-time stamped and put in subdirectory by default
#' fn <- filename("data", tag="qc", ext="txt")
#' print(as.character(fn))
#'
#' # disable date-time stamping and subdirectory insertion
#' fn2 <- filename("data", tag="qc", date=NA, time=NA, subdir=FALSE)
#' print(as.character(fn2))
#'
#' # creating a new file name from an existing one yields a new time stamp
#' fn3 <- filename(fn)
#' print(as.character(fn3))
#'
filename <- function(x, path=NULL, tag=NULL, ext=NULL, date=NULL, time=NULL, subdir=TRUE) {
	if (is.character(x)) {
		fstem <- x;
	} else if (is.filename(x)) {
		fstem <- x$fstem;
		if (is.null(path)) path <- x$path;
		if (is.null(tag)) tag <- x$tag;
		if (is.null(ext)) ext <- x$ext;
		# date and time are not copied over to allow new stamping
		# prevent a new stamped subdirectory from being appended
		subdir <- FALSE;
	}

	fstamp <- .stamp_datetime(date, time, getOption("filenamer.timestamp"));

	if (subdir) {
		pstamp <- .stamp_datetime(date, time, getOption("filenamer.path.timestamp"));
		path <- .append_datetime(path, pstamp$date, pstamp$time);
	}

	structure(
		list(fstem=fstem, path=path, tag=tag, ext=ext,
			date=fstamp$date, time=fstamp$time),
		class = "filename"
	)
}

#' Type checking for filename
#' 
#' This function returns \code{TRUE} if its argument is a \code{filename}
#' and \code{FALSE} otherwise.
#'
#' @param x   object to check
#' @return a \code{logical} value
#' @export
#'
is.filename <- function(x) inherits(x, "filename");

#' Coerce to a filename
#'
#' This function coerces an object into a \code{filename}, if possible.
#'
#' @param x    a \code{character} or a \code{filename}
#' @param ...  other arguments
#' @return a \code{filename} object
#' @export
#'
#' @examples
#' fn <- as.filename("data_raw_2011-01-01.txt")
#' str(fn)
#'
as.filename <- function(x, ...) {
	UseMethod("as.filename")
}

#' @rdname as.filename
#' @export
as.filename.filename <- function(x, ...) {
	return(x);
}

scrub <- function(x, pattern, replacement="", ...) {
	gsub(pattern, replacement, x, ...)
}

.sanitize <- function(x) {
	# convert to lower case
	# remove special characters
	# remove parentheses
	# replace multiple whitespaces with a single dash
	scrub(
		scrub(
			scrub(
				tolower(x), "[?%*:|\"'<>;=&#$@!~^`]"
			),
			"\\[|\\]|\\(|\\)|\\{|\\}"
		),
		"\\s+", "-"
	)
}

#' @rdname as.filename
#' @param tag.char  character to delimit tags, defaults to \code{'_'}
#' @export
as.filename.character <- function(
  x, tag.char=NULL, ...
) {
	tag.char <- .get_tag_char(tag.char);
	ext.char <- .get_ext_char();

	fn <- filename("");
	fn$date <- NA;
	fn$time <- NA;

	# split path into character vectors
	y <- strsplit(x, .Platform$file.sep, fixed=TRUE)[[1]];
	if (substr(x, nchar(x), nchar(x)) == .Platform$file.sep) {
		# filepath ends with "/": target is a directory (file name is empty)
		fn$path <- y;
		x <- "";
	} else {
		# target is a file
		if (length(y) > 1) {
			fn$path <- y[1:(length(y)-1)];
			# proceed with the last part (file name)
			x <- y[length(y)];
		} else {
			# file name has no filepath
			fn$path <- NULL;
		}
	}

	if (nchar(x) == 0) return(fn);

	# split file name by the tag character
	# x[1] is the file stem
	# of the remaining elements of x, all but the final is a file name tag
	# the last element of x will need to be split further
	x <- strsplit(x, tag.char, fixed=TRUE)[[1]];

	if (length(x) > 1) {
		# tag are found
		fn$fstem <- x[1];
		if (length(x) > 2) {
			# add all but the final tag, which will be added later
			fn$tag <- x[2:(length(x)-1)];
		}
		
	}

	# split the last element of x by the extension character
	# last[1] could be a date stamp, date-time stamp, or a file name tag
	last <- strsplit(x[length(x)], ext.char, fixed=TRUE)[[1]];

	if (.grepl_date(last[1])) {
		# first token matches date format
		fn$date <- last[1];
	} else if (.grepl_datetime(last[1])) {
		# first token matches date-time format
		fn <- .set_fdatetime(fn, last[1]);
	} else if (length(x) == 1) {
		# no tags are found, and first token is neither date nor timestmp: 
		# use token as file name stem
		fn$fstem <- last[1];
	} else {
		# first token is the final tag: append it
		fn$tag <- c(fn$tag, last[1]);
	}

	if (length(last) > 1) {
		# all remaining elements of `last` are extensions
		ext <- last[2:length(last)];
		# do not assign ext that is simply ""
		if (length(ext) > 0 || ext != "") {
			fn$ext <- ext;
		}
	}

	fn
}

#' Coerce a character to a filename
#' 
#' This function coerces a \code{filename} into a character.
#'
#' @param x         a \code{filename} object
#' @param tag.char  character to delimit tags, defaults to \code{'_'}
#' @param simplify  if \code{TRUE}, all timestamps are omitted
#' @param sanitize  if \code{TRUE}, file name is sanitized by removing
#'                  problematic characters, replacing whitespace, and
#'                  converting to lowercase
#' @param ...       unused arguments
#' @return a \code{character} vector
#' @export
#'
#' @examples
#' x <- "data_post_2011-01-02.txt"
#' fn <- as.filename(x)
#' print(as.character(fn))
#'
as.character.filename <- function(
  x, tag.char=NULL, simplify=FALSE, sanitize=TRUE, ...
) {
	tag.char <- .get_tag_char(tag.char);
	ext.char <- .get_ext_char();

	y <- c(x$fstem, x$tag);

	# remove empty elements
	y <- y[y != ""];

	# sanitize the components and path before appending datetime
	if (sanitize) {
		path <- .sanitize(x$path);
		ext <- .sanitize(x$ext);
		y <- .sanitize(y);
	} else {
		path <- x$path;
		ext <- x$ext;
	}

	if (simplify) {
		# do not append date/time stamp
		if (length(path) > 0) {
			# further, remove parent directory if it is a date/time stamp
			last <- path[length(path)];
			if (.grepl_date(last) || .grepl_datetime(last)) {
				# remove parent directory
				path <- path[-length(path)];
			}
		}
	} else {
		y <- .append_datetime(y, x$date, x$time);
	}

	# concatentate stem, tags, extensions, and path
	fname <- paste(y, collapse=tag.char);
	fname <- paste(c(fname, ext), collapse=ext.char);
	paste(c(path, fname), collapse=.Platform$file.sep)
}

