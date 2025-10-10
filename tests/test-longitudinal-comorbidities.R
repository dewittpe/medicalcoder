source('utilities.R')
################################################################################
library(medicalcoder)
# build and test the longitudinal flagging of conditions.  The renal code will
# be provided twice, once as poa and once as not poa.   This should flag on the
# encounter as expected.  the duplication is here to see if there is a any bug
# in the code that would get messed up by a 0 and a 1 poa for a conditon on an
# encounter.

# C78.4: Cancer
#   - Charlson (Quan 2005)
#     - mst
#   - Elixhauser (AHRQ 2025)
#     - does not need to be POA to count for Elixhauser
#     - CANCER_METS
#   - PCCC v3.1
#     - malignancy_dxpr_only
#     - malignancy_dxpr_tech_only
#     - malignancy_dxpr_and_tech
#     - malignancy_dxpr_or_tech
#
# I50.40: heart failure, or cardiovasular disease
#   - Charlson (Quan 2005)
#     - chf
#   - Elixhauser (AHRQ 2025)
#     - does need to be POA to count for Elixhauser
#     - HF
#   - PCCC v3.1
#     - cvd_dxpr_only
#     - cvd_dxpr_tech_only
#     - cvd_dxpr_and_tech
#     - cvd_dxpr_or_tech
#
# N18.4: renal
#   - Charlson (Quan 2005)
#     - rnd
#   - Elixhauser (AHRQ 2025)
#     - does need to be POA to count for Elixhauser
#     - RENLFL_SEV
#   - PCCC v3.1
#     - renal_dxpr_only
#     - renal_dxpr_tech_only
#     - renal_dxpr_and_tech
#     - renal_dxpr_or_tech

record <-
  structure(
    list(
      patid = c("A", "A", "A", "A", "A", "A", "A", "A", "A", "B", "B", "B", "B", "B", "B", "B"),
      encid = c(1L, 2L, 3L, 4L, 4L, 5L, 5L, 6L, 7L, 1L, 1L, 1L, 2L, 3L, 4L, 5L),
      code  = c(NA, "C78.4", "I50.40", "N18.4", "N18.4", "C78.4", "I50.40", NA, "-", NA, "N18.4", "N18.4", NA, NA, "N18.4", NA),
      poa = c(NA, 0L, 1L, 1L, 0L, 1L, 0L, NA, 1L, NA, 1L, 0L, NA, NA, 0L, NA)
    ),
  class = "data.frame",
  row.names = c(NA, -16L)
)

# set the data in an unsorted order to verify that the output will be sorted and
# as expected.
set.seed(42)
rws <- c(sample(seq_len(nrow(record))),
         sample(seq_len(nrow(record))),
         sample(seq_len(nrow(record))))
record <- record[rws, ]

################################################################################
# Expected results

expected_zeros <- rep(0L, 12L)
expected_patid <- rep(c("A", "B"), times = c(7, 5))
expected_encid <- c(1:7, 1:5)

################################################################################
# arguments for the comorbidities call
args <-
  list(
       data = record,
       icd.codes = "code",
       id.vars = c("patid", "encid"),
       icdv = 10,
       dx = 1,
       full.codes = TRUE,
       compact.codes = FALSE,
       primarydx = 0
  )

CMRBS <-
  list(
       charlson_current_0 = do.call(comorbidities, c(args, list(method = "charlson_quan2005", flag.method = "current", poa = 0))),
       charlson_current_1 = do.call(comorbidities, c(args, list(method = "charlson_quan2005", flag.method = "current", poa = 1))),
       charlson_current_v = do.call(comorbidities, c(args, list(method = "charlson_quan2005", flag.method = "current", poa.var = "poa"))),

       charlson_cumulative_0 = do.call(comorbidities, c(args, list(method = "charlson_quan2005", flag.method = "cumulative", poa = 0))),
       charlson_cumulative_1 = do.call(comorbidities, c(args, list(method = "charlson_quan2005", flag.method = "cumulative", poa = 1))),
       charlson_cumulative_v = do.call(comorbidities, c(args, list(method = "charlson_quan2005", flag.method = "cumulative", poa.var = "poa"))),

       pccc_current_0 = do.call(comorbidities, c(args, list(method = "pccc_v3.1", flag.method = "current", poa = 0))),
       pccc_current_1 = do.call(comorbidities, c(args, list(method = "pccc_v3.1", flag.method = "current", poa = 1))),
       pccc_current_v = do.call(comorbidities, c(args, list(method = "pccc_v3.1", flag.method = "current", poa.var = "poa"))),

       pccc_cumulative_0 = do.call(comorbidities, c(args, list(method = "pccc_v3.1", flag.method = "cumulative", poa = 0))),
       pccc_cumulative_1 = do.call(comorbidities, c(args, list(method = "pccc_v3.1", flag.method = "cumulative", poa = 1))),
       pccc_cumulative_v = do.call(comorbidities, c(args, list(method = "pccc_v3.1", flag.method = "cumulative", poa.var = "poa"))),

       spccc_current_0 = do.call(comorbidities, c(args, list(method = "pccc_v3.1", flag.method = "current", poa = 0, subconditions = TRUE))),
       spccc_current_1 = do.call(comorbidities, c(args, list(method = "pccc_v3.1", flag.method = "current", poa = 1, subconditions = TRUE))),
       spccc_current_v = do.call(comorbidities, c(args, list(method = "pccc_v3.1", flag.method = "current", poa.var = "poa", subconditions = TRUE))),

       spccc_cumulative_0 = do.call(comorbidities, c(args, list(method = "pccc_v3.1", flag.method = "cumulative", poa = 0, subconditions = TRUE))),
       spccc_cumulative_1 = do.call(comorbidities, c(args, list(method = "pccc_v3.1", flag.method = "cumulative", poa = 1, subconditions = TRUE))),
       spccc_cumulative_v = do.call(comorbidities, c(args, list(method = "pccc_v3.1", flag.method = "cumulative", poa.var = "poa", subconditions = TRUE))),

       elixhauser_current_0 = do.call(comorbidities, c(args, list(method = "elixhauser_ahrq2025", flag.method = "current", poa = 0))),
       elixhauser_current_1 = do.call(comorbidities, c(args, list(method = "elixhauser_ahrq2025", flag.method = "current", poa = 1))),
       elixhauser_current_v = do.call(comorbidities, c(args, list(method = "elixhauser_ahrq2025", flag.method = "current", poa.var = "poa"))),

       elixhauser_cumulative_0 = do.call(comorbidities, c(args, list(method = "elixhauser_ahrq2025", flag.method = "cumulative", poa = 0))),
       elixhauser_cumulative_1 = do.call(comorbidities, c(args, list(method = "elixhauser_ahrq2025", flag.method = "cumulative", poa = 1))),
       elixhauser_cumulative_v = do.call(comorbidities, c(args, list(method = "elixhauser_ahrq2025", flag.method = "cumulative", poa.var = "poa")))
)

