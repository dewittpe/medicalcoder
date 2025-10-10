source('utilities.R')
################################################################################
# Tests for the charlson comorbidities
library(medicalcoder)

################################################################################
# verify the list of possible charlson methods
m <- grep("charlson_", medicalcoder:::comorbidities_methods(), value = TRUE)
m <- sort(m)
stopifnot(
  identical(
    m,
    c("charlson_cdmf2019", "charlson_deyo1992", "charlson_quan2005", "charlson_quan2011")
  )
)

# add an age variable
mdcr$age <- as.integer(substr(as.character(mdcr$patid), 1, 2))

cdmf         <- comorbidities(data = mdcr, id.vars = "patid", icdv.var = "icdv", icd.codes = "code", dx.var = "dx", method = "charlson_cdmf2019", poa = 1)
cdmf_withage <- comorbidities(data = mdcr, id.vars = "patid", icdv.var = "icdv", icd.codes = "code", dx.var = "dx", method = "charlson_cdmf2019", poa = 1, age.var = "age")

deyo         <- comorbidities(data = mdcr, id.vars = "patid", icdv.var = "icdv", icd.codes = "code", dx.var = "dx", method = "charlson_deyo1992", poa = 1)
deyo_withage <- comorbidities(data = mdcr, id.vars = "patid", icdv.var = "icdv", icd.codes = "code", dx.var = "dx", method = "charlson_deyo1992", poa = 1, age.var = "age")

quan2005         <- comorbidities(data = mdcr, id.vars = "patid", icdv.var = "icdv", icd.codes = "code", dx.var = "dx", method = "charlson_quan2005", poa = 1)
quan2005_withage <- comorbidities(data = mdcr, id.vars = "patid", icdv.var = "icdv", icd.codes = "code", dx.var = "dx", method = "charlson_quan2005", poa = 1, age.var = "age")

quan2011         <- comorbidities(data = mdcr, id.vars = "patid", icdv.var = "icdv", icd.codes = "code", dx.var = "dx", method = "charlson_quan2011", poa = 1)
quan2011_withage <- comorbidities(data = mdcr, id.vars = "patid", icdv.var = "icdv", icd.codes = "code", dx.var = "dx", method = "charlson_quan2011", poa = 1, age.var = "age")

# verify that a row is returned for each and every id.var
npatid <- length(unique(mdcr[["patid"]]))
stopifnot(
  nrow(cdmf) == npatid,
  nrow(cdmf_withage) == npatid,
  nrow(deyo) == npatid,
  nrow(deyo_withage) == npatid,
  nrow(quan2005) == npatid,
  nrow(quan2005_withage) == npatid,
  nrow(quan2011) == npatid,
  nrow(quan2011_withage) == npatid
)

# verify that age_score are NA or known
stopifnot(
   all(is.na(cdmf$age_score)),
  !any(is.na(cdmf_withage$age_score)),
   all(is.na(deyo$age_score)),
  !any(is.na(deyo_withage$age_score)),
   all(is.na(quan2005$age_score)),
  !any(is.na(quan2005_withage$age_score)),
   all(is.na(quan2011$age_score)),
  !any(is.na(quan2011_withage$age_score))
)

# verify that the cci is known and that the cci sans age <= cci with age
CDMF <- merge(cdmf, cdmf_withage, by = "patid")
stopifnot(
  !any(is.na(CDMF[["cci.x"]])),
  !any(is.na(CDMF[["cci.y"]])),
  all(CDMF[["cci.x"]] <= CDMF[["cci.y"]])
)

DEYO <- merge(deyo, deyo_withage, by = "patid")
stopifnot(
  !any(is.na(DEYO[["cci.x"]])),
  !any(is.na(DEYO[["cci.y"]])),
  all(DEYO[["cci.x"]] <= DEYO[["cci.y"]])
)

QUAN05 <- merge(quan2005, quan2005_withage, by = "patid")
stopifnot(
  !any(is.na(QUAN05[["cci.x"]])),
  !any(is.na(QUAN05[["cci.y"]])),
  all(QUAN05[["cci.x"]] <= QUAN05[["cci.y"]])
)

QUAN11 <- merge(quan2011, quan2011_withage, by = "patid")
stopifnot(
  !any(is.na(QUAN11[["cci.x"]])),
  !any(is.na(QUAN11[["cci.y"]])),
  all(QUAN11[["cci.x"]] <= QUAN11[["cci.y"]])
)

