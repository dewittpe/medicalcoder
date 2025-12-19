library(data.table)

# ahrq results
ahrq_results <-
  list(
    "2022/sas_result_index_2022.csv.gz",
    "2023/sas_result_index_2023.csv.gz",
    "2024/sas_result_index_2024.csv.gz",
    "2025/sas_result_index_2025.csv.gz",
    "2026/sas_result_index_2026.csv.gz"
  )
ahrq_results <- lapply(ahrq_results, data.table::fread)
ahrq_results <- rbindlist(ahrq_results)

for (j in names(ahrq_results)) {
  if (inherits(ahrq_results[[j]], "integer")) {
    set(ahrq_results, j = j, value = nafill(ahrq_results[[j]], fill = 0L))
  }
}

ahrq_results <- unique(ahrq_results, by = grep("year|EX|CMR_", names(ahrq_results), value = TRUE))

setDF(ahrq_results)
saveRDS(ahrq_results, file = "../expected-ahrq-results.rds", compress = "xz")
