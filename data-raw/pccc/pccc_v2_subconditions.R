################################################################################
# file: pccc/pccc_v2_subconditions.R
#
# purpose: Parse the PCCC v2 condition/subcondition Word export and map listed
#          ICD codes to the known code universe.
#
# inputs:
#   ../icd/icd_codes.rds
#   ./pccc_v2/subconditions.txt
#
# output: pccc_v2_subconditions.rds
#
# deps: data.table, pbapply, zoo
#
# notes:
#   Cleans transcription artefacts, expands code ranges with regex, and aligns
#     terminology with internal naming.
#
#   The source file .pccc_v2?subconditions.txt is the result of copying from
#     Word to Excel and exporting as a tab-delimited file.
#
# idempotent: yes (deterministic transformations)
################################################################################

library(data.table)
library(pbapply)

known_icd_codes  <- readRDS("../icd/icd_codes.rds")
setDT(known_icd_codes)

################################################################################
# subconditions - this has conditions, subconditions, ICD codes
subconditions <- read.table("pccc_v2/subconditions.txt", sep = "\t", skip = 1, header = TRUE, na.strings = "")
setDT(subconditions)
setnames(subconditions,
         old = c("Categories", "Subcategories", "ICD.9", "ICD.10"),
         new = c("condition",  "subcondition",   "icd9",  "icd10"))

subconditions[, condition    := tolower(trimws(condition))]
subconditions[, subcondition := tolower(trimws(subcondition))]

subconditions[, condition    := zoo::na.locf(condition)]
subconditions[, subcondition := zoo::na.locf(subcondition)]

# split the data and "explode" it so each code is on one row. The codes are
# expected to be in comma-separated lists. There are some edits to make for
# that to be valid.
# subconditions[grep("03.72. 03.79", icd9)]
# subconditions[grep("V46.2 81.00", icd9)]
subconditions[, icd9 := sub("03\\.72\\. 03\\.79", "03.72, 03.79", icd9)]
subconditions[, icd9 := sub("V46\\.2 81\\.00", "V46.2, 81.00", icd9)]

subconditions <- split(subconditions, by = c("condition", "subcondition"))

subconditions <-
  subconditions |>
  lapply(function(x) {
           icd9  <- trimws(strsplit(x$icd9, split = ",")[[1]])
           icd10 <- trimws(strsplit(x$icd10, split = ",")[[1]])
           data.table(condition = x$condition[1],
                      subcondition = x$subcondition[1],
                      icdv = c(rep(9L, length(icd9)), rep(10L, length(icd10))),
                      orig_code = c(icd9, icd10))
         }) |>
  rbindlist()

# remove rows that are not needed
subconditions <- subconditions[orig_code != "N/A"]
subconditions <- subconditions[orig_code != ""]

# Add a dx flag
subconditions[, dx := fcase(icdv == 10 & grepl("^\\D", orig_code), 1,
                            icdv ==  9 & grepl("^\\d{3}(\\.|$)", orig_code), 1,
                            icdv ==  9 & grepl("^\\d{3}-\\d{3}$", orig_code), 1,
                            icdv ==  9 & grepl("^V\\d{2}\\.", orig_code), 1,
                            icdv ==  9 & grepl("^\\d{2}\\.", orig_code), 0,
                            icdv == 10 & grepl("^\\d", orig_code), 0
                            )]

# use these codes to match against known codes.  Do so via regex pattern.
subconditions[, pattern := paste0("^", gsub("\\.", "", orig_code))]

