library(medicalcoder)

################################################################################
# a code of length 1 should not be a valid code for either ICD-9 or ICD-10, that
# is because the minimum number of characters for ICD-9-CM ICD-10-CM is three,
# ICD-10-PCS is seven, and ICD-9-PCS is two.  The folowing tests verify that
# is_icd will return FALSE any reasonable one characters string.
#
# tests:
#
#   code_length_one_default: use the default call to is_icd
#   code_length_one_icd9dx:  test against just ICD-9 diagnostic codes
#   code_length_one_icd9pr:  test against just ICD-9 procedure codes
#   code_length_one_icd10dx: test against just ICD-10 diagnostic codes
#   code_length_one_icd10pr: test against just ICD-10 procedure codes
#
one_char_codes <- c(LETTERS, as.character(0:9))
default <- is_icd(one_char_codes)
icd9dx  <- is_icd(one_char_codes, icdv =  9L, dx = 1L)
icd9pr  <- is_icd(one_char_codes, icdv =  9L, dx = 0L)
icd10dx <- is_icd(one_char_codes, icdv = 10L, dx = 1L)
icd10pr <- is_icd(one_char_codes, icdv = 10L, dx = 0L)

stopifnot(
  code_length_one_default = length(default) == 36L && !any(default),
  code_length_one_icd9dx  = length(icd9dx)  == 36L && !any(icd9dx),
  code_length_one_icd9pr  = length(icd9pr)  == 36L && !any(icd9pr),
  code_length_one_icd10dx = length(icd10dx) == 36L && !any(icd10dx),
  code_length_one_icd10pr = length(icd10pr) == 36L && !any(icd10pr)
)

################################################################################
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
# Warn if user provides a year before the earliest known year.  Note: ICD-9 in
# the United states went into effect for
# fiscal year 1980 (Oct 1, 1979 - Sept 30, 1980).  Any year before 1980 will
# generate this error no matter how much data is in the internal lookup tables
# for ICD-9, at least based on the US version.  As of Oct 2025 and pre public
# release of medicalcoder, the earliest known year is 1997.
#
# This should work based on different sets of codes too.  For example, using the
# data in medicalcoder 0.0.0.9045, the warning should be thrown based on the
# version and source.
#
#   > as.data.table(get_icd_codes())[, min(known_start), by = .(src, icdv)]
#         src  icdv    V1
#      <char> <int> <int>
#   1:    cms     9  1997
#   2:    cms    10  2014
#   3:    cdc    10  2001
#   4:    who    10  2008
w1 <- tryCatch(is_icd("516.3", year = 1979), warning = function(w) w)
w2 <- tryCatch(is_icd("516.3", year = 1979, icdv = 9), warning = function(w) w)
w3 <- tryCatch(is_icd("516.3", year = 2000, icdv = 9), warning = function(w) w)
w4 <- tryCatch(is_icd("516.3", year = 2000, icdv = 10), warning = function(w) w)
w5 <- tryCatch(is_icd("516.3", year = 2009, icdv = 10), warning = function(w) w)
w6 <- tryCatch(is_icd("516.3", year = 2009, icdv = 10, src = "cms"), warning = function(w) w)

stopifnot(
  "Year before first known year generates an warning: w1" = inherits(w1, "warning"),
  "Year before first known year generates an warning: w2" = inherits(w2, "warning"),
  "year = 2000 does not generate a warning for icdv 9"    = !inherits(w3, "warning"),
  "year = 2000 generates a warning for icdv 10"           = inherits(w4, "warning"),
  "year = 2009 does not generate a warning for icdv 10"   = !inherits(w5, "warning"),
  "year = 2009 does generate a warning for icdv 10 with src = cms" = inherits(w6, "warning")
)


################################################################################
# ICD-9 516.3 is a good test for ever.assignable and year.  It was assignable
# from 1997 through 2011, and then a header code through the end of ICD-9 in
# 2015.
#
# t1:
#   default call to is_icd for code 516.3 is TRUE becuase year is missing and
#   thus treated as most current, and ever.billable is TRUE because year was
#   missing
#
# t2:
#   explicitly use ever.assignable = TRUE
#
# t3:
#   with ever.assignable = FALSE and year missing the return should be FALSE as
#   the code was not assignable in the most current year.
#
# t4:
#   with ever.assignable = FALSE and year = 2012 the return will be FALSE
#   becuase 516.3 was not assignable in 2012
#
# t5:
#   with ever.assignable = TRUE and year = 2012 the return will be TRUE
#   becuase 516.3 was billable prior to 2012
#
# t6:
#   with ever.assignable = FALSE and year = 2011 the return will be TRUE becuase
#   516.3 was assignable in 2011

stopifnot(
  "t1" =  is_icd("516.3"),
  "t2" =  is_icd("516.3", ever.assignable = TRUE),
  "t3" = !is_icd("516.3", ever.assignable = FALSE),
  "t4" = !is_icd("516.3", ever.assignable = FALSE, year = 2012),
  "t5" =  is_icd("516.3", ever.assignable = TRUE, year = 2012),
  "t6" =  is_icd("516.3", ever.assignable = FALSE, year = 2011)
  )

################################################################################
#                                 End of File                                  #
################################################################################
