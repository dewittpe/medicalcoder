source('utilities.R')
################################################################################
library(medicalcoder)
set.seed(42)

################################################################################
# verify an error will be thrown if lenght(id.vars) < 2 and flag.method =
# "cumulative"

rtn <- # length(id.vars) = 0
  tryCatchError(
    comorbidities(
      data = mdcr,
      icd.codes = "code",
      poa = 1L,
      flag.method = 'cumulative',
      method = "pccc_v3.1"
    )
  )
stopifnot(inherits(rtn, "error"))

rtn <- # length(id.vars) = 1
  tryCatchError(
    comorbidities(
      data = mdcr,
      id.vars = "patid",
      icd.codes = "code",
      poa = 1L,
      flag.method = 'cumulative',
      method = "pccc_v3.1"
    )
  )
stopifnot(inherits(rtn, "error"))


################################################################################
# verify errors are thrown if a "protected" name is used for the id.vars,
# poa.var, or primarydx.var
mdcr2 <- mdcr
mdcr2[["condition"]] <- 1L

x <-
  tryCatchError(
    comorbidities(
      data = mdcr2,
      icd.codes = "code",
      id.vars = c("patid", "condition"),
      method = "pccc_v3.1"
    )
  )
stopifnot(inherits(x, "error"))

x <-
  tryCatchError(
    comorbidities(
      data = mdcr2,
      icd.codes = "code",
      id.vars = c("condition"),
      method = "pccc_v3.1"
    )
  )
stopifnot(inherits(x, "error"))

x <-
  tryCatchError(
    comorbidities(
      data = mdcr2,
      icd.codes = "code",
      poa.var = c("condition"),
      method = "pccc_v3.1"
    )
  )
stopifnot(inherits(x, "error"))

x <-
  tryCatchError(
    comorbidities(
      data = mdcr2,
      icd.codes = "code",
      primarydx.var = "condition",
      method = "elixhauser_ahrq2025"
    )
  )
stopifnot(inherits(x, "error"))

################################################################################
# verify errors are thrown when icdv.var, dx.var, poa.var, or primarydx.var are
# non-numeric
mdcr3 <- mdcr
mdcr3[["icdv_chr"]] <- as.character(mdcr3[["icdv"]])
mdcr3[["dx_chr"]] <- as.character(mdcr3[["dx"]])
mdcr3[["poa_chr"]] <- as.character(rep(1L, nrow(mdcr3)))
mdcr3[["primarydx_chr"]] <- as.character(rep(0L, nrow(mdcr3)))

x <-
  tryCatchError(
    comorbidities(
      data = mdcr3,
      id.vars = "patid",
      icd.codes = "code",
      icdv.var = "icdv_chr",
      dx.var = "dx",
      poa = 1L,
      method = "pccc_v3.1"
    )
  )
stopifnot(
  inherits(x, "error"),
  grepl(
    "Column .*icdv_chr.* must be numeric \\(9/10/NA\\) when supplied as icdv\\.var\\.",
    gsub("['\"`\\p{Pi}\\p{Pf}]", "", x[["message"]], perl = TRUE)
  )
)

x <-
  tryCatchError(
    comorbidities(
      data = mdcr3,
      id.vars = "patid",
      icd.codes = "code",
      icdv.var = "icdv",
      dx.var = "dx_chr",
      poa = 1L,
      method = "pccc_v3.1"
    )
  )
stopifnot(
  inherits(x, "error"),
  grepl(
    "Column .*dx_chr.* must be numeric \\(0/1/NA\\) when supplied as dx\\.var\\.",
    gsub("['\"`\\p{Pi}\\p{Pf}]", "", x[["message"]], perl = TRUE)
  )
)

x <-
  tryCatchError(
    comorbidities(
      data = mdcr3,
      id.vars = "patid",
      icd.codes = "code",
      icdv.var = "icdv",
      dx.var = "dx",
      poa.var = "poa_chr",
      method = "pccc_v3.1"
    )
  )
stopifnot(
  inherits(x, "error"),
  grepl(
    "Column .*poa_chr.* must be numeric \\(0/1/NA\\) when supplied as poa\\.var\\.",
    gsub("['\"`\\p{Pi}\\p{Pf}]", "", x[["message"]], perl = TRUE)
  )
)

x <-
  tryCatchError(
    comorbidities(
      data = mdcr3,
      id.vars = "patid",
      icd.codes = "code",
      icdv.var = "icdv",
      dx.var = "dx",
      poa = 1L,
      primarydx.var = "primarydx_chr",
      method = "elixhauser_ahrq2025"
    )
  )
