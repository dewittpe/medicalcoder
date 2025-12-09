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
  <tr grouplength="18"><td colspan="5" style="border-bottom: 1px solid;"><strong>With Suggested Packages</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.1.0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 6 </td>
   <td style="text-align:center;"> Warning 2 </td>
   <td style="text-align:center;"> Note 4 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.1.1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 6 </td>
   <td style="text-align:center;"> Warning 2 </td>
   <td style="text-align:center;"> Note 4 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.1.2 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 6 </td>
   <td style="text-align:center;"> Warning 2 </td>
   <td style="text-align:center;"> Note 4 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.1.3 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 6 </td>
   <td style="text-align:center;"> Warning 2 </td>
   <td style="text-align:center;"> Note 4 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.2.0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 6 </td>
   <td style="text-align:center;"> Warning 2 </td>
   <td style="text-align:center;"> Note 4 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.2.1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 6 </td>
   <td style="text-align:center;"> Warning 2 </td>
   <td style="text-align:center;"> Note 4 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.2.2 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 6 </td>
   <td style="text-align:center;"> Warning 2 </td>
   <td style="text-align:center;"> Note 4 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.2.3 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 5 </td>
   <td style="text-align:center;"> Warning 1 </td>
   <td style="text-align:center;"> Note 4 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.3.0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 6 </td>
   <td style="text-align:center;"> Warning 2 </td>
   <td style="text-align:center;"> Note 4 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.3.1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 6 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 4 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.3.2 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 6 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 4 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.3.3 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 3 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 1 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.4.0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 2 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 1 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.4.1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 1 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 1 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.4.2 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.5.0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.5.1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.5.2 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr grouplength="31"><td colspan="5" style="border-bottom: 1px solid;"><strong>Without Suggested Packages</strong></td></tr>
<tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 3.5.0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 4 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 2 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 3.5.1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 4 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 2 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 3.5.2 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 4 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 2 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 3.5.3 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 4 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 2 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 3.6.0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 4 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 3.6.1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 4 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 3.6.3 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 4 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.0.0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 7 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.0.1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 7 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.0.2 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 7 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.0.3 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 7 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.0.4 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 7 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.0.5 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 7 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.1.0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.1.1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.1.2 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.1.3 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.2.0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.2.1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.2.2 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.2.3 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.3.0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.3.1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.3.2 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.3.3 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.4.0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.4.1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.4.2 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> Note 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.5.0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.5.1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;padding-left: 2em;" indentlevel="1"> 4.5.2 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> Error 8 </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
</tbody>
</table>


**Errors:**

