################################################################################
# file: charlson/charlson.R
#
# purpose: Construct Charlson comorbidity code tables and associated index
#          weights from published references.
#
# inputs:
#   ../icd/icd_codes.rds
#   ./deyo1992.txt, ./cdmf2019.txt, ./quan2005.txt (regex pattern definitions)
#   ./charlson.txt (condition weights)
#
# output: charlson_codes.rds, charlson_index_scores.rds
#
# deps: data.table, pbapply, qwraps2
#
# notes:
#   Expands regex patterns across ICD universes and harmonises method-specific
#     indicator columns.
#
# idempotent: yes (deterministic transformations)
################################################################################

library(pbapply)
library(data.table)
icd_codes <- readRDS("../icd/icd_codes.rds")
setDT(icd_codes)

################################################################################
# Import the regex patterns for finding all relevant codes
regex_patterns <-
  list(
    "./deyo1992.txt",
    "./cdmf2019.txt",
    "./quan2005.txt"
  ) |>
  lapply(fread, header = TRUE) |>
  rbindlist()
regex_patterns <- split(regex_patterns, f = 1:nrow(regex_patterns))

################################################################################
# get_codes
get_codes <- function(pattern, dx, icdv) {
  idx <- icd_codes[["icdv"]] == icdv
  idx <- idx & (icd_codes[["dx"]] == dx)
  idx <- idx & grepl(pattern, icd_codes[["full_code"]])
  if (any(idx)) {
    cds <- icd_codes[idx, full_code]
  } else {
    cds <- character(0)
  }
  cds
}

# get the set of ever billable codes that match the regex
codes <-
  pblapply(
    regex_patterns,
    function(x) {
      data.table(x,
        full_code = get_codes(pattern = x[["pattern"]], dx = x[["dx"]], icdv = x[["icdv"]])
      )
    },
    cl = min(parallel::detectCores(logical = FALSE), length(regex_patterns))
  )

if (any(sapply(codes, nrow) == 0)) {
  print(regex_patterns[which(sapply(codes, nrow) == 0L)])
  warning("regex with no matches")
  #grep("^I982", who_dx$code, value = TRUE)
  # F05.1 and I98.2 are in the WHO standard and not in the ICD-10-CM standard.
}

codes <- rbindlist(codes)
codes[, pattern := NULL]
codes <- unique(codes)

idx <- duplicated(codes) | duplicated(codes, fromLast = TRUE)
if (any(idx)) {
  codes[idx]
  stop("duplicated rows in codes")
}

stopifnot(!any(is.na(codes[["condition_number"]])))
stopifnot(!any(is.na(codes[["icdv"]])))
stopifnot(!any(is.na(codes[["dx"]])))
stopifnot(!any(is.na(codes[["method"]])))
stopifnot(!any(is.na(codes[["full_code"]])))

# get the compact codes to use as well
charlson_codes <-
  merge(x = codes,
        y = icd_codes[, .(icdv, dx, full_code, code, code_id)],
        all.x = TRUE,
        by = c("icdv", "dx", "full_code"))

charlson_codes <- unique(charlson_codes)

charlson_codes[, icdv := NULL]
charlson_codes[, dx := NULL]
charlson_codes[, full_code := NULL]
charlson_codes[, code := NULL]

################################################################################
# to reduce data size and for consistency with other data sets, have the
# "method" as indicator columns, that is, go from this long format to a wider
# format
#
# as of 7 May 2025 and R version 4.5.0 on MacOS (intel)
#
# object.size(charlson_codes)
#
#   In the format as built above:   1325144 bytes
#   After widening:                 1146704 bytes
#   After adding additional column: 1184208 bytes
#   After factor(condition):        1147544 bytes -- Not worth the headache
#   refactor, 28 May 2025            205304 bytes
#   4 June 2025                      210824 bytes -- with the copy of quan2011

charlson_codes[, dummy := 1L]
charlson_codes <-
  dcast(charlson_codes,
        code_id + condition ~ method,
        value.var = "dummy",
        fill = 0L)

# To make coding easier add another column for quan and have them as quan2005 and
# quan2011 to match with the index scores and the methods that are used on the
# comorbidity function.  To the best of my understanding, the codes are the same
# between quan2005 and quan2011.  The index scores are different.
charlson_codes[, quan2011 := quan2005]

################################################################################
# import scores and prep to match codes
charlson_index_scores <-
  fread(file = "./charlson.txt", header = TRUE)

# Note about the size of this object
#
# As of 7 May 2025, R v4.5.0, MacOS (intel)
#
# object.size(charlson_index_scores)
#
# Asis:                    5800 bytes
# after factor(condition): 6376 bytes -- bigger and not worth the headache
#
# charlson_index_scores[, condition := factor(condition, levels = levels(charlson_codes$condition))]

################################################################################
# some sanity checks
#
# all the conditions in the codes are in the index scores and visa versa
stopifnot(all(charlson_index_scores$condition %in% charlson_codes$condition))
stopifnot(all(charlson_codes$condition %in% charlson_index_scores$condition))

stopifnot(
  qwraps2::set_diff(
    subset(charlson_codes, cdmf2019 == 1)[["condition"]]
    ,
    subset(charlson_index_scores, !is.na(cdmf2019))[["condition"]]
  )$equal
)

stopifnot(
  qwraps2::set_diff(
    subset(charlson_codes, quan2005 == 1)[["condition"]]
    ,
    subset(charlson_index_scores, !is.na(quan2005))[["condition"]]
  )$equal
)

stopifnot(
  qwraps2::set_diff(
    subset(charlson_codes, quan2011 == 1)[["condition"]]
    ,
    subset(charlson_index_scores, !is.na(quan2011))[["condition"]]
  )$equal
)

stopifnot(
  qwraps2::set_diff(
    subset(charlson_codes, deyo1992 == 1)[["condition"]]
    ,
    subset(charlson_index_scores, !is.na(deyo1992))[["condition"]]
  )$equal
)

################################################################################
# add the "charlson_" prefix to the method names for consistency across the PCCC
# and Elixhauser sets
for (j in names(charlson_codes)) {
  if (!(j %in% c("code_id", "icdv", "dx", "full_code", "code", "condition"))) {
    setnames(charlson_codes, old = j, new = paste0("charlson_", j))
  }
}
for (j in names(charlson_index_scores)) {
  if (!(j %in% c("condition", "condition_description"))) {
    setnames(charlson_index_scores, old = j, new = paste0("charlson_", j))
  }
}

################################################################################
# save to disk
setDF(charlson_codes)
saveRDS(charlson_codes, "./charlson_codes.rds")
setDF(charlson_index_scores)
saveRDS(charlson_index_scores, "./charlson_index_scores.rds")

################################################################################
#                                 End of File                                  #
################################################################################