stopifnot(
  inherits(x, "error"),
  grepl(
    "Column .*primarydx_chr.* must be numeric \\(0/1/NA\\) when supplied as primarydx\\.var\\.",
    gsub("['\"`\\p{Pi}\\p{Pf}]", "", x[["message"]], perl = TRUE)
  )
)


################################################################################
# Test: check_and_set_*
#
# The check_and_set_* are non-exported methods.  We test them here with calls to
# comorbidities() so that we can capture these test with covr

# Verify these methods are non-exported
stopifnot(!("check_and_set_id_vars" %in% getNamespaceExports("medicalcoder")))

# The following data frames are used to test check_and_set_id_vars.
# `..medicalcoder_id..` is the initial name used in the check and set when
# creating an id column.  it needs to persist in the output if provided as an
# id.
DF0 <- data.frame(pid = NA, code = "A00")
DF1 <- data.frame(medicalcoder_id = NA, code = "A00")
DF2 <- data.frame(..medicalcoder_id.. = NA, code = "A00")

# verify that the constuction of a id.vars within the function works as
# expected.
OUT0 <- comorbidities(data = DF0, icd.codes = "code", method = "pccc_v3.0", poa = 1)
OUT1 <- comorbidities(data = DF1, icd.codes = "code", method = "pccc_v3.0", poa = 1)
OUT2 <- comorbidities(data = DF2, icd.codes = "code", method = "pccc_v3.0", poa = 1)

expected_names <-
  c(
    "congeni_genetic_dxpr_only",
    "congeni_genetic_tech_only",
    "congeni_genetic_dxpr_and_tech",
    "congeni_genetic_dxpr_or_tech",

    "cvd_dxpr_only",
    "cvd_tech_only",
    "cvd_dxpr_and_tech",
    "cvd_dxpr_or_tech",

    "gi_dxpr_only",
    "gi_tech_only",
    "gi_dxpr_and_tech",
    "gi_dxpr_or_tech",

    "hemato_immu_dxpr_only",
    "hemato_immu_tech_only",
    "hemato_immu_dxpr_and_tech",
    "hemato_immu_dxpr_or_tech",

    "malignancy_dxpr_only",
    "malignancy_tech_only",
    "malignancy_dxpr_and_tech",
    "malignancy_dxpr_or_tech",

    "metabolic_dxpr_only",
    "metabolic_tech_only",
    "metabolic_dxpr_and_tech",
    "metabolic_dxpr_or_tech",

    "misc_dxpr_only",
    "misc_tech_only",
    "misc_dxpr_and_tech",
    "misc_dxpr_or_tech",

    "neonatal_dxpr_only",
    "neonatal_tech_only",
    "neonatal_dxpr_and_tech",
    "neonatal_dxpr_or_tech",

    "neuromusc_dxpr_only",
    "neuromusc_tech_only",
    "neuromusc_dxpr_and_tech",
    "neuromusc_dxpr_or_tech",

    "renal_dxpr_only",
    "renal_tech_only",
    "renal_dxpr_and_tech",
    "renal_dxpr_or_tech",

    "respiratory_dxpr_only",
    "respiratory_tech_only",
    "respiratory_dxpr_and_tech",
    "respiratory_dxpr_or_tech",

    "any_tech_dep",
    "any_transplant",

    "num_cmrb",
    "cmrb_flag"
  )

stopifnot(identical(names(OUT0), expected_names))
stopifnot(identical(names(OUT1), expected_names))
stopifnot(identical(names(OUT2), expected_names))

OUT0 <- comorbidities(data = DF0, id.vars = "pid", icd.codes = "code", method = "pccc_v3.0", poa = 1)
OUT1 <- comorbidities(data = DF1, id.vars = "medicalcoder_id", icd.codes = "code", method = "pccc_v3.0", poa = 1)
OUT2 <- comorbidities(data = DF2, id.vars = "..medicalcoder_id..", icd.codes = "code", method = "pccc_v3.0", poa = 1)

stopifnot(identical(names(OUT0), c("pid", expected_names)))
stopifnot(identical(names(OUT1), c("medicalcoder_id", expected_names)))
stopifnot(identical(names(OUT2), c("..medicalcoder_id..", expected_names)))

################################################################################
# Extra columns with names used internally by lookup tables should not affect
# condition mapping.

collision_data <-
  data.frame(
    id = "p1",
    code = "I50.9",
    icdv = 10L,
    dx = 1L,
    condition = "user_supplied_condition",
    charlson_quan2011 = 0L,
    poaexempt = 0L,
    stringsAsFactors = FALSE
  )

