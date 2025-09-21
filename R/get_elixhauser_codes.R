#' Get Elixhauser Codes
#'
#' Retrieve  copy of internal lookup tables for the ICD codes used in assessing
#' Elixhauser comorbidities.
#'
#' @seealso
#' * [`get_elixhauser_index_scores()`] for the lookup table of the condition by
#'   condition scores for mortality and readmission indices.
#' * [`get_elixhauser_poa()`] for the lookup table of the conditions which do an
#'   do not require associated ICD codes to be present-on-admission to flag the
#'   comorbidity.
#' * [`get_icd_codes()`] for the lookup table of all ICD codes.
#' * [`get_pccc_codes()`] for the lookup table of ICD codes used for the PCCC.
#' * [`get_charlson_codes()`] for the lookup table of ICD codes used for the Charlson comorbidities.
#' * [`comorbidities()`] for applying comorbidity algorithms to a data set.
#' 
#' @return A `data.frame` with the following columns:
#' * `icdv`: Integer vector indicating if the code is from ICD-9 or ICD-10
#' * `dx`: Integer vector.  1 if the code is a diagnostic, (ICD-9-CM, ICD-10-CM, WHO, CDC Mortality), or 0 if the code is procedural (ICD-9-PCS, ICD-10-PCS)
#' * `full_code`: Character vector with the ICD code and any relevant decimal point
#' * `code`: Character vector with the compact ICD code omitting any relevant decimal point
#' * `condition`: Character vector of the conditions
#' * `elixhauser_<variant>`: Integer vector indicating if the code is part of the `<variant>` of the Elixhauser comorbidities.
#'
#' @examples
#' head(get_elixhauser_codes())
#' str(get_elixhauser_codes())
#'
#' @export
get_elixhauser_codes <- function() {
  x <- get("elixhauser_codes", envir = ..mdcr_data_env.., inherits = FALSE)
  unserialize(serialize(x, connection = NULL))
}

################################################################################
#                                 End of File                                  #
################################################################################
