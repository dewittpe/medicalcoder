# Get Charlson Codes

Retrieve a copy of internal lookup tables for the ICD codes used in
assessing Charlson comorbidities. The lookup includes indicator columns
for each implemented Charlson variant.

## Usage

``` r
get_charlson_codes()
```

## Value

A `data.frame` with the following columns:

- `icdv`: Integer vector indicating if the code is from ICD-9 or ICD-10.

- `dx`: Integer vector. `1L` if the code is diagnostic (ICD-9-CM,
  ICD-10-CM, ICD-10-AM, ICD-10-SE, WHO, CDC Mortality), or `0L` if the
  code is procedural (ICD-9-PCS, ICD-10-PCS).

- `full_code`: Character vector with the ICD code and any relevant
  decimal point

- `code`: Character vector with the compact ICD code

- `condition`: Character vector of the conditions

- `charlson_<variant>`: Integer vector indicating if the code is part of
  the `<variant>` of the Charlson comorbidities.

## See also

- [`get_charlson_index_scores()`](http://www.peteredewitt.com/medicalcoder/reference/get_charlson_index_scores.md)
  for a lookup table of comorbidity index scores.

- [`get_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_icd_codes.md)
  for the lookup table of all ICD codes.

- [`get_pccc_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_pccc_codes.md)
  for the lookup table of ICD codes used for the PCCC.

- [`get_elixhauser_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_elixhauser_codes.md)
  for the lookup table of ICD codes used for the Elixhauser
  comorbidities.

- [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  for applying comorbidity algorithms to a dataset.

## Examples

``` r
head(get_charlson_codes())
#>   icdv dx full_code code condition charlson_beyrer2021 charlson_cdmf2019
#> 1    9  0     38.48 3848       pvd                   0                 0
#> 2    9  1     003.1 0031      aids                   0                 1
#> 3    9  1     007.2 0072      aids                   0                 1
#> 4    9  1     007.4 0074      aids                   0                 1
#> 5    9  1       010  010      aids                   0                 1
#> 6    9  1     010.0 0100      aids                   0                 1
#>   charlson_deyo1992 charlson_ludvigsson2021 charlson_mimicivcode
#> 1                 1                       0                    0
#> 2                 0                       0                    0
#> 3                 0                       0                    0
#> 4                 0                       0                    0
#> 5                 0                       0                    0
#> 6                 0                       0                    0
#>   charlson_quan2005 charlson_sundararajan2004 charlson_quan2011
#> 1                 0                         0                 0
#> 2                 0                         0                 0
#> 3                 0                         0                 0
#> 4                 0                         0                 0
#> 5                 0                         0                 0
#> 6                 0                         0                 0
str(get_charlson_codes())
#> 'data.frame':    9248 obs. of  13 variables:
#>  $ icdv                     : int  9 9 9 9 9 9 9 9 9 9 ...
#>  $ dx                       : int  0 1 1 1 1 1 1 1 1 1 ...
#>  $ full_code                : chr  "38.48" "003.1" "007.2" "007.4" ...
#>  $ code                     : chr  "3848" "0031" "0072" "0074" ...
#>  $ condition                : chr  "pvd" "aids" "aids" "aids" ...
#>  $ charlson_beyrer2021      : int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ charlson_cdmf2019        : int  0 1 1 1 1 1 1 1 1 1 ...
#>  $ charlson_deyo1992        : int  1 0 0 0 0 0 0 0 0 0 ...
#>  $ charlson_ludvigsson2021  : int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ charlson_mimicivcode     : int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ charlson_quan2005        : int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ charlson_sundararajan2004: int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ charlson_quan2011        : int  0 0 0 0 0 0 0 0 0 0 ...
```
