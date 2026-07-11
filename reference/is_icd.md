# Is ICD

Answer the question "is the character string x a valid ICD code?" ICD
codes should be character vectors. `is_icd` will assess for both "full
codes" (decimal point present when appropriate) and "compact codes"
(decimal point omitted).

ICD-10 code "C00" is a header code because the four-character codes
C00.0, C00.1, C00.2, C00.3, C00.4, C00.5, C00.6, C00.7, C00.8, and C00.9
exist. Those four-character codes are assignable (as of 2025) because no
five-character descendants (e.g., C00.40) exist.

When the source is the World Health Organization (WHO), CDC Mortality,
or Socialstyrelsen, years refer to calendar years. CMS sources use the
U.S. federal fiscal year, which starts on October 1 (e.g., fiscal year
2024 runs 2023-10-01 to 2024-09-30). IHACPA sources use the Australian
financial year, which starts on July 1 and ends on June 30.

## Usage

``` r
is_icd(
  x,
  icdv = c(9L, 10L),
  dx = c(1L, 0L),
  src = c("cdc", "cms", "ihacpa", "socialstyrelsen", "who"),
  year,
  headerok = FALSE,
  ever.assignable = missing(year),
  warn.ambiguous = TRUE,
  full.codes = TRUE,
  compact.codes = TRUE
)
```

## Arguments

- x:

  Character vector of ICD codes (full or compact form).

- icdv:

  Integer vector of allowed ICD versions. Use `9L` and/or `10L`.
  Defaults to both.

- dx:

  Integer vector indicating allowed code type(s): `1L` for diagnostic
  (ICD-9-CM, ICD-10-CM, ICD-10-AM, ICD-10-SE, CDC mortality, WHO), `0L`
  for procedural (ICD-9-PCS, ICD-10-PCS). Defaults to both.

- src:

  Character vector of code sources. One or more of `"cdc"`, `"cms"`,
  `"ihacpa"`, `"socialstyrelsen"`, and `"who"`. Defaults to all. CDC and
  CMS are from the United States (ICD-9/10-CM and ICD-9/10-PCS), IHACPA
  from Australia (ICD-10-AM), Socialstyrelsen from Sweden (ICD-10-SE),
  and the World Health Organization (ICD-10).

- year:

  Numeric scalar. Calendar, fiscal, or financial year to reference.
  Default is the most current year available per source. For ICD-9, CMS
  data run through fiscal year 2015 and CDC extracts through 2012;
  ICD-10 sources are updated annually. Calendar year for WHO, CDC
  mortality, and Socialstyrelsen. U.S. federal fiscal year for CMS.
  Australian financial year for IHACPA.

- headerok:

  Logical scalar. If `FALSE` (default), only assignable codes are
  considered valid; if `TRUE`, header codes are also accepted.

- ever.assignable:

  Logical scalar. If `TRUE` then ignore `year` and return `TRUE` if the
  `x` was ever an assignable code.

- warn.ambiguous:

  Logical scalar. If `TRUE` (default), warn when a code matches more
  than one ICD version and/or type (e.g., both CM and PCS).

- full.codes:

  Logical scalar. If `TRUE` (default), match codes that include the
  decimal point where applicable.

- compact.codes:

  Logical scalar. If `TRUE` (default), match codes without the decimal
  point.

## Value

A logical vector the same length as `x`.

## Details

Similarly for ICD-9-CM: "055" is a header for measles; 055.0, 055.1,
055.2, 055.8, and 055.9 are assignable. Codes 055.3–055.6 do not exist.
Code 055.7 is a header because 055.71 and 055.72 exist.

Some codes change status across years. For example, ICD-9-CM 516.3 was
assignable in fiscal years 1997–2011 for the CDC extracts (2006–2011 for
CMS) and became a header in 2012–2015.

## See also

- [`get_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_icd_codes.md)
  to retrieve the internal lookup table of ICD codes.

- [`lookup_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/lookup_icd_codes.md)
  for retrieving details on a specific set of ICD codes.