################################################################################
# Test that the aids and hiv flags as expected in charlson_cdmf2019

# Note: if this fails and needs to be updated there is a section in the
# comorbidities vignette that will need to be updated too.

cdmf_eg <-
  merge(x = mdcr,
        y = subset(get_charlson_codes(),
                   condition %in% c("aids", "hiv") &
                   charlson_cdmf2019 == 1),
        by = c("icdv", "dx", "code"))

cdmf_eg <-
  aggregate(
    x = cdmf_eg[["charlson_cdmf2019"]],
    by = cdmf_eg[c("patid", "condition")],
    FUN = function(x) as.integer(sum(x) > 0)
  )

cdmf_eg <-
  merge(
    x = cdmf_eg[cdmf_eg$condition == "aids", c("patid", "x")],
    y = cdmf_eg[cdmf_eg$condition == "hiv",  c("patid", "x")],
    all = TRUE,
    suffixes = c(".aids", ".hiv"),
    by = c("patid")
  )

stopifnot(
  identical(
    table(cdmf_eg[, c("x.aids", "x.hiv")], useNA = "always"),
    structure(c(1L, 6L, 2716L, 0L), dim = c(2L, 2L), dimnames = list(x.aids = c("1", NA), x.hiv = c("1", NA)), class = "table")
  )
)

cmdf_mdcr <-
  comorbidities(data = mdcr,
                icd.codes = "code",
                id.vars = "patid",
                icdv.var = "icdv",
                dx.var = "dx",
                method = "charlson_cdmf2019",
                flag.method = "current",
                poa = 1)

stopifnot(
  identical(
    table(cmdf_mdcr[, c("hiv", "aids")]),
    structure(c(38255L, 6L, 0L, 1L), dim = c(2L, 2L), dimnames = list(hiv = c("0", "1"), aids = c("0", "1")), class = "table")
  )
)

################################################################################
# tests for different sets of inputs
# with or with icdv
# with or without dx

mdcr2 <- mdcr

# add a patient and row to this data set that will result in a false positive
# for charlson_quan2005 when dx is not specified correctly.  This can be an
# ICD-9 procedure code which has the same compact form as an ICD-9 diagnostic
# code.  Found a good code for this.  ICD-9 5829, as a diagnostic code maps to
# rnd, as a procedure code it would map to nothing.  Add a patient to mdcr2 with
# this procedure code.
if (interactive()) {
  merge(
    get_icd_codes(),
    subset(get_charlson_codes(), charlson_quan2005 == 1 & icdv == 9, "code"),
    by = "code"
  )

  lookup_icd_codes("5829")
  subset(get_charlson_codes(), charlson_quan2005 == 1 & code == "5829")
  mdcr[mdcr$code == "5829", ]
}

mdcr2 <-
  rbind(
    mdcr2,
    data.frame(patid = 0, icdv = 9, code = "5829", dx = 0L, age = 42)
  )

#common arguments for the calls to comorbidities for just this bespoke patient
cargs <-
  list(
    data = data.frame(patid = 0, icdv = 9, code = "5829", dx = 0L, age = 42),
    id.vars = "patid",
    icd.codes = "code",
    poa = 1,
    method = "charlson_quan2005"
  )

out00 <- do.call(comorbidities, c(cargs, list(icdv.var = "icdv", dx.var = "dx")))
out01 <- do.call(comorbidities, c(cargs, list(                   dx.var = "dx")))
out02 <- do.call(comorbidities, c(cargs, list(icdv = 9,          dx.var = "dx")))
out03 <- do.call(comorbidities, c(cargs, list(icdv = 10,         dx.var = "dx")))
out04 <- do.call(comorbidities, c(cargs, list(icdv = 9)))
out05 <- do.call(comorbidities, c(cargs, list(icdv = 10)))
out06 <- do.call(comorbidities, c(cargs, list(icdv.var = "icdv"        )))
out07 <- do.call(comorbidities, c(cargs, list(icdv.var = "icdv", dx = 0)))
out08 <- do.call(comorbidities, c(cargs, list(icdv.var = "icdv", dx = 1)))
out09 <- do.call(comorbidities, c(cargs, list(                   dx = 0)))
out10 <- do.call(comorbidities, c(cargs, list(                   dx = 1)))
out11 <- do.call(comorbidities, cargs)

