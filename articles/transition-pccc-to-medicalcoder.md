# Transition From The pccc Package to the medicalcoder Package

## Introduction

The R package [pccc](https://cran.r-project.org/package=pccc) (James A.
Feinstein et al. 2018; DeWitt, Feinstein, and Russell 2026) was
published to support version 2 of the Pediatric Complex Chronic
Conditions (PCCC) (Feudtner et al. 2014). This document is provided to
help users of pccc to transition to medicalcoder.

Major differences between
[`pccc::ccc()`](https://rdrr.io/pkg/pccc/man/ccc.html) and
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md):

1.  Input data format

    - [`pccc::ccc()`](https://rdrr.io/pkg/pccc/man/ccc.html) expects a
      data.frame with each row representing one patient and/or
      encounter. There is a column for each diagnostic and procedure
      code. For example, a data set were the max number of diagnostic
      codes is six and the max number of procedure codes is five, an
      entry for patient XX could look like the following:

&nbsp;

      patid    dx1    dx2    dx3    dx4 dx5 dx6     pr1     pr2     pr3     pr4 pr5
      patXX  T8619  E8809   E876  Z7982  NA  NA 02PAX3Z 5A1D70Z 04Q90ZZ 0TS60ZZ  NA

- [`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  expects the input data to be in a data.frame where each row is single
  ICD code. For example, the same record for patient XX above would be
  three columns below, one row for each code, one column to identify the
  patient/encounter, and a column to denote if the code is a diagnostic
  (dx = 1) or procedure (dx = 0).

&nbsp;

      patid    code  dx
      patXX   T8619   1
      patXX   E8809   1
      patXX    E876   1
      patXX   Z7982   1
      patXX 02PAX3Z   0
      patXX 5A1D70Z   0
      patXX 04Q90ZZ   0
      patXX 0TS60ZZ   0

2.  ICD Version

- [`pccc::ccc()`](https://rdrr.io/pkg/pccc/man/ccc.html) only considers
  ICD-9 and ICD-10 independently. If the input data consists of both
  ICD-9 and ICD-10 data false negatives will be inevitable. The version
  is set by the `icdv` argument to
  [`pccc::ccc()`](https://rdrr.io/pkg/pccc/man/ccc.html).

- [`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  considers both ICD-9 and ICD-10 at the same time. A column added to
  the input data to identify the code version allows for a single
  patient/encounter record to consist of both version and to have PCCC
  flagged accordingly. Users specify the ICD version via the arguments
  `icdv` and `icdv.var` to
  [`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md).

3.  PCCC Versions

- [`pccc::ccc()`](https://rdrr.io/pkg/pccc/man/ccc.html) only implements
  PCCC version 2 (Feudtner et al. 2014)

- [`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  implements:

  - `pccc_v2.0`: consistent results with
    [`pccc::ccc()`](https://rdrr.io/pkg/pccc/man/ccc.html) for pccc
    version 1.0.7.

  - `pccc_v2.1`: improved mappings of ICD codes to PCCC using the PCCC
    v2 scoring algorithm.

  - `pccc_v3.0`: consistent with SAS code published with PCCC version 3
    (James A. Feinstein et al. 2024).

  - `pccc_v3.1`: extended set of ICD code to condition mappings.

  - Note: medicalcoder also provides several variants of the Charlson
    and Elixhauser comorbidities.

4.  Subconditions

- [`pccc::ccc()`](https://rdrr.io/pkg/pccc/man/ccc.html) only returns
  flags for primary conditions

- [`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md):
  when the argument `subconditions = TRUE` is passed in, for PCCC the
  primary conditions and subconditions are flagged. Examples to follow.

5.  Present-on-Admission and Longitudinal data

- [`pccc::ccc()`](https://rdrr.io/pkg/pccc/man/ccc.html) only considers
  singular encounters and considers all codes to be
  present-on-admission.

- [`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  can account for present-on-admission flags and longitudinal flagging
  of comorbidities within a patient over multiple encounters.

## `pccc::ccc()` vs `medicalcoder::comorbidities()`

``` r
library(pccc)
packageVersion("pccc")
## [1] '1.0.7'
library(medicalcoder)
```

### Prepare Data

We’ll use the `mdcr` data set from the medicalcoder package.

``` r
head(mdcr)
##   patid icdv  code dx
## 1 71412    9 99931  1
## 2 71412    9 75169  1
## 3 71412    9 99591  1
## 4 71412    9 V5865  1
## 5 71412    9  V427  1
## 6 17087   10  V441  1
```

We will split the data set into two sets, one for ICD-9 and one for
ICD-10.

Using the tidyverse we can build the needed input data sets

``` r
mdcr_tbls <-
  mdcr |>
  dplyr::group_by(patid, icdv, dx) |>
  dplyr::mutate(n = seq_len(dplyr::n())) |>
  dplyr::ungroup() |>
  dplyr::mutate(dxv = dplyr::if_else(dx == 1, "dx", "pr")) |>
  dplyr::group_by(icdv) |>
  dplyr::group_split()
mdcr_tbls <-
  lapply(mdcr_tbls,
    tidyr::pivot_wider,
    id_cols = "patid",
    names_from = c("dxv", "n"),
    names_sep = "",
    values_from = "code"
  )
```

A data.table approach:

``` r
mdcr_DTs <- data.table::as.data.table(data.table::copy(mdcr))
mdcr_DTs[
  ,
  dxv := paste0(data.table::fifelse(dx == 1, "dx", "pr"), seq_len(.N)),
  by = .(patid, icdv, dx)
]
mdcr_DTs <- split(mdcr_DTs, by = "icdv")
mdcr_DTs <-
  lapply(
    mdcr_DTs,
    data.table::dcast,
    formula = patid ~ dxv,
    value.var = "code",
    na.rm = FALSE
  )
```

### Applying `pccc::ccc()`

To flag PCCC via [`pccc::ccc()`](https://rdrr.io/pkg/pccc/man/ccc.html)
we need to call [`pccc::ccc()`](https://rdrr.io/pkg/pccc/man/ccc.html)
twice and to then aggregate the results.

``` r
tic <- Sys.time()

pccc_9_results_tbl <-
  pccc::ccc(
    data = mdcr_tbls[[1]],
    id = patid,
    dx_cols = grep("dx", names(mdcr_tbls[[1]]), value = TRUE),
    pc_cols = grep("pr", names(mdcr_tbls[[1]]), value = TRUE),
    icdv = 9
  )

pccc_10_results_tbl <-
  pccc::ccc(
    data = mdcr_tbls[[2]],
    id = patid,
    dx_cols = grep("dx", names(mdcr_tbls[[2]]), value = TRUE),
    pc_cols = grep("pr", names(mdcr_tbls[[2]]), value = TRUE),
    icdv = 10
  )

pccc_results_tbl <-
  dplyr::bind_rows(pccc_9_results_tbl, pccc_10_results_tbl) |>
  dplyr::group_by(patid) |>
  dplyr::summarize_all(max) |>
  dplyr::ungroup() |>
  dplyr::arrange(patid)

toc <- Sys.time()

pccc_ccc_tbl_time <- difftime(toc, tic, units = "secs")
```

``` r
tic <- Sys.time()

pccc_9_results_DT <-
  pccc::ccc(
    data = mdcr_DTs[[1]],
    id = patid,
    dx_cols = grep("dx", names(mdcr_DTs[[1]]), value = TRUE),
    pc_cols = grep("pr", names(mdcr_DTs[[1]]), value = TRUE),
    icdv = 9
  )

pccc_10_results_DT <-
  pccc::ccc(
    data = mdcr_DTs[[2]],
    id = patid,
    dx_cols = grep("dx", names(mdcr_DTs[[2]]), value = TRUE),
    pc_cols = grep("pr", names(mdcr_DTs[[2]]), value = TRUE),
    icdv = 10
  )

pccc_results_DT <- data.table::rbindlist(list(pccc_9_results_DT, pccc_10_results_DT))

pccc_results_DT <-
  pccc_results_DT[, lapply(.SD, max), by = .(patid), .SDcols = -"patid"]
data.table::setkey(pccc_results_DT, patid)

toc <- Sys.time()

pccc_ccc_dt_time <- difftime(toc, tic)
```

A quick sanity check that we have the same results for both the
tidyverse and data.table input data sets.

``` r
stopifnot(
  isTRUE(
    all.equal(pccc_results_DT, pccc_results_tbl, check.attributes = FALSE)
  )
)
```

### Calling `medicalcoder::comorbidities()`

``` r
tic <- Sys.time()

medicalcoder_results <-
  medicalcoder::comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    icdv.var = "icdv",
    dx.var = "dx",
    method = "pccc_v2.0",
    poa = 1
  )

toc <- Sys.time()
medicalcoder_df_time <- difftime(toc, tic)
```

### Differences in results?

``` r
old_vs_new <-
  merge(
    x = pccc_results_DT,
    y = medicalcoder_results,
    all = TRUE,
    by = "patid",
    suffixes = c("_old", "_new")
  )
```

Most importantly, the condition flag (`ccc_flag` from
[`pccc::ccc()`](https://rdrr.io/pkg/pccc/man/ccc.html) and `cmrb_flag`
from
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md))
are identical.

``` r
stopifnot(
  isTRUE(
    with(old_vs_new, identical(ccc_flag, cmrb_flag))
  )
)
```

Second, the flags for all but the technology dependence and transplant
flags are identical.

``` r
stopifnot(
  with(old_vs_new, identical(neuromusc_old,       neuromusc_new)),
  with(old_vs_new, identical(cvd_old,             cvd_new)),
  with(old_vs_new, identical(respiratory_old,     respiratory_new)),
  with(old_vs_new, identical(renal_old,           renal_new)),
  with(old_vs_new, identical(gi_old,              gi_new)),
  with(old_vs_new, identical(hemato_immu_old,     hemato_immu_new)),
  with(old_vs_new, identical(metabolic_old,       metabolic_new)),
  with(old_vs_new, identical(congeni_genetic_old, congeni_genetic_new)),
  with(old_vs_new, identical(malignancy_old,      malignancy_new)),
  with(old_vs_new, identical(neonatal_old,        neonatal_new))
)
```

Omitting the columns which are as expected from the `old_vs_new`
data.table we can focus in on the differences in the results.

``` r
good <- c("neuromusc", "cvd", "respiratory", "renal", "gi", "hemato_immu",
  "metabolic", "congeni_genetic", "malignancy", "neonatal", "ccc_flag",
  "cmrb_flag")

for(g in good) {
  for (j in grep(g, names(old_vs_new), value = TRUE)) {
    data.table::set(old_vs_new, j = j, value = NULL)
  }
}

old_vs_new
## Key: <patid>
##        patid tech_dep transplant  misc any_tech_dep any_transplant num_cmrb
##        <int>    <int>      <int> <int>        <int>          <int>    <int>
##     1: 10000        0          0     0            0              0        0
##     2: 10002        0          0     0            0              0        1
##     3: 10005        0          0     0            0              0        1
##     4: 10006        0          0     0            0              0        1
##     5: 10008        0          0     0            0              0        1
##    ---                                                                     
## 38258: 99992        0          0     0            0              0        0
## 38259: 99995        0          0     0            0              0        0
## 38260: 99997        0          0     0            0              0        0
## 38261: 99998        0          0     0            0              0        1
## 38262: 99999        1          0     0            1              0        3
```

First, the `num_cmrb` column is a count of the number of conditions and
is reported by
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md).
There is not similar flag from
[`pccc::ccc()`](https://rdrr.io/pkg/pccc/man/ccc.html).

``` r
old_vs_new[, num_cmrb := NULL]
```

The `misc` column is the “miscellaneous” category reported by
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
and is not reported by
[`pccc::ccc()`](https://rdrr.io/pkg/pccc/man/ccc.html). The existence of
the `misc` column and some differences in the returned results between
[`pccc::ccc()`](https://rdrr.io/pkg/pccc/man/ccc.html) version 1.0.7,
and
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
is due to how medicalcoder is implemented.

``` r
old_vs_new
## Key: <patid>
##        patid tech_dep transplant  misc any_tech_dep any_transplant
##        <int>    <int>      <int> <int>        <int>          <int>
##     1: 10000        0          0     0            0              0
##     2: 10002        0          0     0            0              0
##     3: 10005        0          0     0            0              0
##     4: 10006        0          0     0            0              0
##     5: 10008        0          0     0            0              0
##    ---                                                            
## 38258: 99992        0          0     0            0              0
## 38259: 99995        0          0     0            0              0
## 38260: 99997        0          0     0            0              0
## 38261: 99998        0          0     0            0              0
## 38262: 99999        1          0     0            1              0
```

There are several ICD codes which need to be corrected in pccc

GitHub links:

- [ICD-9 349.1](https://github.com/CUD2V/pccc/issues/45)
- [ICD-9 V56](https://github.com/CUD2V/pccc/issues/46)
- [ICD-10 Z49](https://github.com/CUD2V/pccc/issues/47)
- [ICD-9 86.06](https://github.com/CUD2V/pccc/issues/48)
- [ICD-9 V45.85](https://github.com/CUD2V/pccc/issues/49)
- [ICD-9 V53.3](https://github.com/CUD2V/pccc/issues/50)
- [ICD-9 V53.91](https://github.com/CUD2V/pccc/issues/51)
- [ICD-9 V65.46](https://github.com/CUD2V/pccc/issues/52)
- [ICD-9 37.52](https://github.com/CUD2V/pccc/issues/53)
- [ICD-9 V42.0](https://github.com/CUD2V/pccc/issues/54)
- [ICD-10 Z94](https://github.com/CUD2V/pccc/issues/55)

## Additional Benefits of medicalcoder

### Computation Performance

medicalcoder was built such that only base R is needed to install and
use the package. That said, there is specific support for the tidyverse
and data.table. For example, the same calls as above but with either a
tibble or a data.table instead of a simple base R data.table take less
time to compute. The differences here are small. See
[benchmarking](https://github.com/dewittpe/medicalcoder/tree/main/benchmarking)
for more details.

``` r
mdcr_tbl <- tibble::as_tibble(mdcr)
tic <- Sys.time()
medicalcoder_results <-
  medicalcoder::comorbidities(
    data = mdcr_tbl,
    id.vars = "patid",
    icd.codes = "code",
    icdv.var = "icdv",
    dx.var = "dx",
    method = "pccc_v2.0",
    poa = 1
  )
toc <- Sys.time()
medicalcoder_tbl_time <- difftime(toc, tic, units = "secs")

mdcr_DT <- data.table::as.data.table(data.table::copy(mdcr))
tic <- Sys.time()
medicalcoder_results <-
  medicalcoder::comorbidities(
    data = mdcr_tbl,
    id.vars = "patid",
    icd.codes = "code",
    icdv.var = "icdv",
    dx.var = "dx",
    method = "pccc_v2.0",
    poa = 1
  )
toc <- Sys.time()
medicalcoder_dt_time <- difftime(toc, tic, units = "secs")
```

``` r
pccc_ccc_tbl_time
## Time difference of 9.59286 secs
pccc_ccc_dt_time
## Time difference of 7.187675 secs
medicalcoder_df_time
## Time difference of 0.5783758 secs
medicalcoder_tbl_time
## Time difference of 0.3043261 secs
medicalcoder_dt_time
## Time difference of 0.4581563 secs
```

### Summary of results

A simple call to [`summary()`](https://rdrr.io/r/base/summary.html) will
return a data.frame with counts and percentages for the

``` r
summary(medicalcoder_results)
##          condition                                   label count      percent
## 1  congeni_genetic      Other Congenital or Genetic Defect  3399  8.883487533
## 2              cvd                          Cardiovascular  4952 12.942344885
## 3               gi                        Gastrointestinal  6233 16.290314150
## 4      hemato_immu              Hematologic or Immunologic  2695  7.043541895
## 5       malignancy                              Malignancy  3733  9.756416288
## 6        metabolic                               Metabolic  2983  7.796246929
## 7             misc Miscellaneous, Not Elsewhere Classified   822  2.148345617
## 8         neonatal                    Premature & Neonatal  1559  4.074538707
## 9        neuromusc             Neurologic or Neuromuscular  5580 14.583660028
## 10           renal                          Renal Urologic  2807  7.336260520
## 11     respiratory                             Respiratory  3040  7.945219800
## 12    any_tech_dep               Any Technology Dependence  7897 20.639276567
## 13  any_transplant                     Any Transplantation  1453  3.797501437
## 14       cmrb_flag                           Any Condition 21283 55.624379280
## 15        num_cmrb                         >= 2 conditions 10448 27.306465945
## 16        num_cmrb                         >= 3 conditions  4313 11.272280592
## 17        num_cmrb                         >= 4 conditions  1353  3.536145523
## 18        num_cmrb                         >= 5 conditions   335  0.875542314
## 19        num_cmrb                         >= 6 conditions    64  0.167267785
## 20        num_cmrb                         >= 7 conditions     6  0.015681355
## 21        num_cmrb                         >= 8 conditions     1  0.002613559
## 22        num_cmrb                         >= 9 conditions     0  0.000000000
## 23        num_cmrb                        >= 10 conditions     0  0.000000000
## 24        num_cmrb                        >= 11 conditions     0  0.000000000
```

### Subconditions

In the documentation for both PCCC v2 and v3 there are subconditions.
For example, there are 8 subconditions under cardiovascular disease:

1.  cardiomyopathies
2.  conduction disorder
3.  device and technology use
4.  dysrhythmias
5.  endocardium diseases
6.  heart and great vessel malformations
7.  other
8.  transplantation

Calling
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
with `subconditions = TRUE` when working with PCCC will flag these
conditions as well as the primary conditions.

``` r
with_subconditions <-
  medicalcoder::comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    icdv.var = "icdv",
    dx.var = "dx",
    method = "pccc_v2.0",
    poa = 1,
    subconditions = TRUE
  )

with_subconditions
## 
## Comorbidities and Subconditions via pccc_v2.0
## 
## List of 2
##  $ conditions   :'data.frame':   38262 obs. of  16 variables:
##  $ subconditions:List of 11
##   ..$ congeni_genetic:'data.frame':  3399 obs. of  5 variables:
##   ..$ cvd            :'data.frame':  4952 obs. of  9 variables:
##   ..$ gi             :'data.frame':  6233 obs. of  7 variables:
##   ..$ hemato_immu    :'data.frame':  2695 obs. of  13 variables:
##   ..$ malignancy     :'data.frame':  3733 obs. of  3 variables:
##   ..$ metabolic      :'data.frame':  2983 obs. of  8 variables:
##   ..$ misc           :'data.frame':  822 obs. of  3 variables:
##   ..$ neonatal       :'data.frame':  1559 obs. of  9 variables:
##   ..$ neuromusc      :'data.frame':  5580 obs. of  11 variables:
##   ..$ renal          :'data.frame':  2807 obs. of  7 variables:
##   ..$ respiratory    :'data.frame':  3040 obs. of  7 variables:
```

The summary includes counts and percentages as before. Additionally, for
a subconditon, the percentage is reported as percent of the cohort and
as the percent of those with the primary condition.

``` r
str(summary(with_subconditions))
## 'data.frame':    82 obs. of  5 variables:
##  $ condition                      : chr  "congeni_genetic" "congeni_genetic" "congeni_genetic" "congeni_genetic" ...
##  $ subcondition                   : chr  NA "bone_and_joint_anomalies" "chromosomal_anomalies" "diaphragm_and_abdominal_wall_anomalies" ...
##  $ count                          : num  3399 1239 1509 300 552 ...
##  $ percent_of_cohort              : num  8.883 3.238 3.944 0.784 1.443 ...
##  $ percent_of_those_with_condition: num  NA 36.45 44.4 8.83 16.24 ...
```

Using tools such as kableExtra, these summaries can be formatted into
publication ready tables. For example, say we want to report on the
cardiovascular and metabolic conditions and subconditions.

``` r
cvd_and_metabolic <- subset(summary(with_subconditions), condition %in% c("cvd", "metabolic"))
cvd_and_metabolic$subcondition[is.na(cvd_and_metabolic$subcondition)] <- "Any subcondition"

kableExtra::kbl(
  x = cvd_and_metabolic[, c("subcondition", "count", "percent_of_cohort", "percent_of_those_with_condition")],
  caption = "Patients with cardiovascular and/or metabolic conditions and the associated with_subconditions.",
  row.names = FALSE,
  digits = 2,
  col.names = c("Subcondition", "Patients", "% of chort", "% of those with the primary condition")
) |>
kableExtra::kable_styling(bootstrap_options = "striped") |>
kableExtra::pack_rows(index = table(cvd_and_metabolic$condition))
```

| Subcondition                         | Patients | % of chort | % of those with the primary condition |
|--------------------------------------|----------|------------|---------------------------------------|
| **cvd**                              |          |            |                                       |
| Any subcondition                     | 4952     | 12.94      |                                       |
| cardiomyopathies                     | 240      | 0.63       | 4.85                                  |
| conduction_disorder                  | 653      | 1.71       | 13.19                                 |
| device_and_technology_use            | 438      | 1.14       | 8.84                                  |
| dysrhythmias                         | 1130     | 2.95       | 22.82                                 |
| endocardium_diseases                 | 247      | 0.65       | 4.99                                  |
| heart_and_great_vessel_malformations | 2298     | 6.01       | 46.41                                 |
| other                                | 1071     | 2.80       | 21.63                                 |
| transplantation                      | 237      | 0.62       | 4.79                                  |
| **metabolic**                        |          |            |                                       |
| Any subcondition                     | 2983     | 7.80       |                                       |
| amino_acid_metabolism                | 187      | 0.49       | 6.27                                  |
| carbohydrate_metabolism              | 130      | 0.34       | 4.36                                  |
| device_and_technology_use            | 71       | 0.19       | 2.38                                  |
| endocrine_disorders                  | 748      | 1.95       | 25.08                                 |
| lipid_metabolism                     | 294      | 0.77       | 9.86                                  |
| other_metabolic_disorders            | 1736     | 4.54       | 58.20                                 |
| storage_disorders                    | 69       | 0.18       | 2.31                                  |

Patients with cardiovascular and/or metabolic conditions and the
associated with_subconditions.

## PCCC version 3

For more detail on the differences between PCCC v2 (Feudtner et al.
2014) and PCCC v3 (Feudtner et al. 2014) see the [PCCC
article](https://www.peteredewitt.com/medicalcoder/articles/pccc.html#pccc-version-2-0-vs-pccc-version-3-0).

## References

DeWitt, Peter, James Feinstein, and Seth Russell. 2026. *Pccc: Pediatric
Complex Chronic Conditions*. <https://github.com/CUD2V/pccc>.

Feinstein, James A, Matt Hall, Amber Davidson, and Chris Feudtner. 2024.
“Pediatric Complex Chronic Condition System Version 3.” *JAMA Network
Open* 7 (7): e2420579–79.
<https://doi.org/10.1001/jamanetworkopen.2024.20579>.

Feinstein, James A., Seth Russell, Peter E. DeWitt, Chris Feudtner,
Dingwei Dai, and Tellen D. Bennett. 2018. “R Package for Pediatric
Complex Chronic Condition Classification.” *JAMA Pediatrics* 172 (6):
596–98. <https://doi.org/10.1001/jamapediatrics.2018.0256>.

Feudtner, Chris, James A Feinstein, Wenjun Zhong, Matt Hall, and Dingwei
Dai. 2014. “Pediatric Complex Chronic Conditions Classification System
Version 2: Updated for ICD-10 and Complex Medical Technology Dependence
and Transplantation.” *BMC Pediatrics* 14: 1–7.
<https://doi.org/10.1186/1471-2431-14-199>.
