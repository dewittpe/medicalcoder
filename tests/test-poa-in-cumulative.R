library(medicalcoder)

capture_warning_and_value <- function(expr) {
  warnings <- character(0)
  value <-
    withCallingHandlers(
      expr,
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    )
  list(value = value, warnings = warnings)
}

# Verifies cumulative flagging behavior for Charlson when poa/poa.var is omitted.
# Expected default: first encounter for a condition is NOT flagged (poa defaults
# to `0L`), but the condition carries forward and is flagged on later encounters
# (`poa` set to `1L` after first occurrence). Explicit `poa = 1L` should flag all
# encounters.

df <- data.frame(
  patid = c(1L, 1L),
  enc   = c(1L, 2L),
  icdv  = c(10L, 10L),
  dx    = c(1L, 1L),
  code  = c("I252", "I252"),
  stringsAsFactors = FALSE
)

# Baseline: explicit `poa = 1L` flags the condition under cumulative logic
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

################################################################################
# Encounter order validation for cumulative flagging.

na_enc <- df
na_enc[["enc"]][1L] <- NA_integer_

na_enc_error <-
  tryCatch(
    comorbidities(
      data        = na_enc,
      icd.codes   = "code",
      id.vars     = c("patid", "enc"),
      icdv.var    = "icdv",
      dx.var      = "dx",
      method      = "charlson_quan2011",
      flag.method = "cumulative",
      poa         = 1L,
      primarydx   = 0L
    ),
    error = function(e) e
  )

factor_enc <- df
factor_enc[["enc"]] <- factor(c("b", "a"))

factor_enc_error <-
  tryCatch(
    comorbidities(
      data        = factor_enc,
      icd.codes   = "code",
      id.vars     = c("patid", "enc"),
      icdv.var    = "icdv",
      dx.var      = "dx",
      method      = "charlson_quan2011",
      flag.method = "cumulative",
      poa         = 1L,
      primarydx   = 0L
    ),
    error = function(e) e
  )

character_enc <- df
character_enc[["enc"]] <- c("visit_01", "visit_02")

character_enc_result <-
  capture_warning_and_value(
    comorbidities(
      data        = character_enc,
      icd.codes   = "code",
      id.vars     = c("patid", "enc"),
      icdv.var    = "icdv",
      dx.var      = "dx",
      method      = "charlson_quan2011",
      flag.method = "cumulative",
      poa         = 1L,
      primarydx   = 0L
    )
  )

date_enc <- df
date_enc[["enc"]] <- as.Date(c("2024-01-01", "2024-01-02"))

date_enc_result <-
  comorbidities(
    data        = date_enc,
    icd.codes   = "code",
    id.vars     = c("patid", "enc"),
    icdv.var    = "icdv",
    dx.var      = "dx",
    method      = "charlson_quan2011",
    flag.method = "cumulative",
    poa         = 1L,
    primarydx   = 0L
  )

posix_enc <- df
posix_enc[["enc"]] <- as.POSIXct(c("2024-01-01 00:00:00", "2024-01-02 00:00:00"), tz = "UTC")

posix_enc_result <-
  comorbidities(
    data        = posix_enc,
    icd.codes   = "code",
    id.vars     = c("patid", "enc"),
    icdv.var    = "icdv",
    dx.var      = "dx",
    method      = "charlson_quan2011",
    flag.method = "cumulative",
    poa         = 1L,
    primarydx   = 0L
  )

stopifnot(
  inherits(na_enc_error, "error"),
  na_enc_error[["message"]] == "When using `flag.method = 'cumulative'`, the encounter order column 'enc' must not contain missing values.",
  inherits(factor_enc_error, "error"),
  factor_enc_error[["message"]] == "When using `flag.method = 'cumulative'`, the encounter order column 'enc' must not be a factor. Use an integer sequence, Date, POSIXt, or character column with the intended sort order.",
  identical(
    character_enc_result[["warnings"]],
    "When using `flag.method = 'cumulative'`, the encounter order column 'enc' is character and will be sorted lexicographically. Use an integer sequence, Date, or POSIXt column when possible."
  ),
  all(character_enc_result[["value"]][["cmrb_flag"]] == 1L),
  all(date_enc_result[["cmrb_flag"]] == 1L),
  all(posix_enc_result[["cmrb_flag"]] == 1L)
)
