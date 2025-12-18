source('utilities.R')
library(medicalcoder)

################################################################################
# Verify the summary table output for pccc_v3.0 with flag.method = current is as expected
rtn <- comorbidities(data = mdcr, id.vars = "patid", icd.codes = "code", poa = 1, flag.method = 'current', method = "pccc_v3.0")
rtn <- summary(rtn)

stopifnot(
  inherits(rtn, "data.frame"),
  identical(
    names(rtn),
    c("condition", "label",
      "dxpr_or_tech_count", "dxpr_or_tech_percent",
      "dxpr_only_count", "dxpr_only_percent",
      "tech_only_count", "tech_only_percent",
      "dxpr_and_tech_count", "dxpr_and_tech_percent")
  ),
  is.character(rtn[["condition"]]),
  is.character(rtn[["label"]]),
  is.integer(rtn[["dxpr_or_tech_count"]]),
  is.numeric(rtn[["dxpr_or_tech_percent"]]),
  is.integer(rtn[["dxpr_only_count"]]),
  is.numeric(rtn[["dxpr_only_percent"]]),
  is.integer(rtn[["tech_only_count"]]),
  is.numeric(rtn[["tech_only_percent"]]),
  is.integer(rtn[["dxpr_and_tech_count"]]),
  is.numeric(rtn[["dxpr_and_tech_percent"]])
)

################################################################################
# Verify the summary table output for pccc_v3.0 with flag.method = cumulative is as expected
cmb <- comorbidities(data = mdcr_longitudinal, id.vars = c("patid", "date"), icd.codes = "code", poa = 1, flag.method = 'cumulative', method = "pccc_v3.0")
rtn <- tryCatchWarning(summary(cmb))
stopifnot(inherits(rtn, "warning"))

rtn <- suppressWarnings(summary(cmb))
stopifnot(
  inherits(rtn, "data.frame"),
  identical(
    names(rtn),
    c("condition", "label",
      "dxpr_or_tech_count", "dxpr_or_tech_percent",
      "dxpr_only_count", "dxpr_only_percent",
      "tech_only_count", "tech_only_percent",
      "dxpr_and_tech_count", "dxpr_and_tech_percent")
  ),
  is.character(rtn[["condition"]]),
  is.character(rtn[["label"]]),
  is.integer(rtn[["dxpr_or_tech_count"]]),
  is.numeric(rtn[["dxpr_or_tech_percent"]]),
  is.integer(rtn[["dxpr_only_count"]]),
  is.numeric(rtn[["dxpr_only_percent"]]),
  is.integer(rtn[["tech_only_count"]]),
  is.numeric(rtn[["tech_only_percent"]]),
  is.integer(rtn[["dxpr_and_tech_count"]]),
  is.numeric(rtn[["dxpr_and_tech_percent"]])
)

################################################################################
# Verify the summary table output for pccc_v3.1 is as expected
rtn <- comorbidities(data = mdcr, id.vars = "patid", icd.codes = "code", poa = 1, flag.method = 'current', method = "pccc_v3.1")
rtn <- summary(rtn)

stopifnot(
  inherits(rtn, "data.frame"),
  identical(
    names(rtn),
    c("condition", "label",
      "dxpr_or_tech_count", "dxpr_or_tech_percent",
      "dxpr_only_count", "dxpr_only_percent",
      "tech_only_count", "tech_only_percent",
      "dxpr_and_tech_count", "dxpr_and_tech_percent")
  ),
  is.character(rtn[["condition"]]),
  is.character(rtn[["label"]]),
  is.integer(rtn[["dxpr_or_tech_count"]]),
  is.numeric(rtn[["dxpr_or_tech_percent"]]),
  is.integer(rtn[["dxpr_only_count"]]),
  is.numeric(rtn[["dxpr_only_percent"]]),
  is.integer(rtn[["tech_only_count"]]),
  is.numeric(rtn[["tech_only_percent"]]),
  is.integer(rtn[["dxpr_and_tech_count"]]),
  is.numeric(rtn[["dxpr_and_tech_percent"]])
)

