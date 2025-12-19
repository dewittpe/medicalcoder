# Changelog

## medicalcoder 0.7.0.9000

### New Features

- If a `tibble` is passed to
  [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  and the `dplyr` namespace is available, then `dplyr` methods will be
  used for data manipulation. This change will generally result in less
  computation time than base R `data.frames` (`data.tables` require even
  less time).

- Add the `elixhauser_ahrq2026` method for
  [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  ([\#32](https://github.com/dewittpe/medicalcoder/issues/32))

### Bug Fixes

- `summary.medicalcoder_comorbidites()` no longer crashes when a zero
  row input is passed in. Consistently return `NA` instead of `NaN` when
  counts are zeros.
  ([\#26](https://github.com/dewittpe/medicalcoder/issues/26),
  [\#27](https://github.com/dewittpe/medicalcoder/issues/27))

- Improve the conditional and multiple comorbidities mapped by a code
  under AHRQ ICD-10 codes for fiscal years 2023 through 2026. The bug
  was found and fixed as part of the extension
  [\#32](https://github.com/dewittpe/medicalcoder/issues/32).

### Other Changes

- Extend and improve the internal ICD-9 database to distinguish between
  CDC and CMS source.

- Fix documentation of the `mdcr` and `mdcr_longitudinal` datasets.

- Clarified internal data.frame/data.table helpers: documented that
  `mdcr_select()` deep-copies data.table subsets to avoid aliasing,
  noted the selfref fix in `mdcr_set()`, and added inline guidance in
  the longitudinal section of
  [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  to explain the first-occurrence logic.

- Improve cumulative flagging to apply first-occurrence logic more
  efficiently.

- Extend documentation for the expected default behavior between the
  present-on-admission flags and `flag.method` argument in
  [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  (re: [\#28](https://github.com/dewittpe/medicalcoder/issues/28))

- Add `mdcr_unique()` to the data.frame utilities. This reduced the
  computational time required to apply
  [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  to `tibble`s and `data.table`s.
  ([\#31](https://github.com/dewittpe/medicalcoder/issues/31))

## medicalcoder 0.7.0

CRAN release: 2025-11-22

### Bug Fixes

- Elixhauser AHRQ 2022 - 2025

  - exclusions for less severer conditions when more severer conditions
    are flagged
  - Improved POA, NPOA, and EXEMPTPOA. This came about from
    [\#20](https://github.com/dewittpe/medicalcoder/issues/20).

- Make internal data.frame tool `mdcr_duplicated()` data.table aware.

- Elixhauser (Quan 2005) - added missing ICD-10 codes to the mappings

### New Features

- [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  will return a `tibble` with the input data is a `tbl_df`
  ([\#9](https://github.com/dewittpe/medicalcoder/issues/9)). Assuming
  the `data.table` and/or `tibble` namespaces are available, then the
  initial release (v0.6.0) would return a `data.table` if a `data.table`
  was passed to a
  [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  due to the S3 method dispatches. If a `tibble` (`tdl_df`) or a
  `data.frame` was passed to
  [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  then the return would be a `data.frame`. In this release we have added
  logic to determine if the input is a `tibble` and if the `tibble`
  namespaces is available, then the return from
  [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  will be a `tibble` (or list of `tibble`s when `subconditions = TRUE`).

  The tests were extended to consider the cases of passing in a
  `data.table` or `tibble` to comorbidities when the associated
  namespaces are not available.

- Added `elixhauser_ahrq_icd10` to use all the ICD codes ever defined
  from 2022 to 2025. This will capture any future years as well.

### Other Changes

- Improve formatting of vignettes/articles.

## medicalcoder 0.6.0

CRAN release: 2025-10-15

- Initial CRAN submission, providing a dependency-free toolkit for
  ICD-9/10 code lookups
  - [`lookup_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/lookup_icd_codes.md),
  - [`get_icd_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_icd_codes.md),
  - [`icd_compact_to_full()`](http://www.peteredewitt.com/medicalcoder/reference/icd_compact_to_full.md),
    and
  - [`is_icd()`](http://www.peteredewitt.com/medicalcoder/reference/is_icd.md).
- Introduces a unified
  [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  interface covering Charlson (Deyo, Quan 2005/2011, Glasheen),
  Elixhauser (original, Quan 2005, AHRQ 2017-2025), and Pediatric
  Complex Chronic Conditions (v2.0/2.1/3.0/3.1).
- Adds support for present-on-admission indicators, longitudinal
  look-back, age scoring, and PCCC sub-condition flags within
  [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md).
- Bundles curated ICD dictionaries alongside example datasets (`mdcr`,
  `mdcr_longitudinal`) for reproducible testing and demonstrations.
- Includes vignettes and benchmarking summaries that document usage
  patterns and showcase performance without non-base dependencies.
