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
