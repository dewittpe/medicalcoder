collect_sas_output <- function(path) {
  if (!file.exists(path)) {
    return(NULL)
  }
  sas_df <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  required_cols <- grep("^CMR_", names(sas_df), value = TRUE)
  if (!length(required_cols)) {
    warning(sprintf("%s does not contain any 'CMR_' columns; is this the correct exported file?", path), call. = FALSE)
    return(NULL)
  }
  if (!"PATID" %in% names(sas_df)) {
    warning(sprintf("%s is missing the PATID column expected in the SAS output.", path), call. = FALSE)
    return(NULL)
  }
  out <- sas_df[c("PATID", required_cols)]
  names(out) <- sub("^CMR_", "", names(out))
  names(out)[1] <- "patid"
  out$patid <- as.integer(out$patid)
  out[order(out$patid), ]
}


# Build the mdcr-wide dataset once; reused across years
input_df <- reshape_mdcr_for_sas(medicalcoder::mdcr)
num_dx_cols <- ncol(input_df) - 4L

fixture_dir <- file.path("tests", "ahrq", "expected")
dir.create(fixture_dir, showWarnings = FALSE, recursive = TRUE)

for (yr in years) {
  release <- sprintf("%d-1", yr)
  input_csv <- file.path("tests", "ahrq", sprintf("mdcr_icd10_for_cmr_input_v%s.csv", release))
  output_csv <- file.path("tests", "ahrq", sprintf("mdcr_icd10_with_cmr_v%s.csv", release))
  fixture_path <- file.path(fixture_dir, sprintf("mdcr_elixhauser_ahrq%d_expected.rds", yr))

  write_sas_input_csv(input_df, input_csv)
  message(sprintf("[%d] SAS mapping input written to: %s", yr, input_csv))
  message(sprintf("[%d] Set DXPREFIX=I10_DX, NUMDX=%d, and NDXVAR=I10_NDX in the SAS mapping program.", yr, num_dx_cols))

  res <- collect_sas_output(output_csv)
  if (!is.null(res)) {
    saveRDS(res, fixture_path)
    message(sprintf("[%d] SAS mapping output ingested and saved to: %s", yr, fixture_path))
  } else {
    message(sprintf("[%d] To build the comparison fixture, export the SAS mapping results to %s and rerun this script.", yr, output_csv))
  }
}


