source('utilities.R')
library(medicalcoder)

# lookup exact vs regex consistency
lx <- lookup_icd_codes(c("E11.9","I50.9"), regex = FALSE)
lf <- lookup_icd_codes(factor(c("E11.9","I50.9")), regex = FALSE)
lr <- lookup_icd_codes(c("^E11\\.9$","^I50\\.9$"), regex = TRUE)
stopifnot(
  identical(lx, lf),
  all(lx$full_code %in% lr$full_code),
  all(lr$full_code %in% lx$full_code)
)

# verify that a zero length regex will throw an error
m0 <- tryCatchError(lookup_icd_codes(x = "", regex = TRUE))
stopifnot(
  inherits(m0, "error"),
  m0[["message"]] == "When regex = TRUE, x must be non-empty strings."
)

m00 <- tryCatchError(lookup_icd_codes(x = c("^C4A", ""), regex = TRUE))
stopifnot(
  inherits(m00, "error"),
  m00[["message"]] == "When regex = TRUE, x must be non-empty strings."
)

m000 <- tryCatchError(lookup_icd_codes(x = character(0), regex = TRUE))
stopifnot(
  inherits(m000, "error"),
  m000[["message"]] == "When regex = TRUE, x must be non-empty strings."
)

# out of the data.frame should be the same columns with or without matches
m1 <- lookup_icd_codes(x = "", regex = FALSE)
m2 <- lookup_icd_codes(x = "^$", regex = TRUE)
m3 <- lookup_icd_codes(x = "C84", regex = FALSE)
m4 <- lookup_icd_codes(x = "^C84$", regex = TRUE)

expected_regex_false_names <-
  c("input_code",  "match_type", "icdv", "dx", "full_code", "code", "src", "known_start", "known_end", "assignable_start", "assignable_end")
expected_regex_true_names <-
  c("input_regex", "match_type", "icdv", "dx", "full_code", "code", "src", "known_start", "known_end", "assignable_start", "assignable_end")

stopifnot(
  identical(names(m1), expected_regex_false_names),
  identical(names(m2), expected_regex_true_names),
  identical(names(m3), expected_regex_false_names),
  identical(names(m4), expected_regex_true_names)
)

################################################################################
# tests for matching by full and/or compact codes

# without regex
x00 <- tryCatchError(lookup_icd_codes(x = c("E000", "E000.0"), full.codes = FALSE, compact.codes = FALSE))
stopifnot(inherits(x00, "error"))

# The fallowing tests may fail when ICD codes are updated.  As of 17 Nov 2025,
# there are codes with known end and assignable_end of 2026
x01 <- lookup_icd_codes(x = c("E000", "E000.0"), full.codes = FALSE, compact.codes = TRUE)
x10 <- lookup_icd_codes(x = c("E000", "E000.0"), full.codes = TRUE, compact.codes = FALSE)
x11 <- lookup_icd_codes(x = c("E000", "E000.0"), full.codes = TRUE, compact.codes = TRUE)

