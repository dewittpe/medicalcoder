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
# Create a single data.frame for ICD codes
source("../../R/icd_compact_to_full.R")

icd9  <- readRDS("./icd9/icd9.rds")
icd10 <- readRDS("./icd10/icd10.rds")

data.table::setDT(icd9)
data.table::setDT(icd10)

icd9[, icdv := 9L]
icd9[, full_code := icd_compact_to_full(code, icdv = icdv, dx = dx)]

icd10[, icdv := 10L]
icd10[, full_code := icd_compact_to_full(code, icdv = icdv, dx = dx)]

icd <- data.table::rbindlist(list(icd9, icd10), use.names = TRUE, fill = TRUE)
rm(icd9, icd10)

# Some small clean up of descriptions
for (j in grep("_desc$", names(icd), value = TRUE)) {
  # 1. add a space
  data.table::set(icd, j = j, value = sub('"Light-for-dates"w', '"Light-for-dates" w', icd[[j]]))
  # 2. remove more than one space
  data.table::set(icd, j = j, value = sub(' {2,}', ' ', icd[[j]]))
}

################################################################################
# extract just the codes as a lookup table
icd_codes <- icd[, .(icdv, dx, full_code, code)]
icd_codes <- unique(icd_codes)
data.table::setorder(icd_codes, icdv, dx, code, full_code)
icd_codes[, code_id := seq_len(.N)]

# put the code_id back onto the icd data.frame so it can be used when building
# other tables
icd <- merge(x = icd, y = icd_codes, by = c("icdv", "dx", "full_code", "code"))

################################################################################
# Make a lookup table for the descriptions as well
icd_descs <-
  data.table::melt(
    data = icd,
    id.vars = "code_id",
    measure.vars = grep("_desc$", names(icd), value = TRUE),
    value.name = "desc"
  )

icd_descs <- unique(icd_descs[, "desc", drop = FALSE])
icd_descs <- icd_descs[!is.na(desc)]
data.table::setorder(icd_descs, desc)
icd_descs[, desc_id := seq_len(.N)]

# Now, let's tokenize the desc
pattern <- "(?<=.)(?=[[:space:][:digit:][:punct:]])|(?<=[[:space:][:digit:][:punct:]])(?=.)"
split_desc <- icd_descs[, data.table::tstrsplit(desc, pattern, perl = TRUE)]
split_desc[, desc_id := seq_len(.N)]

tokens <- data.table::melt(split_desc, id.vars = "desc_id", value.name = "token", na.rm = TRUE)
tokens[, variable := NULL]
tokens[, desc_id := NULL]
tokens <- unique(tokens)
tokens[, token_id := seq_len(.N)]

DT <-
  merge(
    x = data.table::melt(split_desc, id.vars = "desc_id", na.rm = TRUE),
    y = tokens,
    all.x = TRUE,
    by.x = "value",
    by.y = "token",
    sort = FALSE
  )
data.table::setkey(DT, desc_id, variable)

icd_desc_token_ids <- split(DT[["token_id"]], f = DT[["desc_id"]])
desc_tokens <- tokens[["token"]]

################################################################################
# Extract the CM and PCS (CMS) variants
cms <- icd[cms == 1L, .(code_id, year, header = cms_header, desc = cms_desc)]
cms <- cms[, .(start = min(year, na.rm = TRUE), end = max(year, na.rm = TRUE)), by = .(code_id, desc, header)]
cms <- merge(cms, icd_descs, all.x = TRUE, by = "desc")
cms[, desc := NULL]
cms[, src := "cms"]
data.table::setorder(cms, code_id, header, start, end, desc_id)
data.table::setkey(cms, code_id, desc_id)

# Extract the WHO releases
who <- icd[who == 1L, .(code_id, year, header = who_header, desc = who_desc)]
who <- who[, .(start = min(year), end = max(year)), by = .(code_id, desc, header)]
who <- merge(who, icd_descs, all.x = TRUE, by = "desc")
who[, desc := NULL]
who[, src := "who"]
data.table::setorder(who, code_id, header, start, end, desc_id)
data.table::setkey(who, code_id, desc_id)

# Extract the CDC mortality codes
cdc <- icd[cdc == 1L, .(code_id, year, header = cdc_header, desc = cdc_desc)]
cdc <- cdc[, .(start = min(year), end = max(year)), by = .(code_id, desc, header)]
cdc <- merge(cdc, icd_descs, all.x = TRUE, by = "desc")
cdc[, desc := NULL]
cdc[, src := "cdc"]
data.table::setorder(cdc, code_id, header, start, end, desc_id)
data.table::setkey(cdc, code_id, desc_id)

