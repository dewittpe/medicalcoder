################################################################################
#' Check and Set
#'
#' A collection of non-exported functions used to check and create needed
#' variables for applying the comorbidity algorithms.  These functions are
#' expected to be called from within [comorbidities()] and nowhere else.
#'
#' @inheritParams comorbidities
#' @param data_names names of the variables within the data set passed to
#' [comorbidities()]
#' @param envir the calling environment and the environment where the data will
#' be updated.
#'
#' @return a boolean if the needed variable was created.
#'
#' @family check_and_set
#' @noRd
#' @name check_and_set
NULL

#' @rdname check_and_set
#' @family check_and_set
#' @noRd
#' @keywords internal
check_and_set_id_vars <- function(data_names, id.vars, envir) {
  rtn <- is.null(id.vars) # return if the id.vars was created
  if (is.null(id.vars)) {
    id.vars <- "..medicalcoder_id.."
    while(id.vars %in% data_names) {
      id.vars <- paste0(".", id.vars, ".")
    }
    # Use parse()/eval() to avoid adding a data.table dependency
    # while still mutating the caller's data in place, mirroring
    # `:=` style behaviour with base R only.
    e <- parse(text = paste0("data <- cbind(data, ", id.vars, " = 1L)"))
    eval(e, envir = envir)
    assign(x = "id.vars", value = id.vars, envir = envir)
  } else {
    stopifnot(all(id.vars %in% data_names))
  }
  rtn
}

#' @rdname check_and_set
#' @family check_and_set
#' @noRd
#' @keywords internal
check_and_set_icdv_var <- function(data_names, icdv.var, icdv, envir) {
  rtn <- is.null(icdv.var)
  if (is.null(icdv.var)) {
    if (!is.null(icdv)) {
      stopifnot(inherits(icdv, "numeric") | inherits(icdv, "integer"))
      stopifnot(length(icdv) == 1L)
      icdv <- as.integer(icdv)
      stopifnot(icdv %in% c(9L, 10L))
      icdv.var <- "..medicalcoder_icdv.."
      while(icdv.var %in% data_names) {
        icdv.var <- paste0(".", icdv.var, ".")
      }
      # Use parse()/eval() to avoid adding a data.table dependency
      # while still mutating the caller's data in place, mirroring
      # `:=` style behaviour with base R only.
      e <- parse(text = paste0("data <- cbind(data, ", icdv.var, " = ", icdv, ")"))
      eval(e, envir = envir)
      assign(x = "icdv.var", value = icdv.var, envir = envir)
    } else {
      # do nothing; icdv.var and  icdv are both NULL
    }
  } else {
    if (!is.null(icdv)) {
      warning("'icdv.var' and 'icdv' were both specified; ignoring 'icdv'")
    }
    stopifnot(length(icdv.var) == 1L)
    stopifnot(icdv.var %in% data_names)
  }
  rtn
}

#' @rdname check_and_set
#' @family check_and_set
#' @noRd
#' @keywords internal
check_and_set_dx_var <- function(data_names, dx.var, dx, envir) {
  rtn <- is.null(dx.var)
  if (is.null(dx.var)) {
    if (!is.null(dx)) {
      stopifnot(inherits(dx, "numeric") | inherits(dx, "integer"))
      stopifnot(length(dx) == 1L)
      dx <- as.integer(dx)
      stopifnot(dx %in% c(0L, 1L))
      dx.var <- "..medicalcoder_dx.."
      while(dx.var %in% data_names) {
        dx.var <- paste0(".", dx.var, ".")
      }
      # Use parse()/eval() to avoid adding a data.table dependency
      # while still mutating the caller's data in place, mirroring
      # `:=` style behaviour with base R only.
      e <- parse(text = paste0("data <- cbind(data, ", dx.var, " = ", dx, ")"))
      eval(e, envir = envir)
      assign(x = "dx.var", value = dx.var, envir = envir)
    } else {
      # do nothing, both dx.var and dx are NULL
    }
  } else {
    if (!is.null(dx)) {
      warning("'dx.var' and 'dx' were both specified; ignoring 'dx'")
    }
    stopifnot(length(dx.var) == 1L)
    stopifnot(dx.var %in% data_names)
  }
  rtn
}

