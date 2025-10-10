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
#        non-missing logical when calling comorbidities()
#
#   t03: verify an error is thrown when `compact.codes` is not a length-1
#        non-missing logical when calling comorbidities()
#
#   t04: verify an error is thrown when subconditions is not a length-1
#        non-missing logical (using pccc_v3.1 as the method to avoid warning
#        messages) when calling comorbidities()
#
#   t05: verify an error is thrown when with.descriptions is not a length-1
#        non-missing logical when calling get_icd_codes()
#
#   t06: verify an error is thrown when with.hierarchy is not a length-1
#        non-missing logical when calling get_icd_codes()

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

t03a <- tryCatchError(do.call(comorbidities, args = c(common_args, list(compact.codes = TRUE))))
t03b <- tryCatchError(do.call(comorbidities, args = c(common_args, list(compact.codes = FALSE))))
t03c <- tryCatchError(do.call(comorbidities, args = c(common_args, list(compact.codes = logical(0)))))
t03d <- tryCatchError(do.call(comorbidities, args = c(common_args, list(compact.codes = NA))))
t03e <- tryCatchError(do.call(comorbidities, args = c(common_args, list(compact.codes = "yes"))))
t03f <- tryCatchError(do.call(comorbidities, args = c(common_args, list(compact.codes = 3))))

t04a <- tryCatchError(do.call(comorbidities, args = c(common_args, list(subconditions = TRUE))))
t04b <- tryCatchError(do.call(comorbidities, args = c(common_args, list(subconditions = FALSE))))
t04c <- tryCatchError(do.call(comorbidities, args = c(common_args, list(subconditions = logical(0)))))
t04d <- tryCatchError(do.call(comorbidities, args = c(common_args, list(subconditions = NA))))
t04e <- tryCatchError(do.call(comorbidities, args = c(common_args, list(subconditions = "yes"))))
t04f <- tryCatchError(do.call(comorbidities, args = c(common_args, list(subconditions = 3))))

t05a <- tryCatchError(get_icd_codes(with.descriptions = TRUE))
t05b <- tryCatchError(get_icd_codes(with.descriptions = FALSE))
t05c <- tryCatchError(get_icd_codes(with.descriptions = logical(0)))
t05d <- tryCatchError(get_icd_codes(with.descriptions = NA))
t05e <- tryCatchError(get_icd_codes(with.descriptions = "yes"))
t05f <- tryCatchError(get_icd_codes(with.descriptions = 3))

t06a <- tryCatchError(get_icd_codes(with.hierarchy = TRUE))
t06b <- tryCatchError(get_icd_codes(with.hierarchy = FALSE))
t06c <- tryCatchError(get_icd_codes(with.hierarchy = logical(0)))
t06d <- tryCatchError(get_icd_codes(with.hierarchy = NA))
t06e <- tryCatchError(get_icd_codes(with.hierarchy = "yes"))
t06f <- tryCatchError(get_icd_codes(with.hierarchy = 3))

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
  t02f[["message"]] == "The value passed to 'full.codes' is expected to be a length-1 non-missing logical.",
  inherits(t03a, "medicalcoder_comorbidities"),
  inherits(t03b, "medicalcoder_comorbidities"),
  inherits(t03c, "error"),
  inherits(t03d, "error"),
  inherits(t03e, "error"),
  inherits(t03f, "error"),
  t03c[["message"]] == "The value passed to 'compact.codes' is expected to be a length-1 non-missing logical.",
  t03d[["message"]] == "The value passed to 'compact.codes' is expected to be a length-1 non-missing logical.",
  t03e[["message"]] == "The value passed to 'compact.codes' is expected to be a length-1 non-missing logical.",
  t03f[["message"]] == "The value passed to 'compact.codes' is expected to be a length-1 non-missing logical.",
  inherits(t04a, "medicalcoder_comorbidities"),
  inherits(t04b, "medicalcoder_comorbidities"),
  inherits(t04c, "error"),
  inherits(t04d, "error"),
  inherits(t04e, "error"),
  inherits(t04f, "error"),
  t04c[["message"]] == "The value passed to 'subconditions' is expected to be a length-1 non-missing logical.",
  t04d[["message"]] == "The value passed to 'subconditions' is expected to be a length-1 non-missing logical.",
  t04e[["message"]] == "The value passed to 'subconditions' is expected to be a length-1 non-missing logical.",
  t04f[["message"]] == "The value passed to 'subconditions' is expected to be a length-1 non-missing logical.",
  inherits(t05a, "data.frame"),
  inherits(t05b, "data.frame"),
  inherits(t05c, "error"),
  inherits(t05d, "error"),
  inherits(t05e, "error"),
  inherits(t05f, "error"),
  t05c[["message"]] == "The value passed to 'with.descriptions' is expected to be a length-1 non-missing logical.",
  t05d[["message"]] == "The value passed to 'with.descriptions' is expected to be a length-1 non-missing logical.",
  t05e[["message"]] == "The value passed to 'with.descriptions' is expected to be a length-1 non-missing logical.",
  t05f[["message"]] == "The value passed to 'with.descriptions' is expected to be a length-1 non-missing logical.",
  inherits(t06a, "data.frame"),
  inherits(t06b, "data.frame"),
  inherits(t06c, "error"),
  inherits(t06d, "error"),
  inherits(t06e, "error"),
  inherits(t06f, "error"),
  t06c[["message"]] == "The value passed to 'with.hierarchy' is expected to be a length-1 non-missing logical.",
  t06d[["message"]] == "The value passed to 'with.hierarchy' is expected to be a length-1 non-missing logical.",
  t06e[["message"]] == "The value passed to 'with.hierarchy' is expected to be a length-1 non-missing logical.",
  t06f[["message"]] == "The value passed to 'with.hierarchy' is expected to be a length-1 non-missing logical."
)

################################################################################
#                                 End of File                                  #
################################################################################