# Set patterns for code ranges:
subconditions[orig_code == "042-044",         pattern := "^04[2-4]"]
subconditions[orig_code == "140-209",         pattern := "^(1[4-9]|20)"]
subconditions[orig_code == "230-239",         pattern := "^23"]
subconditions[orig_code == "270.0-270.9",     pattern := "^270"]
subconditions[orig_code == "271.0-271.9",     pattern := "^271"]
subconditions[orig_code == "272.0-272.9",     pattern := "^272"]
subconditions[orig_code == "275.0-275.3",     pattern := "^275[0-3]"]
subconditions[orig_code == "277.8-277.9",     pattern := "^277[89]"]
subconditions[orig_code == "279.0-279.9",     pattern := "^279"]
subconditions[orig_code == "282.0-282.6",     pattern := "^282[0-6]"]
subconditions[orig_code == "318.0-318.2",     pattern := "^318[012]"]
subconditions[orig_code == "330.0-330.9",     pattern := "^330"]
subconditions[orig_code == "335.0-335.9",     pattern := "^335"]
subconditions[orig_code == "343.0-343.9",     pattern := "^343"]
subconditions[orig_code == "359.0-359.3",     pattern := "^359[0-3]"]
subconditions[orig_code == "425.0-425.4",     pattern := "^425[0-4]"]
subconditions[orig_code == "426.0-427.4",     pattern := "^42(6|7[0-4])"]
subconditions[orig_code == "427.6-427.9",     pattern := "^427[6-9]"]
subconditions[orig_code == "446.4-446.7",     pattern := "^446[4-7]"]
subconditions[orig_code == "555.0-556.9",     pattern := "^55[56]"]
subconditions[orig_code == "571.4-571.9",     pattern := "^571[4-9]"]
subconditions[orig_code == "740.0-742.9",     pattern := "^74[012]"]
subconditions[orig_code == "745.0-745.3",     pattern := "^745[0-3]"]
subconditions[orig_code == "745.60-745.69",   pattern := "^7456"]
subconditions[orig_code == "747.1-747.49",    pattern := "^747[1-4]"]
subconditions[orig_code == "748.0-748.9",     pattern := "^748"]
subconditions[orig_code == "751.1-751.9",     pattern := "^751"]
subconditions[orig_code == "753.0-753.9",     pattern := "^753"]
subconditions[orig_code == "756.0-756.5",     pattern := "^756[0-5]"]
subconditions[orig_code == "758.0-758.9",     pattern := "^758"]
subconditions[orig_code == "759.7-759.9",     pattern := "^759[7-9]"]
subconditions[orig_code == "765.21-765.23",   pattern := "^7652[1-3]"]
subconditions[orig_code == "B20-B24",         pattern := "^B2[0-4]"]
subconditions[orig_code == "C00-C96",         pattern := "^C"]
subconditions[orig_code == "D01-D09",         pattern := "^D0[1-9]"]
subconditions[orig_code == "D37-D49",         pattern := "^D(3[7-9]|4)"]
subconditions[orig_code == "D55-D58",         pattern := "^D5[5-8]"]
subconditions[orig_code == "D60-D61",         pattern := "^D6[01]"]
subconditions[orig_code == "D76.1-D76.3",     pattern := "^D76[1-3]"]
subconditions[orig_code == "D80-D89",         pattern := "^D8[0-9]"]
subconditions[orig_code == "E71.0-E71.5",     pattern := "^E71[0-5]"]
subconditions[orig_code == "E72.0-E72.4",     pattern := "^E72[0-4]"]
subconditions[orig_code == "E74.0-E74.4",     pattern := "^E74[0-4]"]
subconditions[orig_code == "E76.0-E76.3",     pattern := "^E76[0-3]"]
subconditions[orig_code == "E78.0-E78.4",     pattern := "^E78[0-4]"]
subconditions[orig_code == "E78.5-E78.9",     pattern := "^E78[5-9]"]
subconditions[orig_code == "E80.4-E80.7",     pattern := "^E80[4-7]"]
subconditions[orig_code == "F71-F73",         pattern := "^F7[123]"]
subconditions[orig_code == "G11.1-G11.4",     pattern := "^G11[1-4]"]
subconditions[orig_code == "G12.0- G12.2",    pattern := "^G12[012]"]
subconditions[orig_code == "G23.0-G23.2",     pattern := "^G23[0-2]"]
subconditions[orig_code == "G25.3-G25.5",     pattern := "^G25[3-5]"]
subconditions[orig_code == "G25.81-G25.83",   pattern := "^G258[1-3]"]
subconditions[orig_code == "G82.50-G82.54",   pattern := "^G825[0-4]"]
subconditions[orig_code == "I49.1-I49.5",     pattern := "^I49[1-5]"]
subconditions[orig_code == "J95.00-J95.04",   pattern := "^J950[0-4]"]
subconditions[orig_code == "K760-K763",       pattern := "^K76[0-3]"]
subconditions[orig_code == "P07.21-P07.25",   pattern := "^P072[1-5]"]
subconditions[orig_code == "P25.0-P25.3",     pattern := "^P25[0-3]"]
subconditions[orig_code == "Q00-Q07",         pattern := "^Q0[0-7]"]
subconditions[orig_code == "Q21.2-Q24",       pattern := "^Q2(1[2-9]|2|3|4)"]
subconditions[orig_code == "Q25.1-Q26",       pattern := "^Q2(5[1-9]|6)"]
subconditions[orig_code == "Q30-Q34",         pattern := "^Q3[0-4]"]
subconditions[orig_code == "Q39.0-Q39.4",     pattern := "^Q39[0-4]"]
subconditions[orig_code == "Q41-Q45",         pattern := "^Q4[1-5]"]
subconditions[orig_code == "Q60-Q64",         pattern := "^Q6[0-4]"]
subconditions[orig_code == "Q76.0-Q76.2",     pattern := "^Q76[0-2]"]
subconditions[orig_code == "Q76.4-Q76.7",     pattern := "^Q76[4-7]"]
subconditions[orig_code == "Q78.0-Q78.4",     pattern := "^Q78[0-4]"]
subconditions[orig_code == "Q79.0-Q79.5",     pattern := "^Q79[0-5]"]
subconditions[orig_code == "Q87.1-Q87.3",     pattern := "^Q87[1-3]"]
subconditions[orig_code == "T86.00-T86.02",   pattern := "^T860[0-2]"]
subconditions[orig_code == "T86.10-T86.12",   pattern := "^T861[0-2]"]
subconditions[orig_code == "T86.20-T86.22",   pattern := "^T862[0-2]"]
subconditions[orig_code == "T86.40-T86.42",   pattern := "^T864[0-2]"]
subconditions[orig_code == "T86.90-T86.92",   pattern := "^T869[0-2]"]
subconditions[orig_code == "V44.1-V44.4",     pattern := "^V44[1-4]"]
subconditions[orig_code == "V55.1-V55.4",     pattern := "^V55[1-4]"]
subconditions[orig_code == "Z43.1-Z43.4",     pattern := "^Z43[1-4]"]
subconditions[orig_code == "Z93.1-Z93.4",     pattern := "^Z93[1-4]"]
subconditions[orig_code == "Z93.50-Z93.52",   pattern := "^Z935[0-2]"]
subconditions[orig_code == "Z95.810-Z95.812", pattern := "^Z9581[0-2]"]

