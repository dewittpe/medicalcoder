#' Get Elixhauser Present-on-Admission Requirements
#'
#' Retrieve a copy of internal lookup table with details on which Elixhauser
#' comorbidities do and do not require the associated ICD codes to be
#' present-on-admission to be flagged. This is a condition-level rule table;
#' code-level POA exemptions are a separate part of the Elixhauser mapping.
#'
#' For the AHRQ ICD-10-CM methods, `poa_required = 1L` means a condition is
#' flagged when a mapped diagnosis is POA or its code is POA exempt.
#' `poa_required = 0L` means the condition is flagged regardless of the
#' diagnosis POA value. The `elixhauser_ahrqYYYY` columns identify which annual
#' AHRQ release uses each condition/rule row. The combined
#' `elixhauser_ahrq_icd10` column marks rows used by any included annual
#' release; it is a union, not a separate annual AHRQ release.
#'
#' @seealso
#' * [`get_elixhauser_index_scores()`] for the lookup table of the condition by
#'   condition scores for mortality and readmission indices.
#' * [`get_elixhauser_codes()`] for the lookup table of ICD codes mapping to the
#'   Elixhauser comorbidities.
#' * [`comorbidities()`] for applying comorbidity algorithms to a dataset.
#' 
#' @return A `data.frame` with the following columns:
#' * `condition`: Character vector naming the comorbidity condition. A
#'   condition can have more than one row if its POA requirement changes by
#'   method or release.
#' * `poa_required`: Integer rule flag: `1L` means POA is required, subject to
#'   code-level exemptions; `0L` means the condition is POA neutral.
#' * `elixhauser_<variant>`: Integer membership flag indicating whether the
#'   row's condition and POA rule apply to that variant.
#'
#' @examples
#' head(get_elixhauser_poa())
#' str(get_elixhauser_poa())
#'
#' @export
get_elixhauser_poa <- function() {
  unserialize(serialize(..mdcr_internal_elixhauser_poa.., connection = NULL))
}

################################################################################
#                                 End of File                                  #
################################################################################
