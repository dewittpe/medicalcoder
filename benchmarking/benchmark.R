################################################################################
# file: benchmark.R
#
# used to benchmark the medicalcoder package
#
library(data.table)
library(medicalcoder)

outfile <- if (interactive()) {
  "DT__1e3__pccc_v3.1__cumulative__1__1.rds"
} else {
  commandArgs(trailingOnly = TRUE)
}

args <- as.list(strsplit(outfile, split = "__")[[1]])

data_class    <- args[[1]]
subjects      <- as.integer(args[[2]])
method        <- args[[3]]
subconditions <- endsWith(method, "s")
flag_method   <- args[[4]]
seed          <- as.integer(args[[5]])
iter          <- args[[6]]

if (subconditions) {
  method <- sub("s$", "", method)
}

################################################################################
# import data
mimicivdata <- readRDS("mimicivdata.rds")

# generate test set
set.seed(seed)
patients <-
  data.table::data.table(
    subject_id = sample(unique(mimicivdata$subject_id), size = subjects, replace = TRUE)
  )[, .N, by = .(subject_id)]

this_data <-
  Map(function(id, n) {
    x <- subset(mimicivdata, mimicivdata[["subject_id"]] == id)
    x <- replicate(n = n, expr = x, simplify = FALSE)
    x <- data.table::rbindlist(x, idcol = "dup")
    x[, hadm_seq := (dup * 100L) + hadm_seq]
    },
   id = patients$subject_id,
   n = patients$N
  ) |>
  data.table::rbindlist()

if (data_class != "DT") {
  data.table::setDF(this_data)
  if (data_class == "TBL") {
    this_data <- tibble::as_tibble(this_data)
  }
}

# to get best possible time run medicalcoder::comorbidities() once, on a very
# small set, to makesure everything is loaded into memory.

x <-
  suppressWarnings(
    medicalcoder::comorbidities(
      data = mimicivdata[1:10, ],
      icd.codes = "icd_code",
      method = method,
      id.vars = c("subject_id", "hadm_id", "hadm_seq"),
      icdv.var = "icd_version",
      dx.var = "dx",
      poa.var = "poa",
      primarydx.var = "primarydx",
      flag.method = "current"
    )
  )

################################################################################
# Benchmark
tic <- Sys.time()
  x <-
    comorbidities(
      data = this_data,
      icd.codes = "icd_code",
      id.vars = c("subject_id", "hadm_id", "dup", "hadm_seq"),
      icdv.var = "icd_version",
      dx.var = "dx",
      poa.var = "poa",
      primarydx = 0,
      flag.method = flag_method,
      method = method,
      subconditions = subconditions
    )
toc <- Sys.time()

# sanity check
total_encounters <- uniqueN(this_data, by = c("subject_id", "hadm_id", "dup"))
if (nrow(x) != total_encounters) {
  stop(sprintf("%s not created, nrow(x) != total_encounters", outfile))
}

output <-
  data.frame(
    subjects   = subjects,
    encounters = uniqueN(this_data, by = c("subject_id", "hadm_id", "dup")),
    method     = method,
    subconditions = subconditions,
    flag.method = flag_method,
    seed = seed,
    time_seconds = as.numeric(difftime(toc, tic, units = "secs"))
  )

saveRDS(output, file = file.path("bench_results", outfile))
