suppressPackageStartupMessages({
  if (!requireNamespace("medicalcoder", quietly = TRUE)) {
    stop("Install the medicalcoder package before running this benchmark.")
  }
  if (!requireNamespace("data.table", quietly = TRUE)) {
    stop("Install the data.table package (suggested by medicalcoder).")
  }
  if (!requireNamespace("tibble", quietly = TRUE)) {
    stop("Install the tibble package (suggested by medicalcoder).")
  }
})

library(medicalcoder)
library(data.table)
library(tibble)

# Notes: based on observations from the MIMIC-IV data the relative distribuiton
# of the number of procedure codes per encounter is approximately:
dxpr_distribution <-
  data.table(
    ncodes = c(0:40, 0:40),
    dx = rep(c(0, 1), each = 41),
    d  = c(10^(4.5352 - 0.1044 * 0:40),
           10^(4.332356 + 0.030478 * 0:40 - 0.002056 * (0:40)^2))
  )
dxpr_distribution[, d := d / sum(d), by = .(dx)]
dxpr_distribution[, p := cumsum(d), by = .(dx)]
dx_distribution <- dxpr_distribution[dx == 1][, dx := NULL]
pr_distribution <- dxpr_distribution[dx == 0][, dx := NULL]

# the number of encounters per patient
encounter_distribution <-
  data.table(
    nencounters = 1:110,
    d = 10^(2.51837 - 0.02291 * 1:110)
  )
encounter_distribution[, d := d / sum(d)]
encounter_distribution[, p := cumsum(d)]

pccc_codes <- medicalcoder::get_pccc_codes()[, c("icdv", "dx", "full_code")]
pccc_dx_codes <- pccc_codes[pccc_codes$dx == 1, ]
pccc_pr_codes <- pccc_codes[pccc_codes$dx == 0, ]

icd_codes  <- medicalcoder::get_icd_codes()[, c("icdv", "dx", "full_code")]
icd_dx_codes <- icd_codes[icd_codes$dx == 1, ]
icd_pr_codes <- icd_codes[icd_codes$dx == 0, ]

build_set1 <- function(data_class = c("DF", "DT", "TBL") , subjects = 10 , seed = 1) {
  subjects <- as.integer(subjects)
  stopifnot(subjects > 0)
  seed <- as.integer(seed)
  set.seed(seed)

  data_class <- match.arg(data_class)

  dxs <- as.list(sample(dx_distribution$ncodes, size = subjects, prob = dx_distribution$d, replace = TRUE))
  prs <- as.list(sample(pr_distribution$ncodes, size = subjects, prob = pr_distribution$d, replace = TRUE))

  # How many dx and pr codes from pccc?
  pdxs <- lapply(lapply(dxs, runif), function(x) sum(x < 0.3))
  pprs <- lapply(lapply(prs, runif), function(x) sum(x < 0.3))

  # any icd codes
  dxs <- mapply(function(x, y) {x - y}, x = dxs, y = pdxs)
  prs <- mapply(function(x, y) {x - y}, x = prs, y = pprs)

  set <-
    mapply(function(sid, pdx, ppr, adx, apr) {
      x <-
        rbind(
          pccc_dx_codes[sample(seq_len(nrow(pccc_dx_codes)), size = pdx), ],
          pccc_pr_codes[sample(seq_len(nrow(pccc_pr_codes)), size = ppr), ],
          icd_dx_codes[sample(seq_len(nrow(icd_dx_codes)), size = adx), ],
          icd_pr_codes[sample(seq_len(nrow(icd_pr_codes)), size = apr), ]
        )
      if (nrow(x)) {
        x$subject_id <- sid
      } else {
        x <- data.frame(icdv = NA_integer_, dx = NA_integer_, full_code = NA_character_, subject_id = sid)
      }
      x
    },
    pdx = pdxs, ppr = pprs, adx = dxs, apr = prs, sid = seq_along(pdxs),
    SIMPLIFY = FALSE
    )
  set <- do.call(rbind, set)
  rownames(set) <- NULL

  if (data_class == "DT") {
    require(data.table)
    data.table::setDT(set)
  } else if (data_class == "TBL") {
    require(tibble)
    set <- as_tibble(set)
  }

  attr(set, "data_class") <- data_class
  attr(set, "nsubjects") <- subjects
  attr(set, "nencounters") <- subjects

  set
}

