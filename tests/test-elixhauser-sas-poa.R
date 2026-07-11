source('utilities.R')
library(medicalcoder)

################################################################################
# AHRQ SAS-compatible present-on-admission values
#
# The medicalcoder API expects numeric POA values.  AHRQ SAS POA indicators map
# "Y" and "W" to present-on-admission, "N" and "U" to not-present-on-admission,
# and blank or missing values to missing.
################################################################################

sas_poa_to_numeric <- function(x) {
  ifelse(
    x %in% c("Y", "W"),
    1L,
    ifelse(x %in% c("N", "U"), 0L, NA_integer_)
  )
}

method <- "elixhauser_ahrq2026"
codes <- get_elixhauser_codes()

one_code <- function(cnd) {
  subset(
    codes,
    condition == cnd & !is.na(codes[[method]]) & poaexempt == 0L,
    select = "code",
    drop = TRUE
  )[1]
}

hf_code <- one_code("HF")
aids_code <- one_code("AIDS")
cbvd_poa_code <- one_code("CBVD_POA")
cbvd_sqla_code <- one_code("CBVD_SQLA")

dat <-
  data.frame(
    patid = c(
      "HF_W",
      "HF_U",
      "AIDS_U",
      "CBVD_POA_W",
      "CBVD_POA_U",
      "CBVD_SQLA_W",
      "CBVD_SQLA_W_WITH_CBVD_POA_U",
      "CBVD_SQLA_W_WITH_CBVD_POA_U"
    ),
    code = c(
      hf_code,
      hf_code,
      aids_code,
      cbvd_poa_code,
      cbvd_poa_code,
      cbvd_sqla_code,
      cbvd_sqla_code,
      cbvd_poa_code
    ),
    poa_sas = c("W", "U", "U", "W", "U", "W", "W", "U"),
    stringsAsFactors = FALSE
  )

dat[["poa"]] <- sas_poa_to_numeric(dat[["poa_sas"]])

res <-
  comorbidities(
    data = dat,
    icd.codes = "code",
    id.vars = "patid",
    icdv = 10L,
    dx = 1L,
    poa.var = "poa",
    primarydx = 0L,
    method = method,
    flag.method = "current"
  )

row <- function(patid, column) {
  res[[column]][res[["patid"]] == patid]
}

# "W" is SAS-present and should behave like `poa = 1L`.
stopifnot(row("HF_W", "HF") == 1L)

# "U" is SAS-not-present and should behave like `poa = 0L` for POA-required
# conditions.
stopifnot(row("HF_U", "HF") == 0L)

# POA-neutral conditions continue to flag even when the SAS value maps to 0.
stopifnot(row("AIDS_U", "AIDS") == 1L)

# CBVD_POA with "W" directly flags CBVD; CBVD_POA with "U" does not.
stopifnot(row("CBVD_POA_W", "CBVD_POA") == 1L)
stopifnot(row("CBVD_POA_W", "CBVD") == 1L)
stopifnot(row("CBVD_POA_U", "CBVD_POA") == 0L)
stopifnot(row("CBVD_POA_U", "CBVD") == 0L)

# CBVD sequela flags CBVD when present-on-admission, unless a CBVD_POA code is
# present with a SAS-not-present value ("U"), matching the AHRQ CBVD_NPOA rule.
stopifnot(row("CBVD_SQLA_W", "CBVD_SQLA") == 1L)
stopifnot(row("CBVD_SQLA_W", "CBVD") == 1L)
stopifnot(row("CBVD_SQLA_W_WITH_CBVD_POA_U", "CBVD_SQLA") == 1L)
stopifnot(row("CBVD_SQLA_W_WITH_CBVD_POA_U", "CBVD_POA") == 0L)
stopifnot(row("CBVD_SQLA_W_WITH_CBVD_POA_U", "CBVD") == 0L)

################################################################################
#                                 End of File                                  #
################################################################################
