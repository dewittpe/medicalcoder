# covr instruments package code after it is attached.  Briefly attach the
# package during coverage runs, then detach it without unloading the namespace
# so these tests still exercise the loaded-but-unattached state.  Ordinary
# checks load the namespace directly and never attach it.
if (identical(Sys.getenv("R_COVR"), "true")) {
  library(medicalcoder)
  detach("package:medicalcoder", unload = FALSE)
} else {
  loadNamespace("medicalcoder")
}

# Verify the group left medicalcoder loaded but unattached.
stopifnot(
  "medicalcoder namespace loaded" = "medicalcoder" %in% loadedNamespaces(),
  "medicalcoder namespace not attached" = !("package:medicalcoder" %in% search())
)

source(file.path("utilities", "run_script.R"))

test_scripts <-
  list.files(path = "cran-unattached", pattern = "^test-", full.names = TRUE)

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

# Verify the group left medicalcoder loaded but unattached.
stopifnot(
  "medicalcoder namespace loaded" = "medicalcoder" %in% loadedNamespaces(),
  "medicalcoder namespace not attached" = !("package:medicalcoder" %in% search())
)
