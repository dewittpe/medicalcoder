################################################################################
# file: icd/icd10/icd10_cm_pcs.R
#
# purpose: Combine CMS and CDC ICD-10-CM/PCS extracts, reconcile header flags,
#          and harmonize descriptions.
#
# inputs:
#   cdc_icd10.rds (from cdc_icd10_cm.R)
#   cms_icd10.rds (from cms_icd10_cm_and_pcs.R)
#
# output: icd10_cm_pcs.rds (data.table with code, dx, fiscal_year, cm_pcs_desc,
#         cm_pcs_header)
#
# deps: data.table
#
# notes:
#   Assumes CDC and CMS intermediates exist in this directory.
#   Header derivation rebuilds parent codes to guard against source
#     inconsistencies.
#
# idempotent: yes (deterministic merge and post-processing)
################################################################################

################################################################################
# create one data.frame for icd codes
library(data.table)
cdc_icd10 <- readRDS("./cdc_icd10.rds")
cms_icd10 <- readRDS("./cms_icd10.rds")

setDT(cdc_icd10)
setDT(cms_icd10)

cdc_icd10[, dx := as.integer(dxpr == "dx")]
cms_icd10[, dx := as.integer(dxpr == "dx")]

icd10_cm_pcs <-
  merge(
    x = cms_icd10[, .(code, dx, fiscal_year, cms_desc = desc, cms_header = header)],
    y = cdc_icd10[, .(code, dx, fiscal_year, cdc_desc = desc, cdc_header = header)],
    all = TRUE,
    by = c("code", "dx", "fiscal_year")
  )

# The headers come from the source files, let's rebuild
stopifnot(
  icd10_cm_pcs[dx == 1, all(nchar(code) %in% 3:7)],
  icd10_cm_pcs[dx == 0, all(nchar(code) %in% c(3, 7))]
  )

icd10_cm_pcs[nchar(code) == 4, `:=`(h3 = substr(code, 1, 3))]

icd10_cm_pcs[nchar(code) == 5, `:=`(h3 = substr(code, 1, 3),
                                    h4 = substr(code, 1, 4))]

icd10_cm_pcs[nchar(code) == 6, `:=`(h3 = substr(code, 1, 3),
                                    h4 = substr(code, 1, 4),
                                    h5 = substr(code, 1, 5))]

icd10_cm_pcs[nchar(code) == 7, `:=`(h6 = substr(code, 1, 6),
                                    h5 = substr(code, 1, 5),
                                    h4 = substr(code, 1, 4),
                                    h3 = substr(code, 1, 3))]

headers <- icd10_cm_pcs[!is.na(h3) | !is.na(h4) | !is.na(h5) | !is.na(h6)]
headers <- headers[, .(code, dx, fiscal_year, h3, h4, h5, h6)]

icd10_cm_pcs[headers, cm_pcs_header := 1L, on = c("code" = "h3", "dx", "fiscal_year")]
icd10_cm_pcs[headers, cm_pcs_header := 1L, on = c("code" = "h4", "dx", "fiscal_year")]
icd10_cm_pcs[headers, cm_pcs_header := 1L, on = c("code" = "h5", "dx", "fiscal_year")]
icd10_cm_pcs[headers, cm_pcs_header := 1L, on = c("code" = "h6", "dx", "fiscal_year")]
icd10_cm_pcs[, cm_pcs_header := nafill(cm_pcs_header, type = "const", fill = 0L)]

icd10_cm_pcs[, cms_header := nafill(cms_header, type = "const", fill = 0L)]
icd10_cm_pcs[, cdc_header := nafill(cdc_header, type = "const", fill = 0L)]

# all headers for cms take precedence over cdc
stopifnot(icd10_cm_pcs[, all(cms_header >= cdc_header)])
stopifnot(icd10_cm_pcs[cms_header != cm_pcs_header, .N == 0L])
stopifnot(icd10_cm_pcs[is.na(cms_header), .N == 0L])

set(icd10_cm_pcs, j = "cms_header", value = NULL)
set(icd10_cm_pcs, j = "cdc_header", value = NULL)
set(icd10_cm_pcs, j = "h3", value = NULL)
set(icd10_cm_pcs, j = "h4", value = NULL)
set(icd10_cm_pcs, j = "h5", value = NULL)
set(icd10_cm_pcs, j = "h6", value = NULL)

# simplify desc
icd10_cm_pcs[, cm_pcs_desc := fcoalesce(cms_desc, cdc_desc)]
set(icd10_cm_pcs, j = "cms_desc", value = NULL)
set(icd10_cm_pcs, j = "cdc_desc", value = NULL)

################################################################################
setDF(icd10_cm_pcs)
saveRDS(icd10_cm_pcs, file = "icd10_cm_pcs.rds")

################################################################################
#                                 End of File                                  #
################################################################################
