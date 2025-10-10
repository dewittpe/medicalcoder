library(medicalcoder)
source("utilities.R")
################################################################################
# testing assert_scaler_logical
#
# Tests:
#
#   t01:
#     a: verify the method is in the namespace
#     b: verify the method is not exported
#
#   t02: verify an error is thrown when `full.codes` is not a length-1
#        non-missing logical
#
#   t03: verify an error is thrown when `compact.codes` is not a length-1
#        non-missing logical

stopifnot(
  t01a = "assert_scalar_logical" %in% ls(getNamespace("medicalcoder"), all.names = TRUE),
  t01b = !("assert_scalar_logical" %in% getNamespaceExports("medicalcoder"))
)


# the method should only be used within methods and the error messages are
# controlled:
common_args <- list(data = mdcr, method = "pccc_v3.1", icd.codes = "code", poa = 1L)
t02a <- tryCatchError(do.call(comorbidities, args = c(common_args, list(full.codes = TRUE))))
t02b <- tryCatchError(do.call(comorbidities, args = c(common_args, list(full.codes = FALSE))))
t02c <- tryCatchError(do.call(comorbidities, args = c(common_args, list(full.codes = logical(0)))))
t02d <- tryCatchError(do.call(comorbidities, args = c(common_args, list(full.codes = NA))))
t02e <- tryCatchError(do.call(comorbidities, args = c(common_args, list(full.codes = "yes"))))
t02f <- tryCatchError(do.call(comorbidities, args = c(common_args, list(full.codes = 3))))

stopifnot(
  inherits(t02a, "medicalcoder_comorbidities"),
  inherits(t02b, "medicalcoder_comorbidities"),
  inherits(t02c, "error"),
  inherits(t02d, "error"),
  inherits(t02e, "error"),
  inherits(t02f, "error"),
  t02c[["message"]] == "The value passed to 'full.codes' is expected to be a length-1 non-missing logical.",
  t02d[["message"]] == "The value passed to 'full.codes' is expected to be a length-1 non-missing logical.",
  t02e[["message"]] == "The value passed to 'full.codes' is expected to be a length-1 non-missing logical.",
  t02f[["message"]] == "The value passed to 'full.codes' is expected to be a length-1 non-missing logical."
)




x <-
  tryCatch(
    comorbidities(data = mdcr, method = "pccc_v3.1", icd.codes = "code", compact.codes = "yes"),
    error = function(e) e
  )
stopifnot(
  inherits(x, "error"),
  x$message == "The value passed to 'compact.codes' is expected to be a length-1 non-missing logical."
)

x <-
  tryCatch(
    comorbidities(data = mdcr, method = "pccc_v3.1", icd.codes = "code", subconditions = c(TRUE, TRUE)),
    error = function(e) e
  )
stopifnot(
  inherits(x, "error"),
  x$message == "The value passed to 'subconditions' is expected to be a length-1 non-missing logical."
)

x <-
  tryCatch(
    get_icd_codes(with.descriptions = "Yes"),
    error = function(e) e
  )
stopifnot(
  inherits(x, "error"),
  x$message == "The value passed to 'with.descriptions' is expected to be a length-1 non-missing logical."
)

x <-
  tryCatch(
    get_icd_codes(with.hierarchy = "Yes"),
    error = function(e) e
  )
stopifnot(
  inherits(x, "error"),
  x$message == "The value passed to 'with.hierarchy' is expected to be a length-1 non-missing logical."
)

################################################################################
#                                 End of File                                  #
################################################################################
