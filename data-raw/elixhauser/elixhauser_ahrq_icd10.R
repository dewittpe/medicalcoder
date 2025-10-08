################################################################################
# file: elixhauser/elixhauser_ahrq_icd10.R
#
# purpose: Ingest AHRQ ICD-10 Elixhauser kit (versions 2022-2025) to build code
#          flags, POA rules, and index weights.
#
# inputs:
#   ahrq/CMR_v2022-1.zip, CMR_v2023-1.zip, CMR_v2024-1.zip, CMR_v2025.1.zip
#   ../icd/icd_codes.rds
#
# output: elixhauser_index_scores_ahrq_icd10.rds, elixhauser_poa_ahrq_icd10.rds,
#         elixhauser_codes_ahrq_icd10.rds
#
# deps: data.table, readxl
#
# notes:
#   Unzips AHRQ releases into tempdir(), parses SAS programs and reference
#     workbooks, and normalises condition labels.
#
# idempotent: yes (deterministic once source archives are fixed)
################################################################################

library(data.table)
library(readxl)
icd_codes <- readRDS("../icd/icd_codes.rds")
setDT(icd_codes)

################################################################################
# unzip the elixhauser source files into a temp directory
tmpdir <- tempdir()

if (interactive()) {
  unzip("ahrq/CMR_v2022-1.zip", list = TRUE)  # AHRQ based on ICD-10
  unzip("ahrq/CMR_v2023-1.zip", list = TRUE)  # AHRQ based on ICD-10
  unzip("ahrq/CMR_v2024-1.zip", list = TRUE)  # AHRQ based on ICD-10
  unzip("ahrq/CMR_v2025.1.zip", list = TRUE)  # AHRQ based on ICD-10
}

unzip("ahrq/CMR_v2022-1.zip", exdir = tmpdir)
unzip("ahrq/CMR_v2023-1.zip", exdir = tmpdir)
unzip("ahrq/CMR_v2024-1.zip", exdir = tmpdir)
unzip("ahrq/CMR_v2025.1.zip", exdir = tmpdir, junkpaths = TRUE)

# NOTE: AHRQ methods based on ICD-9 codes also require the use DRG codes.  I'm
# not building that.  This is consistent with Quan (2005)
#
# From Quan (2005)
#
#> We did not employ the Diagnosis Related Group (DRG) screen option described
#> by Elixhauser [1998] because the objective of this work was to develop
#> algorithms to define comorbidities in undifferentiated hospital discharge
#> data, and to then directly assess how well comorbidities derived from those
#> algorithms predict mortality.
#