1. checking re-building of vignette outputs ... ERROR Error(s) in re-building vignettes: --- re-building ‘charlson.Rmd’ using rmarkdown  Quitting from charlson.Rmd:14-27 [setup] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ <error/rlang_error> Error in `library()`: ! there is no package called 'kableExtra' --- Backtrace:     ▆  1. └─base::library(kableExtra) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  Error: processing vignette 'charlson.Rmd' failed with diagnostics: there is no package called 'kableExtra' --- failed re-building ‘charlson.Rmd’  --- re-building ‘comorbidities.Rmd’ using rmarkdown  Quitting from comorbidities.Rmd:14-26 [setup] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ <error/rlang_error> Error in `library()`: ! there is no package called 'kableExtra' --- Backtrace:     ▆  1. └─base::library(kableExtra) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  Error: processing vignette 'comorbidities.Rmd' failed with diagnostics: there is no package called 'kableExtra' --- failed re-building ‘comorbidities.Rmd’  --- re-building ‘elixhauser.Rmd’ using rmarkdown  Quitting from elixhauser.Rmd:14-27 [setup] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ <error/rlang_error> Error in `library()`: ! there is no package called 'kableExtra' --- Backtrace:     ▆  1. └─base::library(kableExtra) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  Error: processing vignette 'elixhauser.Rmd' failed with diagnostics: there is no package called 'kableExtra' --- failed re-building ‘elixhauser.Rmd’  --- re-building ‘icd.Rmd’ using rmarkdown --- finished re-building ‘icd.Rmd’  --- re-building ‘pccc.Rmd’ using rmarkdown  Quitting from pccc.Rmd:14-27 [setup] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ <error/rlang_error> Error in `library()`: ! there is no package called 'kableExtra' --- Backtrace:     ▆  1. └─base::library(kableExtra) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  Error: processing vignette 'pccc.Rmd' failed with diagnostics: there is no package called 'kableExtra' --- failed re-building ‘pccc.Rmd’  SUMMARY: processing the following files failed:   ‘charlson.Rmd’ ‘comorbidities.Rmd’ ‘elixhauser.Rmd’ ‘pccc.Rmd’  Error: Vignette re-building failed. Execution halted 
2. checking re-building of vignette outputs ... ERROR Error(s) in re-building vignettes: --- re-building ‘charlson.Rmd’ using rmarkdown  Quitting from lines  at lines 15-27 [setup] (charlson.Rmd) Error: processing vignette 'charlson.Rmd' failed with diagnostics: there is no package called 'kableExtra' --- failed re-building ‘charlson.Rmd’  --- re-building ‘comorbidities.Rmd’ using rmarkdown  Quitting from lines  at lines 15-26 [setup] (comorbidities.Rmd) Error: processing vignette 'comorbidities.Rmd' failed with diagnostics: there is no package called 'kableExtra' --- failed re-building ‘comorbidities.Rmd’  --- re-building ‘elixhauser.Rmd’ using rmarkdown  Quitting from lines  at lines 15-27 [setup] (elixhauser.Rmd) Error: processing vignette 'elixhauser.Rmd' failed with diagnostics: there is no package called 'kableExtra' --- failed re-building ‘elixhauser.Rmd’  --- re-building ‘icd.Rmd’ using rmarkdown --- finished re-building ‘icd.Rmd’  --- re-building ‘pccc.Rmd’ using rmarkdown  Quitting from lines  at lines 15-27 [setup] (pccc.Rmd) Error: processing vignette 'pccc.Rmd' failed with diagnostics: there is no package called 'kableExtra' --- failed re-building ‘pccc.Rmd’  SUMMARY: processing the following files failed:   ‘charlson.Rmd’ ‘comorbidities.Rmd’ ‘elixhauser.Rmd’ ‘pccc.Rmd’  Error: Vignette re-building failed. Execution halted 
3. checking re-building of vignette outputs ... ERROR Error(s) in re-building vignettes: --- re-building ‘charlson.Rmd’ using rmarkdown  Quitting from lines 15-27 [setup] (charlson.Rmd) Error: processing vignette 'charlson.Rmd' failed with diagnostics: there is no package called 'kableExtra' --- failed re-building ‘charlson.Rmd’  --- re-building ‘comorbidities.Rmd’ using rmarkdown  Quitting from lines 15-26 [setup] (comorbidities.Rmd) Error: processing vignette 'comorbidities.Rmd' failed with diagnostics: there is no package called 'kableExtra' --- failed re-building ‘comorbidities.Rmd’  --- re-building ‘elixhauser.Rmd’ using rmarkdown  Quitting from lines 15-27 [setup] (elixhauser.Rmd) Error: processing vignette 'elixhauser.Rmd' failed with diagnostics: there is no package called 'kableExtra' --- failed re-building ‘elixhauser.Rmd’  --- re-building ‘icd.Rmd’ using rmarkdown --- finished re-building ‘icd.Rmd’  --- re-building ‘pccc.Rmd’ using rmarkdown  Quitting from lines 15-27 [setup] (pccc.Rmd) Error: processing vignette 'pccc.Rmd' failed with diagnostics: there is no package called 'kableExtra' --- failed re-building ‘pccc.Rmd’  SUMMARY: processing the following files failed:   ‘charlson.Rmd’ ‘comorbidities.Rmd’ ‘elixhauser.Rmd’ ‘pccc.Rmd’  Error: Vignette re-building failed. Execution halted 
4. checking tests ... ERROR   Running ‘test-asserts.R’   Running ‘test-charlson.R’   Running ‘test-comorbidities.R’   Running ‘test-data-frame-tools.R’ Running the tests in ‘tests/test-data-frame-tools.R’ failed. Last 13 lines of output:   +   data.frame(   +     x1 = c(1L, 2L, 8L),   +     x2.right = c("A", "B", "C"),   +     x2.left  = c("a", "b", "c")   +   )   > r <- data.frame(x1 = as.integer(1:10), x2 = c("A", "B", "D", "E", "F", "T", "A", "C", "9", "ten"), stringsAsFactors = FALSE)   > l <- data.frame(   +   x1 = as.integer(c(1, 2, 33, 44, 55, 66, 77, 8, 99, 1100)),   +   x2 = c("a", "b", "d", "e", "f", "t", "a", "c", "9", "TEN"),   +   stringsAsFactors = FALSE   + )   > outDF <- getFromNamespace(x = "mdcr_inner_join", ns = "medicalcoder")(r, l, by = "x1", suffixes = c(".right", ".left"))   > stopifnot(identical(outDF, expected_df))   Error: identical(outDF, expected_df) is not TRUE   Execution halted
5. checking tests ... ERROR   Running 'test-asserts.R'   Running 'test-charlson.R'   Running 'test-comorbidities.R'   Running 'test-data-frame-tools.R' Running the tests in 'tests/test-data-frame-tools.R' failed. Last 13 lines of output:   +   identical(names(DT),  c("D", "B", "C", "Column A"))   + )   >    > ################################################################################   > # testing mdcr_duplicated   >    > stopifnot(   +   !any(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(DF)),   +   !any(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(TBL)),   +   !any(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(DT))   + )   Error in NextMethod("duplicated") :      'NextMethod' called from an anonymous function   Calls: stopifnot -> <Anonymous> -> <Anonymous> -> NextMethod   Execution halted
6. checking tests ... ERROR   Running ‘test-asserts.R’   Running ‘test-charlson.R’   Running ‘test-comorbidities.R’   Running ‘test-data-frame-tools.R’ Running the tests in ‘tests/test-data-frame-tools.R’ failed. Last 13 lines of output:   +   identical(names(DT),  c("D", "B", "C", "Column A"))   + )   >    > ################################################################################   > # testing mdcr_duplicated   >    > stopifnot(   +   !any(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(DF)),   +   !any(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(TBL)),   +   !any(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(DT))   + )   Error in NextMethod("duplicated") :      'NextMethod' called from an anonymous function   Calls: stopifnot -> <Anonymous> -> <Anonymous> -> NextMethod   Execution halted
7. checking tests ... ERROR   Running ‘test-asserts.R’   Running ‘test-charlson.R’   Running ‘test-comorbidities.R’   Running ‘test-data-frame-tools.R’ Running the tests in ‘tests/test-data-frame-tools.R’ failed. Last 13 lines of output:   > outTBL <- getFromNamespace(x = "mdcr_inner_join", ns = "medicalcoder")(r, l, by.x = "x1", by.y = "z", suffixes = c(".right", ".left"))   > stopifnot(identical(outTBL, expected_tb))   >    > ################################################################################   > # testing mdcr_left_join   >    > # These wrappers around merge have sort = FALSE and dplyr::left_join doesn't   > # sort the return by default.  So, build the merge, sort the result, and then   > # test for the outcome.  The first set of tests for a single   >    > t0 <- getFromNamespace(x = "mdcr_left_join", ns = "medicalcoder")(DF, DF[2, ])   > t0 <- t0[do.call(order, lapply(lapply(names(t0), as.name), get, envir = as.environment(t0))), ]   Error in FUN(X[[i]], ...) : invalid first argument   Calls: [ -> [.data.frame -> do.call -> lapply -> FUN   Execution halted
8. checking tests ... ERROR   Running ‘test-asserts.R’   Running ‘test-charlson.R’   Running ‘test-comorbidities.R’   Running ‘test-data-frame-tools.R’ Running the tests in ‘tests/test-data-frame-tools.R’ failed. Last 13 lines of output:   > stopifnot(identical(outDF, expected_df))   >    > if (requireNamespace("data.table", quietly = TRUE)) {   +   data.table::setDT(r)   +   data.table::setDT(l)   +   expected_dt <- data.table::copy(expected_df)   +   data.table::setDT(expected_dt)   + } else {   +   expected_dt <- expected_df   + }   > outDT <- getFromNamespace(x = "mdcr_left_join", ns = "medicalcoder")(r, l, by = "x1", suffixes = c(".right", ".left"))   > outDT <- outDT[order(outDT$x1), ]   > stopifnot(identical(outDT, expected_dt))   Error: identical(outDT, expected_dt) is not TRUE   Execution halted