################################################################################
# for the testing - check for the expected results and then remove the object
# from the CMRBS until it is empty.

# PCCC Subconditions
#
# The PCCC with subconditions should have the same comorbidities as the objects
# without subconditions.
for (x in grep("^pccc_", names(CMRBS), value = TRUE)) {
  check <-
    all.equal(
      target = CMRBS[[x]],
      current = CMRBS[[paste0("s", x)]][["conditions"]],
      check.attributes = FALSE
    )
  if (check) {
    CMRBS[[paste0("s", x)]][["conditions"]] <- NULL
  } else {
    stop(sprintf('CMRBS[[s%s]][["conditions"]] is not all.equal to CMRBS[[%s]]', x, x))
  }
}


# Check each of the subconditions.  For the following conditions, all of which
# should not be flagged, the number of rows in the output should be zero.
for (cnd in c("respiratory", "neuromusc", "neonatal", "misc", "metabolic", "hemato_immu", "gi", "congeni_genetic")) {
  stopifnot(
    nrow(CMRBS$spccc_current_0$subconditions[[cnd]]) == 0L,
    nrow(CMRBS$spccc_current_1$subconditions[[cnd]]) == 0L,
    nrow(CMRBS$spccc_current_v$subconditions[[cnd]]) == 0L,
    nrow(CMRBS$spccc_cumulative_0$subconditions[[cnd]]) == 0L,
    nrow(CMRBS$spccc_cumulative_1$subconditions[[cnd]]) == 0L,
    nrow(CMRBS$spccc_cumulative_v$subconditions[[cnd]]) == 0L
  )
  CMRBS$spccc_current_0$subconditions[[cnd]] <- NULL
  CMRBS$spccc_current_1$subconditions[[cnd]] <- NULL
  CMRBS$spccc_current_v$subconditions[[cnd]] <- NULL
  CMRBS$spccc_cumulative_0$subconditions[[cnd]] <- NULL
  CMRBS$spccc_cumulative_1$subconditions[[cnd]] <- NULL
  CMRBS$spccc_cumulative_v$subconditions[[cnd]] <- NULL
}

# Specific checks for cvd
stopifnot(identical(nrow(CMRBS$spccc_current_0$subconditions[["cvd"]]), 0L))
CMRBS$spccc_current_0$subconditions[["cvd"]] <- NULL

stopifnot(
  identical(CMRBS$spccc_current_1$subconditions[["cvd"]][["patid"]], c("A", "A")),
  identical(CMRBS$spccc_current_1$subconditions[["cvd"]][["encid"]], c(3L, 5L)),
  identical(CMRBS$spccc_current_1$subconditions[["cvd"]][["other"]], c(1L, 1L)),
  all(CMRBS$spccc_current_1$subconditions[["cvd"]][, !(names(CMRBS$spccc_current_1$subconditions[["cvd"]]) %in% c("patid", "encid", "other"))] == 0)
)
CMRBS$spccc_current_1$subconditions[["cvd"]] <- NULL

stopifnot(
  identical(CMRBS$spccc_current_v$subconditions[["cvd"]][["patid"]], c("A")),
  identical(CMRBS$spccc_current_v$subconditions[["cvd"]][["encid"]], c(3L)),
  identical(CMRBS$spccc_current_v$subconditions[["cvd"]][["other"]], c(1L)),
  all(CMRBS$spccc_current_v$subconditions[["cvd"]][, !(names(CMRBS$spccc_current_v$subconditions[["cvd"]]) %in% c("patid", "encid", "other"))] == 0)
)
CMRBS$spccc_current_v$subconditions[["cvd"]] <- NULL

stopifnot(
  identical(CMRBS$spccc_cumulative_0$subconditions[["cvd"]][["patid"]], rep("A", 4)),
  identical(CMRBS$spccc_cumulative_0$subconditions[["cvd"]][["encid"]], 4:7),
  identical(CMRBS$spccc_cumulative_0$subconditions[["cvd"]][["other"]], rep(1L, 4)),
  all(CMRBS$spccc_cumulative_0$subconditions[["cvd"]][, !(names(CMRBS$spccc_current_0$subconditions[["cvd"]]) %in% c("patid", "encid", "other"))] == 0)
)
CMRBS$spccc_cumulative_0$subconditions[["cvd"]] <- NULL

stopifnot(
  identical(CMRBS$spccc_cumulative_1$subconditions[["cvd"]][["patid"]], rep("A", 5)),
  identical(CMRBS$spccc_cumulative_1$subconditions[["cvd"]][["encid"]], 3:7),
  identical(CMRBS$spccc_cumulative_1$subconditions[["cvd"]][["other"]], rep(1L, 5)),
  all(CMRBS$spccc_cumulative_1$subconditions[["cvd"]][, !(names(CMRBS$spccc_current_1$subconditions[["cdv"]]) %in% c("patid", "encid", "other"))] == 0)
)
CMRBS$spccc_cumulative_1$subconditions[["cvd"]] <- NULL

stopifnot(
  identical(CMRBS$spccc_cumulative_v$subconditions[["cvd"]][["patid"]], rep("A", 5)),
  identical(CMRBS$spccc_cumulative_v$subconditions[["cvd"]][["encid"]], 3:7),
  identical(CMRBS$spccc_cumulative_v$subconditions[["cvd"]][["other"]], rep(1L, 5)),
  all(CMRBS$spccc_cumulative_v$subconditions[["cvd"]][, !(names(CMRBS$spccc_cumulative_v$subconditions[["cvd"]]) %in% c("patid", "encid", "other"))] == 0)
)
CMRBS$spccc_cumulative_v$subconditions[["cvd"]] <- NULL

# for cancer/malignancy
stopifnot(identical(nrow(CMRBS$spccc_current_0$subconditions[["malignancy"]]), 0L))
CMRBS$spccc_current_0$subconditions[["malignancy"]] <- NULL

stopifnot(
  identical(CMRBS$spccc_current_1$subconditions[["malignancy"]][["patid"]], c("A", "A")),
  identical(CMRBS$spccc_current_1$subconditions[["malignancy"]][["encid"]], c(2L, 5L)),
  identical(CMRBS$spccc_current_1$subconditions[["malignancy"]][["neoplasms"]], c(1L, 1L)),
  all(CMRBS$spccc_current_1$subconditions[["malignancy"]][, !(names(CMRBS$spccc_current_1$subconditions[["malignancy"]]) %in% c("patid", "encid", "neoplasms"))] == 0)
)
CMRBS$spccc_current_1$subconditions[["malignancy"]] <- NULL

