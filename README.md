<!-- README.md is generated from README.Rmd. Please edit that file -->



# medicalcoder: An R package for working with ICD codes and Comorbidity Algorithms <img src="man/figures/hex.svg" width="200px" align="right" alt = "medicalcoder hex logo"/>

<!-- badges: start -->
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/dewittpe/medicalcoder/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dewittpe/medicalcoder/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/dewittpe/medicalcoder/graph/badge.svg)](https://app.codecov.io/gh/dewittpe/medicalcoder)
[![CRAN status](https://www.r-pkg.org/badges/version-last-release/medicalcoder)](https://CRAN.R-project.org/package=medicalcoder)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/medicalcoder)](https://www.r-pkg.org/pkg/medicalcoder)
[![downloads](https://cranlogs.r-pkg.org/badges/grand-total/medicalcoder)](https://www.r-pkg.org/pkg/medicalcoder)
<!-- badges: end -->

medicalcoder is a lightweight, base-R package for working with ICD-9 and
ICD-10 diagnosis and procedure codes. It provides fast, dependency-free tools to
look up, validate, and manipulate ICD codes, while also implementing widely used
comorbidity algorithms such as Charlson, Elixhauser, and the Pediatric Complex
Chronic Conditions (PCCC). Designed for portability and reproducibility, the
package avoids external dependencies—requiring only R ≥ 3.5.0—yet offers a rich
set of curated ICD code libraries from the United States' Centers for Medicare
and Medicaid Services (CMS), Centers for Disease Control (CDC), and the World
Health Organization (WHO).

The package balances performance with elegance: its internal caching, efficient
joins, and compact data structures make it practical for large-scale health data
analyses, while its clean design makes it easy to extend or audit. Whether you
need to flag comorbidities, explore ICD hierarchies, or standardize clinical
coding workflows, medicalcoder provides a robust, transparent foundation for
research and applied work in biomedical informatics.

The primary objectives of medicalcoder are:

1. **Fully self-contained**
   - Minimal Dependencies
     - No dependencies other than base R.
     - Requires R version ≥ 3.5.0 due to a [change in data
       serialization](https://cran.r-project.org/src/base/NEWS.3#:~:text=R%20has%20new,to%20version%203.5.0).
       R 3.5.0 was released in April 2018. The initial public release of
       medicalcoder was in 2025.
     - Several packages are listed in the *Suggests* section of the
       `DESCRIPTION` file. These are only needed for building vignettes, other
       documentation, and testing. They are not required to install the package.

   - No Imports
     - medicalcoder does not import any non-base namespaces. This improves
       ease of maintenance and usability.
     - Suggested packages are needed only for development work and building
       vignettes. They are not required for installation or use.
     - That said, there are non-trivial performance gains when passing a
       [`data.table`](https://cran.r-project.org/package=data.table) to the
       `comorbidities()` function compared to passing a base `data.frame` or a
       `tibble` from the tidyverse.
       (See [benchmarking](https://github.com/dewittpe/medicalcoder/tree/main/benchmarking)).

   - Internal lookup tables
     - All required data are included in the package. If you have the `.tar.gz`
       source file and R ≥ 3.5.0, that is all you need to install and use the
       package.

2. **Efficient implementation of multiple comorbidity algorithms**
   - Implements three general algorithms, each with multiple variants. Details
     are provided below.
   - Supports flagging of subconditions within PCCC.
   - Supports longitudinal flagging of comorbidities. medicalcoder will flag
     comorbidities based on present-on-admission indicators for the
     current encounter and can look back in time for a patient to flag a
     comorbidity if reported in a prior encounter. See examples.

3. **Tools for working with ICD codes**
   - Lookup tables.
   - Ability to work with both full codes (ICD codes with decimal points) and
     compact codes (ICD codes with decimal points omitted).

## Why use medicalcoder

There are several tools for working with ICD codes and comorbidity algorithms.
medicalcoder provides novel features:

- Unified access to multiple comorbidity algorithms through a single function:
  `comorbidities()`.
- Support for both ICD-9 and ICD-10 diagnostic and procedure codes.
- Longitudinal patient-level comorbidity flagging using present-on-admission indicators.
- Fully self-contained package (no external dependencies).

## Install

### CRAN

``` r
install.packages("medicalcoder")
```

### From GitHub


``` r
remotes::install_github("dewittpe/medicalcoder")
```

### From source

If you have the .tar.gz file for version X.Y.Z, e.g., `medicalcoder_X.Y.Z.tar.gz`
you can install from within R via:


``` r
install.packages(
  pkgs = "medicalcoder_X.Y.Z.tar.gz", # replace file name with the file you have
  repos = NULL,
  type = "source"
)
```

From the command line:

```
R CMD INSTALL medicalcoder_X.Y.Z.tar.gz
```

## Quick Start:

### Example Data

Input data for `comorbidities()` is expected to be in a 'long' format.  Each row
is one code with additional columns for patient and/or encounter id. There are
two example data sets in the package: `mdcr` and `mdcr_longitudinal`.

``` r
data(mdcr, mdcr_longitudinal, package = "medicalcoder")
```

The `mdcr` data set consists of 319 856 rows.
Each row contains one ICD code (`code`). The column `icdv` denotes
each code as ICD-9 or ICD-10, and the `dx` column denotes diagnostic (1) or
procedure (0) code. This data set contains diagnostic and procedure codes for
38 262 patients.

``` r
str(mdcr)
#> 'data.frame':	319856 obs. of  4 variables:
#>  $ patid: int  71412 71412 71412 71412 71412 17087 64424 64424 84361 84361 ...
#>  $ icdv : int  9 9 9 9 9 10 9 9 9 9 ...
#>  $ code : chr  "99931" "75169" "99591" "V5865" ...
#>  $ dx   : int  1 1 1 1 1 1 1 0 1 1 ...
head(mdcr)
#>   patid icdv  code dx
#> 1 71412    9 99931  1
#> 2 71412    9 75169  1
#> 3 71412    9 99591  1
#> 4 71412    9 V5865  1
#> 5 71412    9  V427  1
#> 6 17087   10  V441  1
```

The `mdcr_longitudinal` data set is distinct from the `mdcr` data set.  The major
difference is that this data set contains only diagnostic codes and there are
only 3 patients.  The `date` column
denotes the date of the diagnosis and allows us to look at changes in
comorbidities over time.

``` r
str(mdcr_longitudinal)
#> 'data.frame':	60 obs. of  4 variables:
#>  $ patid: int  9663901 9663901 9663901 9663901 9663901 9663901 9663901 9663901 9663901 9663901 ...
#>  $ date : IDate, format: "2016-03-18" "2016-03-24" ...
#>  $ icdv : int  10 10 10 10 10 10 10 10 10 10 ...
#>  $ code : chr  "Z77.22" "IMO0002" "V87.7XXA" "J95.851" ...
head(mdcr_longitudinal)
#>     patid       date icdv     code
#> 1 9663901 2016-03-18   10   Z77.22
#> 2 9663901 2016-03-24   10  IMO0002
#> 3 9663901 2016-03-24   10 V87.7XXA
#> 4 9663901 2016-03-25   10  J95.851
#> 5 9663901 2016-03-30   10  IMO0002
#> 6 9663901 2016-03-30   10    Z93.0
```

### Comorbidity Algorithms

There are three comorbidity methods, each with several variants, available in
medicalcoder.  All of which are accessible through the `comorbidities()`
method by specifying the `method` argument.

General examples and explanations for when conditions are flagged are in the
vignette

``` r
vignette(topic = "comorbidities", package = "medicalcoder")
```

#### Pediatric Complex Chronic Conditions (PCCC)

  * Version 2.0
    - BMC Pediatrics: [Feudtner et al. (2014)](https://doi.org/10.1186/1471-2431-14-199)
    - Consistent with R package [pccc](https://cran.r-project.org/package=pccc)

  * Version 2.1
    - Updated code base with the same assessment algorithm as version 2.0.

  * Version 3.0
    - JAMA Network Open: [Feinstein et al. (2024)](https://doi.org/10.1001/jamanetworkopen.2024.20579)
    - Children's Hospital Association [Toolkit](https://www.childrenshospitals.org/content/analytics/toolkit/complex-chronic-conditions)

  * Version 3.1
    - Updated code base with same assessment algorithm as version 3.0.

  * All variants can flag conditions and subconditions.


``` r
# PCCC v3.1 example
library(medicalcoder)
cmrbs2 <-
  comorbidities(
    data = mdcr,
    id.vars = "patid", # can use more than one column, e.g., site, patient, encounter
    icd.codes = "code",
    dx.var = "dx",
    poa = 1,  # consider all codes to be present on admission
    method = "pccc_v2.1"
  )
cmrbs3 <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    dx.var = "dx",
    poa = 1,  # consider all codes to be present on admission
    method = "pccc_v3.1"
  )
str(cmrbs2, max.level = 0)
#> Classes 'medicalcoder_comorbidities' and 'data.frame':	38262 obs. of  16 variables:
#>  - attr(*, "method")= chr "pccc_v2.1"
#>  - attr(*, "id.vars")= chr "patid"
#>  - attr(*, "flag.method")= chr "current"
str(cmrbs3, max.level = 0)
#> Classes 'medicalcoder_comorbidities' and 'data.frame':	38262 obs. of  49 variables:
#>  - attr(*, "method")= chr "pccc_v3.1"
#>  - attr(*, "id.vars")= chr "patid"
#>  - attr(*, "flag.method")= chr "current"
```

A summary of the flagged conditions is generated with a call to `summary()`.

``` r
s2 <- summary(cmrbs2)
str(s2)
```

For `pccc_v2.0` and `pccc_v2.1` the `data.frame` returned by `summary()`
reports the count (unique `id.vars` with the condition) and percentage.


``` r
s3 <- summary(cmrbs3)
str(s3)
```
For `pccc_v3.0` and `pccc_v3.1` the returned `data.frame` reports counts and
percentages for how the condition was flagged based on diagnosis/procedure codes
only, technology dependent codes only, or both.  The `dxpr_or_tech` columns
answer the question "did this patient have the condition".

Further detail, examples, and explanations are in the vignette.

``` r
vignette(topic = "pccc", package = "medicalcoder")
```

#### Charlson Comorbidities
There are four variants of Charlson comorbidities implemented in medicalcoder:

* [Deyo, Cherkin, and Ciol (1992)](https://doi.org/10.1016/0895-4356(92)90133-8)
* [Quan et al. (2005)](https://doi.org/10.1097/01.mlr.0000182534.19832.83)
* [Quan et al. (2011)](https://doi.org/10.1093/aje/kwq433)
* [Glasheen (2019)](https://pubmed.ncbi.nlm.nih.gov/31428236/)


``` r
# Charlson example
cmrbs <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    dx.var = "dx",
    poa = 1,        # assume all codes are present on admission
    primarydx = 0L, # assume all codes are secondary diagnosis codes
    method = "charlson_quan2005"
  )
```
A summary of the flagged conditions can be generated by calling `summary()`.
Where the summary for the PCCC method was a `data.frame` the return for the
Charlson comorbidities is a list of data frames summarizing the conditions, age
category, and the index score.

``` r
s <- summary(cmrbs)
str(s, max.level = 1)
```

More details and examples are provided in the vignette:

``` r
vignette(topic = "charlson", package = "medicalcoder")
```

#### Elixhauser Comorbidities

* [Elixhauser et al. (1998)](https://doi.org/10.1097/00005650-199801000-00004)
  * `method = elixhauser_elixhauser1988`
* [Quan et al. (2005)](https://doi.org/10.1097/01.mlr.0000182534.19832.83)
  * `method = elixhauser_quan2005`
* AHRQ (2017, 2022, 2023, 2024, 2025, ICD10)
  * [For ICD-9 codes](https://hcup-us.ahrq.gov/toolssoftware/comorbidity/comorbidity.jsp)
    * `method = elixhauser_ahrq_web`
  * [For ICD-10 codes](https://hcup-us.ahrq.gov/toolssoftware/comorbidityicd10/comorbidity_icd10.jsp)
    * `method = elixhauser_ahrq2022`
    * `method = elixhauser_ahrq2023`
    * `method = elixhauser_ahrq2024`
    * `method = elixhauser_ahrq2025`
    * `method = elixhauser_ahrq_icd10`


``` r
# Elixhauser example
cmrbs <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    dx.var = "dx",
    poa = 1,
    primarydx = 0L,
    method = "elixhauser_ahrq_icd10"
  )
```
The summary for the results from `method = elixhauser_ahrq_icd10` are similar to those for
Charlson. A `data.frame` with the counts and percentages of distinct
`data[id.vars]` with the noted condition, and a summary of the index scores.

``` r
s <- summary(cmrbs)
str(s, max.level = 1)
```

More details and examples are provided in the vignette:

``` r
vignette(topic = "elixhauser", package = "medicalcoder")
```

### ICD

The package contains internal data sets with references for ICD-9 and ICD-10 US
based diagnostic and procedure codes. These codes are supplemented with
additional codes from the World Health Organization.

You can get a table of ICD codes via `get_icd_codes()`.

``` r
str(medicalcoder::get_icd_codes())
#> 'data.frame':	227534 obs. of  9 variables:
#>  $ icdv            : int  9 9 9 9 9 9 9 9 9 9 ...
#>  $ dx              : int  0 0 0 0 0 0 1 0 1 0 ...
#>  $ full_code       : chr  "00" "00.0" "00.01" "00.02" ...
#>  $ code            : chr  "00" "000" "0001" "0002" ...
#>  $ src             : chr  "cms" "cms" "cms" "cms" ...
#>  $ known_start     : int  2003 2003 2003 2003 2003 2003 1997 2003 1997 2003 ...
#>  $ known_end       : int  2015 2015 2015 2015 2015 2015 2015 2015 2015 2015 ...
#>  $ assignable_start: int  NA NA 2003 2003 2003 2003 NA NA 1997 2003 ...
#>  $ assignable_end  : int  NA NA 2015 2015 2015 2015 NA NA 2015 2015 ...
```

The columns are:

* `icdv`: integer value 9 or 10; for ICD-9 or ICD-10

* `dx`:   integer 0 or 1; 0 = procedure code, 1 = diagnostic code

* `full_code`: character string for the ICD code with any appropriate decimal point.

* `code`: character string for the compact ICD code, that is, the ICD code
  without any decimal point, e.g., the full code C00.1 has the compact code form
  C001.

* `src`: character string denoting the source of the ICD code information.
    * `cms`: The ICD-9-CM, ICD-9-PCS, ICD-10-CM, or ICD-10-PCS codes curated
      by the Centers for Medicare and Medicaid Services (CMS).
    * `cdc`: CDC mortality coding.
    * `who`: World Health Organization.

* `known_start`: The earliest (fiscal) year when source data for the code was
  available in the source code for medicalcoder.  Codes from CMS are for the
  United States fiscal year.  Codes from CDC and WHO are calendar year.  The
  United States fiscal year starts October 1 and concludes September 30.  For
  example, fiscal year 2013 started October 1 2012 and concluded September 30 2013.

  To reemphasize that the year is for the data within medicalcoder.  For
  ICD-9-CM, the codes went into effect for fiscal year 1980.  The source code
  only has documented source files for the codes dating back to
  1997.

* `known_end`: The latest (fiscal) year when the code was part of the ICD
  system and/or known within the medicalcoder lookup tables.

* Assignable codes.  Some codes are header codes, e.g., ICD-10-CM three-digit
  code Z94 is a header code because the four-digit codes Z94.0, Z94.1, Z94.2,
  Z94.3, Z94.4, Z94.5, Z94.6, Z94.7, Z94.8, and Z94.9 exist. All but Z94.8 are
  assignable codes because no five-digit codes with the same initial four-digits
  exist.  Z94.8 is a header code because the five-digit codes Z94.81, Z94.82,
  Z94.83, Z94.84, and Z94.89 exist.
    * `assignable_start`: Earliest (fiscal) year when the code was assignable.
    * `assignable_end`: Latest (fiscal) year when the code was assignable.


``` r
subset(
  x = lookup_icd_codes("^Z94", regex = TRUE, full.codes = TRUE, compact.codes = FALSE),
  subset = src == "cms",
  select = c("full_code", "known_start", "known_end", "assignable_start", "assignable_end")
)
#>    full_code known_start known_end assignable_start assignable_end
#> 1        Z94        2014      2026               NA             NA
#> 5      Z94.0        2014      2026             2014           2026
#> 9      Z94.1        2014      2026             2014           2026
#> 14     Z94.2        2014      2026             2014           2026
#> 17     Z94.3        2014      2026             2014           2026
#> 22     Z94.4        2014      2026             2014           2026
#> 25     Z94.5        2014      2026             2014           2026
#> 29     Z94.6        2014      2026             2014           2026
#> 33     Z94.7        2014      2026             2014           2026
#> 38     Z94.8        2014      2026               NA             NA
#> 41    Z94.81        2014      2026             2014           2026
#> 42    Z94.82        2014      2026             2014           2026
#> 43    Z94.83        2014      2026             2014           2026
#> 44    Z94.84        2014      2026             2014           2026
#> 45    Z94.89        2014      2026             2014           2026
#> 46     Z94.9        2014      2026             2014           2026
```

Additionally, the `get_icd_codes()` method can provide descriptions and the ICD
hierarchy by using the `with.descriptions` and/or `with.hierarchy` arguments.

Functions `lookup_icd_codes()`, `is_icd()`, and `icd_compact_to_full()` are also
provided for working with ICD codes.

More details and examples are in the vignette:

``` r
vignette(topic = "icd", package = "medicalcoder")
```

## Benchmarking

The major factors impacting the expected computation time for applying a
comorbidity algorithm to a data set are:

1. Data size: number of subjects/encounters.
2. Data storage class: medicalcoder has been built such that no imports of
   other namespaces is required.  That said, when a `data.table` is passed to
   `comorbidities()` and the `data.table` namespace is available, then S3
   dispatch for `merge` is used, along with some other methods, to reduce memory
   use and reduce computation time.
3. `flag.method`: "current" will take less time than the "cumulative" method.

Details on the benchmarking method, summary graphics, and tables,  can be found
on the medicalcoder GitHub
[benchmarking](https://github.com/dewittpe/medicalcoder/tree/main/benchmarking)
directory.

## Testing

Along with the GitHub actions and testing on current versions of R, the
[testing](https://github.com/dewittpe/medicalcoder/tree/main/testing)
directory in the medicalcoder GitHub repo reports the `R CMD check` results for
all R versions from 3.5.0 to latest.  Several with, and without Sugguests.
