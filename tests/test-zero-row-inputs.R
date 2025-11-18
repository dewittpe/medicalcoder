library(medicalcoder)
source('utilities.R')

# Verify that when a data.frame with zero rows is passed to comorbidities() the
# return will be a zero row data.frame with the same general structure that
# would be returned if a data.frame with at least one row was passed to
# comorbidities().

# build a zero-row data.frame for
DF <- data.frame(code = c("B", "A"), patid = 1:2)
common_args <- list(data = DF[0, ], id.vars = "patid", icd.codes = "code", poa = 1)

# fit all methods without subconditions
methods <- medicalcoder:::comorbidities_methods()
args <- lapply(methods, function(x) { if (startsWith(x, "pccc")) {c(common_args, list(method = x))} else {c(common_args, list(method = x, primarydx = 0L))} } )
args <- setNames(args, methods)
rtns <- lapply(args, do.call, what = comorbidities)

# pccc with subconditions
common_args[["subconditions"]] <- TRUE
args <- lapply(methods[startsWith(methods, "pccc")], function(x) c(common_args, list(method = x)))
args <- setNames(args, paste0(methods[startsWith(methods, "pccc")], "s"))
rtns <- c(rtns, lapply(args, do.call, what = comorbidities))

# build rtns1 with nrow = nrow(DF), this will be used to check that the names
# and general structure of the returns are the same with zero input rows or more
# than zero input rows
common_args <- list(data = DF, id.vars = "patid", icd.codes = "code", poa = 1)
args <- lapply(methods, function(x) { if (startsWith(x, "pccc")) {c(common_args, list(method = x))} else {c(common_args, list(method = x, primarydx = 0L))} } )
args <- setNames(args, methods)
rtns1 <- lapply(args, do.call, what = comorbidities)

# pccc with subconditions
common_args[["subconditions"]] <- TRUE
args <- lapply(methods[startsWith(methods, "pccc")], function(x) c(common_args, list(method = x)))
args <- setNames(args, paste0(methods[startsWith(methods, "pccc")], "s"))
rtns1 <- c(rtns1, lapply(args, do.call, what = comorbidities))

################################################################################
# verify that all the returned elements inherit the expected classes
for (m in names(rtns)) {
  if (!inherits(rtns[[m]], "medicalcoder_comorbidities")) {
    stop(sprintf("rtns[[%s]] does not inherit `medicalcoder_comorbidities`", m))
  }

  if (!startsWith(m, "pccc") & inherits(rtns[[m]], "medicalcoder_comorbidities_with_subconditions")) {
    stop(sprintf("rtns[[%s]] incorrectly inherits `medicalcoder_comorbidities_with_subconditions`", m))
  } else {
    if (endsWith(m, "s") & !inherits(rtns[[m]], "medicalcoder_comorbidities_with_subconditions")) {
      stop(sprintf("rtns[[%s]] does not inherit `medicalcoder_comorbidities_with_subconditions`", m))
    } else if (!endsWith(m, "s") & inherits(rtns[[m]], "medicalcoder_comorbidities_with_subconditions")) {
      stop(sprintf("rtns[[%s]] incorrectly inherits `medicalcoder_comorbidities_with_subconditions`", m))
    }
  }
}

# verify that all the non subcondition rtns are data.frames
for (m in names(rtns)) {
  if (!startsWith(m, "pccc")) {
    if (!inherits(rtns[[m]], "data.frame")) {
      stop(sprintf("rtns[[%s]] is not a data.frame", m))
    }
    if (nrow(rtns[[m]]) != 0L) {
      stop(sprintf("nrow(rtns[[%s]]) != 0", m))
    }
  } else {
    if (endsWith(m, "s")) {

      if (!inherits(rtns[[m]], "list")) {
        stop(sprintf("rtns[[%s]] is not a list", m))
      }

      if (length(rtns[[m]]) != 2L) {
        stop(sprintf("length(rtns[[%s]]) != 2L", m))
      }

      if (!inherits(rtns[[m]][['conditions']], "data.frame")) {
        stop(sprintf("rtns[[%s]][['conditions']] is not a data.frame", m))
      }

      if (nrow(rtns[[m]][['conditions']]) != 0L) {
        stop(sprintf("nrow(rtns[[%s]][['conditions']]) != 0", m))
      }

      if (!inherits(rtns[[m]][['subconditions']], "list")) {
        stop(sprintf("rtns[[%s]][['subconditions']] is not a list", m))
      }

      if (length(rtns[[m]][['subconditions']]) != 11L) {
        stop(sprintf("length(rtns[[%s]][['subconditions']]) != 11L", m))
      }

      if (!all(sapply(rtns[[m]][['subconditions']], nrow) == 0L)) {
        stop(sprintf("!all(sapply(rtns[[%s]][['subconditions']], nrow) == 0L)", m))
      }

    } else {
      if (!inherits(rtns[[m]], "data.frame")) {
        stop(sprintf("rtns[[%s]] is not a data.frame", m))
      }
      if (nrow(rtns[[m]]) != 0L) {
        stop(sprintf("nrow(rtns[[%s]]) != 0", m))
      }
    }
  }
}

stopifnot(identical(lapply(rtns, names), lapply(rtns1, names)))

stopifnot(
  identical(
    lapply(rtns[grep("pccc_v.+s$", names(rtns))], lapply, names),
    lapply(rtns1[grep("pccc_v.+s$", names(rtns))], lapply, names)
  )
)

################################################################################
#                                 End of File                                  #
################################################################################
