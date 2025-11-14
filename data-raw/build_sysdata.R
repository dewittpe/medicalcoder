################################################################################
# file: build_sysdata.R
#
# purpose: Bundle prebuilt ICD, PCCC, Charlson, and Elixhauser lookup tables
#          into internal package data (R/sysdata.rda) for fast, base-R-only
#          access at runtime.
#
# inputs (relative to data-raw/):
#   ./icd/icd_codes.rds
#   ./icd/icd_descs.rds
#   ./icd/icd_chapters.rds
#   ./icd/icd_subchapters.rds
#   ./icd/known_and_assignable_start_stop.rds
#   ./icd/desc_start_stop.rds
#   ./pccc/pccc_codes.rds
#   ./pccc/pccc_conditions.rds
#   ./charlson/charlson_codes.rds
#   ./charlson/charlson_index_scores.rds
#   ./elixhauser/elixhauser_index_scores.rds
#   ./elixhauser/elixhauser_poa.rds
#   ./elixhauser/elixhauser_codes.rds
#
# output:  R/sysdata.rda (internal package data created via usethis::use_data)
#
# deps:    base (readRDS), usethis (use_data)
#
# notes:   Must be run with working directory set to data-raw/ so relative paths
#          resolve. Overwrites existing R/sysdata.rda.
#
# idempotent: yes (pure read of inputs; deterministic write with overwrite = TRUE)
#
################################################################################

# ICD data sets
..mdcr_internal_icd_codes.. <- readRDS("./icd/icd_codes.rds")
..mdcr_internal_icd_descs.. <- readRDS("./icd/icd_descs.rds")
..mdcr_internal_icd_chapters.. <- readRDS("./icd/icd_chapters.rds")
..mdcr_internal_icd_subchapters.. <- readRDS("./icd/icd_subchapters.rds")
..mdcr_internal_known_and_assignable_start_stop.. <- readRDS("./icd/known_and_assignable_start_stop.rds")
..mdcr_internal_desc_start_stop.. <- readRDS("./icd/desc_start_stop.rds")

# PCCC data sets
..mdcr_internal_pccc_codes.. <- readRDS("./pccc/pccc_codes.rds")
..mdcr_internal_pccc_conditions.. <- readRDS("./pccc/pccc_conditions.rds")

# Charlson Data sets
..mdcr_internal_charlson_codes..        <- readRDS("./charlson/charlson_codes.rds")
..mdcr_internal_charlson_index_scores.. <- readRDS("./charlson/charlson_index_scores.rds")

# Elixhauser Data Sets
..mdcr_internal_elixhauser_index_scores.. <- readRDS("./elixhauser/elixhauser_index_scores.rds")
..mdcr_internal_elixhauser_poa..          <- readRDS("./elixhauser/elixhauser_poa.rds")
..mdcr_internal_elixhauser_codes..        <- readRDS("./elixhauser/elixhauser_codes.rds")

usethis::use_data(
    ..mdcr_internal_pccc_codes..
  , ..mdcr_internal_pccc_conditions..

  , ..mdcr_internal_icd_codes..
  , ..mdcr_internal_icd_descs..
  , ..mdcr_internal_icd_chapters..
  , ..mdcr_internal_icd_subchapters..
  , ..mdcr_internal_known_and_assignable_start_stop..
  , ..mdcr_internal_desc_start_stop..

  , ..mdcr_internal_charlson_codes..
  , ..mdcr_internal_charlson_index_scores..

  , ..mdcr_internal_elixhauser_index_scores..
  , ..mdcr_internal_elixhauser_poa..
  , ..mdcr_internal_elixhauser_codes..

  , internal  = TRUE
  , overwrite = TRUE
)

tools::resaveRdaFiles("../R/sysdata.rda", compress = "xz", compression_level = 9)

################################################################################
#                                 End of File                                  #
################################################################################
