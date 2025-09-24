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
# Verify that all the ICD codes in the data set are valid codes
x <- is_icd(pccc_codes$code, headerok = TRUE, ever.assignable = TRUE, warn.ambiguous = FALSE)
stopifnot("all compact pccc_codes are valid ever.assignable icd codes" = all(x))

x <- is_icd(pccc_codes$full_code, headerok = TRUE, ever.assignable = TRUE, warn.ambiguous = FALSE)
stopifnot("all full pccc_codes are valid ever.assignable icd codes" = all(x))

x <-
  pccc_codes[pccc_codes$icdv == 9 & pccc_codes$dx == 1, "full_code"] |>
  is_icd(icdv = 9, dx = 1, headerok = TRUE, ever.assignable = TRUE, warn.ambiguous = FALSE)
stopifnot("all icdv 9 dx full codes are valid ever.assignable icd codes" = all(x))

x <-
  pccc_codes[pccc_codes$icdv == 9 & pccc_codes$dx == 0, "full_code"] |>
  is_icd(icdv = 9, dx = 0, headerok = TRUE, ever.assignable = TRUE, warn.ambiguous = FALSE)
stopifnot("all icdv 9 pr full codes are valid ever.assignable icd codes" = all(x))

x <-
  pccc_codes[pccc_codes$icdv == 10 & pccc_codes$dx == 1, "full_code"] |>
  is_icd(icdv = 10, dx = 1L, headerok = TRUE, ever.assignable = TRUE, warn.ambiguous = FALSE)
stopifnot("all icdv 10 dx full codes are valid ever.assignable icd codes" = all(x))

x <-
  pccc_codes[pccc_codes$icdv == 10 & pccc_codes$dx == 0L, "full_code"] |>
  is_icd(icdv = 10, dx = 0L, headerok = TRUE, ever.assignable = TRUE)
stopifnot("all icdv 10 pr full codes are valid ever.assignable icd codes" = all(x))

################################################################################
# verify that there is not going to be an error if no matches are found
dat <- data.frame(patid = 1:26,
                  icd = c(letters, LETTERS),
                  pr1 = 1:26,
                  icdv = sample(9:10, size = 26, replace = TRUE))

stopifnot(sum(comorbidities(data = dat, icd.codes = "icd", poa = 1, flag.method = "current", method = "pccc_v3.0"), na.rm = TRUE) == 0)

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

expected <- list.files(path = "expected-results-for-test-pccc", pattern = "\\.rds$", full.name = TRUE)
names(expected) <- sub("\\.rds", "", basename(expected))
expected <- sapply(expected, readRDS, simplify = FALSE)

for (obj in names(current)) {
  stopifnot(all.equal(expected[[obj]], current[[obj]]))
}

################################################################################
#                                 End of File                                  #
################################################################################
