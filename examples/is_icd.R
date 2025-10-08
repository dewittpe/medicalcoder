################################################################################
# Some ICD-9 diagnostic codes
x <- c("136.2", "718.60", "642.02")

is_icd(x, icdv =  9, dx = 1)
is_icd(x, icdv =  9, dx = 0)
is_icd(x, icdv = 10, dx = 1)
is_icd(x, icdv = 10, dx = 0)

is_icd(x, icdv = 9, dx = 1, headerok = TRUE)
is_icd(x, icdv = 9, dx = 1, year = 2006)

################################################################################
# ICD code with, or without a dot.  The ICD-9 diagnostic code 799.3 and ICD-9
# procedure code 79.93 both become 7993 when assessed against the ICD code look
# up tables.  As such "7993" is a valid ICD-9 diagnostic and procedure code,
# whereas 799.3 is only a valid dx code, and 79.93 is only a valid pr code.
# Further, codes such as ".7993", "7.993", "7993.", are all non-valid codes.

x <- c("7993", ".7993", "7.993", "79.93", "799.3", "7993.")
data.frame(
  x,
  dx = is_icd(x, icdv = 9, dx = 1),
  pr = is_icd(x, icdv = 9, dx = 0)
)

################################################################################
# example of a ICD-9 code that was assignable, but became a header when
# more descriptive codes were introduced: ICD-9 diagnostic code 516.3
lookup_icd_codes(paste0("516.3", c("", as.character(0:9))))

# ICD-9 code 516.3 was an assignable code through fiscal year 2011.
is_icd("516.3")

# If `year` is omitted, and `ever.assignable = FALSE` then the `year` is
# implied to be the max `known_end` year for ICD codes matched by `icdv`,
# `dx`, and `src`.
is_icd("516.3", ever.assignable = FALSE)

# when `year` is provided then `ever.assignable` is `FALSE` by default and
# the return is TRUE when 516.3 was assignable and FALSE otherwise.
is_icd("516.3", year = 2015)
is_icd("516.3", year = 2011)

# when year is a non-assignable year, but `ever.assignable = TRUE` the return
# will be TRUE.  Useful if you know the data is retrospective and collected
# through fiscal year 2015.
is_icd("516.3", year = 2015, ever.assignable = TRUE)

################################################################################
# Consiser the string E010
#   - This could be a ICD-9-CM full code
#   - Could be a ICD-10-CM compact code
lookup_icd_codes("E010")
subset(get_icd_codes(with.descriptions = TRUE), grepl("^E010$", code))

is_icd("E010")
is_icd("E010", icdv = 9) # FALSE because it is a header code and was never assignable
is_icd("E010", icdv = 9, ever.assignable = TRUE) # FALSE
is_icd("E010", icdv = 9, headerok = TRUE) # TRUE
