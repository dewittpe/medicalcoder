#' Get Charlson Index Scores
#'
#' Retrieve a copy of internal lookup tables of index scores used in assessing
#' Charlson comorbidities.
#'
#' @seealso
#' * [`get_charlson_codes()`] for a lookup table of the ICD codes mapping to the
#'   Charlson comorbidities.
#' * [comorbidities()] for applying comorbidity algorithms to a data set.
#'
#' @return A `data.frame` with the following columns:
#' 
#' * `condition`: Character vector of the conditions
#' * `index`: Character vector indicating if the score is for the mortality or the readmission index score
#' * `charlson_<variant>`:  the index scores for the variant
#'
#' @examples
#' head(get_charlson_index_scores())
#' str(get_charlson_index_scores())
#'
#' @export
get_charlson_index_scores <- function() {
  unserialize(serialize(..mdcr_internal_charlson_index_scores.., connection = NULL))
}

################################################################################
#                                 End of File                                  #
################################################################################
