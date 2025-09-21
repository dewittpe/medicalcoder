################################################################################
# file: pccc/pccc_v2.0.R
#
# purpose: Recreate the pccc 1.0.6 classification outputs using database joins
#          for reproducibility.
#
# inputs:
#   ../icd/icd_codes.rds
#   ./pccc_v2_subconditions.rds
#   pccc package version 1.0.6 installed
#
# output: pccc_v2.0.rds
#
# deps: data.table, pccc
#
# notes:
#   Validates reproduction of the original pccc 1.0.6 behaviour before applying
#     v2.1 enhancements.
#
# idempotent: yes (deterministic given fixed package version)
################################################################################

################################################################################
# file: pccc_v2.0.R
#
# Generate a code set that will perfectly reproduce the results from pccc_1.0.6
#
library(data.table)
library(pccc)
stopifnot(packageVersion("pccc") == "1.0.6")

icd_codes <- readRDS("../icd/icd_codes.rds")
setDT(icd_codes)
set(icd_codes, j = "chap_id", value = NULL)
set(icd_codes, j = "subchap_id", value = NULL)

subconditions <- readRDS("pccc_v2_subconditions.rds")
setDT(subconditions)

# pccc_1.0.6 requires the input to be in a wide format and can only apply logic
# for ICD-9 or ICD-10 in one call.  Split the codes into the four sets ICD-9-CM,
# ICD-9-PCS, ICD-10-CM, and ICD-10-PCS.  Apply pccc::ccc to each and bind the
# results so we know when ICD codes map to which conditions.
pccc_v2.0 <- rbind(
  pccc::ccc(data = icd_codes[icdv ==  9 & dx == 1, .(code_id,  code)],
             id = code_id, dx_cols = "code", icdv = 9)
  ,
  pccc::ccc(data = icd_codes[icdv ==  9 & dx == 0, .(code_id,  code)],
             id = code_id, pc_cols = "code", icdv = 9)
  ,
  pccc::ccc(data = icd_codes[icdv ==  10 & dx == 1, .(code_id,  code)],
             id = code_id, dx_cols = "code", icdv = 10)
  ,
  pccc::ccc(data = icd_codes[icdv ==  10 & dx == 0, .(code_id,  code)],
             id = code_id, pc_cols = "code", icdv = 10)
)

pccc_v2.0 <-
  melt(pccc_v2.0,
       id.vars = "code_id",
       measure.vars = c("neuromusc", "cvd", "respiratory", "renal",
                        "gi", "hemato_immu", "metabolic", "congeni_genetic",
                        "malignancy", "neonatal", "tech_dep", "transplant"),
       variable.name = "condition",
       variable.factor = FALSE
  )

pccc_v2.0 <- pccc_v2.0[value == 1]
set(pccc_v2.0, j = "value", value = NULL)

# Add on the subconditions
pccc_v2.0 <-
  merge(x = pccc_v2.0,
        y = subconditions[, .(code_id, condition, subcondition)],
        all.x = TRUE,
        all.y = FALSE,
        by = c("code_id", "condition"))

# build tech dep and transplant flags
set(pccc_v2.0, j = "tech_dep_flag", value = 0L)
set(pccc_v2.0, j = "transplant_flag", value = 0L)
pccc_v2.0[condition == "transplant", `:=`(condition = "misc", subcondition = "transplantation", transplant_flag = 1L, tech_dep_flag = 0L)]
pccc_v2.0[condition == "tech_dep",   `:=`(condition = "misc", subcondition = "device & technology use", transplant_flag = 0L, tech_dep_flag = 1L)]
pccc_v2.0[subcondition == "transplantation", transplant_flag := 1L]
pccc_v2.0[subcondition == "device & technology use", tech_dep_flag := 1L]

pccc_v2.0[, tech_dep_flag := max(tech_dep_flag), by = .(code_id)]
pccc_v2.0[, transplant_flag := max(transplant_flag), by = .(code_id)]

