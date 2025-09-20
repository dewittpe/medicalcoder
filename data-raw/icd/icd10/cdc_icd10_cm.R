################################################################################
# file: icd/icd10/cdc_icd10_cm.R
#
# purpose: Extract CDC ICD-10-CM order-file releases into a normalized table
#          with fiscal year and dx/pr flags.
#
# inputs:
#   ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10CM/** (order files
#     for FY2014-FY2026)
#
# output: cdc_icd10.rds (data.table with code, desc, header, dxpr, fiscal_year,
#         src)
#
# deps: data.table, pbapply
#
# notes:
#   Run from data-raw/icd/icd10/; expects the ftp.cdc.gov directory tree
#     downloaded locally.
#   Uses utilities.R::orderfile_to_DT; unzip targets are written to tempdir().
#
# idempotent: yes (recreates the same table given the same source zips)
################################################################################

library(data.table)
library(pbapply)
source("utilities.R")

################################################################################
# Yearly data from CDC
cdc_icd10cm_dir <- "ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10CM"
cdc_tempdir <- paste0(tempdir(), "/cdc")
dir.create(cdc_tempdir, showWarnings = FALSE)

if (interactive()) {
  dir(cdc_icd10cm_dir)
}

######
# 2007
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2007"))
  unzip(paste0(cdc_icd10cm_dir, "/2007/2007_Dxgem.zip"), list = TRUE)
  unzip(paste0(cdc_icd10cm_dir, "/2007/i10drugtbl0707.zip"), list = TRUE)
  unzip(paste0(cdc_icd10cm_dir, "/2007/i10idx0707.zip"), list = TRUE)
}

unzip(paste0(cdc_icd10cm_dir, "/2007/2007_Dxgem.zip"),
      exdir = paste0(cdc_tempdir, "/2007"),
      overwrite = TRUE)

######
# 2008 - no data

######
# 2009
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2009"))
  unzip(paste0(cdc_icd10cm_dir, "/2009/Dxgem2009b.zip"), list = TRUE)
}

unzip(paste0(cdc_icd10cm_dir, "/2009/Dxgem2009b.zip"),
      exdir = paste0(cdc_tempdir, "/2009"),
      overwrite = TRUE)

######
# 2010
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2010"))
  unzip(paste0(cdc_icd10cm_dir, "/2010/2010_DiagnosisGEMs.zip"), list = TRUE)
}

unzip(paste0(cdc_icd10cm_dir, "/2010/2010_DiagnosisGEMs.zip"),
      exdir = paste0(cdc_tempdir, "/2010"),
      overwrite = TRUE)

######
# 2011
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2011"))
  unzip(paste0(cdc_icd10cm_dir, "/2011/ICD10CMdescriptions_2011.zip"), list = TRUE)
}

unzip(paste0(cdc_icd10cm_dir, "/2011/ICD10CMdescriptions_2011.zip"),
      exdir = paste0(cdc_tempdir, "/2011"),
      overwrite = TRUE)

######
# 2012
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2012"))
  unzip(paste0(cdc_icd10cm_dir, "/2012/ICD10_Desc_OrderFiles_2012.zip"), list = TRUE)
}

unzip(paste0(cdc_icd10cm_dir, "/2012/ICD10_Desc_OrderFiles_2012.zip"),
      exdir = paste0(cdc_tempdir, "/2012"),
      overwrite = TRUE)

######
# 2013
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2013"))
  unzip(paste0(cdc_icd10cm_dir, "/2013/ICD10CM_Desc_OrderFiles_2013.zip"), list = TRUE)
}

unzip(paste0(cdc_icd10cm_dir, "/2013/ICD10CM_Desc_OrderFiles_2013.zip"),
      exdir = paste0(cdc_tempdir, "/2013"),
      overwrite = TRUE)

######
# 2014
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2014"))
  unzip(paste0(cdc_icd10cm_dir, "/2014/ICD10CM-FY2014_OrderFiles.zip"), list = TRUE)
}

unzip(paste0(cdc_icd10cm_dir, "/2014/ICD10CM-FY2014_OrderFiles.zip"),
      exdir = paste0(cdc_tempdir, "/2014"),
      overwrite = TRUE)

######
# 2015
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2015"))
  unzip(paste0(cdc_icd10cm_dir, "/2015/ICD10CM_FY2015_code_descriptions.zip"), list = TRUE)
}

unzip(paste0(cdc_icd10cm_dir, "/2015/ICD10CM_FY2015_code_descriptions.zip"),
      exdir = paste0(cdc_tempdir, "/2015"),
      overwrite = TRUE)

######
# 2016
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2016"))
  unzip(paste0(cdc_icd10cm_dir, "/2016/ICD10CM_FY2016_code_descriptions.zip"), list = TRUE)
}

unzip(paste0(cdc_icd10cm_dir, "/2016/ICD10CM_FY2016_code_descriptions.zip"),
      exdir = paste0(cdc_tempdir, "/2016"),
      overwrite = TRUE)

######
# 2017
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2017"))
}

######
# 2018
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2018"))
  unzip(paste0(cdc_icd10cm_dir, "/2018/2018-ICD-10-CM-Codes-File.zip"), list = TRUE)
  unzip(paste0(cdc_icd10cm_dir, "/2018/2018-ICD-10-Code-Order-Descriptions.zip"), list = TRUE)
}

