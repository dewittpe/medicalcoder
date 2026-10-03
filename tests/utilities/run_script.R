run_script <- function(path) {
  tic <- Sys.time()

  warnings <- character()
  skip <- NULL
  error <- NULL

  e <- new.env(parent = globalenv())
  source(file.path("utilities", "tryCatch-wrappers.R"), local = e)
  e$skip_test <- function(message) {
    stop(structure(
      list(message = message, call = NULL),
      class = c("medicalcoder_test_skip", "condition")
    ))
  }

  tryCatch(
    withCallingHandlers(
      source(path, local = e),
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    ),
    medicalcoder_test_skip = function(cnd) {
      skip <<- conditionMessage(cnd)
    },
    error = function(e) {
      error <<- conditionMessage(e)
    }
  )

  status <- if (!is.null(error)) {
    "error"
  } else if (length(warnings)) {
    "warning"
  } else if (!is.null(skip)) {
    "skipped"
  } else {
    "ok"
  }

  toc <- Sys.time()

  data.frame(
    script = basename(path),
    status = status,
    skip = if (is.null(skip)) "" else skip,
    warning = paste(warnings, collapse = " | "),
    error = if (is.null(error)) "" else error,
    runtime = as.numeric(difftime(toc, tic, units = "secs")),
    stringsAsFactors = FALSE
  )
}
