################################################################################
# file: elixhauser/elixhauser_ahrq_icd10.R
#
# purpose: Ingest AHRQ ICD-10 Elixhauser kit (versions 2022-2025) to build code
#          flags, POA rules, and index weights.
#
# inputs:
#   ahrq/CMR_v2022-1.zip
#   ahrq/CMR_v2023-1.zip
#   ahrq/CMR_v2024-1.zip
#   ahrq/CMR_v2025.1.zip
#   ahrq/CMR-v2026-1.zip
#   ../icd/icd_codes.rds
#
# output:
#
#   elixhauser_index_scores_ahrq_icd10.rds:
#     a data.frame with the readmission/mortality index score for each condition
#     by ahrqYYYY
#
#   elixhauser_codes_ahrq_icd10.rds:
#     a data.frame mapping ICD-10 codes to conditions with 0/1 indicators for
#     each ahrqYYYY
#
#   elixhauser_poa_ahrq_icd10.rds:
#     a data.frame with the ahrqYYYY columns indicating if the condition is
#     requires POA or not
#
# deps: data.table, readxl
#
# notes:
#   Unzips AHRQ releases into tempdir(), parses SAS programs and reference
#   workbooks
#
# idempotent: yes (deterministic once source archives are fixed)
################################################################################
library(data.table)
requireNamespace("readxl")
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
  unzip("ahrq/CMR-v2026-1.zip", list = TRUE)  # AHRQ based on ICD-10
}

unzip("ahrq/CMR_v2022-1.zip", exdir = tmpdir)
unzip("ahrq/CMR_v2023-1.zip", exdir = tmpdir)
unzip("ahrq/CMR_v2024-1.zip", exdir = tmpdir)
unzip("ahrq/CMR_v2025.1.zip", exdir = tmpdir, junkpaths = TRUE)
unzip("ahrq/CMR-v2026-1.zip", exdir = tmpdir)

################################################################################
# import all the SAS Programs for the ICD-10 version of Elixhauser

