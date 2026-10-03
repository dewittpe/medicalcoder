################################################################################
# Regex patterns should require at least an ICD category prefix.  This prevents
# short fragments such as "C0" or "49" from flagging while preserving prefix
# matching for overspecified non-package ICD variants after a valid category.

chars <- c(LETTERS, as.character(0:9))
short_code_fragments <- unique(c(chars, as.vector(outer(chars, chars, paste0))))
short_regex_hits <-
  lapply(
    medicalcoder:::..mdcr_internal_charlson_regex..[["pattern"]],
    function(pattern) short_code_fragments[grepl(pattern, short_code_fragments)]
  )

stopifnot(!any(lengths(short_regex_hits) > 0L))

short_fragment_data <-
  data.frame(
    id = c("C0", "C0A", "C1", "C1A", "C6", "C6A", "49", "49A"),
    code = c("C0", "C0A", "C1", "C1A", "C6", "C6A", "49", "49A"),
    icdv = c(10L, 10L, 10L, 10L, 10L, 10L, 9L, 9L),
    dx = 1L,
    stringsAsFactors = FALSE
  )

short_fragment_quan <-
  comorbidities(
    data = subset(short_fragment_data, icdv == 10L),
    id.vars = "id",
    icd.codes = "code",
    icdv.var = "icdv",
    dx.var = "dx",
    poa = 1L,
    primarydx = 0L,
    method = "charlson_quan2011",
    mapping = "regex"
  )

short_fragment_deyo <-
  comorbidities(
    data = subset(short_fragment_data, icdv == 9L),
    id.vars = "id",
    icd.codes = "code",
    icdv.var = "icdv",
    dx.var = "dx",
    poa = 1L,
    primarydx = 0L,
    method = "charlson_deyo1992",
    mapping = "regex"
  )

stopifnot(
  all(short_fragment_quan[["cmrb_flag"]] == 0L),
  all(short_fragment_deyo[["cmrb_flag"]] == 0L)
)

# The exhaustive comparisons below apply every supported Charlson regex to the
# full ICD database, in both full and compact code formats. They take several
# minutes, so leave them out of routine package checks. Run them locally with
# MEDICALCODER_RUN_EXTENDED_TESTS=true to enable the extended checks.
if (!extended_tests_enabled()) {
  message(
    "Skipping extended regex comparisons; set ",
    "MEDICALCODER_RUN_EXTENDED_TESTS=true to run them."
  )
  q(save = "no", status = 0)
}

################################################################################
# Test that the regex will capture the same codes as the precomputed codes

js <- c("icdv", "dx", "full_code", "code")
jsc <- c(js, "condition")
all_codes <- unique(get_icd_codes()[, js])
all_codes_split <- split(all_codes, f = all_codes[c("icdv", "dx")])

charlson_codes <- get_charlson_codes()

p <- new.env()   # store precomputed results
rf <- new.env()  # store regex on full codes
rc <- new.env()  # sotre regex on compact codes

# define the lapply to use
if (requireNamespace("parallel", quietly = TRUE)) {
  listapply <- getExportedValue(ns = "parallel", name = "mclapply")
  cores <- parallel::detectCores()
  cores <- if (is.na(cores)) 1L else max(floor(cores / 2L), 1L)
  limit_cores <- tolower(Sys.getenv("_R_CHECK_LIMIT_CORES_", "")) %in% c("true", "1")
  if (limit_cores) {
    cores <- min(cores, 2L)
  }
  options(mc.cores = cores)
} else {
  listapply <- lapply
}

map_by_regex_wrapper <- function(uc, ptrns, full_code = TRUE) {
  if (full_code) {
    rtn <-
      listapply(
        split(ptrns, f = ptrns["pattern"]),
        medicalcoder:::map_by_regex,
        uc = uc,
        icd.codes = "full_code",
        by_x = c("full_code", "icdv", "dx"),
        by_y = c("icdv", "dx")
      )
  } else {
    rtn <-
      listapply(
        split(ptrns, f = ptrns["pattern"]),
        medicalcoder:::map_by_regex,
        uc = uc,
        icd.codes = "code",
        by_x = c("code", "icdv", "dx"),
        by_y = c("icdv", "dx")
      )
  }
  rtn <- do.call(rbind, rtn)
  rtn
}

