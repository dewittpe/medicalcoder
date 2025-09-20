################################################################################
# file: icd/icd_codes.R
#
# purpose: Construct unified ICD-9/ICD-10 code tables, description lookup, and
#          chapter mapping artifacts used by the package.
#
# inputs:
#   ./icd9/icd9_cm_pcs.rds
#   ./icd10/icd10.rds
#   icd_chapters_subchapters.dat
#
# output: icd_codes.rds, icd_descs.rds, known_and_assignable_start_stop.rds,
#         desc_start_stop.rds, icd_chapters.rds, icd_subchapters.rds
#
# deps: data.table, ../../R/icd_compact_to_full.R
#
# notes:
#   Run from data-raw/icd/ after generating ICD-9 and ICD-10 intermediates.
#   Assigns integer IDs and consolidates chapter/subchapter metadata for
#     downstream use.
#
# idempotent: yes (deterministic pipeline, overwrites outputs)
################################################################################

################################################################################
# create one data.frame for icd codes
library(data.table)
source("../../R/icd_compact_to_full.R")

icd9 <- readRDS("./icd9/icd9_cm_pcs.rds")
icd10 <- readRDS("./icd10/icd10.rds")

setDT(icd9)
setDT(icd10)

icd9[, icdv := 9L]
icd9[, dx := as.integer(dxpr == "dx")]
icd9[, dxpr := NULL]
icd9[, full_code := icd_compact_to_full(code, icdv = icdv, dx = dx)]

icd10[, icdv := 10L]
icd10[, full_code := icd_compact_to_full(code, icdv = icdv, dx = dx)]

icd <- rbindlist(list(icd9, icd10), use.names = TRUE, fill = TRUE)

# extract just the codes as a lookup table
icd_codes <- icd[, .(icdv, dx, full_code, code)]
icd_codes <- unique(icd_codes)
icd_codes[, code_id := 1:.N]

# put the code_id back onto the icd data.frame so it can be used when building
# other tables
icd <- merge(x = icd, y = icd_codes, by = c("icdv", "dx", "full_code", "code"))

# Make a lookup table for the descriptions as well
# storage size
icd_descs <-
  rbind(icd9[ , .(desc = cm_pcs_desc)],
        icd10[, .(desc = cm_pcs_desc)],
        icd10[, .(desc = who_desc)],
        icd10[, .(desc = cdc_mortality_desc)])
icd_descs <- unique(icd_descs)
icd_descs <- icd_descs[!is.na(desc)]
icd_descs[, desc_id := 1:.N]

# Extract just the CM and PCS version
cms <- icd[ , .(code_id, year = fcoalesce(fiscal_year, calendar_year), header = cm_pcs_header, desc = cm_pcs_desc)]
cms <- cms[!is.na(desc)]
cms <- cms[, .(start = min(year, na.rm = TRUE), end = max(year, na.rm = TRUE)), by = .(code_id, desc, header)]
cms <- merge(cms, icd_descs, by = "desc")
cms[, desc := NULL]
cms[, src := "cms"]
setkey(cms, code_id, desc_id)

# Extract just the WHO
who <- icd[ , .(code_id, year = calendar_year,   header = who_header, desc = who_desc)]
who <- who[!is.na(desc)]
who <- who[, .(start = min(year), end = max(year)), by = .(code_id, desc, header)]
who <- merge(who, icd_descs, by = "desc")
who[, desc := NULL]
who[, src := "who"]
setkey(who, code_id, desc_id)

# Extract just the CDC Mortality Codes
cdc <- icd[ , .(code_id, year = calendar_year,   header = cdc_mortality_header, desc = cdc_mortality_desc)]
cdc <- cdc[!is.na(desc)]
cdc <- cdc[, .(start = min(year), end = max(year)), by = .(code_id, desc, header)]
cdc <- merge(cdc, icd_descs, by = "desc")
cdc[, desc := NULL]
cdc[, src := "cdc"]
setkey(cdc, code_id, desc_id)

# stack up the ICD sources and build the
# known_start, known_end, assignable_start, assignable_end columns
icd_srcs <- rbindlist(list(cms, who, cdc))