**Warnings:**

1. checking running R code from vignettes ... WARNING Errors in running code in vignettes: when running code in 'charlson.Rmd'   ...  > library(kableExtra)    When sourcing 'charlson.R': Error: there is no package called 'kableExtra' Execution halted when running code in 'comorbidities.Rmd'   ...  > library(kableExtra)    When sourcing 'comorbidities.R': Error: there is no package called 'kableExtra' Execution halted when running code in 'elixhauser.Rmd'   ...  > library(kableExtra)    When sourcing 'elixhauser.R': Error: there is no package called 'kableExtra' Execution halted when running code in 'pccc.Rmd'   ...  > library(kableExtra)    When sourcing 'pccc.R': Error: there is no package called 'kableExtra' Execution halted    'charlson.Rmd' using 'UTF-8'... failed   'comorbidities.Rmd' using 'UTF-8'... failed   'elixhauser.Rmd' using 'UTF-8'... failed   'icd.Rmd' using 'UTF-8'... OK   'pccc.Rmd' using 'UTF-8'... failed
2. checking running R code from vignettes ... WARNING Errors in running code in vignettes: when running code in ‘charlson.Rmd’   ...  > library(kableExtra)    When sourcing ‘charlson.R’: Error: there is no package called ‘kableExtra’ Execution halted when running code in ‘comorbidities.Rmd’   ...  > library(kableExtra)    When sourcing ‘comorbidities.R’: Error: there is no package called ‘kableExtra’ Execution halted when running code in ‘elixhauser.Rmd’   ...  > library(kableExtra)    When sourcing ‘elixhauser.R’: Error: there is no package called ‘kableExtra’ Execution halted when running code in ‘pccc.Rmd’   ...  > library(kableExtra)    When sourcing ‘pccc.R’: Error: there is no package called ‘kableExtra’ Execution halted    ‘charlson.Rmd’ using ‘UTF-8’... failed   ‘comorbidities.Rmd’ using ‘UTF-8’... failed   ‘elixhauser.Rmd’ using ‘UTF-8’... failed   ‘icd.Rmd’ using ‘UTF-8’... OK   ‘pccc.Rmd’ using ‘UTF-8’... failed

**Notes:**

1. checking package dependencies ... NOTE Package suggested but not available for checking: ‘kableExtra’
2. checking package dependencies ... NOTE Packages suggested but not available for checking:   ‘data.table’ ‘dplyr’ ‘kableExtra’ ‘knitr’ ‘R.utils’ ‘rmarkdown’   ‘tibble’
3. checking package dependencies ... NOTE Packages suggested but not available for checking:   'data.table', 'dplyr', 'kableExtra', 'knitr', 'R.utils', 'rmarkdown',   'tibble'
4. checking package dependencies ... NOTE Packages suggested but not available for checking:   'dplyr', 'kableExtra', 'tibble'

