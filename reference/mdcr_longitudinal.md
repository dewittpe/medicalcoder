# Synthetic Longitudinal Data

Synthetic Longitudinal Data

## Usage

``` r
mdcr_longitudinal
```

## Format

`mdcr_longitudinal` is a `data.frame` with 4 columns. The codes are
expected to be treated as diagnostic codes. Warning: there are a few
ICD-9 codes which could match to procedure codes.

- `patid`: patient identifier, integer values

- `date`: date the diagnostic code was recorded

- `icdv`: ICD version `9L` or `10L`, integer valued

- `code`: ICD codes; character values

## See also

Other datasets:
[`mdcr`](http://www.peteredewitt.com/medicalcoder/reference/mdcr.md)
