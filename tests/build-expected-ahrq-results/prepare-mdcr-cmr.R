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
library(data.table)
mdcr10cm <-
  subset(
    x = medicalcoder::mdcr,
    subset = icdv == 10L & dx == 1L,
    select = c("patid", "code")
  )
stopifnot("all compact codes" = !any(grepl("\\.", mdcr10cm$code)))
setDT(mdcr10cm)
mdcr10cm <- unique(mdcr10cm)

# flag the codes which are in the Elixhauser mappings
mdcr10cm[, inelixhuaser := as.integer(mdcr10cm[["code"]] %in% get_elixhauser_codes()[["code"]])]

ecodes <- mdcr10cm[inelixhuaser == 1L]
ecodes <- split(ecodes, by = "patid")
ecodes <- lapply(ecodes, function(x) {
  max_dx <- length(x$code)
  mat <- expand.grid(rep(list(c(0, 1)), max_dx))
  colnames(mat) <- x$code
  mat <- as.data.table(mat)
  set(mat, j = "patid", value = x$patid[1])
  set(mat, j = "encid", value = seq_len(nrow(mat)))
  mat <- melt(mat, id.vars = c("patid", "encid"), value.name = "poa", variable.name = "code", variable.factor = FALSE)
  mat[, DX := paste0("DX", seq_len(nrow(.SD))), by = .(patid, encid)]
  mat
  })
ecodes <- rbindlist(ecodes)
ecodes[, DX := factor(DX, levels = paste0("DX", 1:12))]

ecodes[patid == 55176]
ecodes[patid == 55176 & encid == 4096]

ecodes_sas_dx <- dcast(ecodes, patid + encid ~ DX, value.var = "code")
ecodes_sas_poa <- dcast(ecodes, patid + encid ~ DX, value.var = "poa")

setnames(ecodes_sas_dx, old = names(ecodes_sas_poa), new = sub("DX", "I10_DX", names(ecodes_sas_poa)))
setnames(ecodes_sas_poa, old = names(ecodes_sas_poa), new = sub("DX", "DXPOA", names(ecodes_sas_poa)))

for (j in grep("I10_DX", names(ecodes_sas_dx), value = TRUE)) {
  set(ecodes_sas_dx, j = j, value = ifelse(is.na(ecodes_sas_dx[[j]]), "", ecodes_sas_dx[[j]]))
}

for (j in grep("DXPOA", names(ecodes_sas_poa), value = TRUE)) {
  set(ecodes_sas_poa, j = j, value = fcase(ecodes_sas_poa[[j]] == 1, "Y", ecodes_sas_poa[[j]] == 0, "N", default = ""))
}

ecodes_sas <-
  merge(ecodes_sas_dx, ecodes_sas_poa, all = TRUE, by = c("patid", "encid"))

ecodes_sas[patid == 55176]

ecodes[, PATID := paste0(patid, "-", encid)]
ecodes[, patid := NULL]
ecodes[, encid := NULL]

ecodes_sas[, PATID := paste0(patid, "-", encid)]
ecodes_sas[, patid := NULL]
ecodes_sas[, encid := NULL]

ecodes_sas[, YEAR := year]
ecodes_sas[, DQTR := 4L]

setcolorder(ecodes_sas, c("PATID", "YEAR", "DQTR"))

fwrite(
  x = ecodes_sas,
  file = file.path(as.character(year), paste0("mdcr_for_sas_", as.character(year), ".csv"))
  )

################################################################################
#                                 End of File                                  #
################################################################################
