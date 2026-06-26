on_cran <- function () {
  env <- Sys.getenv("NOT_CRAN")
  if (identical(env, "")) {
    !interactive()
  }
  else {
    !isTRUE(as.logical(env))
  }
}

if (on_cran()) {
  message("CRAN environment detected: skipping this test file.")
  q(save = "no", status = 0)
}

source('utilities.R')
################################################################################
# Test that the regex will capture the same codes as the precomputed codes
library(medicalcoder)

js <- c("icdv", "dx", "full_code", "code")
jsc <- c(js, "condition")
all_codes <- unique(get_icd_codes()[, js])
all_codes_split <- split(all_codes, f = all_codes[c("icdv", "dx")])

charlson_codes <- get_charlson_codes()

p <- new.env()   # store precomputed results
rf <- new.env()  # store regex on full codes
rc <- new.env()  # sotre regex on compact codes

tic <- Sys.time()
for (m in names(charlson_codes)[which(!(names(charlson_codes) %in% jsc))]) {
#for (m in "charlson_quan2005") {
  if (interactive()) message(m)

  v <- medicalcoder:::mdcr_subset(charlson_codes, charlson_codes[[m]] == 1L, c(jsc, m))
  rownames(v) <- NULL
  assign(x = m, value = v, envir = p)

  lookup <- medicalcoder:::..mdcr_internal_charlson_regex..
  lookup <- medicalcoder:::mdcr_subset(lookup, lookup[[m]] == 1L)

  # by full codes
  m9.0 <- medicalcoder:::map_by_regex(
    uc = all_codes_split[["9.0"]],
    ptrns = medicalcoder:::mdcr_subset(lookup, lookup[["icdv"]] == 9L & lookup[["dx"]] == 0L),
    icd.codes = "full_code",
    by_x = c("full_code", "icdv", "dx"),
    by_y = c("icdv", "dx")
  )

  m9.1 <- medicalcoder:::map_by_regex(
    uc = all_codes_split[["9.1"]],
    ptrns = medicalcoder:::mdcr_subset(lookup, lookup[["icdv"]] == 9L & lookup[["dx"]] == 1L),
    icd.codes = "full_code",
    by_x = c("full_code", "icdv", "dx"),
    by_y = c("icdv", "dx")
  )

  m10.0 <- medicalcoder:::map_by_regex(
    uc = all_codes_split[["10.0"]],
    medicalcoder:::mdcr_subset(lookup, lookup[["icdv"]] == 10L & lookup[["dx"]] == 0L),
    icd.codes = "full_code",
    by_x = c("full_code", "icdv", "dx"),
    by_y = c("icdv", "dx")
  )

  m10.1 <- medicalcoder:::map_by_regex(
    uc = all_codes_split[["10.1"]],
    ptrns = medicalcoder:::mdcr_subset(lookup, lookup[["icdv"]] == 10L & lookup[["dx"]] == 1L),
    icd.codes = "full_code",
    by_x = c("full_code", "icdv", "dx"),
    by_y = c("icdv", "dx")
  )

  by_regex <- rbind(m9.0, m9.1, m10.0, m10.1)[, c(jsc, m)]
  by_regex <- unique(by_regex)
  rownames(by_regex) <- NULL

  assign(x = m, value = by_regex, envir = rf)

  # by compact code
  m9.0 <- medicalcoder:::map_by_regex(
    uc = all_codes_split[["9.0"]],
    ptrns = medicalcoder:::mdcr_subset(lookup, lookup[["icdv"]] == 9L & lookup[["dx"]] == 0L),
    icd.codes = "code",
    by_x = c("code", "icdv", "dx"),
    by_y = c("icdv", "dx")
  )

  m9.1 <- medicalcoder:::map_by_regex(
    uc = all_codes_split[["9.1"]],
    ptrns = medicalcoder:::mdcr_subset(lookup, lookup[["icdv"]] == 9L & lookup[["dx"]] == 1L),
    icd.codes = "code",
    by_x = c("code", "icdv", "dx"),
    by_y = c("icdv", "dx")
  )

  m10.0 <- medicalcoder:::map_by_regex(
    uc = all_codes_split[["10.0"]],
    medicalcoder:::mdcr_subset(lookup, lookup[["icdv"]] == 10L & lookup[["dx"]] == 0L),
    icd.codes = "code",
    by_x = c("code", "icdv", "dx"),
    by_y = c("icdv", "dx")
  )

  m10.1 <- medicalcoder:::map_by_regex(
    uc = all_codes_split[["10.1"]],
    ptrns = medicalcoder:::mdcr_subset(lookup, lookup[["icdv"]] == 10L & lookup[["dx"]] == 1L),
    icd.codes = "code",
    by_x = c("code", "icdv", "dx"),
    by_y = c("icdv", "dx")
  )

  by_regex <- rbind(m9.0, m9.1, m10.0, m10.1)[, c(jsc, m)]
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

  if (identical(z[["p"]], z[["rf"]]) & identical(z[["p"]], z[["rc"]])) {
    message("  [INFO] precomputed vs regex is the same for ", m)
    message("  [INFO] assement completed in ", round(difftime(Sys.time(), tic, units = "secs"), 2), " seconds")
  } else {
    stop("precomputed vs regex is not the smae for ", m, call. = FALSE)
  }
}

################################################################################
# test that you get the same results when icdv and dx are specified.  There
# should be false positives if icdv and/or dx are not specified.

# verify the list of possible charlson methods
m <- grep("charlson_", medicalcoder:::comorbidities_methods(), value = TRUE)
m <- sort(m)
stopifnot(
  identical(
    m,
    c("charlson_cdmf2019", "charlson_deyo1992", "charlson_ludvigsson2021", "charlson_quan2005", "charlson_quan2011", "charlson_sundararajan2004")
  )
)

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
