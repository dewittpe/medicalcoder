################################################################################
# file: pccc/pccc_codes.R
#
# purpose: Unify PCCC version 2.x/3.x code sets with consistent conditions,
#          subconditions, and version flags.
#
# inputs:
#   ../icd/icd_codes.rds
#   ./pccc_v2.0.rds
#   ./pccc_v2.1.rds
#   ./pccc_v3.0.rds
#   ./pccc_v3.1.rds
#
# output: pccc_codes.rds, pccc_conditions.rds
#
# deps: data.table
#
# notes:
#   Collapses duplicates, ensures subconditions exist across versions, and keeps
#     tech/transplant flags aligned.
#
# idempotent: yes (deterministic merges)
################################################################################

library(data.table)

icd_codes <- readRDS("../icd/icd_codes.rds")
setDT(icd_codes)
set(icd_codes, j = "chap_id", value = NULL)
set(icd_codes, j = "subchap_id", value = NULL)

pccc_codes <-
  list(
    pccc_v2.0 = readRDS("./pccc_v2.0.rds"),
    pccc_v2.1 = readRDS("./pccc_v2.1.rds"),
    pccc_v3.0 = readRDS("./pccc_v3.0.rds"),
    pccc_v3.1 = readRDS("./pccc_v3.1.rds")
  ) |>
  lapply(setDT) |>
  rbindlist(idcol = "version", use.names = TRUE, fill = TRUE)

pccc_codes <- pccc_codes[, .(icdv, dx, code, condition, subcondition, tech_dep_flag, transplant_flag, version, dummy = 1L)]
pccc_codes <- unique(pccc_codes)

stopifnot("all subconditions are in all versions" =
  pccc_codes[, .(n = uniqueN(version),
                 vs = paste(sort(unique(version)), collapse = ", ")
                 ), by = .(condition, subcondition)
  ][, all(n == 4)]
)

pccc_codes <-
  dcast(pccc_codes,
        icdv + dx + code + condition + subcondition + tech_dep_flag + transplant_flag ~ version,
        value.var = "dummy")

pccc_codes[, pccc_v2.0 := nafill(pccc_v2.0, fill = 0L, type = "const")]
pccc_codes[, pccc_v2.1 := nafill(pccc_v2.1, fill = 0L, type = "const")]
pccc_codes[, pccc_v3.0 := nafill(pccc_v3.0, fill = 0L, type = "const")]
pccc_codes[, pccc_v3.1 := nafill(pccc_v3.1, fill = 0L, type = "const")]
pccc_codes <- unique(pccc_codes)

# Look for unexpected duplicated codes
v2.0 <- pccc_codes[pccc_v2.0 == 1][, N := .N, by = .(icdv, dx, code)][!is.na(N)]
stopifnot(all(v2.0$N <= 2))

v2.1 <- pccc_codes[pccc_v2.1 == 1][, N := .N, by = .(icdv, dx, code)][!is.na(N)]
stopifnot(all(v2.1$N <= 2))

v3.0 <- pccc_codes[pccc_v3.0 == 1][, N := .N, by = .(icdv, dx, code)][!is.na(N)]
stopifnot(all(v3.0$N <= 2))

v3.1 <- pccc_codes[pccc_v3.1 == 1][, N := .N, by = .(icdv, dx, code)][!is.na(N)]
stopifnot(all(v3.1$N <= 2))

################################################################################
# pccc conditions
# start with the common conditions between v2 and v3 and then add on the
# specific ones needed for each version

# check that the conditions are as expected
cnds <- sort(unique(pccc_codes$condition))
stopifnot(length(cnds) == 11,
          isTRUE(cnds[ 1] == "congeni_genetic"),
          isTRUE(cnds[ 2] == "cvd"),
          isTRUE(cnds[ 3] == "gi"),
          isTRUE(cnds[ 4] == "hemato_immu"),
          isTRUE(cnds[ 5] == "malignancy"),
          isTRUE(cnds[ 6] == "metabolic"),
          isTRUE(cnds[ 7] == "misc"),
          isTRUE(cnds[ 8] == "neonatal"),
          isTRUE(cnds[ 9] == "neuromusc"),
          isTRUE(cnds[10] == "renal"),
          isTRUE(cnds[11] == "respiratory"))

