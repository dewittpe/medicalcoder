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

mdcrDT <- data.table::as.data.table(medicalcoder::mdcr)
mdcrDT_icd9dx  <- subset(mdcrDT, icdv ==  9L & dx == 1L)
mdcrDT_icd10dx <- subset(mdcrDT, icdv == 10L & dx == 1L)
mdcrDT_icd9dx <-
  rbind(
    mdcrDT_icd9dx,
    data.table::data.table(
      patid = setdiff(mdcrDT$patid, mdcrDT_icd9dx$patid),
      icdv = 9L,
      code = "",
      dx = 1L
    )
  )
mdcrDT_icd10dx <-
  rbind(
    mdcrDT_icd10dx,
    data.table::data.table(
      patid = setdiff(mdcrDT$patid, mdcrDT_icd10dx$patid),
      icdv = 10L,
      code = "",
      dx = 1L
    )
  )
```

[`icdcomorbid::long_to_wide()`](https://rdrr.io/pkg/icdcomorbid/man/long_to_wide.html)
is provided to transform data sets, but it is very slow. I waited about
fifteen seconds for the following and then stopped the process because
there are more efficient ways.

``` r

#  mdcrDT_icd9dx_wide <-
#    icdcomorbid::long_to_wide(
#      df = mdcrDT_icd9dx,
#      idx = "patid",
#      icd_cols = "code"
#    )
#
# killed process after 15 seconds
```

``` r

tic <- Sys.time()

mdcrDT_icd9dx[, DX := paste0("DX", seq_along(code)), by = .(patid)]
mdcrDT_icd10dx[, DX := paste0("DX", seq_along(code)), by = .(patid)]

mdcrDT_icd9dx_wide <-
  data.table::dcast(mdcrDT_icd9dx, patid ~ DX, value.var = "code")

mdcrDT_icd10dx_wide <-
  data.table::dcast(mdcrDT_icd10dx, patid ~ DX, value.var = "code")

toc <- Sys.time()

difftime(toc, tic, units = "secs")
## Time difference of 0.5973091 secs
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
    data      = mdcrDT,
    id.vars   = "patid",
    icd.codes = "code",
    dx.var    = "dx",
    icdv.var  = "icdv",
    poa       = 1L, # assume all codes are present on admission
    primarydx = 0L, # assume all codes are secondary diagnoses
    method    = "charlson_quan2011"
  )

toc <- Sys.time()

attr(medicalcoder_charlson_results, "tictoc") <-
  as.numeric(difftime(toc, tic, units = "secs"))
```

There are 38262 patids to assess. To compare the results between
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
and the results from the R package icdcomorbid would require calling
[`icdcomorbid::icd9_to_comorbid()`](https://rdrr.io/pkg/icdcomorbid/man/icd9_to_comorbid.html),
[`icd10_to_comorbid()`](https://rdrr.io/pkg/icdcomorbid/man/icd10_to_comorbid.html),
aggregating the results, and scoring.

``` r

tic <- Sys.time()

icdcomorbid_charlson_icd9_results <-
  icdcomorbid::icd9_to_comorbid(
    df = mdcrDT_icd9dx_wide,
    idx = "patid",
    icd_cols = grep("^DX", names(mdcrDT_icd9dx_wide), value = TRUE),
    mapping = "charlson9"
  )

icdcomorbid_charlson_icd10_results <-
  icdcomorbid::icd10_to_comorbid(
    df = mdcrDT_icd10dx_wide,
    idx = "patid",
    icd_cols = grep("^DX", names(mdcrDT_icd10dx_wide), value = TRUE),
    mapping = "charlson10"
  )

icdcomorbid_charlson_results <-
  rbind(
    data.table::setDT(icdcomorbid_charlson_icd9_results),
    data.table::setDT(icdcomorbid_charlson_icd10_results),
    use.names = TRUE,
    fill = TRUE
  )

# Slow aggregating
#icdcomorbid_charlson_results <-
#  aggregate(
#    . ~ patid,
#    data = icdcomorbid_charlson_results,
#    FUN = any,
#    na.rm = TRUE
#  )

# faster aggregating
icdcomorbid_charlson_results <-
  icdcomorbid_charlson_results[
    ,
    lapply(.SD, any),
    by = .(patid),
    .SDcols = -"patid"
  ]

toc <- Sys.time()

attr(icdcomorbid_charlson_results, "tictoc") <-
  as.numeric(difftime(toc, tic, units = "secs"))
```

The amount of time required to process the data differs greatly between
the packages.

``` r

attr(medicalcoder_charlson_results, "tictoc") # seconds
## [1] 0.3171103
attr(icdcomorbid_charlson_results,  "tictoc") # seconds
## [1] 608.8486
```

The return from icdcomorbid are booleans. We will coerce to integers
before comparing to medicalcoder.

``` r