build_set2 <- function(data_class = c("DF", "DT", "TBL") , subjects = 10 , seed = 1) {
  subjects <- as.integer(subjects)
  stopifnot(subjects > 0)
  seed <- as.integer(seed)
  set.seed(seed)

  data_class <- match.arg(data_class)

  # encounters
  encs <- sample(x = encounter_distribution$nencounters, size = subjects, prob = encounter_distribution$d)
  se <- Map(function(s, e) {data.frame(s = s, e = seq_len(e))}, s = seq_len(length(encs)), e = encs)
  se <- do.call(rbind, se)

  dxs <- as.list(sample(dx_distribution$ncodes, size = sum(encs), prob = dx_distribution$d, replace = TRUE))
  prs <- as.list(sample(pr_distribution$ncodes, size = sum(encs), prob = pr_distribution$d, replace = TRUE))

  # How many dx and pr codes from pccc?
  pdxs <- lapply(lapply(dxs, runif), function(x) sum(x < 0.3))
  pprs <- lapply(lapply(prs, runif), function(x) sum(x < 0.3))

  # any icd codes
  dxs <- mapply(function(x, y) {x - y}, x = dxs, y = pdxs)
  prs <- mapply(function(x, y) {x - y}, x = prs, y = pprs)

  set <-
    mapply(function(sid, eid, pdx, ppr, adx, apr) {
      x <-
        rbind(
          pccc_dx_codes[sample(seq_len(nrow(pccc_dx_codes)), size = pdx), ],
          pccc_pr_codes[sample(seq_len(nrow(pccc_pr_codes)), size = ppr), ],
          icd_dx_codes[sample(seq_len(nrow(icd_dx_codes)), size = adx), ],
          icd_pr_codes[sample(seq_len(nrow(icd_pr_codes)), size = apr), ]
        )
      if (nrow(x)) {
        x$subject_id <- sid
        x$enc_id <- eid
      } else {
        x <- data.frame(icdv = NA_integer_, dx = NA_integer_, full_code = NA_character_, subject_id = sid, enc_id = eid)
      }
      x
    },
    pdx = pdxs, ppr = pprs, adx = dxs, apr = prs,
    sid = se$s, eid = se$e,
    SIMPLIFY = FALSE
    )
  set <- do.call(rbind, set)
  rownames(set) <- NULL

  if (data_class == "DT") {
    require(data.table)
    data.table::setDT(set)
  } else if (data_class == "TBL") {
    require(tibble)
    set <- as_tibble(set)
  }

  attr(set, "data_class") <- data_class
  attr(set, "nsubjects") <- subjects
  attr(set, "nencounters") <- sum(encs)

  set
}

build_set1()
build_set2()

benchmark1 <- function(data, method, subconditions) {
  tic <- Sys.time()
  comorbidities(
    data = data,
    icd.codes = "full_code",
    id.vars = "subject_id",
    icdv.var = "icdv",
    dx.var = "dx",
    poa = 1,
    primarydx = 0,
    flag.method = "current",
    method = method,
    subconditions = subconditions
  )
  toc <- Sys.time()
  data.frame(
    data_class = attr(data, "data_class"),
    subjects   = attr(data, "nsubjects"),
    encounters = attr(data, "nencounters"),
    method     = method,
    subconditions = subconditions,
    flag.method = "current",
    seed = 1,
    time_seconds = as.numeric(difftime(toc, tic, units = "secs"))
  )
}

benchmark2 <- function(data, method, subconditions, flag.method) {
  tic <- Sys.time()
  comorbidities(
    data = set,
    icd.codes = "full_code",
    id.vars = c("subject_id", "enc_id"),
    icdv.var = "icdv",
    dx.var = "dx",
    poa = 1,
    primarydx = 0,
    flag.method = flag.method,
    method = method,
    subconditions = subconditions
  )
  toc <- Sys.time()

  data.frame(
    data_class = data_class,
    subjects   = attr(data, "nsubjects"),
    encounters = attr(data, "nencounters"),
    method     = method,
    subconditions = subconditions,
    flag.method = flag.method,
    seed = 1,
    time_seconds = as.numeric(difftime(toc, tic, units = "secs"))
  )
}

