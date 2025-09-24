# test the construction and results of the icd to pccc mappings.  the code to
# build the data sets is in
# inst/mappings/icd-codes-and-mappings.R
#
# ANY CHANGES IN THE CODES AND THESE TESTS MAY IMPACT THE WRITE UP AND THESE TESTS
if (!requireNamespace("data.table", quietly = TRUE)) {
  message("SKIP: data.table not available; skipping test-pccc-deltas.R")
  quit(save = "no", status = 0, runLast = FALSE)
}

#
library(medicalcoder)
library(data.table)
setDTthreads(threads = 1L) # to prevent CPU time exceeding elapsed time on CRAN

source(
  system.file("mappings", "icd-codes-and-mappings.R", package = "medicalcoder"),
  verbose = interactive()
)

stopifnot("pccc_deltas" %in% ls())
stopifnot("pccc_pers" %in% ls())

# Expected counts in pccc_pers
stopifnot(
  pccc_pers[per ==  1, N == 198439],
  pccc_pers[per ==  2, N ==      3],
  pccc_pers[per ==  3, N ==      0],
  pccc_pers[per ==  4, N ==      0],
  pccc_pers[per ==  5, N ==      7],
  pccc_pers[per ==  6, N ==     37],
  pccc_pers[per ==  7, N ==    962],
  pccc_pers[per ==  8, N ==      0],
  pccc_pers[per ==  9, N ==     47],
  pccc_pers[per == 10, N ==      0],
  pccc_pers[per == 11, N ==      0],
  pccc_pers[per == 12, N ==      0],
  pccc_pers[per == 13, N ==      0],
  pccc_pers[per == 14, N ==      0],
  pccc_pers[per == 15, N ==      0],
  pccc_pers[per == 16, N ==     49],
  pccc_pers[per == 17, N ==      0],
  pccc_pers[per == 18, N ==      0],
  pccc_pers[per == 19, N ==      0],
  pccc_pers[per == 20, N ==      0],
  pccc_pers[per == 21, N ==      0],
  pccc_pers[per == 22, N ==      0],
  pccc_pers[per == 23, N ==      0],
  pccc_pers[per == 24, N ==      0],
  pccc_pers[per == 25, N ==      0],
  pccc_pers[per == 26, N ==      0],
  pccc_pers[per == 27, N ==      0],
  pccc_pers[per == 28, N ==      7],
  pccc_pers[per == 29, N ==      0],
  pccc_pers[per == 30, N ==      0],
  pccc_pers[per == 31, N ==      0],
  pccc_pers[per == 32, N ==      0],
  pccc_pers[per == 33, N ==      0],
  pccc_pers[per == 34, N ==     24],
  pccc_pers[per == 35, N ==      0],
  pccc_pers[per == 36, N ==      4],
  pccc_pers[per == 37, N ==      0],
  pccc_pers[per == 38, N ==      0],
  pccc_pers[per == 39, N ==      0],
  pccc_pers[per == 40, N ==      0],
  pccc_pers[per == 41, N ==      1],
  pccc_pers[per == 42, N ==      0],
  pccc_pers[per == 43, N ==     64],
  pccc_pers[per == 44, N ==      0],
  pccc_pers[per == 45, N ==   1032],
  pccc_pers[per == 46, N ==      0],
  pccc_pers[per == 47, N ==      3],
  pccc_pers[per == 48, N ==     25],
  pccc_pers[per == 49, N ==      0],
  pccc_pers[per == 50, N ==      0],
  pccc_pers[per == 51, N ==      3],
  pccc_pers[per == 52, N ==   5451]
)

