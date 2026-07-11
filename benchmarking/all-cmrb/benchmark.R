################################################################################
# file: benchmark2.R
#
# what happens if _all_ subjects have a comorbidity?  The MIMIC-IV data is great
# for realistic data, but what is a worse-case
#
library(data.table)
library(medicalcoder)

outfile <- if (interactive()) {
  #"DT__1e3__pccc_v3.1s__cumulative__1__1.rds"
  "DT__1e5__pccc_v3.1s__cumulative__1__1.rds"
  #"DT__1e3__charlson_quan2005__cumulative__1__1.rds"
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
# generate test set
set.seed(seed)
# define a vector to sample the number of encounters per subject from
encounters <-
  c(4L, 2L, 1L, 7L, 1L, 12L, 1L, 7L, 3L, 1L, 6L, 1L, 1L, 3L, 2L,
  7L, 1L, 1L, 1L, 1L, 5L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 2L, 3L, 1L,
  1L, 6L, 1L, 1L, 20L, 2L, 1L, 13L, 3L, 1L, 3L, 1L, 2L, 4L, 2L,
  1L, 1L, 1L, 8L, 2L, 2L, 1L, 1L, 1L, 2L, 3L, 1L, 5L, 1L, 1L, 1L,
  2L, 6L, 1L, 2L, 1L, 1L, 1L, 1L, 7L, 3L, 1L, 2L, 2L, 1L, 2L, 1L,
  2L, 3L, 2L, 1L, 1L, 1L, 1L, 2L, 1L, 9L, 1L, 2L, 10L, 1L, 1L,
  1L, 2L, 2L, 10L, 1L, 3L, 10L)

codes <-
  data.table::rbindlist(
    list(
      get_pccc_codes(),
      get_charlson_codes(),
      get_elixhauser_codes()
      ), use.names = TRUE, fill = TRUE
  )
codes <- codes[, .(icdv, dx, full_code, code)]
dxcodes <- codes[dx == 1L]

encounters <- sample(encounters, size = subjects, replace = TRUE)

this_data <-
  Map(function(s, e) {
    rbindlist(
      lapply(seq_len(e), function(x) {
        dx <- sample.int(n = nrow(dxcodes), size = sample.int(6, size = 1))
        others <- sample.int(n = nrow(codes), size = sample.int(6, size = 1))
        rbind(dxcodes[dx, ], codes[dx, ])
          }
        ),
      idcol = "eid"
    )
    },
    s = seq_len(subjects),
    e = encounters
  )
this_data <- rbindlist(this_data, idcol = "sid")
this_data[runif(n = .N) < 0.5, code := full_code]
this_data[, full_code := NULL]

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
      data = this_data[1:10, ],
      icd.codes = "code",
      method = method,
      id.vars = c("sid", "eid"),
      icdv.var = "icdv",
      dx.var = "dx",
      poa = 1L,
      primarydx = 0L,
      flag.method = "current"
    )
  )

################################################################################
# Benchmark
tic <- Sys.time()
  x <-
    medicalcoder::comorbidities(
      data = this_data,
      icd.codes = "code",
      method = method,
      id.vars = c("sid", "eid"),
      icdv.var = "icdv",
      dx.var = "dx",
      poa = 1L,
      primarydx = 0L,
      flag.method = flag_method,
      subconditions = subconditions
    )
toc <- Sys.time()

# sanity check
total_encounters <- uniqueN(this_data, by = c("sid", "eid"))
if (subconditions) {
  if (nrow(x[["conditions"]]) != total_encounters) {
    stop(sprintf("%s not created, nrow(x) != total_encounters", outfile))
  }
} else {
  if (nrow(x) != total_encounters) {
    stop(sprintf("%s not created, nrow(x) != total_encounters", outfile))
  }
}

output <-
  data.frame(
    subjects   = subjects,
    encounters = total_encounters,
    method     = method,
    subconditions = subconditions,
    flag.method = flag_method,
    seed = seed,
    time_seconds = as.numeric(difftime(toc, tic, units = "secs"))
  )

saveRDS(output, file = file.path("bench_results", outfile))
