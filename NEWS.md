# medicalcoder 0.8.0

## License Change

medicalcoder <= 0.7.0 was under GPL-2 for no other reason that that was the
default in the template DESCRIPTION file.  With this release we have
transitioned from GPL-2 to BSD-3-Clause to reduce almost all barriers to use of
the package in other environments.

## New Features

* If a `tibble` is passed to `comorbidities()` and the `dplyr` namespace is
  available, then `dplyr` methods will be used for data manipulation.  This
  change will generally result in less computation time than base R
  `data.frames` (`data.tables` require even less time).

* Add the `elixhauser_ahrq2026` method for `comorbidities()` (#32)

## Bug Fixes

* `summary.medicalcoder_comorbidites()` no longer crashes when a zero row input
  is passed in. Consistently return `NA` instead of `NaN` when counts are zeros.
  (#26, #27)

* Improve the conditional and multiple comorbidities mapped by a code under AHRQ
  ICD-10 codes for fiscal years 2023 through 2026.  The bug was found and fixed
  as part of the extension #32.

* Add ICD-9-PCS 35.7 to the PCCC codes. (#38)
  The v2 docs have 37.52, 37.53, 37.54, 37.55 as cvd (device) and 37.5, 37.51 as
  cvd (transplant). v3 docs have 3751 as cvd (transplant), all other four digit
  codes under 37.5 as cvd (device). One issue here is that 37.5 was an
  assignable code from CDC through 2003 and then was a header with the same four
  digit codes as CMS through 2012. CMS continued to use the four digit codes
  through 2015.

* Improve Elixhauser (Quan 2005) ICD-10 codes
  * omitting F42.2 for depression
  * adding G36.x for neuro
  * adding 333.4 for neuro

* Add checks for data structures (#41)

* Handle zero length patterns in regex (#42)

## Other Changes

* Extend and improve the internal ICD-9 database to distinguish between CDC and
  CMS source.

* Fix documentation of the `mdcr` and `mdcr_longitudinal` datasets.

* Clarified internal data.frame/data.table helpers: documented that `mdcr_select()`
  deep-copies data.table subsets to avoid aliasing, noted the selfref fix in
  `mdcr_set()`, and added inline guidance in the longitudinal section of
  `comorbidities()` to explain the first-occurrence logic.

* Improve cumulative flagging to apply first-occurrence logic more efficiently.

* Extend documentation for the expected default behavior between the
  present-on-admission flags and `flag.method` argument in `comorbidities()`
  (re: #28)

* Add `mdcr_unique()` to the data.frame utilities. This reduced the computational
  time required to apply `comorbidities()` to `tibble`s and `data.table`s. (#31)

# medicalcoder 0.7.0

## Bug Fixes
* Elixhauser AHRQ 2022 - 2025

  * exclusions for less severe conditions when more severe conditions are
    flagged.
  * Improved POA, NPOA, and EXEMPTPOA.  This came about from #20.

* Make internal data.frame tool `mdcr_duplicated()` data.table aware.

* Elixhauser (Quan 2005) - added missing ICD-10 codes to the mappings

## New Features

* `comorbidities()` will return a `tibble` when the input data is a `tbl_df`
  (#9).  Assuming the `data.table` and/or `tibble` namespaces are available,
  then the initial release (v0.6.0) would return a `data.table` if a
  `data.table` was passed to a `comorbidities()` due to the S3 method
  dispatches.  If a `tibble` (`tbl_df`) or a `data.frame` was passed to
  `comorbidities()` then the return would be a `data.frame`.  In this release we
  have added logic to determine if the input is a `tibble` and if the `tibble`
  namespace is available, then the return from `comorbidities()` will be a
  `tibble` (or list of `tibble`s when `subconditions = TRUE`).

  The tests were extended to consider the cases of passing in a `data.table` or
  `tibble` to comorbidities when the associated namespaces are not available.

* Added `elixhauser_ahrq_icd10` to use all the ICD codes ever defined from 2022
  to 2025.  This will capture any future years as well.

## Other Changes

* Improve formatting of vignettes/articles.

# medicalcoder 0.6.0

* Initial CRAN submission, providing a dependency-free toolkit for ICD-9/10 code
  lookups
  * `lookup_icd_codes()`,
  * `get_icd_codes()`,
  * `icd_compact_to_full()`, and
  * `is_icd()`.
* Introduces a unified `comorbidities()` interface covering Charlson (Deyo, Quan
  2005/2011, Glasheen), Elixhauser (original, Quan 2005, AHRQ 2017-2025), and
  Pediatric Complex Chronic Conditions (v2.0/2.1/3.0/3.1).
* Adds support for present-on-admission indicators, longitudinal look-back, age
  scoring, and PCCC sub-condition flags within `comorbidities()`.
* Bundles curated ICD dictionaries alongside example datasets (`mdcr`,
  `mdcr_longitudinal`) for reproducible testing and demonstrations.
* Includes vignettes and benchmarking summaries that document usage patterns and
  showcase performance without non-base dependencies.
