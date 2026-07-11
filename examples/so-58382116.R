# answer for https://stackoverflow.com/q/58382116/1104685
library(reprex)

reprex({

  #' The R package [medicalcoder](https://cran.r-project.org/package=medicalcoder)
  #' will provide the Charlson Comorbidity Index by your id variables
  #' with a single call to `medicalcoder::comorbidities()`.

  library(medicalcoder)
  packageVersion("medicalcoder")

  # generate example data
  df <-
    data.frame(
      "ID" = c("A","A","A","A","B","B","B","C","C","C","C"),
      "ICD10" = c("A41.9","G92","K52.9","N30.00","N20.0","R10.9","Z95.5","E78.5","I63.9","R47.81","Z87.891"),
      "NumEncounters" = rep(1, times = 11)
    )

  # call medicalcoder::comorbidities()
  rtn <-
    medicalcoder::comorbidities(
      data          = df,
      icd.codes     = "ICD10",
      id.vars       = c("ID"),
      icdv          = 10L, # all codes are ICD-10; use icdv.var to specify a column in data for mixed ICD version data.
      dx            = 1L, # all ICD codes are diagnostic codes; use dx.var to specify a column in data for mixed diagnostic and procedure codes
      poa           = 1L, # assume all ICD codes are present-on-admission; use poa.var to specify a column in data for dynamic data
      primarydx     = 0L, # assume all ICD codes are secondary diagnoses; use primarydx.var to specify individual codes are primary/secondary
      method        = "charlson_quan2005", # <family>_<variant>, support for Charlson, Elixhauser, PCCC
      full.codes    = TRUE, # (default) match on full ICD codes (with dots, e.g. E78.5)
      compact.codes = TRUE # (default) match on compact ICD codes (no dots, e.g. E785)
    )

  #' The return from `medicalcoder::comorbidities()` is a data.frame (or a
  #' tibble if the input was a tibble, or a data.table if the input was a
  #' data.table, and those namespaces are available on the system) with
  #' columns for the `id.vars` (more than one id variable can be passed in,
  #' e.g., a patient id and encounter id), and each of the Charlson
  #' Comorbidities, along with columns `num_cmrb` for the number of
  #' comorbidities, `cmrb_flag` an indicator for at least one comorbidity, and
  #' `cci` the Charlson Comorbidity Index.
  rtn

},
venue = "so"
)