data.table::setDT(icdcomorbid_charlson_results)
for (j in setdiff(names(icdcomorbid_charlson_results), "patid")) {
  data.table::set(
    icdcomorbid_charlson_results,
    j = j,
    value = as.integer(icdcomorbid_charlson_results[[j]])
  )
}
mdcr_v_icdcomorbid <-
  merge(
    x = medicalcoder_charlson_results,
    y = icdcomorbid_charlson_results,
    all = TRUE,
    by = c("patid")
  )
```

Let’s compare the results starting the AIDS/HIV.

``` r

identical(
  mdcr_v_icdcomorbid[["aidshiv"]],  # medicalcoder::comorbidities()
  mdcr_v_icdcomorbid[["aids_hiv"]]  # icdcomorbid
)
## [1] FALSE

mdcr_v_icdcomorbid[aidshiv != aids_hiv, .(patid, aidshiv, aids_hiv)]
## Key: <patid>
##    patid aidshiv aids_hiv
##    <int>   <int>    <int>
## 1: 11834       1        0
## 2: 21758       1        0
## 3: 51157       1        0
## 4: 60140       1        0
## 5: 64670       1        0

merge(
  x = data.table::as.data.table(mdcr)[patid %in% mdcr_v_icdcomorbid[aidshiv != aids_hiv, patid]],
  y = subset(
        x      = medicalcoder::get_charlson_codes(),
        subset = condition == "aidshiv",
        select = c("code", "icdv", "dx", "condition", "charlson_quan2005")
        ),
  by = c("code", "icdv", "dx")
)
## Key: <code, icdv, dx>
##      code  icdv    dx patid condition charlson_quan2005
##    <char> <int> <int> <int>    <char>             <int>
## 1:    042     9     1 21758   aidshiv                 1
## 2:    042     9     1 11834   aidshiv                 1
## 3:    042     9     1 60140   aidshiv                 1
## 4:    042     9     1 51157   aidshiv                 1
## 5:    042     9     1 51157   aidshiv                 1
## 6:    042     9     1 64670   aidshiv                 1
```

There are differences in the flags for AIDS/HIV, all false-negatives
from icdcomorbid. The issue, as shown below, is that ICD-9-CM code 042
is not flagged as AIDS/HIV by icdcomorbid. This appears to be due to the
string “042.x” using within the json files within icdcomorbid for
mapping codes to comorbidities. Table 1 within Quan (2005) (Quan et al.
2005) reports “042.x-044.x” which should match any ICD-9 code under the
three digit code 042, 043, or 044. (Note: 043 and 044 were removed from
the ICD-9-CM standard starting October 1, 1994 (fiscal year 1995) which
is before the earliest set of codes medicalcoder has in its internal
database.)

Within icdcomorbid, the references file for the Charlson ICD-9 codes
appears to have 042.x. The false-negative suggests an issue with the way
comorbidities are flagged.

``` r

scan(
  file = system.file(package = "icdcomorbid", "comorbidity_mappings", "charlson9.json"),
  what = "character",
  sep = "\n",
  quiet = TRUE
) |>
grep("aids_hiv", x = _, value = TRUE)
## [1] "    \"aids_hiv\":[\"042.x\",\"043.x\",\"044.x\"]"
```

Next, congestive heart failure.

``` r

identical(
  mdcr_v_icdcomorbid[["chf"]],  # medicalcoder::comorbidities()
  mdcr_v_icdcomorbid[["congestive_heart_failure"]]  # icdcomorbid
)
## [1] FALSE
mdcr_v_icdcomorbid[
  chf != congestive_heart_failure,
  .(patid, chf, congestive_heart_failure)
]
## Key: <patid>
##      patid   chf congestive_heart_failure
##      <int> <int>                    <int>
##   1: 10114     1                        0
##   2: 10229     1                        0
##   3: 10374     1                        0
##   4: 10409     1                        0
##   5: 11113     1                        0
##  ---                                     
## 493: 98523     1                        0
## 494: 98599     1                        0
## 495: 99487     1                        0
## 496: 99637     1                        0
## 497: 99719     1                        0

mdcr_v_icdcomorbid[, .N, keyby = .(chf, congestive_heart_failure)]
## Key: <chf, congestive_heart_failure>
##      chf congestive_heart_failure     N
##    <int>                    <int> <int>
## 1:     0                        0 37550
## 2:     0                        1    28
## 3:     1                        0   469
## 4:     1                        1   215
```

Focusing on the differences:

``` r

mdcr_v_icdcomorbid[
  !Vectorize(identical)(chf, congestive_heart_failure),
  .N,
  keyby = .(chf, congestive_heart_failure)
  ]
## Key: <chf, congestive_heart_failure>
##      chf congestive_heart_failure     N
##    <int>                    <int> <int>
## 1:     0                        1    28
## 2:     1                        0   469
```

There are records which are missing form the results from icdcomorbid.
In these cases, it appears that the missing rows are from records with
no comorbidities flagged. It should be noted that not all cases of
`num_cmrb == 0` have missing values for `congestive_heart_failure`.

``` r

