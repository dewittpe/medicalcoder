# Get ICD Codes

Retrieve a copy of the internal lookup table for all known ICD codes.

## Usage

``` r
get_icd_codes(with.descriptions = FALSE, with.hierarchy = FALSE)
```

## Arguments

- with.descriptions:

  Logical scalar, if `TRUE` include the description of the codes.

- with.hierarchy:

  Logical scalar, if `TRUE` include the ICD hierarchy.

## Value

a `data.frame`

The default return has the following columns:

- `icdv`: Integer vector indicating if the code is from ICD-9 or ICD-10

- `dx`: Integer vector. `1L` if the code is diagnostic (ICD-9-CM,
  ICD-10-CM, ICD-10-AM, ICD-10-SE, WHO, CDC Mortality), or `0L` if the
  code is procedural (ICD-9-PCS, ICD-10-PCS)

- `full_code`: Character vector with the ICD code and any relevant
  decimal point

- `code`: Character vector with the compact ICD code omitting any
  relevant decimal point

- `src`: Character vector reporting the source of the information. See
  Details.

- `known_start`: Integer vector reporting the first known year of use.
  See Details.

- `known_end`: Integer vector reporting the last known year of use. See
  Details.

- `assignable_start`: Integer vector reporting the first known year the
  code was assignable. See Details.

- `assignable_end`: Integer vector reporting the last known year the
  code was assignable. See Details.

When `with.descriptions = TRUE` there are the following additional
columns:

- `desc`: Character vector of descriptions. For `cms` codes descriptions
  from CMS are used preferentially over CDC.

- `desc_start`: Integer vector of the first year the description was
  used.

- `desc_end`: Integer vector of the last year the description was used.

When `with.hierarchy = TRUE` there are the following additional columns:

- `chapter`

- `subchapter`

- `category`

- `subcategory`

- `subclassification`

- `subsubclassification`

- `extension`

## Details

### Sources

There are five sources of ICD codes.

- `cms`: Codes from the ICD-9-CM, ICD-9-PCS, ICD-10-CM, and ICD-10-PCS
  standards.

- `who`: Codes from the World Health Organization.

- `cdc`: For ICD-10, CDC mortality codes, not CDC-hosted ICD-10-CM
  files. ICD-10-CM uses the canonical `cms` source. CDC ICD-9 extracts
  are also retained under `cdc`.

- `ihacpa`: ICD-10-AM codes from the Independent Health and Aged Care
  Pricing Authority.

- `socialstyrelsen`: ICD-10-SE codes from Sweden's National Board of
  Health and Welfare.

### Fiscal, Financial, and Calendar Years

When reporting years there is a mix of fiscal, financial, and calendar
years.

Fiscal years are the United States Federal Government fiscal years,
running from October 1 to September 30. For example, fiscal year 2013
started October 1, 2012 and ended on September 30, 2013.

Financial years are the Australian financial years used for IHACPA data,
running from July 1 to June 30.

Calendar years run January 1 to December 31.

Within the ICD data there are columns `known_start`, `known_end`,
`assignable_start`, `assignable_end`, `desc_start` and `desc_end`. For
ICD codes with `src == "cms"`, these are fiscal years. For codes with
`src == "ihacpa"`, these are financial years. For codes with
`src == "cdc"`, `src == "socialstyrelsen"`, or `src == "who"` these are
calendar years.

`known_start` is the first fiscal, financial, or calendar year
(depending on source) that the medicalcoder package has definitive
source data for. ICD-9-CM started in the United States in fiscal year
1980. The CDC extracts included in medicalcoder span fiscal years
1997–2012; the CMS ICD-9-CM/PCS extracts start in fiscal year 2006 and
run through fiscal year 2015. As such 1997 is the earliest "known start"
for ICD-9 within medicalcoder.

`known_end` is the last fiscal, financial, or calendar year (depending
on source) for which we have definitive source data. For ICD-9-CM and
ICD-9-PCS, CMS provides data through fiscal year 2015, while the CDC
extracts stop at fiscal year 2012. For ICD-10-CM and ICD-10-PCS, which
are active, it is just the last year of known data. ICD-10 from the WHO
ends in 2019.