e01 <- structure(list(input_code = c("E000", "E000", "E000", "E000", "E000", "E000.0"), match_type = c("compact_code", "compact_code", "compact_code", "compact_code", "compact_code", NA), icdv = c(9L, 9L, 10L, 10L, 10L, NA), dx = c(1L, 1L, 1L, 1L, 1L, NA), full_code = c("E000", "E000", "E00.0", "E00.0", "E00.0", NA), code = c("E000", "E000", "E000", "E000", "E000", NA), src = c("cms", "cdc", "cms", "who", "cdc", NA), known_start = c(2010L, 2010L, 2014L, 2008L, 2001L, NA), known_end = c(2015L, 2012L, 2026L, 2019L, 2025L, NA), assignable_start = c(NA, NA, 2014L, 2008L, 2001L, NA), assignable_end = c(NA, NA, 2026L, 2019L, 2025L, NA)), row.names = c(5L, 1L, 3L, 4L, 2L, 6L), class = "data.frame")
e10 <- structure(list(input_code = c("E000", "E000", "E000.0", "E000.0"), match_type = c("full_code", "full_code", "full_code", "full_code"), icdv = c(9L, 9L, 9L, 9L), dx = c(1L, 1L, 1L, 1L), full_code = c("E000", "E000", "E000.0", "E000.0"), code = c("E000", "E000", "E0000", "E0000"), src = c("cms", "cdc", "cms", "cdc"), known_start = c(2010L, 2010L, 2010L, 2010L), known_end = c(2015L, 2012L, 2015L, 2012L), assignable_start = c(NA, NA, 2010L, 2010L), assignable_end = c(NA, NA, 2015L, 2012L)), row.names = c(2L, 1L, 3L, 4L), class = "data.frame")
e11 <- structure(list(input_code = c("E000", "E000", "E000", "E000", "E000", "E000.0", "E000.0"), match_type = c("full_code", "full_code", "compact_code", "compact_code", "compact_code", "full_code", "full_code"), icdv = c(9L, 9L, 10L, 10L, 10L, 9L, 9L), dx = c(1L, 1L, 1L, 1L, 1L, 1L, 1L), full_code = c("E000", "E000", "E00.0", "E00.0", "E00.0", "E000.0", "E000.0"), code = c("E000", "E000", "E000", "E000", "E000", "E0000", "E0000"), src = c("cms", "cdc", "cms", "who", "cdc", "cms", "cdc"), known_start = c(2010L, 2010L, 2014L, 2008L, 2001L, 2010L, 2010L), known_end = c(2015L, 2012L, 2026L, 2019L, 2025L, 2015L, 2012L), assignable_start = c(NA, NA, 2014L, 2008L, 2001L, 2010L, 2010L), assignable_end = c(NA, NA, 2026L, 2019L, 2025L, 2015L, 2012L)), row.names = c(2L, 1L, 4L, 5L, 3L, 6L, 7L), class = "data.frame")

stopifnot(
  identical(x01, e01),
  identical(x10, e10),
  identical(x11, e11)
)

# with regex
x00 <- tryCatchError(lookup_icd_codes(x = c("E000", "E000\\.0"), regex = TRUE, full.codes = FALSE, compact.codes = FALSE))
stopifnot(inherits(x00, "error"))

# The fallowing tests may fail when ICD codes are updated.  As of 17 Nov 2025,
# there are codes with known end and assignable_end of 2026
x01 <- lookup_icd_codes(x = c("E000", "E000\\.0"), regex = TRUE, full.codes = FALSE, compact.codes = TRUE)
x10 <- lookup_icd_codes(x = c("E000", "E000\\.0"), regex = TRUE, full.codes = TRUE, compact.codes = FALSE)
x11 <- lookup_icd_codes(x = c("E000", "E000\\.0"), regex = TRUE, full.codes = TRUE, compact.codes = TRUE)

