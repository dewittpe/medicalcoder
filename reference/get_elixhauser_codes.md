# Get Elixhauser Codes

Retrieve copy of internal lookup tables for the ICD codes used in
assessing Elixhauser comorbidities.

## Usage

``` r
get_elixhauser_codes()
```

## Value

A `data.frame` with the following columns:

- `icdv`: Integer vector indicating if the code is from ICD-9 or ICD-10

- `dx`: Integer vector. 1 if the code is a diagnostic, (ICD-9-CM,
  ICD-10-CM, WHO, CDC Mortality), or 0 if the code is procedural
  (ICD-9-PCS, ICD-10-PCS)

- `full_code`: Character vector with the ICD code and any relevant
  decimal point

- `code`: Character vector with the compact ICD code omitting any
  relevant decimal point

- `condition`: Character vector of the conditions

- `elixhauser_<variant>`: Integer vector indicating if the code is part
  of the `<variant>` of the Elixhauser comorbidities.

## See also

- [`get_elixhauser_index_scores()`](http://www.peteredewitt.com/medicalcoder/reference/get_elixhauser_index_scores.md)
  for the lookup table of the condition by condition scores for
  mortality and readmission indices.

- [`get_elixhauser_poa()`](http://www.peteredewitt.com/medicalcoder/reference/get_elixhauser_poa.md)
  for the lookup table of the conditions which do an do not require
  associated ICD codes to be present-on-admission to flag the
  comorbidity.

- [`get_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_icd_codes.md)
  for the lookup table of all ICD codes.

- [`get_pccc_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_pccc_codes.md)
  for the lookup table of ICD codes used for the PCCC.

- [`get_charlson_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_charlson_codes.md)
  for the lookup table of ICD codes used for the Charlson comorbidities.

- [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  for applying comorbidity algorithms to a data set.

## Examples

``` r
head(get_elixhauser_codes())
#>   icdv dx full_code  code poaexempt condition elixhauser_ahrq_web
#> 1    9  1       042   042        NA      AIDS                   1
#> 2    9  1    070.22 07022        NA     LIVER                   1
#> 3    9  1    070.23 07023        NA     LIVER                   1
#> 4    9  1    070.32 07032        NA     LIVER                   1
#> 5    9  1    070.33 07033        NA     LIVER                   1
#> 6    9  1    070.44 07044        NA     LIVER                   1
#>   elixhauser_elixhauser1988 elixhauser_quan2005 elixhauser_ahrq2022
#> 1                         1                   1                  NA
#> 2                         0                   1                  NA
#> 3                         0                   1                  NA
#> 4                         1                   1                  NA
#> 5                         1                   1                  NA
#> 6                         0                   1                  NA
#>   elixhauser_ahrq2023 elixhauser_ahrq2024 elixhauser_ahrq2025
#> 1                  NA                  NA                  NA
#> 2                  NA                  NA                  NA
#> 3                  NA                  NA                  NA
#> 4                  NA                  NA                  NA
#> 5                  NA                  NA                  NA
#> 6                  NA                  NA                  NA
#>   elixhauser_ahrq_icd10
#> 1                    NA
#> 2                    NA
#> 3                    NA
#> 4                    NA
#> 5                    NA
#> 6                    NA
str(get_elixhauser_codes())
#> 'data.frame':    10428 obs. of  14 variables:
#>  $ icdv                     : int  9 9 9 9 9 9 9 9 9 9 ...
#>  $ dx                       : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ full_code                : chr  "042" "070.22" "070.23" "070.32" ...
#>  $ code                     : chr  "042" "07022" "07023" "07032" ...
#>  $ poaexempt                : int  NA NA NA NA NA NA NA NA NA NA ...
#>  $ condition                : chr  "AIDS" "LIVER" "LIVER" "LIVER" ...
#>  $ elixhauser_ahrq_web      : int  1 1 1 1 1 1 1 0 0 0 ...
#>  $ elixhauser_elixhauser1988: int  1 0 0 1 1 0 1 0 0 0 ...
#>  $ elixhauser_quan2005      : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ elixhauser_ahrq2022      : int  NA NA NA NA NA NA NA NA NA NA ...
#>  $ elixhauser_ahrq2023      : int  NA NA NA NA NA NA NA NA NA NA ...
#>  $ elixhauser_ahrq2024      : int  NA NA NA NA NA NA NA NA NA NA ...
#>  $ elixhauser_ahrq2025      : int  NA NA NA NA NA NA NA NA NA NA ...
#>  $ elixhauser_ahrq_icd10    : int  NA NA NA NA NA NA NA NA NA NA ...
```
