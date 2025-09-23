source("benchmark-utilities.R")

if (interactive()) {
  outfile <- "DT__1e3__pccc_v3.1__cumulative__1__1.rds"
} else {
  outfile <- commandArgs(trailingOnly = TRUE)
}

args <- as.list(strsplit(outfile, split = "__")[[1]])

this_data_set <-
  build_set2(
    data_class = args[[1]],
    subjects = as.integer(args[[2]]),
    seed = as.integer(args[[5]])
  )

method <- args[[3]]
subconditions <- endsWith(method, "s")
flag_method <- args[[4]]

if (subconditions) {
  method <- sub("s$", "", method)
}

output <-
  benchmark2(
    data = this_data_set,
    method = method,
    subconditions = subconditions,
    flag.method = flag_method
  )

saveRDS(output, file = file.path("bench2_results", outfile))