# There are typeos to fix.
#
# ICD-9 code '6.88' is a miscellanceous; transplantation code.  This is not a
# valid ICD code.  However, it appears that it is a typeo.  It is listed in the
# set: "996.80, 6.88, 996.89."  That strongly suggests that the 6.88 is a typeo and
# should be 996.88. Fix this by fixing the pattern to match codes on.
if (interactive()) {
  subconditions[orig_code == "6.88"]
}
subconditions[orig_code == "6.88", `:=`(pattern = "^99688", dx = 1)]

# ICD-10-CM P25.21 and P25.22 are not valid codes, there is no fifth digit,
# replace the pattern for matching with P25.2
subconditions[orig_code == "P25.21", pattern := "^P252"]
subconditions[orig_code == "P25.22", pattern := "^P252"]

# M43.30 is not a valid ICD-10-CM code, M43.3 is.
subconditions[orig_code == "M43.30", pattern := "^M433"]

# ICD 277.4 was listed in the ICD-10 column but this is a ICD-9 code
subconditions[orig_code == "277.4", `:=`(icdv = 9L, dx = 1L)]

# ICD-10-CM G82.90
# As of FY 2025, ICD-10-CM G82.[0-5] are valid codes.  omit this record
subconditions <- subconditions[orig_code != "G82.90"]

# ICD-9-CM 428.[0-4,9] are valid ICD-9-CM codes.
# 428.8, and any fifth digit, are not a valid ICD-9-CM codes.
# Omit the row for 428.83
#subset(get_icd_codes(with.description = T), grepl("^428\\d$", code) & icdv == 9 & dx == 1)
subconditions <- subconditions[orig_code != "428.83"]

# ICD-9 "33.4" is listed as neuromuscular movement disease.
# In the docx the code "33.4" is listed in the
# set: "... 333.0, 333.2, 33.4, 333.5, ..." which suggests this could be a typeo
# In the V3 documentation it is noted that this is a typeo
subconditions[orig_code == "33.4", `:=`(icdv = 9, dx = 1, pattern = "^3334")]

# Find all the codes that match the patterns
subconditions <-
  subconditions |>
  split(f = 1:nrow(subconditions)) |>
  pblapply(function(x) {
             idx <-
               (known_icd_codes$dx == x$dx) &
               (known_icd_codes$icdv == x$icdv) &
               grepl(x$pattern, known_icd_codes$code)
             merge(x, known_icd_codes[idx, ], all = TRUE, by = c("icdv", "dx"))
           },
           cl = 8L) |>
  rbindlist()

subconditions[, condition := fcase(
  condition == "neurologic and neuromuscular",            "neuromusc",
  condition == "cardiovascular",                          "cvd",
  condition == "respiratory",                             "respiratory",
  condition == "renal and urologic",                      "renal",
  condition == "gastrointestinal",                        "gi",
  condition == "hematologic or immunologic",              "hemato_immu",
  condition == "metabolic",                               "metabolic",
  condition == "other congenital or genetic defect",      "congeni_genetic",
  condition == "malignancy",                              "malignancy",
  condition == "premature and neonatal",                  "neonatal",
  condition == "miscellaneous, not elsewhere classified", "misc")
]

################################################################################
# The subconditions
subconditions[, subcondition := trimws(subcondition)]

if (interactive()) {
  subconditions[, .N, keyby = .(subcondition)] |> print(nrow = Inf)
}

# modify the 'devices' subcondition to be more verbose
subconditions[subcondition == "devices", subcondition := "device & technology use"]

subconditions[subcondition == "bone and join anomalies",
              subcondition := "bone and joint anomalies"]

################################################################################
# look for anything that didn't map to a known icd code

if (interactive()) {
  subconditions[is.na(code)]
}
stopifnot(subconditions[, !any(is.na(code))])

################################################################################
# Save objects
setDT(subconditions)
saveRDS(subconditions, file = "pccc_v2_subconditions.rds")

################################################################################
#                                 End of File                                  #
################################################################################
