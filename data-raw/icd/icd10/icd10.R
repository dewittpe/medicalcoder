################################################################################
# file: icd/icd10/icd10.R
#
# purpose: Join CDC, WHO, and CMS ICD-10 tables into a single lookup for package
#          data.
#
# inputs:
#   cdc_allvalid.rds
#   who_icd10.rds
#   icd10_cm_pcs.rds
#
# output: icd10.rds (data.frame with merged mortality and CM/PCS metadata)
#
# deps: data.table
#
# notes:
#   Run after generating mortality and CM/PCS intermediates under data-
#     raw/icd/icd10/.
#
# idempotent: yes (pure joins and save)
################################################################################
library(data.table)

cdc_allvalid <- readRDS("./cdc_allvalid.rds")
who_icd10    <- readRDS("./who_icd10.rds")
cm_pcs_icd10 <- readRDS("./icd10_cm_pcs.rds")

setDT(cdc_allvalid)
setDT(who_icd10)
setDT(cm_pcs_icd10)

who_icd10[, dx := 1L]
cdc_allvalid[, dx := 1L]

icd10 <-
  merge(
    x = cdc_allvalid[, .(code, dx, calendar_year = year, cdc_mortality_desc = desc, cdc_mortality_header = header)],
    y = who_icd10[,    .(code, dx, calendar_year,                  who_desc = desc,           who_header = header)],
    all = TRUE,
    by = c("code", "dx", "calendar_year")
  )

icd10 <-
  merge(
    x = icd10,
    y = cm_pcs_icd10[, .(code, dx, fiscal_year, cm_pcs_desc, cm_pcs_header)],
    all = TRUE,
    by.x = c("code", "dx", "calendar_year"),
    by.y = c("code", "dx", "fiscal_year")
  )

################################################################################
setDF(icd10)
saveRDS(icd10, file = "icd10.rds")

################################################################################
#                                 End of File                                  #
################################################################################
