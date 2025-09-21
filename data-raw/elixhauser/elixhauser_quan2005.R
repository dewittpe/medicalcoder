################################################################################
# file: elixhauser/elixhauser_quan2005.R
#
# purpose: Generate Elixhauser comorbidity code flags and index scores following
#          Quan (2005).
#
# inputs:
#   ../icd/icd_codes.rds
#   regex_based_on_quan2005.txt
#   ./ahrq/comindex2012-2015.txt
#
# output: elixhauser_codes_quan2005.rds, elixhauser_index_scores_quan2005.rds
#
# deps: data.table, pbapply
#
# notes:
#   Expands Quan regex patterns across ICD-9 and ICD-10 code sets and maps to
#     code_id.
#   Weights borrow from the AHRQ web release for continuity with historical
#     toolkits.
#
# idempotent: yes (deterministic pipeline)
################################################################################

library(pbapply)
library(data.table)
icd_codes <- readRDS("../icd/icd_codes.rds")
setDT(icd_codes)

################################################################################
# Regular expressions for codes reported in Table 2 of Quan (2005) could be used
# here for the ICD-9 and an ICD-10 version of Elixhauser
regex_patterns <- fread(file = "regex_based_on_quan2005.txt")
regex_patterns <- split(regex_patterns, f = 1:nrow(regex_patterns))

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
  pblapply(regex_patterns,
           function(x) {
             data.table(x,
                        full_code = get_codes(pattern = x[["pattern"]], dx = x[["dx"]], icdv = x[["icdv"]])
             )
           }
           , cl = 8L
  )

if (any(sapply(codes, nrow) == 0)) {
  print(regex_patterns[which(sapply(codes, nrow) == 0L)])
  warning("regex with no matches")
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
codes <-
  merge(x = codes,
        y = icd_codes,
        all.x = TRUE,
        by = c("icdv", "dx", "full_code"))

codes <- unique(codes)

codes[, dummy := 1L]
codes <-
  dcast(codes,
        code_id + condition ~ method,
        value.var = "dummy",
        fill = 0L)

################################################################################
# Weights for these methods will be based on ahrq refernce data
index_scores <-
  list("ahrq_web" = scan(file = "./ahrq/comindex2012-2015.txt",  what = character(), sep = "\n", quiet = !interactive())) |>
  lapply(grep, pattern = "^\\s*(r|m)w\\w+.*\\d\\s;", value = TRUE) |>
  lapply(sub, pattern = ";", replacement = "") |>
  lapply(strsplit, split = "=") |>
  lapply(lapply, trimws) |>
  lapply(do.call, what = rbind) |>
  lapply(as.data.table)

for (i in seq_along(index_scores)) {
  setnames(index_scores[[i]], old = c("V1", "V2"), new = c("condition", names(index_scores)[i]))
}

index_scores <- Reduce(function(x,y){merge(x, y, all = TRUE, by = "condition")}, x = index_scores)
index_scores[, index := fifelse(grepl("^rw", condition), "readmission", "mortality")]
index_scores[, condition := sub("^(m|r)w", "", condition)]

for (j in grep("^ahrq", names(index_scores))) {
  set(index_scores, j = j, value = as.integer(index_scores[[j]]))
}

# to make coding easier when building the index scores duplicate the index score
# column with the method names
index_scores[, elixhauser1988 := ahrq_web]
index_scores[, quan2005       := ahrq_web]

################################################################################
# save to disk
setDF(index_scores)
saveRDS(index_scores, "./elixhauser_index_scores_quan2005.rds")

setDF(codes)
saveRDS(codes, "./elixhauser_codes_quan2005.rds")

################################################################################
#                                 End of File                                  #
################################################################################