stopifnot(
  identical(CMRBS$spccc_current_v$subconditions[["malignancy"]][["patid"]], c("A")),
  identical(CMRBS$spccc_current_v$subconditions[["malignancy"]][["encid"]], c(5L)),
  identical(CMRBS$spccc_current_v$subconditions[["malignancy"]][["neoplasms"]], c(1L)),
  all(CMRBS$spccc_current_v$subconditions[["malignancy"]][, !(names(CMRBS$spccc_current_v$subconditions[["malignancy"]]) %in% c("patid", "encid", "neoplasms"))] == 0)
)
CMRBS$spccc_current_v$subconditions[["malignancy"]] <- NULL

stopifnot(
  identical(CMRBS$spccc_cumulative_0$subconditions[["malignancy"]][["patid"]], rep("A", 5)),
  identical(CMRBS$spccc_cumulative_0$subconditions[["malignancy"]][["encid"]], 3:7),
  identical(CMRBS$spccc_cumulative_0$subconditions[["malignancy"]][["neoplasms"]], rep(1L, 5)),
  all(CMRBS$spccc_cumulative_0$subconditions[["malignancy"]][, !(names(CMRBS$spccc_cumulative_0$subconditions[["malignancy"]]) %in% c("patid", "encid", "neoplasms"))] == 0)
)
CMRBS$spccc_cumulative_0$subconditions[["malignancy"]] <- NULL

stopifnot(
  identical(CMRBS$spccc_cumulative_1$subconditions[["malignancy"]][["patid"]], rep("A", 6)),
  identical(CMRBS$spccc_cumulative_1$subconditions[["malignancy"]][["encid"]], 2:7),
  identical(CMRBS$spccc_cumulative_1$subconditions[["malignancy"]][["neoplasms"]], rep(1L, 6)),
  all(CMRBS$spccc_cumulative_1$subconditions[["malignancy"]][, !(names(CMRBS$spccc_cumulative_1$subconditions[["malignancy"]]) %in% c("patid", "encid", "neoplasms"))] == 0)
)
CMRBS$spccc_cumulative_1$subconditions[["malignancy"]] <- NULL

stopifnot(
  identical(CMRBS$spccc_cumulative_v$subconditions[["malignancy"]][["patid"]], rep("A", 5)),
  identical(CMRBS$spccc_cumulative_v$subconditions[["malignancy"]][["encid"]], 3:7),
  identical(CMRBS$spccc_cumulative_v$subconditions[["malignancy"]][["neoplasms"]], rep(1L, 5)),
  all(CMRBS$spccc_cumulative_v$subconditions[["malignancy"]][, !(names(CMRBS$spccc_cumulative_v$subconditions[["malignancy"]]) %in% c("patid", "encid", "neoplasms"))] == 0)
)
CMRBS$spccc_cumulative_v$subconditions[["malignancy"]] <- NULL

# for renal
stopifnot(identical(nrow(CMRBS$spccc_current_0$subconditions[["renal"]]), 0L))
CMRBS$spccc_current_0$subconditions[["renal"]] <- NULL

stopifnot(
  identical(CMRBS$spccc_current_1$subconditions[["renal"]][["patid"]], c("A", "B", "B")),
  identical(CMRBS$spccc_current_1$subconditions[["renal"]][["encid"]], c(4L, 1L, 4L)),
  identical(CMRBS$spccc_current_1$subconditions[["renal"]][["chronic_renal_failure"]], c(1L, 1L, 1L)),
  all(CMRBS$spccc_current_1$subconditions[["renal"]][, !(names(CMRBS$spccc_current_1$subconditions[["renal"]]) %in% c("patid", "encid", "chronic_renal_failure"))] == 0)
)
CMRBS$spccc_current_1$subconditions[["renal"]] <- NULL

stopifnot(
  identical(CMRBS$spccc_current_v$subconditions[["renal"]][["patid"]], c("A", "B")),
  identical(CMRBS$spccc_current_v$subconditions[["renal"]][["encid"]], c(4L, 1L)),
  identical(CMRBS$spccc_current_v$subconditions[["renal"]][["chronic_renal_failure"]], c(1L, 1L)),
  all(CMRBS$spccc_current_v$subconditions[["renal"]][, !(names(CMRBS$spccc_current_v$subconditions[["renal"]]) %in% c("patid", "encid", "chronic_renal_failure"))] == 0)
)
CMRBS$spccc_current_v$subconditions[["renal"]] <- NULL

stopifnot(
  identical(CMRBS$spccc_cumulative_0$subconditions[["renal"]][["patid"]], rep(c("A", "B"), times = c(3, 4))),
  identical(CMRBS$spccc_cumulative_0$subconditions[["renal"]][["encid"]], c(5:7, 2:5)),
  identical(CMRBS$spccc_cumulative_0$subconditions[["renal"]][["chronic_renal_failure"]], rep(1L, 7)),
  all(CMRBS$spccc_cumulative_0$subconditions[["renal"]][, !(names(CMRBS$spccc_cumulative_0$subconditions[["renal"]]) %in% c("patid", "encid", "chronic_renal_failure"))] == 0)
)
CMRBS$spccc_cumulative_0$subconditions[["renal"]] <- NULL

stopifnot(
  identical(CMRBS$spccc_cumulative_1$subconditions[["renal"]][["patid"]], rep(c("A", "B"), times = c(4, 5))),
  identical(CMRBS$spccc_cumulative_1$subconditions[["renal"]][["encid"]], c(4:7, 1:5)),
  identical(CMRBS$spccc_cumulative_1$subconditions[["renal"]][["chronic_renal_failure"]], rep(1L, 9)),
  all(CMRBS$spccc_cumulative_1$subconditions[["renal"]][, !(names(CMRBS$spccc_cumulative_1$subconditions[["renal"]]) %in% c("patid", "encid", "chronic_renal_failure"))] == 0)
)
CMRBS$spccc_cumulative_1$subconditions[["renal"]] <- NULL

stopifnot(
  identical(CMRBS$spccc_cumulative_v$subconditions[["renal"]][["patid"]], rep(c("A", "B"), times = c(4, 5))),
  identical(CMRBS$spccc_cumulative_v$subconditions[["renal"]][["encid"]], c(4:7, 1:5)),
  identical(CMRBS$spccc_cumulative_v$subconditions[["renal"]][["chronic_renal_failure"]], rep(1L, 9)),
  all(CMRBS$spccc_cumulative_v$subconditions[["renal"]][, !(names(CMRBS$spccc_cumulative_v$subconditions[["renal"]]) %in% c("patid", "encid", "chronic_renal_failure"))] == 0)
)
CMRBS$spccc_cumulative_v$subconditions[["renal"]] <- NULL

# remove the subcondtions after verifying they are all empty
stopifnot(identical(length(CMRBS$spccc_current_0$subconditions), 0L))
CMRBS$spccc_current_0$subconditions <- NULL
stopifnot(identical(length(CMRBS$spccc_current_0), 0L))
CMRBS$spccc_current_0 <- NULL

