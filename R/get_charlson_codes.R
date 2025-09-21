#' Get Charlson Codes
#'
#' Retrieve a copy of internal lookup tables for the ICD codes 
#' used in assessing Charlson comorbidities.
#'
#' @seealso
#' * [`get_charlson_index_scores()`] for a lookup table of the by comorbidity index scores.
#' * [`get_icd_codes()`] for the lookup table of all ICD codes.
#' * [`get_pccc_codes()`] for the lookup table of ICD codes used for the PCCC.
#' * [`get_elixhauser_codes()`] for the lookup table of ICD codes used for the Elixhauser comorbidities.
#' * [`comorbidities()`] for applying comorbidity algorithms to a data set.
#'
#' @return
#'
#' A `data.frame` with the following columns:
#' 
#' * `icdv`: Integer vector indicating if the code is from ICD-9 or ICD-10
#' * `dx`: Integer vector.  1 if the code is a diagnostic, (ICD-9-CM, ICD-10-CM, WHO, CDC Mortality), or 0 if the code is procedural (ICD-9-PCS, ICD-10-PCS)
#' * `full_code`: Character vector with the ICD code and any relevant decimal point
#' * `code`: Character vector with the compact ICD code
#' * `condition`: Character vector of the conditions
#' * `charson_\<variant\>`: Integer vector indicating if the code is part of the \<variant\> of the Charlson comorbidities.
#'
#' @examples
#' head(get_charlson_codes())
#' str(get_charlson_codes())
#'
#' @export
get_charlson_codes <- function() {
  x <- get("charlson_codes", envir = ..mdcr_data_env.., inherits = FALSE)
  unserialize(serialize(x, connection = NULL))
}
