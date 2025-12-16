################################################################################
# file: prep-mimic-data.R
#
# inputs:
#   mimic-iv-clinical-database-demo-2.2.zip (downloaded from
#     https://physionet.org/content/mimic-iv-demo/2.2/hosp/#files-panel
#     on 16 December 2025)
#
#
# output:
#
#   mimic-iv-demo.rds
#
#     a data.frame

################################################################################
# required namespaces
requireNamespace("data.table")
requireNamespace("R.utils")

################################################################################
# unzip the data to a temp directory
mimic_data_path <- tempdir()
unzip(
  zipfile = "mimic-iv-clinical-database-demo-2.2.zip",
  overwrite = TRUE,
  exdir = mimic_data_path
)

# get the hosp(ital) data
files <-
  list.files(path = mimic_data_path, recursive = TRUE, full.names = TRUE)
admissions <- data.table::fread(files[endsWith(files, "admissions.csv.gz")])
patients   <- data.table::fread(files[endsWith(files, "patients.csv.gz")])
diagnoses  <- data.table::fread(files[endsWith(files, "diagnoses_icd.csv.gz")])
procedures <- data.table::fread(files[endsWith(files, "procedures_icd.csv.gz")])

################################################################################
# Build Variables

## flag for diagnosic or procedure codes
diagnoses[, dx := 1L]
procedures[, dx := 0L]

## primary diagnoses
diagnoses[, primarydx := seq_num == 1]

## Hospital Admission Sequence
# note: hadm_id are not sequential with respect to admittime
admissions[, hadm_seq := order(admittime), by = .(subject_id)]

################################################################################
## Present on Admission

# MIMIC-IV does not have an explicit present on admission (POA) varaible.  We
# will build one.  If a ICD code "XXXX" is not on admission 1 but is listed on
# admission 2 and admission 3, then the code will be considered present on
# admission for admission 3.
poa <-
  merge(
    x = diagnoses,
    y = admissions[, .(subject_id, hadm_id, hadm_seq)],
    all.x = TRUE,
    by = c("subject_id", "hadm_id")
  )

first_reported <- poa[, .(first_reported = min(hadm_seq)), keyby = .(subject_id, icd_version, icd_code)]
poa <- merge(poa, first_reported, by = c("subject_id", "icd_version", "icd_code"))
poa[, poa := as.integer(hadm_seq > first_reported)]

diagnoses <-
  merge(
    x = diagnoses,
    y = poa[, .(subject_id, hadm_id, icd_version, icd_code, poa)],
    all.x = TRUE,
    by = c("subject_id", "hadm_id", "icd_version", "icd_code")
  )

procedures[, poa := 0L]

################################################################################
icd_codes <-
  data.table::rbindlist(
    list(
      diagnoses[,  .(subject_id, hadm_id, icd_version, icd_code, seq_num, dx, poa, primarydx)],
      procedures[, .(subject_id, hadm_id, icd_version, icd_code, seq_num, dx, poa, primarydx = NA_integer_)]
    )
  )

mimicivdata <-
  merge(
    x = admissions[, .(subject_id, hadm_id, hadm_seq)],
    y = icd_codes,
    all = TRUE,
    by = c("subject_id", "hadm_id")
  )

################################################################################
# save to disk
saveRDS(mimicivdata, file = "mimicivdata.rds")

################################################################################
#                                 End of File                                  #
################################################################################