# Expected counts in pccc_deltas, this should be the same as pccc_pers, but you
# need to count the rows.
stopifnot(
  pccc_deltas[per ==  1, .N == 198439],
  pccc_deltas[per ==  2, .N ==      3],
  pccc_deltas[per ==  3, .N ==      0],
  pccc_deltas[per ==  4, .N ==      0],
  pccc_deltas[per ==  5, .N ==      7],
  pccc_deltas[per ==  6, .N ==     37],
  pccc_deltas[per ==  7, .N ==    962],
  pccc_deltas[per ==  8, .N ==      0],
  pccc_deltas[per ==  9, .N ==     47],
  pccc_deltas[per == 10, .N ==      0],
  pccc_deltas[per == 11, .N ==      0],
  pccc_deltas[per == 12, .N ==      0],
  pccc_deltas[per == 13, .N ==      0],
  pccc_deltas[per == 14, .N ==      0],
  pccc_deltas[per == 15, .N ==      0],
  pccc_deltas[per == 16, .N ==     49],
  pccc_deltas[per == 17, .N ==      0],
  pccc_deltas[per == 18, .N ==      0],
  pccc_deltas[per == 19, .N ==      0],
  pccc_deltas[per == 20, .N ==      0],
  pccc_deltas[per == 21, .N ==      0],
  pccc_deltas[per == 22, .N ==      0],
  pccc_deltas[per == 23, .N ==      0],
  pccc_deltas[per == 24, .N ==      0],
  pccc_deltas[per == 25, .N ==      0],
  pccc_deltas[per == 26, .N ==      0],
  pccc_deltas[per == 27, .N ==      0],
  pccc_deltas[per == 28, .N ==      7],
  pccc_deltas[per == 29, .N ==      0],
  pccc_deltas[per == 30, .N ==      0],
  pccc_deltas[per == 31, .N ==      0],
  pccc_deltas[per == 32, .N ==      0],
  pccc_deltas[per == 33, .N ==      0],
  pccc_deltas[per == 34, .N ==     24],
  pccc_deltas[per == 35, .N ==      0],
  pccc_deltas[per == 36, .N ==      4],
  pccc_deltas[per == 37, .N ==      0],
  pccc_deltas[per == 38, .N ==      0],
  pccc_deltas[per == 39, .N ==      0],
  pccc_deltas[per == 40, .N ==      0],
  pccc_deltas[per == 41, .N ==      1],
  pccc_deltas[per == 42, .N ==      0],
  pccc_deltas[per == 43, .N ==     64],
  pccc_deltas[per == 44, .N ==      0],
  pccc_deltas[per == 45, .N ==   1032],
  pccc_deltas[per == 46, .N ==      0],
  pccc_deltas[per == 47, .N ==      3],
  pccc_deltas[per == 48, .N ==     25],
  pccc_deltas[per == 49, .N ==      0],
  pccc_deltas[per == 50, .N ==      0],
  pccc_deltas[per == 51, .N ==      3],
  pccc_deltas[per == 52, .N ==   5451]
)

