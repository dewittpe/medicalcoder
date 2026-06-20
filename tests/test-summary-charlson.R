source('utilities.R')
################################################################################
# Tests for summarizing Charlson comorbidities
library(medicalcoder)

################################################################################
# Prepare input with an age variable to exercise age scoring logic
mdcr$age <- as.integer(substr(as.character(mdcr$patid), 1, 2))

charlson <- comorbidities(
  data       = mdcr,
  id.vars    = "patid",
  icdv.var   = "icdv",
  icd.codes  = "code",
  dx.var     = "dx",
  method     = "charlson_quan2011",
  flag.method = "current",
  poa        = 1L,
  primarydx  = 0L,
  age.var    = "age"
)

summary_current <- summary(charlson)
charlson_conditions <- charlson[["conditions"]]

stopifnot(
  is.list(summary_current),
  identical(names(summary_current), c("conditions", "age_summary", "index_summary")),
  is.data.frame(summary_current$conditions),
  identical(
    names(summary_current$conditions),
    c("condition_description", "condition", "count", "percent")
  ),
  is.character(summary_current$conditions$condition_description),
  is.character(summary_current$conditions$condition),
  is.numeric(summary_current$conditions$count),
  is.numeric(summary_current$conditions$percent),
  isTRUE(all(summary_current$conditions$count >= 0)),
  isTRUE(all(summary_current$conditions$percent >= 0)),
  isTRUE(all(summary_current$conditions$percent <= 100))
)

################################################################################
# Conditions summary matches direct aggregations
aidshiv_count <- summary_current$conditions[
  !is.na(summary_current$conditions$condition) &
  summary_current$conditions$condition == "aidshiv",
  "count"
]
copd_count <- summary_current$conditions[
  !is.na(summary_current$conditions$condition) &
  summary_current$conditions$condition == "copd",
  "count"
]

stopifnot(
  isTRUE(aidshiv_count == sum(charlson_conditions$aidshiv)),
  isTRUE(copd_count   == sum(charlson_conditions$copd))
)

num_ge_1 <- summary_current$conditions[
  is.na(summary_current$conditions$condition) &
  summary_current$conditions$condition_description == ">= 1",
  "count"
]
num_ge_2 <- summary_current$conditions[
  is.na(summary_current$conditions$condition) &
  summary_current$conditions$condition_description == ">= 2",
  "count"
]

stopifnot(
  isTRUE(num_ge_1 == sum(charlson_conditions$num_cmrb >= 1)),
  isTRUE(num_ge_2 == sum(charlson_conditions$num_cmrb >= 2))
)

################################################################################
# Age and index summaries align with expected calculations
expected_age_summary <-
  {
    age_count <- table(charlson_conditions$age_score, useNA = "always")
    age_percent <- 100 * prop.table(age_count)
    data.frame(
      age_score = unname(names(age_count)),
      count = unname(as.integer(age_count)),
      percent = unname(as.numeric(age_percent)),
      stringsAsFactors = FALSE
    )
  }

stopifnot(identical(summary_current$age_summary, expected_age_summary))

expected_index_summary <-
  data.frame(
    min    = min(charlson_conditions$cci),
    q1     = stats::quantile(charlson_conditions$cci, prob = 0.25),
    median = stats::median(charlson_conditions$cci),
    q3     = stats::quantile(charlson_conditions$cci, prob = 0.75),
    max    = max(charlson_conditions$cci),
    row.names = NULL
  )

stopifnot(identical(summary_current$index_summary, expected_index_summary))

################################################################################
# Missing age.var creates an all-NA age_score and should still summarize cleanly
charlson_no_age <- comorbidities(
  data        = mdcr,
  id.vars     = "patid",
  icdv.var    = "icdv",
  icd.codes   = "code",
  dx.var      = "dx",
  method      = "charlson_quan2011",
  flag.method = "current",
  poa         = 1L,
  primarydx   = 0L
)

summary_no_age <- summary(charlson_no_age)

stopifnot(
  identical(summary_no_age$age_summary$age_score, NA_character_),
  identical(summary_no_age$age_summary$count, nrow(charlson_no_age[["conditions"]])),
  identical(summary_no_age$age_summary$percent, 100),
  !anyNA(row.names(summary_no_age$age_summary))
)

################################################################################
# A non-current flag.method generates a warning but still returns the summary
charlson_cumulative <- charlson
charlson_cumulative[["metadata"]][["flag.method"]] <- "cumulative"

warn_obj <- tryCatchWarning(summary(charlson_cumulative))

stopifnot(
  inherits(warn_obj, "warning"),
  identical(
    conditionMessage(warn_obj),
    "Logic for charlson summary table has been implemented for flag.method = 'current'.  Using this function for flag.method = 'cumulative' may not provide a meaningful summary."
  )
)

summary_cumulative <- suppressWarnings(summary(charlson_cumulative))

stopifnot(
  identical(summary_cumulative$conditions, summary_current$conditions),
  identical(summary_cumulative$age_summary, summary_current$age_summary),
  identical(summary_cumulative$index_summary, summary_current$index_summary)
)

################################################################################
# Zero-row input should summarize without NaN/Inf
df0 <- data.frame(
  patid = integer(),
  icdv  = integer(),
  dx    = integer(),
  code  = character(),
  age   = integer(),
  stringsAsFactors = FALSE
)

charlson_zero <- comorbidities(
  data        = df0,
  id.vars     = "patid",
  icdv.var    = "icdv",
  icd.codes   = "code",
  dx.var      = "dx",
  method      = "charlson_quan2011",
  flag.method = "current",
  poa         = 1L,
  primarydx   = 0L,
  age.var     = "age"
)

summary_zero <- summary(charlson_zero)

stopifnot(
  is.list(summary_zero),
  identical(names(summary_zero), c("conditions", "age_summary", "index_summary")),
  isTRUE(all(summary_zero$conditions$count == 0L)),
  isTRUE(!any(is.nan(summary_zero$conditions$percent))),
  isTRUE(all(is.na(summary_zero$conditions$percent))),
  isTRUE(all(summary_zero$index_summary == 0 | is.na(summary_zero$index_summary)))
)

################################################################################
#                                 End of File                                  #
################################################################################
