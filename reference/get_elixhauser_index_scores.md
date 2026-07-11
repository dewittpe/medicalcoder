# Get Elixhauser Index Scores

Functions to get a copy of internal lookup tables for the ICD codes and
index scores used in assessing Elixhauser comorbidities.

## Usage

``` r
get_elixhauser_index_scores()
```

## Value

A `data.frame` with the following columns:

- `condition`: Character vector of the conditions

- `index`: Character vector indicating whether the score is for the
  mortality or readmission index.

- `elixhauser_<variant>`: Integer vector of the scores.

## See also

- [`get_elixhauser_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_elixhauser_codes.md)
  for the lookup table of ICD codes mapping to the Elixhauser
  comorbidities.

- [`get_elixhauser_poa()`](http://www.peteredewitt.com/medicalcoder/reference/get_elixhauser_poa.md)
  for the lookup table of the conditions which do and do not require
  associated ICD codes to be present-on-admission to flag the
  comorbidity.

- [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  for applying comorbidity algorithms to a dataset.

## Examples

``` r
head(get_elixhauser_index_scores())
#>   condition       index elixhauser_ahrq_web elixhauser_elixhauser1988
#> 1      AIDS   mortality                   0                         0
#> 2      AIDS readmission                  19                        19
#> 3   ALCOHOL   mortality                  -1                        -1
#> 4   ALCOHOL readmission                   6                         6
#> 5   ANEMDEF   mortality                  -2                        -2
#> 6   ANEMDEF readmission                   9                         9
#>   elixhauser_quan2005 elixhauser_ahrq2022 elixhauser_ahrq2023
#> 1                   0                  -4                  -4
#> 2                  19                   5                   5
#> 3                  -1                  -1                  -1
#> 4                   6                   3                   3
#> 5                  -2                  -3                  -3
#> 6                   9                   5                   5
#>   elixhauser_ahrq2024 elixhauser_ahrq2025 elixhauser_ahrq2026
#> 1                  -4                  -4                  -4
#> 2                   5                   5                   5
#> 3                  -1                  -1                  -1
#> 4                   3                   3                   3
#> 5                  -3                  -3                  -3
#> 6                   5                   5                   5
#>   elixhauser_ahrq_icd10
#> 1                    -4
#> 2                     5
#> 3                    -1
#> 4                     3
#> 5                    -3
#> 6                     5
str(get_elixhauser_index_scores())
#> 'data.frame':    112 obs. of  11 variables:
#>  $ condition                : chr  "AIDS" "AIDS" "ALCOHOL" "ALCOHOL" ...
#>  $ index                    : chr  "mortality" "readmission" "mortality" "readmission" ...
#>  $ elixhauser_ahrq_web      : int  0 19 -1 6 -2 9 0 4 NA NA ...
#>  $ elixhauser_elixhauser1988: int  0 19 -1 6 -2 9 0 4 NA NA ...
#>  $ elixhauser_quan2005      : int  0 19 -1 6 -2 9 0 4 NA NA ...
#>  $ elixhauser_ahrq2022      : int  -4 5 -1 3 -3 5 NA NA -1 2 ...
#>  $ elixhauser_ahrq2023      : int  -4 5 -1 3 -3 5 NA NA 0 2 ...
#>  $ elixhauser_ahrq2024      : int  -4 5 -1 3 -3 5 NA NA 0 2 ...
#>  $ elixhauser_ahrq2025      : int  -4 5 -1 3 -3 5 NA NA 0 2 ...
#>  $ elixhauser_ahrq2026      : int  -4 5 -1 3 -3 5 NA NA 0 2 ...
#>  $ elixhauser_ahrq_icd10    : int  -4 5 -1 3 -3 5 NA NA 0 2 ...
```
