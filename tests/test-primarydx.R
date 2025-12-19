################################################################################
# Verify primary diagnoses are excluded from comorbidity flagging
library(medicalcoder)

df <- data.frame(
  patid = c(1L, 2L),
  icdv  = c(10L, 10L),
  dx    = c(1L, 1L),
  code  = c("I252", "I252"), # MI code that should flag Charlson when counted
  primarydx = c(0L, 1L),
  stringsAsFactors = FALSE
)

res0 <- comorbidities(
  data      = df,
  id.vars   = "patid",
  icdv.var  = "icdv",
  dx.var    = "dx",
  icd.codes = "code",
  method    = "charlson_quan2011",
  poa       = 1L,
  primarydx = 0L
)

res1 <- comorbidities(
  data      = df,
  id.vars   = "patid",
  icdv.var  = "icdv",
  dx.var    = "dx",
  icd.codes = "code",
  method    = "charlson_quan2011",
  poa       = 1L,
  primarydx = 1L
)

resv <- comorbidities(
  data      = df,
  id.vars   = "patid",
  icdv.var  = "icdv",
  dx.var    = "dx",
  icd.codes = "code",
  method    = "charlson_quan2011",
  poa       = 1L,
  primarydx.var = "primarydx"
)

stopifnot(identical(res0[["cmrb_flag"]], c(1L, 1L)))
stopifnot(identical(res1[["cmrb_flag"]], c(0L, 0L)))
stopifnot(identical(resv[["cmrb_flag"]], c(1L, 0L)))

################################################################################
#                                 End of File                                  #
################################################################################
