# Get Charlson Index Scores

Retrieve a copy of internal lookup tables of index scores used in
assessing Charlson comorbidities. The lookup includes score columns for
each implemented Charlson variant.

## Usage

``` r
get_charlson_index_scores()
```

## Value

A `data.frame` with the following columns:

- `condition`: Character vector of the conditions

- `index`: Character vector indicating if the score is for the mortality
  or the readmission index score

- `charlson_<variant>`: the index scores for the variant

## See also

- [`get_charlson_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_charlson_codes.md)
  for a lookup table of the ICD codes mapping to the Charlson
  comorbidities.

- [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  for applying comorbidity algorithms to a data set.

## Examples

``` r
head(get_charlson_index_scores())
#>       condition_description condition charlson_cdmf2019 charlson_quan2011
#> 1                      AIDS      aids                 6                NA
#> 2                  AIDS/HIV   aidshiv                NA                 4
#> 3    HIV infection, no AIDS       hiv                 3                NA
#> 4            Any malignancy       mal                 2                 2
#> 5   Cerebrovascular disease     cebvd                 1                 0
#> 6 Chronic pulmonary disease      copd                 1                 1
#>   charlson_quan2005 charlson_deyo1992 charlson_sundararajan2004
#> 1                NA                NA                        NA
#> 2                 6                 6                         6
#> 3                NA                NA                        NA
#> 4                 2                 2                         2
#> 5                 1                 1                         1
#> 6                 1                 1                         1
#>   charlson_ludvigsson2021
#> 1                      NA
#> 2                       6
#> 3                      NA
#> 4                       2
#> 5                       1
#> 6                       1
str(get_charlson_index_scores())
#> 'data.frame':    22 obs. of  8 variables:
#>  $ condition_description    : chr  "AIDS" "AIDS/HIV" "HIV infection, no AIDS" "Any malignancy" ...
#>  $ condition                : chr  "aids" "aidshiv" "hiv" "mal" ...
#>  $ charlson_cdmf2019        : int  6 NA 3 2 1 1 1 1 2 1 ...
#>  $ charlson_quan2011        : int  NA 4 NA 2 0 1 2 2 1 0 ...
#>  $ charlson_quan2005        : int  NA 6 NA 2 1 1 1 1 2 1 ...
#>  $ charlson_deyo1992        : int  NA 6 NA 2 1 1 1 1 2 1 ...
#>  $ charlson_sundararajan2004: int  NA 6 NA 2 1 1 1 1 2 1 ...
#>  $ charlson_ludvigsson2021  : int  NA 6 NA 2 1 1 1 1 2 1 ...
```
