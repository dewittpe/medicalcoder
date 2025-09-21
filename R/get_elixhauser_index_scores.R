#' Get Elixhauser Index Scores
#'
#' Functions to get a copy of internal lookup tables for the ICD codes and index
#' scores used in assessing Elixhauser comorbidities.
#'
#' @seealso
#' * [`get_elixhauser_codes()`] for the lookup table of ICD codes mapping to the
#'   Elixhauser comorbidities.
#' * [`get_elixhauser_poa()`] for the lookup table of the conditions which do an
#'   do not require associated ICD codes to be present-on-admission to flag the
#'   comorbidity.
#' * [comorbidities()] for applying comorbidity algorithms to a data set.
#' 
#' @return A `data.frame` with the following columns:
#' * `condition`: Character vector of the conditions
#' * `index`: Character vector indicating if the score is for the mortality or the readmission index score
#' * `elixhauser_<variant>`: integer vector of the scores 
#'
#' @examples
#' head(get_elixhauser_index_scores())
#' str(get_elixhauser_index_scores())
#' 
#' @export
get_elixhauser_index_scores <- function() {
  unserialize(serialize(..mdcr_internal_elixhauser_index_scores.., connection = NULL))
}

################################################################################
#                                 End of File                                  #
################################################################################
