library(medicalcoder)

# Verifies cumulative flagging behavior for Charlson when poa/poa.var is omitted.
# Expected default: first encounter for a condition is NOT flagged (poa defaults
# to 0), but the condition carries forward and is flagged on later encounters
# (poa set to 1 after first occurrence). Explicit poa = 1 should flag all
# encounters.

df <- data.frame(
  patid = c(1L, 1L),
  enc   = c(1L, 2L),
  icdv  = c(10L, 10L),
  dx    = c(1L, 1L),
  code  = c("I252", "I252"),
  stringsAsFactors = FALSE
)

# Baseline: explicit poa = 1 flags the condition under cumulative logic
explicit_poa <- comorbidities(
  data        = df,
  icd.codes   = "code",
  id.vars     = c("patid", "enc"),
  icdv.var    = "icdv",
  dx.var      = "dx",
  method      = "charlson_quan2011",
  flag.method = "cumulative",
  poa         = 1L,
  primarydx   = 0L
)

stopifnot(any(explicit_poa[["cmrb_flag"]]))
stopifnot(
  explicit_poa$cmrb_flag[explicit_poa$enc == 1L] == 1L,
  explicit_poa$cmrb_flag[explicit_poa$enc == 2L] == 1L
)

# Without specifying poa/poa.var, encounter 1 should remain unflagged and
# encounter 2 should be flagged.
default_poa <- comorbidities(
  data        = df,
  icd.codes   = "code",
  id.vars     = c("patid", "enc"),
  icdv.var    = "icdv",
  dx.var      = "dx",
  method      = "charlson_quan2011",
  flag.method = "cumulative",
  primarydx   = 0L
)

stopifnot(
  default_poa$cmrb_flag[default_poa$enc == 1L] == 0L,
  default_poa$cmrb_flag[default_poa$enc == 2L] == 1L
)
