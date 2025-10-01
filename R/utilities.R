#' Tools for working with data.frames.
#'
#' An objective of the medicalcoder package is to use only base R methods.  That
#' said, when data.tables are passed into the methods within the package there
#' are operations where the data.table set functions should be used or the
#' subsetting needs to be specific to data.tables. These internal (non-exported)
#' functions provide the needed method by data.table or data.frame.
#'
#' @param x a data.frame or data.table
#' @param i Optional. Indicates the rows on which the values must be updated. If
#'   not `NULL`, implies all rows.
#' @param j Column name (character).  For `mdcr_set` this is the column assigned
#'   `value`, update values if it exits. If `x[[j]]` does note exist it will be
#'   created.
#' @param value replacement values
#'
#' @family data.frame tools
#' @noRd
#' @name mdcr_data_frame_tools
NULL

#' @rdname mdcr_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
mdcr_set <- function(x, i = NULL, j, value) {
  stopifnot(is.data.frame(x))
  if (requireNamespace("data.table", quietly = TRUE) && inherits(x, "data.table")) {
    getExportedValue(name = "setDT", ns = "data.table")(x = x)
    getExportedValue(name = "set", ns = "data.table")(x = x, i = i, j = j, value = value)
  } else {
    if (is.null(i)) {
      x[[j]] <- value
    } else {
      x[[j]][i] <- value
    }
  }
  x
}

#'
#' @rdname mdcr_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
mdcr_select <- function(x, cols) {
  stopifnot(is.data.frame(x))
  if (missing(cols)) {
    return(x)
  }

  if (requireNamespace("data.table", quietly = TRUE) && inherits(x, "data.table")) {
    return(getExportedValue(name = "copy", ns = "data.table")(x[, cols, drop = FALSE, with = FALSE]))
  } else {
    return(x[, cols, drop = FALSE])
  }
}

#'
#' @rdname mdcr_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
mdcr_subset <- function(x, i, cols) {
  stopifnot(is.data.frame(x))

  if (missing(i)) {
    if (missing(cols)) {
      return(x)
    } else {
      return(mdcr_select(x, cols = cols))
    }
  } else {
    rows <- if (is.logical(i)) which(i) else i

    if (missing(cols)) {
      if (requireNamespace("data.table", quietly = TRUE) && inherits(x, "data.table")) {
        return(x[rows, , drop = FALSE, with = FALSE])
      } else {
        return(x[rows, , drop = FALSE])
      }
    } else {
      if (requireNamespace("data.table", quietly = TRUE) && inherits(x, "data.table")) {
        return(x[rows, cols, drop = FALSE, with = FALSE])
      } else {
        cols_idx <- match(cols, names(x))
        return(x[rows, cols_idx, drop = FALSE])
      }
    }
  }
}

#'
#' @rdname mdcr_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
mdcr_setorder <- function(x, by) {
  stopifnot(is.data.frame(x))
  if (requireNamespace("data.table", quietly = TRUE) && inherits(x, "data.table")) {
    getExportedValue(name = "setorderv", ns = "data.table")(x, by)
  } else {
    x <- x[do.call(order, x[by]), , drop = FALSE]
  }
  x
}

#'
#' @rdname mdcr_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
mdcr_setnames <- function(x, old, new, ...) {
  stopifnot(is.data.frame(x))
  if (requireNamespace("data.table", quietly = TRUE) && inherits(x, "data.table")) {
    getExportedValue(name = "setnames", ns = "data.table")(x, old, new, ...)
  } else {
    stopifnot(is.character(old), is.character(new))
    stopifnot(length(old) == length(new))
    for (i in seq_len(length(old))) {
      names(x)[names(x) == old[i]] <- new[i]
    }
  }
  x
}

#'
#' @rdname mdcr_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
mdcr_duplicated <- function(x, by = seq_along(x), ...) {
  stopifnot(is.data.frame(x))
  if (requireNamespace("data.table", quietly = TRUE) && inherits(x, "data.table")) {
    rtn <- duplicated(x, by = by, ...)
  } else {
    rtn <- duplicated(x[, by, drop = FALSE], ...)
  }
  rtn
}


################################################################################

#' Assert
#'
#' A set of functions used to check function arguments.
#'
#' @details
#'
#' ## assert_scalar_logical
#' tests if the input is a length-1, non-missing logical.
#'
#' **Developer example (not executed):**
#' ```
#' medicalcoder:::assert_scalar_logical(TRUE)          # pass, return TRUE
#' medicalcoder:::assert_scalar_logical(FALSE)         # pass, return TRUE
#' medicalcoder:::assert_scalar_logical(NA)            # fail, throw error
#' medicalcoder:::assert_scalar_logical(1L)            # fail, throw error
#' medicalcoder:::assert_scalar_logical(c(TRUE, TRUE)) # fail, throw error
#' ```
#'
#' @param x a R object
#'
#' @return `TRUE`, invisibly if the assertion is TRUE, otherwise an error is
#' thrown.
#'
#' @noRd
#' @keywords internal
assert_scalar_logical <- function(x) {
  z <- is.logical(x) && length(x) == 1L && !is.na(x)
  if (!z) {
    stop(sprintf("The value passed to '%s' is expected to be a length-1 non-missing logical.", deparse(substitute(x))), call. = FALSE)
  }
  invisible(z)
}

################################################################################
#                                 End of File                                  #
################################################################################