################################################################################
# Let's find all the labels for the comorbidities
comorbidities <-
  list(
    "ahrq2022" = scan(file = paste0(tmpdir, "/CMR_Mapping_Program_v2022-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2023" = scan(file = paste0(tmpdir, "/CMR_Mapping_Program_v2023-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2024" = scan(file = paste0(tmpdir, "/CMR_Mapping_Program_v2024-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2025" = scan(file = paste0(tmpdir, "/CMR_Mapping_Program_v2025-1.sas"), what = character(), sep = "\n", quiet = !interactive())
  )

# find the lines between a LABEL and ;
LABELSTART <- lapply(comorbidities, grep, pattern = "LABEL")
SEMICOLON  <- lapply(comorbidities, grep, pattern = ";")
LABELEND   <- LABELSTART

for (j in seq_along(SEMICOLON)) {
  for (i in seq_along(LABELSTART[[j]])) {
    LABELEND[[j]][i] <-
      SEMICOLON[[j]][min(which(SEMICOLON[[j]] - LABELSTART[[j]][i] >= 0))]
  }
}

# it appears that the largest number of lines between LABEL and ; are the
# comorbidities and that these are at the end of each of the lists
LABELS <-
  Map(function(x, y) {
        i <- which.max(y - x)
        c(x[i], y[i])
    }, x = LABELSTART, y = LABELEND)

LABELS <-
  Map(function(c,l) {c[l[1]:l[2]]}, c = comorbidities, l = LABELS) |>
  lapply(gsub, pattern = "LABEL", replacement = "") |>
  lapply(gsub, pattern = ";", replacement = "") |>
  lapply(gsub, pattern = "'", replacement = "") |>
  lapply(gsub, pattern = "CMR_", replacement = "") |>
  lapply(trimws) |>
  lapply(function(x) fread(text = x, sep = "=", header = FALSE)) |>
  rbindlist(idcol = "method")
setnames(LABELS, old = c("V1", "V2"), new = c("comorbidity", "comorbidity_description"))

# clean up some labels and descriptions
LABELS[comorbidity_description == "Deficiency Anemias",
       comorbidity_description := "Deficiency anemias"]
LABELS[comorbidity_description == "Coagulopthy",
       comorbidity_description := "Deficiency anemias"]

LABELS[, dummy:=1L]

LABELS <-
  dcast(LABELS,
        comorbidity + comorbidity_description ~ method,
        value.var = "dummy",
        fill = 0L)

################################################################################
# Index Scores
elixhauser_index_scores <-
  list(
    "ahrq2022" = scan(file = paste0(tmpdir, "/CMR_Index_Program_v2022-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2023" = scan(file = paste0(tmpdir, "/CMR_Index_Program_v2023-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2024" = scan(file = paste0(tmpdir, "/CMR_Index_Program_v2024-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2025" = scan(file = paste0(tmpdir, "/CMR_Index_Program_v2025-1.sas"), what = character(), sep = "\n", quiet = !interactive())
  )

elixhauser_index_scores <-
  elixhauser_index_scores |>
  lapply(grep, pattern = "^\\s*(r|m)w\\w+.*\\d\\s;", value = TRUE) |>
  lapply(sub, pattern = ";", replacement = "") |>
  lapply(strsplit, split = "=") |>
  lapply(lapply, trimws) |>
  lapply(do.call, what = rbind) |>
  lapply(as.data.table)

for (i in seq_along(elixhauser_index_scores)) {
  setnames(elixhauser_index_scores[[i]], old = c("V1", "V2"), new = c("condition", names(elixhauser_index_scores)[i]))
}

elixhauser_index_scores <- Reduce(function(x,y){merge(x, y, all = TRUE, by = "condition")}, x = elixhauser_index_scores)
elixhauser_index_scores[, index := fifelse(grepl("^rw", condition), "readmission", "mortality")]
elixhauser_index_scores[, condition := sub("^(m|r)w", "", condition)]

for (j in grep("^ahrq\\d{4}", names(elixhauser_index_scores))) {
  set(elixhauser_index_scores, j = j, value = as.integer(elixhauser_index_scores[[j]]))
}

################################################################################
# POA
elixhauser_poa <-
  list("ahrq2022" = readxl::read_xlsx(paste0(tmpdir, "/CMR-Reference-File-v2022-1.xlsx"), sheet = 2, skip = 1),
       "ahrq2023" = readxl::read_xlsx(paste0(tmpdir, "/CMR-Reference-File-v2023-1.xlsx"), sheet = 2, skip = 1),
       "ahrq2024" = readxl::read_xlsx(paste0(tmpdir, "/CMR-Reference-File-v2024-1.xlsx"), sheet = 2, skip = 1),
       "ahrq2025" = readxl::read_xlsx(paste0(tmpdir, "/CMR-Reference-File-v2025-1.xlsx"), sheet = 2, skip = 1))

elixhauser_poa <- lapply(elixhauser_poa, setDT)

for (i in seq_along(elixhauser_poa)) {
  names(elixhauser_poa[[i]]) <- c("condition", "desc", "poa_required")
  elixhauser_poa[[i]] <- subset(elixhauser_poa[[i]], condition != "End of Content")
  elixhauser_poa[[i]][, poa_required := as.integer(poa_required == "Yes")]
  set(elixhauser_poa[[i]], j = names(elixhauser_poa)[i], value = 1L)
}

if (interactive()) {
  lapply(elixhauser_poa, names)
}

elixhauser_poa <-
  Reduce(function(x,y) {
           merge(x, y, all = TRUE, by = c('condition', 'desc', 'poa_required'))
       },
       x = elixhauser_poa)

elixhauser_poa[, condition := sub("CMR_", "", condition)]

################################################################################
# import the codes
elixhauser_codes <-
  list(readxl::read_xlsx(paste0(tmpdir, "/CMR-Reference-File-v2022-1.xlsx"), sheet = 3, skip = 1),
       readxl::read_xlsx(paste0(tmpdir, "/CMR-Reference-File-v2023-1.xlsx"), sheet = 3, skip = 1),
       readxl::read_xlsx(paste0(tmpdir, "/CMR-Reference-File-v2024-1.xlsx"), sheet = 3, skip = 1),
       readxl::read_xlsx(paste0(tmpdir, "/CMR-Reference-File-v2025-1.xlsx"), sheet = 3, skip = 1))

elixhauser_codes <- lapply(elixhauser_codes, setDT)

elixhauser_codes <- lapply(elixhauser_codes, subset, `ICD-10-CM Diagnosis` != "End of Content")
elixhauser_codes <- lapply(elixhauser_codes, setnames, old = "ICD-10-CM Diagnosis", new = "code")
elixhauser_codes <- lapply(elixhauser_codes, set, j = "ICD-10-CM Code Description", value = NULL)
elixhauser_codes <- lapply(elixhauser_codes, set, j = "# Comorbidities", value = NULL)

elixhauser_codes <- lapply(elixhauser_codes, melt, id.vars = "code", variable.name = "condition", variable.factor = FALSE)
elixhauser_codes <- lapply(elixhauser_codes, subset, value > 0)

for (i in 1:length(elixhauser_codes)) {
  setnames(elixhauser_codes[[i]], old = "value", new = paste0("ahrq", as.character(2021 + i)))
}

elixhauser_codes <-
  Reduce(f = function(x, y) {
           merge(x, y, all = TRUE, by = c("code", "condition"))
       },
       x = elixhauser_codes
  )

for (j in grep("^ahrq\\d{4}", names(elixhauser_codes), value = TRUE)) {
  set(elixhauser_codes, j = j, value = nafill(elixhauser_codes[[j]], type = "const", fill = 0L))
  set(elixhauser_codes, j = j, value = as.integer(elixhauser_codes[[j]]))
}

elixhauser_codes[, icdv := 10L]
elixhauser_codes[, dx   :=  1L]

elixhauser_codes <-
  merge(x = elixhauser_codes,
        y = icd_codes,
        all.x = TRUE,
        by = c("icdv", "dx", "code"))

elixhauser_codes <- elixhauser_codes[, .SD, .SDcols = patterns("code_id|condition|ahrq")]

################################################################################
# Import codes from the SAS format files
sas_format <-
  list(
    "ahrq22" = scan(file = paste0(tmpdir, "/CMR_Format_Program_v2022-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq23" = scan(file = paste0(tmpdir, "/CMR_Format_Program_v2023-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq24" = scan(file = paste0(tmpdir, "/CMR_Format_Program_v2024-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq25" = scan(file = paste0(tmpdir, "/CMR_Format_Program_v2025-1.sas"), what = character(), sep = "\n", quiet = !interactive())
  )

################################################################################
# save to disk
setDF(elixhauser_index_scores)
saveRDS(elixhauser_index_scores, "./elixhauser_index_scores_ahrq_icd10.rds")

setDF(elixhauser_poa)
saveRDS(elixhauser_poa, "./elixhauser_poa_ahrq_icd10.rds")

setDF(elixhauser_codes)
saveRDS(elixhauser_codes, "./elixhauser_codes_ahrq_icd10.rds")

################################################################################
#                                 End of File                                  #
################################################################################
