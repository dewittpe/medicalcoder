# Synthetic Data

Synthetic Data

## Usage

``` r
mdcr
```

## Format

`mdcr` is a `data.frame` with 4 columns. Each row is for one ICD code.

- `patid`: patient identifier, integer values

- `icdv`: ICD version; integer values, `9L` or `10L`

- `dx`: indicator column for ICD diagnostic (`1L`) or procedure (`0L`)
  codes

- `code`: ICD code; character values

## See also

Other datasets:
[`mdcr_longitudinal`](http://www.peteredewitt.com/medicalcoder/reference/mdcr_longitudinal.md)
