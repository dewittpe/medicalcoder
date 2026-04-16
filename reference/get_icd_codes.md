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

- `dx`: Integer vector. 1 if the code is a diagnostic, (ICD-9-CM,
  ICD-10-CM, WHO, CDC Mortality), or 0 if the code is procedural
  (ICD-9-PCS, ICD-10-PCS)

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

There are three sources of ICD codes.

- `cms`: Codes from the ICD-9-CM, ICD-9-PCS, ICD-10-CM, and ICD-10-PCS
  standards.

- `who`: Codes from World Health Organization.

- `cdc`: Codes from CDC Mortality coding standard.

### Fiscal and Calendar Years

When reporting years there is a mix of fiscal and calendar years.

Fiscal years are the United States Federal Government fiscal years,
running from October 1 to September 30. For example, fiscal year 2013
started October 1 2012 and ended on September 30 2013.

Calendar years run January 1 to December 31.

Within the ICD data there are columns `known_start`, `known_end`,
`assignable_start`, `assignable_end`, `desc_start` and `desc_end`. For
ICD codes with `src == "cms"`, these are fiscal years. For codes with
`src == "cdc"` or `src == "who"` these are calendar years.

`known_start` is the first fiscal or calendar year (depending on source)
that the medicalcoder package as definitive source data for. ICD-9-CM
started in the United States in fiscal year 1980. The CDC extracts
included in medicalcoder span fiscal years 1997–2012; the CMS
ICD-9-CM/PCS extracts start in fiscal year 2006 and run through fiscal
year 2015. As such 1997 is the earliest "known start" for ICD-9 within
medicalcoder.

`known_end` is the last fiscal or calendar year (depending on source)
for which we have definitive source data for. For ICD-9-CM and
ICD-9-PCS, CMS provides data through fiscal year 2015, while the CDC
extracts stop at fiscal year 2012. For ICD-10-CM and ICD-10-PCS, which
are active, it is just the last year of known data. ICD-10 from the WHO
ends in 2019.

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
#> 'data.frame':    249819 obs. of  9 variables:
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
#>        icdv dx full_code code src known_start known_end assignable_start
#> 133130   10  1       C86  C86 cms        2014      2026               NA
#> 133131   10  1       C86  C86 who        2010      2019               NA
#>        assignable_end
#> 133130             NA
#> 133131             NA
subset(get_icd_codes(), grepl("^C86\\.\\d$", full_code))
#>        icdv dx full_code code src known_start known_end assignable_start
#> 133132   10  1     C86.0 C860 cms        2014      2026             2014
#> 133133   10  1     C86.0 C860 who        2010      2019             2010
#> 133136   10  1     C86.1 C861 cms        2014      2026             2014
#> 133137   10  1     C86.1 C861 who        2010      2019             2010
#> 133140   10  1     C86.2 C862 cms        2014      2026             2014
#> 133141   10  1     C86.2 C862 who        2010      2019             2010
#> 133144   10  1     C86.3 C863 cms        2014      2026             2014
#> 133145   10  1     C86.3 C863 who        2010      2019             2010
#> 133148   10  1     C86.4 C864 cms        2014      2026             2014
#> 133149   10  1     C86.4 C864 who        2010      2019             2010
#> 133152   10  1     C86.5 C865 cms        2014      2026             2014
#> 133153   10  1     C86.5 C865 who        2010      2019             2010
#> 133156   10  1     C86.6 C866 cms        2014      2026             2014
#> 133157   10  1     C86.6 C866 who        2010      2019             2010
#>        assignable_end
#> 133132           2024
#> 133133           2019
#> 133136           2024
#> 133137           2019
#> 133140           2024
#> 133141           2019
#> 133144           2024
#> 133145           2019
#> 133148           2024
#> 133149           2019
#> 133152           2024
#> 133153           2019
#> 133156           2024
#> 133157           2019
subset(get_icd_codes(), grepl("^C86\\.0(\\d|$)", full_code))
#>        icdv dx full_code  code src known_start known_end assignable_start
#> 133132   10  1     C86.0  C860 cms        2014      2026             2014
#> 133133   10  1     C86.0  C860 who        2010      2019             2010
#> 133134   10  1    C86.00 C8600 cms        2025      2026             2025
#> 133135   10  1    C86.01 C8601 cms        2025      2026             2025
#>        assignable_end
#> 133132           2024
#> 133133           2019
#> 133134           2026
#> 133135           2026

is_icd("C86", headerok = FALSE) # FALSE
#> [1] FALSE
is_icd("C86", headerok = TRUE)  # TRUE
#> [1] TRUE
is_icd("C86", headerok = TRUE, src = "cdc") # Not a CDC mortality code
#> [1] FALSE

lookup_icd_codes("^C86\\.0\\d*", regex = TRUE)
#>    input_regex match_type icdv dx full_code  code src known_start known_end
#> 2 ^C86\\.0\\d*  full_code   10  1     C86.0  C860 cms        2014      2026
#> 1 ^C86\\.0\\d*  full_code   10  1     C86.0  C860 who        2010      2019
#> 5 ^C86\\.0\\d*  full_code   10  1    C86.00 C8600 cms        2025      2026
#> 6 ^C86\\.0\\d*  full_code   10  1    C86.01 C8601 cms        2025      2026
#>   assignable_start assignable_end
#> 2             2014           2024
#> 1             2010           2019
#> 5             2025           2026
#> 6             2025           2026
```
