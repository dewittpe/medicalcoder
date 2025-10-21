source('utilities.R')
library(medicalcoder)

################################################################################
# Verify that the pccc codes are retrievable as a data.frame
pccc_codes <- get_pccc_codes()
stopifnot("pccc_codes are a data.frame" = identical(class(pccc_codes), "data.frame"))
stopifnot(
  identical(
    names(pccc_codes),
    c("icdv", "dx", "full_code", "code", "condition", "subcondition", "transplant_flag", "tech_dep_flag", "pccc_v3.1", "pccc_v3.0", "pccc_v2.1", "pccc_v2.0")
  )
)

################################################################################
# verify that there is not going to be an error if no matches are found
dat <- data.frame(patid = 1:26,
                  icd = c(letters, LETTERS),
                  pr1 = 1:26,
                  icdv = sample(9:10, size = 26, replace = TRUE))

stopifnot(sum(
    comorbidities(data = dat, icd.codes = "icd", poa = 1, flag.method = "current", method = "pccc_v3.0")
    , na.rm = TRUE) == 0)

stopifnot(sum(comorbidities(data = dat, id.vars = "patid", icd.codes = "icd",                    poa = 1, flag.method = "current", method = "pccc_v3.0"), na.rm = TRUE) == sum(1:26))
stopifnot(sum(comorbidities(data = dat, id.vars = "patid", icd.codes = "icd", icdv.var = "icdv", poa = 1, flag.method = "current", method = "pccc_v3.0"), na.rm = TRUE) == sum(1:26))
stopifnot(sum(comorbidities(data = dat, id.vars = "patid", icd.codes = "icd", icdv = 9,          poa = 1, flag.method = "current", method = "pccc_v3.0"), na.rm = TRUE) == sum(1:26))
stopifnot(sum(comorbidities(data = dat, id.vars = "patid", icd.codes = "icd", icdv = 10,         poa = 1, flag.method = "current", method = "pccc_v3.0"), na.rm = TRUE) == sum(1:26))
stopifnot(sum(comorbidities(data = dat, id.vars = "patid", icd.codes = "icd", dx = 1L,       poa = 1, flag.method = "current", method = "pccc_v3.0"), na.rm = TRUE) == sum(1:26))
stopifnot(sum(comorbidities(data = dat, id.vars = "patid", icd.codes = "icd", dx = 0L,       poa = 1, flag.method = "current", method = "pccc_v3.0"), na.rm = TRUE) == sum(1:26))

stopifnot(sum(comorbidities(data = dat, icd.codes = "icd", method = "pccc_v2.0", poa = 1, flag.method = "current"), na.rm = TRUE) == 0)

stopifnot(sum(comorbidities(data = dat, id.vars = "patid", icd.codes = "icd",                    poa = 1, flag.method = "current", method = "pccc_v2.0"), na.rm = TRUE) == sum(1:26))
stopifnot(sum(comorbidities(data = dat, id.vars = "patid", icd.codes = "icd", icdv.var = "icdv", poa = 1, flag.method = "current", method = "pccc_v2.0"), na.rm = TRUE) == sum(1:26))
stopifnot(sum(comorbidities(data = dat, id.vars = "patid", icd.codes = "icd", icdv = 9,          poa = 1, flag.method = "current", method = "pccc_v2.0"), na.rm = TRUE) == sum(1:26))
stopifnot(sum(comorbidities(data = dat, id.vars = "patid", icd.codes = "icd", icdv = 10,         poa = 1, flag.method = "current", method = "pccc_v2.0"), na.rm = TRUE) == sum(1:26))
stopifnot(sum(comorbidities(data = dat, id.vars = "patid", icd.codes = "icd", dx = 1L,       poa = 1, flag.method = "current", method = "pccc_v2.0"), na.rm = TRUE) == sum(1:26))
stopifnot(sum(comorbidities(data = dat, id.vars = "patid", icd.codes = "icd", dx = 0L,       poa = 1, flag.method = "current", method = "pccc_v2.0"), na.rm = TRUE) == sum(1:26))

