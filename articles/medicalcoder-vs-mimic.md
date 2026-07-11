# \_medicalcoder\_ vs MIMIC

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
can evaluate the SQL locally via RSQLite and on a local dataset.

The SQL file used here is vendored from [`mimic-code` commit
`278df75ec30991ff3a6f5ceb6d2221635a085e9f`](https://raw.githubusercontent.com/MIT-LCP/mimic-code/278df75ec30991ff3a6f5ceb6d2221635a085e9f/mimic-iv/concepts/comorbidity/charlson.sql)
so this article does not depend on network access during rendering.

The manuscript supplement uses the same commit as the published
comparator and then harmonizes output conventions before assessing
agreement. The SQL relies on string comparisons in the source query,
whereas *medicalcoder* maps input codes to known ICD codes through
method-specific lookup tables. That precomputed map is what allows the
same
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
interface to support full and compact codes, mixed ICD versions, and
multiple comorbidity families.

``` r

mimic_charlson_query <-
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
# replace Google Big Query table names with table names used in
# the local RSQLite in-memory database.  Three table names need to be
# changed and one function call: GBQ GREATEST needs to be replaced by MAX
prs <-
  c(
    "physionet-data.mimiciv_hosp.admissions" = "admissions",
    "physionet-data.mimiciv_hosp.diagnoses_icd" = "diagnoses",
    "physionet-data.mimiciv_derived.age" = "ages",
    "GREATEST" = "MAX"
  )
for(i in seq_len(length(prs))) {
  mimic_charlson_query <-
    gsub(
      pattern     = names(prs)[i],
      replacement = prs[i],
      x           = mimic_charlson_query,
      fixed       = TRUE
    )
}

mimic_charlson_query <- paste(mimic_charlson_query, collapse = "\n")
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

# add data to the database
dbWriteTable(
  conn  = con,
  name  = "diagnoses",
  value = mdcr_for_mimic[dx == 1L]
)

dbWriteTable(
  conn = con,
  name = "admissions",
  value = mdcr_for_mimic[, unique(.SD), .SDcols = c("subject_id", "hadm_id")]
)

dbWriteTable(
  conn = con,
  name = "ages",
  value = mdcr_for_mimic[, unique(.SD), .SDcols = c("hadm_id", "age")]
)

# get the charlson results via MIMIC-IV
mimic_charlson_results <- dbGetQuery(con, mimic_charlson_query)

# close DB connection
dbDisconnect(conn = con)

setDT(mimic_charlson_results)
```

To get the same results as the MIMIC-IV Code form
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
use `method = charlson_mimicivcode`.

``` r

medicalcoder_charlson_results <-
  comorbidities(
    data = mdcr_for_mimic,
    id.vars = c("subject_id", "hadm_id"),
    icd.codes = "icd_code",
    icdv.var = "icd_version",
    dx.var = "dx",
    age.var = "age",
    method = "charlson_mimicivcode",
    full.codes = FALSE,
    flag.method = "current",
    poa = 1L,
    primarydx = 0L
  )
```

Let’s compare the results:

``` r

delta <-
  merge(
    x = medicalcoder_charlson_results,
    y = mimic_charlson_results,
    all = TRUE,
    by = c("subject_id", "hadm_id")
  )
```

Conditions with multiple severity levels differ between the two methods.

``` r

dcolumns <- fread(text = "
medicalcoder | mimic
aidshiv      | aids
cebvd        | cerebrovascular_disease
copd         | chronic_pulmonary_disease
chf          | congestive_heart_failure
dem          | dementia
hp           | paraplegia
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
  if (r) {
    delta[[x]] <- NULL
    delta[[y]] <- NULL
  }
}
## identical(delta[["aidshiv"]], delta[["aids"]])
## [1] TRUE
## identical(delta[["cebvd"]], delta[["cerebrovascular_disease"]])
## [1] TRUE
## identical(delta[["copd"]], delta[["chronic_pulmonary_disease"]])
## [1] TRUE
## identical(delta[["chf"]], delta[["congestive_heart_failure"]])
## [1] TRUE
## identical(delta[["dem"]], delta[["dementia"]])
## [1] TRUE
## identical(delta[["hp"]], delta[["paraplegia"]])
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
## [1] TRUE
```

There are three comorbidities where there are different levels of
severity.
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
will set the less severe condition indicator to 0 when the more severe
condition is flagged. Both methods only consider the more severe case in
the index scoring.

``` r

# medicalcoder | mimic
# dmc          | diabetes_with_cc
# dm           | diabetes_without_cc
# mld          | mild_liver_disease
# msld         | severe_liver_disease
# mal          | malignant_cancer
# mst          | metastatic_solid_tumor
str(delta)
## Classes 'medicalcoder_comorbidities', 'data.table' and 'data.frame': 38262 obs. of  16 variables:
##  $ subject_id            : int  10000 10002 10005 10006 10008 10010 10014 10015 10017 10018 ...
##  $ hadm_id               : chr  "10000e1" "10002e1" "10005e1" "10006e1" ...
##  $ mal                   : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ dmc                   : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ dm                    : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ mld                   : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ msld                  : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ mst                   : int  0 0 1 0 0 0 0 0 0 0 ...
##  $ num_cmrb              : int  1 0 1 0 0 0 0 1 0 0 ...
##  $ cmrb_flag             : int  1 0 1 0 0 0 0 1 0 0 ...
##  $ mild_liver_disease    : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ diabetes_without_cc   : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ diabetes_with_cc      : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ malignant_cancer      : int  0 0 1 0 0 0 0 0 0 0 ...
##  $ severe_liver_disease  : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ metastatic_solid_tumor: int  0 0 1 0 0 0 0 0 0 0 ...
##  - attr(*, ".internal.selfref")=<pointer: 0x55931b845ee0> 
##  - attr(*, "sorted")= chr [1:2] "subject_id" "hadm_id"
```

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
## [1] TRUE
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
## [1] TRUE
delta[mal == 1L & mst == 1L, .N == 0L]
## [1] TRUE

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
## Classes 'medicalcoder_comorbidities', 'data.table' and 'data.frame': 38262 obs. of  4 variables:
##  $ subject_id: int  10000 10002 10005 10006 10008 10010 10014 10015 10017 10018 ...
##  $ hadm_id   : chr  "10000e1" "10002e1" "10005e1" "10006e1" ...
##  $ num_cmrb  : int  1 0 1 0 0 0 0 1 0 0 ...
##  $ cmrb_flag : int  1 0 1 0 0 0 0 1 0 0 ...
##  - attr(*, ".internal.selfref")=<pointer: 0x55931b845ee0> 
##  - attr(*, "sorted")= chr [1:2] "subject_id" "hadm_id"
##  - attr(*, "index")= int(0)
```

After accounting for naming conventions and severity-suppression
conventions, the remaining columns are *medicalcoder*-specific
summaries.

## References

Johnson, Alistair E W, David J Stone, Leo A Celi, and Tom J Pollard.
2018. “The MIMIC Code Repository: Enabling Reproducibility in Critical
Care Research.” *Journal of the American Medical Informatics
Association* 25 (1): 32–39.
