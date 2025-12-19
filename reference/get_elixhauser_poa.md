# Get Elixhauser Present-on-Admission Requirements

Retrieve a copy of internal lookup table with details on which
Elixhauser comorbidities do and do not require the associated ICD codes
to be present-on-admission to be flagged.

## Usage

``` r
get_elixhauser_poa()
```

## Value

A `data.frame` with the following columns:

- `condition`: Character vector of the conditions

- `desc`: Character vector with a verbose description of the condition

- `poa_required`: Integer indicators if the code needs to present on
  admission to be considered a comorbidity

- `elixhauser_<variant>`: indicators for the Elixhauser `<variant>`

## See also

- [`get_elixhauser_index_scores()`](http://www.peteredewitt.com/medicalcoder/reference/get_elixhauser_index_scores.md)
  for the lookup table of the condition by condition scores for
  mortality and readmission indices.

- [`get_elixhauser_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_elixhauser_codes.md)
  for the lookup table of ICD codes mapping to the Elixhauser
  comorbidities.

- [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  for applying comorbidity algorithms to a data set.

## Examples

``` r
head(get_elixhauser_poa())
#>     condition poa_required elixhauser_ahrq2022 elixhauser_ahrq2023
#> 1        AIDS            0                   1                   1
#> 2     ALCOHOL            0                   1                   1
#> 3     ANEMDEF            1                   1                   1
#> 4  AUTOIMMUNE            0                   1                   1
#> 5     BLDLOSS            1                   1                   1
#> 6 CANCER_LEUK            0                   1                   1
#>   elixhauser_ahrq2024 elixhauser_ahrq2025 elixhauser_ahrq2026
#> 1                   1                   1                   1
#> 2                   1                   1                   1
#> 3                   1                   1                   1
#> 4                   1                   1                   1
#> 5                   1                   1                   1
#> 6                   1                   1                   1
#>   elixhauser_ahrq_icd10
#> 1                     1
#> 2                     1
#> 3                     1
#> 4                     1
#> 5                     1
#> 6                     1
str(get_elixhauser_poa())
#> 'data.frame':    50 obs. of  8 variables:
#>  $ condition            : chr  "AIDS" "ALCOHOL" "ANEMDEF" "AUTOIMMUNE" ...
#>  $ poa_required         : int  0 0 1 0 1 0 0 0 0 0 ...
#>  $ elixhauser_ahrq2022  : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ elixhauser_ahrq2023  : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ elixhauser_ahrq2024  : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ elixhauser_ahrq2025  : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ elixhauser_ahrq2026  : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ elixhauser_ahrq_icd10: int  1 1 1 1 1 1 1 1 1 1 ...
```