k <- icd_srcs[,            .(known_start      = min(start), known_end      = max(end)), keyby = .(code_id, src)]
a <- icd_srcs[header == 0, .(assignable_start = min(start), assignable_end = max(end)), keyby = .(code_id, src)]
d <- icd_srcs[,            .(desc_start       = min(start), desc_end       = max(end)), keyby = .(code_id, desc_id, src)]

ka <- merge(x = k, y = a, all = TRUE)


ka[, src := factor(src, levels = c("cms", "who", "cdc"))]
d[, src := factor(src, levels = c("cms", "who", "cdc"))]

################################################################################
# chapters and subchapters
icd_chapters <-
  fread(sep = ";", header = TRUE, strip.white = TRUE,
        na.strings = "",
        colClass = c("integer", "integer", rep("character", 6)),
        file = "icd_chapters_subchapters.dat")

set(icd_codes, j = "chapter", value = NA_character_)
set(icd_codes, j = "subchapter", value = NA_character_)

for (icdv in c(9L, 10L)) {
  for (dx in c(1L, 0L)) {
    i <- icd_chapters[["icdv"]] == icdv & icd_chapters[["dx"]] == dx
    chaps <- icd_chapters[which(i & !is.na(icd_chapters[["chapter"]])), ]
    subchaps <- icd_chapters[which(i & !is.na(icd_chapters[["subchapter"]])), ]
    code_rows <- which((icd_codes[["icdv"]] == icdv & icd_codes[["dx"]] == dx))
    code_subset <- icd_codes[["code"]][code_rows]

    for (i in 1:nrow(chaps)) {
      m <- which(grepl(x = code_subset, pattern = chaps[["pattern"]][i]))
      icd_codes[["chapter"]][code_rows[m]] <- chaps[["description"]][i]
    }

    if (nrow(subchaps)) {
      for (i in 1:nrow(subchaps)) {
        m <- which(grepl(x = code_subset, pattern = subchaps[["pattern"]][i]))
        icd_codes[["subchapter"]][code_rows[m]] <- subchaps[["description"]][i]
      }
    }

  }
}

icd_chapters <- icd_codes[, unique(.SD), .SDcols = "chapter"]
stopifnot(!any(is.na(icd_chapters[["chapter"]])))
icd_chapters[, chap_id := 1:.N]

icd_subchapters <- icd_codes[!is.na(subchapter), unique(.SD), .SDcols = "subchapter"]
stopifnot(!any(is.na(icd_subchapters[["subchapter"]])))
icd_subchapters[, subchap_id := 1:.N]

stopifnot(icd_codes[icdv ==  9L & dx == 1L & is.na(subchapter)][, .N == 0L])
stopifnot(icd_codes[icdv ==  9L & dx == 0L & !is.na(subchapter)][, .N == 0L])

# TODO - update and add subchapters
#icd_codes[icdv == 10L & dx == 1L & is.na(subchapter)]
#icd_codes[icdv == 10L & dx == 0L & is.na(subchapter)]

# replace the chapter and subchapter strings with ids in icd_codes
icd_codes <- merge(icd_codes, icd_chapters, all.x = TRUE, by = "chapter")
set(icd_codes, j = "chapter", value = NULL)

icd_codes <- merge(icd_codes, icd_subchapters, all.x = TRUE, by = "subchapter")
set(icd_codes, j = "subchapter", value = NULL)





################################################################################
# Save to disk
setDF(icd_codes)
setDF(icd_descs)
setDF(ka)
setDF(d)
setDF(icd_chapters)
setDF(icd_subchapters)

saveRDS(icd_codes,       file = "icd_codes.rds")
saveRDS(icd_descs,       file = "icd_descs.rds")
saveRDS(ka,              file = "known_and_assignable_start_stop.rds")
saveRDS(d,               file = "desc_start_stop.rds")
saveRDS(icd_chapters,    file = "icd_chapters.rds")
saveRDS(icd_subchapters, file = "icd_subchapters.rds")

################################################################################
#                                 End of File                                  #
################################################################################