no_collision_data <- collision_data[, c("id", "code", "icdv", "dx")]

collision_args <-
  list(
    id.vars = "id",
    icd.codes = "code",
    icdv.var = "icdv",
    dx.var = "dx",
    poa = 1L,
    primarydx = 0L,
    method = "charlson_quan2011"
  )

collision_result <-
  do.call(
    comorbidities,
    c(list(data = collision_data), collision_args)
  )

no_collision_result <-
  do.call(
    comorbidities,
    c(list(data = no_collision_data), collision_args)
  )

stopifnot(
  identical(collision_result, no_collision_result),
  collision_result[["chf"]] == 1L,
  collision_result[["cmrb_flag"]] == 1L
)

################################################################################
# Check for "protected" names in id.vars.
#
# During development I had been using id.vars such as:
#
#   id.vars = c("patid", "icd_code")
#
# so I could look at which codes in a patient record where flagging.
#
# When I tried the following
#
#   id.vars = c("patid", "icd_code", "icdv")
#   icdv.var = NULL
#   icdv = NULL
#
# I'd get an error because the "icdv" name is being used in the lookup tables and
# gets drop in the methods and the joins in the code created a icdv.x and icdv.y
# variable.  The code was updated so that the suffixes would be c("", ".y") to
# fix this issue.
#
# for 0.0.0.9038 the following calls to comorbidities would error with the
# following message:
#
#    Error in `[.data.frame`(x, r, vars, drop = drop) :
#      undefined columns selected
#
# Expect that the following calls should work without error
#
# between 0.0.0.9044 and 0.0.0.9045 it was determined that there are some names
# that should not be used in the id.vars, poa.var, or the primarydx.var.  Tests
# for those are above.  The tests below would have passed for 0.0.0.9039 -
# 0.0.0.9044, but will error for 0.0.0.9045 with a useful error message.
mdcr$full_code <- "just a test"
mdcr$icd_code <- mdcr$code

args <- list(data = mdcr, icd.code = "icd_code", method = "pccc_v3.0", poa = 1)

out1 <- tryCatchError(do.call(comorbidities, c(args, list(id.vars = c("patid", "full_code")))))
out2 <- tryCatchError(do.call(comorbidities, c(args, list(id.vars = c("patid", "icdv")))))
out3 <- tryCatchError(do.call(comorbidities, c(args, list(id.vars = c("patid", "dx")))))
out4 <- tryCatchError(do.call(comorbidities, c(args, list(id.vars = c("patid", "code")))))
stopifnot(
  inherits(out1, "error"),
  inherits(out2, "error"),
  inherits(out3, "error"),
  inherits(out4, "error")
)

################################################################################
# when a primarydx.var was passed to comorbidities when not needed an error was
# thrown.  https://github.com/dewittpe/medicalcoder/issues/16
#
# This has been corrected to be a warning
x <-
  tryCatchWarning(
    comorbidities(
      data = mdcr,
      id.var = "patid",
      method = "charlson_quan2005",
      icd.codes = "code",
      poa = 1
    )
  )
stopifnot("warning for missing primarydx" = inherits(x, "warning"))

################################################################################
# Subconditions are only applicable to PCCC, so a warning should be given when
# subconditions = TRUE for any other method
args <- list(
  data = mdcr[1:10, ],
  icd.codes = "icd_code",
  icdv.var = "icdv",
  dx.var = "dx",
  poa = 1,
  subconditions = TRUE
  )
ms <- medicalcoder:::comorbidities_methods()
ms <- ms[!startsWith(ms, "pccc")]
for (m in ms) {
  x <- tryCatchWarning(do.call(comorbidities, c(args, list(method = m))))
  z <- inherits(x, "warning")
  if (!z) {
    stop(sprintf("no warning given for subconditions = TRUE with method = '%s'", m))
  }
  if (x$message != "subconditions only implemented for PCCC") {
    stop(sprintf("unexpected warning message for subcondtions = TRUE with method = '%s'", m))
  }
}

################################################################################
# Argument precedence warnings and cumulative encounter validation

warn_pccc_primarydx <-
  tryCatchWarning(
    comorbidities(
      data = mdcr[1:10, ],
      id.vars = "patid",
      icd.codes = "code",
      poa = 1L,
      primarydx = 0L,
      method = "pccc_v3.1"
    )
  )

warn_icdv_conflict <-
  tryCatchWarning(
    comorbidities(
      data = mdcr[1:10, ],
      id.vars = "patid",
      icd.codes = "code",
      icdv.var = "icdv",
      icdv = 10L,
      poa = 1L,
      method = "pccc_v3.1"
    )
  )

