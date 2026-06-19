# Elixhauser Comorbidities

``` r

library(medicalcoder)
packageVersion("medicalcoder")
## [1] '0.8.0'
```

## Introduction

The medicalcoder package implements several variants of the Elixhauser
comorbidity algorithm.

- Based on codes provided by the Agency for Healthcare Research and
  Quality (AHRQ) for fiscal years 2022 through 2026 (Healthcare Research
  and (AHRQ) 2025)
  - `elixhauser_ahrq2022`
  - `elixhauser_ahrq2023`
  - `elixhauser_ahrq2024`
  - `elixhauser_ahrq2025`
  - `elixhauser_ahrq2026`
  - `elixhauser_ahrq_icd10` - All ICD-10 codes ever listed by AHRQ
- Codes from Table 2 of Quan et al. (2005)
  - `elixhauser_elixhauser1988`: (Elixhauser et al. 1998; Quan et al.
    2005)
  - `elixhauser_ahrq_web`: (Quan et al. 2005; Healthcare Cost and
    Utilization Project (HCUP) 2017)
  - `elixhauser_quan2005`: (Quan et al. 2005)

**IMPORTANT NOTE:** Elixhauser 1998 and AHRQ Web used diagnosis-related
group (DRG) codes as part of the methods. The medicalcoder package *does
not* use DRG codes. This is consistent with the way these methods were
implemented in Quan et al. (2005).

## ICD Codes and Index Scores

End users may access three lookup tables relevant to Elixhauser
variants.

``` r

str(get_elixhauser_codes())
## 'data.frame':    10455 obs. of  15 variables:
##  $ icdv                     : int  9 9 9 9 9 9 9 9 9 9 ...
##  $ dx                       : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ full_code                : chr  "042" "070.22" "070.23" "070.32" ...
##  $ code                     : chr  "042" "07022" "07023" "07032" ...
##  $ poaexempt                : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ condition                : chr  "AIDS" "LIVER" "LIVER" "LIVER" ...
##  $ elixhauser_ahrq_web      : int  1 1 1 1 1 1 1 0 0 0 ...
##  $ elixhauser_elixhauser1988: int  1 0 0 1 1 0 1 0 0 0 ...
##  $ elixhauser_quan2005      : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ elixhauser_ahrq2022      : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ elixhauser_ahrq2023      : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ elixhauser_ahrq2024      : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ elixhauser_ahrq2025      : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ elixhauser_ahrq2026      : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ elixhauser_ahrq_icd10    : int  NA NA NA NA NA NA NA NA NA NA ...
str(get_elixhauser_index_scores())
## 'data.frame':    112 obs. of  11 variables:
##  $ condition                : chr  "AIDS" "AIDS" "ALCOHOL" "ALCOHOL" ...
##  $ index                    : chr  "mortality" "readmission" "mortality" "readmission" ...
##  $ elixhauser_ahrq_web      : int  0 19 -1 6 -2 9 0 4 NA NA ...
##  $ elixhauser_elixhauser1988: int  0 19 -1 6 -2 9 0 4 NA NA ...
##  $ elixhauser_quan2005      : int  0 19 -1 6 -2 9 0 4 NA NA ...
##  $ elixhauser_ahrq2022      : int  -4 5 -1 3 -3 5 NA NA -1 2 ...
##  $ elixhauser_ahrq2023      : int  -4 5 -1 3 -3 5 NA NA 0 2 ...
##  $ elixhauser_ahrq2024      : int  -4 5 -1 3 -3 5 NA NA 0 2 ...
##  $ elixhauser_ahrq2025      : int  -4 5 -1 3 -3 5 NA NA 0 2 ...
##  $ elixhauser_ahrq2026      : int  -4 5 -1 3 -3 5 NA NA 0 2 ...
##  $ elixhauser_ahrq_icd10    : int  -4 5 -1 3 -3 5 NA NA 0 2 ...
str(get_elixhauser_poa())
## 'data.frame':    50 obs. of  8 variables:
##  $ condition            : chr  "AIDS" "ALCOHOL" "ANEMDEF" "AUTOIMMUNE" ...
##  $ poa_required         : int  0 0 1 0 1 0 0 0 0 0 ...
##  $ elixhauser_ahrq2022  : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ elixhauser_ahrq2023  : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ elixhauser_ahrq2024  : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ elixhauser_ahrq2025  : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ elixhauser_ahrq2026  : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ elixhauser_ahrq_icd10: int  1 1 1 1 1 1 1 1 1 1 ...
```