stopifnot(identical(length(CMRBS$spccc_current_1$subconditions), 0L))
CMRBS$spccc_current_1$subconditions <- NULL
stopifnot(identical(length(CMRBS$spccc_current_1), 0L))
CMRBS$spccc_current_1 <- NULL

stopifnot(identical(length(CMRBS$spccc_current_v$subconditions), 0L))
CMRBS$spccc_current_v$subconditions <- NULL
stopifnot(identical(length(CMRBS$spccc_current_v), 0L))
CMRBS$spccc_current_v <- NULL

stopifnot(identical(length(CMRBS$spccc_cumulative_0$subconditions), 0L))
CMRBS$spccc_cumulative_0$subconditions <- NULL
stopifnot(identical(length(CMRBS$spccc_cumulative_0), 0L))
CMRBS$spccc_cumulative_0 <- NULL

stopifnot(identical(length(CMRBS$spccc_cumulative_1$subconditions), 0L))
CMRBS$spccc_cumulative_1$subconditions <- NULL
stopifnot(identical(length(CMRBS$spccc_cumulative_1), 0L))
CMRBS$spccc_cumulative_1 <- NULL

stopifnot(identical(length(CMRBS$spccc_cumulative_v$subconditions), 0L))
CMRBS$spccc_cumulative_v$subconditions <- NULL
stopifnot(identical(length(CMRBS$spccc_cumulative_v), 0L))
CMRBS$spccc_cumulative_v <- NULL

################################################################################
# Check the conditions for charlson current poa 0
stopifnot(identical(CMRBS$charlson_current_0[["age_score"]], rep(NA_integer_, 12)))
CMRBS$charlson_current_0[["age_score"]] <- NULL
stopifnot(identical(CMRBS$charlson_current_0[["patid"]], expected_patid))
CMRBS$charlson_current_0[["patid"]] <- NULL
stopifnot(identical(CMRBS$charlson_current_0[["encid"]], expected_encid))
CMRBS$charlson_current_0[["encid"]] <- NULL
stopifnot(all(CMRBS$charlson_current_0 == 0))
CMRBS$charlson_current_0 <- NULL

################################################################################
# Check the conditions for pccc current poa 0
stopifnot(identical(CMRBS$pccc_current_0[["patid"]], expected_patid))
CMRBS$pccc_current_0[["patid"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_0[["encid"]], expected_encid))
CMRBS$pccc_current_0[["encid"]] <- NULL
stopifnot(all(CMRBS$pccc_current_0 == 0))
CMRBS$pccc_current_0 <- NULL

################################################################################
# Check the conditions for elixhauser current poa 0
stopifnot(identical(CMRBS$elixhauser_current_0[["patid"]], expected_patid))
CMRBS$elixhauser_current_0[["patid"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_0[["encid"]], expected_encid))
CMRBS$elixhauser_current_0[["encid"]] <- NULL

stopifnot(identical(CMRBS$elixhauser_current_0[["CANCER_METS"]], c(0L, 1L, 0L, 0L, 1L, rep(0L, 7))))
CMRBS$elixhauser_current_0[["CANCER_METS"]] <- NULL

stopifnot(identical(CMRBS$elixhauser_current_0[["mortality_index"]], 22L * c(0L, 1L, 0L, 0L, 1L, rep(0L, 7))))
CMRBS$elixhauser_current_0[["mortality_index"]] <- NULL

stopifnot(identical(CMRBS$elixhauser_current_0[["readmission_index"]], 11L * c(0L, 1L, 0L, 0L, 1L, rep(0L, 7))))
CMRBS$elixhauser_current_0[["readmission_index"]] <- NULL

stopifnot(identical(CMRBS$elixhauser_current_0[["cmrb_flag"]], c(0L, 1L, 0L, 0L, 1L, rep(0L, 7))))
CMRBS$elixhauser_current_0[["cmrb_flag"]] <- NULL

stopifnot(identical(CMRBS$elixhauser_current_0[["num_cmrb"]], c(0L, 1L, 0L, 0L, 1L, rep(0L, 7))))
CMRBS$elixhauser_current_0[["num_cmrb"]] <- NULL

stopifnot(all(CMRBS$elixhauser_current_0 == 0))
CMRBS$elixhauser_current_0 <- NULL

################################################################################
# Charlson, current, poa 1
stopifnot(identical(CMRBS$charlson_current_1[["patid"]], expected_patid))
CMRBS$charlson_current_1[["patid"]] <- NULL
stopifnot(identical(CMRBS$charlson_current_1[["encid"]], expected_encid))
CMRBS$charlson_current_1[["encid"]] <- NULL

stopifnot(identical(CMRBS$charlson_current_1[["age_score"]], rep(NA_integer_, 12)))
CMRBS$charlson_current_1[["age_score"]] <- NULL

stopifnot(identical(CMRBS$charlson_current_1[["chf"]], c(0L, 0L, 1L, 0L, 1L, rep(0L, 7L))))
CMRBS$charlson_current_1[["chf"]] <- NULL

stopifnot(identical(CMRBS$charlson_current_1[["mst"]], c(0L, 1L, 0L, 0L, 1L, rep(0L, 7L))))
CMRBS$charlson_current_1[["mst"]] <- NULL

stopifnot(identical(CMRBS$charlson_current_1[["rnd"]], c(0L, 0L, 0L, 1L, 0L, 0L, 0L, 1L, 0L, 0L, 1L, 0L)))
CMRBS$charlson_current_1[["rnd"]] <- NULL

stopifnot(identical(CMRBS$charlson_current_1[["cmrb_flag"]], c(0L, 1L, 1L, 1L, 1L, 0L, 0L, 1L, 0L, 0L, 1L, 0L)))
CMRBS$charlson_current_1[["cmrb_flag"]] <- NULL

stopifnot(identical(CMRBS$charlson_current_1[["num_cmrb"]], c(0L, 1L, 1L, 1L, 2L, 0L, 0L, 1L, 0L, 0L, 1L, 0L)))
CMRBS$charlson_current_1[["num_cmrb"]] <- NULL

stopifnot(identical(CMRBS$charlson_current_1[["cci"]], c(0L, 6L, 1L, 2L, 7L, 0L, 0L, 2L, 0L, 0L, 2L, 0L)))
CMRBS$charlson_current_1[["cci"]] <- NULL

stopifnot(all(CMRBS$charlson_current_1 == 0))
CMRBS$charlson_current_1 <- NULL