pccc_v2.0 <- unique(pccc_v2.0)

# verify that only device and transplantation for condition misc
if (interactive()) {
  pccc_v2.0[condition == "misc", .N, by = .(subcondition)]
}
stopifnot(pccc_v2.0[condition == "misc", all(subcondition %in% c("device & technology use", "transplantation"))])

# Omit rows for misc (device & technology use) if the code maps to another
# condition with the device & technology use subcondition
non_misc_code_ids <- pccc_v2.0[condition != "misc" & subcondition == "device & technology use", code_id]
    misc_code_ids <- pccc_v2.0[condition == "misc" & subcondition == "device & technology use", code_id]
pccc_v2.0 <-
  pccc_v2.0[!(code_id %in% intersect(non_misc_code_ids, misc_code_ids) & condition == "misc" & subcondition == "device & technology use")]

# Omit rows for misc (transplantation) if the code maps to another
# condition with the device & technology use subcondition
non_misc_code_ids <- pccc_v2.0[condition != "misc" & subcondition == "transplantation", code_id]
    misc_code_ids <- pccc_v2.0[condition == "misc" & subcondition == "transplantation", code_id]
pccc_v2.0 <-
  pccc_v2.0[!(code_id %in% intersect(non_misc_code_ids, misc_code_ids) & condition == "misc" & subcondition == "transplantation")]

# for the codes that appear twice, most of these should be a non-misc condition
# followed by a misc condition.  There are some misc condition rows as the codes
# map to both tech_dep and transplant.
#
# add a column "allmisc" to quickly identify the case of duplicated code with
# only a misc condition
pccc_v2.0[, allmisc := all(condition == "misc"), by = .(code_id)]
pccc_v2.0[, N := .N, by = .(code_id)]

set(pccc_v2.0, j = "N", value = NULL)
set(pccc_v2.0, j = "allmisc", value = NULL)

# merge on the icd codes and find the subcondition for anything that isn't
# already figured out or document the problem.
pccc_v2.0 <-
  merge(x = pccc_v2.0,
        y = icd_codes,
        all.x = TRUE,
        all.y = FALSE,
        by = "code_id")

# ICD-9-CM V53.91 "Fitting and adjustment of insulin pump"
# This is listed in the documentation as metabolic (devices) by has been
# implanted in R as metabolic (transplant).  One major issue with this error is
# that there are no codes for metabolic (transplant). It doesn't make since to
# retain this error so, method=pccc_v2.0 will differ from the R package
# pccc_1.0.6 for this code.

# ICD-9-CM 253.9
#
# V2 documentation has 235.9 listed as metabolic
# V2 documentation does not map 253.9.
# However, in the documentation the codes 253.[2,5,6] and then 235.9 are listed
# for metabolic which suggests that 235.9 is a typeo.
#
# Then again, 253.9 is listed in the R code for metabolic and 235.9 is not in
# the R code.  The opposite is true for SAS and Stata sources.
#
# There are other 253.\\d codes mapping to metabolic in all three languages.
#
# V3 documentation only complicates this more with 235.9 mapping to malignancy
# and 253.9 mapping to metabolic.
#
#     icdv    dx full_code   code    src assignable_start assignable_end                                                                       desc desc_start desc_end
#    <int> <int>    <char> <char> <char>            <int>          <int>                                                                     <char>      <int>    <int>
# 1:     9     1     235.9   2359 cm_pcs             1997           2015                                   Other and unspecified respiratory organs       1997     2009
# 2:     9     1     235.9   2359 cm_pcs             1997           2015 Neoplasm of uncertain behavior of other and unspecified respiratory organs       2010     2015
# 3:     9     1     253.9   2539 cm_pcs             1997           2015                                                                Unspecified       1997     2009
# 4:     9     1     253.9   2539 cm_pcs             1997           2015   Unspecified disorder of the pituitary gland and its hypothalamic control       2010     2015
#
# For the objective of having pccc_v2.0 reproducing pccc_1.0.6 then keep what
# appears to be an error, 2539 mapping to metabolic.  For pccc_v2.1 map the
# 235.9 and 253.9 as will be done in V3.
pccc_v2.0[full_code == "253.9", subcondition := "endocrine disorders"]

