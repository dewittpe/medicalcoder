#' Tools for working with data.frames.
#'
#' An objective of the medicalcoder package is to use only base R methods.  That
#' said, when data.tables are passed into the methods within the package there
#' are operations where the data.table set functions should be used or the
#' subsetting needs to be specific to data.tables. These internal (non-exported)
#' functions provide the needed method by data.table or data.frame.
#'
#' `mdcr_select()` deep-copies data.table subsets (via data.table::copy()) to
#' avoid aliasing when downstream code mutates; this intentionally trades some
#' performance for isolation.
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
  if (requireNamespace(package = "data.table", quietly = TRUE) && inherits(x, "data.table")) {
    # calling data.table::setDT to make sure that the object can be modified by
    # reference. Without data.table::setDT here we see an error if the table was
    # read from disk (e.g., readRDS()) or hand-constructed:
    #
    #   This data.table has either been loaded from disk (e.g. using
    #   readRDS()/load()) or constructed manually (e.g. using structure()).
    #   Please run setDT() or setalloccol() on it first (to pre-allocate space
    #   for new columns) before assigning by reference to it.
    #
    # data.tables read via readRDS()/load() or hand‑constructed can have an
    # invalid .internal.selfref, so the first by‑reference op (set()/:= ) errors.
    # data.table::setDT() reinitializes the selfref so data.table::set() can work
    # by reference. This wrapper keeps by-ref semantics consistent across backends.

    getExportedValue(name = "setDT", ns = "data.table")(x = x)
    getExportedValue(name = "set", ns = "data.table")(x = x, i = i, j = j, value = value)
  } else if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    mutate <- getExportedValue(name = "mutate", ns = "dplyr")
    if (is.null(i)) {
      newcol <- if (nrow(x) == 0L) value[0] else value
    } else {
      newcol <- x[[j]]
      if (is.null(newcol)) {
        newcol <- rep(NA, length = nrow(x))
        storage.mode(newcol) <- typeof(value)
      }
      newcol[i] <- value
    }
    x <- do.call(mutate, c(list(.data = x), stats::setNames(list(newcol), j)))
  } else {
    if (is.null(i)) {
      x[[j]] <- value
    } else {
      if (is.null(x[[j]])) {
        x[[j]] <- rep(NA, nrow(x))
        storage.mode(x[[j]]) <- typeof(value)
      }
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

  #  # By making sure that cols is a character vector the `with = FALSE` is not
  #  # needed for data.tables which will allow for a simple call.  This is
  #  # important because `[.data.frame` will error if `with = FALSE` is passed.
  #  # `[.data.table` does not need `with = FALSE` if `j` is a character vector.
  #  stopifnot(inherits(cols, "character"))
  #  #x[, cols, drop = FALSE, with = FALSE]
  #  x[, cols, drop = FALSE]

  if (requireNamespace(package = "data.table", quietly = TRUE) && inherits(x, "data.table")) {
    # note: the data.table::copy() is needed here because x[, cols] returns a
    # shallow copy of the columns. The use of mdcr_select in the package
    # implicitly assumes deep copies. Downstream setorder()/setnames() mutate in
    # place, so copying here preserves the original. This pays a copy cost to
    # protect callers who expect an isolated subset.
    return(getExportedValue(name = "copy", ns = "data.table")(x[, cols, drop = FALSE, with = FALSE]))
  } else if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    select <- getExportedValue(name = "select", ns = "dplyr")
    all_of <- getExportedValue(name = "all_of", ns = "dplyr")
    return(select(x, all_of(cols)))
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
    # match base/data.table semantics: logical i is converted to positions
    rows <- if (is.logical(i)) which(i) else i

    if (missing(cols)) {
      if (requireNamespace(package = "data.table", quietly = TRUE) && inherits(x, "data.table")) {
        return(x[rows, , drop = FALSE, with = FALSE])
      } else if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
        slice <- getExportedValue(name = "slice", ns = "dplyr")
        return(slice(x, rows))
      } else {
        return(x[rows, , drop = FALSE])
      }
    } else {
      if (requireNamespace(package = "data.table", quietly = TRUE) && inherits(x, "data.table")) {
        return(x[rows, cols, drop = FALSE, with = FALSE])
      } else if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
        slice  <- getExportedValue(name = "slice",  ns = "dplyr")
        select <- getExportedValue(name = "select", ns = "dplyr")
        all_of <- getExportedValue(name = "all_of", ns = "dplyr")
        x <- slice(x, rows)
        return(select(x, all_of(cols)))
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
  if (requireNamespace(package = "data.table", quietly = TRUE) && inherits(x, "data.table")) {
    getExportedValue(name = "setorderv", ns = "data.table")(x, by)
  } else if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    arrange <- getExportedValue(name = "arrange", ns = "dplyr")
    x <- do.call(arrange, c(list(.data = x), lapply(by, as.name)))
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
  stopifnot(is.character(old), is.character(new))
  stopifnot(length(old) == length(new))
  if (requireNamespace(package = "data.table", quietly = TRUE) && inherits(x, "data.table")) {
    getExportedValue(name = "setnames", ns = "data.table")(x, old, new, ...)
  } else if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    rename <- getExportedValue(name = "rename", ns = "dplyr")
    args <- c(list(.data = x), stats::setNames(lapply(old, as.name), new))
    x <- do.call(rename, args)
  } else {
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
  if (requireNamespace(package = "data.table", quietly = TRUE) && inherits(x, "data.table")) {
    # Flag this frame as data.table-aware so duplicated.data.table uses its
    # optimized path instead of falling back to duplicated.data.frame.
    .datatable.aware <- TRUE
    rtn <- utils::getFromNamespace(x = 'duplicated.data.table', ns = "data.table")(x, by = by, ...)
  } else {  # this is for base R data.frames and tidyverse tbl_df
    rtn <- duplicated(x[, by, drop = FALSE], ...)
  }
  rtn
}

#'
#' @rdname mdcr_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
mdcr_unique <- function(x, ...) {
  stopifnot(is.data.frame(x))
  if (requireNamespace(package = "data.table", quietly = TRUE) && inherits(x, "data.table")) {
    # Flag this frame as data.table-aware so unique.data.table uses its
    # optimized path instead of falling back to unique.data.frame.
    .datatable.aware <- TRUE
    rtn <- utils::getFromNamespace(x = 'unique.data.table', ns = "data.table")(x, ...)
  } else if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    rtn <- getExportedValue(name = "distinct", ns = "dplyr")(.data = x, ...)
  } else {
    rtn <- unique(x, ...)
  }
  rtn
}