################################################################################
# Verify the output of the pccc call

rtn <- comorbidities(data = mdcr, icd.codes = "code", method = "pccc_v3.0", poa = 1, flag.method = "current")

expected_rtn <-
  structure(
    list(
      congeni_genetic_dxpr_only = 1L,
      congeni_genetic_tech_only = 0L,
      congeni_genetic_dxpr_and_tech = 0L,
      congeni_genetic_dxpr_or_tech = 1L,
      cvd_dxpr_only = 0L,
      cvd_tech_only = 0L,
      cvd_dxpr_and_tech = 1L,
      cvd_dxpr_or_tech = 1L,
      gi_dxpr_only = 0L,
      gi_tech_only = 0L,
      gi_dxpr_and_tech = 1L,
      gi_dxpr_or_tech = 1L,
      hemato_immu_dxpr_only = 1L,
      hemato_immu_tech_only = 0L,
      hemato_immu_dxpr_and_tech = 0L,
      hemato_immu_dxpr_or_tech = 1L,
      malignancy_dxpr_only = 1L,
      malignancy_tech_only = 0L,
      malignancy_dxpr_and_tech = 0L,
      malignancy_dxpr_or_tech = 1L,
      metabolic_dxpr_only = 0L,
      metabolic_tech_only = 0L,
      metabolic_dxpr_and_tech = 1L,
      metabolic_dxpr_or_tech = 1L,
      misc_dxpr_only = 0L,
      misc_tech_only = 0L,
      misc_dxpr_and_tech = 1L,
      misc_dxpr_or_tech = 1L,
      neonatal_dxpr_only = 1L,
      neonatal_tech_only = 0L,
      neonatal_dxpr_and_tech = 0L,
      neonatal_dxpr_or_tech = 1L,
      neuromusc_dxpr_only = 0L,
      neuromusc_tech_only = 0L,
      neuromusc_dxpr_and_tech = 1L,
      neuromusc_dxpr_or_tech = 1L,
      renal_dxpr_only = 0L,
      renal_tech_only = 0L,
      renal_dxpr_and_tech = 1L,
      renal_dxpr_or_tech = 1L,
      respiratory_dxpr_only = 0L,
      respiratory_tech_only = 0L,
      respiratory_dxpr_and_tech = 1L,
      respiratory_dxpr_or_tech = 1L,
      any_tech_dep = 1L,
      any_transplant = 1L,
      num_cmrb = 11L,
      cmrb_flag = 1L
    ),
    row.names = c(NA, -1L),
    class = c("medicalcoder_comorbidities", "data.frame"),
    method = "pccc_v3.0",
    id.vars = "..medicalcoder_id..",
    flag.method = "current"
  )

stopifnot(
  "pccc v3 with mdcr is as all.equal" = isTRUE(all.equal(rtn, expected_rtn)),
  "pccc v3 with mdcr is as expected" = isTRUE(identical(rtn, expected_rtn))
)

################################################################################
# test longitudinal output

args <- list(data = mdcr_longitudinal, id.vars = c("patid", "date"), icdv.var = "icdv", icd.codes = "code", poa = 1)

current <-
  list(
    pccc_current_v3.1    = do.call(comorbidities, c(args, list(flag.method = 'current',    method = "pccc_v3.1"))),
    pccc_cumulative_v3.1 = do.call(comorbidities, c(args, list(flag.method = "cumulative", method = "pccc_v3.1"))),
    pccc_current_v3.0    = do.call(comorbidities, c(args, list(flag.method = 'current',    method = "pccc_v3.0"))),
    pccc_cumulative_v3.0 = do.call(comorbidities, c(args, list(flag.method = "cumulative", method = "pccc_v3.0"))),
    pccc_current_v2.1    = do.call(comorbidities, c(args, list(flag.method = 'current',    method = "pccc_v2.1"))),
    pccc_cumulative_v2.1 = do.call(comorbidities, c(args, list(flag.method = "cumulative", method = "pccc_v2.1"))),
    pccc_current_v2.1    = do.call(comorbidities, c(args, list(flag.method = 'current',    method = "pccc_v2.0"))),
    pccc_cumulative_v2.1 = do.call(comorbidities, c(args, list(flag.method = "cumulative", method = "pccc_v2.0")))
)

