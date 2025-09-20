################################################################################
# file: icd/icd10/cms_icd10_cm_and_pcs.R
#
# purpose: Parse CMS ICD-10-CM and ICD-10-PCS order files from zipped downloads
#          into a unified table.
#
# inputs:
#   cms/cms_*.zip archives containing icd10cm_order_*.txt and
#     icd10pcs_order_*.txt
#
# output: cms_icd10.rds (data.table with code, desc, header, dxpr, fiscal_year,
#         src)
#
# deps: data.table, readxl, pbapply
#
# notes:
#   Run from data-raw/icd/icd10/ with the cms/ zip archives downloaded.
#   Relies on utilities.R::orderfile_to_DT for parsing.
#
# idempotent: yes (deterministic unzip/read/merge)
################################################################################

library(data.table)
library(readxl)
library(pbapply)
source("utilities.R")

################################################################################
# Data from CSM
cms_files <- list.files(path = "cms", pattern = "cms_.*\\.zip", full.name = TRUE)
cms_tempdir <- paste0(tempdir(), "/cms")
dir.create(cms_tempdir, showWarnings = FALSE)
for (f in cms_files) {
  suppressWarnings(unzip(f, exdir = cms_tempdir, overwrite = FALSE))
}

cms_files <- list(
    cms_dx_2026 = "icd10cm_order_2026.txt"
  , cms_dx_2025 = "icd10cm_order_2025.txt"
  , cms_dx_2024 = "icd10cm_order_2024.txt"
  , cms_dx_2023 = "icd10cm_order_2023.txt"
  , cms_dx_2022 = "Code Descriptions/icd10cm_order_2022.txt"
  , cms_dx_2021 = "2021-code-descriptions-tabular-order/icd10cm_order_2021.txt"
  , cms_dx_2020 = "2020 Code Descriptions/icd10cm_order_2020.txt"
  , cms_dx_2019 = "icd10cm_order_2019.txt"
  , cms_dx_2018 = "icd10cm_order_2018.txt"
  , cms_dx_2017 = "icd10cm_order_2017.txt"
  , cms_dx_2016 = "icd10cm_order_2016.txt"
  , cms_dx_2015 = "icd10cm_order_2015.txt"
  , cms_dx_2014 = "icd10cm_order_2014.txt"
  , cms_pr_2026 = "icd10pcs_order_2026.txt"
  , cms_pr_2025 = "icd10pcs_order_2025.txt"
  , cms_pr_2024 = "icd10pcs_order_2024.txt"
  , cms_pr_2023 = "icd10pcs_order_2023.txt"
  , cms_pr_2022 = "icd10pcs_order_2022.txt"
  , cms_pr_2021 = "Zip File 5 2021 ICD-10-PCS Order File (Long and Abbreviated Titles)/icd10pcs_order_2021.txt"
  , cms_pr_2020 = "icd10pcs_order_2020.txt"
  , cms_pr_2019 = "icd10pcs_order_2019.txt"
  , cms_pr_2018 = "icd10pcs_order_2018.txt"
  , cms_pr_2017 = "icd10pcs_order_2017.txt"
  , cms_pr_2016 = "icd10pcs_order_2016.txt"
  , cms_pr_2015 = "icd10pcs_order_2015.txt"
  , cms_pr_2014 = "icd10pcs_order_2014.txt"
  )

cms_files <- lapply(cms_files, function(x) paste0(cms_tempdir, "/", x))
cms_files <- lapply(cms_files, scan,
                    what = "character",
                    sep = "\n",
                    quiet = !interactive())

cms_files <- pblapply(cms_files, orderfile_to_DT, cl = 8L)
cms_files <- rbindlist(cms_files, fill = TRUE, use.names = TRUE, idcol = "src")
cms_files[, code := toupper(code)]

cms_files[, fiscal_year := as.integer(substr(src, start = nchar(src) - 3, stop = nchar(src)))]
cms_files[, dxpr := substr(src, start = 5, stop = 6)]
cms_files[, src := substr(src, start = 1, stop = 3)]

################################################################################
setDF(cms_files)
saveRDS(cms_files, file = "cms_icd10.rds")

################################################################################
#                                 End of File                                  #
################################################################################
