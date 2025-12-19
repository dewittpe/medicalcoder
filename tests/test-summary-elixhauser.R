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
  all(summary_current$conditions$count >= 0),
  all(summary_current$conditions$percent >= 0),
  all(summary_current$conditions$percent <= 100)
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
  hf_count == sum(elixhauser$HF),
  diab_cx_count == sum(elixhauser$DIAB_CX)
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
  num_ge_1 == sum(elixhauser$num_cmrb >= 1),
  num_ge_2 == sum(elixhauser$num_cmrb >= 2)
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
    min    = c(min(elixhauser$readmission_index),
               min(elixhauser$mortality_index)),
    q1     = c(stats::quantile(elixhauser$readmission_index, prob = 0.25),
               stats::quantile(elixhauser$mortality_index, prob = 0.25)),
    median = c(stats::median(elixhauser$readmission_index),
               stats::median(elixhauser$mortality_index)),
    q3     = c(stats::quantile(elixhauser$readmission_index, prob = 0.75),
               stats::quantile(elixhauser$mortality_index, prob = 0.75)),
    max    = c(max(elixhauser$readmission_index),
               max(elixhauser$mortality_index)),
    row.names = NULL,
    stringsAsFactors = FALSE
  )

stopifnot(identical(summary_current$index_summary, expected_index_summary))

################################################################################
# A non-current flag.method generates a warning but still returns the summary
elixhauser_cumulative <- elixhauser
attr(elixhauser_cumulative, "flag.method") <- "cumulative"

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
  all(summary_zero$conditions$count == 0L),
  !any(is.nan(summary_zero$conditions$percent)),
  all(is.na(summary_zero$conditions$percent)),
  all(is.na(summary_zero$index_summary$min)),
  all(is.na(summary_zero$index_summary$q1)),
  all(is.na(summary_zero$index_summary$median)),
  all(is.na(summary_zero$index_summary$q3)),
  all(is.na(summary_zero$index_summary$max))
)

################################################################################
#                                 End of File                                  #
################################################################################
