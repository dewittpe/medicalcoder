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
rtn <- tryCatch(summary(cmb), warning = function(w) w)
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
#                                 End of File                                  #
################################################################################