# Extract the ICD-10-AM codes from IHACPA
ihacpa <- icd[ihacpa == 1L, .(code_id, year, header = ihacpa_header, desc = ihacpa_desc)]
ihacpa <- ihacpa[, .(start = min(year), end = max(year)), by = .(code_id, desc, header)]
ihacpa <- merge(ihacpa, icd_descs, all.x = TRUE, by = "desc")
ihacpa[, desc := NULL]
ihacpa[, src := "ihacpa"]
data.table::setorder(ihacpa, code_id, header, start, end, desc_id)
data.table::setkey(ihacpa, code_id, desc_id)

# Extract the ICD-10-SE
socialstyrelsen <- icd[socialstyrelsen == 1L, .(code_id, year, header = socialstyrelsen_header, desc = socialstyrelsen_desc)]
socialstyrelsen <- socialstyrelsen[, .(start = min(year), end = max(year)), by = .(code_id, desc, header)]
socialstyrelsen <- merge(socialstyrelsen, icd_descs, all.x = TRUE, by = "desc")
socialstyrelsen[, desc := NULL]
socialstyrelsen[, src := "socialstyrelsen"]
data.table::setorder(socialstyrelsen, code_id, header, start, end, desc_id)
data.table::setkey(socialstyrelsen, code_id, desc_id)

# stack up the ICD sources and build the
# known_start, known_end, assignable_start, assignable_end columns
icd_srcs <- data.table::rbindlist(list(cms, who, cdc, ihacpa, socialstyrelsen))

k <- icd_srcs[,                .(known_start      = min(start), known_end      = max(end)), keyby = .(code_id, src)]
a <- icd_srcs[header == 0,     .(assignable_start = min(start), assignable_end = max(end)), keyby = .(code_id, src)]
d <- icd_srcs[!is.na(desc_id), .(desc_start       = min(start), desc_end       = max(end)), keyby = .(code_id, desc_id, src)]

ka <- merge(x = k, y = a, all = TRUE)

ka[, src := factor(src, levels = c("cms", "cdc", "ihacpa", "socialstyrelsen", "who"))]
d[, src := factor(src, levels = c("cms", "cdc", "ihacpa", "socialstyrelsen", "who"))]
data.table::setorder(ka, code_id, src)
data.table::setorder(d, code_id, desc_id, src)

################################################################################
# chapters and subchapters
icd_chapters <-
  data.table::fread(
    sep = ";",
    header = TRUE,
    strip.white = TRUE,
    na.strings = "",
    colClass = c("integer", "integer", rep("character", 6)),
    file = "icd_chapters_subchapters.dat"
  )

data.table::set(icd_codes, j = "chapter",    value = NA_character_)
data.table::set(icd_codes, j = "subchapter", value = NA_character_)

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
data.table::setorder(icd_chapters, chapter)
icd_chapters[, chap_id := seq_len(.N)]

icd_subchapters <- icd_codes[!is.na(subchapter), unique(.SD), .SDcols = "subchapter"]
stopifnot(!any(is.na(icd_subchapters[["subchapter"]])))
data.table::setorder(icd_subchapters, subchapter)
icd_subchapters[, subchap_id := seq_len(.N)]

stopifnot(icd_codes[icdv ==  9L & dx == 1L & is.na(subchapter)][, .N == 0L])
stopifnot(icd_codes[icdv ==  9L & dx == 0L & !is.na(subchapter)][, .N == 0L])

# TODO - update and add subchapters
#icd_codes[icdv == 10L & dx == 1L & is.na(subchapter)]
#icd_codes[icdv == 10L & dx == 0L & is.na(subchapter)]

# replace the chapter and subchapter strings with ids in icd_codes
icd_codes <- merge(icd_codes, icd_chapters, all.x = TRUE, by = "chapter")
data.table::set(icd_codes, j = "chapter", value = NULL)

icd_codes <- merge(icd_codes, icd_subchapters, all.x = TRUE, by = "subchapter")
data.table::set(icd_codes, j = "subchapter", value = NULL)
data.table::setorder(icd_codes, code_id)

################################################################################
# Save to disk
data.table::setDF(icd_codes)
data.table::setDF(icd_descs)
data.table::setDF(ka)
data.table::setDF(d)
data.table::setDF(icd_chapters)
data.table::setDF(icd_subchapters)

saveRDS(icd_codes,          file = "icd_codes.rds")
#saveRDS(icd_descs,          file = "icd_descs.rds")
saveRDS(desc_tokens,        file = "desc_tokens.rds")
saveRDS(icd_desc_token_ids, file = "icd_desc_token_ids.rds")
saveRDS(ka,                 file = "known_and_assignable_start_stop.rds")
saveRDS(d,                  file = "desc_start_stop.rds")
saveRDS(icd_chapters,       file = "icd_chapters.rds")
saveRDS(icd_subchapters,    file = "icd_subchapters.rds")

################################################################################
#                                 End of File                                  #
################################################################################