################################################################################
# PCCC Version 2.0

rtn <- comorbidities(data = mdcr, id.vars = "patid", icd.codes = "code", poa = 1, flag.method = 'current', method = "pccc_v2.0")
rtn <- summary(rtn)

stopifnot(
  inherits(rtn, "data.frame"),
  identical(
    names(rtn),
    c("condition", "label", "count", "percent")
  ),
  is.character(rtn[["condition"]]),
  is.character(rtn[["label"]]),
  is.integer(rtn[["count"]]),
  is.numeric(rtn[["percent"]])
)


################################################################################
# PCCC Version 2.1

rtn <- comorbidities(data = mdcr, id.vars = "patid", icd.codes = "code", poa = 1, flag.method = 'current', method = "pccc_v2.1")
rtn <- summary(rtn)

stopifnot(
  inherits(rtn, "data.frame"),
  identical(
    names(rtn),
    c("condition", "label", "count", "percent")
  ),
  is.character(rtn[["condition"]]),
  is.character(rtn[["label"]]),
  is.integer(rtn[["count"]]),
  is.numeric(rtn[["percent"]])
)

################################################################################
# PCCC Version 2.1 with flag.method = "cumulative"

cmb <- comorbidities(data = mdcr_longitudinal, id.vars = c("patid", "date"), icd.codes = "code", poa = 1, flag.method = 'cumulative', method = "pccc_v2.1")
rtn <- tryCatchWarning(summary(cmb))
stopifnot(inherits(rtn, "warning"))
rtn <- suppressWarnings(summary(cmb))

stopifnot(
  inherits(rtn, "data.frame"),
  identical(
    names(rtn),
    c("condition", "label", "count", "percent")
  ),
  is.character(rtn[["condition"]]),
  is.character(rtn[["label"]]),
  is.integer(rtn[["count"]]),
  is.numeric(rtn[["percent"]])
)

################################################################################
# Zero-row input should summarize without NaN/Inf (v2.1)

pccc_zero <- comorbidities(
  data        = mdcr[0, ],
  id.vars     = "patid",
  icd.codes   = "code",
  poa         = 1,
  flag.method = "current",
  method      = "pccc_v2.1"
)

summary_zero <- summary(pccc_zero)

stopifnot(
  inherits(summary_zero, "data.frame"),
  all(identical(summary_zero$count, c(rep(0L, 24)))),
  !any(is.nan(summary_zero$percent)),
  all(is.na(summary_zero$percent))
)

################################################################################
# Zero-row input should summarize without NaN/Inf (v3.1)

pccc_zero <- comorbidities(
  data        = mdcr[0, ],
  id.vars     = "patid",
  icd.codes   = "code",
  poa         = 1,
  flag.method = "current",
  method      = "pccc_v3.1"
)

summary_zero <- summary(pccc_zero)

stopifnot(
  inherits(summary_zero, "data.frame"),
  all(identical(summary_zero$dxpr_or_tech_count, c(rep(0L, 24)))),
  all(identical(summary_zero$dxpr_only_count, c(rep(0L, 11), rep(NA_integer_, 13)))),
  all(identical(summary_zero$tech_only_count, c(rep(0L, 11), rep(NA_integer_, 13)))),
  all(identical(summary_zero$dxpr_and_tech_count, c(rep(0L, 11), rep(NA_integer_, 13)))),
  !any(is.nan(summary_zero$dxpr_or_tech_percent)),
  !any(is.nan(summary_zero$dxpr_only_percent)),
  !any(is.nan(summary_zero$tech_only_percent)),
  !any(is.nan(summary_zero$dxpr_and_tech_percent))
)

################################################################################
#                                 End of File                                  #
################################################################################
