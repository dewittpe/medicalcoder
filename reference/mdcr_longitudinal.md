# Synthetic Longitudinal Data

Synthetic Longitudinal Data

## Usage

``` r
mdcr_longitudinal
```

## Format

`mdcr_longitudinal` is a `data.frame` with four columns. The codes are
expected to be treated as diagnostic codes but there are a few ICD-9
codes which could match to procedure codes as well.

- `patid`: patient identifier, integer values

- `date`: date the diagnostic code was recorded

- `icdv`: ICD version 9 or 10, integer valued

- `code`: ICD codes; character values

## See also

Other datasets:
[`mdcr`](http://www.peteredewitt.com/medicalcoder/reference/mdcr.md)
