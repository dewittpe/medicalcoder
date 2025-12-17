library(medicalcoder)

# Verifies that cumulative flagging does not silently drop Charlson flags when
# the caller omits an explicit poa/poa.var. With flag.method = "cumulative",
# the default poa fallback currently sets poa = 0 and later filters to poa == 1,
# which zeroes out all conditions. This test compares the explicit-poa path to
# the implicit default to ensure cumulative logic retains flags without forcing
# users to specify poa manually.

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

# Without specifying poa/poa.var, cumulative should still flag the condition.
# If this fails, the default poa handling is discarding rows needed for Charlson.
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

if (!any(default_poa[["cmrb_flag"]])) {
  stop("Cumulative + missing poa/poa.var dropped all Charlson flags; expected behavior to match explicit poa = 1.")
}
