# define some helper functions for the testing suite
tryCatchError <- function(expr, ...) {
  tryCatch(expr, ..., error = function(e) {e})
}

tryCatchWarning <- function(expr, ...) {
  tryCatch(expr, ..., warning = function(w) {w})
}

extended_tests_enabled <- function() {
  identical(
    tolower(Sys.getenv("MEDICALCODER_RUN_EXTENDED_TESTS", "false")),
    "true"
  )
}