################################################################################
# charlson_current_v
stopifnot(identical(CMRBS$charlson_current_v[["patid"]], expected_patid))
CMRBS$charlson_current_v[["patid"]] <- NULL
stopifnot(identical(CMRBS$charlson_current_v[["encid"]], expected_encid))
CMRBS$charlson_current_v[["encid"]] <- NULL
stopifnot(identical(CMRBS$charlson_current_v[["age_score"]], rep(NA_integer_, 12L)))
CMRBS$charlson_current_v[["age_score"]] <- NULL
stopifnot(identical(CMRBS$charlson_current_v[["chf"]], c(rep(0L, 2L), 1L, rep(0L, 9L))))
CMRBS$charlson_current_v[["chf"]] <- NULL
stopifnot(identical(CMRBS$charlson_current_v[["rnd"]], c(rep(0L, 3L), 1L, rep(0L, 3L), 1L, rep(0L, 4L))))
CMRBS$charlson_current_v[["rnd"]] <- NULL
stopifnot(identical(CMRBS$charlson_current_v[["mst"]], c(rep(0L, 4L), 1L, rep(0L, 7L))))
CMRBS$charlson_current_v[["mst"]] <- NULL
stopifnot(identical(CMRBS$charlson_current_v[["num_cmrb"]], c(0L, 0L, 1L, 1L, 1L, 0L, 0L, 1L, 0L, 0L, 0L, 0L)))
CMRBS$charlson_current_v[["num_cmrb"]] <- NULL
stopifnot(identical(CMRBS$charlson_current_v[["cmrb_flag"]], c(0L, 0L, 1L, 1L, 1L, 0L, 0L, 1L, 0L, 0L, 0L, 0L)))
CMRBS$charlson_current_v[["cmrb_flag"]] <- NULL
stopifnot(identical(CMRBS$charlson_current_v[["cci"]], c(0L, 0L, 1L, 2L, 6L, 0L, 0L, 2L, 0L, 0L, 0L, 0L)))
CMRBS$charlson_current_v[["cci"]] <- NULL
stopifnot(all(CMRBS$charlson_current_v == 0))
CMRBS$charlson_current_v <- NULL

################################################################################
# charlson_cumulative_0
stopifnot(identical(CMRBS$charlson_cumulative_0[["patid"]], expected_patid))
CMRBS$charlson_cumulative_0[["patid"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_0[["encid"]], expected_encid))
CMRBS$charlson_cumulative_0[["encid"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_0[["age_score"]], rep(NA_integer_, 12L)))
CMRBS$charlson_cumulative_0[["age_score"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_0[["chf"]], c(0L, 0L, 0L, rep(1L, 4L), rep(0L, 5L))))
CMRBS$charlson_cumulative_0[["chf"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_0[["rnd"]], c(rep(0L, 4L), rep(1L, 3L), 0L, rep(1L, 4L))))
CMRBS$charlson_cumulative_0[["rnd"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_0[["mst"]], c(0L, 0L, rep(1L, 5L), rep(0L, 5))))
CMRBS$charlson_cumulative_0[["mst"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_0[["num_cmrb"]], c(0L, 0L, 1L, 2L, 3L, 3L, 3L, 0L, 1L, 1L, 1L, 1L)))
CMRBS$charlson_cumulative_0[["num_cmrb"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_0[["cmrb_flag"]], c(0L, 0L, 1L, 1L, 1L, 1L, 1L, 0L, 1L, 1L, 1L, 1L)))
CMRBS$charlson_cumulative_0[["cmrb_flag"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_0[["cci"]], c(0L, 0L, 6L, 7L, 9L, 9L, 9L, 0L, 2L, 2L, 2L, 2L)))
CMRBS$charlson_cumulative_0[["cci"]] <- NULL

stopifnot(all(CMRBS$charlson_cumulative_0 == 0))
CMRBS$charlson_cumulative_0 <- NULL

################################################################################
# charlson_cumulative_1
stopifnot(identical(CMRBS$charlson_cumulative_1[["patid"]], expected_patid))
CMRBS$charlson_cumulative_1[["patid"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_1[["encid"]], expected_encid))
CMRBS$charlson_cumulative_1[["encid"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_1[["age_score"]], rep(NA_integer_, 12L)))
CMRBS$charlson_cumulative_1[["age_score"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_1[["chf"]], c(0L, 0L, rep(1L, 5L), rep(0L, 5L))))
CMRBS$charlson_cumulative_1[["chf"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_1[["rnd"]], c(rep(0L, 3L), rep(1L, 4L), rep(1L, 5L))))
CMRBS$charlson_cumulative_1[["rnd"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_1[["mst"]], c(0L, rep(1L, 6L), rep(0L, 5))))
CMRBS$charlson_cumulative_1[["mst"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_1[["num_cmrb"]], c(0L, 1L, 2L, 3L, 3L, 3L, 3L, rep(1L, 5L))))
CMRBS$charlson_cumulative_1[["num_cmrb"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_1[["cmrb_flag"]], c(0L, rep(1L, 11L))))
CMRBS$charlson_cumulative_1[["cmrb_flag"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_1[["cci"]], c(0L, 6L, 7L, 9L, 9L, 9L, 9L, 2L, 2L, 2L, 2L, 2L)))
CMRBS$charlson_cumulative_1[["cci"]] <- NULL

stopifnot(all(CMRBS$charlson_cumulative_1 == 0))
CMRBS$charlson_cumulative_1 <- NULL

################################################################################
# charlson_cumulative_v
stopifnot(identical(CMRBS$charlson_cumulative_v[["patid"]], expected_patid))
CMRBS$charlson_cumulative_v[["patid"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_v[["encid"]], expected_encid))
CMRBS$charlson_cumulative_v[["encid"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_v[["age_score"]], rep(NA_integer_, 12L)))
CMRBS$charlson_cumulative_v[["age_score"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_v[["chf"]], c(0L, 0L, rep(1L, 5L), rep(0L, 5L))))
CMRBS$charlson_cumulative_v[["chf"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_v[["rnd"]], c(rep(0L, 3L), rep(1L, 4L), rep(1L, 5L))))
CMRBS$charlson_cumulative_v[["rnd"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_v[["mst"]], c(0L, 0L, rep(1L, 5L), rep(0L, 5))))
CMRBS$charlson_cumulative_v[["mst"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_v[["num_cmrb"]], c(0L, 0L, 2L, 3L, 3L, 3L, 3L, rep(1L, 5L))))
CMRBS$charlson_cumulative_v[["num_cmrb"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_v[["cmrb_flag"]], c(0L, 0L, rep(1L, 10L))))
CMRBS$charlson_cumulative_v[["cmrb_flag"]] <- NULL
stopifnot(identical(CMRBS$charlson_cumulative_v[["cci"]], c(0L, 0L, 7L, 9L, 9L, 9L, 9L, 2L, 2L, 2L, 2L, 2L)))
CMRBS$charlson_cumulative_v[["cci"]] <- NULL

stopifnot(all(CMRBS$charlson_cumulative_v == 0))
CMRBS$charlson_cumulative_v <- NULL

