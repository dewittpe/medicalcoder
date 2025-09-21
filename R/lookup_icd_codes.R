#' Lookup ICD Codes
#'
#' Functions for working with ICD codes.
#'
#' ICD codes should be character vectors. These tools work with either
#' "full codes" (decimal point present when appropriate) or "compact codes"
#' (decimal point omitted).
#'
#' @template details-header-and-assignable-codes
#' @template details-fiscal-and-calendar-years
#'
#' @param x Character vector of ICD codes (full or compact form).
#' @param regex Logical scalar. If `TRUE`, treat `x` as regular
#'   expressions; if `FALSE`, use exact matching.
#' @template params-icd-form
#'
#' @param ... Passed to [base::grep()] when `regex = TRUE`
#'
#' @seealso
#' * [`get_icd_codes()`] to retrieve the internal lookup table of ICD codes.
#' * [`is_icd()`] to test if a string is a known ICD code.
#' * [`icd_compact_to_full()`] converts a string from a compact format to the
#'   full format based on ICD version and type (diagnostic or procedure).
#'
#' @return A `data.frame` with one or more rows per input, including columns
#' * `match_type`: did the input match a full or compact code
#' * `icdv`: icd version (9 or 10)
#' * `dx`: diagnostic code (1) or procedure code (0)
#' * `full_code`: the full code string
#' * `code`: the compact codes string
#' * `src`: the source - CMS, CDC, or WHO.
#' * year ranges (`known_*`, `assignable_*`).
#'
#' @family ICD tools
#' @export
lookup_icd_codes <- function(x, regex = FALSE, full.codes = TRUE, compact.codes = TRUE, ...) {
  stopifnot(inherits(x, "character"))
  stopifnot(isTRUEorFALSE(regex))
  stopifnot(isTRUEorFALSE(full.codes))
  stopifnot(isTRUEorFALSE(compact.codes))
  stopifnot(isTRUE(full.codes | compact.codes))

  ICDCODES <- get_icd_codes(with.descriptions = FALSE, with.hierarchy = FALSE)

  if (regex) {
    if(full.codes) {
      fcmatches <- lapply(x, grep, x = ICDCODES$full_code, value = TRUE, ...)
      fcmatches <- data.frame(input_seq   = rep(seq_along(x), times = sapply(fcmatches, length)),
                              input_regex = rep(x, times = sapply(fcmatches, length)),
                              input_code  = do.call(c, fcmatches))
    }
    if (compact.codes) {
      ccmatches <- lapply(x, grep, x = ICDCODES$code, value = TRUE, ...)
      ccmatches <- data.frame(input_seq   = rep(seq_along(x), times = sapply(ccmatches, length)),
                              input_regex = rep(x, times = sapply(ccmatches, length)),
                              input_code  = do.call(c, ccmatches))
    }
    if (full.codes & compact.codes) {
      input <- rbind(fcmatches, ccmatches)
    } else if (full.codes & !compact.codes) {
      input <- fcmatches
    } else if (!full.codes & compact.codes) {
      input <- ccmatches
    }
  } else {
    input <- data.frame(input_seq = seq_along(x), input_code = x)
  }

  if (full.codes) {
    on_full_code <-
      merge(x = input,
            y = cbind(ICDCODES, "matched_full_code" = ICDCODES[["full_code"]], zzz = 1L),
            by.x = "input_code",
            by.y = "full_code")
  }

  if (compact.codes) {
    on_compact_code <-
      merge(x = input,
            y = cbind(ICDCODES, "matched_code" = ICDCODES[["code"]], zzz = 1L),
            by.x = "input_code",
            by.y = "code")
  }

  if (full.codes & compact.codes) {
    # Prefer full-code matches when both forms are requested so the
    # same record does not appear twice; drop compact-code rows whose
    # join key already matched on the full-code pass.
    keys <- c("input_seq", "input_code", "icdv", "dx", "src")
    ckey <- do.call(paste, c(on_compact_code[keys], sep = "\r"))
    fkey <- do.call(paste, c(on_full_code[keys], sep = "\r"))
    keep <- is.na(match(ckey, unique(fkey)))
    on_compact_code <- on_compact_code[keep, , drop = FALSE]
  }

  if (regex) {
    col_order <- c("input_regex")
  } else {
    col_order <- c("input_code")
  }
  col_order <- c(col_order, "input_seq", "match_type", "icdv", "dx", "full_code", "code", "src", "known_start", "known_end", "assignable_start", "assignable_end")

  ofc <- exists("on_full_code") && nrow(on_full_code)
  occ <- exists("on_compact_code") && nrow(on_compact_code)

  if (ofc) {
    on_full_code[["match_type"]] <- "full_code"
    names(on_full_code) <- sub("matched_", "", names(on_full_code))
    on_full_code <- mdcr_select(on_full_code, cols = col_order)
  }

  if (occ) {
    on_compact_code[["match_type"]] <- "compact_code"
    names(on_compact_code) <- sub("matched_", "", names(on_compact_code))
    on_compact_code <- mdcr_select(on_compact_code, cols = col_order)
  }

  if (ofc & occ) {
    matches <- rbind(on_full_code, on_compact_code)
  } else if (ofc & !occ) {
    matches <- on_full_code
  } else if (!ofc & occ) {
    matches <- on_compact_code
  } else {
    matches <- as.data.frame(matrix(NA_character_, nrow = 1L, ncol = length(col_order), dimnames = list("", col_order)))
  }

  rtn <- merge(x = input, y = matches, all.x = TRUE, by = col_order[1:2])

  if (regex) {
    rtn[["input_code"]] <- NULL
  }

  rtn <- rtn[order(rtn$input_seq), , drop = FALSE]
  rtn[["input_seq"]] <- NULL

  unique(rtn)
}

################################################################################
#                                 End of File                                  #
################################################################################