expected_out_false_positive <- structure(list(patid = 0, aidshiv = 0L, mal = 0L, cebvd = 0L, copd = 0L, chf = 0L, dem = 0L, dmc = 0L, dm = 0L, hp = 0L, mld = 0L, msld = 0L, mst = 0L, mi = 0L, pud = 0L, pvd = 0L, rnd = 1L, rhd = 0L, num_cmrb = 1L, cmrb_flag = 1L, cci = 2L, age_score = NA_integer_), row.names = c(NA, -1L), class = c("medicalcoder_comorbidities", "data.frame"), method = "charlson_quan2005", id.vars = "patid", flag.method = "current")
expected_out <- structure(list(patid = 0, aidshiv = 0L, mal = 0L, cebvd = 0L, copd = 0L, chf = 0L, dem = 0L, dmc = 0L, dm = 0L, hp = 0L, mld = 0L, msld = 0L, mst = 0L, mi = 0L, pud = 0L, pvd = 0L, rnd = 0L, rhd = 0L, num_cmrb = 0L, cmrb_flag = 0L, cci = 0L, age_score = NA_integer_), row.names = c(NA, -1L), class = c("medicalcoder_comorbidities", "data.frame"), method = "charlson_quan2005", id.vars = "patid", flag.method = "current")

stopifnot(
  identical(out00, expected_out),
  identical(out01, expected_out),
  identical(out02, expected_out),
  identical(out03, expected_out),
  identical(out04, expected_out_false_positive),
  identical(out05, expected_out),
  identical(out06, expected_out_false_positive),
  identical(out07, expected_out),
  identical(out08, expected_out_false_positive),
  identical(out09, expected_out),
  identical(out10, expected_out_false_positive),
  identical(out11, expected_out_false_positive)
)

# More general: common arguments for the calls to comorbidities
cargs <-
  list(
    data = mdcr2,
    id.vars = "patid",
    icd.codes = "code",
    poa = 1,
    method = "charlson_quan2005"
  )

out00 <- do.call(comorbidities, c(cargs, list(icdv.var = "icdv", dx.var = "dx")))
out01 <- do.call(comorbidities, c(cargs, list(                   dx.var = "dx")))
out02 <- do.call(comorbidities, c(cargs, list(icdv = 9,          dx.var = "dx")))
out03 <- do.call(comorbidities, c(cargs, list(icdv = 10,         dx.var = "dx")))
out04 <- do.call(comorbidities, c(cargs, list(icdv.var = "icdv"               )))
out05 <- do.call(comorbidities, c(cargs, list(icdv.var = "icdv", dx = 0       )))
out06 <- do.call(comorbidities, c(cargs, list(icdv.var = "icdv", dx = 1       )))

# all the outputs should be unique _except_ out04 and out06: charlson is only
# defined on diagnostic codes, so when nothing is passed for dx.var and dx then
# any diagnostic or procedure code will flag, in the same way that when dx = 1
# will treat al the input codes as diagnostic and will have the same false
# positives.
stopifnot(
  !isTRUE(all.equal(out00, out01)),
  !isTRUE(all.equal(out00, out02)),
  !isTRUE(all.equal(out00, out03)),
  !isTRUE(all.equal(out00, out04)),
  !isTRUE(all.equal(out00, out05)),
  !isTRUE(all.equal(out00, out06)),
  !isTRUE(all.equal(out01, out02)),
  !isTRUE(all.equal(out01, out03)),
  !isTRUE(all.equal(out01, out04)),
  !isTRUE(all.equal(out01, out05)),
  !isTRUE(all.equal(out01, out06)),
  !isTRUE(all.equal(out02, out03)),
  !isTRUE(all.equal(out02, out04)),
  !isTRUE(all.equal(out02, out05)),
  !isTRUE(all.equal(out02, out06)),
  !isTRUE(all.equal(out03, out04)),
  !isTRUE(all.equal(out03, out05)),
  !isTRUE(all.equal(out03, out06)),
  !isTRUE(all.equal(out04, out05)),
   isTRUE(all.equal(out04, out06)),
  !isTRUE(all.equal(out05, out06))
)

################################################################################
#                                 End of File                                  #
################################################################################
