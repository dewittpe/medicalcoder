library(medicalcoder)
source("utilities.R")

capture_warning_and_value <- function(expr) {
  warning <- NULL
  value <-
    withCallingHandlers(
      expr,
      warning = function(w) {
        warning <<- w
        invokeRestart("muffleWarning")
      }
    )
  list(value = value, warning = warning)
}

summary_warning_msg <-
  "This object no longer appears to be a valid medicalcoder_comorbidities object; using the next summary method."

################################################################################
# Modified data-frame results fall back to base summary/print methods.

pccc <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    dx.var = "dx",
    poa = 1L,
    method = "pccc_v3.1"
  )

pccc_modified <- pccc[c("patid", "cmrb_flag")]

pccc_summary <- capture_warning_and_value(summary(pccc_modified))
pccc_print <- capture_warning_and_value(utils::capture.output(print(pccc_modified)))

stopifnot(
  inherits(pccc_modified, "medicalcoder_comorbidities"),
  identical(pccc_summary[["warning"]][["message"]], summary_warning_msg),
  !inherits(pccc_summary[["value"]], "error"),
  length(pccc_print[["value"]]) > 0L
)

################################################################################
# Modified Charlson results with missing summary columns also fall back.

charlson <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    dx.var = "dx",
    poa = 1L,
    primarydx = 0L,
    method = "charlson_quan2011"
  )

charlson_modified <- charlson[c("patid", "cmrb_flag")]
charlson_summary <- capture_warning_and_value(summary(charlson_modified))

stopifnot(
  inherits(charlson_modified, "medicalcoder_comorbidities"),
  identical(charlson_summary[["warning"]][["message"]], summary_warning_msg),
  !inherits(charlson_summary[["value"]], "error")
)

################################################################################
# Modified subcondition results fall back to base summary/print methods.

pccc_subconditions <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    dx.var = "dx",
    poa = 1L,
    method = "pccc_v3.1",
    subconditions = TRUE
  )

pccc_subconditions_modified <- pccc_subconditions
pccc_subconditions_modified[["subconditions"]] <- NULL

pccc_subconditions_summary <-
  capture_warning_and_value(summary(pccc_subconditions_modified))
pccc_subconditions_print <-
  capture_warning_and_value(utils::capture.output(print(pccc_subconditions_modified)))

stopifnot(
  inherits(pccc_subconditions_modified, "medicalcoder_comorbidities_with_subconditions"),
  identical(pccc_subconditions_summary[["warning"]][["message"]], summary_warning_msg),
  !inherits(pccc_subconditions_summary[["value"]], "error"),
  length(pccc_subconditions_print[["value"]]) > 0L
)

################################################################################
# Valid objects continue to use medicalcoder summary methods.

valid_summary <- capture_warning_and_value(summary(pccc))
valid_subconditions_summary <- capture_warning_and_value(summary(pccc_subconditions))

stopifnot(
  is.null(valid_summary[["warning"]]),
  is.data.frame(valid_summary[["value"]]),
  is.null(valid_subconditions_summary[["warning"]]),
  is.data.frame(valid_subconditions_summary[["value"]])
)

################################################################################
#                                 End of File                                  #
################################################################################
