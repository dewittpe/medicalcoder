library(medicalcoder)
source(file.path("utilities", "run_script.R"))

test_scripts <-
  list.files(path = "cran-attached", pattern = "^test-", full.names = TRUE)

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

# TODO: test-modified-comorbidites uses caputre warning and value,
# why is this not part of the utilities?
