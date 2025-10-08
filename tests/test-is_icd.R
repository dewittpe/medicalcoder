library(medicalcoder)

# a code of length 1 should not be a valid code for either ICD-9 or ICD-10
x <- is_icd(c(LETTERS, as.character(0:9)))
stopifnot(length(x) == 36L, !any(x))

x <- is_icd(c(LETTERS, as.character(0:9)), icdv = 9, dx = 1L)
stopifnot(length(x) == 36L, !any(x))

x <- is_icd(c(LETTERS, as.character(0:9)), icdv = 9, dx = 0L)
stopifnot(length(x) == 36L, !any(x))

x <- is_icd(c(LETTERS, as.character(0:9)), icdv = 10, dx = 1L)
stopifnot(length(x) == 36L, !any(x))

x <- is_icd(c(LETTERS, as.character(0:9)), icdv = 10, dx = 0L)
stopifnot(length(x) == 36L, !any(x))

# For ICD-9 test that the presense of a dot is considered when testing.
# Example 7993 is the simplified version of the proper ICD-9 DX code 799.3 and
# PR code 79.93.  Becuase the look up tables use 7993, the input of 7993 will be
# valid code for both dx and pr.  if a dot is present, consider it, and return
# FALSE if the dot is in the wrong place

x <- c("7993", ".7993", "7.993", "79.93", "799.3", "7993.")
stopifnot(
  identical(is_icd(x, icdv =  9, dx = 1L), c(TRUE, FALSE, FALSE, FALSE, TRUE, FALSE)),
  identical(is_icd(x, icdv =  9, dx = 0L), c(TRUE, FALSE, FALSE, TRUE, FALSE, FALSE)),
  !any(is_icd(x, icdv = 10, dx = 1L)),
  !any(is_icd(x, icdv = 10, dx = 0L))
)

# expect a warning that 7993 is ambiguous
x <- tryCatch(is_icd("7993"), warning = function(w) w)
stopifnot(inherits(x, "warning"))

# For ICD-10 dx, if there is a dot, it need be the fourth character
# C44.1121 (basal cell carcinoma of skn of right upper eyelide, including
# canthus) is a valid code, so "C441121" should return TRUE and a dot anywere
# other than the fourth character should be FALSE.
x <- c("C441121",
       ".C441121",
       "C.441121",
       "C4.41121",
       "C44.1121",
       "C441.121",
       "C4411.21",
       "C44112.1",
       "C441121.")
stopifnot(
  identical(is_icd(x, icdv = 10, dx = 1L), c(TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE)),
  !any(is_icd(x, icdv = 9, dx = 1L)),
  !any(is_icd(x, icdv = 9, dx = 0L)),
  !any(is_icd(x, icdv = 10, dx = 0L))
  )

# another example
x <- c("Y389X2S",
       ".Y389X2S",
       "Y.389X2S",
       "Y3.89X2S",
       "Y38.9X2S",
       "Y389.X2S",
       "Y389X.2S",
       "Y389X2.S",
       "Y389X2S.")
stopifnot(
  identical(is_icd(x), c(TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE)),
  identical(is_icd(x, icdv = 10, dx = 1L), c(TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE)),
  !any(is_icd(x, icdv = 9, dx = 1L)),
  !any(is_icd(x, icdv = 9, dx = 0L)),
  !any(is_icd(x, icdv = 10, dx = 0L))
  )

# ICD 10 pr codes have no dots
x <- c("0016074",
       ".0016074",
       "0.016074",
       "00.16074",
       "001.6074",
       "0016.074",
       "00160.74",
       "001607.4",
       "0016074.")
stopifnot(
  identical(is_icd(x), c(TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)),
  identical(is_icd(x, icdv = 10, dx = 0L), c(TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)),
  !any(is_icd(x, icdv = 9, dx = 1L)),
  !any(is_icd(x, icdv = 9, dx = 0L)),
  !any(is_icd(x, icdv = 10, dx = 1L))
  )

################################################################################
# Ever assignable status of ICD-9 516.3
# lookup_icd_codes("516\\.3", regex = TRUE)
stopifnot(
    is_icd("516.3")              # TRUE, because it was assignable through 2011
  , is_icd("516.3", year = 1998) # TRUE, it was assignable
  , is_icd("516.3", year = 1999) # TRUE, it was assignable
  , is_icd("516.3", year = 2000) # TRUE, it was assignable
  , is_icd("516.3", year = 2001) # TRUE, it was assignable
  , is_icd("516.3", year = 2002) # TRUE, it was assignable
  , is_icd("516.3", year = 2003) # TRUE, it was assignable
  , is_icd("516.3", year = 2004) # TRUE, it was assignable
  , is_icd("516.3", year = 2004) # TRUE, it was assignable
  , is_icd("516.3", year = 2005) # TRUE, it was assignable
  , is_icd("516.3", year = 2006) # TRUE, it was assignable
  , is_icd("516.3", year = 2007) # TRUE, it was assignable
  , is_icd("516.3", year = 2008) # TRUE, it was assignable
  , is_icd("516.3", year = 2009) # TRUE, it was assignable
  , is_icd("516.3", year = 2010) # TRUE, it was assignable
  , is_icd("516.3", year = 2011) # TRUE, it was assignable
  , !is_icd("516.3", year = 2012) # FALSE, not assignable
  , !is_icd("516.3", year = 2013) # FALSE, not assignable
  , !is_icd("516.3", year = 2014) # FALSE, not assignable
  , !is_icd("516.3", year = 2015) # FALSE, not assignable
  , !is_icd("516.3", year = 2016) # FALSE, not assignable
)

################################################################################
#
# check
x <- c("E010", "C84.1", "Not a Code", "C04", "E010", "021", "V91.1", NA, "E010",
       "021")

default_rtn <-
  is_icd(x, headerok = TRUE, ever.assignable = TRUE, warn.ambiguous = FALSE)

stopifnot(identical(default_rtn, c(TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, NA, TRUE, TRUE)))

warn <-
  tryCatch(
    is_icd(x, headerok = TRUE, ever.assignable = TRUE, warn.ambiguous = TRUE),
    warning = function(w) w)
stopifnot(inherits(warn, "warning"))

################################################################################
# Warn and set year to the first known year if user provides a year before the
# earliest known year
w <-
  tryCatch(
    is_icd("516.3", year = 1876),
    warning = function(w) w
  )

stopifnot(
  "TODO: Year before first known year generates an warning" = inherits(w, "warning")
)

is_icd("NOT A CODE", dx = 0, src = c("who", "hg"))

################################################################################
# ICD-9 516.3 is a good test for ever.assignable and year.  It was assignable
# from 1997 through 2011, and then a header code through the end of ICD-9 in
# 2015.

stopifnot(
  "Default call to is_icd for 516.3 is TRUE" = is_icd("516.3")
  )

is_icd("516.3", ever.assignable = TRUE)
is_icd("516.3", ever.assignable = TRUE, year = 1832)
is_icd("516.3", ever.assignable = FALSE, year = 1832)


################################################################################
#                                 End of File                                  #
################################################################################
