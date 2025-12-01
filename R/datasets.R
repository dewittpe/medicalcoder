#' Synthetic Data
#'
#' @format
#' `mdcr` is a `data.frame` with 4 columns, Each row is for one ICD id.
#'
#' * `patid`: patient identifier, integer values
#' * `icdv`: ICD version; integer values, 9 or 10
#' * `dx`: indicator column for ICD diagnostic (1) or procedure (0) codes
#' * `code`: ICD code; character values
#'
#' @family datasets
#'
"mdcr"

#' Synthetic Longitudinal Data
#'
#' @format
#' `mdcr_longitudinal` is a `data.frame` with 4 columns.  The codes are
#' expected to be treated as diagnostic codes. Warning: there are a few ICD-9
#' codes which could match to procedure codes.
#'
#' * `patid`: patient identifier, integer values
#' * `date`: date the diagnostic code was recorded
#' * `icdv`: ICD version 9 or 10, integer valued
#' * `code`: ICD codes; character values
#'
#' @family datasets
#'
"mdcr_longitudinal"
