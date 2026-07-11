#' @param data A `data.frame` in a "long" format. The input `data.frame` is
#'   expected to have one column of ICD codes (one code per row) with additional
#'   (optional) columns for patient/encounter ids, ICD version,
#'   diagnostic/procedure status, present-on-admission flags, primary
#'   diagnostic flags, or age.
#'
#' @param icd.codes Character scalar naming the column in `data` that contains
#'   ICD codes (character strings). Codes may be provided in full form (with
#'   decimal points, e.g., C84.2), compact form (dots omitted, e.g., C842), or
#'   any mix of the two. Matching against lookup tables is governed by
#'   `icdv.var`/`icdv`, `dx.var`/`dx`, and the `full.codes` / `compact.codes`
#'   flags.
#'
#' @param id.vars Optional character vector of column names. When
#'   missing, the entire input `data` is treated as a single encounter from a
#'   single patient. If you want to set `flag.method = "cumulative"` then
#'   `length(id.vars) >= 2` is
#'   expected. The last element should be the encounter order. It must not
#'   contain missing values, must not be a factor, and must be numeric,
#'   character, `Date`, or `POSIXt`. Character encounter order columns are
#'   allowed with a warning because they are sorted lexicographically.
#'
#' @param icdv.var Character scalar naming the column in `data` that indicates
#'   the ICD version. If present it must be numeric. Rows with values other than
#'   `9L` or `10L` will not be used to map ICD codes to comorbidities.
#'   `icdv.var` takes precedence over `icdv` if both are provided.
#'
#' @param icdv An integer value of `9L` or `10L` indicating that all
#'   `data[[icd.codes]]` are ICD version 9 or 10, respectively. Ignored
#'   (with a warning) if `icdv.var` is provided.
#'
#' @param dx.var Character scalar naming the column in `data` that indicates
#'   diagnostic (`1L`) vs procedural (`0L`) codes. If present it must be numeric.
#'   Rows with values other than `0L` or `1L` will not be used to map ICD codes to
#'   comorbidities. `dx.var` takes precedence over `dx` if both are provided.
#'
#' @param dx An integer indicating that all `data[[icd.codes]]` are
#'   diagnostic (`1L`) or procedure (`0L`) codes. Ignored (with a
#'   warning) if `dx.var` is provided.
#'
#' @param poa.var Character scalar naming the column with present-on-admission
#'   flags: integer `1L` (present), `0L` (not present), or `NA`.
#'   For AHRQ SAS-compatible present-on-admission indicators, convert `"Y"`
#'   and `"W"` to `1L`, convert `"N"` and `"U"` to `0L`, and convert blank or
#'   missing values to `NA_integer_` before calling `comorbidities()`.
#'   PCCC and Charlson will only flag conditions when the code is
#'   present-on-admission. Elixhauser has a mix of conditions; some require
#'   present-on-admission while others do not. `poa.var` takes precedence over
#'   `poa` if both are provided.
#'
#' @param poa Integer scalar `0L` or `1L`. Use when all `icd.codes` share the same
#'   present-on-admission status. Ignored with a warning if `poa` and `poa.var`
#'   are both provided.
#'
#' @param primarydx.var Character scalar naming the column in `data` that
#'   indicates whether `data[[icd.codes]]` are primary diagnostic codes (`1L`)
#'   or not (`0L`). Primary diagnosis is used only for Elixhauser and Charlson
#'   comorbidities and is ignored when the method is a PCCC variant.
#'   `primarydx.var` takes precedence over `primarydx` if both are provided.
#'
#' @param primarydx An integer value of `0L` or `1L`. If `0L`,
#'   treat all codes as non-primary diagnoses; if `1L`, treat all codes as
#'   primary diagnoses. Ignored, with a warning, if `primarydx.var` is provided.
#'
#' @param age.var Character scalar naming the column in `data` that contains
#'   patient age in years. Only applicable to Charlson comorbidities.
#'
#' @param flag.method When `flag.method = "current"` (default) only codes
#'   associated with the current `id.vars` are considered when flagging
#'   comorbidities. The `flag.method = "cumulative"` option also
#'   considers prior encounters when flagging comorbidities. See **Details**.
#'
#' @param full.codes,compact.codes Logical; when `TRUE` compare
#'   `data[[icd.codes]]` against full and/or compact ICD codes in the
#'   method’s lookup tables. Full ICD codes include a decimal point (when
#'   applicable) and compact codes omit the decimal point. For example:
#'   `B95.0` is the full ICD-10-CM diagnostic code for “Streptococcus,
#'   group A, as the cause of disease classified elsewhere,” whereas `B950`
#'   is the associated compact code.
#'
#' @param method Character string indicating the comorbidity algorithm to
#'   apply to `data`.
#'
#' @param subconditions Logical scalar; when `TRUE`, report both conditions and
#'   subconditions (PCCC only).
#'
#' @param mapping Character string specifying how `data[[icd.codes]]` should be
#'   mapped to comorbidity conditions. `mapping = "precomputed"` uses the
#'   precomputed ICD code-condition links included with medicalcoder and is the
#'   default. `mapping = "regex"` applies the method's regular expressions
#'   directly to the input ICD codes. See Details.
#'
