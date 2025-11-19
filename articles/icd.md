# ICD Codes

There are four functions in the `medicalcoder` package specifically for
working with International Classification of Diseases (ICD) codes.

1.  [`get_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_icd_codes.md):
    returns a look up table of ICD codes as a `data.frame`.
2.  [`lookup_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/lookup_icd_codes.md):
    returns details on specific ICD codes.
3.  [`is_icd()`](http://www.peteredewitt.com/medicalcoder/reference/is_icd.md):
    returns `TRUE` or `FALSE` for a vector of codes while considering
    ICD version, type, and billable status.
4.  [`icd_compact_to_full()`](http://www.peteredewitt.com/medicalcoder/reference/icd_compact_to_full.md):
    insert a decimal point into a string to be consistent with ICD-9
    diagnostic, ICD-9 procedure, or ICD-10 diagnostic codes. (ICD-10
    procedure codes do not have decimal places.) NOTE: this will not
    validate the return as a valid ICD code, just format the input
    string appropriately.

## `get_icd_codes()`

A look up table for the ICD codes have been built as internal data sets
within the `medicalcoder` package. The sources for these look up tables
come from the Centers for Disease Control (CDC) and from the Centers for
Medicare & Medicaid Services (CMS). The specific links to the source
data sets can be found in the source code for the `medicalcoder` package
on [GitHub](https://github.com/dewittpe/medicalcoder).

End users can get a `data.frame` with ICD-9 diagnostic, ICD-9 procedure,
ICD-10 diagnostic, and ICD-10 procedure codes.

``` r
library(medicalcoder)
icd_codes <- get_icd_codes()
str(icd_codes)
## 'data.frame':    227534 obs. of  9 variables:
##  $ icdv            : int  9 9 9 9 9 9 9 9 9 9 ...
##  $ dx              : int  0 0 0 0 0 0 1 0 1 0 ...
##  $ full_code       : chr  "00" "00.0" "00.01" "00.02" ...
##  $ code            : chr  "00" "000" "0001" "0002" ...
##  $ src             : chr  "cms" "cms" "cms" "cms" ...
##  $ known_start     : int  2003 2003 2003 2003 2003 2003 1997 2003 1997 2003 ...
##  $ known_end       : int  2015 2015 2015 2015 2015 2015 2015 2015 2015 2015 ...
##  $ assignable_start: int  NA NA 2003 2003 2003 2003 NA NA 1997 2003 ...
##  $ assignable_end  : int  NA NA 2015 2015 2015 2015 NA NA 2015 2015 ...
```

The columns of this data.frame are:

- `icdv`: integer value 9 or 10 indicating ICD-9 or ICD-10

- `dx`: 1 if the code is a diagnostic code, i.e., from the ICD-9-CM or
  ICD-10-CM standard. This also covers codes from the World Health
  Organization (WHO) and the Center for Disease Control and
  Prevention (CDC) Mortality codes. `dx` will be 0 if the code is a
  procedure code, i.e., from the ICD-9-PCS or ICD-10-PCS standard.

- `full_code`: the full ICD code with the decimal point if applicable.

- `code`: compact code, any applicable decimal point has been omitted.

- `src`: a character vector denoting the source of the information.

- `known_start`: The first year that the `medicalcoder` package as data
  for this code.

  - For codes based on the ICD-9-CM, ICD-9-PCS, ICD-10-CM, ICD-10-PCS
    standards the year is the *fiscal year* for the United States
    Federal Government; October 1 - September 30. For example, fiscal
    year 2018 started October 1, 2017 and ended on September 30, 2018.

  - For codes from the World Health Organization (WHO) and the Centers
    for Disease Control and Prevention (CDC) Mortality coding, the year
    is *calendar year*.

- `known_end`: the last year the code was part of the standard, or that
  the `medicalcoder` package has data for.

  - ICD-9 last year of active use was FY 2015.
  - ICD-10 is active. The current version of `medicalcoder` has details
    on ICD-10 codes through FY 2026.

- `assignable_start`: The first year (fiscal or calendar based on src) a
  code was assignable. `NA` indicates the code was never assignable.
  Assignable status can vary from source to source. For example the code
  “C84.6” is an assignable code using the WHO ICD-10 codes because there
  is no code with more granularity. The same code is not assignable
  under ICD-10-CM because codes C84.60, C84.61, C84.62, C84.63, C84.64,
  C84.65, C84.66, C84.67, C84.68, C84.69, C84.6A exist. Codes that are
  not assignable are called header codes. Ideally codes are reported
  with the greatest level of granularity, but that is not always the
  case.

- `assignable_end`: The last year the code was assignable.

### with.descriptions

To get the descriptions of the ICD codes call
[`get_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_icd_codes.md)
with `with.descriptions = TRUE`.

``` r
str(get_icd_codes(with.descriptions = TRUE))
## 'data.frame':    241988 obs. of  12 variables:
##  $ icdv            : int  9 9 9 9 9 9 9 9 9 9 ...
##  $ dx              : int  0 0 0 0 0 0 1 0 1 1 ...
##  $ full_code       : chr  "00" "00.0" "00.01" "00.02" ...
##  $ code            : chr  "00" "000" "0001" "0002" ...
##  $ src             : chr  "cms" "cms" "cms" "cms" ...
##  $ known_start     : int  2003 2003 2003 2003 2003 2003 1997 2003 1997 1997 ...
##  $ known_end       : int  2015 2015 2015 2015 2015 2015 2015 2015 2015 2015 ...
##  $ assignable_start: int  NA NA 2003 2003 2003 2003 NA NA 1997 1997 ...
##  $ assignable_end  : int  NA NA 2015 2015 2015 2015 NA NA 2015 2015 ...
##  $ desc            : chr  "Procedures and interventions, Not Elsewhere Classified" "Therapeutic ultrasound" "Therapeutic ultrasound of vessels of head and neck" "Therapeutic ultrasound of heart" ...
##  $ desc_start      : int  2003 2003 2003 2003 2003 2003 1997 2003 1997 2010 ...
##  $ desc_end        : int  2015 2015 2015 2015 2015 2015 2015 2015 2009 2015 ...
```

The return has the additional columns:

- `desc`: the description of the code
- `desc_start`: the first fiscal_year that the description was
  documented
- `desc_end`: the last fiscal_year that the description was documented

Over time the descriptions for some ICD codes were modified within
sources. There are also many differences between sources. The tables
below have several examples.

``` r
delta_in_desc <-
  subset(
    get_icd_codes(with.descriptions = TRUE),
    subset = full_code %in% c("Z88.7", "010.93", "V76.49"),
    select = c("full_code", "src", "desc", "desc_start", "desc_end")
  )
```

The only difference in the description for 010.93 is a comma.

| full_code | src | desc                                                                                         | desc_start | desc_end |
|:----------|:----|:---------------------------------------------------------------------------------------------|-----------:|---------:|
| 010.93    | cms | Primary tuberculous infection, unspecified tubercle bacilli found (in sputum) by microscopy  |       1997 |     2009 |
| 010.93    | cms | Primary tuberculous infection, unspecified, tubercle bacilli found (in sputum) by microscopy |       2010 |     2015 |

ICD-10-CM Z88.7 has differences in the description over time within
`cms` source and between `cms` and `who`.

| full_code | src | desc                                             | desc_start | desc_end |
|:----------|:----|:-------------------------------------------------|-----------:|---------:|
| Z88.7     | cms | Allergy status to serum and vaccine status       |       2014 |     2020 |
| Z88.7     | cms | Allergy status to serum and vaccine              |       2021 |     2026 |
| Z88.7     | who | Personal history of allergy to serum and vaccine |       2008 |     2019 |

ICD-9-CM V79.49 had the description of ‘other’ which would require
exploration of the header codes to understand. Even when the most
verbose description may still require consideration of the header codes
to fullye understand.

| full_code | src | desc                                                     | desc_start | desc_end |
|:----------|:----|:---------------------------------------------------------|-----------:|---------:|
| V76.49    | cms | Other                                                    |       1997 |     1999 |
| V76.49    | cms | Other sites                                              |       2001 |     2009 |
| V76.49    | cms | Special screening for malignant neoplasms of other sites |       2010 |     2015 |

### with.hierarchy

Lastly, the
[`get_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_icd_codes.md)
function includes the argument `with.hierarchy` which will provide
additional details for the codes.

``` r
str(get_icd_codes(with.hierarchy = TRUE))
## 'data.frame':    227534 obs. of  16 variables:
##  $ icdv                : int  10 10 10 10 10 10 10 10 10 10 ...
##  $ dx                  : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ full_code           : chr  "001" "0016070" "0016071" "0016072" ...
##  $ code                : chr  "001" "0016070" "0016071" "0016072" ...
##  $ src                 : chr  "cms" "cms" "cms" "cms" ...
##  $ known_start         : int  2014 2014 2014 2014 2014 2014 2014 2014 2014 2014 ...
##  $ known_end           : int  2026 2026 2026 2026 2026 2026 2026 2026 2026 2026 ...
##  $ assignable_start    : int  NA 2014 2014 2014 2014 2014 2014 2014 2014 2014 ...
##  $ assignable_end      : int  NA 2026 2026 2026 2026 2026 2026 2026 2026 2026 ...
##  $ chapter             : chr  "0  Medical and Surgical" "0  Medical and Surgical" "0  Medical and Surgical" "0  Medical and Surgical" ...
##  $ subchapter          : chr  "00 Central Nervous System and Cranial Nerves" "00 Central Nervous System and Cranial Nerves" "00 Central Nervous System and Cranial Nerves" "00 Central Nervous System and Cranial Nerves" ...
##  $ category            : chr  "001" "001" "001" "001" ...
##  $ subcategory         : chr  NA "0016" "0016" "0016" ...
##  $ subclassification   : chr  NA "00160" "00160" "00160" ...
##  $ subsubclassification: chr  NA "001607" "001607" "001607" ...
##  $ extension           : chr  NA "0016070" "0016071" "0016072" ...
```

The additional columns, in order of hierarchy, are:

- chapter
- subchapter
- category
- subcategory
- subclassification
- subsubclassification
- extension

To keep the install size of `medicalcoder` under the size limits for
CRAN, the stored data is structured in a way that several joins and
other operations are need to have a data set that is end user friendly.
Several data sets are generated and cached when the namespace is loaded.

## `lookup_icd_codes()`

A related function,
[`lookup_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/lookup_icd_codes.md),
allows the user to look up specific ICD codes. The return is a
`data.frame`. The columns report the input code, if it was matched as a
full code (with an applicable decimal point) or a compact code
(applicable decimal point omitted) along with the ICD version ,type, and
when the code was assignable.

``` r
codes <- c("0011", "7329", "732", "73291", "not a code", "001.1", "A9248", "A924", "Z00")
knitr::kable(lookup_icd_codes(codes), row.names = FALSE)
```

| input_code | match_type   | icdv |  dx | full_code | code | src | known_start | known_end | assignable_start | assignable_end |
|:-----------|:-------------|-----:|----:|:----------|:-----|:----|------------:|----------:|-----------------:|---------------:|
| 0011       | compact_code |    9 |   0 | 00.11     | 0011 | cms |        2003 |      2015 |             2003 |           2015 |
| 0011       | compact_code |    9 |   1 | 001.1     | 0011 | cms |        1997 |      2015 |             1997 |           2015 |
| 7329       | compact_code |    9 |   1 | 732.9     | 7329 | cms |        1997 |      2015 |             1997 |           2015 |
| 732        | compact_code |    9 |   0 | 73.2      | 732  | cms |        1997 |      2015 |               NA |             NA |
| 732        | full_code    |    9 |   1 | 732       | 732  | cms |        1997 |      2015 |               NA |             NA |
| 73291      | NA           |   NA |  NA | NA        | NA   | NA  |          NA |        NA |               NA |             NA |
| not a code | NA           |   NA |  NA | NA        | NA   | NA  |          NA |        NA |               NA |             NA |
| 001.1      | full_code    |    9 |   1 | 001.1     | 0011 | cms |        1997 |      2015 |             1997 |           2015 |
| A9248      | NA           |   NA |  NA | NA        | NA   | NA  |          NA |        NA |               NA |             NA |
| A924       | compact_code |   10 |   1 | A92.4     | A924 | who |        2008 |      2019 |             2008 |           2019 |
| A924       | compact_code |   10 |   1 | A92.4     | A924 | cdc |        2001 |      2025 |             2001 |           2025 |
| A924       | compact_code |   10 |   1 | A92.4     | A924 | cms |        2014 |      2026 |             2014 |           2026 |
| Z00        | full_code    |   10 |   1 | Z00       | Z00  | cms |        2014 |      2026 |               NA |             NA |
| Z00        | full_code    |   10 |   1 | Z00       | Z00  | who |        2008 |      2019 |               NA |             NA |

It is possible to restrict the look up to just full or compact codes.
The default, as shown above, is to consider full and compact codes. Set
`full.codes = FALSE` so only compact codes are considered.

``` r
knitr::kable(
  lookup_icd_codes(codes, full.codes = FALSE),
  row.names = FALSE
)
```

| input_code | match_type   | icdv |  dx | full_code | code | src | known_start | known_end | assignable_start | assignable_end |
|:-----------|:-------------|-----:|----:|:----------|:-----|:----|------------:|----------:|-----------------:|---------------:|
| 0011       | compact_code |    9 |   0 | 00.11     | 0011 | cms |        2003 |      2015 |             2003 |           2015 |
| 0011       | compact_code |    9 |   1 | 001.1     | 0011 | cms |        1997 |      2015 |             1997 |           2015 |
| 7329       | compact_code |    9 |   1 | 732.9     | 7329 | cms |        1997 |      2015 |             1997 |           2015 |
| 732        | compact_code |    9 |   0 | 73.2      | 732  | cms |        1997 |      2015 |               NA |             NA |
| 732        | compact_code |    9 |   1 | 732       | 732  | cms |        1997 |      2015 |               NA |             NA |
| 73291      | NA           |   NA |  NA | NA        | NA   | NA  |          NA |        NA |               NA |             NA |
| not a code | NA           |   NA |  NA | NA        | NA   | NA  |          NA |        NA |               NA |             NA |
| 001.1      | NA           |   NA |  NA | NA        | NA   | NA  |          NA |        NA |               NA |             NA |
| A9248      | NA           |   NA |  NA | NA        | NA   | NA  |          NA |        NA |               NA |             NA |
| A924       | compact_code |   10 |   1 | A92.4     | A924 | cdc |        2001 |      2025 |             2001 |           2025 |
| A924       | compact_code |   10 |   1 | A92.4     | A924 | cms |        2014 |      2026 |             2014 |           2026 |
| A924       | compact_code |   10 |   1 | A92.4     | A924 | who |        2008 |      2019 |             2008 |           2019 |
| Z00        | compact_code |   10 |   1 | Z00       | Z00  | who |        2008 |      2019 |               NA |             NA |
| Z00        | compact_code |   10 |   1 | Z00       | Z00  | cms |        2014 |      2026 |               NA |             NA |

And set `compact.codes = FALSE` to only consider full codes.

``` r
knitr::kable(
  lookup_icd_codes(codes, compact.codes = FALSE),
  row.names = FALSE
)
```

| input_code | match_type | icdv |  dx | full_code | code | src | known_start | known_end | assignable_start | assignable_end |
|:-----------|:-----------|-----:|----:|:----------|:-----|:----|------------:|----------:|-----------------:|---------------:|
| 0011       | NA         |   NA |  NA | NA        | NA   | NA  |          NA |        NA |               NA |             NA |
| 7329       | NA         |   NA |  NA | NA        | NA   | NA  |          NA |        NA |               NA |             NA |
| 732        | full_code  |    9 |   1 | 732       | 732  | cms |        1997 |      2015 |               NA |             NA |
| 73291      | NA         |   NA |  NA | NA        | NA   | NA  |          NA |        NA |               NA |             NA |
| not a code | NA         |   NA |  NA | NA        | NA   | NA  |          NA |        NA |               NA |             NA |
| 001.1      | full_code  |    9 |   1 | 001.1     | 0011 | cms |        1997 |      2015 |             1997 |           2015 |
| A9248      | NA         |   NA |  NA | NA        | NA   | NA  |          NA |        NA |               NA |             NA |
| A924       | NA         |   NA |  NA | NA        | NA   | NA  |          NA |        NA |               NA |             NA |
| Z00        | full_code  |   10 |   1 | Z00       | Z00  | who |        2008 |      2019 |               NA |             NA |
| Z00        | full_code  |   10 |   1 | Z00       | Z00  | cms |        2014 |      2026 |               NA |             NA |

By default,
[`lookup_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/lookup_icd_codes.md)
considers the input to be a string and a direct match to the internal
lookup table is made.

[`lookup_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/lookup_icd_codes.md)
can also accept regular expressions. By providing a vector of regular
expression patterns for the codes (passed to
[`grep()`](https://rdrr.io/r/base/grep.html))

``` r
knitr::kable(
  lookup_icd_codes(x = "^C84\\.6[0-1A-Z]", regex = TRUE),
  row.names = FALSE
)
```

| input_regex      | match_type | icdv |  dx | full_code | code  | src | known_start | known_end | assignable_start | assignable_end |
|:-----------------|:-----------|-----:|----:|:----------|:------|:----|------------:|----------:|-----------------:|---------------:|
| ^C84.6\[0-1A-Z\] | full_code  |   10 |   1 | C84.60    | C8460 | cms |        2014 |      2026 |             2014 |           2026 |
| ^C84.6\[0-1A-Z\] | full_code  |   10 |   1 | C84.61    | C8461 | cms |        2014 |      2026 |             2014 |           2026 |
| ^C84.6\[0-1A-Z\] | full_code  |   10 |   1 | C84.6A    | C846A | cms |        2025 |      2026 |             2025 |           2026 |

## `is_icd()`

By convention, ICD codes are generally reported without decimal points.
Under this convention discriminating between ICD-9 and ICD-10, and
between diagnostic and procedure codes can be difficult.

Is “7993” a valid code? It is not a valid ICD-10 code as a four digit
code could not be an ICD-10 procedure code, and all ICD-10 diagnostic
codes start with a letter, not a number. So this string could only be a
ICD-9 code. It is a valid ICD-9 diagnostic code, and a valid ICD-9
procedure code.

``` r
is_icd(x = "7993")
## Warning: Input '7993' is a: ICD 9 dx compact; ICD 9 pr compact
## [1] TRUE
is_icd(x = "7993", icdv =  9, dx = 1)
## [1] TRUE
is_icd(x = "7993", icdv =  9, dx = 0)
## [1] TRUE
is_icd(x = "7993", icdv = 10, dx = 1)
## [1] FALSE
is_icd(x = "7993", icdv = 10, dx = 0)
## [1] FALSE
lookup_icd_codes("7993")
##   input_code   match_type icdv dx full_code code src known_start known_end
## 1       7993 compact_code    9  1     799.3 7993 cms        1997      2015
## 2       7993 compact_code    9  0     79.93 7993 cms        1997      2015
##   assignable_start assignable_end
## 1             1997           2015
## 2             1997           2015
```

A vector of possible codes:

``` r
x <- c("7993", "A924", "7993", "A924", "no", "A92", "516", "5163", "51631", "A00")
is_icd(x)
## Warning: Input '7993' is a: ICD 9 dx compact; ICD 9 pr compact
## Warning: Input '5163' is a: ICD 9 dx compact; ICD 9 pr compact
##  [1]  TRUE  TRUE  TRUE  TRUE FALSE FALSE FALSE  TRUE  TRUE FALSE
```

If you have codes with decimal points then discriminating between ICD-9
diagnostic and procedure codes can be done.

``` r
x <- c("7993",  # valid dx and pr code
       ".7993", # not a valid code
       "7.993", # not a valid code
       "79.93", # invalid dx code; valid pr code
       "799.3", # valid dx code; invalid pr code
       "7993.") # not a valid code
data.frame(x = x,
           icd9_dx = is_icd(x, icdv = 9, dx = 1, warn.ambiguous = FALSE),
           icd9_pr = is_icd(x, icdv = 9, dx = 0, warn.ambiguous = FALSE))
##       x icd9_dx icd9_pr
## 1  7993    TRUE    TRUE
## 2 .7993   FALSE   FALSE
## 3 7.993   FALSE   FALSE
## 4 79.93   FALSE    TRUE
## 5 799.3    TRUE   FALSE
## 6 7993.   FALSE   FALSE
```

#### Assignable codes

Ideally, codes are reported with the greatest level of detail. While
there is always a chance for incomplete coding, it is possible that an
assignable code in one year becomes a header code in a subsequent year.
Let’s look at the ICD-9 DX code 516.3 and five digit codes 516.30
through 516.39 (not all of these are valid, as we’ll see in the
examples.)

Given the default settings, we have the following results for testing if
these strings are valid ICD-9 dx codes.

By default, if no year is provided in the
[`is_icd()`](http://www.peteredewitt.com/medicalcoder/reference/is_icd.md)
call then return will be `TRUE` if the code was ever assignable.

``` r
x <- paste0("516.3", c("", 0:9))
tab <-
  data.frame(
    code       = x,
    default    = is_icd(x, icdv = 9, dx = 1),
    assignable_1997 = is_icd(x, src = "cms", icdv = 9, dx = 1, year = 1997),
    assignable_2010 = is_icd(x, src = "cms", icdv = 9, dx = 1, year = 2010),
    assignable_2011 = is_icd(x, src = "cms", icdv = 9, dx = 1, year = 2011),
    assignable_2012 = is_icd(x, src = "cms", icdv = 9, dx = 1, year = 2012),
    assignable_2013 = is_icd(x, src = "cms", icdv = 9, dx = 1, year = 2013),
    assignable_2016 = is_icd(x, src = "cms", icdv = 9, dx = 1, year = 2016),
    assignable_ever = is_icd(x, src = "cms", icdv = 9, dx = 1, ever.assignable = TRUE)
  )
## Warning: The combination of `icdv` = 9; `dx` = 1; and `src` = cms; has ICD
## codes with a max known_end year of 2015. The input of `year` = 2016 results in
## no possible positive match.
knitr::kable(tab)
```

| code   | default | assignable_1997 | assignable_2010 | assignable_2011 | assignable_2012 | assignable_2013 | assignable_2016 | assignable_ever |
|:-------|:--------|:----------------|:----------------|:----------------|:----------------|:----------------|:----------------|:----------------|
| 516.3  | TRUE    | TRUE            | TRUE            | TRUE            | FALSE           | FALSE           | FALSE           | TRUE            |
| 516.30 | TRUE    | FALSE           | FALSE           | FALSE           | TRUE            | TRUE            | FALSE           | TRUE            |
| 516.31 | TRUE    | FALSE           | FALSE           | FALSE           | TRUE            | TRUE            | FALSE           | TRUE            |
| 516.32 | TRUE    | FALSE           | FALSE           | FALSE           | TRUE            | TRUE            | FALSE           | TRUE            |
| 516.33 | TRUE    | FALSE           | FALSE           | FALSE           | TRUE            | TRUE            | FALSE           | TRUE            |
| 516.34 | TRUE    | FALSE           | FALSE           | FALSE           | TRUE            | TRUE            | FALSE           | TRUE            |
| 516.35 | TRUE    | FALSE           | FALSE           | FALSE           | TRUE            | TRUE            | FALSE           | TRUE            |
| 516.36 | TRUE    | FALSE           | FALSE           | FALSE           | TRUE            | TRUE            | FALSE           | TRUE            |
| 516.37 | TRUE    | FALSE           | FALSE           | FALSE           | TRUE            | TRUE            | FALSE           | TRUE            |
| 516.38 | FALSE   | FALSE           | FALSE           | FALSE           | FALSE           | FALSE           | FALSE           | FALSE           |
| 516.39 | FALSE   | FALSE           | FALSE           | FALSE           | FALSE           | FALSE           | FALSE           | FALSE           |

Similar information can be quickly and easily retrieved via
[`lookup_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/lookup_icd_codes.md).

``` r
knitr::kable(lookup_icd_codes(x))
```

| input_code | match_type | icdv |  dx | full_code | code  | src | known_start | known_end | assignable_start | assignable_end |
|:-----------|:-----------|-----:|----:|:----------|:------|:----|------------:|----------:|-----------------:|---------------:|
| 516.3      | full_code  |    9 |   1 | 516.3     | 5163  | cms |        1997 |      2015 |             1997 |           2011 |
| 516.30     | full_code  |    9 |   1 | 516.30    | 51630 | cms |        2012 |      2015 |             2012 |           2015 |
| 516.31     | full_code  |    9 |   1 | 516.31    | 51631 | cms |        2012 |      2015 |             2012 |           2015 |
| 516.32     | full_code  |    9 |   1 | 516.32    | 51632 | cms |        2012 |      2015 |             2012 |           2015 |
| 516.33     | full_code  |    9 |   1 | 516.33    | 51633 | cms |        2012 |      2015 |             2012 |           2015 |
| 516.34     | full_code  |    9 |   1 | 516.34    | 51634 | cms |        2012 |      2015 |             2012 |           2015 |
| 516.35     | full_code  |    9 |   1 | 516.35    | 51635 | cms |        2012 |      2015 |             2012 |           2015 |
| 516.36     | full_code  |    9 |   1 | 516.36    | 51636 | cms |        2012 |      2015 |             2012 |           2015 |
| 516.37     | full_code  |    9 |   1 | 516.37    | 51637 | cms |        2012 |      2015 |             2012 |           2015 |
| 516.38     | NA         |   NA |  NA | NA        | NA    | NA  |          NA |        NA |               NA |             NA |
| 516.39     | NA         |   NA |  NA | NA        | NA    | NA  |          NA |        NA |               NA |             NA |

For fiscal years 1997 through 2011 the code 516.3 was assignable. In
2012 516.3 was not assignable due to the introduction of the five digit
codes 516.30, 516.31, 516.32, 516.33, 516.34, 516.35, 516.36, and
516.37. Codes 526.38 and 516.39 were never in the ICD-9-CM standard.
When looking at retrospective data over several years the use of the
`ever.assignable` argument will simplify the testing for valid codes.

#### Header codes

There is also an option to considering header codes to be valid. As seen
below, the code “516” is a header, it was never assignable in ICD-9-CM.
By setting `headerok = TRUE` “516” will be flagged as a valid code. A
ICD-10 header “A00” will be FALSE in the following checks of ICD-9
codes.

``` r
x <- c("516", "5163", "51631", "A00")
tab <-
  data.frame(
    code     = x,
    default  = is_icd(x, icdv = 9, dx = 1, src = "cms", headerok = FALSE, ever.assignable = FALSE, warn.ambiguous = FALSE),
    ever     = is_icd(x, icdv = 9, dx = 1, src = "cms", headerok = FALSE, ever.assignable = TRUE,  warn.ambiguous = FALSE),
    headerok = is_icd(x, icdv = 9, dx = 1, src = "cms", headerok = TRUE,                           warn.ambiguous = FALSE)
  )
knitr::kable(tab)
```

| code  | default | ever  | headerok |
|:------|:--------|:------|:---------|
| 516   | FALSE   | FALSE | TRUE     |
| 5163  | FALSE   | TRUE  | TRUE     |
| 51631 | TRUE    | TRUE  | TRUE     |
| A00   | FALSE   | FALSE | FALSE    |

A more complex situation is ICD-9-CM code 719.7 and the five digit codes
719.70, 719.75, 719.76, 719.77, 719.78, and 719.79. The five digit codes
were assignable codes through FY 2004. Starting in FY 2004 the five
digit codes were removed from the standard and the four digit code
became assignable. This is a rare example of a header code becoming
assignable.

``` r
x <- paste0("719.7", c("", "0", 5:9))
tab <-
  data.frame(
    code            = x,
    default         = is_icd(x, src = "cms", icdv = 9, dx = 1),
    assignable_2002 = is_icd(x, src = "cms", icdv = 9, dx = 1, year = 2002),
    assignable_2003 = is_icd(x, src = "cms", icdv = 9, dx = 1, year = 2003),
    assignable_2004 = is_icd(x, src = "cms", icdv = 9, dx = 1, year = 2004),
    assignable_2005 = is_icd(x, src = "cms", icdv = 9, dx = 1, year = 2005),
    assignable_ever = is_icd(x, src = "cms", icdv = 9, dx = 1, ever.assignable = TRUE)
  )
knitr::kable(tab)
```

| code   | default | assignable_2002 | assignable_2003 | assignable_2004 | assignable_2005 | assignable_ever |
|:-------|:--------|:----------------|:----------------|:----------------|:----------------|:----------------|
| 719.7  | TRUE    | FALSE           | FALSE           | TRUE            | TRUE            | TRUE            |
| 719.70 | TRUE    | TRUE            | TRUE            | FALSE           | FALSE           | TRUE            |
| 719.75 | TRUE    | TRUE            | TRUE            | FALSE           | FALSE           | TRUE            |
| 719.76 | TRUE    | TRUE            | TRUE            | FALSE           | FALSE           | TRUE            |
| 719.77 | TRUE    | TRUE            | TRUE            | FALSE           | FALSE           | TRUE            |
| 719.78 | TRUE    | TRUE            | TRUE            | FALSE           | FALSE           | TRUE            |
| 719.79 | TRUE    | TRUE            | TRUE            | FALSE           | FALSE           | TRUE            |

## `icd_compact_to_full()`

To go from a full code to a compact code is simple, omit any decimal
point in the string.

To go from a compact code to a full code requires knowing if the code is
from version 9 or 10, and if it is a diagnostic or a procedure code.
[`icd_compact_to_full()`](http://www.peteredewitt.com/medicalcoder/reference/icd_compact_to_full.md)
will format a string appropriately, within reason. This method only
formats the strings and will not validate the return.

For example, the compact code “E1234” is in the format expected for a
ICD-9 diagnostic code or ICD-10 diagnostic code. It could not be a
procedure code as ICD-9 procedure codes are all numeric values and
ICD-10 procedure codes are seven characters long. The actual code E1234
is not a valid ICD code. We use this string as an example.

``` r
icd_compact_to_full("E1234", icdv =  9, dx = 1)
## [1] "E123.4"
icd_compact_to_full("E1234", icdv = 10, dx = 1)
## [1] "E12.34"

lookup_icd_codes(c("E1234", "E123.4", "E12.34"))[, c("input_code", "match_type")]
##   input_code match_type
## 3      E1234       <NA>
## 2     E123.4       <NA>
## 1     E12.34       <NA>
```

Notice that no change to the string is made when trying to convert to a
full procedure code.

``` r
icd_compact_to_full("E1234", icdv =  9, dx = 0)
## [1] "E1234"
icd_compact_to_full("E1234", icdv = 10, dx = 0)
## [1] "E1234"
```

## General Notes on ICD Code Structure

All four sets of codes have a hierarchical structure. The first level of
the hierarchy is the chapter which groups codes by disease category,
body system, and/or condition. Following that are subchapters for all
but the ICD-9 procedure codes. After the subchapter, depending on the
ICD variant, are the category, subcategory, subclassification,
subsubclassification, and extension.

### ICD-9 Diagnostic Codes

ICD-9 Diagnostic codes are organized by a hierarchy of five levels:

1.  chapter,
2.  subchapter,
3.  category,
4.  subcategory, and
5.  subclassification.

ICD-9 diagnostic codes are three to five digits, not counting a decimal
point, numeric or alpha numeric strings. The first three digits are the
category with numeric code 000 through 999 (leading zeros are part of
the numeric code), or V00-V99, or E000-E999. When the category does not
provide sufficient detail, a fourth numeric digit, separated from the
category by a decimal point, is used. Lastly, when the subcategory is
insufficient detail, then a fifth numeric digit is used, save for the E
categories.

### ICD-9 Procedure Codes

ICD-9 Procedure codes are organized by a hierarchy of four levels:

1.  chapter,
2.  category,
3.  subcategory, and
4.  subclassification.

The codes are numeric strings of four digits with a decimal point
between the second and third digits. The first two digits are the
category, the third digit is the subcategory, and the fourth digit is
the subclassification.

### ICD-10 Diagnostic Codes

ICD-10 diagnostic codes are up to seven alphanumeric codes with a
hierarchy of

1.  chapter,
2.  subchapter,
3.  category,
4.  subcategory,
5.  subclassification,
6.  subsubclassification, and
7.  extension.

The category describes the general type of disease of injury, with the
subcategory, subclassification and subsubclassification providing detail
on the cause, manifestation, location, severity, and type of disease or
injury. Finally, the extension specifies the type of encounter, i.e.,
initial or subsequent encounter, or sequela for encounters related to
prior disease or injury.

### ICD-10 Procedure Codes

In general, ICD-10 procedure codes are seven digits. In medicalcoder,
the three digit (chapter, subchapter, *category*) and the seven digit
codes are in the data base.
