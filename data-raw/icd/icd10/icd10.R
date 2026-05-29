################################################################################
# file: icd/icd10/icd10.R
#
# purpose: Join CDC, WHO, and CMS ICD-10 tables into a single lookup for package
#          data.
#
# inputs:
#   cdc_allvalid.rds
#   who_icd10.rds
#   cms_icd10.rds
#   ihacpa_icd10.rds
#
# output: icd10.rds (data.frame with merged cdc cms and who data)
#
# deps: data.table
#
# notes:
#   Run after generating CDC, WHO and CMS intermediates under data-raw/icd/icd10/
#
# idempotent: yes (pure joins and save)
################################################################################
cdc_allvalid <- readRDS("./cdc_allvalid.rds")
who_icd10    <- readRDS("./who_icd10.rds")
cms_icd10    <- readRDS("./cms_icd10.rds")
ihacpa_icd10 <- readRDS("./ihacpa_icd10.rds")

data.table::setDT(cdc_allvalid)
data.table::setDT(who_icd10)
data.table::setDT(cms_icd10)
data.table::setDT(ihacpa_icd10)

who_icd10[, dx := 1L]
cdc_allvalid[, dx := 1L]
ihacpa_icd10[, dx := 1L]

icd10 <-
  merge(
    x = cdc_allvalid[, .(cdc = 1L, code, dx, year, cdc_desc = desc, cdc_header = header)],
    y = who_icd10[,    .(who = 1L, code, dx, year, who_desc = desc, who_header = header)],
    all = TRUE,
    by = c("code", "dx", "year")
  )

icd10 <-
  merge(
    x = icd10,
    y = cms_icd10[, .(cms = 1L, code, dx, year, cms_desc, cms_header)],
    all = TRUE,
    by.x = c("code", "dx", "year"),
    by.y = c("code", "dx", "year")
  )

icd10 <-
  merge(
    x = icd10,
    y = ihacpa_icd10[, .(ihacpa = 1L, code, dx, year, ihacpa_desc = description, ihacpa_header = header)],
    all = TRUE,
    by.x = c("code", "dx", "year"),
    by.y = c("code", "dx", "year")
  )

################################################################################
data.table::setDF(icd10)
saveRDS(icd10, file = "icd10.rds")

################################################################################
#                                 End of File                                  #
################################################################################
