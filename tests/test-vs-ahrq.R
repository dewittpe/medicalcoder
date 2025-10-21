################################################################################
# file: test-vs-ahrq.R
#
# objective:
#
#   compare medicalcoder::comorbidities(..., method = "elixhauser_ahrqYYYY")
#   against the official AHRQ SAS mapping results when fixtures are available.
#
################################################################################
source('utilities.R')
suppressPackageStartupMessages({
  library(medicalcoder)
  library(data.table)
  library(R.utils) #needed for data.table::fread to read the .gz files
})

# ahrq results
ahrq_results <- readRDS("expected-ahrq-results.rds")
setDT(ahrq_results)

codes <-
  melt(
    data = ahrq_results,
    id.vars = c("CMR_VERSION", "PATID"),
    measure.vars = paste0("I10_DX", as.character(1:41)),
    value.name = "code"
  )
codes[, primarydx := as.integer(variable == "I10_DX1")]




# apply medicalcoder::comorbidities
common_args <-
  list(
    icd.codes = "code",
    id.vars = c("CMR_VERSION", "PATID"),
    dx = 1,
    icdv = 10,
    poa = 0,
    primarydx.var = "primarydx",
    flag.method = "current"
  )

mdcr_2022 <- do.call(comorbidities, c(common_args, list(data = subset(codes, CMR_VERSION == 2022.1), method = "elixhauser_ahrq2022")))
mdcr_2023 <- do.call(comorbidities, c(common_args, list(data = subset(codes, CMR_VERSION == 2023.1), method = "elixhauser_ahrq2023")))
mdcr_2024 <- do.call(comorbidities, c(common_args, list(data = subset(codes, CMR_VERSION == 2024.1), method = "elixhauser_ahrq2024")))
mdcr_2025 <- do.call(comorbidities, c(common_args, list(data = subset(codes, CMR_VERSION == 2025.1), method = "elixhauser_ahrq2025")))

mdcr_vs_ahrq_2022 <- merge(x = mdcr_2022, y = ahrq_results, all.x = TRUE, by = c("CMR_VERSION", "PATID"))
mdcr_vs_ahrq_2023 <- merge(x = mdcr_2023, y = ahrq_results, all.x = TRUE, by = c("CMR_VERSION", "PATID"))
mdcr_vs_ahrq_2024 <- merge(x = mdcr_2024, y = ahrq_results, all.x = TRUE, by = c("CMR_VERSION", "PATID"))
mdcr_vs_ahrq_2025 <- merge(x = mdcr_2025, y = ahrq_results, all.x = TRUE, by = c("CMR_VERSION", "PATID"))

stopifnot("same number of rows" = nrow(mdcr_2022) == nrow(ahrq_results[CMR_VERSION == 2022.1]) & nrow(mdcr_2022) == nrow(mdcr_vs_ahrq_2022))
stopifnot("same number of rows" = nrow(mdcr_2023) == nrow(ahrq_results[CMR_VERSION == 2022.1]) & nrow(mdcr_2023) == nrow(mdcr_vs_ahrq_2023))
stopifnot("same number of rows" = nrow(mdcr_2024) == nrow(ahrq_results[CMR_VERSION == 2022.1]) & nrow(mdcr_2024) == nrow(mdcr_vs_ahrq_2024))
stopifnot("same number of rows" = nrow(mdcr_2025) == nrow(ahrq_results[CMR_VERSION == 2022.1]) & nrow(mdcr_2025) == nrow(mdcr_vs_ahrq_2025))

# check each condition - this can change year to year
cnds_2022 <- subset(get_elixhauser_index_scores(), !is.na(elixhauser_ahrq2022), select = "condition", drop = TRUE)
cnds_2022 <- unique(cnds_2022)

cnds_2023 <- subset(get_elixhauser_index_scores(), !is.na(elixhauser_ahrq2023), select = "condition", drop = TRUE)
cnds_2023 <- unique(cnds_2023)

cnds_2024 <- subset(get_elixhauser_index_scores(), !is.na(elixhauser_ahrq2024), select = "condition", drop = TRUE)
cnds_2024 <- unique(cnds_2024)

cnds_2025 <- subset(get_elixhauser_index_scores(), !is.na(elixhauser_ahrq2025), select = "condition", drop = TRUE)
cnds_2025 <- unique(cnds_2025)

for (j in cnds_2022) {
  t <- identical(mdcr_vs_ahrq_2022[[j]], mdcr_vs_ahrq_2022[[paste0("CMR_", j)]])
  if (!t) {
    stop(sprintf('identical(mdcr_vs_ahrq_2022[["%s"]], mdcr_vs_ahrq_2022[["%s"]]) is not true', j, paste0("CMR_", j)))
  }
}

for (j in cnds_2023) {
  t <- identical(mdcr_vs_ahrq_2023[[j]], mdcr_vs_ahrq_2023[[paste0("CMR_", j)]])
  if (!t) {
    stop(sprintf('identical(mdcr_vs_ahrq_2023[["%s"]], mdcr_vs_ahrq_2023[["%s"]]) is not true', j, paste0("CMR_", j)))
  }
}

for (j in cnds_2024) {
  t <- identical(mdcr_vs_ahrq_2024[[j]], mdcr_vs_ahrq_2024[[paste0("CMR_", j)]])
  if (!t) {
    stop(sprintf('identical(mdcr_vs_ahrq_2024[["%s"]], mdcr_vs_ahrq_2024[["%s"]]) is not true', j, paste0("CMR_", j)))
  }
}

for (j in cnds_2025) {
  t <- identical(mdcr_vs_ahrq_2025[[j]], mdcr_vs_ahrq_2025[[paste0("CMR_", j)]])
  if (!t) {
    stop(sprintf('identical(mdcr_vs_ahrq_2025[["%s"]], mdcr_vs_ahrq_2025[["%s"]]) is not true', j, paste0("CMR_", j)))
  }
}

stopifnot(mdcr_vs_ahrq_2022[["mortality_index"]]   == mdcr_vs_ahrq_2022[["CMR_Index_Mortality"]])
stopifnot(mdcr_vs_ahrq_2022[["readmission_index"]] == mdcr_vs_ahrq_2022[["CMR_Index_Readmission"]])

stopifnot(mdcr_vs_ahrq_2023[["mortality_index"]]   == mdcr_vs_ahrq_2023[["CMR_Index_Mortality"]])
stopifnot(mdcr_vs_ahrq_2023[["readmission_index"]] == mdcr_vs_ahrq_2023[["CMR_Index_Readmission"]])

stopifnot(mdcr_vs_ahrq_2024[["mortality_index"]]   == mdcr_vs_ahrq_2024[["CMR_Index_Mortality"]])
stopifnot(mdcr_vs_ahrq_2024[["readmission_index"]] == mdcr_vs_ahrq_2024[["CMR_Index_Readmission"]])

stopifnot(mdcr_vs_ahrq_2025[["mortality_index"]]   == mdcr_vs_ahrq_2025[["CMR_Index_Mortality"]])
stopifnot(mdcr_vs_ahrq_2025[["readmission_index"]] == mdcr_vs_ahrq_2025[["CMR_Index_Readmission"]])

################################################################################
#                                 End of File                                  #
################################################################################
