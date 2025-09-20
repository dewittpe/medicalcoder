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
# output: icd9_cm_pcs.rds (data.table with code, dxpr, fiscal_year, cm_pcs_desc,
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

library(data.table)
cdc <- readRDS(file = "cdc.rds")
cms <- readRDS(file = "cms.rds")
setDT(cdc)
setDT(cms)

################################################################################
# Look for differences between codes from CDC and CMS by fiscal_year
#
# This is focused only on the codes themselves, not the descriptions.
cdc_codes <- cdc[, .(code, dxpr, fiscal_year, src = "cdc", dummy = 1L)]
cms_codes <- cms[, .(code, dxpr, fiscal_year, src = "cms", dummy = 1L)]

# if there are dupliated codes dcast will give a warning.  For this work that
# needs to be an error
old_warn <- options()$warn
options(warn = 2)
allcodes <-
  dcast(rbindlist(list(cdc_codes, cms_codes), use.name = TRUE),
        code + dxpr ~ paste(src, fiscal_year, sep = "_"),
        value.var = "dummy")
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
#stopifnot(nrow(test2013) == 0L)
#stopifnot(nrow(test2014) == 0L)
#stopifnot(nrow(test2015) == 0L)

################################################################################
# As one data set
icd9 <-
  merge(x = cdc,
        y = cms,
        all = TRUE,
        by = c("code", "dxpr", "fiscal_year"))

################################################################################
# HEADERS
#
# look for headers in the dx codes.
# 001 is a header becuase 001.0 exists
# 001.0 is not a header becuase no code with five digits starting with 0010
# exist, that is, 001.0 is a non-header code
#
# 003 is header because 0032 exists
# 0032 is a header because 00320, 00321, ... exists
#
# For procedure codes you
#   10   - header
#   102  - header
#   1021 - non-header
#
# Header status can chage from year to year
#
# Denote header.  codes from the WHO may not have the same level of granulatity.
# Header is a reasonable name for the column.  All codes (ICD-10) include things
# for reporting mortality which are not non-header codes the way CMS might
# consider them.

# verify that the codes are the lenght expected
stopifnot(icd9[dxpr == "pr", all(nchar(code) %in% 2:4)])
stopifnot(icd9[dxpr == "dx", all(nchar(code) %in% 3:5)])

icd9[nchar(code) == 5L & dxpr == "dx", `:=`(h4 = substr(code, 1, 4), h3 = substr(code, 1, 3))]
icd9[nchar(code) == 4L & dxpr == "dx", `:=`(h3 = substr(code, 1, 3))]

icd9[nchar(code) == 4L & dxpr == "pr", `:=`(h3 = substr(code, 1, 3), h2 = substr(code, 1, 2))]
icd9[nchar(code) == 3L & dxpr == "pr", `:=`(h2 = substr(code, 1, 2))]

headers <- icd9[!is.na(h2) | !is.na(h3) | !is.na(h4), .(code, h2, h3, h4, dxpr, fiscal_year)]
headers <- unique(headers)

icd9[headers, header := 1L, on = c("code" = "h2", 'dxpr', 'fiscal_year')]
icd9[headers, header := 1L, on = c("code" = "h3", 'dxpr', 'fiscal_year')]
icd9[headers, header := 1L, on = c("code" = "h4", 'dxpr', 'fiscal_year')]

# all the codes that have not yet been matched are not-headers
icd9[, header := nafill(header, type = 'const', fill = 0L)]
set(icd9, j = "h2", value = NULL)
set(icd9, j = "h3", value = NULL)
set(icd9, j = "h4", value = NULL)


################################################################################
# Simplify Descriptions

setnames(icd9, old = "long_desc", new = "cms_desc")
setnames(icd9, old = "desc", new = "cdc_desc")
icd9[, short_desc := NULL]

# For conveniece, especially with header codes which are listed in the CDC but
# not CMS, any code that does not have a cdc_desc will get a
stopifnot("all codes with missing desc are headers" = icd9[is.na(cdc_desc) & is.na(cms_desc), sum(header) == .N])

# data.table does not support last observation carried forward for non-numeric
# vectors
setkey(icd9, code, dxpr, fiscal_year)
icd9[, cdc_desc := zoo::na.locf(cdc_desc), by = .(code, dxpr)]

# there are a few codes with missing cdc but non-missing cms
if (interactive()) {
  icd9[, .N, keyby = .(missing_cdc = is.na(cdc_desc), missing_cms = is.na(cms_desc))]
  icd9[is.na(cdc_desc) & is.na(cms_desc)]
  icd9[is.na(cdc_desc) & !is.na(cms_desc)] |> print(nrow = Inf)
  icd9[code == "148" & dxpr == "pr", .(code, dxpr, cdc_desc, cms_desc)] |> unique() |> print(nrow = Inf)
}

# a header code introduced in 2014
icd9[code == "148" & dxpr == "pr", cms_desc := "Operations on epiretinal visual prosthesis"]

# check
stopifnot("all codes have a desc" = icd9[is.na(cdc_desc) & is.na(cms_desc), .N == 0L])

################################################################################
# Special edits??
#
# 043 and 044 were retired in FY 1994 but are listed as part of the
# Carlson comorbidities
#
# 042 was valid FY 1987 through FY 2015
# 042.0, 042.1, 042.2, 042.9 from FY87 - FY94
# 043 from FY87 - FY94
# 044 from FY87 - FY94
#
#icd9_dx_codes[grepl("^04[2-4]\\.[0-2,9]", code)]
#icd9_dx_descs[grepl("^04[2-4]\\.[0-2,9]", code)]

################################################################################
# A sanity check
#
# ICD-9-CM code 719.7 had fifth digits [0,5-9] through FY 2003.  In FY 2004 the
# fifth digits were removed and the four digit code was no longer a header
stopifnot(
  icd9[code == "7197",
       all(
         (fiscal_year <= 2003 & header == 1) |
         (fiscal_year >  2003 & header == 0)
       )]
 ,
 icd9[grepl("^7197\\d$", code),
      all(
        (fiscal_year <= 2003 & header == 0) |
        (fiscal_year >  2003 & header == 1)
      )]
 )

################################################################################
# build a single cm_pcs_desc and cm_pcs_header
icd9[, cm_pcs_desc := fcoalesce(cms_desc, cdc_desc)]
set(icd9, j = "cdc_desc", value = NULL)
set(icd9, j = "cms_desc", value = NULL)
setnames(icd9, old = "header", new = "cm_pcs_header")

################################################################################
# save
setDF(icd9)
saveRDS(file = "icd9_cm_pcs.rds", object = icd9)

################################################################################
#                                 End of File                                  #
################################################################################
