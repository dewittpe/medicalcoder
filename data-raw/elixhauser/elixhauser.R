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

# Check that code-level POA exemption status stays static across AHRQ releases
# whenever a code is mapped by the release and assignable in the corresponding
# CMS fiscal year. Include both exempt and non-exempt values so a 1-to-0
# transition is detected as well as a 0-to-1 transition. AHRQ omits a code from
# an exemption list once it is no longer assignable; that omission is expected
# because the code is no longer valid input for that ICD version. This check
# therefore tests code-level exemption stability only during assignable years,
# not equality of the all-years union with every version-specific AHRQ list.
poaexempt_by_release <- data.table::as.data.table(
  readRDS("./elixhauser_poaexempt_ahrq_icd10.rds")
)
cms_validity <- data.table::as.data.table(
  readRDS("../icd/known_and_assignable_start_stop.rds")
)[src == "cms", .(code_id, assignable_start, assignable_end)]
cms_validity <- unique(cms_validity)

annual_methods <- sub(
  "^poaexempt_", "",
  grep("^poaexempt_ahrq[0-9]{4}$", names(poaexempt_by_release), value = TRUE)
)
stopifnot(length(annual_methods) > 0L)
stopifnot(setequal(annual_methods, grep("^ahrq[0-9]{4}$", names(codes), value = TRUE)))

mapped_by_release <- data.table::melt(
  data = unique(data.table::as.data.table(
    codes[, c("code_id", annual_methods), drop = FALSE]
  )),
  id.vars = "code_id",
  variable.name = "method",
  value.name = "mapped"
)
exempt_by_release <- data.table::melt(
  data = poaexempt_by_release,
  id.vars = "code_id",
  variable.name = "method",
  value.name = "poaexempt"
)
exempt_by_release[, method := sub("^poaexempt_", "", method)]

poaexempt_check <- merge(
  x = mapped_by_release,
  y = exempt_by_release,
  by = c("code_id", "method"),
  all.x = TRUE
)
poaexempt_check[is.na(poaexempt), poaexempt := 0L]
poaexempt_check <- merge(poaexempt_check, cms_validity, by = "code_id", all = FALSE)

poaexempt_check[, year := as.integer(sub("^ahrq", "", method))]

poaexempt_check <- unique(
  poaexempt_check[
    mapped == 1L &
    !is.na(assignable_start) &
    !is.na(assignable_end) &
    assignable_start <= year &
    assignable_end >= year,
    .(code_id, method, year, poaexempt)
  ]
)

poaexempt_status_by_code <- poaexempt_check[
  , .(n_releases = data.table::uniqueN(method), n_statuses = data.table::uniqueN(poaexempt)),
  by = "code_id"
]
poaexempt_comparison_codes <- poaexempt_status_by_code[n_releases > 1L]
if (nrow(poaexempt_comparison_codes) == 0L) {
  stop("No CMS codes mapped in multiple AHRQ releases found for POA exemption check")
}
poaexempt_changes <- poaexempt_comparison_codes[n_statuses > 1L, code_id]
if (length(poaexempt_changes) > 0L) {
  stop(
    "POA exemption status changes across AHRQ releases for mapped, assignable CMS code_id(s): ",
    paste(poaexempt_changes, collapse = ", ")
  )
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