warn_dx_conflict <-
  tryCatchWarning(
    comorbidities(
      data = mdcr[1:10, ],
      id.vars = "patid",
      icd.codes = "code",
      dx.var = "dx",
      dx = 1L,
      poa = 1L,
      method = "pccc_v3.1"
    )
  )

warn_poa_conflict <-
  tryCatchWarning(
    comorbidities(
      data = data.frame(id = 1L, code = "C78.4", poa = 1L),
      id.vars = "id",
      icd.codes = "code",
      poa.var = "poa",
      poa = 0L,
      method = "pccc_v3.1"
    )
  )

warn_primarydx_conflict <-
  tryCatchWarning(
    comorbidities(
      data = data.frame(id = 1L, code = "C78.4", primarydx = 0L),
      id.vars = "id",
      icd.codes = "code",
      poa = 1L,
      primarydx.var = "primarydx",
      primarydx = 1L,
      method = "charlson_quan2005"
    )
  )

pccc_primarydx_complete <-
  suppressWarnings(
    comorbidities(
      data = data.frame(id = 1L, code = "C78.4"),
      id.vars = "id",
      icd.codes = "code",
      poa = 1L,
      primarydx = 1L,
      method = "pccc_v3.1"
    )
  )

subconditions_complete <-
  suppressWarnings(
    comorbidities(
      data = data.frame(id = 1L, code = "C78.4"),
      id.vars = "id",
      icd.codes = "code",
      poa = 1L,
      method = "charlson_quan2005",
      subconditions = TRUE
    )
  )

icdv_conflict_complete <-
  suppressWarnings(
    comorbidities(
      data = data.frame(id = 1L, code = "C78.4", icdv = 10L),
      id.vars = "id",
      icd.codes = "code",
      icdv.var = "icdv",
      icdv = 9L,
      dx = 1L,
      poa = 1L,
      primarydx = 0L,
      method = "charlson_quan2005"
    )
  )

dx_conflict_complete <-
  suppressWarnings(
    comorbidities(
      data = data.frame(id = 1L, code = "C78.4", dx = 1L),
      id.vars = "id",
      icd.codes = "code",
      icdv = 10L,
      dx.var = "dx",
      dx = 0L,
      poa = 1L,
      primarydx = 0L,
      method = "charlson_quan2005"
    )
  )

primarydx_default_complete <-
  suppressWarnings(
    comorbidities(
      data = data.frame(id = 1L, code = "C78.4"),
      id.vars = "id",
      icd.codes = "code",
      poa = 1L,
      method = "charlson_quan2005"
    )
  )

bad_enc <-
  tryCatchError(
    comorbidities(
      data = data.frame(id = 1L, enc = I(list(list(1L))), code = "C78.4"),
      id.vars = c("id", "enc"),
      icd.codes = "code",
      poa = 1L,
      flag.method = "cumulative",
      method = "pccc_v3.1"
    )
  )

stopifnot(
  inherits(warn_pccc_primarydx, "warning"),
  warn_pccc_primarydx$message == "primarydx.var and primarydx are ignored when method = 'pccc_v3.1'",
  inherits(warn_icdv_conflict, "warning"),
  warn_icdv_conflict$message == "'icdv.var' and 'icdv' were both specified; ignoring 'icdv'",
  inherits(warn_dx_conflict, "warning"),
  warn_dx_conflict$message == "'dx.var' and 'dx' were both specified; ignoring 'dx'",
  inherits(warn_poa_conflict, "warning"),
  warn_poa_conflict$message == "'poa.var' and 'poa' were both specified; ignoring 'poa'",
  inherits(warn_primarydx_conflict, "warning"),
  warn_primarydx_conflict$message == "'primarydx.var' and 'primarydx' were both specified; ignoring 'primarydx'",
  inherits(bad_enc, "error"),
  grepl("must be numeric, character, Date, or POSIXt", bad_enc$message, fixed = TRUE),
  inherits(pccc_primarydx_complete, "medicalcoder_comorbidities"),
  inherits(subconditions_complete, "medicalcoder_comorbidities"),
  inherits(icdv_conflict_complete, "medicalcoder_comorbidities"),
  inherits(dx_conflict_complete, "medicalcoder_comorbidities"),
  inherits(primarydx_default_complete, "medicalcoder_comorbidities")
)

################################################################################
# Regex mapping paths for Charlson variants

regex_data <-
  data.frame(
    id = seq_len(4L),
    code = c("C78.4", "C78.4", "C78.4", "C78.4"),
    icdv = c(10L, 10L, 10L, 10L),
    dx = c(1L, 1L, 1L, 1L),
    stringsAsFactors = FALSE
  )