# ICD-9-CM 277.4
# In the V2 documentation this code appears under the 'metabolic' condition,
# 'other metabolic disorders' subcondition.  It should be noted that this code
# appears in the ICD-10 column, not the ICD-9 column.  But, due to the partial
# string matching and the way codes are applied, this was still flagged.
# Several other 277 codes are in this condition so it seems reasonable.
pccc_v2.0[full_code == "277.4", subcondition := "other metabolic disorders"]

# ICD-9-CM 331
#
# This header code was flagged.  It's not explicitly in the V2 documenation.
# Due to partial string matching 331 and all descendant codes are flagged.  The
# only place in the V2 docs were 331 appear is in the 'neuromusc' condition with
# 'cns degeneration and diseases' subcondition
pccc_v2.0[grepl("^331", full_code) & icdv == 9 & dx == 1,
          subcondition := "cns degeneration and diseases"]

# ICD-9-CM 333.4
#
# Under neuromusc, movement diseases, there are several 333 codes.  "33.4" is
# there, which appears to be a typo in the docs and the reason that the merge
# above didn't map the subcondition
pccc_v2.0[full_code == "333.4", subcondition := "movement diseases"]

# ICD-9-CM 359
#
# This is a header code. It is set up in match exactly in the R code.  That is
# important because the documentation only flags neuromusc, muscular dystrophies
# and myopathies, for 359.0-359.3 were code 359.4-359.9 (some with fifth digits)
# are all valid ICD-9-CM codes.  Add the subcondition for this header code here

if (interactive()) {
  pccc_v2.0[grepl("^359", full_code)]
  #subset(lookup_icd_codes(x = "^359", regex = T, full.codes = TRUE, compact.codes = F), dx == 1)
}
pccc_v2.0[full_code == "359", subcondition := "muscular dystrophies and myopathies"]

# ICD-9-CM 416
#
# From the documentation:
# 416.2 is respiratory in the docx
# 416.1, 416.8, 416.9 are listed as cvd
# 416.0 was not listed in the docx at all.
#
# The R code as 416 as cvd (fixed so exact matching)
# 4161, 4168, 4169 for cvd
# 4160, 4162, for respiratory
#
# all the 416 codes in cvd have the subcondition "other" so use that here
pccc_v2.0[full_code == "416", subcondition := "other"]

# Since 416.0 is not in the documentation but is in the R code I can only guess
# that the subcondition should the same as 416.2 which is listed in respiratory
pccc_v2.0[full_code == "416.0", subcondition := "chronic respiratory diseases"]

# ICD-9-PCS 56.7
# The three-digit 56.7 header is listed in the documentation as renal (other)
# along with 56.71 and 56.79.  The docx lists 56.72, 56.73, 56.74, 56.75 under
# renal (device).  56.7[1-5,9] is the complete set of codes.  listing of 56.7
# for renal (other) appears to be too much.  It is also inconsistent with v3
# docs and the implimentation of pccc_1.0.6.  Omit this header code from v2.1
#
# from pccc_1.0.6 src/pccc.cpp:
#   renal: "5671","5672","5673","5674","5675","5679"  >>>> Set to renal (other)
#    tech:  5672","5673","5674","5675"                >>>> Set to renal (device and technology use)
#
if (interactive()) {
  pccc_v2.0[grepl("^567", code) & icdv == 9 & dx == 0]
}
# remove unwanted renal (device) mappings
pccc_v2.0 <- pccc_v2.0[!(grepl("^567[19]", code) & icdv == 9 & dx == 0 & grepl("device", subcondition))]
# remove unwanted renal (other)
pccc_v2.0 <- pccc_v2.0[!(grepl("^567[2345]", code) & icdv == 9 & dx == 0 & grepl("other", subcondition))]

