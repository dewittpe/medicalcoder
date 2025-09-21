################################################################################
library(medicalcoder)
library(data.table)
setDTthreads(threads = 1L) # to prevent CPU time exceeding elapsed time on CRAN
set.seed(42)

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
# A quick check that all the reasonable combinations of inputs for comorbidities
# run without error.  There should be alot of warnings generated from this.  The
# objective here is to just check that everything runs without error so the
# warnings will be suppressed.
#
# Will check with data.tables, data.frame, and tibbles
DT <- copy(mdcr_longitudinal)
setDT(DT)
DT[, poa := as.integer(runif(.N) < 0.1)]
DT[, dx  := as.integer(runif(.N) < 0.5)]
DT[, age := runif(.N, min = 0, max = 99)]
DT[, primary := as.integer(runif(.N) < 0.1)]
DF <- copy(DT)
setDF(DF)
TB <- copy(DT)
setDF(TB)
TB <- tibble::as_tibble(TB)

stopifnot(identical(
  capture.output(args(comorbidities)),
  c("function (data, icd.codes, method, id.vars = NULL, icdv.var = NULL, ",
  "    icdv = NULL, dx.var = NULL, dx = NULL, poa.var = NULL, poa = NULL, ",
  "    age.var = NULL, primarydx.var = NULL, primarydx = NULL, flag.method = c(\"current\", ",
  "        \"cumulative\"), full.codes = TRUE, compact.codes = TRUE, ",
  "    subconditions = FALSE) ", "NULL")
  )
)

# 5598720 count of input combinations
# if takes 1 second to run the test it would take
# 5598720 / (3600 * 24) = 64.8 days to run the following test.
#
# SO DON'T RUN THIS
if (FALSE) {
  for (DATA in c("DT", "DF", "TB")) {
    for (METHOD in medicalcoder:::comorbidities_methods()) {
      for (IDVARS in list(NA, "patid", c("patid", "date"))) {
        for (ICDVVAR in list(NA, "icdv")) {
          for (ICDV in list(NA, 9L, 10L)) {
            for (DXVAR in list(NA, "dx")) {
              for (DX in list(NA, 0L, 1L)) {
                for (POAVAR in list(NA, "poa")) {
                  for (POA in list(NA, 0L, 1L)) {
                    for (AGEVAR in list(NA, "age")) {
                      for (PRIMARYDXVAR in list(NA, "primary")) {
                        for (PRIMARYDX in list(NA, 0L, 1L)) {
                          for (FLAGMETHOD in c("current", "cumulative")) {
                            for (FULLCODES in c(TRUE, FALSE)) {
                              for (COMPACTCODES in c(TRUE, FALSE)) {
                                for (SUBCONDITIONS in c(TRUE, FALSE)) {

                                  cl <- list(quote(comorbidities),
                                             data = as.name(DATA),
                                             icd.codes = "code",
                                             method = METHOD,
                                             flag.method = FLAGMETHOD,
                                             full.codes = FULLCODES,
                                             compact.codes = COMPACTCODES,
                                             subconditions = SUBCONDITIONS)

                                  if (length(IDVARS) > 1) {
                                    cl[["id.vars"]] <- IDVARS
                                  } else if (!is.na(IDVARS)) {
                                    cl[["id.vars"]] <- IDVARS
                                  }

                                  if (!is.na(ICDVVAR)) {
                                    cl[["icdv.var"]] <- ICDVVAR
                                  }

                                  if (!is.na(ICDV)) {
                                    cl[["icdv"]] <- ICDV
                                  }

                                  if (!is.na(DXVAR)) {
                                    cl[["dx.var"]] <- DXVAR
                                  }

                                  if (!is.na(DX)) {
                                    cl[["dx"]] <- DX
                                  }

                                  if (!is.na(POAVAR)) {
                                    cl[["poa.var"]] <- POAVAR
                                  }

                                  if (!is.na(POA)) {
                                    cl[["poa"]] <- POA
                                  }

                                  if (!is.na(AGEVAR)) {
                                    cl[["age.var"]] <- AGEVAR
                                  }

                                  if (!is.na(PRIMARYDXVAR)) {
                                    cl[["primarydx.var"]] <- PRIMARYDXVAR
                                  }

                                  if (!is.na(PRIMARYDX)) {
                                    cl[["primarydx"]] <- PRIMARYDX
                                  }

                                  suppressWarnings(eval(as.call(cl)))

                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

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
# variable.  The code was updated so that the suffixes would by c("", ".y") to
# fix this issue.
#
# for 0.0.0.9038 the following calls to comorbidities would error with the
# following message:
#
#    Error in `[.data.frame`(x, r, vars, drop = drop) :
#      undefined columns selected
#
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
