source("benchmark-utilities.R")

outfile <- if (interactive()) "DT__1e3__pccc_v3.1__cumulative__1__1.rds" else commandArgs(trailingOnly = TRUE)

args <- as.list(strsplit(outfile, split = "__")[[1]])

data_class <- args[[1]]
subjects   <- as.integer(args[[2]])
method <- args[[3]]
subconditions <- endsWith(method, "s")
flag_method <- args[[4]]
seed <- as.integer(args[[5]])
iter <- args[[6]]

if (subconditions) {
  method <- sub("s$", "", method)
}

dataset_file <- file.path("bench_data", sprintf("%s__%s.rds", subjects, seed))
if (!file.exists(dataset_file)) {
  stop(sprintf("Dataset %s is missing; build datasets first.", dataset_file))
}

this_data_set <- readRDS(dataset_file)
# Convert to requested class on the fly
if (data_class == "DT") {
  data.table::setDT(this_data_set)
} else if (data_class == "TBL") {
  this_data_set <- tibble::as_tibble(this_data_set)
}

output <-
  benchmark(
    data = this_data_set,
    method = method,
    subconditions = subconditions,
    flag.method = flag_method
  )

saveRDS(output, file = file.path("bench_results", outfile))
