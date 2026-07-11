#' Pediatric Complex Chronic Condition and Subconditions
#'
#' Retrieve a copy of internal lookup tables for the syntactically valid and human
#' readable labels of the Pediatric Complex Chronic Conditions (PCCC) conditions
#' and subconditions.
#'
#' @seealso
#' * [`get_pccc_codes()`] for the lookup table of ICD codes used for the PCCC.
#' * [`comorbidities()`] for applying comorbidity algorithms to a dataset.
#'
#' @return A `data.frame` with the following character columns:
#' * `condition`: Syntactically valid name for the condition
#' * `subcondition`: Syntactically valid name for the subcondition
#' * `condition_label`: Human-readable label for the condition
#' * `subcondition_label`: Human-readable label for the
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
