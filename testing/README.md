<!-- README.md is generated from README.Rmd. Please edit that file -->



# Testing medicalcoder

Along with GitHub Actions and local tests, the workflow in this directory will
test a recent local build of `medicalcoder` against every major and minor
release of R from 3.5.0 through the latest version, with, and without, suggested
packages.  The tests are done in [Docker](https://www.docker.com/) images based
on the [R-base](https://hub.docker.com/_/r-base) images.

## System Requirements:
To run the tests you need

* [Docker Desktop](https://www.docker.com/products/docker-desktop/)
* [GNU Make](https://www.gnu.org/software/make/)

Just run `make` from this directory.

# Last Testing Results


```
#> Error in eval(jsub, SDenv, parent.frame()): object 'DF' not found
#> Error in setkeyv(x, cols, verbose = verbose, physical = physical): some columns are not in the data.table: [suggests]
```


```
#> Error in data.frame(header = header, colspan = 1, row.names = NULL): arguments imply differing number of rows: 0, 1
```

* Errors:
  * Error  
* Warnings:
  * Warning 1 checking package dependencies ... WARNING Skipping vignette re-building Packages suggested but not available for checking:   'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble'  VignetteBuilder package required for checking but not installed: ‘knitr’
* Notes:
  * Note 1 checking package dependencies ... NOTE Packages suggested but not available for checking:   ‘data.table’ ‘kableExtra’ ‘knitr’ ‘rmarkdown’ ‘tibble’
  * Note 2 checking package dependencies ... NOTE Packages suggested but not available for checking:   'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble'
  * Note 3 checking package vignettes ... NOTE Package has ‘vignettes’ subdirectory but apparently no vignettes. Perhaps the ‘VignetteBuilder’ information is missing from the DESCRIPTION file?

