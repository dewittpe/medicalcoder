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

**NOTE:** When something goes wrong and you need to dig into a specific image
run from this directory.

    docker run -v .:/work/ -it <image>

# Last Testing Results



<table>
 <thead>
  <tr>
   <th style="text-align:center;"> R Version </th>
   <th style="text-align:center;"> Status </th>
   <th style="text-align:center;"> Error </th>
   <th style="text-align:center;"> Warning </th>
   <th style="text-align:center;"> Note </th>
  </tr>
 </thead>
<tbody>
  <tr grouplength="3"><td colspan="5" style="border-bottom: 1px solid;"><strong>With Suggested Packages</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.5.0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 1 </td>
   <td style="text-align:center;"> Warning 1 </td>
   <td style="text-align:center;"> Note 1 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.5.1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 1 </td>
   <td style="text-align:center;"> Warning 1 </td>
   <td style="text-align:center;"> Note 1 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.5.2 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
</tbody>
</table>


**Errors:**

1. checking tests ... ERROR   Running ‘test-asserts.R’   Running ‘test-charlson.R’   Running ‘test-comorbidities.R’   Running ‘test-data-frame-tools.R’ Running the tests in ‘tests/test-data-frame-tools.R’ failed. Last 13 lines of output:   + }   > outDT <- getFromNamespace(x = "mdcr_inner_join", ns = "medicalcoder")(r, l, by = "x1", suffixes = c(".right", ".left"))   > stopifnot(identical(outDT, expected_dt))   >    > if (requireNamespace("tibble", quietly = TRUE)) {   +   r <- tibble::as_tibble(r)   +   l <- tibble::as_tibble(l)   +   expected_tb <- tibble::as_tibble(expected_df)   + } else {   +   expected_tb <- expected_df   + }   > outTBL <- getFromNamespace(x = "mdcr_inner_join", ns = "medicalcoder")(r, l, by = "x1", suffixes = c(".right", ".left"))   > stopifnot(identical(outTBL, expected_tb))   Error: identical(outTBL, expected_tb) is not TRUE   Execution halted

**Warnings:**

1. checking package dependencies ... WARNING Cannot process vignettes Packages suggested but not available for checking:   'dplyr', 'kableExtra', 'knitr', 'R.utils', 'rmarkdown', 'tibble'  VignetteBuilder package required for checking but not installed: ‘knitr’

**Notes:**

1. checking package vignettes ... NOTE Package has ‘vignettes’ subdirectory but apparently no vignettes. Perhaps the ‘VignetteBuilder’ information is missing from the DESCRIPTION file?

