################################################################################
# file: test-vs-ahrq.R
#
# objective:
#
#   compare medicalcoder::comorbidities(..., method = "elixhauser_ahrqYYYY")
#   against the official AHRQ SAS mapping results when fixtures are available.
#
# Note: using stats::reshape instead of data.table::melt so that this test can
# run when no-suggests is TRUE.
#
################################################################################
library(medicalcoder)
source('utilities.R')

# ahrq results
ahrq_results <- readRDS("expected-ahrq-results.rds")

codes <-
  stats::reshape(
    data = ahrq_results,
    direction = "long",
    idvar = c("CMR_VERSION", "PATID"),
    varying = list(
      grep("^I10_DX", names(ahrq_results), value = TRUE),
      grep("^DXPOA",  names(ahrq_results), value = TRUE)
      ),
    v.names = c("code", "poa"),
    times = seq_along(grep("^I10_DX", names(ahrq_results)))
  )

codes[["primarydx"]] <- as.integer(codes[["time"]] == "1")
codes[["poa"]] <- as.integer(codes[["poa"]] == "Y")

# apply medicalcoder::comorbidities
common_args <-
  list(
    icd.codes = "code",
    id.vars = c("CMR_VERSION", "PATID"),
    dx = 1,
    icdv = 10,
    poa.var = "poa",
    primarydx.var = "primarydx",
    flag.method = "current"
  )

mdcr_2022 <- do.call(comorbidities, c(common_args, list(data = subset(codes, CMR_VERSION == 2022.1), method = "elixhauser_ahrq2022")))
mdcr_2023 <- do.call(comorbidities, c(common_args, list(data = subset(codes, CMR_VERSION == 2023.1), method = "elixhauser_ahrq2023")))
mdcr_2024 <- do.call(comorbidities, c(common_args, list(data = subset(codes, CMR_VERSION == 2024.1), method = "elixhauser_ahrq2024")))
mdcr_2025 <- do.call(comorbidities, c(common_args, list(data = subset(codes, CMR_VERSION == 2025.1), method = "elixhauser_ahrq2025")))
mdcr_2026 <- do.call(comorbidities, c(common_args, list(data = subset(codes, CMR_VERSION == 2026.1), method = "elixhauser_ahrq2026")))

mdcr_vs_ahrq_2022 <- merge(x = mdcr_2022, y = ahrq_results, all.x = TRUE, by = c("CMR_VERSION", "PATID"))
mdcr_vs_ahrq_2023 <- merge(x = mdcr_2023, y = ahrq_results, all.x = TRUE, by = c("CMR_VERSION", "PATID"))
mdcr_vs_ahrq_2024 <- merge(x = mdcr_2024, y = ahrq_results, all.x = TRUE, by = c("CMR_VERSION", "PATID"))
mdcr_vs_ahrq_2025 <- merge(x = mdcr_2025, y = ahrq_results, all.x = TRUE, by = c("CMR_VERSION", "PATID"))
mdcr_vs_ahrq_2026 <- merge(x = mdcr_2026, y = ahrq_results, all.x = TRUE, by = c("CMR_VERSION", "PATID"))

stopifnot("same number of rows (2022)" = nrow(mdcr_2022) == nrow(subset(ahrq_results, CMR_VERSION == 2022.1)) & nrow(mdcr_2022) == nrow(mdcr_vs_ahrq_2022))
stopifnot("same number of rows (2023)" = nrow(mdcr_2023) == nrow(subset(ahrq_results, CMR_VERSION == 2023.1)) & nrow(mdcr_2023) == nrow(mdcr_vs_ahrq_2023))
stopifnot("same number of rows (2024)" = nrow(mdcr_2024) == nrow(subset(ahrq_results, CMR_VERSION == 2024.1)) & nrow(mdcr_2024) == nrow(mdcr_vs_ahrq_2024))
stopifnot("same number of rows (2025)" = nrow(mdcr_2025) == nrow(subset(ahrq_results, CMR_VERSION == 2025.1)) & nrow(mdcr_2025) == nrow(mdcr_vs_ahrq_2025))
stopifnot("same number of rows (2026)" = nrow(mdcr_2026) == nrow(subset(ahrq_results, CMR_VERSION == 2026.1)) & nrow(mdcr_2026) == nrow(mdcr_vs_ahrq_2026))

# check each condition - this can change year to year
cnds_2022 <- subset(get_elixhauser_index_scores(), !is.na(elixhauser_ahrq2022), select = "condition", drop = TRUE)
cnds_2022 <- unique(cnds_2022)

cnds_2023 <- subset(get_elixhauser_index_scores(), !is.na(elixhauser_ahrq2023), select = "condition", drop = TRUE)
cnds_2023 <- unique(cnds_2023)

cnds_2024 <- subset(get_elixhauser_index_scores(), !is.na(elixhauser_ahrq2024), select = "condition", drop = TRUE)
cnds_2024 <- unique(cnds_2024)

cnds_2025 <- subset(get_elixhauser_index_scores(), !is.na(elixhauser_ahrq2025), select = "condition", drop = TRUE)
cnds_2025 <- unique(cnds_2025)

cnds_2026 <- subset(get_elixhauser_index_scores(), !is.na(elixhauser_ahrq2026), select = "condition", drop = TRUE)
cnds_2026 <- unique(cnds_2026)

for (j in cnds_2022) {
  t <- identical(mdcr_vs_ahrq_2022[[j]], mdcr_vs_ahrq_2022[[paste0("CMR_", j)]])
  if (!t) {# & !(j %in% c("CBVD", "HF"))) {
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

for (j in cnds_2026) {
  t <- identical(mdcr_vs_ahrq_2026[[j]], mdcr_vs_ahrq_2026[[paste0("CMR_", j)]])
  if (!t) {
    stop(sprintf('identical(mdcr_vs_ahrq_2026[["%s"]], mdcr_vs_ahrq_2026[["%s"]]) is not true', j, paste0("CMR_", j)))
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

stopifnot(mdcr_vs_ahrq_2026[["mortality_index"]]   == mdcr_vs_ahrq_2026[["CMR_Index_Mortality"]])
stopifnot(mdcr_vs_ahrq_2026[["readmission_index"]] == mdcr_vs_ahrq_2026[["CMR_Index_Readmission"]])

################################################################################
#                                 End of File                                  #
################################################################################
