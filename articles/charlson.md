# Charlson Comorbidities

``` r

library(medicalcoder)
packageVersion("medicalcoder")
## [1] '0.8.0'
```

## Introduction

The medicalcoder package implements several variants of the Charlson
comorbidities algorithm.

- `charlson_deyo1992`: Deyo’s original set of codes (Deyo et al. 1992;
  Quan et al. 2005)
- `charlson_quan2005` and `charlson_quan2011`: Codes and index scoring
  (Quan et al. 2005, 2011)
- `charlson_cdmf2019`: (Glasheen et al. 2019)

## ICD Codes and Index Scores

End users can access the lookup tables for the mapping between ICD-9 and
ICD-10 codes to conditions and the index scoring in `data.frame`s from
the
[`get_charlson_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_charlson_codes.md)
and
[`get_charlson_index_scores()`](http://www.peteredewitt.com/medicalcoder/reference/get_charlson_index_scores.md)
calls respectively.

``` r

str(get_charlson_codes())
## 'data.frame':    7410 obs. of  9 variables:
##  $ icdv             : int  9 9 9 9 9 9 9 9 9 9 ...
##  $ dx               : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ full_code        : chr  "003.1" "007.2" "007.4" "010" ...
##  $ code             : chr  "0031" "0072" "0074" "010" ...
##  $ condition        : chr  "aids" "aids" "aids" "aids" ...
##  $ charlson_cdmf2019: int  1 1 1 1 1 1 1 1 1 1 ...
##  $ charlson_deyo1992: int  0 0 0 0 0 0 0 0 0 0 ...
##  $ charlson_quan2005: int  0 0 0 0 0 0 0 0 0 0 ...
##  $ charlson_quan2011: int  0 0 0 0 0 0 0 0 0 0 ...
str(get_charlson_index_scores())
## 'data.frame':    21 obs. of  6 variables:
##  $ condition_description: chr  "AIDS" "AIDS/HIV" "HIV infection, no AIDS" "Any malignancy" ...
##  $ condition            : chr  "aids" "aidshiv" "hiv" "mal" ...
##  $ charlson_cdmf2019    : int  6 NA 3 2 1 1 1 1 2 1 ...
##  $ charlson_quan2011    : int  NA 4 NA 2 0 1 2 2 1 0 ...
##  $ charlson_quan2005    : int  NA 6 NA 2 1 1 1 1 2 1 ...
##  $ charlson_deyo1992    : int  NA 6 NA 2 1 1 1 1 2 1 ...
```

## Applying Charlson

Example: applying the Quan et al. (2005) variant of the Charlson
comorbidities to the `mdcr` data can be done as follows.

``` r

mdcr_results <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icdv.var = "icdv",
    icd.codes = "code",
    dx.var = "dx",
    flag.method = "current",
    poa = 1,
    primarydx = 0,
    method = "charlson_quan2005"
  )
```

The return object is a `data.frame` with 0/1 integer indicator columns
for the relevant conditions, the id.vars (if applicable), `age_score`
(if age, in years, is supplied), `num_cmrb` the number of comorbidities,
`cmrb_flag` a 0/1 indicator for presence of at least one comorbidity,
and `cci` the Charlson Comorbidity Index.

``` r

str(mdcr_results)
## Classes 'medicalcoder_comorbidities' and 'data.frame':   38262 obs. of  22 variables:
##  $ patid    : int  10000 10002 10005 10006 10008 10010 10014 10015 10017 10018 ...
##  $ aidshiv  : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ mal      : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ cebvd    : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ copd     : int  1 0 0 0 0 0 0 0 0 0 ...
##  $ chf      : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ dem      : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ dmc      : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ dm       : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ hp       : int  0 0 0 0 0 0 0 1 0 0 ...
##  $ mld      : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ msld     : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ mst      : int  0 0 1 0 0 0 0 0 0 0 ...
##  $ mi       : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ pud      : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ pvd      : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ rnd      : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ rhd      : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ num_cmrb : int  1 0 1 0 0 0 0 1 0 0 ...
##  $ cmrb_flag: int  1 0 1 0 0 0 0 1 0 0 ...
##  $ cci      : int  1 0 6 0 0 0 0 2 0 0 ...
##  $ age_score: int  NA NA NA NA NA NA NA NA NA NA ...
##  - attr(*, "method")= chr "charlson_quan2005"
##  - attr(*, "id.vars")= chr "patid"
##  - attr(*, "flag.method")= chr "current"
```

Call [`summary()`](https://rdrr.io/r/base/summary.html) on the return
object for a list of summary objects. These can be used to generate
output tables to the end user’s liking.

``` r

