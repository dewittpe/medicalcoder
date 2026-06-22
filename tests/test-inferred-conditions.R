library(medicalcoder)

# Use two sites with the same patient identifier to exercise a composite
# patient key plus an encounter key under cumulative flagging.
dat <-
  data.frame(
    site = c("A", "A", "B", "B"),
    patid = c(1L, 1L, 1L, 1L),
    encounter = c(1L, 2L, 1L, 2L),
    code = c("I252", "I252", "I252", "I252"),
    stringsAsFactors = FALSE
  )

cumulative <-
  comorbidities(
    data = dat,
    id.vars = c("site", "patid", "encounter"),
    icd.codes = "code",
    icdv = 10L,
    dx = 1L,
    poa = 0L,
    primarydx = 0L,
    method = "charlson_quan2011",
    flag.method = "cumulative",
    inferred.conditions = TRUE
  )

# inferred.conditions previously indexed a data frame with [[id.vars2]], which
# failed when id.vars2 contained more than one column. Verify the documented
# output and that occurrence numbering restarts for each composite patient key.
# This was a bug between v0.8.1 and v0.9.0.
stopifnot(
  is.data.frame(cumulative[["inferred_conditions"]]),
  all(c("site", "patid", "encounter", "condition", "reported_poa", "inferred_poa",
        "reported_primarydx", "inferred_primarydx", "occurrence") %in%
      names(cumulative[["inferred_conditions"]])),
  isTRUE(
    all(
      tapply(
        cumulative[["inferred_conditions"]][["occurrence"]],
        interaction(cumulative[["inferred_conditions"]][c("site", "patid")]),
        function(x) x[1L]
      ) == 1L
    )
  )
)

warning_message <- NULL
current <-
  withCallingHandlers(
    comorbidities(
      data = dat,
      id.vars = c("site", "patid", "encounter"),
      icd.codes = "code",
      icdv = 10L,
      dx = 1L,
      poa = 1L,
      primarydx = 0L,
      method = "charlson_quan2011",
      flag.method = "current",
      inferred.conditions = TRUE
    ),
    warning = function(w) {
      warning_message <<- conditionMessage(w)
      invokeRestart("muffleWarning")
    }
  )

# Inferred-condition output is meaningful only for cumulative flagging. Current
# flagging must issue the documented warning and leave the optional list element
# NULL rather than returning misleading data.
stopifnot(
  identical(
    warning_message,
    "`inferred.conditions = TRUE` is only meaningful when `flag.method = 'cumulative'."
  ),
  is.null(current[["inferred_conditions"]])
)

# The inferred_conditions object used to be undefined when cumulative mapping
# found no comorbidities. A no-match call must still return a valid result with
# either NULL or an empty data frame for the optional element.
no_matches <-
  comorbidities(
    data = data.frame(
      patid = 1L,
      encounter = 1L,
      code = "ZZZ999",
      stringsAsFactors = FALSE
    ),
    id.vars = c("patid", "encounter"),
    icd.codes = "code",
    icdv = 10L,
    dx = 1L,
    poa = 0L,
    primarydx = 0L,
    method = "charlson_quan2011",
    flag.method = "cumulative",
    inferred.conditions = TRUE
  )

stopifnot(
  inherits(no_matches, "medicalcoder_comorbidities"),
  is.null(no_matches[["inferred_conditions"]]) ||
    is.data.frame(no_matches[["inferred_conditions"]])
)
