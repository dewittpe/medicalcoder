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
library(medicalcoder)
library(data.table)

# ahrq results
ahrq_2022 <- fread("ahrq/2022/mdcr_sas_result_index_2022.csv")
ahrq_2023 <- fread("ahrq/2023/mdcr_sas_result_index_2023.csv")
ahrq_2024 <- fread("ahrq/2024/mdcr_sas_result_index_2024.csv")
ahrq_2025 <- fread("ahrq/2025/mdcr_sas_result_index_2025.csv")

fill_zero <- function(data) {
  for (j in names(data)) {
    if (startsWith(j, "CMR_")) {
      if (is.logical(data[[j]])) {
        if (all(is.na(data[[j]]))) {
          set(data, j = j, value = as.integer(data[[j]]))
          set(data, j = j, value = as.integer(0L))
        }
      }
    }
  }
}
fill_zero(ahrq_2022)
fill_zero(ahrq_2023)
fill_zero(ahrq_2024)
fill_zero(ahrq_2025)

# build the data sets to pass to medicalcoder::comorbidities
common_args <-
  list(
    id.vars = "PATID",
    measure.vars = paste0("I10_DX", as.character(1:41)),
    value.name = "code"
  )

codes_2022 <- do.call(melt, c(list(data = ahrq_2022), common_args))
codes_2023 <- do.call(melt, c(list(data = ahrq_2023), common_args))
codes_2024 <- do.call(melt, c(list(data = ahrq_2024), common_args))
codes_2025 <- do.call(melt, c(list(data = ahrq_2025), common_args))

codes_2022[, primarydx := as.integer(variable == "I10_DX1")]
codes_2023[, primarydx := as.integer(variable == "I10_DX1")]
codes_2024[, primarydx := as.integer(variable == "I10_DX1")]
codes_2025[, primarydx := as.integer(variable == "I10_DX1")]

# apply medicalcoder::comorbidities
common_args <-
  list(
    icd.codes = "code",
    id.vars = "PATID",
    dx = 1,
    icdv = 10,
    poa = 0,
    primarydx.var = "primarydx",
    flag.method = "current"
  )

mdcr_2022 <- do.call(comorbidities, c(common_args, list(data = codes_2022, method = "elixhauser_ahrq2022")))
mdcr_2023 <- do.call(comorbidities, c(common_args, list(data = codes_2023, method = "elixhauser_ahrq2023")))
mdcr_2024 <- do.call(comorbidities, c(common_args, list(data = codes_2024, method = "elixhauser_ahrq2024")))
mdcr_2025 <- do.call(comorbidities, c(common_args, list(data = codes_2025, method = "elixhauser_ahrq2025")))

mdcr_vs_ahrq_2022 <- merge(x = mdcr_2022, y = ahrq_2022, all = TRUE, by = "PATID")
mdcr_vs_ahrq_2023 <- merge(x = mdcr_2023, y = ahrq_2023, all = TRUE, by = "PATID")
mdcr_vs_ahrq_2024 <- merge(x = mdcr_2024, y = ahrq_2024, all = TRUE, by = "PATID")
mdcr_vs_ahrq_2025 <- merge(x = mdcr_2025, y = ahrq_2025, all = TRUE, by = "PATID")

stopifnot("same number of rows" = nrow(mdcr_2022) == nrow(ahrq_2022) & nrow(mdcr_2022) == nrow(mdcr_vs_ahrq_2022))
stopifnot("same number of rows" = nrow(mdcr_2023) == nrow(ahrq_2023) & nrow(mdcr_2023) == nrow(mdcr_vs_ahrq_2023))
stopifnot("same number of rows" = nrow(mdcr_2024) == nrow(ahrq_2024) & nrow(mdcr_2024) == nrow(mdcr_vs_ahrq_2024))
stopifnot("same number of rows" = nrow(mdcr_2025) == nrow(ahrq_2025) & nrow(mdcr_2025) == nrow(mdcr_vs_ahrq_2025))


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
  #if (!t & !(j %in% c("CANCER_SOLID", "DIAB_UNCX", "HTN_UNCX"))) {
  if (!t) {
    stop(sprintf('identical(mdcr_vs_ahrq_2022[["%s"]], mdcr_vs_ahrq_2022[["%s"]]) is not true', j, paste0("CMR_", j)))
  }
}


for (j in cnds_2023) {
  t <- identical(mdcr_vs_ahrq_2023[[j]], mdcr_vs_ahrq_2023[[paste0("CMR_", j)]])
  #if (!t & !(j %in% c("CANCER_SOLID", "DIAB_UNCX", "HTN_UNCX"))) {
  if (!t) {
    stop(sprintf('identical(mdcr_vs_ahrq_2023[["%s"]], mdcr_vs_ahrq_2023[["%s"]]) is not true', j, paste0("CMR_", j)))
  }
}

for (j in cnds_2024) {
  t <- identical(mdcr_vs_ahrq_2024[[j]], mdcr_vs_ahrq_2024[[paste0("CMR_", j)]])
  #if (!t & !(j %in% c("CANCER_SOLID", "DIAB_UNCX", "HTN_UNCX"))) {
  if (!t) {
    stop(sprintf('identical(mdcr_vs_ahrq_2024[["%s"]], mdcr_vs_ahrq_2024[["%s"]]) is not true', j, paste0("CMR_", j)))
  }
}

for (j in cnds_2025) {
  t <- identical(mdcr_vs_ahrq_2025[[j]], mdcr_vs_ahrq_2025[[paste0("CMR_", j)]])
  #if (!t & !(j %in% c("CANCER_SOLID", "DIAB_UNCX", "HTN_UNCX"))) {
  if (!t) {
    stop(sprintf('identical(mdcr_vs_ahrq_2025[["%s"]], mdcr_vs_ahrq_2025[["%s"]]) is not true', j, paste0("CMR_", j)))
  }
}

data.table::as.data.table(mdcr_vs_ahrq_2022)[CANCER_SOLID != CMR_CANCER_SOLID]
data.table::as.data.table(mdcr_vs_ahrq_2022)[DIAB_UNCX != CMR_DIAB_UNCX]
data.table::as.data.table(mdcr_vs_ahrq_2022)[HTN_UNCX != CMR_HTN_UNCX]

################################################################################
#                                 End of File                                  #
################################################################################
