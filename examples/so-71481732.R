# answer for https://stackoverflow.com/q/71481732/1104685
library(reprex)

reprex({

  #' The R package [medicalcoder](https://cran.r-project.org/package=medicalcoder)
  #' will provide the Charlson Comorbidity Index by your id variables
  #' with a single call to `medicalcoder::comorbidities()`.

  library(medicalcoder)
  library(comorbidity)

  packageVersion("medicalcoder")
  packageVersion("comorbidity")

  # generate example data
  set.seed(1)

  x <-
    data.frame(
      pat_id = sample(100:999, size = 300, replace = TRUE),
      code   = comorbidity::sample_diag(n = 300, version = "ICD10_2011")
    )

  rtn <-
    medicalcoder::comorbidities(
      data      = x,
      icd.codes = "code",
      id.vars   = c("pat_id"),
      dx        = 1, # all ICD codes are diagnostic codes
      poa       = 1, # assume all ICD codes are present-on-admission
      primarydx = 0, # assume all ICD codes are secondary diagnoses
      method    = "charlson_quan2005" # <family>_<variant>, support for Charlson, Elixhuaser, PCCC
    )

  #' The return from `medicalcoder::comorbidities()` is a data.frame (or a
  #' tibble if the input was a tibble, or a data.table if the input was a
  #' data.table, and those namespaces are available on the system) with
  #' columns for the `id.vars` (more than one id variable can be passed in,
  #' e.g., a patient id and encounter id), and each of the Charlson
  #' Comorbidities, along with columns `num_cmrb` for the number of
  #' comorbidities, `cmrb_flag` an indicator for at least one comorbidity, and
  #' `cci` the Charlson Comorbidity Index.
  str(rtn)

},
venue = "so"
)