#' @rdname check_and_set
#' @family check_and_set
#' @noRd
#' @keywords internal
check_and_set_poa_var <- function(data_names, poa.var, poa, flag.method, method, envir) {
  rtn <- is.null(poa.var)
  if (is.null(poa.var) & is.null(poa)) {
    # set defaults for poa if not specified
    if (flag.method == "current") {
      poa <- 1L
      warning("poa.var and poa are both NULL.  With flag.method = 'current' poa is set to 1")
    } else if (flag.method == "cumulative") {
      poa <- 0L
      warning("poa.var and poa are both NULL.  With flag.method = 'cumulative' poa is set to 0")
    } else {
      stop(sprintf("Unknown flag.method: %s. - something as gone very wrong, should not be able to get here.", flag.method))
    }
  }

  if (is.null(poa.var)) {
    stopifnot(inherits(poa, "numeric") | inherits(poa, "integer"))
    stopifnot(length(poa) == 1L)
    poa <- as.integer(poa)
    stopifnot(poa %in% c(0L, 1L))
    poa.var <- "..medicalcoder_poa.."
    while(poa.var %in% data_names) {
      poa.var <- paste0(".", poa.var, ".")
    }
    # Use parse()/eval() to avoid adding a data.table dependency
    # while still mutating the caller's data in place, mirroring
    # `:=` style behaviour with base R only.
    e <- parse(text = paste0("data <- cbind(data, ", poa.var, " = ", poa, ")"))
    eval(e, envir = envir)
    assign(x = "poa.var", value = poa.var, envir = envir)
  } else {
    if (!is.null(poa)) {
      warning("'poa.var' and 'poa' were both specified; ignoring 'poa'")
    }
    stopifnot(length(poa.var) == 1L)
    stopifnot(poa.var %in% data_names)
  }
  rtn
}

#' @rdname check_and_set
#' @family check_and_set
#' @noRd
#' @keywords internal
check_and_set_primarydx_var <- function(data_names, primarydx.var, primarydx, method, envir) {
  rtn <- is.null(primarydx.var)
  # primary dx flag is only needed for elixhauser, so if it is not specified or
  # if the method is not elixhauser then create a dummy and warn, if needed,
  # that all dx are considered secondary.
  if (is.null(primarydx.var)) {
    if (!is.null(primarydx)) {
      stopifnot(inherits(primarydx, "numeric") | inherits(primarydx, "integer"))
      stopifnot(length(primarydx) == 1L)
      primarydx <- as.integer(primarydx)
      stopifnot(primarydx %in% c(0L, 1L))
    } else {
      if (grepl("^elixhauser", method)) {
        warning("Assuming all codes provided are seconday diagnostic codes.  Define `primarydx.var` or `primarydx` if this assumption is incorrect.", call. = FALSE)
      }
      primarydx <- 0L
    }

    primarydx.var <- "..medicalcoder_primarydx.."
    while(primarydx.var %in% data_names) {
      primarydx.var <- paste0(".", primarydx.var, ".")
    }

    if (grepl("^elixhauser", method)) {
      # Use parse()/eval() to avoid adding a data.table dependency
      # while still mutating the caller's data in place, mirroring
      # `:=` style behaviour with base R only.
      e <- parse(text = paste0("data <- cbind(data, ", primarydx.var, " = ", primarydx, ")"))
      eval(e, envir = envir)
      assign(x = "primarydx.var", value = primarydx.var, envir = envir)
    }

  } else {
    if (!is.null(primarydx)) {
      warning("'primarydx.var' and 'primarydx' were both specified; ignoring 'primarydx'")
    }
    stopifnot(length(primarydx.var) == 1L)
    stopifnot(primarydx.var %in% data_names)
  }
  rtn
}

################################################################################

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
#' not `NULL`, implies all rows.
#' @param j Column name (character).  For `mdcr_set` this is the column
#' assigned `value`, update values if it exits.
#' For `mdcr_na2zero` the column to replace `NA` values with 0s.  If
#' `x[[j]]` does note exist it will be created.
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
mdcr_na2zero <- function(x, j) {
  stopifnot(is.data.frame(x))
  if (j %in% names(x)) {
    mdcr_set(x, i = which(is.na(x[[j]])), j = j, value = 0L)
  } else {
    mdcr_set(x, j = j, value = 0)
  }
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

#' Is True or False
#'
#' A helpful wrapper inspired by data.table to check that the input `x` is a
#' scalar value of either TRUE or FALSE.
#'
#' @details
#' **Developer example (not executed):**
#' ```
#' medicalcoder:::isTRUEorFALSE(TRUE) # TRUE
#' medicalcoder:::isTRUEorFALSE(FALSE) # TRUE
#' medicalcoder:::isTRUEorFALSE(c("A", "B")) # FALSE, vector length > 1
#' medicalcoder:::isTRUEorFALSE(c(TRUE, TRUE, NA, FALSE)) # FALSE, vector length > 1
#' medicalcoder:::isTRUEorFALSE(NA) # FALSE, Not TRUE or FALSE
#' ```
#'
#' @param x a R object
#'
#' @return a logical of length 1
#'
#' @noRd
#' @keywords internal
isTRUEorFALSE <- function(x) {
  is.logical(x) && length(x) == 1L && !is.na(x)
}

################################################################################
#                                 End of File                                  #
################################################################################
