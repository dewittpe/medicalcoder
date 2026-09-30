################################################################################
# file: elixhauser/elixhauser.R
#
# purpose: Merge Quan (2005) and AHRQ ICD-10 Elixhauser resources into unified
#          code, index, and POA lookup tables.
#
# inputs:
#   ./elixhauser_codes_quan2005.rds           -- includes ahrq_web (ICD-9)
#   ./elixhauser_codes_ahrq_icd10.rds         -- ICD-10
#   ./elixhauser_index_scores_quan2005.rds
#   ./elixhauser_index_scores_ahrq_icd10.rds
#   ./elixhauser_poa_ahrq_icd10.rds
#   ./elixhauser_poaexempt_ahrq_icd10.rds
#   ../icd/known_and_assignable_start_stop.rds
#
# output:
#   elixhauser_codes.rds
#   elixhauser_index_scores.rds
#   elixhauser_poa.rds: public condition-level POA requirement table. One row
#     per condition/poa_required rule, annual method columns indicate which
#     AHRQ releases use that rule, and ahrq_icd10 marks rules used by any
#     included annual release.
#
# deps: base R
#
# notes:
#   Prefixes method columns with elixhauser_ for consistency across package
#     datasets.
#
# idempotent: yes (deterministic merges)
################################################################################
index <-
  list("./elixhauser_index_scores_quan2005.rds",
       "./elixhauser_index_scores_ahrq_icd10.rds") |>
  lapply(readRDS) |>
  Reduce(function(x, y) { merge(x, y, all = TRUE, by = c("condition", "index"))},
         x = _)

codes <-
  list("./elixhauser_codes_quan2005.rds",
       "./elixhauser_codes_ahrq_icd10.rds") |>
  lapply(readRDS) |>
  Reduce(function(x, y) { merge(x, y, all = TRUE, by = c("code_id", "condition")) },
         x = _)

# set column order
codes <- codes[,
  c("code_id", "poaexempt", "condition",
  "ahrq_web",
  "elixhauser1998",
  "quan2005",
  sort(grep("ahrq\\d{4}", names(codes), value = TRUE)),
  "ahrq_icd10")]

# Which conditions require a POA-required flag?
# This isn't needed for the codes defined in Quan (2005).
poa <- readRDS("./elixhauser_poa_ahrq_icd10.rds")

# Check the unioned exemption flag against each annual release for codes that
# are mapped by that release and valid in the corresponding CMS fiscal year.
# Use known validity rather than assignability: AHRQ mapping membership is the
# relevant criterion.
poaexempt_by_release <- data.table::as.data.table(
  readRDS("./elixhauser_poaexempt_ahrq_icd10.rds")
)
cms_validity <- data.table::as.data.table(
  readRDS("../icd/known_and_assignable_start_stop.rds")
)[src == "cms", .(code_id, known_start, known_end)]
cms_validity <- unique(cms_validity)

annual_methods <- sub(
  "^poaexempt_", "",
  grep("^poaexempt_ahrq[0-9]{4}$", names(poaexempt_by_release), value = TRUE)
)
stopifnot(length(annual_methods) > 0L)
stopifnot(setequal(annual_methods, grep("^ahrq[0-9]{4}$", names(codes), value = TRUE)))

poaexempt_check <- merge(
  x = data.table::as.data.table(codes[, c("code_id", annual_methods), drop = FALSE]),
  y = poaexempt_by_release,
  by = "code_id",
  all = FALSE
)
poaexempt_check <- merge(poaexempt_check, cms_validity, by = "code_id", all = FALSE)

for (method in annual_methods) {
  year <- as.integer(sub("^ahrq", "", method))
  exemption_method <- paste0("poaexempt_", method)
  idx <-
    !is.na(poaexempt_check[[method]]) &
    poaexempt_check[[exemption_method]] == 1L &
    !is.na(poaexempt_check[["known_start"]]) &
    !is.na(poaexempt_check[["known_end"]]) &
    poaexempt_check[["known_start"]] <= year &
    poaexempt_check[["known_end"]] >= year
  if (!any(idx)) stop("No mapped CMS codes found for POA exemption check in ", method)
  if (!all(poaexempt_check[["poaexempt"]][idx] == poaexempt_check[[exemption_method]][idx])) {
    stop("Union POA exemption differs for mapped CMS codes in ", method)
  }
}

################################################################################
# Prefix all method columns with elixhauser_
names(index)[which(grepl("ahrq|elixhauser|quan", names(index)))] <-
  paste0("elixhauser_",
         names(index)[which(grepl("ahrq|elixhauser|quan", names(index)))])

names(codes)[which(grepl("ahrq|elixhauser|quan", names(codes)))] <-
  paste0("elixhauser_",
         names(codes)[which(grepl("ahrq|elixhauser|quan", names(codes)))])

names(poa)[which(grepl("ahrq|elixhauser|quan", names(poa)))] <-
  paste0("elixhauser_",
         names(poa)[which(grepl("ahrq|elixhauser|quan", names(poa)))])

# `elixhauser_ahrq_icd10` is the any-release union for this condition-level
# table, matching the combined code mapping. `poa_required` itself stays
# paired with its method-membership column so release-specific rules are kept.

################################################################################
# Save data
saveRDS(codes, "./elixhauser_codes.rds")
saveRDS(index, "./elixhauser_index_scores.rds")
saveRDS(poa,   "./elixhauser_poa.rds")

################################################################################
#                                 End of File                                  #
################################################################################
