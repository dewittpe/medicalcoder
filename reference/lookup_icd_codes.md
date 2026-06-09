# Lookup ICD Codes

Functions for working with ICD codes.

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
lookup_icd_codes(
  x,
  regex = FALSE,
  full.codes = TRUE,
  compact.codes = TRUE,
  ...
)
```

## Arguments

- x:

  Character vector of ICD codes (full or compact form). When
  `regex = TRUE`, `x` must contain at least one non-empty, non-missing
  string.

- regex:

  Logical scalar. If `TRUE`, treat `x` as regular expressions; if
  `FALSE`, use exact matching.

- full.codes:

  Logical scalar. If `TRUE` (default), match codes that include the
  decimal point where applicable.

- compact.codes:

  Logical scalar. If `TRUE` (default), match codes without the decimal
  point.

- ...:

  Passed to [`base::grep()`](https://rdrr.io/r/base/grep.html) when
  `regex = TRUE`

## Value

A `data.frame` with one or more rows per input, including columns

- `match_type`: did the input match a full or compact code

- `icdv`: icd version (9 or 10)

- `dx`: diagnostic code (1) or procedure code (0)

- `full_code`: the full code string

- `code`: the compact codes string

- `src`: the source - CMS, CDC, or WHO.

- year ranges (`known_*`, `assignable_*`).

## Details

ICD codes should be character vectors. These tools work with either
"full codes" (decimal point present when appropriate) or "compact codes"
(decimal point omitted).

Similarly for ICD-9-CM: "055" is a header for measles; 055.0, 055.1,
055.2, 055.8, and 055.9 are assignable. Codes 055.3–055.6 do not exist.
Code 055.7 is a header because 055.71 and 055.72 exist.

Some codes change status across years. For example, ICD-9-CM 516.3 was
assignable in fiscal years 1997–2011 for the CDC extracts (2006–2011 for
CMS) and became a header in 2012–2015.

## See also

- [`get_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_icd_codes.md)
  to retrieve the internal lookup table of ICD codes.

- [`is_icd()`](http://www.peteredewitt.com/medicalcoder/reference/is_icd.md)
  to test if a string is a known ICD code.

- [`icd_compact_to_full()`](http://www.peteredewitt.com/medicalcoder/reference/icd_compact_to_full.md)
  converts a string from a compact format to the full format based on
  ICD version and type (diagnostic or procedure).

Other ICD tools:
[`icd_compact_to_full()`](http://www.peteredewitt.com/medicalcoder/reference/icd_compact_to_full.md),
[`is_icd()`](http://www.peteredewitt.com/medicalcoder/reference/is_icd.md)
