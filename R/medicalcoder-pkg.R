#' medicalcoder
#'
#' An R package for working with ICD codes and comorbidity assessments.
#'
#' `medicalcoder` is a lightweight, base-R package for working with ICD-9 and
#' ICD-10 diagnosis and procedure codes. It provides fast, dependency-free tools
#' to look up, validate, and manipulate ICD codes, while also implementing
#' widely used comorbidity algorithms such as Charlson, Elixhauser, and the
#' Pediatric Complex Chronic Conditions (PCCC).
#' Designed for portability and reproducibility, the package avoids external
#' dependencies—requiring only R >= 3.5.0—yet offers a rich set of curated ICD
#' code libraries from the United States' Centers for Medicare and Medicaid
#' Services (CMS), Centers for Disease Control (CDC), and the World Health
#' Organization (WHO).
#'
#' The package balances performance with elegance: its internal caching,
#' efficient joins, and compact data structures make it practical for
#' large-scale health data analyses, while its clean design makes it easy to
#' extend or audit. Whether you need to flag comorbidities, explore ICD
#' hierarchies, or standardize clinical coding workflows, `medicalcoder` provides
#' a robust, transparent foundation for research and applied work in biomedical
#' informatics.
#'
#' # Implementation
#'
#' The `medicalcoder` package was intentionally designed and built to have zero
#' dependencies beyond R version 3.5.0 (needed due to a [change in data
#' serialization](https://cran.r-project.org/src/base/NEWS.3#:~:text=R%20has%20new,to%20version%203.5.0.))
#' and zero imports.  The package is completely self contained for the purposes
#' of installation and use.
#'
#' This design choice was made for several reasons.
#'
#' 1. Ease of installation:
#'    * Only requirement is R >= 3.5.0.
#'    * No need for external files or downloads or other packages for the ICD data-base.
#'
#' 2. Works well with different data paradigms
#'    * Base R `data.frames`,
#'    * [tidyverse](https://tidyverse.org/) `tibble`s, and
#'    * `data.table`s from the [data.table](https://rdatatable.gitlab.io/data.table/) package.
#'
#' One of the reasons for focusing on building a self-contained package with no
#' need for additional namespaces is to make installation and use in an
#' pseudo-air-gapped system easier.  The author of this package routinely works
#' on machines with extremely limited, access to the world-wide-web.  As
#' such, relying on any system dependencies or other R packages can become
#' difficult as the machine may or may not have the needed software.  So long as
#' R >= 3.5.0 is available `medicalcoder` will work.
#'
#' A great deal of thought went into performance of the methods and the size of
#' the package.  The internal data sets, for example, are not stored in a
#' structure that is easy to use by end user.  When the package namespaces is
#' loaded the needed internal lookup tables are generated and cached.
#'
#' @seealso [comorbidities()], [get_icd_codes()], [is_icd()],
#'
#' * Vignette for working with ICD codes:
#'   * `vignette(topic = "icd", package = "medicalcoder")`
#' * Vignettes for applying comorbidities:
#'   * `vignette(topic = "comorbidities", package = "medicalcoder")`
#'   * `vignette(topic = "pccc", package = "medicalcoder")`
#'   * `vignette(topic = "charlson", package = "medicalcoder")`
#'   * `vignette(topic = "elixhauser", package = "medicalcoder")`
#'
#' @keywords internal
"_PACKAGE"