unzip(paste0(cdc_icd10cm_dir, "/2018/2018-ICD-10-Code-Order-Descriptions.zip"),
      exdir = paste0(cdc_tempdir, "/2018"),
      overwrite = TRUE)

######
# 2019
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2019"))
  # nothing to unzip
}

######
# 2020
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2020"))
  # nothing to unzip
}

######
# 2021
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2021"))
  # nothing to unzip
}

######
# 2022
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2022"))
  # nothing to unzrip
}

######
# 2023
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2023"))
  unzip(paste0(cdc_icd10cm_dir, "/2023/icd10-Order-CodeFiles2023.zip"), list = TRUE)
}

unzip(paste0(cdc_icd10cm_dir, "/2023/icd10-Order-CodeFiles2023.zip"),
      exdir = paste0(cdc_tempdir, "/2023"),
      overwrite = TRUE)

######
# 2024
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2024"))
  unzip(paste0(cdc_icd10cm_dir, "/2024/icd10cm-CodesDescriptions-2024.zip"), list = TRUE)
}

unzip(paste0(cdc_icd10cm_dir, "/2024/icd10cm-CodesDescriptions-2024.zip"),
      exdir = paste0(cdc_tempdir, "/2024"),
      overwrite = TRUE)

######
# 2025
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2025"))
  unzip(paste0(cdc_icd10cm_dir, "/2025/ICD10-CM Code Descriptions 2025.zip"), list = TRUE)
}

unzip(paste0(cdc_icd10cm_dir, "/2025/ICD10-CM Code Descriptions 2025.zip"),
      exdir = paste0(cdc_tempdir, "/2025"),
      overwrite = TRUE)

######
# 2026
if (interactive()) {
  dir(paste0(cdc_icd10cm_dir, "/2026"))
  unzip(paste0(cdc_icd10cm_dir, "/2026/icd10cm-Code Descriptions-2026.zip"), list = TRUE)
}

unzip(paste0(cdc_icd10cm_dir, "/2026/icd10cm-Code Descriptions-2026.zip"),
      exdir = paste0(cdc_tempdir, "/2026"),
      overwrite = TRUE)

################################################################################
# scan all the files - Just for 2014 and beyond, the same as for CMS
cdc_files <-
  list(
       #cdc_dx_2007 = paste0(cdc_tempdir, "/2007/2007_I10desc.txt"),
       # no 2008 data
       #cdc_dx_2009 = paste0(cdc_tempdir, "/2009/I10cm_desc.txt"),
       #cdc_dx_2010 = paste0(cdc_tempdir, "/2010/I10cm_desc2010.txt"),
       #cdc_dx_2011 = paste0(cdc_tempdir, "/2011/icd10cm_desc_2011.txt"),
       #cdc_dx_2012 = paste0(cdc_tempdir, "/2012/icd10cm_order_2012.txt"),
       #cdc_dx_2013 = paste0(cdc_tempdir, "/2013/icd10cm_order_2013.txt"),
       cdc_dx_2014 = paste0(cdc_tempdir, "/2014/icd10cm_order_2014.txt"),
       cdc_dx_2015 = paste0(cdc_tempdir, "/2015/icd10cm_order_2015.txt"),
       cdc_dx_2016 = paste0(cdc_tempdir, "/2016/icd10cm_order_2016.txt"),
       cdc_dx_2017 = paste0(cdc_icd10cm_dir, "/2017/icd10cm_order_2017.txt"),
       cdc_dx_2018 = paste0(cdc_tempdir, "/2018/icd10cm_order_2018.txt"),
       cdc_dx_2019 = paste0(cdc_icd10cm_dir, "/2019/icd10cm_order_2019.txt"),
       cdc_dx_2020 = paste0(cdc_icd10cm_dir, "/2020/icd10cm_order_2020.txt"),
       cdc_dx_2021 = paste0(cdc_icd10cm_dir, "/2021/icd10cm_order_2021.txt"),
       cdc_dx_2022 = paste0(cdc_icd10cm_dir, "/2022/icd10cm_order_2022.txt"),
       cdc_dx_2023 = paste0(cdc_tempdir, "/2023/icd10cm-order-2023.txt"),
       cdc_dx_2024 = paste0(cdc_tempdir, "/2024/icd10cm-order-2024.txt"),
       cdc_dx_2025 = paste0(cdc_tempdir, "/2025/icd10cm-order-2025.txt"),
       cdc_dx_2026 = paste0(cdc_tempdir, "/2026/icd10cm-order-2026.txt")
      ) |>
  lapply(scan, what = "character", sep = "\n", quiet = !interactive())

cdc_files <- pblapply(cdc_files, orderfile_to_DT, cl = 8L)
cdc_files <- rbindlist(cdc_files, fill = TRUE, use.names = TRUE, idcol = "src")
cdc_files[, code := toupper(code)]

cdc_files[, fiscal_year := as.integer(substr(src, start = nchar(src) - 3, stop = nchar(src)))]
cdc_files[, dxpr := substr(src, start = 5, stop = 6)]
cdc_files[, src := substr(src, start = 1, stop = 3)]

################################################################################
setDF(cdc_files)
saveRDS(cdc_files, file = "cdc_icd10.rds")

################################################################################
#                                 End of File                                  #
################################################################################
