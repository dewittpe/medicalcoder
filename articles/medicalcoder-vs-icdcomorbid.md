# medicalcoder vs icdcomorbid

## Introduction

The purpose of this article is to compare the API and results between
medicalcoder and the R package
[icdcomorbid](https://cran.r-project.org/package=icdcomorbid) (Nguyen
and Lee 2024).

``` r
library(medicalcoder)
library(icdcomorbid)
packageVersion("icdcomorbid")
## [1] '1.0.0'
packageDescription("icdcomorbid")$Title
## [1] "Mapping ICD Codes to Comorbidity"
cat(packageDescription("icdcomorbid")$Description)
## 
##     Provides tools for mapping International Classification of Diseases codes to comorbidity, 
##     enabling the identification and analysis of various medical conditions within healthcare data.
```

icdcomorbid provides (Quan et al. 2005) Charlson and Elixhauser
comorbidities. A nice feature of icdcomorbid is the ability to use
custom mappings between ICD codes and comorbidities.

## Prepare Data for icdcomorbid

The example data set `mdcr` within medicalcoder is in a format that is
ideal for
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md).
To prepare that data set for use in the
[`icdcomorbid::icd9_to_comorbid()`](https://rdrr.io/pkg/icdcomorbid/man/icd9_to_comorbid.html)
and
[`icdcomorbid::icd10_to_comorbid()`](https://rdrr.io/pkg/icdcomorbid/man/icd10_to_comorbid.html),
the data needs to be in a “wide” format instead of the provided long
format.

We start by splitting the data into ICD-9 and ICD-10 sets and add rows
for any missing patids.

``` r
mdcr_icd9dx  <- subset(mdcr, icdv ==  9L & dx == 1L)
mdcr_icd10dx <- subset(mdcr, icdv == 10L & dx == 1L)
mdcr_icd9dx <-
  rbind(
    mdcr_icd9dx,
    data.frame(patid = setdiff(mdcr$patid, mdcr_icd9dx$patid), icdv = 9L, code = "", dx = 1L)
  )
mdcr_icd10dx <-
  rbind(
    mdcr_icd10dx,
    data.frame(patid = setdiff(mdcr$patid, mdcr_icd10dx$patid), icdv = 10L, code = "", dx = 1L)
  )
```

[`icdcomorbid::long_to_wide()`](https://rdrr.io/pkg/icdcomorbid/man/long_to_wide.html)
is provided to transform data sets, but it is very slow. I waited about
fifteen seconds for the following and then stopped the process because
there are more efficient ways.

``` r
#  mdcr_icd9dx_wide <-
#    icdcomorbid::long_to_wide(
#      df = mdcr_icd9dx,
#      idx = "patid",
#      icd_cols = "code"
#    )
#
# killed process after 15 seconds
```

``` r
tic <- Sys.time()

library(data.table)
setDT(mdcr_icd9dx)
setDT(mdcr_icd10dx)
mdcr_icd9dx[, DX := paste0("DX", seq_along(code)), by = .(patid)]
mdcr_icd10dx[, DX := paste0("DX", seq_along(code)), by = .(patid)]

mdcr_icd9dx_wide <-
  data.table::dcast(mdcr_icd9dx, patid ~ DX, value.var = "code")

mdcr_icd10dx_wide <-
  data.table::dcast(mdcr_icd10dx, patid ~ DX, value.var = "code")

toc <- Sys.time()
difftime(toc, tic, units = "secs")
## Time difference of 0.4476905 secs
```

## Charlson Comorbidities

A detailed comparison between
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
and the methods in the icdcomorbid package will not be presented here.
Note the time required to apply the Charlson comorbidities to the `mdcr`
data set via
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md).

``` r
tic <- Sys.time()

medicalcoder_charlson_results <-
  medicalcoder::comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    dx.var = "dx",
    icdv.var = "icdv",
    poa = 1L, # assume all codes are present on admission
    primarydx = 0L, # assume all codes are secondary diagnoses
    method = "charlson_quan2011"
  )

toc <- Sys.time()

difftime(toc, tic, units = "secs")
## Time difference of 0.5508158 secs
```

Compare that to the amount of time required to process just the first
1,000 patids via
[`icdcomorbid::icd9_to_comorbid()`](https://rdrr.io/pkg/icdcomorbid/man/icd9_to_comorbid.html).

``` r
tic <- Sys.time()

icd9_to_comorbid_results <-
  icdcomorbid::icd9_to_comorbid(
    df = mdcr_icd9dx_wide[1:1000, ],
    idx = "patid",
    icd_cols = grep("^DX", names(mdcr_icd9dx_wide), value = TRUE),
    mapping = "charlson9"
  )

toc <- Sys.time()

difftime(toc, tic, units = "secs")
## Time difference of 5.768837 secs
```

There are 38262 patids to assess. To compare the results between
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
and the results from the R package icdcomorbid would require calling
[`icdcomorbid::icd9_to_comorbid()`](https://rdrr.io/pkg/icdcomorbid/man/icd9_to_comorbid.html),
[`icd10_to_comorbid()`](https://rdrr.io/pkg/icdcomorbid/man/icd10_to_comorbid.html),
aggregating the results, and scoring.

Based just on the time required to compute the results, medicalcoder is
superior to icdcomorbid.

## References

Nguyen, April, and Seungwon Lee. 2024. *Icdcomorbid: Mapping ICD Codes
to Comorbidity*. <https://doi.org/10.32614/CRAN.package.icdcomorbid>.

Quan, Hude, Vijaya Sundararajan, Patricia Halfon, Andrew Fong, Bernard
Burnand, Jean-Christophe Luthi, L Duncan Saunders, Catherine A. Beck,
Thomas E. Feasby, and William A. Ghali. 2005. “Coding Algorithms for
Defining Comorbidities in ICD-9-CM and ICD-10 Administrative Data.”
*Medical Care* 43 (11): 1130–39.
<https://doi.org/10.1097/01.mlr.0000182534.19832.83>.