mdcr_v_icdcomorbid[num_cmrb == 0, .N]
## [1] 28470
mdcr_v_icdcomorbid[is.na(congestive_heart_failure), all(num_cmrb == 0)]
## [1] TRUE
```

What about the cases where icdcomorbid flagged congestive_heart_failure
and medicalcoder did not

``` r

# where does icdcomorbid flag that medicalcoder does not?
DT <-
  mdcrDT[patid %in% mdcr_v_icdcomorbid[congestive_heart_failure > chf, patid]]

all(DT$icdv == 10L)
## [1] TRUE

DT <- DT[, unique(.SD), .SDcols = c("code")]
DT[, code_id := 1:.N]
DT[, DX := "DX"]
DT <- data.table::dcast(DT, code_id ~ DX, value.var = "code")

false_positives <-
  icdcomorbid::icd10_to_comorbid(
    df = DT,
    idx = "code_id",
    icd_cols = "DX", mapping = "charlson10"
  )
data.table::setDT(false_positives)

false_positives[(congestive_heart_failure), .N]
## [1] 2

DT[
  false_positives[(congestive_heart_failure)], on = "code_id"
  ][
  , .(DX, congestive_heart_failure)
  ]
##        DX congestive_heart_failure
##    <char>                   <lgcl>
## 1:  P2930                     TRUE
## 2:  I1310                     TRUE
```

- P2930 (full code P29.30) should not be part of the Charlson
  comorbidities for CHF, I’m not sure why this is flagging at the
  moment, the JSON files within icdcomorbid report the code P29.0 only,
  which is correct and consistent with Table 1 of (Quan et al. 2005).

- I1310 (full code I13.10) should not flag based on what I see in the
  icdcomorbid JSON files.

``` r

scan(
  file = system.file(package = "icdcomorbid", "comorbidity_mappings", "charlson10.json"),
  what = "character",
  sep = "\n",
  quiet = TRUE) |>
grep("congestive_heart_failure", x = _, value = TRUE)
## [1] "    \"congestive_heart_failure\":[\"I09.9\",\"I11.0\",\"I13.0\",\"I13.2\",\"I25.5\",\"I42.0\",\"I42.5\",\"I42.6\",\"I42.7\",\"I42.8\",\"I42.9\",\"I43.x\",\"I50.x\",\"P29.0\"],"
```

And what about the cases where medicalcoder flags and icdcomorbid does
not?

``` r

icdcomorbid_false_negatives <-
  merge(
    x = mdcrDT[patid %in% mdcr_v_icdcomorbid[congestive_heart_failure < chf, patid]],
    y = subset(
          x      = medicalcoder::get_charlson_codes(),
          subset = condition == "chf",
          select = c("code", "icdv", "dx", "condition", "charlson_quan2005")
          ),
    by = c("code", "icdv", "dx")
  )
str(icdcomorbid_false_negatives)
## Classes 'data.table' and 'data.frame':   659 obs. of  6 variables:
##  $ code             : chr  "40401" "40491" "40491" "4254" ...
##  $ icdv             : int  9 9 9 9 9 9 9 9 9 9 ...
##  $ dx               : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ patid            : int  19368 40729 86363 79065 80692 60642 61627 89753 66356 71033 ...
##  $ condition        : chr  "chf" "chf" "chf" "chf" ...
##  $ charlson_quan2005: int  1 1 1 1 1 1 1 1 1 1 ...
##  - attr(*, ".internal.selfref")=<pointer: 0x55cbdcbe5ee0> 
##  - attr(*, "sorted")= chr [1:3] "code" "icdv" "dx"

unique(icdcomorbid_false_negatives[icdv == 9 & dx == 1, .(code)][["code"]])
##  [1] "40401" "40491" "4254"  "4257"  "4258"  "4259"  "4280"  "4281"  "42820"
## [10] "42821" "42822" "42823" "42830" "42831" "42832" "42833" "42840" "42841"
## [19] "42842" "42843" "4289"
unique(icdcomorbid_false_negatives[icdv == 10 & dx == 1, .(code)][["code"]])
## [1] "I110" "I132" "I255" "I420" "I425" "I427" "I428" "I429" "P290"
```

These are all false negatives from icdcomorbid.

Given the false positive and false negative results, along with several
orders of magnitude longer computation time, we conclude here that
medicalcoder is preferable to icdcomorbid.

There are many more conditions to explore, but the above should be
sufficient to support using medicalcoder over icdcomorbid.

## References

Nguyen, April, and Seungwon Lee. 2024. *Icdcomorbid: Mapping ICD Codes
to Comorbidity*. <https://doi.org/10.32614/CRAN.package.icdcomorbid>.

Quan, Hude, Vijaya Sundararajan, Patricia Halfon, et al. 2005. “Coding
Algorithms for Defining Comorbidities in ICD-9-CM and ICD-10
Administrative Data.” *Medical Care* 43 (11): 1130–39.
<https://doi.org/10.1097/01.mlr.0000182534.19832.83>.
