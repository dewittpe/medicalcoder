################################################################################
# file: icd/icd10/cms_icd10_cm_and_pcs.R
#
# purpose: Parse CMS ICD-10-CM and ICD-10-PCS order files from zipped downloads
#          into a unified table.
#
# inputs:
#   cms-releases.tsv selects cms/cms_*.zip archives containing
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
# Only manifest-selected archives participate. Read the selected ZIP member
# directly: October and April archives can share filenames without collisions.
releases <- read.delim("cms-releases.tsv", stringsAsFactors = FALSE)
stopifnot(!anyDuplicated(releases[c("year", "dxpr")]))
cms_files <- lapply(seq_len(nrow(releases)), function(i) {
  read_order_archive(releases$archive[i], releases$member[i])
})
names(cms_files) <- paste("cms", releases$dxpr, releases$year, sep = "_")

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