################################################################################
# pccc_current_1
stopifnot(identical(CMRBS$pccc_current_1[["patid"]], expected_patid))
CMRBS$pccc_current_1[["patid"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_1[["encid"]], expected_encid))
CMRBS$pccc_current_1[["encid"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_1[["cvd_dxpr_or_tech"]], c(0L, 0L, 1L, 0L, 1L, rep(0L, 7L))))
CMRBS$pccc_current_1[["cvd_dxpr_or_tech"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_1[["cvd_dxpr_only"]], c(0L, 0L, 1L, 0L, 1L, rep(0L, 7L))))
CMRBS$pccc_current_1[["cvd_dxpr_only"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_1[["malignancy_dxpr_or_tech"]], c(0L, 1L, 0L, 0L, 1L, rep(0L, 7L))))
CMRBS$pccc_current_1[["malignancy_dxpr_or_tech"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_1[["malignancy_dxpr_only"]], c(0L, 1L, 0L, 0L, 1L, rep(0L, 7L))))
CMRBS$pccc_current_1[["malignancy_dxpr_only"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_1[["renal_dxpr_or_tech"]], c(0L, 0L, 0L, 1L, 0L, 0L, 0L, 1L, 0L, 0L, 1L, 0L)))
CMRBS$pccc_current_1[["renal_dxpr_or_tech"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_1[["renal_dxpr_only"]], c(0L, 0L, 0L, 1L, 0L, 0L, 0L, 1L, 0L, 0L, 1L, 0L)))
CMRBS$pccc_current_1[["renal_dxpr_only"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_1[["cmrb_flag"]], c(0L, 1L, 1L, 1L, 1L, 0L, 0L, 1L, 0L, 0L, 1L, 0L)))
CMRBS$pccc_current_1[["cmrb_flag"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_1[["num_cmrb"]], c(0L, 1L, 1L, 1L, 2L, 0L, 0L, 1L, 0L, 0L, 1L, 0L)))
CMRBS$pccc_current_1[["num_cmrb"]] <- NULL

stopifnot(all(CMRBS$pccc_current_1 == 0))
CMRBS$pccc_current_1 <- NULL

################################################################################
# pccc_current_v
stopifnot(identical(CMRBS$pccc_current_v[["patid"]], expected_patid))
CMRBS$pccc_current_v[["patid"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_v[["encid"]], expected_encid))
CMRBS$pccc_current_v[["encid"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_v[["cvd_dxpr_or_tech"]], c(0L, 0L, 1L, 0L, 0L, rep(0L, 7L))))
CMRBS$pccc_current_v[["cvd_dxpr_or_tech"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_v[["cvd_dxpr_only"]], c(0L, 0L, 1L, 0L, 0L, rep(0L, 7L))))
CMRBS$pccc_current_v[["cvd_dxpr_only"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_v[["malignancy_dxpr_or_tech"]], c(0L, 0L, 0L, 0L, 1L, rep(0L, 7L))))
CMRBS$pccc_current_v[["malignancy_dxpr_or_tech"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_v[["malignancy_dxpr_only"]], c(0L, 0L, 0L, 0L, 1L, rep(0L, 7L))))
CMRBS$pccc_current_v[["malignancy_dxpr_only"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_v[["renal_dxpr_or_tech"]], c(0L, 0L, 0L, 1L, 0L, 0L, 0L, 1L, 0L, 0L, 0L, 0L)))
CMRBS$pccc_current_v[["renal_dxpr_or_tech"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_v[["renal_dxpr_only"]], c(0L, 0L, 0L, 1L, 0L, 0L, 0L, 1L, 0L, 0L, 0L, 0L)))
CMRBS$pccc_current_v[["renal_dxpr_only"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_v[["cmrb_flag"]], c(0L, 0L, 1L, 1L, 1L, 0L, 0L, 1L, 0L, 0L, 0L, 0L)))
CMRBS$pccc_current_v[["cmrb_flag"]] <- NULL
stopifnot(identical(CMRBS$pccc_current_v[["num_cmrb"]], c(0L, 0L, 1L, 1L, 1L, 0L, 0L, 1L, 0L, 0L, 0L, 0L)))
CMRBS$pccc_current_v[["num_cmrb"]] <- NULL

stopifnot(all(CMRBS$pccc_current_v == 0))
CMRBS$pccc_current_v <- NULL

################################################################################
# pccc_cumulative_0
stopifnot(identical(CMRBS$pccc_cumulative_0[["patid"]], expected_patid))
CMRBS$pccc_cumulative_0[["patid"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_0[["encid"]], expected_encid))
CMRBS$pccc_cumulative_0[["encid"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_0[["cvd_dxpr_or_tech"]], c(0L, 0L, 0L, rep(1L, 4L), rep(0L, 5L))))
CMRBS$pccc_cumulative_0[["cvd_dxpr_or_tech"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_0[["cvd_dxpr_only"]], c(0L, 0L, 0L, rep(1L, 4L), rep(0L, 5L))))
CMRBS$pccc_cumulative_0[["cvd_dxpr_only"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_0[["renal_dxpr_or_tech"]], c(rep(0L, 4L), rep(1L, 3L), 0L, rep(1L, 4L))))
CMRBS$pccc_cumulative_0[["renal_dxpr_or_tech"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_0[["renal_dxpr_only"]], c(rep(0L, 4L), rep(1L, 3L), 0L, rep(1L, 4L))))
CMRBS$pccc_cumulative_0[["renal_dxpr_only"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_0[["malignancy_dxpr_or_tech"]], c(0L, 0L, rep(1L, 5L), rep(0L, 5))))
CMRBS$pccc_cumulative_0[["malignancy_dxpr_or_tech"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_0[["malignancy_dxpr_only"]], c(0L, 0L, rep(1L, 5L), rep(0L, 5))))
CMRBS$pccc_cumulative_0[["malignancy_dxpr_only"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_0[["num_cmrb"]], c(0L, 0L, 1L, 2L, 3L, 3L, 3L, 0L, 1L, 1L, 1L, 1L)))
CMRBS$pccc_cumulative_0[["num_cmrb"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_0[["cmrb_flag"]], c(0L, 0L, 1L, 1L, 1L, 1L, 1L, 0L, 1L, 1L, 1L, 1L)))
CMRBS$pccc_cumulative_0[["cmrb_flag"]] <- NULL

stopifnot(all(CMRBS$pccc_cumulative_0 == 0))
CMRBS$pccc_cumulative_0 <- NULL