# ICD-9-PCS 89.45
#
# Not listed in the documentation, it is listed in the procedure codes for cvd.
# Codes 89.4[6-9] are all CVD device and technology use
pccc_v2.0[full_code == "89.45",
          `:=`(condition = "cvd",
               subcondition = "device and technology use",
               tech_dep_flag = 1L)]
pccc_v2.0 <- unique(pccc_v2.0)

# ICD-9-CM V08
#
# This code is not in the documentation
#
# This is an assignable ICD-9-CM code.  The R code has this mapped to
# hemato_immu, which seems reasonable:
#
#    subset(get_icd_codes(with.description = T), code == "V08")
#          icdv dx full_code code    src known_start known_end assignable_start assignable_end                                                             desc desc_start desc_end
#    37787    9  1       V08  V08 cm_pcs        1997      2015             1997           2015 Asymptomatic human immunodeficiency virus [HIV] infection status       1997     2015
#
# Given that the ICD-10 codes for HIV/AIDS are listed with the subcondition of
# acquired immunodeficiency, I'll use that here too.
pccc_v2.0[full_code == "V08", subcondition := "acquired immunodeficiency"]

# ICD-9-CM V56 & ICD-10-CM Z49
#
# Not in the docs, in the R code for renal, all codes are related to dialysis
#    subset(get_icd_codes(with.description = T), icdv == 9 & grepl("^V56", code))
#
# I will map these codes to device and technology use
pccc_v2.0[grepl("^V56", full_code) & icdv == 9,
          `:=`(subcondition = "device and technology use",
               tech_dep_flag = 1L)]
pccc_v2.0[grepl("^Z49", full_code) & icdv == 10,
          `:=`(subcondition = "device and technology use",
               tech_dep_flag = 1L)]

# ICD-9-CM 349.1
#
# Not in the docs. Description: "Nervous system complications from surgically
# implanted device".  Map to device
#
pccc_v2.0[full_code == "349.1",
          `:=`(subcondition = "device and technology use",
               tech_dep_flag = 1L)]

# ICD-9-CM V53.3
#
# This is a header code for cvd devices
pccc_v2.0[full_code == "V53.3",
          `:=`(subcondition = "device and technology use",
               tech_dep_flag = 1L)]

# ICD-9-CM V65.46
#
# Not in the docs.  Description: encounter for insulin pump training
pccc_v2.0[full_code == "V65.46",
          `:=`(subcondition = "device and technology use",
               tech_dep_flag = 1L)]

# ICD-10-CM D00
#
# Not in the doc, but D01-D09 are.  All mapping to subcondition neoplasms
pccc_v2.0[grepl("^D00", full_code), `:=`(subcondition = "neoplasms")]

# ICD-10-CM E70.5
#
# Not in docs,
pccc_v2.0[full_code == "E70.5", subcondition := "amino acid metabolism"]

# ICD-10-CM E75
#
# This is another headache.  In the docs
# E75 maps to metabolic; lipid metabolism
# E75.[0,1,2,4] map to neuromusc; cns degeneration
#
# Given that the descriptions are
# E75: "Disorders of sphingolipid metabolism and other lipid storage disorders"
# E751: "Other and unspecified gangliosidosis"
# E752: "Other sphingolipidosis"
# E753: "Sphingolipidosis, unspecified"
# E754: "Neuronal ceroid lipofuscinosis"
#
# This really should map to both conditions.
#
# chatGPT's response to how to classify gangliosidosis:
# > Gangliosidosis is best classified as a metabolic disorder, specifically a
# > lysosomal storage disorder — a subgroup of inborn errors of metabolism.
#
# > Primary Classification: Metabolic Disorder
# >
# > Gangliosidosis results from enzyme deficiencies that impair the breakdown of
# > gangliosides in lysosomes.
# >
# > This leads to abnormal accumulation of lipids within cells, particularly
# > neurons.
# >
# > It falls under the broader umbrella of lysosomal storage diseases, which are
# > all metabolic in nature.
# >
# > Secondary Impact: Neurologic (and sometimes neuromuscular) features
# > Although primarily metabolic, gangliosidosis causes progressive neurological
# > deterioration:
# >
# > Developmental regression
# > Seizures
# > Hypotonia
# > Movement disorders
# >
# > These symptoms might overlap with neuromuscular presentations, but they are
# > secondary to the underlying metabolic defect.
pccc_v2.0[condition == "neuromusc" & grepl("^E75", full_code),
          subcondition := "cns degeneration and diseases"]

