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
#
# output: elixhauser_codes.rds, elixhauser_index_scores.rds, elixhauser_poa.rds
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

# a POA required flag isn't needed for the codes defined in Quan (2005).
poa <- readRDS("./elixhauser_poa_ahrq_icd10.rds")

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

################################################################################
# Save data
saveRDS(codes, "./elixhauser_codes.rds")
saveRDS(index, "./elixhauser_index_scores.rds")
saveRDS(poa,   "./elixhauser_poa.rds")

################################################################################
#                                 End of File                                  #
################################################################################
