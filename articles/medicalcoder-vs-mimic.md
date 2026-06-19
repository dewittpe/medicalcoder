# medicalcoder vs mimic

## Introduction

The purpose of this article is to compare the results for the Charlson
comorbidity flags returned by
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
vs the SQL code provided by Johnson et al. (2018).

``` r

library(medicalcoder)
```

## MIMIC SQL

SQL code for applying a Charlson comorbidity algorithm to the MIMIC-IV
data is available from MIT Laboratory for Computational Physiology
(MIT_LCP) on GitHub. The code is expected to run on Google Big Query on
the MIMIC-IV data. We make a few small modifications to the code so we
can evaluate the SQL locally via RSQLite and on a local data set.

The SQL file used here is vendored from [`mimic-code` commit
`278df75ec30991ff3a6f5ceb6d2221635a085e9f`](https://raw.githubusercontent.com/MIT-LCP/mimic-code/278df75ec30991ff3a6f5ceb6d2221635a085e9f/mimic-iv/concepts/comorbidity/charlson.sql)
so this article does not depend on network access during rendering.

``` r

mimic_charson_query <-
  scan(
    file = system.file(
      "sql", "mimic-iv-charlson-278df75.sql",
      package = "medicalcoder",
      mustWork = TRUE
    ),
    what = character(),
    sep = "\n"
  )

# modify the query to work in SQLite
mimic_charson_query <-
  gsub(pattern = "physionet-data.mimiciv_hosp.admissions",
       replacement = "admissions",
       x = mimic_charson_query,
       fixed = TRUE)
mimic_charson_query <-
  gsub(pattern = "physionet-data.mimiciv_hosp.diagnoses_icd",
       replacement = "diagnoses",
       x = mimic_charson_query,
       fixed = TRUE)
mimic_charson_query <-
  gsub(pattern = "physionet-data.mimiciv_derived.age",
       replacement = "ages",
       x = mimic_charson_query,
       fixed = TRUE)
mimic_charson_query <-
  gsub(pattern = "GREATEST",
       replacement = "MAX",
       x = mimic_charson_query,
       fixed = TRUE)

mimic_charson_query <- paste(mimic_charson_query, collapse = "\n")
```

``` r

library(medicalcoder)
library(data.table)
## 
## Attaching package: 'data.table'
## The following object is masked from 'package:base':
## 
##     %notin%
mdcr_for_mimic <- data.table::copy(mdcr)
setDT(mdcr_for_mimic)

# create a hospital admission id  (one admission per patient id in mdcr)
setnames(
  mdcr_for_mimic,
  old = c("patid", "code", "icdv"),
  new = c("subject_id", "icd_code", "icd_version")
)

mdcr_for_mimic[, hadm_id := paste0(subject_id, "e1")]
mdcr_for_mimic[, seq_num := 1L:.N, by = .(subject_id, hadm_id)]
mdcr_for_mimic[, age := as.integer(substr(as.character(subject_id), 1L, 2L))]
```

``` r

library(odbc)
library(DBI)
library(RSQLite)

con <- dbConnect(drv = RSQLite::SQLite(), dbname = ":memory:")

# add data to the data base
dbWriteTable(conn = con, name = "diagnoses",  value = mdcr_for_mimic[dx == 1L])
dbWriteTable(conn = con, name = "admissions", value = mdcr_for_mimic[, unique(.SD), .SDcols = c("subject_id", "hadm_id")])
dbWriteTable(conn = con, name = "ages",       value = mdcr_for_mimic[, unique(.SD), .SDcols = c("hadm_id", "age")])

# get the charlson results via MIMIC-IV
mimic_charlson_results <- dbGetQuery(con, mimic_charson_query)

# close DB connection
dbDisconnect(conn = con)

setDT(mimic_charlson_results)
```

``` r

medicalcoder_charlson_results <-
  comorbidities(
    data = mdcr_for_mimic,
    id.vars = c("subject_id", "hadm_id"),
    icd.codes = "icd_code",
    icdv.var = "icd_version",
    dx.var = "dx",
    age.var = "age",
    method = "charlson_quan2005",
    full.codes = FALSE,
    flag.method = "current",
    poa = 1L,
    primarydx = 0L
  )
```

``` r

delta <-
  merge(
    x = medicalcoder_charlson_results,
    y = mimic_charlson_results,
    all = TRUE,
    by = c("subject_id", "hadm_id")
  )
```

``` r

uniqueN(mdcr_for_mimic$hadm_id)
## [1] 38262
nrow(mimic_charlson_results)
## [1] 38262
nrow(medicalcoder_charlson_results)
## [1] 38262
```

Conditions with multiple severity levels, and the metastatic cancer
flags differ between the two methods.

``` r

dcolumns <- fread(text = "
medicalcoder | mimic
aidshiv      | aids
mal          | malignant_cancer
cebvd        | cerebrovascular_disease
copd         | chronic_pulmonary_disease
chf          | congestive_heart_failure
dem          | dementia
dmc          | diabetes_with_cc
dm           | diabetes_without_cc
hp           | paraplegia
mld          | mild_liver_disease
msld         | severe_liver_disease
mi           | myocardial_infarct
pud          | peptic_ulcer_disease
pvd          | peripheral_vascular_disease
rnd          | renal_disease
rhd          | rheumatic_disease
age_score.x  | age_score.y
cci          | charlson_comorbidity_index
")
```

``` r

for (i in seq_len(nrow(dcolumns))) {
  x <- dcolumns[["medicalcoder"]][i]
  y <- dcolumns[["mimic"]][i]
  e <- base::substitute(identical(delta[[X]], delta[[Y]]), list(X = x, Y = y))
  print(e)
  r <- eval(e)
  print(r)
  #if (r) {
  #  delta[[x]] <- NULL
  #  delta[[y]] <- NULL
  #}
}
## identical(delta[["aidshiv"]], delta[["aids"]])
## [1] TRUE
## identical(delta[["mal"]], delta[["malignant_cancer"]])
## [1] FALSE
## identical(delta[["cebvd"]], delta[["cerebrovascular_disease"]])
## [1] TRUE
## identical(delta[["copd"]], delta[["chronic_pulmonary_disease"]])
## [1] TRUE
## identical(delta[["chf"]], delta[["congestive_heart_failure"]])
## [1] TRUE
## identical(delta[["dem"]], delta[["dementia"]])
## [1] TRUE
## identical(delta[["dmc"]], delta[["diabetes_with_cc"]])
## [1] TRUE
## identical(delta[["dm"]], delta[["diabetes_without_cc"]])
## [1] FALSE
## identical(delta[["hp"]], delta[["paraplegia"]])
## [1] TRUE
## identical(delta[["mld"]], delta[["mild_liver_disease"]])
## [1] FALSE
## identical(delta[["msld"]], delta[["severe_liver_disease"]])
## [1] TRUE
## identical(delta[["mi"]], delta[["myocardial_infarct"]])
## [1] TRUE
## identical(delta[["pud"]], delta[["peptic_ulcer_disease"]])
## [1] TRUE
## identical(delta[["pvd"]], delta[["peripheral_vascular_disease"]])
## [1] TRUE
## identical(delta[["rnd"]], delta[["renal_disease"]])
## [1] TRUE
## identical(delta[["rhd"]], delta[["rheumatic_disease"]])
## [1] TRUE
## identical(delta[["age_score.x"]], delta[["age_score.y"]])
## [1] TRUE
## identical(delta[["cci"]], delta[["charlson_comorbidity_index"]])
## [1] FALSE
```

There are three comorbidities where there are different levels of
severity.
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
will set the less severe condition indicator to 0 when the more severe
condition is flagged. Both methods only consider the more severe case in
the index scoring.

Diabetes -
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
sets the flag for diabetes without complication to 0 when diabetes with
complication is present. MIMIC code retains the non-complex case.

``` r

delta[dm == 1L & dmc == 1L, .N == 0L] # medicalcoder
## [1] TRUE
delta[diabetes_without_cc == 0L & diabetes_with_cc == 0L, .N > 0L] # MIMIC
## [1] TRUE

delta[diabetes_without_cc == 0L & diabetes_with_cc == 0L, .N > 0L & all(dm == 0L) & all(dmc == 0L)]
## [1] TRUE
delta[diabetes_without_cc == 1L & diabetes_with_cc == 0L, .N > 0L & all(dm == 1L) & all(dmc == 0L)]
## [1] TRUE
delta[diabetes_without_cc == 0L & diabetes_with_cc == 1L, .N > 0L &                all(dmc == 1L)]
## [1] TRUE
delta[diabetes_without_cc == 1L & diabetes_with_cc == 1L, .N > 0L &                all(dmc == 1L)]
## [1] TRUE

delta[dm == 0L & dmc == 0L, .N > 0L & all(diabetes_without_cc == 0L) & all(diabetes_with_cc == 0L)]
## [1] TRUE
delta[dm == 1L & dmc == 0L, .N > 0L & all(diabetes_without_cc == 1L) & all(diabetes_with_cc == 0L)]
## [1] TRUE
delta[dm == 0L & dmc == 1L, .N > 0L &                                 all(diabetes_with_cc == 1L)]
## [1] TRUE
delta[dm == 1L & dmc == 1L, .N == 0L]
## [1] TRUE

delta[, dm := NULL]
delta[, dmc := NULL]
delta[, diabetes_with_cc := NULL]
delta[, diabetes_without_cc := NULL]
```

Cancer -
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
sets malignant cancer (mal) to 0 when metastatic solid tumor (mst) is
present. MIMIC retains both flags.

``` r

delta[mal == 1L & mst == 1L, .N == 0L] # medicalcoder
## [1] TRUE
delta[malignant_cancer == 1L & metastatic_solid_tumor == 1L, .N > 0L] # MIMIC
## [1] TRUE

delta[malignant_cancer == 0L & metastatic_solid_tumor == 0L, .N > 0L & all(mal == 0L) & all(mst == 0L)]
## [1] FALSE
delta[malignant_cancer == 1L & metastatic_solid_tumor == 0L, .N > 0L & all(mal == 1L) & all(mst == 0L)]
## [1] TRUE
delta[malignant_cancer == 0L & metastatic_solid_tumor == 1L, .N > 0L &                 all(mst == 1L)]
## [1] TRUE
delta[malignant_cancer == 1L & metastatic_solid_tumor == 1L, .N > 0L &                 all(mst == 1L)]
## [1] TRUE

delta[mal == 0L & mst == 0L, .N > 0L & all(malignant_cancer == 0L) & all(metastatic_solid_tumor == 0L)]
## [1] TRUE
delta[mal == 1L & mst == 0L, .N > 0L & all(malignant_cancer == 1L) & all(metastatic_solid_tumor == 0L)]
## [1] TRUE
delta[mal == 0L & mst == 1L, .N > 0L &                               all(metastatic_solid_tumor == 1L)]
## [1] FALSE
delta[mal == 1L & mst == 1L, .N == 0L]
## [1] TRUE
```

Additionally, ICD-10 codes from CMS of the form C7A.x are not mapped by
the MIMIC codes to metastatic_solid_tumor, but medicalcoder does map
these codes to that comorbidity.

``` r

subset(
  merge(
    x = mdcr_for_mimic,
    y = subset(delta, mst == 1 & metastatic_solid_tumor == 0, select = c("subject_id", "hadm_id")),
    all = FALSE,
    by = c("subject_id", "hadm_id")
  ),
  grepl("^C7[A-Z]", icd_code)
)
## Key: <subject_id, hadm_id>
##    subject_id hadm_id icd_version icd_code    dx seq_num   age
##         <int>  <char>       <int>   <char> <int>   <int> <int>
## 1:      25628 25628e1          10   C7A098     1      10    25
## 2:      90045 90045e1          10     C7A8     1       1    90
## 3:      90045 90045e1          10     C7B8     1       2    90
## 4:      99058 99058e1          10     C7A8     1       2    99
subset(medicalcoder::get_icd_codes(with.descriptions = TRUE),
  full_code %in% c("C7A.098", "C7A.8", "C7B.8"))
##        icdv dx full_code   code src known_start known_end assignable_start
## 148812   10  1   C7A.098 C7A098 cms        2014      2026             2014
## 148814   10  1     C7A.8   C7A8 cms        2014      2026             2014
## 148824   10  1     C7B.8   C7B8 cms        2014      2026             2014
##        assignable_end                                      desc desc_start
## 148812           2026 Malignant carcinoid tumors of other sites       2014
## 148814           2026     Other malignant neuroendocrine tumors       2014
## 148824           2026     Other secondary neuroendocrine tumors       2014
##        desc_end
## 148812     2026
## 148814     2026
## 148824     2026
```

``` r

delta[, mal := NULL]
delta[, mst := NULL]
delta[, malignant_cancer := NULL]
delta[, metastatic_solid_tumor := NULL]
```

Liver disease -
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
sets the flag for mild liver disease (mld) to 0 when moderate/severe
liver disease (msld) is flagged. MIMIC retains both flags.

``` r

delta[mld == 1L & msld == 1L, .N == 0L] # medicalcoder
## [1] TRUE
delta[mild_liver_disease == 1L & severe_liver_disease == 1L, .N > 0L] # MIMIC
## [1] TRUE

delta[mild_liver_disease == 0L & severe_liver_disease == 0L, .N > 0L & all(mld == 0L) & all(msld == 0L)]
## [1] TRUE
delta[mild_liver_disease == 1L & severe_liver_disease == 0L, .N > 0L & all(mld == 1L) & all(msld == 0L)]
## [1] TRUE
delta[mild_liver_disease == 0L & severe_liver_disease == 1L, .N > 0L &                 all(msld == 1L)]
## [1] TRUE
delta[mild_liver_disease == 1L & severe_liver_disease == 1L, .N > 0L &                 all(msld == 1L)]
## [1] TRUE

delta[mld == 0L & msld == 0L, .N > 0L & all(mild_liver_disease == 0L) & all(severe_liver_disease == 0L)]
## [1] TRUE
delta[mld == 1L & msld == 0L, .N > 0L & all(mild_liver_disease == 1L) & all(severe_liver_disease == 0L)]
## [1] TRUE
delta[mld == 0L & msld == 1L, .N > 0L &                                all(severe_liver_disease == 1L)]
## [1] TRUE
delta[mld == 1L & msld == 1L, .N == 0L]
## [1] TRUE

delta[, mld := NULL]
delta[, msld := NULL]
delta[, mild_liver_disease := NULL]
delta[, severe_liver_disease := NULL]
```

All that is left in the `delta` `data.frame` are the id.vars and the
`num_cmrb`, and `cmrb_flag`. These columns are from
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
and report the number of comorbidities flagged and indicator for any
comorbidity.

``` r

str(delta)
## Classes 'medicalcoder_comorbidities', 'data.table' and 'data.frame': 38262 obs. of  30 variables:
##  $ subject_id                 : int  10000 10002 10005 10006 10008 10010 10014 10015 10017 10018 ...
##  $ hadm_id                    : chr  "10000e1" "10002e1" "10005e1" "10006e1" ...
##  $ aidshiv                    : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ cebvd                      : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ copd                       : int  1 0 0 0 0 0 0 0 0 0 ...
##  $ chf                        : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ dem                        : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ hp                         : int  0 0 0 0 0 0 0 1 0 0 ...
##  $ mi                         : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ pud                        : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ pvd                        : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ rnd                        : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ rhd                        : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ num_cmrb                   : int  1 0 1 0 0 0 0 1 0 0 ...
##  $ cmrb_flag                  : int  1 0 1 0 0 0 0 1 0 0 ...
##  $ cci                        : int  1 0 6 0 0 0 0 2 0 0 ...
##  $ age_score.x                : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ age_score.y                : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ myocardial_infarct         : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ congestive_heart_failure   : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ peripheral_vascular_disease: int  0 0 0 0 0 0 0 0 0 0 ...
##  $ cerebrovascular_disease    : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ dementia                   : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ chronic_pulmonary_disease  : int  1 0 0 0 0 0 0 0 0 0 ...
##  $ rheumatic_disease          : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ peptic_ulcer_disease       : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ paraplegia                 : int  0 0 0 0 0 0 0 1 0 0 ...
##  $ renal_disease              : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ aids                       : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ charlson_comorbidity_index : int  1 0 6 0 0 0 0 2 0 0 ...
##  - attr(*, ".internal.selfref")=<pointer: 0x55aaa36a7ee0> 
##  - attr(*, "sorted")= chr [1:2] "subject_id" "hadm_id"
##  - attr(*, "index")= int(0)
```

## References

Johnson, Alistair E W, David J Stone, Leo A Celi, and Tom J Pollard.
2018. “The MIMIC Code Repository: Enabling Reproducibility in Critical
Care Research.” *Journal of the American Medical Informatics
Association* 25 (1): 32–39.
