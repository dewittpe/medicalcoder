library(medicalcoder)
################################################################################
# assert scaler logical

# verify the function is defined and not exported
stopifnot(
  "assert_scalar_logical" %in% ls(getNamespace("medicalcoder"), all.names = TRUE),
  !("assert_scalar_logical" %in% getNamespaceExports("medicalcoder"))
)

# the method should only be used within methods and the error messages are
# controlled:

x <-
  tryCatch(
    comorbidities(data = mdcr, method = "pccc_v3.1", icd.codes = "code", full.codes = "yes"),
    error = function(e) e
  )

stopifnot(
  inherits(x, "error"),
  x$message == "The value passed to 'full.codes' is expected to be a length-1 non-missing logical."
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
