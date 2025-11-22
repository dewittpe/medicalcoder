# medicalcoder 0.7.0

## Bug Fixes
* Elixhauser AHRQ 2022 - 2025

  * exclusions for less severer conditions when more severer conditions are flagged
  * Improved POA, NPOA, and EXEMPTPOA.  This came about from #20.

* Make internal data.frame tool `mdcr_duplicated` data.table aware.

* Elixhauser (Quan 2005) - added missing ICD-10 codes to the mappings

## New Features

* `comorbidities()` will return a `tibble` with the input data is a `tbl_df`
  (#9).  Assuming the `data.table` and/or `tibble` namespaces are available,
  then the initial release (v0.6.0) would return a `data.table` if a
  `data.table` was passed to a `comorbidities()` due to the S3 method
  dispatches.  If a `tibble` (`tdl_df`) or a `data.frame` was passed to
  `comorbidities()` then the return would be a `data.frame`.  In this release we
  have added logic to determine if the input is a `tibble` and if the `tibble`
  namespaces is available, then the return from `comorbidities()` will be a
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