# if the expected results need to be updated:
### for (n in names(current)) {
###   saveRDS(
###     object = current[[n]],
###     file = file.path("expected-results-for-test-pccc", paste0(n, ".rds")),
###     compress = "xz"
###   )
### }

expected <- list.files(path = "expected-results-for-test-pccc", pattern = "\\.rds$", full.name = TRUE)
names(expected) <- sub("\\.rds", "", basename(expected))
expected <- sapply(expected, readRDS, simplify = FALSE)

for (obj in names(current)) {
  stopifnot(all.equal(expected[[obj]], current[[obj]]))
}

################################################################################
# tests for different sets of inputs
# with or with icdv
# with or without dx

# common arguments for the calls to comorbidities
cargs <-
  list(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    poa = 1,
    method = "pccc_v3.1"
  )

out00 <- do.call(comorbidities, c(cargs, list(icdv.var = "icdv", dx.var = "dx")))
out01 <- do.call(comorbidities, c(cargs, list(                   dx.var = "dx")))
out02 <- do.call(comorbidities, c(cargs, list(icdv = 9,          dx.var = "dx")))
out03 <- do.call(comorbidities, c(cargs, list(icdv = 10,         dx.var = "dx")))
out04 <- do.call(comorbidities, c(cargs, list(icdv.var = "icdv"               )))
out05 <- do.call(comorbidities, c(cargs, list(icdv.var = "icdv", dx = 0       )))
out06 <- do.call(comorbidities, c(cargs, list(icdv.var = "icdv", dx = 1       )))
out07 <- do.call(comorbidities, c(cargs))

# all the outputs should be unique
stopifnot(
  !isTRUE(all.equal(out00, out01)),
  !isTRUE(all.equal(out00, out02)),
  !isTRUE(all.equal(out00, out03)),
  !isTRUE(all.equal(out00, out04)),
  !isTRUE(all.equal(out00, out05)),
  !isTRUE(all.equal(out00, out06)),
  !isTRUE(all.equal(out00, out07)),

  !isTRUE(all.equal(out01, out02)),
  !isTRUE(all.equal(out01, out03)),
  !isTRUE(all.equal(out01, out04)),
  !isTRUE(all.equal(out01, out05)),
  !isTRUE(all.equal(out01, out06)),
  !isTRUE(all.equal(out01, out07)),

  !isTRUE(all.equal(out02, out03)),
  !isTRUE(all.equal(out02, out04)),
  !isTRUE(all.equal(out02, out05)),
  !isTRUE(all.equal(out02, out06)),
  !isTRUE(all.equal(out02, out07)),

  !isTRUE(all.equal(out03, out04)),
  !isTRUE(all.equal(out03, out05)),
  !isTRUE(all.equal(out03, out06)),
  !isTRUE(all.equal(out03, out07)),

  !isTRUE(all.equal(out04, out05)),
  !isTRUE(all.equal(out04, out06)),
  !isTRUE(all.equal(out04, out07)),

  !isTRUE(all.equal(out05, out06)),
  !isTRUE(all.equal(out05, out07)),

  !isTRUE(all.equal(out06, out07))
)

# out00 should be "correct", out01 and out04 should only have false positives
stopifnot(
  all(out00$num_cmrb <= out01$num_cmrb),
  all(out00$num_cmrb <= out04$num_cmrb)
)

# for out02, out03, out05, and out06, there will be false positives and false
# negatives
stopifnot(
  !identical(out00$num_cmrb, out02$num_cmrb),
  !identical(out00$num_cmrb, out03$num_cmrb),
  !identical(out00$num_cmrb, out05$num_cmrb),
  !identical(out00$num_cmrb, out06$num_cmrb),
  !identical(out00$num_cmrb, out07$num_cmrb)
)

################################################################################
#                                 End of File                                  #
################################################################################
