# Synthetic Data

Synthetic Data

## Usage

``` r
mdcr
```

## Format

`mdcr` is a `data.frame` with 4 columns, one for a patient id and 41 for
diagnostic codes and 41 possible procedure codes. Each row is for one
patient id.

- `patid`: patient identifier, integer values

- `icdv`: ICD version; integer values, 9 or 10

- `dx`: indicator column for ICD diagnostic (1) or procedure (0) codes

- `code`: ICD code; character values

## See also

Other datasets:
[`mdcr_longitudinal`](http://www.peteredewitt.com/medicalcoder/reference/mdcr_longitudinal.md)
