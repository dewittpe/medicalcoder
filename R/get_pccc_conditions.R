#' Pediatric Complex Chronic Condition and Subconditions
#'
#' Retrieve a copy of internal lookup tables for the syntax valid and human
#' readable labels of the Pediatric Complex Chronic Conditions (PCCC) conditions
#' and subconditions.
#'
#' @seealso
#' * [`get_pccc_codes()`] for the lookup table of ICD codes used for the PCCC.
#' * [comorbidities()] for applying comorbidity algorithms to a data set.
#'
#' @return a `data.frame` with the following columns
#' * `condition`: (character) syntax valid name for the condition
#' * `subcondition`: (character) syntax valid name for the subcondition
#' * `condition_label`: (character) human readable label for the condition
#' * `subcondition_label`: (character) human readable label for the
#'   subcondition
#'
#' @examples
#' get_pccc_conditions()
#'
#' @export
get_pccc_conditions <- function() {
  unserialize(serialize(..mdcr_internal_pccc_conditions.., connection = NULL))
}

################################################################################
#                                 End of File                                  #
################################################################################