- [`icd_compact_to_full()`](http://www.peteredewitt.com/medicalcoder/reference/icd_compact_to_full.md)
  converts a string from a compact format to the full format based on
  ICD version and type (diagnostic or procedure).

Other ICD tools:
[`icd_compact_to_full()`](http://www.peteredewitt.com/medicalcoder/reference/icd_compact_to_full.md),
[`lookup_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/lookup_icd_codes.md)

## Examples

``` r
################################################################################
# Some ICD-9 diagnostic codes
x <- c("136.2", "718.60", "642.02")

is_icd(x, icdv =  9L, dx = 1L)
#> [1] TRUE TRUE TRUE
is_icd(x, icdv =  9L, dx = 0L)
#> [1] FALSE FALSE FALSE
is_icd(x, icdv = 10L, dx = 1L)
#> [1] FALSE FALSE FALSE
is_icd(x, icdv = 10L, dx = 0L)
#> [1] FALSE FALSE FALSE

is_icd(x, icdv = 9L, dx = 1L, headerok = TRUE)
#> [1] TRUE TRUE TRUE
is_icd(x, icdv = 9L, dx = 1L, year = 2006)
#> [1] TRUE TRUE TRUE

################################################################################
# ICD code with, or without a dot.  The ICD-9 diagnostic code 799.3 and ICD-9
# procedure code 79.93 both become 7993 when assessed against the ICD code look
# up tables.  As such "7993" is a valid ICD-9 diagnostic and procedure code,
# whereas 799.3 is only a valid dx code, and 79.93 is only a valid pr code.
# Further, codes such as ".7993", "7.993", "7993.", are all non-valid codes.

x <- c("7993", ".7993", "7.993", "79.93", "799.3", "7993.")
data.frame(
  x,
  dx = is_icd(x, icdv = 9L, dx = 1L),
  pr = is_icd(x, icdv = 9L, dx = 0L)
)
#>       x    dx    pr
#> 1  7993  TRUE  TRUE
#> 2 .7993 FALSE FALSE
#> 3 7.993 FALSE FALSE
#> 4 79.93 FALSE  TRUE
#> 5 799.3  TRUE FALSE
#> 6 7993. FALSE FALSE

################################################################################
# example of a ICD-9 code that was assignable, but became a header when
# more descriptive codes were introduced: ICD-9 diagnostic code 516.3
lookup_icd_codes(paste0("516.3", c("", as.character(0:9))))
#>    input_code match_type icdv dx full_code  code  src known_start known_end
#> 1       516.3  full_code    9  1     516.3  5163  cms        2006      2015
#> 2       516.3  full_code    9  1     516.3  5163  cdc        1997      2012
#> 3      516.30  full_code    9  1    516.30 51630  cms        2012      2015
#> 4      516.30  full_code    9  1    516.30 51630  cdc        2012      2012
#> 5      516.31  full_code    9  1    516.31 51631  cms        2012      2015
#> 6      516.31  full_code    9  1    516.31 51631  cdc        2012      2012
#> 7      516.32  full_code    9  1    516.32 51632  cms        2012      2015
#> 8      516.32  full_code    9  1    516.32 51632  cdc        2012      2012
#> 9      516.33  full_code    9  1    516.33 51633  cms        2012      2015
#> 10     516.33  full_code    9  1    516.33 51633  cdc        2012      2012
#> 11     516.34  full_code    9  1    516.34 51634  cms        2012      2015
#> 12     516.34  full_code    9  1    516.34 51634  cdc        2012      2012
#> 13     516.35  full_code    9  1    516.35 51635  cms        2012      2015
#> 14     516.35  full_code    9  1    516.35 51635  cdc        2012      2012
#> 15     516.36  full_code    9  1    516.36 51636  cms        2012      2015
#> 16     516.36  full_code    9  1    516.36 51636  cdc        2012      2012
#> 17     516.37  full_code    9  1    516.37 51637  cms        2012      2015
#> 18     516.37  full_code    9  1    516.37 51637  cdc        2012      2012
#> 19     516.38       <NA>   NA NA      <NA>  <NA> <NA>          NA        NA
#> 20     516.39       <NA>   NA NA      <NA>  <NA> <NA>          NA        NA
#>    assignable_start assignable_end
#> 1              2006           2011
#> 2              1997           2011
#> 3              2012           2015
#> 4              2012           2012
#> 5              2012           2015
#> 6              2012           2012
#> 7              2012           2015
#> 8              2012           2012
#> 9              2012           2015
#> 10             2012           2012
#> 11             2012           2015
#> 12             2012           2012
#> 13             2012           2015
#> 14             2012           2012
#> 15             2012           2015
#> 16             2012           2012
#> 17             2012           2015
#> 18             2012           2012
#> 19               NA             NA
#> 20               NA             NA

# ICD-9 code 516.3 was an assignable code through fiscal year 2011.
is_icd("516.3")
#> [1] TRUE

# If `year` is omitted, and `ever.assignable = FALSE` then the `year` is
# implied to be the max `known_end` year for ICD codes matched by `icdv`,
# `dx`, and `src`.
is_icd("516.3", ever.assignable = FALSE)
#> [1] FALSE

# when `year` is provided then `ever.assignable` is `FALSE` by default and
# the return is TRUE when 516.3 was assignable and FALSE otherwise.
is_icd("516.3", year = 2015)
#> [1] FALSE
is_icd("516.3", year = 2011)
#> [1] TRUE

# when year is a non-assignable year, but `ever.assignable = TRUE` the return
# will be TRUE.  Useful if you know the data is retrospective and collected
# through fiscal year 2015.
is_icd("516.3", year = 2015, ever.assignable = TRUE)
#> [1] TRUE

################################################################################
# Consider the string E010
#   - This could be an ICD-9-CM full code
#   - Could be an ICD-10-CM compact code
lookup_icd_codes("E010")
#>   input_code   match_type icdv dx full_code code             src known_start
#> 1       E010    full_code    9  1      E010 E010             cms        2010
#> 2       E010    full_code    9  1      E010 E010             cdc        2010
#> 3       E010 compact_code   10  1     E01.0 E010             cms        2014
#> 4       E010 compact_code   10  1     E01.0 E010             cdc        2001
#> 5       E010 compact_code   10  1     E01.0 E010          ihacpa        2020
#> 6       E010 compact_code   10  1     E01.0 E010 socialstyrelsen        1997
#> 7       E010 compact_code   10  1     E01.0 E010             who        2008
#>   known_end assignable_start assignable_end
#> 1      2015               NA             NA
#> 2      2012               NA             NA
#> 3      2026             2014           2026
#> 4      2025             2001           2025
#> 5      2026             2020           2026
#> 6      2026             1997           2026
#> 7      2021             2008           2021
subset(get_icd_codes(with.descriptions = TRUE), grepl("^E010$", code))
#>        icdv dx full_code code             src known_start known_end
#> 47745     9  1      E010 E010             cms        2010      2015
#> 47746     9  1      E010 E010             cdc        2010      2012
#> 153669   10  1     E01.0 E010             cms        2014      2026
#> 153670   10  1     E01.0 E010             cdc        2001      2025
#> 153671   10  1     E01.0 E010          ihacpa        2020      2026
#> 153672   10  1     E01.0 E010             who        2008      2021
#> 153673   10  1     E01.0 E010 socialstyrelsen        1997      2026
#>        assignable_start assignable_end
#> 47745                NA             NA
#> 47746                NA             NA
#> 153669             2014           2026
#> 153670             2001           2025
#> 153671             2020           2026
#> 153672             2008           2021
#> 153673             1997           2026
#>                                                           desc desc_start
#> 47745  Activity involving other muscle strengthening exercises       2010
#> 47746  Activity involving other muscle strengthening exercises       2010
#> 153669      Iodine-deficiency related diffuse (endemic) goiter       2014
#> 153670      Iodine-deficiency-related diffuse (endemic) goiter       2001
#> 153671      Iodine-deficiency-related diffuse (endemic) goitre       2020
#> 153672      Iodine-deficiency-related diffuse (endemic) goitre       2008
#> 153673              Jodbristrelaterad diffus (endemisk) struma       1997
#>        desc_end
#> 47745      2015
#> 47746      2012
#> 153669     2026
#> 153670     2025
#> 153671     2026
#> 153672     2021
#> 153673     2026

is_icd("E010")
#> [1] TRUE
is_icd("E010", icdv = 9L) # FALSE because it is a header code and was never assignable
#> [1] FALSE
is_icd("E010", icdv = 9L, ever.assignable = TRUE) # FALSE
#> [1] FALSE
is_icd("E010", icdv = 9L, headerok = TRUE) # TRUE
#> [1] TRUE
```