# ICD-10-CM G97.82
#
# Not in the docs, no G97 is.
# desc: "Other postprocedural complications and disorders of nervous system"
pccc_v2.0[condition == "neuromusc" & full_code == "G97.82",
          subcondition := "other disorders of the cns"]

# ICD-10-CM M43.3
#
# Errantly listed in the docs as M43.30 which is not a valid ICD-10 code.
pccc_v2.0[full_code == "M43.3",
          subcondition := "bone and joint anomalies"]

# ICD-10-CM Q89.8
#
# Only Q89.7 and Q89.9 are in the docs for congeni_genetic; other congenital
# anomalies.  Assign same subcondition
pccc_v2.0[full_code == "Q89.8",
          subcondition := "other congenital anomalies"]

# ICD-10-CM Q89.81 and Q89.89 were introduced for FY 2026, previously Q89.8 was
# the assignable code
if (interactive()) {
  icd_codes[grepl("^Q89", full_code)]
  pccc_v2.0[grepl("^Q89", full_code)]
  subset(
    merge(icd_codes,
          readRDS("../icd/known_and_assignable_start_stop.rds"),
          by = "code_id"),
    grepl("^Q89\\.8", full_code)
  )
}
pccc_v2.0[grepl("^Q89\\.8", full_code), subcondition := unique(na.omit(subcondition))]

# ICD-10-CM Z21
#
# Not in the docs,
# desc: Asymptomatic human immunodeficiency virus [HIV] infection status
pccc_v2.0[full_code == "Z21", subcondition := "acquired immunodeficiency"]

# ICD-10-CM Z79.4
#
# long term (current) use of insulin
pccc_v2.0[full_code == "Z79.4", subcondition := "endocrine disorders"]

if (interactive()) {
  #pccc_v2.0[is.na(subcondition)]
  #subconditions[orig_code == "Q21.2-Q24"]
  #pccc_v2.0[, unique(subcondition)]
  #lookup_icd_codes("^V08", regex = T)
  #subset(get_icd_codes(with.description = T), code == "Z794")
  pccc_v2.0[is.na(subcondition)]
}
stopifnot(isTRUE(!any(is.na(pccc_v2.0$subcondition))))

# clean up some of the subconditions to be consistent with other sources
pccc_v2.0[subcondition == "storage disorder", subcondition := "storage disorders"]
pccc_v2.0[subcondition == "other disorders of the cns", subcondition := "other neurologic disorders"]
pccc_v2.0[subcondition == "other disorders of cns", subcondition := "other neurologic disorders"]
pccc_v2.0[subcondition == "device & technology use",
          subcondition := "device and technology use"]
pccc_v2.0[subcondition == "mental retardation", subcondition := "intellectual disabilities"]
pccc_v2.0[subcondition == "inflammatory bowel diseases", subcondition := "inflammatory bowel disease"]
pccc_v2.0[subcondition == "diaphragm and abdominal wall", subcondition := "diaphragm and abdominal wall anomalies"]

################################################################################
pccc_v2.0[grepl("trans", subcondition) & transplant_flag == 0L, transplant_flag := 1L]
pccc_v2.0[grepl("tech", subcondition) & tech_dep_flag == 0L, tech_dep_flag := 1L]


################################################################################
setDF(pccc_v2.0)
saveRDS(pccc_v2.0, file = "pccc_v2.0.rds")

################################################################################
#                                 End of File                                  #
################################################################################
