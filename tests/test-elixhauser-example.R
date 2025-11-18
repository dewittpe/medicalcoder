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

# P1: congestive heart failure and HTN_C
stopifnot(res[["CHF"]][res[["patid"]] == "P1"] == 1L)
stopifnot(res[["HTN_C"]][res[["patid"]] == "P1"] == 1L)
stopifnot(res[["num_cmrb"]][res[["patid"]] == "P1"] == 2L)

# P2: diabetes (with and without complications) + obesity - the patient should
# flag both but only have with complications reported.
stopifnot(res[["DM"]][res[["patid"]] == "P2"]  == 0L)
stopifnot(res[["DMCX"]][res[["patid"]] == "P2"] == 1L)
stopifnot(res[["OBESE"]][res[["patid"]] == "P2"] == 1L)
stopifnot(res[["num_cmrb"]][res[["patid"]] == "P2"] == 2L)

# P3: renal failure only
stopifnot(res[["RENLFAIL"]][res[["patid"]] == "P3"] == 1L)
stopifnot(res[["num_cmrb"]][res[["patid"]] == "P3"] == 1L)

################################################################################
#                                 End of File                                  #
################################################################################