format_programs <-
  list(
    "ahrq2022" = scan(file = file.path(tmpdir, "CMR_Format_Program_v2022-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2023" = scan(file = file.path(tmpdir, "CMR_Format_Program_v2023-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2024" = scan(file = file.path(tmpdir, "CMR_Format_Program_v2024-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2025" = scan(file = file.path(tmpdir, "CMR_Format_Program_v2025-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2026" = scan(file = file.path(tmpdir, "CMR_Format_Program_v2026-1.sas"), what = character(), sep = "\n", quiet = !interactive())
  )

mapping_programs <-
  list(
    "ahrq2022" = scan(file = file.path(tmpdir, "CMR_Mapping_Program_v2022-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2023" = scan(file = file.path(tmpdir, "CMR_Mapping_Program_v2023-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2024" = scan(file = file.path(tmpdir, "CMR_Mapping_Program_v2024-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2025" = scan(file = file.path(tmpdir, "CMR_Mapping_Program_v2025-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2026" = scan(file = file.path(tmpdir, "CMR_Mapping_Program_v2026-1.sas"), what = character(), sep = "\n", quiet = !interactive())
  )

index_programs <-
  list(
    "ahrq2022" = scan(file = file.path(tmpdir, "CMR_Index_Program_v2022-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2023" = scan(file = file.path(tmpdir, "CMR_Index_Program_v2023-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2024" = scan(file = file.path(tmpdir, "CMR_Index_Program_v2024-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2025" = scan(file = file.path(tmpdir, "CMR_Index_Program_v2025-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2026" = scan(file = file.path(tmpdir, "CMR_Index_Program_v2026-1.sas"), what = character(), sep = "\n", quiet = !interactive())
  )

################################################################################
# extract the sas code and build the needed R variables for conditions, ICD
# codes, and POA exempt codes
get_value_start_stop <- function(fp) {
  values <- grep(fp, pattern = "Value \\$")
  start  <- values + 1
  stop   <- c(values[-1] - 1, length(fp))
  values <- sub("(^.+\\$)(.+\\S)\\s*$", "\\2", fp[values])
  strings <- vector(mode = "list", length = length(values))
  for ( i in seq_len(length(values)) ) {
    strings[[i]] <- fp[start[i]:stop[i]]
  }
  data.table::data.table(value = values, start, stop, strings)
}

values <-
  lapply(format_programs, get_value_start_stop) |>
  rbindlist(idcol = "version")

build_comfmt <- function(x) {
  x <- sub(pattern = '=', replacement = "->", x)
  x <- sub(pattern = '-> \\"(.+)\\"', replacement = ") -> \\1;", x = x)
  strt <- grep("->", x) + 1
  x[1] <- paste("c(", x[1])
  x[strt] <- paste("c(", x[strt])
  other_idx <- grep("other", x)
  x <- x[-seq(other_idx, length(x))]
  tmpfile <- tempfile()
  cat(x, file = tmpfile)
  e <- new.env()
  source(tmpfile, local = e)
  as.list(e)
}

build_poaexmpt <- function(x) {
  other_idx <- grep("other", x)
  x <- x[-seq(other_idx, length(x))]
  # for 2022 - 2025 the last element ended with "1"
  # for 2026 the last element ended with '1'
  # Change from double quotes to single quotes.
  x <- sub('= \\"1\\"', ')', x)
  x <- sub("= '1'", ')', x)
  x <- trimws(x)
  x[1] <- paste("poaexmpt <- c(", x[1])
  tmpfile <- tempfile()
  cat(x, file = tmpfile)
  e <- new.env()
  source(tmpfile, local = e)
  as.list(e)
}

values[, obj := strings]

for (i in seq_len(nrow(values))) {
  if (values[["value"]][i] == "COMFMT") {
    data.table::set(values, i = i, j = "obj", value = list(build_comfmt(x = values[["strings"]][[i]])))
  } else {
    data.table::set(values, i = i, j = "obj", value = list(build_poaexmpt(x = values[["strings"]][[i]])))
  }
}

# build a data.table for the elixhauser_codes
elixhauser_codes <-
  setNames(
    values[value == "COMFMT"][["obj"]],
    values[value == "COMFMT"][["version"]]
  )

elixhauser_codes <-
  lapply(elixhauser_codes,
    function(x) {
      rbindlist(
        lapply(names(x), function(nm) { data.table(condition = nm, code = x[[nm]]) })
      )
    })

elixhauser_codes <- rbindlist(elixhauser_codes, idcol = "version")
elixhauser_codes[, dummy := 1L]

elixhauser_codes <-
  dcast(
    data = elixhauser_codes,
    formula = condition + code ~ version,
    value.var = "dummy",
    fill = 0L
  )

# poa exempt
elixhauser_poaexempt <- values[value != "COMFMT"]
elixhauser_poaexempt[, strings := NULL]
elixhauser_poaexempt[, start := NULL]
elixhauser_poaexempt[, stop := NULL]
elixhauser_poaexempt <-
  split(elixhauser_poaexempt, by = c("version", "value")) |>
    lapply(function(x) {
      y <-
        data.table(
          version = x$version,
          value   = x$value,
          code    = x[["obj"]][[1]]
          )
      y
    }) |>
  rbindlist()

elixhauser_poaexempt <- unique(elixhauser_poaexempt$code)

# add a poaexmpt column to elixhauser_codes
elixhauser_codes[, poaexempt := as.integer(code %in% elixhauser_poaexempt)]

# add a "ever" column, that is, ahrq_icd10, which is 1 if the icd was every part
# of the standard
elixhauser_codes[, ahrq_icd10 := as.integer(rowSums(.SD) > 0), .SDcols = patterns("^ahrq\\d{4}$")]

# use the code_id for the ICD codes
elixhauser_codes <-
  merge(x = elixhauser_codes,
    y = icd_codes[icdv == 10L & dx == 1L],
    all.x = TRUE,
    all.y = FALSE,
    by = c("code")
  )

elixhauser_codes <-
  elixhauser_codes[, .SD, .SDcols = patterns("code_id|poaexempt|condition|ahrq")]

################################################################################
# find the LABELS for the conditions
LABELSTART <- lapply(mapping_programs, grep, pattern = "LABEL")
SEMICOLON  <- lapply(mapping_programs, grep, pattern = ";")
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
  Map(function(m, l) {m[l[1]:l[2]]}, m = mapping_programs, l = LABELS) |>
  lapply(gsub, pattern = "LABEL", replacement = "") |>
  lapply(gsub, pattern = ";", replacement = "") |>
  lapply(gsub, pattern = "'", replacement = "") |>
  lapply(gsub, pattern = "CMR_", replacement = "") |>
  lapply(trimws) |>
  lapply(function(x) fread(text = x, sep = "=", header = FALSE)) |>
  rbindlist(idcol = "method")
setnames(LABELS, old = c("V1", "V2"), new = c("condition", "condition_description"))

LABELS[, dummy := 1L]

elixhauser_conditions <-
  dcast(
    LABELS,
    condition + condition_description ~ method,
    value.var = "dummy",
    fill = 0L
  )

################################################################################
# POA Required - conditions that require a POA flag
elixhauser_poa <-
  list("ahrq2022" = readxl::read_xlsx(paste0(tmpdir, "/CMR-Reference-File-v2022-1.xlsx"), sheet = 2, skip = 1),
       "ahrq2023" = readxl::read_xlsx(paste0(tmpdir, "/CMR-Reference-File-v2023-1.xlsx"), sheet = 2, skip = 1),
       "ahrq2024" = readxl::read_xlsx(paste0(tmpdir, "/CMR-Reference-File-v2024-1.xlsx"), sheet = 2, skip = 1),
       "ahrq2025" = readxl::read_xlsx(paste0(tmpdir, "/CMR-Reference-File-v2025-1.xlsx"), sheet = 2, skip = 1),
       "ahrq2026" = readxl::read_xlsx(paste0(tmpdir, "/CMR-Reference-File-v2026-1.xlsx"), sheet = 2, skip = 1)
  )

elixhauser_poa <- lapply(elixhauser_poa, setDT)

for (i in seq_along(elixhauser_poa)) {
  data.table::setnames(elixhauser_poa[[i]], old = names(elixhauser_poa[[j]])[1:3], new = c("condition", "desc", "poa_required"))
  elixhauser_poa[[i]] <- subset(elixhauser_poa[[i]], condition != "End of Content")
  elixhauser_poa[[i]][, poa_required := as.integer(poa_required == "Yes")]
  set(elixhauser_poa[[i]], j = names(elixhauser_poa)[i], value = 1L)
  set(elixhauser_poa[[i]], j = "desc", value = NULL)
}

if (interactive()) {
  lapply(elixhauser_poa, names)
}

elixhauser_poa <-
  Reduce(function(x,y) {
           merge(x, y, all = TRUE, by = c('condition', 'poa_required'))
       },
       x = elixhauser_poa)

elixhauser_poa[, condition := sub("CMR_", "", condition)]

# Extend conditions -- several of the conditions in the elixhauser_poa set are
# catch alls and more granular conditions are in the codes.  Extend the
# elixhauser_poa set to include the more granular conditions
#
# 2026 added a new condition, LIVER_MLD_PULMCIRC
#> qwraps2::set_diff(
#>   elixhauser_codes[ahrq2025 == 1, condition],
#>   elixhauser_codes[ahrq2026 == 1, condition]
#> )
#+ Total number of unique values: 49
#+ Number of elements in both elixhauser_codes[ahrq2025 == 1, condition] and elixhauser_codes[ahrq2026 == 1, condition]: 48
#+ Number of elements only in elixhauser_codes[ahrq2025 == 1, condition]: 0
#+ Number of elements only in elixhauser_codes[ahrq2026 == 1, condition]: 1
#+   unique elements: LIVER_MLD_PULMCIRC

#> qwraps2::set_diff(elixhauser_poa$condition, elixhauser_codes$condition)
#+ Total number of unique values: 50
#+ Number of elements in both elixhauser_poa$condition and elixhauser_codes$condition: 37
#+ Number of elements only in elixhauser_poa$condition: 1
#+   unique elements: CBVD
#+ Number of elements only in elixhauser_codes$condition: 12
#+   unique elements: DRUG_ABUSEPSYCHOSES, CBVD_POA, NEURO_OTH_SEIZ, HFHTN_CX, HTN_CXRENLFL_SEV, HFHTN_CXRENLFL_SEV, LIVER_MLD_PULMCIRC, CBVD_SQLA, CBVD_SQLAPARALYSIS, ALCOHOLLIVER_MLD, LIVER_MLD_NEURO, VALVE_AUTOIMMUNE

elixhauser_poa <-
  rbind(
    elixhauser_poa,
    elixhauser_poa[condition == "ALCOHOL"][, condition := "ALCOHOLLIVER_MLD"],
    elixhauser_poa[condition == "CBVD"][, condition := "CBVD_POA"],
    elixhauser_poa[condition == "CBVD"][, condition := "CBVD_SQLA"],
    elixhauser_poa[condition == "CBVD"][, condition := "CBVD_SQLAPARALYSIS"],
    elixhauser_poa[condition == "DRUG_ABUSE"][, condition := "DRUG_ABUSEPSYCHOSES"],
    elixhauser_poa[condition == "HF"][, condition := "HFHTN_CX"],
    elixhauser_poa[condition == "HF"][, condition := "HTN_CXRENLFL_SEV"],
    elixhauser_poa[condition == "HF"][, condition := "HFHTN_CXRENLFL_SEV"],
    elixhauser_poa[condition == "NEURO_OTH"][, condition := "NEURO_OTH_SEIZ"],
    elixhauser_poa[condition == "AUTOIMMUNE"][, condition := "VALVE_AUTOIMMUNE"],
    elixhauser_poa[condition == "LIVER_MLD"][, condition := "LIVER_MLD_NEURO"],
    elixhauser_poa[condition == "LIVER_MLD"][, condition := "LIVER_MLD_PULMCIRC"]
  )

#> qwraps2::set_diff(elixhauser_poa$condition, elixhauser_codes$condition)
#+ Total number of unique values: 50
#+ Number of elements in both elixhauser_poa$condition and elixhauser_codes$condition: 49
#+ Number of elements only in elixhauser_poa$condition: 1
#+   unique elements: CBVD
#+ Number of elements only in elixhauser_codes$condition: 0

# Under the assumption that the POA required flag is static over the years, then
# the this data structure is not needed and a POA required flag cold just be
# added to the elixhauser_conditions data.frame.  Keep the elixhauser_poa
# data.frame incase there is a change that comes in the in the future.
elixhauser_poa[, ahrq_icd10 := as.integer(rowSums(.SD) > 0), .SDcols = patterns("^ahrq\\d{4}$")]

elixhauser_poa <- unique(elixhauser_poa)

################################################################################
# Index scores
elixhauser_index_scores <-
  index_programs |>
  lapply(grep, pattern = "^\\s*(r|m)w\\w+.*\\d\\s;", value = TRUE) |>
  lapply(sub, pattern = ";", replacement = "") |>
  lapply(strsplit, split = "=") |>
  lapply(lapply, trimws) |>
  lapply(do.call, what = rbind) |>
  lapply(as.data.table)

for (i in seq_along(elixhauser_index_scores)) {
  setnames(
    elixhauser_index_scores[[i]],
    old = c("V1", "V2"),
    new = c("condition", names(elixhauser_index_scores)[i])
  )
}

elixhauser_index_scores <-
  Reduce(
    function(x, y){ merge(x, y, all = TRUE, by = "condition")},
    x = elixhauser_index_scores
  )

elixhauser_index_scores[, index := fifelse(grepl("^rw", condition), "readmission", "mortality")]
elixhauser_index_scores[, condition := sub("^(m|r)w", "", condition)]

for (j in grep("^ahrq\\d{4}", names(elixhauser_index_scores))) {
  set(elixhauser_index_scores, j = j, value = as.integer(elixhauser_index_scores[[j]]))
}

elixhauser_index_scores[, ahrq_icd10 := get(max(grep("ahrq", names(elixhauser_index_scores), value = TRUE)))]

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
