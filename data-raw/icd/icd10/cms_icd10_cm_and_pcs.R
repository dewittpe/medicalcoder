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
# output: cms_icd10.rds (data.table with code, desc, header, dx, year,
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
source("utilities.R")

################################################################################
# Data from CMS
cms_files <- list.files(path = "cms", pattern = "cms_.*\\.zip", full.name = TRUE)
cms_tempdir <- file.path(tempdir(), "/cms")
dir.create(cms_tempdir, showWarnings = FALSE)
for (f in cms_files) {
  suppressWarnings(unzip(f, exdir = cms_tempdir, junkpaths = TRUE, overwrite = FALSE))
}

if (interactive()) {
  dir(cms_tempdir)
}

cms_files <-
  list(
      cms_dx_2026 = "icd10cm_order_2026.txt"
    , cms_dx_2025 = "icd10cm_order_2025.txt"
    , cms_dx_2024 = "icd10cm_order_2024.txt"
    , cms_dx_2023 = "icd10cm_order_2023.txt"
    , cms_dx_2022 = "icd10cm_order_2022.txt"
    , cms_dx_2021 = "icd10cm_order_2021.txt"
    , cms_dx_2020 = "icd10cm_order_2020.txt"
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
    , cms_pr_2021 = "icd10pcs_order_2021.txt"
    , cms_pr_2020 = "icd10pcs_order_2020.txt"
    , cms_pr_2019 = "icd10pcs_order_2019.txt"
    , cms_pr_2018 = "icd10pcs_order_2018.txt"
    , cms_pr_2017 = "icd10pcs_order_2017.txt"
    , cms_pr_2016 = "icd10pcs_order_2016.txt"
    , cms_pr_2015 = "icd10pcs_order_2015.txt"
    , cms_pr_2014 = "icd10pcs_order_2014.txt"
  )

cms_files <- lapply(cms_files, function(x) file.path(cms_tempdir, x))

cms_files <-
  lapply(
    cms_files,
    scan,
    what = "character",
    sep = "\n",
    quiet = !interactive()
  )

cms_files <- pbapply::pblapply(cms_files, orderfile_to_DT, cl = 8L)
cms_files <- data.table::rbindlist(cms_files, fill = TRUE, use.names = TRUE, idcol = "src")
cms_files[, code := toupper(code)]

cms_files[, year := as.integer(substr(src, start = nchar(src) - 3, stop = nchar(src)))]
cms_files[, dxpr := substr(src, start = 5, stop = 6)]
cms_files[, src := substr(src, start = 1, stop = 3)]
cms_files[, dx := as.integer(dxpr == "dx")]

data.table::setnames(
  cms_files,
  old = c("header", "desc"),
  new = c("cms_header", "cms_desc")
)

################################################################################
# check headers

# Procedure codes: all headers are three digits, all other codes are seven
# digits
stopifnot(
  cms_files[dx == 0 & cms_header == 1, all(nchar(code) == 3L)],
  cms_files[dx == 0 & cms_header == 0, all(nchar(code) == 7L)]
)

# diagnostic codes are all three, four, five, six, or seven characters
stopifnot(
  cms_files[dx == 1, sort(unique(nchar(code))) == c(3L, 4L, 5L, 6L, 7L)]
)

# correctly marked headers
dxheaders <- data.table::copy(cms_files)
dxheaders <- dxheaders[dx == 1L]

# get the parts of each code
dxheaders[nchar(code) >= 3, d3 := substr(code, 1, 3)]
dxheaders[nchar(code) >= 4, d4 := substr(code, 1, 4)]
dxheaders[nchar(code) >= 5, d5 := substr(code, 1, 5)]
dxheaders[nchar(code) >= 6, d6 := substr(code, 1, 6)]
dxheaders[nchar(code) >= 7, d7 := substr(code, 1, 7)]

# if d3 appears once, it is not a header, if d3 appears more than once it is a
# header.  Similar for d4, d5, d6, and d7
dxheaders[, d3n := .N, by = .(year, d3)]
dxheaders[, d4n := .N, by = .(year, d4)]
dxheaders[, d5n := .N, by = .(year, d5)]
dxheaders[, d6n := .N, by = .(year, d6)]
dxheaders[, d7n := .N, by = .(year, d7)]

stopifnot(
  dxheaders[d3n == 1L, all(cms_header == 0L)],
  dxheaders[d3n >  1L, all(cms_header >= 0L)],
  dxheaders[d4n == 1L, all(cms_header == 0L)],
  dxheaders[d4n >  1L, all(cms_header >= 0L)],
  dxheaders[d5n == 1L, all(cms_header == 0L)],
  dxheaders[d5n >  1L, all(cms_header >= 0L)],
  dxheaders[d6n == 1L, all(cms_header == 0L)],
  dxheaders[d6n >  1L, all(cms_header >= 0L)],
  dxheaders[d7n == 1L, all(cms_header == 0L)],
  dxheaders[d7n >  1L, all(cms_header >= 0L)]
)

################################################################################
data.table::setDF(cms_files)
saveRDS(cms_files, file = "cms_icd10.rds")

################################################################################
#                                 End of File                                  #
################################################################################