for (m in names(charlson_codes)[which(!(names(charlson_codes) %in% jsc))]) {
  if (m == "charlson_beyrer2021") {
    # skip for now, no regex yet
    next
  }

  tic <- Sys.time()

  if (interactive()) message(m)

  v <- medicalcoder:::mdcr_subset(charlson_codes, charlson_codes[[m]] == 1L, c(jsc, m))
  rownames(v) <- NULL
  assign(x = m, value = v, envir = p)

  lookup <- medicalcoder:::..mdcr_internal_charlson_regex..
  lookup <- medicalcoder:::mdcr_subset(lookup, lookup[[m]] == 1L)

  # by full codes
  m9.0f <- map_by_regex_wrapper(
    uc = all_codes_split[["9.0"]],
    ptrns = medicalcoder:::mdcr_subset(lookup, lookup[["icdv"]] == 9L & lookup[["dx"]] == 0L)
  )

  m9.1f <- map_by_regex_wrapper(
    uc = all_codes_split[["9.1"]],
    ptrns = medicalcoder:::mdcr_subset(lookup, lookup[["icdv"]] == 9L & lookup[["dx"]] == 1L)
  )

  m10.0f <- map_by_regex_wrapper(
    uc = all_codes_split[["10.0"]],
    ptrns = medicalcoder:::mdcr_subset(lookup, lookup[["icdv"]] == 10L & lookup[["dx"]] == 0L)
  )

  m10.1f <- map_by_regex_wrapper(
    uc = all_codes_split[["10.1"]],
    ptrns = medicalcoder:::mdcr_subset(lookup, lookup[["icdv"]] == 10L & lookup[["dx"]] == 1L)
  )

  by_regex <- rbind(m9.0f, m9.1f, m10.0f, m10.1f)[, c(jsc, m)]
  by_regex <- unique(by_regex)
  rownames(by_regex) <- NULL
  assign(x = m, value = by_regex, envir = rf)

  # by compact codes
  m9.0c <- map_by_regex_wrapper(
    uc = all_codes_split[["9.0"]],
    ptrns = medicalcoder:::mdcr_subset(lookup, lookup[["icdv"]] == 9L & lookup[["dx"]] == 0L),
    full_code = FALSE
  )

  m9.1c <- map_by_regex_wrapper(
    uc = all_codes_split[["9.1"]],
    ptrns = medicalcoder:::mdcr_subset(lookup, lookup[["icdv"]] == 9L & lookup[["dx"]] == 1L),
    full_code = FALSE
  )

  m10.0c <- map_by_regex_wrapper(
    uc = all_codes_split[["10.0"]],
    ptrns = medicalcoder:::mdcr_subset(lookup, lookup[["icdv"]] == 10L & lookup[["dx"]] == 0L),
    full_code = FALSE
  )

  m10.1c <- map_by_regex_wrapper(
    uc = all_codes_split[["10.1"]],
    ptrns = medicalcoder:::mdcr_subset(lookup, lookup[["icdv"]] == 10L & lookup[["dx"]] == 1L),
    full_code = FALSE
  )

  by_regex <- rbind(m9.0c, m9.1c, m10.0c, m10.1c)[, c(jsc, m)]
  by_regex <- unique(by_regex)
  rownames(by_regex) <- NULL

  assign(x = m, value = by_regex, envir = rc)

  # Test to see if there are any differences
  z <-
    merge(
      merge(
        x = cbind(p[[m]], p = 1),
        y = cbind(rf[[m]], rf = 1),
        all = TRUE,
        by = c(jsc, m)
        ),
      cbind(rc[[m]], rc = 1),
      all = TRUE,
      by = c(jsc, m)
    )

  message("  [INFO] assessment completed in ", round(difftime(Sys.time(), tic, units = "secs"), 2), " seconds")

  if (!identical(z[["rf"]], z[["rc"]])) {
    stop("regex on full codes is not the same as for compact codes for ", m, call. = FALSE)
  } else if (identical(z[["p"]], z[["rf"]]) & identical(z[["p"]], z[["rc"]])) {
    message("  [INFO] precomputed vs regex is the same for ", m)
  } else {
    stop("precomputed vs regex is not the same for ", m, call. = FALSE)
  }
}

################################################################################
# test that you get the same results when icdv and dx are specified.  There
# should be false positives if icdv and/or dx are not specified.

# verify the list of possible charlson methods
m <- grep("charlson_",  names(medicalcoder:::..mdcr_internal_charlson_regex..), value = TRUE)

# add an age variable
mdcr$age <- as.integer(substr(as.character(mdcr$patid), 1, 2))

commonargs <-
  list(
    data = mdcr,
    id.vars = "patid",
    icdv.var = "icdv",
    icd.codes = "code",
    dx.var = "dx",
    poa = 1,
    primarydx = 0L
  )

e <- expression({
  tics <- tocs <- vector(mode = "list", length = 0)
  p <- new.env()
  r <- new.env()
  for (thism in m) {
    for (mapping in c("precomputed", "regex")) {
      x <- paste(thism, mapping, sep = "_")
      if (interactive()) message("start ", x)
      tics[[x]] <- Sys.time()
      assign(
        x = thism,
        value = do.call(comorbidities, c(commonargs, list(method = thism, mapping = mapping))),
        envir = if(mapping == "precomputed") p else r
      )
      tocs[[x]] <- Sys.time()
      if (interactive()) message("finished ", x, " in ", round(difftime(tocs[[x]], tics[[x]], units = "secs"), 2), " seconds")
    }
  }
})

eval(e)
DFclock <- Map(difftime, time1 = tocs, time2 = tics)
stopifnot(all.equal(p, r))

################################################################################
#                                 End of File                                  #
################################################################################
