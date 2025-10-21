library(data.table)

# ahrq results
ahrq_results <-
  list(
    "2022/mdcr_sas_result_index_2022.csv.gz",
    "2023/mdcr_sas_result_index_2023.csv.gz",
    "2024/mdcr_sas_result_index_2024.csv.gz",
    "2025/mdcr_sas_result_index_2025.csv.gz"
  )
ahrq_results <- lapply(ahrq_results, data.table::fread)

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
  data
}

ahrq_results <- lapply(ahrq_results, fill_zero)

ahrq_results <- rbindlist(ahrq_results)

setDF(ahrq_results)

saveRDS(ahrq_results, file = "../expected-ahrq-results.rds", compress = "xz")