- [`get_elixhauser_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_elixhauser_codes.md)
  returns a `data.frame` of the ICD codes mapping to each condition with
  indicators for the inclusion in specific variants.

- [`get_elixhauser_index_scores()`](http://www.peteredewitt.com/medicalcoder/reference/get_elixhauser_index_scores.md)
  returns a `data.frame` with points scored per condition for both
  mortality and readmission indices by variant.

- [`get_elixhauser_poa()`](http://www.peteredewitt.com/medicalcoder/reference/get_elixhauser_poa.md)
  returns a `data.frame` which reports which conditions are required and
  not required to be present-on-admission for the conditions to be
  classified as a comorbidity by variant. For the variants not listed
  the default is as with the Charlson and PCCC methods, the code needs
  to be present-on-admission for the condition to be flagged.

## Applying Elixhauser

The Elixhauser method considers if the diagnostic codes are for primary
or secondary diagnoses. As such, the following call will throw a warning
that the `primarydx.var` or `primarydx` argument was not set and that
all conditions will be assumed to be secondary. To suppress this warning
pass an appropriate value for either argument.

``` r

# will warn because primarydx and primarydx.var are both NULL
mdcr_results0 <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icdv.var = "icdv",
    icd.codes = "code",
    dx.var = "dx",
    flag.method = "current",
    poa = 1,
    method = "elixhauser_ahrq2025"
  )
## Warning: Assuming all codes provided are secondary diagnostic codes.  Define
## `primarydx.var` or `primarydx` if this assumption is incorrect.

# no warning
mdcr_results <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icdv.var = "icdv",
    icd.codes = "code",
    dx.var = "dx",
    flag.method = "current",
    poa = 1,
    method = "elixhauser_ahrq2025",
    primarydx = 0
  )

identical(mdcr_results, mdcr_results0)
## [1] TRUE
```

The return object is a `data.frame` with 0/1 integer indicator columns
for the relevant conditions, the id.vars (if applicable), `num_cmrb`,
the number of comorbidities, `cmrb_flag`, a 0/1 indicator for presence
of at least one comorbidity, and the mortality and readmission index
scores.

``` r

str(mdcr_results)
## Classes 'medicalcoder_comorbidities' and 'data.frame':   38262 obs. of  54 variables:
##  $ patid              : int  10000 10002 10005 10006 10008 10010 10014 10015 10017 10018 ...
##  $ AIDS               : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ ALCOHOL            : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ ALCOHOLLIVER_MLD   : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ ANEMDEF            : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ AUTOIMMUNE         : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ BLDLOSS            : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ CANCER_LEUK        : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ CANCER_LYMPH       : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ CANCER_METS        : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ CANCER_NSITU       : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ CANCER_SOLID       : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ CBVD_POA           : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ CBVD_SQLA          : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ CBVD_SQLAPARALYSIS : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ COAG               : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ DEMENTIA           : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ DEPRESS            : int  0 1 0 0 0 0 0 0 0 1 ...
##  $ DIAB_CX            : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ DIAB_UNCX          : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ DRUG_ABUSE         : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ DRUG_ABUSEPSYCHOSES: int  0 0 0 0 0 0 0 0 0 0 ...
##  $ HF                 : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ HFHTN_CX           : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ HFHTN_CXRENLFL_SEV : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ HTN_CX             : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ HTN_CXRENLFL_SEV   : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ HTN_UNCX           : int  0 0 0 0 0 0 1 0 0 0 ...
##  $ LIVER_MLD          : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ LIVER_MLD_NEURO    : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ LIVER_SEV          : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ LUNG_CHRONIC       : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ NEURO_MOVT         : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ NEURO_OTH          : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ NEURO_OTH_SEIZ     : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ NEURO_SEIZ         : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ OBESE              : int  0 1 0 0 0 0 0 0 0 0 ...
##  $ PARALYSIS          : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ PERIVASC           : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ PSYCHOSES          : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ PULMCIRC           : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ RENLFL_MOD         : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ RENLFL_SEV         : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ THYROID_HYPO       : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ THYROID_OTH        : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ ULCER_PEPTIC       : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ VALVE              : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ VALVE_AUTOIMMUNE   : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ WGHTLOSS           : int  0 0 0 0 0 0 1 0 0 0 ...
##  $ CBVD               : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ num_cmrb           : int  0 2 0 0 0 0 2 0 0 1 ...
##  $ cmrb_flag          : int  0 1 0 0 0 0 1 0 0 1 ...
##  $ mortality_index    : int  0 -15 0 0 0 0 13 0 0 -8 ...
##  $ readmission_index  : int  0 0 0 0 0 0 6 0 0 2 ...
##  - attr(*, "method")= chr "elixhauser_ahrq2025"
##  - attr(*, "id.vars")= chr "patid"
##  - attr(*, "flag.method")= chr "current"
```

Call [`summary()`](https://rdrr.io/r/base/summary.html) to get a list of
summaries which can be used to generate summary tables.

``` r

