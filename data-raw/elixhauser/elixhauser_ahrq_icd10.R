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

################################################################################
# import all the SAS Programs for the ICD-10 version of Elixhauser

format_programs <-
  list(
    "ahrq2022" = scan(file = paste0(tmpdir, "/CMR_Format_Program_v2022-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2023" = scan(file = paste0(tmpdir, "/CMR_Format_Program_v2023-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2024" = scan(file = paste0(tmpdir, "/CMR_Format_Program_v2024-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2025" = scan(file = paste0(tmpdir, "/CMR_Format_Program_v2025-1.sas"), what = character(), sep = "\n", quiet = !interactive())
  )

mapping_programs <-
  list(
    "ahrq2022" = scan(file = paste0(tmpdir, "/CMR_Mapping_Program_v2022-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2023" = scan(file = paste0(tmpdir, "/CMR_Mapping_Program_v2023-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2024" = scan(file = paste0(tmpdir, "/CMR_Mapping_Program_v2024-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2025" = scan(file = paste0(tmpdir, "/CMR_Mapping_Program_v2025-1.sas"), what = character(), sep = "\n", quiet = !interactive())
  )

index_programs <-
  list(
    "ahrq2022" = scan(file = paste0(tmpdir, "/CMR_Index_Program_v2022-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2023" = scan(file = paste0(tmpdir, "/CMR_Index_Program_v2023-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2024" = scan(file = paste0(tmpdir, "/CMR_Index_Program_v2024-1.sas"), what = character(), sep = "\n", quiet = !interactive()),
    "ahrq2025" = scan(file = paste0(tmpdir, "/CMR_Index_Program_v2025-1.sas"), what = character(), sep = "\n", quiet = !interactive())
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

build_comfmt <-
  function(x) {
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
  x <- sub('= \\"1\\"', ')', x)
  x <- trimws(x)
  x[1] <- paste("poaexmpt <- c(", x[1])
  x
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

elixhauser_codes[, icdv := 10L]
elixhauser_codes[, dx := 1L]

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

################################################################################
# save to disk
setDF(elixhauser_index_scores)
saveRDS(elixhauser_index_scores, "./elixhauser_index_scores_ahrq_icd10.rds")

setDF(elixhauser_poa)
saveRDS(elixhauser_poa, "./elixhauser_poa_ahrq_icd10.rds")

setDF(elixhauser_codes)
saveRDS(elixhauser_codes, "./elixhauser_codes_ahrq_icd10.rds")

# elixhauser_poaexempt is just a character vector
stopifnot(is.vector(elixhauser_poaexempt), is.character(elixhauser_poaexempt))
saveRDS(elixhauser_poaexempt, "./elixhauser_poaexempt_ahrq_icd10.rds")

################################################################################
#                                 End of File                                  #
################################################################################
