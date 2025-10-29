source('utilities.R')
################################################################################
# Tests for summarizing PCCC comorbidities with subconditions
library(medicalcoder)

################################################################################
# Build PCCC with subconditions and compute the summary
pccc_sub <- comorbidities(
  data        = mdcr,
  id.vars     = "patid",
  icd.codes   = "code",
  icdv.var    = "icdv",
  dx.var      = "dx",
  method      = "pccc_v3.1",
  flag.method = "current",
  poa         = 1,
  subconditions = TRUE
)

summary_current <- summary(pccc_sub)

stopifnot(
  inherits(summary_current, "data.frame"),
  identical(
    names(summary_current),
    c("condition",
      "subcondition",
      "count",
      "percent_of_cohort",
      "percent_of_those_with_condition")
  ),
  is.character(summary_current[["condition"]]),
  is.character(summary_current[["subcondition"]]),
  is.numeric(summary_current[["count"]]),
  is.numeric(summary_current[["percent_of_cohort"]]),
  is.numeric(summary_current[["percent_of_those_with_condition"]]),
  all(summary_current[["count"]] >= 0),
  all(summary_current[["percent_of_cohort"]] >= 0),
  all(summary_current[["percent_of_cohort"]] <= 100),
  all(is.na(summary_current[["percent_of_those_with_condition"]][is.na(summary_current[["subcondition"]])])),
  all(summary_current[["percent_of_those_with_condition"]][!is.na(summary_current[["subcondition"]])] >= 0),
  all(summary_current[["percent_of_those_with_condition"]][!is.na(summary_current[["subcondition"]])] <= 100)
)

################################################################################
# Condition-level counts align with the underlying comorbidity object
N <- nrow(pccc_sub[["conditions"]])

cvd_total <- sum(pccc_sub[["conditions"]][["cvd_dxpr_or_tech"]])
cvd_row <- summary_current[
  summary_current[["condition"]] == "cvd" &
  is.na(summary_current[["subcondition"]]),
]

stopifnot(
  nrow(cvd_row) == 1L,
  cvd_row[["count"]] == cvd_total,
  isTRUE(all.equal(cvd_row[["percent_of_cohort"]], 100 * cvd_total / N)),
  is.na(cvd_row[["percent_of_those_with_condition"]])
)

resp_total <- sum(pccc_sub[["conditions"]][["respiratory_dxpr_or_tech"]])
resp_row <- summary_current[
  summary_current[["condition"]] == "respiratory" &
  is.na(summary_current[["subcondition"]]),
]

stopifnot(
  nrow(resp_row) == 1L,
  resp_row[["count"]] == resp_total,
  isTRUE(all.equal(resp_row[["percent_of_cohort"]], 100 * resp_total / N)),
  is.na(resp_row[["percent_of_those_with_condition"]])
)

################################################################################
# Subcondition counts and percentages match direct aggregations
cvd_sub <- pccc_sub[["subconditions"]][["cvd"]]
cvd_hgvm <- sum(cvd_sub[["heart_and_great_vessel_malformations"]])

cvd_hgvm_idx <- which(
  summary_current[["condition"]] == "cvd" &
  summary_current[["subcondition"]] == "heart_and_great_vessel_malformations"
)
cvd_hgvm_row <- summary_current[cvd_hgvm_idx, , drop = FALSE]

stopifnot(
  nrow(cvd_hgvm_row) == 1L,
  cvd_hgvm_row[["count"]] == cvd_hgvm,
  isTRUE(all.equal(cvd_hgvm_row[["percent_of_cohort"]], 100 * cvd_hgvm / N)),
  isTRUE(all.equal(cvd_hgvm_row[["percent_of_those_with_condition"]], 100 * cvd_hgvm / cvd_total))
)

resp_sub <- pccc_sub[["subconditions"]][["respiratory"]]
resp_cystic_fibrosis <- sum(resp_sub[["cystic_fibrosis"]])

resp_cf_idx <- which(
  summary_current[["condition"]] == "respiratory" &
  summary_current[["subcondition"]] == "cystic_fibrosis"
)
resp_cf_row <- summary_current[resp_cf_idx, , drop = FALSE]

stopifnot(
  nrow(resp_cf_row) == 1L,
  resp_cf_row[["count"]] == resp_cystic_fibrosis,
  isTRUE(all.equal(resp_cf_row[["percent_of_cohort"]], 100 * resp_cystic_fibrosis / N)),
  isTRUE(all.equal(resp_cf_row[["percent_of_those_with_condition"]], 100 * resp_cystic_fibrosis / resp_total))
)

################################################################################
# A non-current flag.method emits a warning but returns the same summary
pccc_sub_cumulative <- pccc_sub
attr(pccc_sub_cumulative, "flag.method") <- "cumulative"

warn_obj <- tryCatchWarning(summary(pccc_sub_cumulative))

stopifnot(
  inherits(warn_obj, "warning"),
  identical(
    conditionMessage(warn_obj),
    "Logic for pccc_summary_table has been implemented for flag.method = 'current'.  Using this function for flag.method = 'cumulative' may not provide a meaningful summary."
  )
)

summary_cumulative <- suppressWarnings(summary(pccc_sub_cumulative))

stopifnot(identical(summary_cumulative, summary_current))

################################################################################
#                                 End of File                                  #
################################################################################
