source("benchmark-utilities.R")

if (interactive()) {
  outfile <- "DT__1e1__pccc_v3.1__1__1.rds"
} else {
  outfile <- commandArgs(trailingOnly = TRUE)
}

args <- as.list(strsplit(outfile, split = "__")[[1]])

this_data_set <-
  build_set1(
    data_class = args[[1]],
    subjects = as.integer(args[[2]]),
    seed = as.integer(args[[4]])
  )

method <- args[[3]]
subconditions <- endsWith(method, "s")

if (subconditions) {
  method <- sub("s$", "", method)
}

output <-
  benchmark1(
    data = this_data_set,
    method = method,
    subconditions = subconditions
  )

saveRDS(output, file = file.path("bench1_results", outfile))

