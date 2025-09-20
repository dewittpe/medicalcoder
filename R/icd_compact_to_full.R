#' Convert ICD Compact Codes to Full Codes
#'
#' Take an assumed ICD compact code string and convert to a full code based on
#' the ICD version (9 or 10) and type (diagnostic or procedure).  This method
#' only formats strings and does not validate the code(s).
#'
#' @param x Character vector
#' @template params-icd-icdv
#' @template params-icd-dx
#'
#' @seealso
#' * [`get_icd_codes()`] to retrieve the internal lookup table of ICD codes.
#' * [`lookup_icd_codes()`] for retrieving details on a specific set of ICD
#'   codes.
#' * [`is_icd()`] to test if a string is a known ICD code.
#'
#' @return A character vector the same length as `x`.
#'
#' @family ICD tools
#' @export
icd_compact_to_full <- function(x, icdv, dx) {
  # given a compact ICD code, a code with no decimal point, and knowing if the
  # code is ICD-9 or ICD-10, and diagnostic or procedure, return the full code
  # with the decimal point
  stopifnot(inherits(x, "character"))

  # standardize icdv/dx lengths
  # icdv and dx need to be length 1 or the same length as x
  stopifnot(length(icdv) == 1L || length(icdv) == length(x))
  stopifnot(length(dx)   == 1L || length(dx)   == length(x))
  if (length(icdv) == 1L) icdv <- rep_len(icdv, length(x))
  if (length(dx)   == 1L) dx   <- rep_len(dx,   length(x))

  # leave entries with an existing decimal untouched
  has_dot <- grepl("\\.", x, useBytes = TRUE)
  nc <- nchar(x, type = "bytes", allowNA = FALSE, keepNA = FALSE)

  # patterns apply only to compact forms (no dot)
  iscompact <- !has_dot & !is.na(x)

  # There are four sets of codes which could have a decimal
  #   * ICD-9-CM non-E codes
  #   * ICD-9-CM E codes
  #   * ICD-9 Procedure codes
  #   * ICD-10-CM
  #     - NOTE: \\D\\d{2} will not match all the codes.  Z3A.29 is a valid code
  #       for 29 weeks gestation of pregnancy. Just use nchar > 3
  #
  # ICD-10 Procedure codes do not have a decimal

  icd9cm_nonE <- which(iscompact & (icdv ==  9 & dx == 1) & grepl("^(\\d{4,5}|V\\d{3,4})$", x))
  icd9cm_E    <- which(iscompact & (icdv ==  9 & dx == 1) & grepl("^(E\\d{4})$", x))
  icd9pr      <- which(iscompact & (icdv ==  9 & dx == 0) & grepl("^\\d{3,4}$", x))
  icd10cm     <- which(iscompact & (icdv == 10 & dx == 1) & nc > 3L)

  if (length(icd9cm_nonE) > 0L) {
    x[icd9cm_nonE] <-
      paste0(substr(x[icd9cm_nonE], start = 1, stop = 3), ".",
             substr(x[icd9cm_nonE], start = 4, stop = nchar(x[icd9cm_nonE])))
  }

  if (length(icd9cm_E) > 0L) {
    x[icd9cm_E] <-
      paste0(substr(x[icd9cm_E], start = 1, stop = 4), ".",
             substr(x[icd9cm_E], start = 5, stop = nchar(x[icd9cm_E])))
  }

  if (length(icd9pr) > 0L) {
    x[icd9pr] <-
      paste0(substr(x[icd9pr], start = 1, stop = 2), ".",
             substr(x[icd9pr], start = 3, stop = 4))
  }

  if (length(icd10cm) > 0L) {
    x[icd10cm] <-
      paste0(substr(x[icd10cm], start = 1, stop = 3), ".",
             substr(x[icd10cm], start = 4, stop = nchar(x[icd10cm])))
  }

  # return the modified x vector as the full codes
  x
}

################################################################################
#                                 End of File                                  #
################################################################################