CMS annual tables represent the selected release within each fiscal
year, including April updates where incorporated. Integer validity years
do not distinguish October and April effective dates within the same
fiscal year.

### Header and Assignable Codes

"Assignable" indicates that the code is the most granular for the
source. Ideally codes are reported with the greatest level of detail but
that is not always the case. Also, the greatest level of detail can
differ between sources. Example: C86 is a header code for `cms` and
`who` because codes C86.0, C86.1, C86.2, C86.3, C86.4, C86.5, and C86.6
all exist in both standards. No code with a fifth digit exists in the
`who` so all these four digit codes are 'assignable.' In the `cms`
standard, C86.0 was assignable through fiscal year 2024. In fiscal year
2025 codes C86.00 and C86.01 were added making C86.0 a header code and
C86.00 and C86.01 assignable codes.

## See also

[`is_icd()`](http://www.peteredewitt.com/medicalcoder/reference/is_icd.md),
[`lookup_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/lookup_icd_codes.md),
[`vignette(topic = "icd", package = "medicalcoder")`](http://www.peteredewitt.com/medicalcoder/articles/icd.md)

## Examples

``` r
icd_codes <- get_icd_codes()
str(icd_codes)
#> 'data.frame':    330947 obs. of  9 variables:
#>  $ icdv            : int  9 9 9 9 9 9 9 9 9 9 ...
#>  $ dx              : int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ full_code       : chr  "00" "00" "00.0" "00.0" ...
#>  $ code            : chr  "00" "00" "000" "000" ...
#>  $ src             : chr  "cms" "cdc" "cms" "cdc" ...
#>  $ known_start     : int  2006 2003 2006 2003 2006 2003 2006 2003 2006 2003 ...
#>  $ known_end       : int  2015 2012 2015 2012 2015 2012 2015 2012 2015 2012 ...
#>  $ assignable_start: int  NA NA NA NA 2006 2003 2006 2003 2006 2003 ...
#>  $ assignable_end  : int  NA NA NA NA 2015 2012 2015 2012 2015 2012 ...

# Explore the change in the assignable year for C86 code between CMS and
# WHO
subset(get_icd_codes(), grepl("^C86$", full_code))
#>        icdv dx full_code code             src known_start known_end
#> 136444   10  1       C86  C86             cms        2014      2027
#> 136445   10  1       C86  C86          ihacpa        2020      2026
#> 136446   10  1       C86  C86 socialstyrelsen        2010      2026
#> 136447   10  1       C86  C86             who        2010      2021
#>        assignable_start assignable_end
#> 136444               NA             NA
#> 136445               NA             NA
#> 136446               NA             NA
#> 136447               NA             NA
subset(get_icd_codes(), grepl("^C86\\.\\d$", full_code))
#>        icdv dx full_code code             src known_start known_end
#> 136448   10  1     C86.0 C860             cms        2014      2027
#> 136449   10  1     C86.0 C860          ihacpa        2020      2026
#> 136450   10  1     C86.0 C860 socialstyrelsen        2010      2026
#> 136451   10  1     C86.0 C860             who        2010      2021
#> 136454   10  1     C86.1 C861             cms        2014      2027
#> 136455   10  1     C86.1 C861          ihacpa        2020      2026
#> 136456   10  1     C86.1 C861 socialstyrelsen        2010      2026
#> 136457   10  1     C86.1 C861             who        2010      2021
#> 136460   10  1     C86.2 C862             cms        2014      2027
#> 136461   10  1     C86.2 C862          ihacpa        2020      2026
#> 136462   10  1     C86.2 C862 socialstyrelsen        2010      2026
#> 136463   10  1     C86.2 C862             who        2010      2021
#> 136466   10  1     C86.3 C863             cms        2014      2027
#> 136467   10  1     C86.3 C863          ihacpa        2020      2026
#> 136468   10  1     C86.3 C863 socialstyrelsen        2010      2026
#> 136469   10  1     C86.3 C863             who        2010      2021
#> 136472   10  1     C86.4 C864             cms        2014      2027
#> 136473   10  1     C86.4 C864          ihacpa        2020      2026
#> 136474   10  1     C86.4 C864 socialstyrelsen        2010      2026
#> 136475   10  1     C86.4 C864             who        2010      2021
#> 136478   10  1     C86.5 C865             cms        2014      2027
#> 136479   10  1     C86.5 C865          ihacpa        2020      2026
#> 136480   10  1     C86.5 C865 socialstyrelsen        2010      2026
#> 136481   10  1     C86.5 C865             who        2010      2021
#> 136484   10  1     C86.6 C866             cms        2014      2027
#> 136485   10  1     C86.6 C866          ihacpa        2020      2026
#> 136486   10  1     C86.6 C866 socialstyrelsen        2010      2026
#> 136487   10  1     C86.6 C866             who        2010      2021
#>        assignable_start assignable_end
#> 136448             2014           2024
#> 136449             2020           2026
#> 136450             2010           2026
#> 136451             2010           2021
#> 136454             2014           2024
#> 136455             2020           2026
#> 136456             2010           2026
#> 136457             2010           2021
#> 136460             2014           2024
#> 136461             2020           2026
#> 136462             2010           2026
#> 136463             2010           2021
#> 136466             2014           2024
#> 136467             2020           2026
#> 136468             2010           2026
#> 136469             2010           2021
#> 136472             2014           2024
#> 136473             2020           2026
#> 136474             2010           2026
#> 136475             2010           2021
#> 136478             2014           2024
#> 136479             2020           2026
#> 136480             2010           2026
#> 136481             2010           2021
#> 136484             2014           2024
#> 136485             2020           2026
#> 136486             2010           2026
#> 136487             2010           2021
subset(get_icd_codes(), grepl("^C86\\.0(\\d|$)", full_code))
#>        icdv dx full_code  code             src known_start known_end
#> 136448   10  1     C86.0  C860             cms        2014      2027
#> 136449   10  1     C86.0  C860          ihacpa        2020      2026
#> 136450   10  1     C86.0  C860 socialstyrelsen        2010      2026
#> 136451   10  1     C86.0  C860             who        2010      2021
#> 136452   10  1    C86.00 C8600             cms        2025      2027
#> 136453   10  1    C86.01 C8601             cms        2025      2027
#>        assignable_start assignable_end
#> 136448             2014           2024
#> 136449             2020           2026
#> 136450             2010           2026
#> 136451             2010           2021
#> 136452             2025           2027
#> 136453             2025           2027

is_icd("C86", headerok = FALSE) # FALSE
#> [1] FALSE
is_icd("C86", headerok = TRUE)  # TRUE
#> [1] TRUE
is_icd("C86", headerok = TRUE, src = "cdc") # Not a CDC mortality code
#> [1] FALSE

lookup_icd_codes("^C86\\.0\\d*", regex = TRUE)
#>    input_regex match_type icdv dx full_code  code             src known_start
#> 1 ^C86\\.0\\d*  full_code   10  1     C86.0  C860             cms        2014
#> 2 ^C86\\.0\\d*  full_code   10  1     C86.0  C860          ihacpa        2020
#> 3 ^C86\\.0\\d*  full_code   10  1     C86.0  C860 socialstyrelsen        2010
#> 4 ^C86\\.0\\d*  full_code   10  1     C86.0  C860             who        2010
#> 5 ^C86\\.0\\d*  full_code   10  1    C86.00 C8600             cms        2025
#> 6 ^C86\\.0\\d*  full_code   10  1    C86.01 C8601             cms        2025
#>   known_end assignable_start assignable_end
#> 1      2027             2014           2024
#> 2      2026             2020           2026
#> 3      2026             2010           2026
#> 4      2021             2010           2021
#> 5      2027             2025           2027
#> 6      2027             2025           2027
```
