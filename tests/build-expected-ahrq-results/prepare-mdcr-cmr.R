################################################################################
# file:      prepare-mdcr-cmr.R
#
# purpose:   Create AHRQ Elixhauser Comorbidity Software (ICD-10-CM) inputs and
#            optional regression-test fixtures for one or more release years.
#
# Usage:     Rscript tests/ahrq/prepare-mdcr-cmr.R # defaults to 2025
#            Rscript tests/ahrq/prepare-mdcr-cmr.R 2023 2024 2025
#
# The script filters `mdcr` to ICD-10-CM and reshape to the wide layout expected
# by the SAS mapping macros.  The result is written to CSV.
################################################################################
library(medicalcoder)

################################################################################
# Parse command line arguments (years)
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0L) {
  year <- 2025L
} else if (length(args) > 1L) {
  stop("Sole arguments must be four-digit year (e.g., 2024)")
} else {
  year <- suppressWarnings(as.integer(args))
  if (anyNA(year)) {
    stop("Sole argument must be four-digit year (e.g., 2024)")
  }
}
year <- sort(unique(year))

################################################################################
# reshpae data
mdcr10cm <-
  subset(
    x = medicalcoder::mdcr,
    subset = icdv == 10L & dx == 1L,
    select = c("patid", "code")
  )
stopifnot("all compact codes" = !any(grepl("\\.", mdcr10cm$code)))

mdcr10cm <- split(mdcr10cm[["code"]], f = mdcr10cm[["patid"]])
max_dx <- max(lengths(mdcr10cm))
dx_mat <- matrix("", nrow = length(mdcr10cm), ncol = max_dx)

for (i in seq_along(mdcr10cm)) {
  codes <- mdcr10cm[[i]]
  if (length(codes)) {
    dx_mat[i, seq_along(codes)] <- codes
  }
}

colnames(dx_mat) <- sprintf("I10_DX%d", seq_len(max_dx))


out <-
  data.frame(
    PATID = as.integer(names(mdcr10cm)),
    YEAR = rep.int(year, length(mdcr10cm)),
    DQTR = rep.int(4L, length(mdcr10cm)),
    I10_NDX = lengths(mdcr10cm),
    stringsAsFactors = FALSE
  )

out <- cbind(out, as.data.frame(dx_mat, stringsAsFactors = FALSE))
out <- out[order(out$PATID), ]

utils::write.csv(
  out,
  file = file.path(as.character(year), paste0("mdcr_for_sas_", as.character(year), ".csv")),
  row.names = FALSE,
  quote = TRUE
)

################################################################################
#                                 End of File                                  #
################################################################################
