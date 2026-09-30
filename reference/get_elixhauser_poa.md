# Get Elixhauser Present-on-Admission Requirements

Retrieve a copy of internal lookup table with details on which
Elixhauser comorbidities do and do not require the associated ICD codes
to be present-on-admission to be flagged. This is a condition-level rule
table; code-level POA exemptions are a separate part of the Elixhauser
mapping.

## Usage

``` r
get_elixhauser_poa()
```

## Value

A `data.frame` with the following columns:

- `condition`: Character vector naming the comorbidity condition. A
  condition can have more than one row if its POA requirement changes by
  method or release.

- `poa_required`: Integer rule flag: `1L` means POA is required, subject
  to code-level exemptions; `0L` means the condition is POA neutral.

- `elixhauser_<variant>`: Integer membership flag indicating whether the
  row's condition and POA rule apply to that variant.

## Details

For the AHRQ ICD-10-CM methods, `poa_required = 1L` means a condition is
flagged when a mapped diagnosis is POA or its code is POA exempt.
`poa_required = 0L` means the condition is flagged regardless of the
diagnosis POA value. The `elixhauser_ahrqYYYY` columns identify which
annual AHRQ release uses each condition/rule row. The combined
`elixhauser_ahrq_icd10` column marks rows used by any included annual
release; it is a union, not a separate annual AHRQ release.

## See also

- [`get_elixhauser_index_scores()`](http://www.peteredewitt.com/medicalcoder/reference/get_elixhauser_index_scores.md)
  for the lookup table of the condition by condition scores for
  mortality and readmission indices.

- [`get_elixhauser_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_elixhauser_codes.md)
  for the lookup table of ICD codes mapping to the Elixhauser
  comorbidities.

- [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  for applying comorbidity algorithms to a dataset.

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