str(summary(mdcr_results))
## List of 3
##  $ conditions   :'data.frame':   22 obs. of  4 variables:
##   ..$ condition_description: chr [1:22] "AIDS/HIV" "Any malignancy" "Cerebrovascular disease" "Chronic pulmonary disease" ...
##   ..$ condition            : chr [1:22] "aidshiv" "mal" "cebvd" "copd" ...
##   ..$ count                : num [1:22] 7 2301 411 3415 684 ...
##   ..$ percent              : num [1:22] 0.0183 6.0138 1.0742 8.9253 1.7877 ...
##  $ age_summary  :'data.frame':   1 obs. of  3 variables:
##   ..$ age_score: chr NA
##   ..$ count    : int 38262
##   ..$ percent  : num 100
##  $ index_summary:'data.frame':   1 obs. of  5 variables:
##   ..$ min   : int 0
##   ..$ q1    : num 0
##   ..$ median: num 0
##   ..$ q3    : num 1
##   ..$ max   : int 12
```

|                                        | Count | Percentage |
|----------------------------------------|-------|------------|
| **Comorbidity**                        |       |            |
| AIDS/HIV                               | 7     | 0.018      |
| Any malignancy                         | 2301  | 6.014      |
| Cerebrovascular disease                | 411   | 1.074      |
| Chronic pulmonary disease              | 3415  | 8.925      |
| Congestive heart failure               | 684   | 1.788      |
| Dementia                               | 13    | 0.034      |
| Diabetes with chronic complications    | 13    | 0.034      |
| Diabetes without chronic complications | 441   | 1.153      |
| Hemiplegia or paraplegia               | 1177  | 3.076      |
| Liver disease, mild                    | 562   | 1.469      |
| Liver disease, moderate to severe      | 206   | 0.538      |
| Metastatic solid tumor                 | 453   | 1.184      |
| Myocardial infarction                  | 10    | 0.026      |
| Peptic ulcer disease                   | 45    | 0.118      |
| Peripheral vascular disease            | 217   | 0.567      |
| Renal disease                          | 877   | 2.292      |
| Rheumatic disease                      | 136   | 0.355      |
| **Total Comorbidities**                |       |            |
| \>= 1                                  | 9789  | 25.584     |
| \>= 2                                  | 1075  | 2.810      |
| \>= 3                                  | 94    | 0.246      |
| \>= 4                                  | 9     | 0.024      |
| \>= 5                                  | 1     | 0.003      |

Counts and percentages of patients in the mdcr example data sets with
the Quan et al. (2005) comorbidities. {.table .table .table-striped
style="font-size: 10px; margin-left: auto; margin-right: auto;"}

## References

Deyo, Richard A, Daniel C Cherkin, and Marcia A Ciol. 1992. “Adapting a
Clinical Comorbidity Index for Use with ICD-9-CM Administrative
Databases.” *Journal of Clinical Epidemiology* 45 (6): 613–19.
https://doi.org/<https://doi.org/10.1016/0895-4356(92)90133-8>.

Glasheen, William P, Tristan Cordier, Rajiv Gumpina, Gil Haugh, Jared
Davis, and Andrew Renda. 2019. “Charlson Comorbidity Index: ICD-9 Update
and ICD-10 Translation.” *American Health & Drug Benefits* 12 (4): 188.
<https://pubmed.ncbi.nlm.nih.gov/31428236/>.

Quan, Hude, Bo Li, Colette M. Couris, et al. 2011. “Updating and
Validating the Charlson Comorbidity Index and Score for Risk Adjustment
in Hospital Discharge Abstracts Using Data from 6 Countries.” *American
Journal of Epidemiology* 173 (6): 676–82.
<https://doi.org/10.1093/aje/kwq433>.

Quan, Hude, Vijaya Sundararajan, Patricia Halfon, et al. 2005. “Coding
Algorithms for Defining Comorbidities in ICD-9-CM and ICD-10
Administrative Data.” *Medical Care* 43 (11): 1130–39.
<https://doi.org/10.1097/01.mlr.0000182534.19832.83>.
