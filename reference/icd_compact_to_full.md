# Convert ICD Compact Codes to Full Codes

Take an assumed ICD compact code string and convert to a full code based
on the ICD version (9 or 10) and type (diagnostic or procedure). This
method only formats strings and does not validate the code(s).

## Usage

``` r
icd_compact_to_full(x, icdv, dx)
```

## Arguments

- x:

  Character vector

- icdv:

  Integer vector of allowed ICD versions. Use `9L` and/or `10L`.
  Defaults to both.

- dx:

  Integer vector indicating allowed code type(s): `1L` for diagnostic
  (ICD-9-CM, ICD-10-CM, CDC mortality, WHO), `0L` for procedural
  (ICD-9-PCS, ICD-10-PCS). Defaults to both.

## Value

A character vector the same length as `x`.

## See also

- [`get_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_icd_codes.md)
  to retrieve the internal lookup table of ICD codes.

- [`lookup_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/lookup_icd_codes.md)
  for retrieving details on a specific set of ICD codes.

- [`is_icd()`](http://www.peteredewitt.com/medicalcoder/reference/is_icd.md)
  to test if a string is a known ICD code.

Other ICD tools:
[`is_icd()`](http://www.peteredewitt.com/medicalcoder/reference/is_icd.md),
[`lookup_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/lookup_icd_codes.md)
