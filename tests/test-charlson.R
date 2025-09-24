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
#                                 End of File                                  #
################################################################################
