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



<table class=" lightable-paper lightable-striped" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; margin-left: auto; margin-right: auto;'>
 <thead>
  <tr>
   <th style="text-align:center;"> Suggested Packages </th>
   <th style="text-align:center;"> Status </th>
   <th style="text-align:center;"> Errors </th>
   <th style="text-align:center;"> Warnings </th>
   <th style="text-align:center;"> Notes </th>
  </tr>
 </thead>
<tbody>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>3.5.0</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  ‘data.table’ ‘kableExtra’ ‘knitr’ ‘rmarkdown’ ‘tibble’ </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>3.5.1</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  ‘data.table’ ‘kableExtra’ ‘knitr’ ‘rmarkdown’ ‘tibble’ </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>3.5.2</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  ‘data.table’ ‘kableExtra’ ‘knitr’ ‘rmarkdown’ ‘tibble’ </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>3.5.3</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  ‘data.table’ ‘kableExtra’ ‘knitr’ ‘rmarkdown’ ‘tibble’ </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>3.6.0</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>3.6.1</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="2"><td colspan="5" style="border-bottom: 1px solid;"><strong>3.6.3</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.0.0</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.0.1</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.0.2</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.0.3</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.0.4</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.0.5</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.1.0</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.1.1</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.1.2</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.1.3</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.2.0</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.2.1</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.2.2</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.2.3</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.3.0</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.3.1</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.3.2</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="1"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.3.3</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="2"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.4.0</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> With </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... WARNING
Skipping vignette re-building
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble'

VignetteBuilder package required for checking but not installed: ‘kn </td>
   <td style="text-align:center;"> tr’ | checking package vignettes ... NOTE
Package has ‘vignettes’ subdirectory but apparently no vignettes.
Perhaps the ‘VignetteBuilder’ information is missing from the
DESCRIPTIO </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="2"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.4.1</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> With </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="2"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.4.2</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> With </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> checking package dependencies ... NOTE
Packages suggested but not available for checking:
  'data.table', 'kableExtra', 'knitr', 'rmarkdown', 'tibble' </td>
  </tr>
  <tr grouplength="2"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.5.0</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> With </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr grouplength="2"><td colspan="5" style="border-bottom: 1px solid;"><strong>4.5.1</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> With </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> Without </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
</tbody>
</table>



