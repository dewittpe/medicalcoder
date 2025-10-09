library(medicalcoder)

################################################################################
# Regression test: selected ICD-10 codes should map to specific Elixhauser
# comorbidities under the Quan (2005) implementation. The codes were drawn from
# the internal lookup table (get_elixhauser_codes()).
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

res_df <- as.data.frame(res[, c("patid", "CHF", "DM", "DMCX", "OBESE", "RENLFAIL", "num_cmrb")])

# P1: congestive heart failure only
stopifnot(res_df[["CHF"]][res_df[["patid"]] == "P1"] == 1L)
stopifnot(all(res_df[["CHF"]][res_df[["patid"]] != "P1"] == 0L))

# P2: diabetes (with and without complications) + obesity
stopifnot(res_df[["DM"]][res_df[["patid"]] == "P2"]  == 1L)
stopifnot(res_df[["DMCX"]][res_df[["patid"]] == "P2"] == 1L)
stopifnot(res_df[["OBESE"]][res_df[["patid"]] == "P2"] == 1L)

# P3: renal failure only
stopifnot(res_df[["RENLFAIL"]][res_df[["patid"]] == "P3"] == 1L)

# Overall comorbidity counts match the manual expectation
stopifnot(res_df[["num_cmrb"]][res_df[["patid"]] == "P1"] == 1L)
stopifnot(res_df[["num_cmrb"]][res_df[["patid"]] == "P2"] == 3L)
stopifnot(res_df[["num_cmrb"]][res_df[["patid"]] == "P3"] == 1L)

################################################################################
#                                 End of File                                  #
################################################################################