################################################################################
# pccc_cumulative_1
stopifnot(identical(CMRBS$pccc_cumulative_1[["patid"]], expected_patid))
CMRBS$pccc_cumulative_1[["patid"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_1[["encid"]], expected_encid))
CMRBS$pccc_cumulative_1[["encid"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_1[["cvd_dxpr_or_tech"]], c(0L, 0L, rep(1L, 5L), rep(0L, 5L))))
CMRBS$pccc_cumulative_1[["cvd_dxpr_or_tech"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_1[["renal_dxpr_or_tech"]], c(rep(0L, 3L), rep(1L, 4L), rep(1L, 5L))))
CMRBS$pccc_cumulative_1[["renal_dxpr_or_tech"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_1[["malignancy_dxpr_or_tech"]], c(0L, rep(1L, 6L), rep(0L, 5))))
CMRBS$pccc_cumulative_1[["malignancy_dxpr_or_tech"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_1[["cvd_dxpr_only"]], c(0L, 0L, rep(1L, 5L), rep(0L, 5L))))
CMRBS$pccc_cumulative_1[["cvd_dxpr_only"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_1[["renal_dxpr_only"]], c(rep(0L, 3L), rep(1L, 4L), rep(1L, 5L))))
CMRBS$pccc_cumulative_1[["renal_dxpr_only"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_1[["malignancy_dxpr_only"]], c(0L, rep(1L, 6L), rep(0L, 5))))
CMRBS$pccc_cumulative_1[["malignancy_dxpr_only"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_1[["num_cmrb"]], c(0L, 1L, 2L, 3L, 3L, 3L, 3L, rep(1L, 5L))))
CMRBS$pccc_cumulative_1[["num_cmrb"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_1[["cmrb_flag"]], c(0L, rep(1L, 11L))))
CMRBS$pccc_cumulative_1[["cmrb_flag"]] <- NULL

stopifnot(all(CMRBS$pccc_cumulative_1 == 0))
CMRBS$pccc_cumulative_1 <- NULL

################################################################################
# pccc_cumulative_v
stopifnot(identical(CMRBS$pccc_cumulative_v[["patid"]], expected_patid))
CMRBS$pccc_cumulative_v[["patid"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_v[["encid"]], expected_encid))
CMRBS$pccc_cumulative_v[["encid"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_v[["cvd_dxpr_or_tech"]], c(0L, 0L, rep(1L, 5L), rep(0L, 5L))))
CMRBS$pccc_cumulative_v[["cvd_dxpr_or_tech"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_v[["renal_dxpr_or_tech"]], c(rep(0L, 3L), rep(1L, 4L), rep(1L, 5L))))
CMRBS$pccc_cumulative_v[["renal_dxpr_or_tech"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_v[["malignancy_dxpr_or_tech"]], c(0L, 0L, rep(1L, 5L), rep(0L, 5))))
CMRBS$pccc_cumulative_v[["malignancy_dxpr_or_tech"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_v[["cvd_dxpr_only"]], c(0L, 0L, rep(1L, 5L), rep(0L, 5L))))
CMRBS$pccc_cumulative_v[["cvd_dxpr_only"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_v[["renal_dxpr_only"]], c(rep(0L, 3L), rep(1L, 4L), rep(1L, 5L))))
CMRBS$pccc_cumulative_v[["renal_dxpr_only"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_v[["malignancy_dxpr_only"]], c(0L, 0L, rep(1L, 5L), rep(0L, 5))))
CMRBS$pccc_cumulative_v[["malignancy_dxpr_only"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_v[["num_cmrb"]], c(0L, 0L, 2L, 3L, 3L, 3L, 3L, rep(1L, 5L))))
CMRBS$pccc_cumulative_v[["num_cmrb"]] <- NULL
stopifnot(identical(CMRBS$pccc_cumulative_v[["cmrb_flag"]], c(0L, 0L, rep(1L, 10L))))
CMRBS$pccc_cumulative_v[["cmrb_flag"]] <- NULL

stopifnot(all(CMRBS$pccc_cumulative_v == 0))
CMRBS$pccc_cumulative_v <- NULL

################################################################################
# elixhauser_current_1
stopifnot(identical(CMRBS$elixhauser_current_1[["patid"]], expected_patid))
CMRBS$elixhauser_current_1[["patid"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_1[["encid"]], expected_encid))
CMRBS$elixhauser_current_1[["encid"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_1[["cmrb_flag"]], c(0L, 1L, 1L, 1L, 1L, 0L, 0L, 1L, 0L, 0L, 1L, 0L)))
CMRBS$elixhauser_current_1[["cmrb_flag"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_1[["num_cmrb"]], c(0L, 1L, 1L, 1L, 2L, 0L, 0L, 1L, 0L, 0L, 1L, 0L)))
CMRBS$elixhauser_current_1[["num_cmrb"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_1[["RENLFL_SEV"]], c(0L, 0L, 0L, 1L, 0L, 0L, 0L, 1L, 0L, 0L, 1L, 0L)))
CMRBS$elixhauser_current_1[["RENLFL_SEV"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_1[["HF"]], c(0L, 0L, 1L, 0L, 1L, 0L, 0L, 0L, 0L, 0L, 0L, 0L)))
CMRBS$elixhauser_current_1[["HF"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_1[["CANCER_METS"]], c(0L, 1L, 0L, 0L, 1L, 0L, 0L, 0L, 0L, 0L, 0L, 0L)))
CMRBS$elixhauser_current_1[["CANCER_METS"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_1[["mortality_index"]], c(0L, 22L, 14L, 7L, 36L, 0L, 0L, 7L, 0L, 0L, 7L, 0L)))
CMRBS$elixhauser_current_1[["mortality_index"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_1[["readmission_index"]], c(0L, 11L, 7L, 8L, 18L, 0L, 0L, 8L, 0L, 0L, 8L, 0L)))
CMRBS$elixhauser_current_1[["readmission_index"]] <- NULL

stopifnot(all(CMRBS$elixhauser_current_1 == 0))
CMRBS$elixhauser_current_1 <- NULL

################################################################################
# elixhauser_current_v
stopifnot(identical(CMRBS$elixhauser_current_v[["patid"]], expected_patid))
CMRBS$elixhauser_current_v[["patid"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_v[["encid"]], expected_encid))
CMRBS$elixhauser_current_v[["encid"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_v[["cmrb_flag"]], c(0L, 1L, 1L, 1L, 1L, 0L, 0L, 1L, 0L, 0L, 0L, 0L)))
CMRBS$elixhauser_current_v[["cmrb_flag"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_v[["num_cmrb"]], c(0L, 1L, 1L, 1L, 1L, 0L, 0L, 1L, 0L, 0L, 0L, 0L)))
CMRBS$elixhauser_current_v[["num_cmrb"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_v[["RENLFL_SEV"]], c(0L, 0L, 0L, 1L, 0L, 0L, 0L, 1L, 0L, 0L, 0L, 0L)))
CMRBS$elixhauser_current_v[["RENLFL_SEV"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_v[["HF"]], c(0L, 0L, 1L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L)))
CMRBS$elixhauser_current_v[["HF"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_v[["CANCER_METS"]], c(0L, 1L, 0L, 0L, 1L, 0L, 0L, 0L, 0L, 0L, 0L, 0L)))
CMRBS$elixhauser_current_v[["CANCER_METS"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_v[["mortality_index"]], c(0L, 22L, 14L, 7L, 22L, 0L, 0L, 7L, 0L, 0L, 0L, 0L)))
CMRBS$elixhauser_current_v[["mortality_index"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_current_v[["readmission_index"]], c(0L, 11L, 7L, 8L, 11L, 0L, 0L, 8L, 0L, 0L, 0L, 0L)))
CMRBS$elixhauser_current_v[["readmission_index"]] <- NULL