summary(mdcr_results)
## $conditions
##       condition count      percent
## 1          AIDS     3  0.007840677
## 2       ALCOHOL    11  0.028749151
## 3       ANEMDEF   700  1.829491401
## 4    AUTOIMMUNE   170  0.444305055
## 5       BLDLOSS    33  0.086247452
## 6   CANCER_LEUK   381  0.995766034
## 7  CANCER_LYMPH    76  0.198630495
## 8   CANCER_METS   213  0.556688098
## 9  CANCER_NSITU     0  0.000000000
## 10 CANCER_SOLID   477  1.246667712
## 11         CBVD   117  0.305786420
## 12         COAG   877  2.292091370
## 13     DEMENTIA    35  0.091474570
## 14      DEPRESS   321  0.838952485
## 15      DIAB_CX   123  0.321467775
## 16    DIAB_UNCX   184  0.480894883
## 17   DRUG_ABUSE    77  0.201244054
## 18           HF   246  0.642935550
## 19       HTN_CX   286  0.747477915
## 20     HTN_UNCX   395  1.032355862
## 21    LIVER_MLD   179  0.467827087
## 22    LIVER_SEV   159  0.415555904
## 23 LUNG_CHRONIC  1359  3.551826878
## 24   NEURO_MOVT   139  0.363284721
## 25    NEURO_OTH   948  2.477654069
## 26   NEURO_SEIZ  1490  3.894203126
## 27        OBESE   315  0.823271131
## 28    PARALYSIS   767  2.004599864
## 29     PERIVASC   209  0.546233861
## 30    PSYCHOSES    96  0.250901678
## 31     PULMCIRC   332  0.867701636
## 32   RENLFL_MOD   107  0.279650828
## 33   RENLFL_SEV   247  0.645549109
## 34 THYROID_HYPO   371  0.969630443
## 35  THYROID_OTH    36  0.094088129
## 36 ULCER_PEPTIC    23  0.060111860
## 37        VALVE   572  1.494955831
## 38     WGHTLOSS   616  1.609952433
## 39         >= 1  7869 20.566096911
## 40         >= 2  3186  8.326799435
## 41         >= 3  1135  2.966389629
## 42         >= 4   347  0.906905023
## 43         >= 5   120  0.313627097
## 44         >= 6    25  0.065338979
## 45         >= 7     7  0.018294914
## 46         >= 8     1  0.002613559
## 
## $index_summary
##         index min q1 median q3 max
## 1 readmission  -2  0      0  0  35
## 2   mortality -24  0      0  0  75
```

|                         | Count | Percentage |
|-------------------------|-------|------------|
| **Comorbidity**         |       |            |
| AIDS                    | 3     | 0.008      |
| ALCOHOL                 | 11    | 0.029      |
| ANEMDEF                 | 700   | 1.829      |
| AUTOIMMUNE              | 170   | 0.444      |
| BLDLOSS                 | 33    | 0.086      |
| CANCER_LEUK             | 381   | 0.996      |
| CANCER_LYMPH            | 76    | 0.199      |
| CANCER_METS             | 213   | 0.557      |
| CANCER_NSITU            | 0     | 0.000      |
| CANCER_SOLID            | 477   | 1.247      |
| CBVD                    | 117   | 0.306      |
| COAG                    | 877   | 2.292      |
| DEMENTIA                | 35    | 0.091      |
| DEPRESS                 | 321   | 0.839      |
| DIAB_CX                 | 123   | 0.321      |
| DIAB_UNCX               | 184   | 0.481      |
| DRUG_ABUSE              | 77    | 0.201      |
| HF                      | 246   | 0.643      |
| HTN_CX                  | 286   | 0.747      |
| HTN_UNCX                | 395   | 1.032      |
| LIVER_MLD               | 179   | 0.468      |
| LIVER_SEV               | 159   | 0.416      |
| LUNG_CHRONIC            | 1359  | 3.552      |
| NEURO_MOVT              | 139   | 0.363      |
| NEURO_OTH               | 948   | 2.478      |
| NEURO_SEIZ              | 1490  | 3.894      |
| OBESE                   | 315   | 0.823      |
| PARALYSIS               | 767   | 2.005      |
| PERIVASC                | 209   | 0.546      |
| PSYCHOSES               | 96    | 0.251      |
| PULMCIRC                | 332   | 0.868      |
| RENLFL_MOD              | 107   | 0.280      |
| RENLFL_SEV              | 247   | 0.646      |
| THYROID_HYPO            | 371   | 0.970      |
| THYROID_OTH             | 36    | 0.094      |
| ULCER_PEPTIC            | 23    | 0.060      |
| VALVE                   | 572   | 1.495      |
| WGHTLOSS                | 616   | 1.610      |
| **Total Comorbidities** |       |            |
| \>= 1                   | 7869  | 20.566     |
| \>= 2                   | 3186  | 8.327      |
| \>= 3                   | 1135  | 2.966      |
| \>= 4                   | 347   | 0.907      |
| \>= 5                   | 120   | 0.314      |
| \>= 6                   | 25    | 0.065      |
| \>= 7                   | 7     | 0.018      |
| \>= 8                   | 1     | 0.003      |

Counts and percentages of patients in the mdcr example data sets with
the Elixhauser Quan et al. (2005) comorbidities. {.table .table
.table-striped
style="font-size: 10px; margin-left: auto; margin-right: auto;"}

## References

Elixhauser, Anne, Claudia Steiner, D Robert Harris, and Rosanna M
Coffey. 1998. “Comorbidity Measures for Use with Administrative Data.”
*Medical Care* 36 (1): 8–27.
<https://doi.org/10.1097/00005650-199801000-00004>.

Healthcare Cost and Utilization Project (HCUP). 2017. *Elixhauser
Comorbidity Software for ICD-9-CM*.
[Https://hcup-us.ahrq.gov/toolssoftware/comorbidity/comorbidity.jsp](https://hcup-us.ahrq.gov/toolssoftware/comorbidity/comorbidity.jsp).

Healthcare Research, Agency for, and Quality (AHRQ). 2025. *Elixhauser
Comorbidity Software Refined for ICD-10-CM Healthcare Cost and
Utilization Project (HCUP)*.
<https://hcup-us.ahrq.gov/toolssoftware/comorbidityicd10/comorbidity_icd10.jsp>.

Quan, Hude, Vijaya Sundararajan, Patricia Halfon, et al. 2005. “Coding
Algorithms for Defining Comorbidities in ICD-9-CM and ICD-10
Administrative Data.” *Medical Care* 43 (11): 1130–39.
<https://doi.org/10.1097/01.mlr.0000182534.19832.83>.