# Verify the per_desc are as expected.
stopifnot(
  pccc_deltas[per ==  1, per_desc == "[v2.0, v2.1, v3.0, v3.1]"],
  pccc_deltas[per ==  2, per_desc == "[v2.0, v2.1, v3.0]; \\{v3.1\\}"],
  pccc_deltas[per ==  3, per_desc == "[v2.0, v2.1, v3.1]; \\{v3.0\\}"],
  pccc_deltas[per ==  4, per_desc == "[v2.0, v3.0, v3.1]; \\{v2.1\\}"],
  pccc_deltas[per ==  5, per_desc == "[v2.1, v3.0, v3.1]; \\{v2.0\\}"],
  pccc_deltas[per ==  6, per_desc == "[v2.0, v2.1]; \\{v3.0\\}; \\{v3.1\\}"],
  pccc_deltas[per ==  8, per_desc == "[v2.0], \\{v2.1\\}; [v3.0]; \\{v3.1\\}"],
  pccc_deltas[per ==  7, per_desc == "[v2.0, v2.1]; \\{v3.0, v3.1\\}"],
  pccc_deltas[per ==  9, per_desc == "[v2.0, v3.0]; \\{v2.1, v3.1\\}"],
  pccc_deltas[per == 10, per_desc == "[v2.0, v3.1]; \\{v2.1\\}; \\{v3.0\\}"],
  pccc_deltas[per == 11, per_desc == "[v2.0]; \\{v2.1\\}; \\{v3.0\\}; \\{v3.1\\}"],
  pccc_deltas[per == 12, per_desc == "[v2.0]; \\{v2.1\\}; \\{v3.0, v3.1\\}"],
  pccc_deltas[per == 13, per_desc == "[v2.0]; \\{v2.1, v3.1\\}, \\{v3.0\\}"],
  pccc_deltas[per == 14, per_desc == "[v2.0, v3.1]; \\{v2.1, v3.0\\}"],
  pccc_deltas[per == 15, per_desc == "[v2.0]; \\{v2.1, v3.0\\}, \\{v3.1\\}"],
  pccc_deltas[per == 16, per_desc == "[v2.0]; \\{v2.1, v3.0, v3.1\\}"],
  pccc_deltas[per == 17, per_desc == "\\{v2.0\\}; [v2.1, v3.0], \\{v3.1\\}"],
  pccc_deltas[per == 18, per_desc == "\\{v2.0, v3.1\\}; [v2.1, v3.0]"],
  pccc_deltas[per == 19, per_desc == "\\{v2.0\\}; [v2.1, v3.1]; \\{v3.0\\}"],
  pccc_deltas[per == 20, per_desc == "\\{v2.0\\}; [v2.1], \\{v3.0\\}, \\{v3.1\\}"],
  pccc_deltas[per == 21, per_desc == "\\{v2.0\\}; [v2.1], \\{v3.0, v3.1\\}"],
  pccc_deltas[per == 22, per_desc == "\\{v2.0, v3.1\\}; [v2.1], \\{v3.0\\}"],
  pccc_deltas[per == 23, per_desc == "\\{v2.0, v3.0\\}; [v2.1, v3.1]"],
  pccc_deltas[per == 24, per_desc == "\\{v2.0, v3.0\\}; [v2.1]; \\{v3.1\\}"],
  pccc_deltas[per == 25, per_desc == "\\{v2.0, v3.0, v3.1\\}; [v2.1]"],
  pccc_deltas[per == 26, per_desc == "\\{v2.0\\}; \\{v2.1\\}; [v3.0, v3.1]"],
  pccc_deltas[per == 27, per_desc == "\\{v2.0\\}; \\{v2.1\\}; [v3.0], \\{v3.1\\}"],
  pccc_deltas[per == 28, per_desc == "\\{v2.0\\}; \\{v2.1, v3.1\\}; [v3.0]"],
  pccc_deltas[per == 29, per_desc == "\\{v2.0, v3.1\\}; \\{v2.1\\} [v3.0]"],
  pccc_deltas[per == 30, per_desc == "\\{v2.0\\}; \\{v2.1\\}; \\{v3.0\\}, [v3.1]"],
  pccc_deltas[per == 31, per_desc == "\\{v2.0\\}; \\{v2.1, v3.0\\}; [v3.1]"],
  pccc_deltas[per == 32, per_desc == "\\{v2.0\\}; \\{v2.1\\}; \\{v3.0\\}; \\{v3.1\\}"],
  pccc_deltas[per == 33, per_desc == "\\{v2.0\\}; \\{v2.1\\}; \\{v3.0, v3.1\\}"],
  pccc_deltas[per == 34, per_desc == "\\{v2.0\\}; \\{v2.1, v3.1\\}; \\{v3.0\\}"],
  pccc_deltas[per == 35, per_desc == "\\{v2.0\\}; \\{v2.1, v3.0\\}; \\{v3.1\\}"],
  pccc_deltas[per == 36, per_desc == "\\{v2.0\\}; \\{v2.1, v3.0, v3.1\\}"],
  pccc_deltas[per == 37, per_desc == "\\{v2.0, v3.1\\}; \\{v2.1\\}; \\{v3.0\\}"],
  pccc_deltas[per == 38, per_desc == "\\{v2.0, v3.1\\}, \\{v2.1, v3.0\\}"],
  pccc_deltas[per == 39, per_desc == "\\{v2.0, v3.0\\}, \\{v2.1\\}; [v3.1]"],
  pccc_deltas[per == 40, per_desc == "\\{v2.0, v3.0\\}; \\{v2.1\\}; \\{v3.1\\}"],
  pccc_deltas[per == 41, per_desc == "\\{v2.0, v3.0\\}; \\{v2.1, v3.1\\}"],
  pccc_deltas[per == 42, per_desc == "\\{v2.0, v3.0, v3.1\\}; \\{v2.1\\}"],
  pccc_deltas[per == 43, per_desc == "\\{v2.0, v2.1\\}, [v3.0, v3.1]"],
  pccc_deltas[per == 44, per_desc == "\\{v2.0, v2.1\\}; [v3.0]; \\{v3.1\\}"],
  pccc_deltas[per == 45, per_desc == "\\{v2.0, v2.1, v3.1\\}; [v3.0]"],
  pccc_deltas[per == 46, per_desc == "\\{v2.0, v2.1\\}; \\{v3.0\\}, [v3.1]"],
  pccc_deltas[per == 47, per_desc == "\\{v2.0, v2.1\\}; \\{v3.0\\}; \\{v3.1\\}"],
  pccc_deltas[per == 48, per_desc == "\\{v2.0, v2.1\\}; \\{v3.0, v3.1\\}"],
  pccc_deltas[per == 49, per_desc == "\\{v2.0, v2.1, v3.1\\}; \\{v3.0\\}"],
  pccc_deltas[per == 50, per_desc == "\\{v2.0, v2.1, v3.0\\}; [v3.1]"],
  pccc_deltas[per == 51, per_desc == "\\{v2.0, v2.1, v3.0\\}; \\{v3.1\\}"],
  pccc_deltas[per == 52, per_desc == "\\{v2.0, v2.1, v3.0, v3.1\\}"]
)

# Tests related to PER 1
# All ICD-10 codes starting with a D mapping to a condition are diagnostic
# codes.  There are ICD-10 procedure codes starting with D which should not be
# in any mapping.
stopifnot(
  pccc_deltas[per != 1 & icdv == 10 & dx == 0 & grepl("^D", code), .N == 0]
)