e01 <- structure(list(input_regex = c("E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000"), match_type = c("compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code"), icdv = c(9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 10L, 10L, 10L), dx = c(1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L), full_code = c("E000", "E000", "E000.0", "E000.0", "E000.1", "E000.1", "E000.2", "E000.2", "E000.8", "E000.8", "E000.9", "E000.9", "E00.0", "E00.0", "E00.0"), code = c("E000", "E000", "E0000", "E0000", "E0001", "E0001", "E0002", "E0002", "E0008", "E0008", "E0009", "E0009", "E000", "E000", "E000"), src = c("cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "who", "cdc"), known_start = c(2010L, 2010L, 2010L, 2010L, 2010L, 2010L, 2011L, 2011L, 2010L, 2010L, 2010L, 2010L, 2014L, 2008L, 2001L), known_end = c(2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2026L, 2019L, 2025L), assignable_start = c(NA, NA, 2010L, 2010L, 2010L, 2010L, 2011L, 2011L, 2010L, 2010L, 2010L, 2010L, 2014L, 2008L, 2001L), assignable_end = c(NA, NA, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2026L, 2019L, 2025L)), row.names = c(5L, 3L, 26L, 27L, 30L, 31L, 34L, 35L, 38L, 39L, 42L, 43L, 1L, 2L, 4L), class = "data.frame")
e10 <- structure(list(input_regex = c("E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000\\.0", "E000\\.0"), match_type = c("full_code", "full_code", "full_code", "full_code", "full_code", "full_code", "full_code", "full_code", "full_code", "full_code", "full_code", "full_code", "full_code", "full_code"), icdv = c(9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L), dx = c(1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L), full_code = c("E000", "E000", "E000.0", "E000.0", "E000.1", "E000.1", "E000.2", "E000.2", "E000.8", "E000.8", "E000.9", "E000.9", "E000.0", "E000.0"), code = c("E000", "E000", "E0000", "E0000", "E0001", "E0001", "E0002", "E0002", "E0008", "E0008", "E0009", "E0009", "E0000", "E0000"), src = c("cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "cdc"), known_start = c(2010L, 2010L, 2010L, 2010L, 2010L, 2010L, 2011L, 2011L, 2010L, 2010L, 2010L, 2010L, 2010L, 2010L), known_end = c(2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L), assignable_start = c(NA, NA, 2010L, 2010L, 2010L, 2010L, 2011L, 2011L, 2010L, 2010L, 2010L, 2010L, 2010L, 2010L), assignable_end = c(NA, NA, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L)), row.names = c(2L, 1L, 5L, 6L, 9L, 10L, 13L, 14L, 17L, 18L, 21L, 22L, 289L, 290L), class = "data.frame")
e11 <- structure(list(input_regex = c("E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000", "E000\\.0", "E000\\.0"), match_type = c("full_code", "full_code", "full_code", "full_code", "full_code", "full_code", "full_code", "full_code", "full_code", "full_code", "full_code", "full_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "compact_code", "full_code", "full_code"), icdv = c(9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 9L, 10L, 10L, 10L, 9L, 9L), dx = c(1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L), full_code = c("E000", "E000", "E000.0", "E000.0", "E000.1", "E000.1", "E000.2", "E000.2", "E000.8", "E000.8", "E000.9", "E000.9", "E000.0", "E000.0", "E000.1", "E000.1", "E000.2", "E000.2", "E000.8", "E000.8", "E000.9", "E000.9", "E00.0", "E00.0", "E00.0", "E000.0", "E000.0"), code = c("E000", "E000", "E0000", "E0000", "E0001", "E0001", "E0002", "E0002", "E0008", "E0008", "E0009", "E0009", "E0000", "E0000", "E0001", "E0001", "E0002", "E0002", "E0008", "E0008", "E0009", "E0009", "E000", "E000", "E000", "E0000", "E0000"), src = c("cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "cdc", "cms", "who", "cdc", "cms", "cdc"), known_start = c(2010L, 2010L, 2010L, 2010L, 2010L, 2010L, 2011L, 2011L, 2010L, 2010L, 2010L, 2010L, 2010L, 2010L, 2010L, 2010L, 2011L, 2011L, 2010L, 2010L, 2010L, 2010L, 2014L, 2008L, 2001L, 2010L, 2010L), known_end = c(2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2026L, 2019L, 2025L, 2015L, 2012L), assignable_start = c(NA, NA, 2010L, 2010L, 2010L, 2010L, 2011L, 2011L, 2010L, 2010L, 2010L, 2010L, 2010L, 2010L, 2010L, 2010L, 2011L, 2011L, 2010L, 2010L, 2010L, 2010L, 2014L, 2008L, 2001L, 2010L, 2010L), assignable_end = c(NA, NA, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2015L, 2012L, 2026L, 2019L, 2025L, 2015L, 2012L)), row.names = c(2L, 1L, 17L, 18L, 23L, 24L, 16L, 15L, 31L, 21L, 22L, 36L, 47L, 48L, 64L, 54L, 55L, 67L, 61L, 60L, 72L, 73L, 29L, 40L, 28L, 2027L, 2026L), class = "data.frame")

stopifnot(
  identical(x01, e01),
  identical(x10, e10),
  identical(x11, e11)
)

################################################################################
#                                 End of File                                  #
################################################################################
