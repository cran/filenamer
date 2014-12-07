# README #

`filenamer` is an R package for managing file names with time stamps, tags, and
subdirectories. It facilitates quick derivation of new file names and supports
conversions to and from character vectors.

### Dependencies ###

* R (>= 3.0)
* roxygen2 (>= 4.0, for building only)

### Build ###

Clone the repository, build the documentation with roxygen2, then install.

    $ git clone https://bitbucket.org/djhshih/filenamer.git
    $ cd filename
    $ R

    R> library(roxygen2)
    R> roxygenize()
    R> quit()

    $ R CMD INSTALL .

### Usage ###

    library(filenamer)

We can create a `filenamer` object by conversion from a `character` vector.

    f <- as.filename("cars.txt")

Alternatively, we can use the `filename` constructor, which by default
apply a time stamp (when the file name is created) and places the target file
in a date-stamped directory.

    f <- filename("cars", ext="txt")
    as.character(f)
    ## [1] "2014-12-09/cars_20141209T184403.txt"
    
    # tag() tags a file name and returns the resulting character vector;
    # without any extra argument, tag() just type casts
    tag(f)
    ## [1] "2014-12-09/cars_20141209T184403.txt"

We can also do only date stamping, or turn off the stamping completely.

    # Set option to enable only date stamping
    options(filename.timestamp=1)
    
    # Disable automatic date-stamped subdirectory placement
    options(filename.path.timestamp=0) 

    f <- filename("cars", ext="txt")
    tag(f)
    ## [1] "cars_2014-12-09.txt"
    
    # Set option to disable stamping
    options(filename.timestamp=0)
    
    f <- filename("cars", ext="txt")
    tag(f)
    ## [1] "cars.txt"

We can manage `filename` (or `character`) using `insert`.

    # Insert a tag to derive a new file name for the normalized data
    g <- insert(f, tag="norm")
    tag(g)
    ## [1] "cars_norm.txt"
    
    # Replace the extension
    # (if we start with a character vector, we end with a character vector)
    g <- set_ext("cars.txt", "csv")
    g 
    ## [1] "cars.csv"
    
We can also use the `tag` function for `insert` + `as.character`.

    data(cars)
    pdf(tag(f, ext="pdf", replace=TRUE))
    plot(dist ~ speed, cars)
    dev.off()

Together with the `io` package, we can name and create files
painlessly with time stamping and directory organization. The directory
structure is automatically created by `io::qwrite`.

    # Set options back to default values
    options(filename.timestamp=2)
    options(filename.path.timestamp=1) 
    
    library(io)
    f <- filename("cars", path="out", ext="txt")
    qwrite(cars, f)
    qdraw(plot(dist ~ speed, cars), set_fext(f, "pdf"))
    
    # Sometimes when the plot has many graphical elements,
    # you may wish to output the plot in a bitmap format;
    # you do so by simply changing the file extension
    qdraw(plot(dist ~ speed, cars), set_fext(f, "png"))

    list.files("out/2014-12-09")
    ## [1] "cars_20141209T191048.pdf" "cars_20141209T191048.txt"

The time stamps on the file names prevent them from being clobbered on repeat
runs (that are more than a second apart). The files are automatically organized
into subdirectories. Accordingly, you can keep all versions of your results, and
you have ready access to the latest version in the base directory:

    # Symbolic links are automatically created with simpler names
    list.files("out", pattern="cars")
    ## [1] "cars.pdf" "cars.txt"

See `?filename` and `?io`.