regex_args <-
  list(
    data = regex_data,
    id.vars = "id",
    icd.codes = "code",
    poa = 1L,
    primarydx = 0L,
    method = "charlson_quan2005",
    mapping = "regex"
  )

regex_none <- do.call(comorbidities, regex_args)
regex_dx <- do.call(comorbidities, c(regex_args, list(dx.var = "dx")))
regex_icdv <- do.call(comorbidities, c(regex_args, list(icdv.var = "icdv")))
regex_both <- do.call(comorbidities, c(regex_args, list(icdv.var = "icdv", dx.var = "dx")))

stopifnot(
  all(regex_none[["mst"]] == 1L),
  all(regex_dx[["mst"]] == 1L),
  all(regex_icdv[["mst"]] == 1L),
  all(regex_both[["mst"]] == 1L)
)

name_collision <-
  comorbidities(
    data = data.frame(..medicalcoder_id.. = "C78.4", stringsAsFactors = FALSE),
    icd.codes = "..medicalcoder_id..",
    poa = 1L,
    primarydx = 0L,
    method = "charlson_quan2005"
  )

stopifnot(name_collision[["mst"]] == 1L, !("..medicalcoder_id.." %in% names(name_collision)))

################################################################################
# Zero-row inputs without id.vars exercise internally-created ID removal paths.

zero_no_id <-
  comorbidities(
    data = mdcr[0, ],
    icd.codes = "code",
    poa = 1L,
    method = "pccc_v3.1"
  )

zero_subconditions_no_id <-
  comorbidities(
    data = mdcr[0, ],
    icd.codes = "code",
    poa = 1L,
    method = "pccc_v3.1",
    subconditions = TRUE
  )

stopifnot(
  inherits(zero_no_id, "medicalcoder_comorbidities"),
  nrow(zero_no_id) == 0L,
  inherits(zero_subconditions_no_id, "medicalcoder_comorbidities_with_subconditions"),
  nrow(zero_subconditions_no_id[["conditions"]]) == 0L,
  all(vapply(zero_subconditions_no_id[["subconditions"]], nrow, integer(1)) == 0L)
)

################################################################################
# age.var handling for charlson with missing/ambiguous id.vars
#
# RE: https://github.com/dewittpe/medicalcoder/issues/43
DF <-
  data.frame(
    pid = c(1, 1, 2),
    enc_id = c(1, 2, 1),
    icd_code = c("", "", ""),
    age = c(54, 55, 54),
    stringsAsFactors = FALSE
  )

common_args <-
  list(
    data      = DF,
    icd.codes = "icd_code",
    poa       = 1L,
    primarydx = 0L,
    method    = "charlson_quan2005"
  )

# id.vars = NULL should not error when age.var is supplied
# for v0.8.0 this would error.
out_no_error <-
  tryCatchError(
    suppressWarnings(
      do.call(comorbidities, c(common_args, list(id.vars = NULL, age.var = "age")))
    )
  )
stopifnot(inherits(out_no_error, "medicalcoder_comorbidities"), nrow(out_no_error) == 2L)

# if id.vars = NULL, or id.vars = "ptid", for the example, data, the return will
# have three rows becuase the ages are distinct.  This should give a warning
out0_warning <-
  tryCatchWarning(
    do.call(comorbidities, c(common_args, list(id.vars = NULL, age.var = "age")))
  )
out1_warning <-
  tryCatchWarning(
    do.call(comorbidities, c(common_args, list(id.vars = "pid", age.var = "age")))
  )
stopifnot(inherits(out0_warning, "warning"), inherits(out1_warning, "warning"))
stopifnot(
  out0_warning$message == "There is more than one unique value for age.  Since `id.vars = NULL` the expectation is there would be one unique age value.  The return will have more than one row, one for each unique age.",
  out1_warning$message == "There is at least one set of id.vars with more than one age value.  The expectation is that there is only one age value for each unique set of id.vars.  The return will have more than one row for each unique set of id.vars."
)

out0 <-
  suppressWarnings(
    do.call(comorbidities, c(common_args, list(id.vars = NULL, age.var = "age")))
  )
out1 <-
  suppressWarnings(
    do.call(comorbidities, c(common_args, list(id.vars = "pid", age.var = "age")))
  )
stopifnot(
  inherits(out0, "medicalcoder_comorbidities"), nrow(out0) == 2L,
  inherits(out1, "medicalcoder_comorbidities"), nrow(out1) == 3L
)

################################################################################
#                                 End of File                                  #
################################################################################