stopifnot(all(CMRBS$elixhauser_current_v == 0))
CMRBS$elixhauser_current_v <- NULL

################################################################################
# elixhauser_cumulative_0
stopifnot(identical(CMRBS$elixhauser_cumulative_0[["patid"]], expected_patid))
CMRBS$elixhauser_cumulative_0[["patid"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_0[["encid"]], expected_encid))
CMRBS$elixhauser_cumulative_0[["encid"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_0[["cmrb_flag"]], c(0L, 1L, 1L, 1L, 1L, 1L, 1L, 0L, 1L, 1L, 1L, 1L)))
CMRBS$elixhauser_cumulative_0[["cmrb_flag"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_0[["num_cmrb"]],  c(0L, 1L, 1L, 2L, 3L, 3L, 3L, 0L, 1L, 1L, 1L, 1L)))
CMRBS$elixhauser_cumulative_0[["num_cmrb"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_0[["RENLFL_SEV"]], c(0L, 0L, 0L, 0L, 1L, 1L, 1L, 0L, 1L, 1L, 1L, 1L)))
CMRBS$elixhauser_cumulative_0[["RENLFL_SEV"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_0[["HF"]], c(0L, 0L, 0L, 1L, 1L, 1L, 1L, 0L, 0L, 0L, 0L, 0L)))
CMRBS$elixhauser_cumulative_0[["HF"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_0[["CANCER_METS"]], c(0L, 1L, 1L, 1L, 1L, 1L, 1L, 0L, 0L, 0L, 0L, 0L)))
CMRBS$elixhauser_cumulative_0[["CANCER_METS"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_0[["mortality_index"]], c(0L, 22L, 22L, 36L, 43L, 43L, 43L, 0L, 7L, 7L, 7L, 7L)))
CMRBS$elixhauser_cumulative_0[["mortality_index"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_0[["readmission_index"]], c(0L, 11L, 11L, 18L, 26L, 26L, 26L, 0L, 8L, 8L, 8L, 8L)))
CMRBS$elixhauser_cumulative_0[["readmission_index"]] <- NULL

stopifnot(all(CMRBS$elixhauser_cumulative_0 == 0))
CMRBS$elixhauser_cumulative_0 <- NULL

################################################################################
# elixhauser_cumulative_1
stopifnot(identical(CMRBS$elixhauser_cumulative_1[["patid"]], expected_patid))
CMRBS$elixhauser_cumulative_1[["patid"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_1[["encid"]], expected_encid))
CMRBS$elixhauser_cumulative_1[["encid"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_1[["cmrb_flag"]], c(0L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L)))
CMRBS$elixhauser_cumulative_1[["cmrb_flag"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_1[["num_cmrb"]], c(0L, 1L, 2L, 3L, 3L, 3L, 3L, 1L, 1L, 1L, 1L, 1L)))
CMRBS$elixhauser_cumulative_1[["num_cmrb"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_1[["RENLFL_SEV"]], c(0L, 0L, 0L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L)))
CMRBS$elixhauser_cumulative_1[["RENLFL_SEV"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_1[["HF"]], c(0L, 0L, 1L, 1L, 1L, 1L, 1L, 0L, 0L, 0L, 0L, 0L)))
CMRBS$elixhauser_cumulative_1[["HF"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_1[["CANCER_METS"]], c(0L, 1L, 1L, 1L, 1L, 1L, 1L, 0L, 0L, 0L, 0L, 0L)))
CMRBS$elixhauser_cumulative_1[["CANCER_METS"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_1[["mortality_index"]], c(0L, 22L, 36L, 43L, 43L, 43L, 43L, 7L, 7L, 7L, 7L, 7L)))
CMRBS$elixhauser_cumulative_1[["mortality_index"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_1[["readmission_index"]], c(0L, 11L, 18L, 26L, 26L, 26L, 26L, 8L, 8L, 8L, 8L, 8L)))
CMRBS$elixhauser_cumulative_1[["readmission_index"]] <- NULL

stopifnot(all(CMRBS$elixhauser_cumulative_1 == 0))
CMRBS$elixhauser_cumulative_1 <- NULL

################################################################################
# elixhauser_cumulative_v
stopifnot(identical(CMRBS$elixhauser_cumulative_v[["patid"]], expected_patid))
CMRBS$elixhauser_cumulative_v[["patid"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_v[["encid"]], expected_encid))
CMRBS$elixhauser_cumulative_v[["encid"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_v[["cmrb_flag"]], c(0L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L)))
CMRBS$elixhauser_cumulative_v[["cmrb_flag"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_v[["num_cmrb"]], c(0L, 1L, 2L, 3L, 3L, 3L, 3L, 1L, 1L, 1L, 1L, 1L)))
CMRBS$elixhauser_cumulative_v[["num_cmrb"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_v[["RENLFL_SEV"]], c(0L, 0L, 0L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L)))
CMRBS$elixhauser_cumulative_v[["RENLFL_SEV"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_v[["HF"]], c(0L, 0L, 1L, 1L, 1L, 1L, 1L, 0L, 0L, 0L, 0L, 0L)))
CMRBS$elixhauser_cumulative_v[["HF"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_v[["CANCER_METS"]], c(0L, 1L, 1L, 1L, 1L, 1L, 1L, 0L, 0L, 0L, 0L, 0L)))
CMRBS$elixhauser_cumulative_v[["CANCER_METS"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_v[["mortality_index"]], c(0L, 22L, 36L, 43L, 43L, 43L, 43L, 7L, 7L, 7L, 7L, 7L)))
CMRBS$elixhauser_cumulative_v[["mortality_index"]] <- NULL
stopifnot(identical(CMRBS$elixhauser_cumulative_v[["readmission_index"]], c(0L, 11L, 18L, 26L, 26L, 26L, 26L, 8L, 8L, 8L, 8L, 8L)))
CMRBS$elixhauser_cumulative_v[["readmission_index"]] <- NULL

stopifnot(all(CMRBS$elixhauser_cumulative_v == 0))
CMRBS$elixhauser_cumulative_v <- NULL

################################################################################
#summary(CMRBS)

stopifnot(identical(length(CMRBS), 0L))

################################################################################
#                                 End of File                                  #
################################################################################
