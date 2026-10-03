
extended_tests_enabled <- function() {
  identical(
    tolower(Sys.getenv("MEDICALCODER_RUN_EXTENDED_TESTS", "false")),
    "true"
  )
}
