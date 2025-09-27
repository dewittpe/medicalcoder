################################################################################
library(medicalcoder)
set.seed(42)

################################################################################
# verify that an error will be thrown if id.vars is passed and it is not a name
# in the data
e <-
  tryCatch(
    comorbidities(data = mdcr, id.vars = "not_a_name", icd.code = "code"),
    error = function(e) {e}
  )
stopifnot(inherits(e, "error"))

if (requireNamespace("data.table", quietly = TRUE)) {
  e <-
    tryCatch(
      comorbidities(data = data.table::as.data.table(mdcr), id.vars = "not_a_name", icd.code = "code"),
      error = function(e) {e}
    )
  stopifnot(inherits(e, "error"))
}

if (requireNamespace("tibble", quietly = TRUE)) {
  e <-
    tryCatch(
      comorbidities(data = tibble::as_tibble(mdcr), id.vars = "not_a_name", icd.code = "code"),
      error = function(e) {e}
    )
  stopifnot(inherits(e, "error"))
}


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
# I'd get an error becuase the "icdv" name is being used in the lookup tables and
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
mdcr$full_code <- "just a test"
mdcr$icd_code <- mdcr$code

args <- list(data = mdcr, icd.code = "icd_code", method = "pccc_v3.0", poa = 1)
out <- do.call(comorbidities, c(args, list(id.vars = c("patid", "full_code"))))
out <- do.call(comorbidities, c(args, list(id.vars = c("patid", "icdv"))))
out <- do.call(comorbidities, c(args, list(id.vars = c("patid", "dx"))))
out <- do.call(comorbidities, c(args, list(id.vars = c("patid", "code"))))

################################################################################
#                                 End of File                                  #
################################################################################
