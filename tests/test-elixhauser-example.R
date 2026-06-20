source('utilities.R')
library(medicalcoder)

################################################################################
# Regression test: selected ICD-10 codes should map to specific Elixhauser
# comorbidities under the Quan (2005) implementation.
################################################################################

example_codes <-
  data.frame(
    patid = c("P1", "P1", "P1", "P2", "P2", "P2", "P3"),
    icdv  = 10L,
    dx    = 1L,
    code  = c("I099",  # CHF
              "I110",  # Hypertensive heart disease with heart failure (supports CHF)
              "I132",  # Hypertensive heart and kidney disease with heart failure
              "E109",  # Diabetes mellitus without complications
              "E1021", # Diabetes with renal complications
              "E6609", # Other obesity
              "N185"   # Chronic kidney disease, stage 5 (renal failure)
    ),
    stringsAsFactors = FALSE
  )

res <- comorbidities(
  data        = example_codes,
  icd.codes   = "code",
  id.vars     = "patid",
  icdv.var    = "icdv",
  dx.var      = "dx",
  method      = "elixhauser_quan2005",
  poa         = 1,
  primarydx   = 0,
  flag.method = "current"
)
conditions <- res[["conditions"]]

# P1: congestive heart failure and HTN_C
stopifnot(isTRUE(conditions[["CHF"]][conditions[["patid"]] == "P1"] == 1L))
stopifnot(isTRUE(conditions[["HTN_C"]][conditions[["patid"]] == "P1"] == 1L))
stopifnot(isTRUE(conditions[["num_cmrb"]][conditions[["patid"]] == "P1"] == 2L))

# P2: diabetes (with and without complications) + obesity - the patient should
# flag both but only have with complications reported.
stopifnot(isTRUE(conditions[["DM"]][conditions[["patid"]] == "P2"]  == 0L))
stopifnot(isTRUE(conditions[["DMCX"]][conditions[["patid"]] == "P2"] == 1L))
stopifnot(isTRUE(conditions[["OBESE"]][conditions[["patid"]] == "P2"] == 1L))
stopifnot(isTRUE(conditions[["num_cmrb"]][conditions[["patid"]] == "P2"] == 2L))

# P3: renal failure only
stopifnot(isTRUE(conditions[["RENLFAIL"]][conditions[["patid"]] == "P3"] == 1L))
stopifnot(isTRUE(conditions[["num_cmrb"]][conditions[["patid"]] == "P3"] == 1L))

################################################################################
#                                 End of File                                  #
################################################################################
