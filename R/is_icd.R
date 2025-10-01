#' Is ICD
#'
#' Answer the question "is the character string x a valid ICD code?"
#' ICD codes should be character vectors. `is_icd` will assess for both
#' "full codes" (decimal point present when appropriate) and "compact codes"
#' (decimal point omitted).
#'
#' @template details-header-and-assignable-codes
#' @template details-fiscal-and-calendar-years
#'
#' @param x Character vector of ICD codes (full or compact form).
#' @param headerok Logical scalar. If `FALSE` (default), only assignable
#'   codes are considered valid; if `TRUE`, header codes are also accepted.
#' @param ever.assignable Logical scalar. If `TRUE` then ignore `year`
#'   and return `TRUE` if the `x` was ever an assignable code.
#' @param warn.ambiguous Logical scalar. If `TRUE` (default), warn when a
#'   code matches more than one ICD version and/or type (e.g., both CM and PCS).
#' @template params-icd-icdv
#' @template params-icd-src
#' @template params-icd-dx
#' @template params-icd-year
#' @template params-icd-form
#'
#' @seealso 
#' * [`get_icd_codes()`] to retrieve the internal lookup table of ICD codes.
#' * [`lookup_icd_codes()`] for retrieving details on a specific set of ICD
#'   codes.
#' * [`icd_compact_to_full()`] converts a string from a compact format to the
#'   full format based on ICD version and type (diagnostic or procedure).
#'
#' @return A logical vector the same length as `x`.
#'
#' @example examples/is_icd.R
#'
#' @family ICD tools
#' @export
is_icd <- function(x, icdv = c(9L, 10L), dx = c(1L, 0L),
                   src = c("cms", "who", "cdc"),
                   year, headerok = FALSE,
                   ever.assignable = missing(year),
                   warn.ambiguous = TRUE,
                   full.codes = TRUE, compact.codes = TRUE) {

  # check arguments
  if (is.factor(x)) {
    x <- as.character(x)
  }
  stopifnot(is.character(x))
  stopifnot(all(icdv %in% c(9L, 10L)))
  stopifnot(all(dx %in% c(1L, 0L)))
  src <- match.arg(src, several.ok = TRUE)
  assert_scalar_logical(headerok)
  assert_scalar_logical(ever.assignable)
  assert_scalar_logical(warn.ambiguous)
  assert_scalar_logical(full.codes)
  assert_scalar_logical(compact.codes)
  stopifnot(full.codes | compact.codes)

  if (missing(year)) {
    year <- Inf
  } else {
    stopifnot(length(year) == 1L, is.numeric(year))
  }

  # get the known icd codes and filter to relevent codes
  codes <- get_icd_codes(with.descriptions = FALSE, with.hierarchy = FALSE)
  ux <- unique(x)

  kf <- integer(0L)
  kc <- integer(0L)
  if (full.codes) {
    kf <- which(codes[["full_code"]] %in% ux)
  }
  if (compact.codes) {
    kc <- which(codes[["code"]] %in% ux)
  }

  codes <- codes[union(kf, kc), , drop = FALSE]

  keep <-
    (codes[["icdv"]] %in% icdv) &
    (codes[["dx"]]  %in% dx) &
    (codes[["src"]] %in% src)

  if (!headerok) {
    # require assignable rows, either ever or at the given year
    keep <- keep & !is.na(codes[["assignable_start"]])
    if (!ever.assignable) {
      keep <- keep &
        codes[["assignable_start"]] <= year &
        codes[["assignable_end"]] >= year
    }
  }

  # if there are no valid look ups return FALSE and warn
  if (!any(keep)) {
    rtn <- rep_len(FALSE, length(x))
    rtn[is.na(x)] <- NA
    return(rtn)
  }

  codes <- codes[keep, , drop = FALSE]

  # If you are here, there are possible valid ICD to compare to

  if (full.codes) {
    rf <- x %in% codes[["full_code"]]
  } else {
    rf <- rep_len(FALSE, length(x))
  }
  if (compact.codes) {
    rc <- x %in% codes[["code"]]
  } else {
    rc <- rep_len(FALSE, length(x))
  }

  rtn <- rf | rc
  rtn[is.na(x)] <- NA

  # ambiguity check
  if (warn.ambiguous) {

    DF <- unique(codes[c("full_code", "code", "icdv", "dx")])

    dfcs <- DF[0, , drop = FALSE]
    dccs <- DF[0, , drop = FALSE]

    if (full.codes) {
      dfcs <- DF[DF$full_code %in% ux, c("full_code", "icdv", "dx"), drop = FALSE]
      dfcs <- dfcs[duplicated(dfcs$full_code) | duplicated(dfcs$full_code, fromLast = TRUE), ]
      dfcs[["msg"]] <- sprintf("ICD %d %s full", dfcs[["icdv"]],
                               c("pr", "dx")[1L + dfcs[["dx"]]])
    }

    if (compact.codes) {
      dccs <- DF[DF$code %in% ux, c("code", "icdv", "dx"), drop = FALSE]
      dccs <- dccs[duplicated(dccs$code) | duplicated(dccs$code, fromLast = TRUE), ]
      dccs[["msg"]] <- sprintf("ICD %d %s compact", dccs[["icdv"]],
                               c("pr", "dx")[1L + dccs[["dx"]]])
    }

    dfcs <- split(dfcs, dfcs$full_code)
    dccs <- split(dccs, dccs$code)


    for (u in ux) {
      mf <- mc <- character(0L)
      if (u %in% names(dfcs)) {
        mf <- paste(dfcs[[u]][["msg"]], collapse = "; ")
      }
      if (u %in% names(dccs)) {
        mc <- paste(dccs[[u]][["msg"]], collapse = "; ")
      }
      if (length(mf) | length(mc)) {
        msg <-
          sprintf("Input '%s' is a: %s ",
                  u, paste(c(mf, mc), collapse = "; "))
        warning(msg, call. = FALSE)
      }
    }
  }

  rtn
}

################################################################################
#                                 End of File                                  #
################################################################################
