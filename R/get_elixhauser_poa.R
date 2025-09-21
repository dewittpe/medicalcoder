#' Get Elixhauser Present-on-Admission Requirements
#'
#' Retrieve a copy of internal lookup table with details on which Elixhauser
#' comorbidities do and do not require the associated ICD codes to be
#' present-on-admission to be flagged.
#'
#' @seealso
#' * [`get_elixhauser_index_scores()`] for the lookup table of the condition by
#'   condition scores for mortality and readmission indices.
#' * [`get_elixhauser_codes()`] for the lookup table of ICD codes mapping to the
#'   Elixhauser comorbidities.
#' * [comorbidities()] for applying comorbidity algorithms to a data set.
#' 
#' @return A `data.frame` with the following columns:
#' * `condition`: Character vector of the conditions
#' * `desc`: Character vector with a verbose description of the condition
#' * `poa_required`: Integer indicators if the code needs to present on admission to be considered a comorbidity
#' * `elixhauser_<variant>`: indicators for the Elixhauser `<variant>`
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
