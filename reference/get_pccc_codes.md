# Pediatric Complex Chronic Conditions ICD Codes

Retrieve a copy of internal lookup tables for the ICD codes mapping to
the Pediatric Complex Chronic Conditions (PCCC) conditions and
subconditions by variant.

## Usage

``` r
get_pccc_codes()
```

## Value

a `data.frame` with the following columns

- `icdv`: Integer vector indicating if the code is from ICD-9 or ICD-10.

- `dx`: Integer vector. 1 if the code is a diagnostic, (ICD-9-CM,
  ICD-10-CM, WHO, CDC Mortality), or 0 if the code is procedural
  (ICD-9-PCS, ICD-10-PCS).

- `full_code`: Character vector with the ICD code and any relevant
  decimal point.

- `code`: Character vector with the compact ICD code omitting any
  relevant decimal point.

- `condition`: Character vector of the conditions.

- `subcondition`: Character vector of the subconditions.

- `transplant_flag`: Integer vector indicating if the code is associated
  with a transplant.

- `tech_dep_flag`: Integer vector indicating if the code is associated
  with technology dependence.

- `pccc_<variant>`: Integer vector indicating if the code is part of the
  v2.0, v2.1, v3.0, or v3.1 variant.

## See also

- [`get_pccc_conditions()`](http://www.peteredewitt.com/medicalcoder/reference/get_pccc_conditions.md)
  for a reference of the PCCC conditions and subconditions.

- [`get_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_icd_codes.md)
  for the lookup table of all ICD codes.

- [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  for applying comorbidity algorithms to a data set.

## Examples

``` r
head(get_pccc_codes())
#>   icdv dx full_code code  condition              subcondition transplant_flag
#> 1    9  0     00.10 0010 malignancy                 neoplasms               0
#> 2    9  0     00.50 0050        cvd device_and_technology_use               0
#> 3    9  0     00.51 0051        cvd device_and_technology_use               0
#> 4    9  0     00.53 0053        cvd device_and_technology_use               0
#> 5    9  0     00.54 0054        cvd device_and_technology_use               0
#> 6    9  0     00.55 0055        cvd device_and_technology_use               0
#>   tech_dep_flag pccc_v3.1 pccc_v3.0 pccc_v2.1 pccc_v2.0
#> 1             0         1         1         1         1
#> 2             1         1         1         1         1
#> 3             1         1         1         1         1
#> 4             1         1         1         1         1
#> 5             1         1         1         1         1
#> 6             1         1         1         1         1
str(get_pccc_codes())
#> 'data.frame':    7906 obs. of  12 variables:
#>  $ icdv           : int  9 9 9 9 9 9 9 9 9 9 ...
#>  $ dx             : int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ full_code      : chr  "00.10" "00.50" "00.51" "00.53" ...
#>  $ code           : chr  "0010" "0050" "0051" "0053" ...
#>  $ condition      : chr  "malignancy" "cvd" "cvd" "cvd" ...
#>  $ subcondition   : chr  "neoplasms" "device_and_technology_use" "device_and_technology_use" "device_and_technology_use" ...
#>  $ transplant_flag: int  0 0 0 0 0 0 0 1 1 1 ...
#>  $ tech_dep_flag  : int  0 1 1 1 1 1 1 0 0 0 ...
#>  $ pccc_v3.1      : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ pccc_v3.0      : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ pccc_v2.1      : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ pccc_v2.0      : int  1 1 1 1 1 1 1 1 1 1 ...
```