# Check that the list of unique subconditions are as expected
subcnds <- sort(unique(pccc_codes$subcondition))
stopifnot(isTRUE(identical(subcnds,
c("acquired immunodeficiency", "amino acid metabolism", "aplastic anemias",
"birth asphyxia", "bone and joint anomalies", "brain and spinal cord malformations",
"carbohydrate metabolism", "cardiomyopathies", "cerebral hemorrhage at birth",
"chromosomal anomalies", "chronic bladder diseases", "chronic liver disease and cirrhosis",
"chronic renal failure", "chronic respiratory diseases", "cns degeneration and diseases",
"coagulation/hemorrhagic", "conduction disorder", "congenital anomalies",
"cystic fibrosis", "device and technology use", "diaphragm and abdominal wall anomalies",
"diffuse diseases of connective tissue", "dysrhythmias", "endocardium diseases",
"endocrine disorders", "epilepsy", "extreme immaturity", "fetal malnutrition",
"heart and great vessel malformations", "hemophagocytic syndromes",
"hereditary anemias", "hereditary immunodeficiency", "hypoxic-ischemic encephalopathy",
"infantile cerebral palsy", "inflammatory bowel disease", "intellectual disabilities",
"leukopenia", "lipid metabolism", "movement diseases", "muscular dystrophies and myopathies",
"neoplasms", "occlusion of cerebral arteries", "other", "other congenital anomalies",
"other metabolic disorders", "other neurologic disorders", "polyarteritis nodosa and related conditions",
"respiratory diseases", "respiratory malformations", "sarcoidosis",
"spinal cord injury at birth", "storage disorders", "transplantation"
))))

# set the subcondtions to syntax valid
pccc_codes[, subcondition := gsub(" ", "_", subcondition)]
pccc_codes[, subcondition := gsub("-", "_", subcondition)]
pccc_codes[, subcondition := gsub("/", "_", subcondition)]
stopifnot(all(make.names(pccc_codes$subcondition)  == pccc_codes$subcondition))

# build one data.frame for these
pccc_conditions <- unique(pccc_codes[, .(condition, subcondition)])

pccc_conditions[, condition_label :=
  data.table::fcase(pccc_conditions[["condition"]] == "neuromusc",       "Neurologic or Neuromuscular",
                    pccc_conditions[["condition"]] == "cvd",             "Cardiovascular",
                    pccc_conditions[["condition"]] == "respiratory",     "Respiratory",
                    pccc_conditions[["condition"]] == "renal",           "Renal Urologic",
                    pccc_conditions[["condition"]] == "gi",              "Gastrointestinal",
                    pccc_conditions[["condition"]] == "hemato_immu",     "Hematologic or Immunologic",
                    pccc_conditions[["condition"]] == "metabolic",       "Metabolic",
                    pccc_conditions[["condition"]] == "congeni_genetic", "Other Congenital or Genetic Defect",
                    pccc_conditions[["condition"]] == "malignancy",      "Malignancy",
                    pccc_conditions[["condition"]] == "neonatal",        "Premature & Neonatal",
                    pccc_conditions[["condition"]] == "misc",            "Miscellaneous, Not Elsewhere Classified",
                    default = NA_character_)]
#    "Transplant"                 = "transplant",
#    "Technology dependence"      = "tech_dep")
capitalize_words <- function(x) {
  sapply(strsplit(x, " "), function(words) {
    paste(toupper(substring(words, 1, 1)), tolower(substring(words, 2)), sep = "", collapse = " ")
  })
}
pccc_conditions[, subcondition_label := gsub("_", " ", subcondition)]
pccc_conditions[, subcondition_label := capitalize_words(subcondition_label)]

################################################################################
# save to disk
pccc_codes <-
  merge(x = pccc_codes,
        y = icd_codes,
        by = c("icdv", "dx", "code"))
set(pccc_codes, j = "icdv", value = NULL)
set(pccc_codes, j = "dx", value = NULL)
set(pccc_codes, j = "code", value = NULL)
set(pccc_codes, j = "full_code", value = NULL)

setcolorder(pccc_codes, c("code_id", "condition", "subcondition", "transplant_flag", "tech_dep_flag", "pccc_v3.1", "pccc_v3.0", "pccc_v2.1", "pccc_v2.0"))

setDF(pccc_codes)
saveRDS(pccc_codes, "pccc_codes.rds")

setDF(pccc_conditions)
saveRDS(pccc_conditions, "pccc_conditions.rds")
################################################################################
#                                 End of File                                  #
################################################################################
