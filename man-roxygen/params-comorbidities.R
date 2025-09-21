#' @param data A `data.frame` in a "long" format. The input `data.frame` is
#'   expected to have one column of ICD codes (one code per row) with additional
#'   (optional) columns for patient/encounter ids, ICD version,
#'   diagnostic/procedure status, present-on-admission flags, primary
#'   diagnostic flags, or age.
#'
#' @param icd.codes Character scalar naming the column in `data` that contains
#'   ICD codes.  The codes can be full (with applicable dots, e.g., C84.2),
#'   compact (dots omitted, e.g., C842), or a mix of both full and compact
#'   codes.  Use
#'
#' @param id.vars Optional character vector of column names. When
#'   missing, the entire input `data` is treated as a single encounter from a
#'   single patient.  If you want to set `flag.method = "current"` then
#'   `length(id.vars) >= 2` is expected.  The last element would be the
#'   encounter order (must be sortable)."
#'
#' @param icdv.var Character scalar naming the column in `data` that indicates
#'   the ICD version (9 or 10). If present it must be integer values `9` or
#'   `10`.  `icdv.var` takes precedence over `icdv` if both are provided.
#'
#' @param icdv An integer value of `9L` or `10L` indicating that all
#'   `data[[icd.codes]]` are ICD version 9 or 10, respectively. Ignored
#'   (with a warning) if `icdv.var` is provided.
#'
#' @param dx.var Character scalar naming the column in `data` that indicates
#'   diagnostic (`1`) vs procedural (`0`) codes. If present it must be integer
#'   values `0` or `1`.  `dx.var` takes precedence over `dx` if both are
#'   provided.
#'
#' @param dx An integer indicating that all `data[[icd.codes]]` are
#'   diagnostic (`1`) or procedure (`0`) codes. Ignored (with a
#'   warning) if `dx.var` is provided.
#'
#' @param poa.var Character scalar naming the column with present-on-admission
#'   flags: integer `1L` (present), `0L` (not present), or `NA`.
#'   PCCC and Charlson will only flag conditions when the code is
#'   present-on-admission.  Elixhauser has a mix of conditions some require
#'   present-on-admission others do not. `poa.var` takes precedence over `poa`
#'   is both are provided.
#'
#' @param poa Integer scalar `0` or `1`. Use when all `icd.codes` share the same
#'   present-on-admission status. Ignored with a warning if `poa` and `poa.var`
#'   are both provided.
#'
#' @param primarydx.var Character scalar naming the column in `data` that
#'   indicates whether `data[[icd.codes]]` are primary diagnostic codes (`1L`)
#'   or not (`0L`). Primary diagnosis is used only for Elixhauser comorbidities
#'   and is ignored when the method is PCCC or Charlson. `primarydx.var` takes
#'   precedence over `primarydx` if both are provided.
#'
#' @param primarydx An integer value of `0` or `1`. If `0`,
#'   treat all codes as non-primary diagnoses; if `1`, treat all codes as
#'   primary diagnoses. Ignored, with a  warning, if `primarydx.var` is
#'   provided.
#'
#' @param age.var Character scalar naming the column in `data` that contains
#'   patient age in years. Only applicable to Charlson comorbidities.
#'
#' @param flag.method When `flag.method = 'current'` (default) only codes
#' associated with the current `id.vars` are considered when flagging
#' comorbidities.  When `flag.method = 'cumulative'` then all prior encounters
#' are considered when flagging comorbidities. See **Details**.
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
