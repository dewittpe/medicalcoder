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
#'   `length(id.vars) >= 2` is expected. The last element should be the
#'   encounter order (must be sortable).
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
#'   present-on-admission. Elixhauser has a mix of conditions; some require
#'   present-on-admission while others do not. `poa.var` takes precedence over
#'   `poa` if both are provided.
#'
#' @param poa Integer scalar `0` or `1`. Use when all `icd.codes` share the same
#'   present-on-admission status. Ignored with a warning if `poa` and `poa.var`
#'   are both provided.
#'
#' @param primarydx.var Character scalar naming the column in `data` that
#'   indicates whether `data[[icd.codes]]` are primary diagnostic codes (`1L`)
#'   or not (`0L`). Primary diagnosis is used only for Elixhauser and Charlson
#'   comorbidities and is ignored when the method is a PCCC variant.
#'   `primarydx.var` takes precedence over `primarydx` if both are provided.
#'
#' @param primarydx An integer value of `0` or `1`. If `0`,
#'   treat all codes as non-primary diagnoses; if `1`, treat all codes as
#'   primary diagnoses. Ignored, with a warning, if `primarydx.var` is provided.
#'
#' @param age.var Character scalar naming the column in `data` that contains
#'   patient age in years. Only applicable to Charlson comorbidities.
#'
#' @param flag.method When `flag.method = 'current'` (default) only codes
#' associated with the current `id.vars` are considered when flagging
#' comorbidities.  When `flag.method = 'cumulative'` then all prior encounters
#' are considered when flagging comorbidities. See **Details**.
#'
#' @param full.codes,compact.codes Logical values indicating whether dotted
#'   ICD codes, compact ICD codes, or both should be considered when
#'   `mapping = "precomputed"`. When `mapping = "regex"`, code-format
#'   tolerance is built into the package-supplied regular expressions, so
#'   submitted codes may be dotted or compact without separate expansion.
#'
#'   Full ICD codes include a decimal point (when
#'   applicable) and compact codes omit the decimal point. For example:
#'   `B95.0` is the full ICD-10-CM diagnostic code for “Streptococcus,
#'   group A, as the cause of disease classified elsewhere,” whereas `B950`
#'   is the associated compact code.
#'
#' @param method Character string indicating the comorbidity algorithm to
#'   apply to `data`.
#'
#' @param subconditions Logical scalar; when `TRUE`, report both conditions and
#'   subconditions (PCCC only). Subcondition tables are returned in the
#'   `subconditions` element of the result.
#'
#' @param mapping The mapping strategy to use. The default,
#'   `"precomputed"`, matches submitted ICD codes against package data
#'   containing the relevant code-to-comorbidity relationships.
#'   `"regex"` matches submitted ICD codes against regular expressions
#'   derived from the published comorbidity definitions.
#'
#'   The regular expressions used by `"regex"` are written to match both
#'   dotted and compact ICD code formats. For example, a pattern such as
#'   `"^F02\\.?4"` matches both `"F02.4"` and `"F024"`. The expressions
#'   are anchored at the start of the code and are generally intended to
#'   match ICD code prefixes, so descendant codes also match when implied by
#'   the comorbidity definition.
#'
#'
#' @param inferred.conditions Logical scalar; when `TRUE` and
#'   `flag.method = "cumulative"`, include a table describing reported and
#'   carried-forward conditions in the `inferred_conditions` element of the
#'   result. For other flagging methods, `inferred_conditions` is `NULL`.
