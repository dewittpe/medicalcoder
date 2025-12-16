source("benchmark-utilities.R")

if (interactive()) {
  outfile <- "bench_data/1e1__1.rds"
} else {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) != 1L) stop("expected a single output path argument")
  outfile <- args[[1]]
}

dir.create(dirname(outfile), showWarnings = FALSE, recursive = TRUE)

# Idempotent: skip if already built
if (file.exists(outfile) && file.info(outfile)$size > 0) {
  quit(save = "no")
}

parts <- strsplit(basename(outfile), split = "__")[[1]]
subjects <- as.integer(parts[[1]])
seed <- as.integer(sub("\\.rds$", "", parts[[2]]))

dataset <-
  build_set(
    data_class = "DF",
    subjects = subjects,
    seed = seed
  )

saveRDS(dataset, file = outfile)
