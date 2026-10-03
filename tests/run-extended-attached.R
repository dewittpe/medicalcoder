source(file.path("utilities", "extended_tests_enabled.R"))

if (interactive()) {
  Sys.setenv(MEDICALCODER_RUN_EXTENDED_TESTS = "true")
}

if (!extended_tests_enabled()) {
  msg <- "Skipping extended tests; set MEDICALCODER_RUN_EXTENDED_TESTS=true to run them."
  if (interactive()) {
    stop(msg)
  } else {
    message(msg)
    quit(save = "no", status = 0, runLast = FALSE)
  }
}

library(medicalcoder)

source(file.path("utilities", "run_script.R"))

test_scripts <-
  list.files(path = "extended-attached", pattern = "^test-", full.names = TRUE)

report <- do.call(rbind, lapply(test_scripts, run_script))
notok  <- subset(report, report[["status"]] %in% c("error", "warning"))
skipped <- subset(report, report[["status"]] == "skipped")

if (nrow(skipped) > 0L) {
  message(
    "Skipped tests: ",
    paste(paste0(skipped$script, " (", skipped$skip, ")"), collapse = "; ")
  )
}

if (nrow(notok) > 0L) {
  if (interactive()) {
    print(notok)
  } else {
    print(notok[, c("script", "status")])
  }
  stop("At least one test failed with an error or warning")
}
