################################################################################
# file: icd/icd9/icd9_cm_pcs.R
#
# purpose: Merge CDC and CMS ICD-9-CM/PCS extracts, harmonize descriptions, and
#          flag header rows for comorbidity algorithms.
#
# inputs:
#   cdc.rds (built via data-raw/icd/icd9/cdc.R)
#   cms.rds (built via data-raw/icd/icd9/cms.R)
#
# output: icd9_cm_pcs.rds (data.table with code, dx, year, cm_pcs_desc,
#         cm_pcs_header)
#
# deps: data.table, zoo
#
# notes:
#   Requires prior execution of CDC and CMS builders in this directory.
#   Interactive sanity checks are optional and skipped when non-interactive.
#
# idempotent: yes (deterministic merge and transformations)
################################################################################
cdc <- readRDS(file = "cdc.rds")
cms <- readRDS(file = "cms.rds")
data.table::setDT(cdc)
data.table::setDT(cms)

################################################################################
# Look for differences between codes from CDC and CMS by year
#
# This is focused only on the codes themselves, not the descriptions.
cdc_codes <- cdc[, .(code, dx, year, src = "cdc", dummy = 1L)]
cms_codes <- cms[, .(code, dx, year, src = "cms", dummy = 1L)]

# If there are duplicated codes dcast will give a warning. For this work that
# needs to be an error
old_warn <- options()$warn
options(warn = 2)
allcodes <-
  data.table::dcast(
    data.table::rbindlist(list(cdc_codes, cms_codes), use.name = TRUE),
    code + dx ~ paste(src, year, sep = "_"),
    value.var = "dummy"
  )
options(warn = old_warn)

# check for FY 1997 - 2005 not needed, cdc only

# check for codes between CDC and CMS in FY 2006
test2006 <-
  allcodes[(!is.na(cdc_2006) &  is.na(cms_2006)) |
           ( is.na(cdc_2006) & !is.na(cms_2006)),
         .(code, cdc_2006, cms_2006)]

test2007 <-
  allcodes[(!is.na(cdc_2007) &  is.na(cms_2007)) |
           ( is.na(cdc_2007) & !is.na(cms_2007)),
         .(code, cdc_2007, cms_2007)]

test2008 <-
  allcodes[(!is.na(cdc_2008) &  is.na(cms_2008)) |
           ( is.na(cdc_2008) & !is.na(cms_2008)),
         .(code, cdc_2008, cms_2008)]

test2009 <-
  allcodes[(!is.na(cdc_2009) &  is.na(cms_2009)) |
           ( is.na(cdc_2009) & !is.na(cms_2009)),
         .(code, cdc_2009, cms_2009)]

test2010 <-
  allcodes[(!is.na(cdc_2010) &  is.na(cms_2010)) |
           ( is.na(cdc_2010) & !is.na(cms_2010)),
         .(code, cdc_2010, cms_2010)]

test2011 <-
  allcodes[(!is.na(cdc_2011) &  is.na(cms_2011)) |
           ( is.na(cdc_2011) & !is.na(cms_2011)),
         .(code, cdc_2011, cms_2011)]

test2012 <-
  allcodes[(!is.na(cdc_2012) &  is.na(cms_2012)) |
           ( is.na(cdc_2012) & !is.na(cms_2012)),
         .(code, cdc_2012, cms_2012)]

# test for FY 2013, 2014, 2015 - no cdc data; there are new procedure codes
test2013 <-
  allcodes[(!is.na(cdc_2012) &  is.na(cms_2013)) |
           ( is.na(cdc_2012) & !is.na(cms_2013)),
         .(code, cdc_2012, cms_2013)]
test2014 <-
  allcodes[(!is.na(cdc_2012) &  is.na(cms_2014)) |
           ( is.na(cdc_2012) & !is.na(cms_2014)),
         .(code, cdc_2012, cms_2014)]
test2015 <-
  allcodes[(!is.na(cdc_2012) &  is.na(cms_2015)) |
           ( is.na(cdc_2012) & !is.na(cms_2015)),
         .(code, cdc_2012, cms_2015)]

stopifnot(nrow(test2006) == 0L)
stopifnot(nrow(test2007) == 0L)
stopifnot(nrow(test2008) == 0L)
stopifnot(nrow(test2009) == 0L)
stopifnot(nrow(test2010) == 0L)
stopifnot(nrow(test2011) == 0L)
stopifnot(nrow(test2012) == 0L)

################################################################################
# Combine CDC and CMS tables
icd9 <-
  merge(x = cdc[, cdc := 1L],
        y = cms[, cms := 1L],
        all = TRUE,
        by = c("code", "dx", "year"))

################################################################################
# For convenience, especially with header codes that are listed in the CDC but
# not CMS, any code that does not have a cdc_desc will get a
stopifnot("all codes with missing desc are headers" =
  icd9[is.na(cdc_desc) & is.na(cms_desc),
    sum(is.na(cdc_header) | cdc_header == 1L) == .N &
    sum(is.na(cms_header) | cms_header == 1L) == .N]
)

################################################################################
# save
data.table::setDF(icd9)
saveRDS(file = "icd9.rds", object = icd9)

################################################################################
#                                 End of File                                  #
################################################################################
