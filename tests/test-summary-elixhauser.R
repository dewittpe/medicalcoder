source('utilities.R')
################################################################################
# Tests for summarizing Elixhauser comorbidities
library(medicalcoder)

################################################################################
# Build Elixhauser comorbidities and summary
elixhauser <- comorbidities(
  data        = mdcr,
  id.vars     = "patid",
  icdv.var    = "icdv",
  icd.codes   = "code",
  dx.var      = "dx",
  method      = "elixhauser_ahrq_icd10",
  flag.method = "current",
  poa         = 1,
  primarydx   = 0
)

summary_current <- summary(elixhauser)
elixhauser_conditions <- elixhauser[["conditions"]]

stopifnot(
  is.list(summary_current),
  identical(names(summary_current), c("conditions", "index_summary")),
  is.data.frame(summary_current$conditions),
  identical(
    names(summary_current$conditions),
    c("condition", "count", "percent")
  ),
  is.character(summary_current$conditions$condition),
  is.numeric(summary_current$conditions$count),
  is.numeric(summary_current$conditions$percent),
  isTRUE(all(summary_current$conditions$count >= 0)),
  isTRUE(all(summary_current$conditions$percent >= 0)),
  isTRUE(all(summary_current$conditions$percent <= 100))
)

################################################################################
# Conditions summary matches direct aggregations
hf_count <- summary_current$conditions[
  summary_current$conditions$condition == "HF",
  "count"
]
diab_cx_count <- summary_current$conditions[
  summary_current$conditions$condition == "DIAB_CX",
  "count"
]

stopifnot(
  isTRUE(hf_count == sum(elixhauser_conditions$HF)),
  isTRUE(diab_cx_count == sum(elixhauser_conditions$DIAB_CX))
)

num_ge_1 <- summary_current$conditions[
  summary_current$conditions$condition == ">= 1",
  "count"
]
num_ge_2 <- summary_current$conditions[
  summary_current$conditions$condition == ">= 2",
  "count"
]

stopifnot(
  isTRUE(num_ge_1 == sum(elixhauser_conditions$num_cmrb >= 1)),
  isTRUE(num_ge_2 == sum(elixhauser_conditions$num_cmrb >= 2))
)

################################################################################
# Index summary aligns with expected calculations
stopifnot(
  is.data.frame(summary_current$index_summary),
  identical(
    names(summary_current$index_summary),
    c("index", "min", "q1", "median", "q3", "max")
  ),
  is.character(summary_current$index_summary$index),
  is.numeric(summary_current$index_summary$min),
  is.numeric(summary_current$index_summary$q1),
  is.numeric(summary_current$index_summary$median),
  is.numeric(summary_current$index_summary$q3),
  is.numeric(summary_current$index_summary$max)
)

expected_index_summary <-
  data.frame(
    index  = c("readmission", "mortality"),
    min    = c(min(elixhauser_conditions$readmission_index),
               min(elixhauser_conditions$mortality_index)),
    q1     = c(stats::quantile(elixhauser_conditions$readmission_index, prob = 0.25),
               stats::quantile(elixhauser_conditions$mortality_index, prob = 0.25)),
    median = c(stats::median(elixhauser_conditions$readmission_index),
               stats::median(elixhauser_conditions$mortality_index)),
    q3     = c(stats::quantile(elixhauser_conditions$readmission_index, prob = 0.75),
               stats::quantile(elixhauser_conditions$mortality_index, prob = 0.75)),
    max    = c(max(elixhauser_conditions$readmission_index),
               max(elixhauser_conditions$mortality_index)),
    row.names = NULL,
    stringsAsFactors = FALSE
  )

stopifnot(identical(summary_current$index_summary, expected_index_summary))

################################################################################
# A non-current flag.method generates a warning but still returns the summary
elixhauser_cumulative <- elixhauser
elixhauser_cumulative[["metadata"]][["flag.method"]] <- "cumulative"

warn_obj <- tryCatchWarning(summary(elixhauser_cumulative))

stopifnot(
  inherits(warn_obj, "warning"),
  identical(
    conditionMessage(warn_obj),
    "Logic for Elixhauser summary has been implemented for flag.method = 'current'.  Using this function for flag.method = 'cumulative' may not provide a meaningful summary."
  )
)

summary_cumulative <- suppressWarnings(summary(elixhauser_cumulative))

stopifnot(
  identical(summary_cumulative$conditions, summary_current$conditions),
  identical(summary_cumulative$index_summary, summary_current$index_summary)
)

################################################################################
# Zero-row input should summarize without NaN/Inf
df0 <- data.frame(
  patid = integer(),
  icdv  = integer(),
  dx    = integer(),
  code  = character(),
  stringsAsFactors = FALSE
)

elixhauser_zero <- comorbidities(
  data        = df0,
  id.vars     = "patid",
  icdv.var    = "icdv",
  icd.codes   = "code",
  dx.var      = "dx",
  method      = "elixhauser_ahrq_icd10",
  flag.method = "current",
  poa         = 1L,
  primarydx   = 0L
)

summary_zero <- summary(elixhauser_zero)

stopifnot(
  is.list(summary_zero),
  identical(names(summary_zero), c("conditions", "index_summary")),
  isTRUE(all(summary_zero$conditions$count == 0L)),
  isTRUE(!any(is.nan(summary_zero$conditions$percent))),
  isTRUE(all(is.na(summary_zero$conditions$percent))),
  isTRUE(all(is.na(summary_zero$index_summary$min))),
  isTRUE(all(is.na(summary_zero$index_summary$q1))),
  isTRUE(all(is.na(summary_zero$index_summary$median))),
  isTRUE(all(is.na(summary_zero$index_summary$q3))),
  isTRUE(all(is.na(summary_zero$index_summary$max)))
)

################################################################################
#                                 End of File                                  #
################################################################################