#'
#' @rdname mdcr_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
mdcr_left_join <- function(x, y, ...) {
  stopifnot(is.data.frame(x), is.data.frame(y))

  if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    lj <- getExportedValue(name = "left_join", ns = "dplyr")
    dots <- list(...)
    if (!is.null(dots$by.x) & !is.null(dots$by.y)) {
      by <- stats::setNames(dots$by.y, dots$by.x)
      dots$by.x <- NULL
      dots$by.y <- NULL
    } else if (!is.null(dots$by)) {
      by <- dots$by
      dots$by   <- NULL
    } else {
      by <- NULL
    }
    if (!is.null(dots$suffixes)) {
      suffix <- dots$suffixes
      dots$suffixes <- NULL
    } else {
      suffix <- c(".x", ".y")
    }
    # normalize to dplyr's by/suffix arguments to mirror base/data.table defaults
    rtn <- do.call(what = lj, args = c(list(x = x, y = y, by = by, suffix = suffix), dots))
  } else {
    # if x is a data.table and the data.table namespace is available then the
    # data.table:::merge.data.table method will be called and a specific block
    # for data.table is not needed here
    rtn <- merge(x = x, y = y, all.x = TRUE, all.y = FALSE, sort = FALSE, allow.cartesian = TRUE, ...)
  }
  rtn
}

#'
#' @rdname mdcr_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
mdcr_full_outer_join <- function(x, y, ...) {
  stopifnot(is.data.frame(x), is.data.frame(y))

  if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    fj <- getExportedValue(name = "full_join", ns = "dplyr")
    dots <- list(...)
    if (!is.null(dots$by.x) & !is.null(dots$by.y)) {
      by <- stats::setNames(dots$by.y, dots$by.x)
      dots$by.x <- NULL
      dots$by.y <- NULL
    } else if (!is.null(dots$by)) {
      by <- dots$by
      dots$by   <- NULL
    } else {
      by <- NULL
    }
    if (!is.null(dots$suffixes)) {
      suffix <- dots$suffixes
      dots$suffixes <- NULL
    } else {
      suffix <- c(".x", ".y")
    }
    # normalize to dplyr's by/suffix arguments to mirror base/data.table defaults
    rtn <- do.call(what = fj, args = c(list(x = x, y = y, by = by, suffix = suffix), dots))
  } else {
    # if x is a data.table and the data.table namespace is available then the
    # data.table:::merge.data.table method will be called and a specific block
    # for data.table is not needed here
    rtn <- merge(x = x, y = y, all.x = TRUE, all.y = TRUE, sort = FALSE, allow.cartesian = TRUE, ...)
  }
  rtn
}

#'
#' @rdname mdcr_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
mdcr_inner_join <- function(x, y, ...) {
  stopifnot(is.data.frame(x), is.data.frame(y))

  if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    ij <- getExportedValue(name = "inner_join", ns = "dplyr")
    dots <- list(...)
    if (!is.null(dots$by.x) & !is.null(dots$by.y)) {
      by <- stats::setNames(dots$by.y, dots$by.x)
      dots$by.x <- NULL
      dots$by.y <- NULL
    } else if (!is.null(dots$by)) {
      by <- dots$by
      dots$by   <- NULL
    } else {
      by <- NULL
    }
    if (!is.null(dots$suffixes)) {
      suffix <- dots$suffixes
      dots$suffixes <- NULL
    } else {
      suffix <- c(".x", ".y")
    }
    # normalize to dplyr's by/suffix arguments to mirror base/data.table defaults
    rtn <- do.call(what = ij, args = c(list(x = x, y = y, by = by, suffix = suffix), dots))
  } else {
    # if x is a data.table and the data.table namespace is available then the
    # data.table:::merge.data.table method will be called and a specific block
    # for data.table is not needed here
    rtn <- merge(x = x, y = y, all.x = FALSE, all.y = FALSE, sort = FALSE, ...)
  }
  rtn
}

#'
#' @rdname mdcr_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
mdcr_cbind <- function(x, ...) {
  stopifnot(is.data.frame(x))
  if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    cb <- getExportedValue(name = "bind_cols", ns = "dplyr")
    rtn <- cb(x, ...)
  } else {
    # if x is a data.table and the data.table namespace is available then the
    # data.table:::cbind.data.table method will be called and a specific block
    # for data.table is not needed here
    rtn <- cbind(x, ...)
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
