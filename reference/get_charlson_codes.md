# Get Charlson Codes

Retrieve a copy of internal lookup tables for the ICD codes used in
assessing Charlson comorbidities.

## Usage

``` r
get_charlson_codes()
```

## Value

A `data.frame` with the following columns:

- `icdv`: Integer vector indicating if the code is from ICD-9 or ICD-10

- `dx`: Integer vector. 1 if the code is a diagnostic, (ICD-9-CM,
  ICD-10-CM, WHO, CDC Mortality), or 0 if the code is procedural
  (ICD-9-PCS, ICD-10-PCS)

- `full_code`: Character vector with the ICD code and any relevant
  decimal point

- `code`: Character vector with the compact ICD code

- `condition`: Character vector of the conditions

- `charlson_\<variant\>`: Integer vector indicating if the code is part
  of the \\variant\\ of the Charlson comorbidities.

## See also

- [`get_charlson_index_scores()`](http://www.peteredewitt.com/medicalcoder/reference/get_charlson_index_scores.md)
  for a lookup table of the by comorbidity index scores.

- [`get_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_icd_codes.md)
  for the lookup table of all ICD codes.

- [`get_pccc_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_pccc_codes.md)
  for the lookup table of ICD codes used for the PCCC.

- [`get_elixhauser_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_elixhauser_codes.md)
  for the lookup table of ICD codes used for the Elixhauser
  comorbidities.

- [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  for applying comorbidity algorithms to a data set.

## Examples

``` r
head(get_charlson_codes())
#>   icdv dx full_code  code condition charlson_cdmf2019 charlson_deyo1992
#> 1    9  1     003.1  0031      aids                 1                 0
#> 2    9  1     007.2  0072      aids                 1                 0
#> 3    9  1     007.4  0074      aids                 1                 0
#> 4    9  1       010   010      aids                 1                 0
#> 5    9  1     010.0  0100      aids                 1                 0
#> 6    9  1    010.00 01000      aids                 1                 0
#>   charlson_quan2005 charlson_quan2011
#> 1                 0                 0
#> 2                 0                 0
#> 3                 0                 0
#> 4                 0                 0
#> 5                 0                 0
#> 6                 0                 0
str(get_charlson_codes())
#> 'data.frame':    7410 obs. of  9 variables:
#>  $ icdv             : int  9 9 9 9 9 9 9 9 9 9 ...
#>  $ dx               : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ full_code        : chr  "003.1" "007.2" "007.4" "010" ...
#>  $ code             : chr  "0031" "0072" "0074" "010" ...
#>  $ condition        : chr  "aids" "aids" "aids" "aids" ...
#>  $ charlson_cdmf2019: int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ charlson_deyo1992: int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ charlson_quan2005: int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ charlson_quan2011: int  0 0 0 0 0 0 0 0 0 0 ...
```
