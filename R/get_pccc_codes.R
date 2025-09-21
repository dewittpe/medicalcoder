#' Pediatric Complex Chronic Conditions ICD Codes
#'
#' Retrieve a copy of internal lookup tables for the ICD codes mapping to the
#' Pediatric Complex Chronic Conditions (PCCC) conditions and subconditions by
#' variant.
#'
#' @seealso
#' * [`get_pccc_conditions()`] for a reference of the PCCC conditions and
#'   subconditions.
#' * [`get_icd_codes()`] for the lookup table of all ICD codes.
#' * [`comorbidities()`] for applying comorbidity algorithms to a data set.
#'
#' @return a `data.frame` with the following columns
#' * `icdv`: Integer vector indicating if the code is from ICD-9 or ICD-10.
#' * `dx`: Integer vector.  1 if the code is a diagnostic, (ICD-9-CM,
#'   ICD-10-CM, WHO, CDC Mortality), or 0 if the code is procedural (ICD-9-PCS,
#'   ICD-10-PCS).
#' * `full_code`: Character vector with the ICD code and any relevant decimal point.
#' * `code`: Character vector with the compact ICD code omitting any relevant decimal point.
#' * `condition`: Character vector of the conditions.
#' * `subcondition`: Character vector of the subconditions.
#' * `transplant_flag`: Integer vector indicating if the code is associated with a transplant.
#' * `tech_dep_flag`: Integer vector indicating if the code is associated with technology dependence.
#' * `pccc_<variant>`: Integer vector indicating if the code is part of the
#'    v2.0, v2.1, v3.0, or v3.1 variant.
#'
#' @example examples/get_pccc_codes.R
#'
#' @export
get_pccc_codes <- function() {
  x <- get(x = "pccc_codes", envir = ..mdcr_data_env.., inherits = FALSE)
  unserialize(serialize(x, connection = NULL))
}

################################################################################
#                                 End of File                                  #
################################################################################
