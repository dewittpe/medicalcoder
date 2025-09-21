#' Synthetic Data
#'
#' @format
#' `mdcr` is a `data.frame` with 4 columns, one for a patient id and 41 for
#' diagnostic codes and 41 possible procedure codes.  Each row is for one
#' patient id.
#'
#' * patid: patient identifier, integer values
#' * icdv: ICD version; integer values, 9 or 10
#' * dx: indicator column for ICD diagnostic (1) or procedure (0) codes
#' * code: ICD code; character values
#'
#' @family datasets
#'
"mdcr"

#' Synthetic Longitudinal Data
#'
#' @format
#' `mdcr_longitudinal` is a `data.frame` with four columns.  The codes are
#' expected to be treated as diagnostic codes but there are a few ICD-9 codes
#' which could match to procedure codes as well.
#'
#' * patid: patient identifier, integer values
#' * date: date the diagnostic code was recorded
#' * icdv: ICD version 9 or 10, integer valued
#' * code: ICD codes; character values
#"
#' @family datasets
#'
"mdcr_longitudinal"