# Tests related to PER 2
# for per 2 verify that the codes are as expected
stopifnot(pccc_deltas[per == 2, full_code == c("E72.530", "E72.538", "E72.539")])

# Tests related to PER 3

# Tests related to PER 4
# for per 4 verify that the codes are as expected
stopifnot(pccc_deltas[per == 4, full_code == c("56.7")])

# Tests related to PER 5

# Tests related to PER 6
stopifnot(
  pccc_deltas[per == 6, all(pccc_v3.1 == "cvd (other); neuromusc (occlusion_of_cerebral_arteries)")],
  pccc_deltas[per == 6, all(pccc_v3.0 == "neuromusc (occlusion_of_cerebral_arteries)")]
)

# Tests related to PER 7

# Tests related to PER 8

# Tests related to PER 9

# Tests related to PER 10

# Tests related to PER 11

# Tests related to PER 12

# Tests related to PER 13

# Tests related to PER 14

# Tests related to PER 15

# Tests related to PER 16

# Tests related to PER 17

# Tests related to PER 18

# Tests related to PER 19

# Tests related to PER 20

# Tests related to PER 21

# Tests related to PER 22

# Tests related to PER 23

# Tests related to PER 24

# Tests related to PER 25

# Tests related to PER 26

# Tests related to PER 27

# Tests related to PER 28

# Tests related to PER 29

# Tests related to PER 30

# Tests related to PER 31

# Tests related to PER 32

# Tests related to PER 33

# Tests related to PER 34

# Tests related to PER 35

# Tests related to PER 36

# Tests related to PER 37

# Tests related to PER 38

# Tests related to PER 39

# Tests related to PER 40

# Tests related to PER 41

# Tests related to PER 42

# Tests related to PER 43
not_documented_in_eTable3_per43 <-
  c("737.3",  # header that needs to be omitted because 737.3[049] were removed from V3
    "02H70KZ", # possible typo in eTable3 - might have needed to be 02H70JZ
    "02UA0JZ", # possible typo in eTable3 - might have needed to be 02UA07Z
    "C97",   # not a CMS code, in cdc_mortality and WHO
    "D84", # headers and multiple subconditions
    "D86", "D86.8", # headers and multiple subconditions
    "E88", "E88.8", "E88.82", "E88.A", # headers and multiple subconditions
    "G25.4",
    "G31.8",
    "G31.80",
    "G31.86",
    "G31.87",
    "G80",
    "M41.2",  # omit this header - all other codes removed from v3
    "M41.8",  # omit this header - all other codes removed from v3
    "P21.0",  # not a cms code - is in cdc mortality and who
    "P21.9",  # not a cms code - is in cdc mortality and who
    "P84",
    "Q43", "Q43.0", # not in the mappings for v3.0 -- that appears to be an missing code from v3 documents
    "T84.049A" # not in eTable3, but should likely be omitted from v3 based on similarity to other codes.
  )

#"M41.34",   # documented in eTable3 but not in this per
#"M41.35",   # documented in eTable3 but not in this per

documented_in_eTable3_per43 <-
  c(
    "737.30",
    "737.34",
    "737.39",
    "770.4",
    "G25.3",
    "G40.301",
    "M41.20",
    "M41.22",
    "M41.23",
    "M41.24",
    "M41.25",
    "M41.26",
    "M41.27",
    "M41.30",
    "M41.80",
    "M41.82",
    "M41.83",
    "M41.84",
    "M41.85",
    "M41.86",
    "M41.87",
    "M41.9",
    "P28.0",
    "T84.019A",
    "T84.029A",
    "T84.039A",
    "T84.059A",
    "T84.069A",
    "T84.099A",
    "T84.119A",
    "T84.129A",
    "T84.199A",
    "T84.498A",
    "T84.50XA",
    "T84.60XA",
    "T84.7XXA",
    "T85.79XA",
    "Z46.6",
    "Z95.9")

stopifnot(
  pccc_deltas[per == 43][, all(documented_in_eTable3_per43 %in% full_code)]
  ,
  pccc_deltas[per == 43][, all(not_documented_in_eTable3_per43 %in% full_code)]
  ,
  pccc_deltas[per == 43][, all(full_code %in% c(not_documented_in_eTable3_per43, documented_in_eTable3_per43))]
)

# Tests related to PER 44

# Tests related to PER 45

# Tests related to PER 46

# Tests related to PER 47

# Tests related to PER 48

# Tests related to PER 49

# Tests related to PER 50

# Tests related to PER 51

# Tests related to PER 52

################################################################################
#                                 End of File                                  #
################################################################################
