################################################################################
# file: pccc/pccc_v3.R
#
# purpose: Construct PCCC v3.0/v3.1 code tables from published Excel sources and
#          augment with inferred headers.
#
# inputs:
#   ./pccc_v3/eTable2.xlsx
#   ./pccc_v3/final-v3-with-rev-code-list-02282023.xlsx
#   ./pccc_v3/supp3.xlsx
#   ../icd/icd_codes.rds
#
# output: pccc_v3.0.rds, pccc_v3.1.rds
#
# deps: readxl, data.table, pbapply
#
# notes:
#   Applies errata (e.g., 20255 vs 20555), removes redundant misc rows, and
#     fills missing descendants via icd_codes.
#
# idempotent: yes (deterministic once sources are fixed)
################################################################################

################################################################################
# build of codes for version 3 of the pccc
#
# version 3.0 will attempt to reproduce the published sas code.
#
# version 3.1 will extend the code base
#
# THERE ARE MISSING CODES IN THE SAS CODE AND THE EXCEL FILE INFORMING THE SAS
# CODE!!!!
#
# SAS imports codes from the file ./pccc_v3/final-v3-with-rev-code-list-02282023.xlsx
#
# A simple example of a problem.  ICD-10-CMS E75.00 should map to both metabolic
# and neuromusc.  That mapping would be consisitent with the documentation for
# verion 2 and, depending on the srouce, for version 3 as well. In supp3.xlsx
# from the 2024 publication we see E7500 reported for both conditions.  E7500 is
# only mapping to metabolic in SAS code source file.
#
# This is a problem with the v2.0 as well.  v2.1 has the extended codes.
#
# For this work v3.0 will be as similar to the SAS code as possible
#
# v3.1 will be based on the codes from supp3.xlsx.
#
# Just to make this even more frustrating, the eTable3 that was sent to me seems
# to be documented by supp3.

library(readxl)
library(data.table)

################################################################################
pccc_v3.0 <-
  list(
      "eTable2" = read_xlsx("./pccc_v3/eTable2.xlsx", sheet = 2, col_types = "text")
    , "web02282023" = read_xlsx("./pccc_v3/final-v3-with-rev-code-list-02282023.xlsx", col_types = "text")
  )

pccc_v3.0 <- lapply(pccc_v3.0, as.data.table)
pccc_v3.0 <- rbindlist(pccc_v3.0, idcol = "src")

setnames(pccc_v3.0,
         old = c("ICD_Code", "ICD_Code_Description", "DX_PR", "CCC_Category", "CCC_Subcategory", "ICD9_ICD10", "Tech_Dep", "Transplant"),
         new = c("code",     "desc",                 "dxpr",  "condition",     "subcondition",     "icdv",       "tech_dep", "transplant")
         )

pccc_v3.0[icdv == "0", icdv := "10"]
pccc_v3.0[, icdv := as.integer(icdv)]
pccc_v3.0[, dx   := as.integer(tolower(dxpr) == "dx")]
pccc_v3.0[, dxpr := NULL]
pccc_v3.0[, condition := tolower(condition)]
pccc_v3.0[, subcondition := tolower(subcondition)]
pccc_v3.0[subcondition == "hypoxic-ischemia encephalopathy", subcondition := "hypoxic-ischemic encephalopathy"]

pccc_v3.0[, dummy := 1L]

pccc_v3.0 <-
  dcast(pccc_v3.0,
        code + desc + dx + condition + subcondition + icdv + tech_dep + transplant ~ src,
        value.var = "dummy",
        fill = 0L)

if (interactive()) {
  pccc_v3.0[eTable2 == 0 | web02282023 == 0]
  pccc_v3.0[code %in% c("20255", "20555")]
  ## NOTE:
  ## web version was wrong and should be updated.  just use the eTable2 version for v3
  ## From emails on 14 Nov 2024
  ##
  ## I wrote:
  ##
  ## > thank you for sending eTable2.xlsx, that was a huge help.
  ## >
  ## > The existence of ICD-9 code 20555 is not in eTable2.xlsx, but it is in the
  ## > .xlsx file that can be downloaded from the website:
  ## >
  ## > I see the code 20255 in eTable2 but 20255 is not in the
  ## > https://www.childrenshospitals.org/-/media/files/analytics/ccc/final-v3-with-rev-code-list-02282023.xlsx
  ## >
  ## > Conversely, 20555 is not in eTable2, but is in the web version.
  ## >
  ## > It looks to me that the 20555 (row 1202 of the web version) should just be
  ## > omitted and a row for 20255 should be added to the web version
  ##
  ## The reply
  ##
  ## > You are correct! It is in the website documents in error as 20555 when the
  ## > code should be 20255. I will get the website document corrected and
  ## > reloaded there. The eTable2 document is the one submitted with the
  ## > manuscript for publication so it should be the correct one.
  ## >
  ## > Thank you for bringing this to our attention.
}

pccc_v3.0 <- pccc_v3.0[eTable2 == 1]
pccc_v3.0[, eTable2 := NULL]
pccc_v3.0[, web02282023 := NULL]

pccc_v3.0[, tech_dep := as.integer(tech_dep)]
pccc_v3.0[, transplant := as.integer(transplant)]

setnames(pccc_v3.0,
         old = c("tech_dep", "transplant"),
         new = c("tech_dep_flag", "transplant_flag"))

set(pccc_v3.0, j = "desc", value = NULL)

# look at setting the condition and subcondition to be consisitent with other
# sets.  there should be a misc condition with only tech_dep and transplant
# subconditions
if (interactive()) {
  pccc_v3.0[, .N, keyby = .(condition)] |> print(nrow = Inf)
}

stopifnot(pccc_v3.0[condition == "transplant", all(is.na(subcondition))])
stopifnot(pccc_v3.0[condition == "transplant", all(transplant_flag == 1)])
pccc_v3.0[subcondition == "device & technology use", subcondition := "device and technology use"]
pccc_v3.0[subcondition == "polyarteritis nodosa & related conditions",
          subcondition := "polyarteritis nodosa and related conditions"]
pccc_v3.0[condition == "transplant", `:=`(condition = "misc", subcondition = "transplantation")]
stopifnot(pccc_v3.0[condition == "misc", all(subcondition %in% c("transplantation", "device and technology use"))])

pccc_v3.0[condition == "neonatal" & subcondition == "other premature or neonatal",
          subcondition := "other"]
pccc_v3.0[condition == "cvd" & subcondition == "other cardiovascular",
          subcondition := "other"]
pccc_v3.0[condition == "renal" & subcondition == "other renal & urologic",
          subcondition := "other"]
pccc_v3.0[condition == "gi" & subcondition == "other gi disease",
          subcondition := "other"]
pccc_v3.0[condition == "respiratory" & subcondition == "other respiratory",
          subcondition := "other"]
pccc_v3.0[condition == "hemato_immu" & subcondition == "other hematologic/immunologic",
          subcondition := "other"]

# remove the non-misc
# Codes which are device and tech in misc should only be retained if not in
# another conidtion.  same for transplant.
non_misc_tech <- pccc_v3.0[condition != "misc" & subcondition == "device and technology use"]
non_misc_tran <- pccc_v3.0[condition != "misc" & subcondition == "transplantation"]

# remove the "misc" rows
pccc_v3.0 <-
  pccc_v3.0[!(condition    ==   "misc" &
              subcondition ==   "device and technology use" &
              code         %in% non_misc_tech$code)]

pccc_v3.0 <-
  pccc_v3.0[!(condition    ==   "misc" &
              subcondition ==   "transplantation" &
              code         %in% non_misc_tran$code)]

################################################################################
# pccc v3.1
if (interactive()) {
  readxl::excel_sheets(path = "./pccc_v3/supp3.xlsx") |> dput()
}

pccc_v3.1 <-
  c("Neuro Neuromuscular",
    "Cardiovascular",
    "Respiratory",
    "Renal Urologic",
    "Gastrointestinal",
    "Hematologic Immunologic",
    "Metabolic",
    "Other Congenital Genetic Defect",
    "Malignancy",
    "Premature & Neonatal",
    "Device & Tech Use",
    "Transplant") |>
  lapply(readxl::read_xlsx,
         path = "./pccc_v3/supp3.xlsx",
         skip = 1,
         col_types = "text") |>
  rbindlist(use.names = TRUE, fill = TRUE)

set(pccc_v3.1, j = "ICDCode Description", value = NULL)

setnames(pccc_v3.1,
         old = c("ICD Code", "DX/PX", "CCC Category", "Subcategory",  "ICD9/ICD10", "Comments", "CF/JF Comments", "CCC Code Type"),
         new = c("code",     "dxpr",  "condition",    "subcondition", "icdv",       "comments", "cfjf_comments",  "ccc_code_type")
         )

set(pccc_v3.1, j = "dx", value = as.integer(pccc_v3.1$dxpr == "DX"))
set(pccc_v3.1, j = "dxpr", value = NULL)
set(pccc_v3.1, j = "icdv", value = as.integer(pccc_v3.1$icdv))

pccc_v3.1[subcondition == "N/A", subcondition := NA_character_]


# the ccc_code_type column will be used to
if (interactive()) {
  pccc_v3.1[, .N, keyby = .(ccc_code_type)] |> print(nrow = Inf)
}
pccc_v3.1 <- pccc_v3.1[!(ccc_code_type %in% c("Delete from V3", "do not include"))]

set(pccc_v3.1, j = "comments",      value = NULL)
set(pccc_v3.1, j = "cfjf_comments", value = NULL)
set(pccc_v3.1, j = "ccc_code_type", value = NULL)

# set tech_dep_flag and transplant_flag
pccc_v3.1[, transplant_flag := as.integer(condition == "Transplant")]
pccc_v3.1[, tech_dep_flag   := as.integer(condition == "Devices")]

# set the condition to be consistent with other data sources
pccc_v3.1[condition == "Transplant", `:=`(condition = "misc", subcondition = "transplantation")]
pccc_v3.1[condition == "Devices",    `:=`(condition = "misc", subcondition = "device and technology use")]

pccc_v3.1[,
  condition := fcase(condition == "Cardiovascular", "cvd",
                     condition == "Gastrointestinal", "gi",
                     condition == "Hematologic Immunologic", "hemato_immu",
                     condition == "Malignancy", "malignancy",
                     condition == "Metabolic",  "metabolic",
                     condition == "Neurologic/Neuromuscular", "neuromusc",
                     condition == "Other congenital and genetic defects", "congeni_genetic",
                     condition == "Premature & Neonatal", "neonatal",
                     condition == "Renal/Urologic", "renal",
                     condition == "Respiratory", "respiratory",
                     default = condition)
  ]

# clean up some of the subcondition
pccc_v3.1[, subcondition := tolower(subcondition)]
pccc_v3.1[subcondition == "cerebral hemorhage at birth", subcondition := "cerebral hemorrhage at birth"]
pccc_v3.1[subcondition == "hypoxic-ischemia encephalopathy", subcondition := "hypoxic-ischemic encephalopathy"]
pccc_v3.1[subcondition == "polyarteritis nodosa & related conditions",
          subcondition := "polyarteritis nodosa and related conditions"]
pccc_v3.1[subcondition == "device & technology use",
          subcondition := "device and technology use"]
pccc_v3.1[subcondition == "mental retardation",
          subcondition := "intellectual disabilities"]

pccc_v3.1[condition == "neonatal" & subcondition == "other premature or neonatal",
          subcondition := "other"]
pccc_v3.1[condition == "cvd" & subcondition == "other cardiovascular",
          subcondition := "other"]
pccc_v3.1[condition == "renal" & subcondition == "other renal & urologic",
          subcondition := "other"]
pccc_v3.1[condition == "gi" & subcondition == "other gi disease",
          subcondition := "other"]
pccc_v3.1[condition == "respiratory" & subcondition == "other respiratory",
          subcondition := "other"]
pccc_v3.1[condition == "hemato_immu" & subcondition == "other hematologic/immunologic",
          subcondition := "other"]

# Great, a bunch of device codes are in the device table, but not the primary
# condition tables.  Example CVD.  other conditions too
if (interactive()) {
  pccc_v3.1[
            pccc_v3.0[condition == "cvd" & subcondition == "device and technology use"]
            ,
            on = c('icdv', 'dx', 'code')
            ]
}

cvd_devices         <- pccc_v3.0[condition == "cvd" & subcondition == "device and technology use"]
respiratory_devices <- pccc_v3.0[condition == "respiratory" & subcondition == "device and technology use"]
neuromusc_devices   <- pccc_v3.0[condition == "neuromusc" & subcondition == "device and technology use"]
renal_devices       <- pccc_v3.0[condition == "renal" & subcondition == "device and technology use"]
gi_devices          <- pccc_v3.0[condition == "gi" & subcondition == "device and technology use"]
metabolic_devices   <- pccc_v3.0[condition == "metabolic" & subcondition == "device and technology use"]

# some more to add that are missing from v3.0 code
renal_devices <- rbind(renal_devices,
                       data.table(code = "06HY33Z",
                                  dx = 0,
                                  condition = "renal",
                                  subcondition = "device and technology use",
                                  icdv = 10L,
                                  tech_dep_flag = 1L,
                                  transplant_flag = 0L))

pccc_v3.1[condition == "misc" & subcondition == "device and technology use" &
          code %in% cvd_devices$code &
          icdv %in% cvd_devices$icdv &
          dx %in% cvd_devices$dx,
          condition := "cvd"]

pccc_v3.1[condition == "misc" & subcondition == "device and technology use" &
          code %in% respiratory_devices$code &
          icdv %in% respiratory_devices$icdv &
          dx %in% respiratory_devices$dx,
          condition := "respiratory"]

pccc_v3.1[condition == "misc" & subcondition == "device and technology use" &
          code %in% neuromusc_devices$code &
          icdv %in% neuromusc_devices$icdv &
          dx %in% neuromusc_devices$dx,
          condition := "neuromusc"]

pccc_v3.1[condition == "misc" & subcondition == "device and technology use" &
          code %in% renal_devices$code &
          icdv %in% renal_devices$icdv &
          dx %in% renal_devices$dx,
          condition := "renal"]

pccc_v3.1[condition == "misc" & subcondition == "device and technology use" &
          code %in% gi_devices$code &
          icdv %in% gi_devices$icdv &
          dx %in% gi_devices$dx,
          condition := "gi"]

pccc_v3.1[condition == "misc" & subcondition == "device and technology use" &
          code %in% metabolic_devices$code &
          icdv %in% metabolic_devices$icdv &
          dx %in% metabolic_devices$dx,
          condition := "metabolic"]


# there is a code that is missing
pccc_v3.1[code == "Z87761", `:=`(icdv = 10L, dx = 1L)]
stopifnot(pccc_v3.1[is.na(icdv), .N == 0])
stopifnot(pccc_v3.1[is.na(dx), .N == 0])
stopifnot(
  pccc_v3.1[condition == "misc", all(subcondition %in% c("transplantation", "device and technology use"))]
)

pccc_v3.1[subcondition == "transplantation",  transplant_flag := 1L]
pccc_v3.1[subcondition == "device and technology use",  tech_dep_flag := 1L]
pccc_v3.1 <- unique(pccc_v3.1)

# remove the non-misc
# Codes which are device and tech in misc should only be retained if not in
# another conidtion.  same for transplant.
non_misc_tech <- pccc_v3.1[condition != "misc" & subcondition == "device and technology use"]
non_misc_tran <- pccc_v3.1[condition != "misc" & subcondition == "transplantation"]

if (interactive()) {
  non_misc_tran[code == "T8630"]
}

# remove the "misc" rows
pccc_v3.1 <-
  pccc_v3.1[!(condition    ==   "misc" &
              subcondition ==   "device and technology use" &
              code         %in% non_misc_tech$code)]

pccc_v3.1 <-
  pccc_v3.1[!(condition    ==   "misc" &
              subcondition ==   "transplantation" &
              code         %in% non_misc_tran$code)]

# add technology use, transplantation, and flags for V43.21, V43.22
pccc_v3.1[grepl("^V432[12]", code), tech_dep_flag := 1L]
pccc_v3.1 <-
  rbind(pccc_v3.1,
        pccc_v3.1[grepl("^V432[12]", code)][, `:=`(tech_dep_flag = 1L, subcondition = "device and technology use")])

################################################################################
# Additional codes to add onto v3.1

# HEADERS, e.g., ICD-9 140 - all assignable codes under this header code are in
# so include this header too.  There are a lot of these codes.
pccc_v3.1 <-
  rbind(pccc_v3.1,
        pccc_v3.1[code == "1400" & icdv == 9 & dx == 1][, code := "140"],
        pccc_v3.1[code == "1410" & icdv == 9 & dx == 1][, code := "141"],
        pccc_v3.1[code == "1420" & icdv == 9 & dx == 1][, code := "142"],
        pccc_v3.1[code == "1430" & icdv == 9 & dx == 1][, code := "143"],
        pccc_v3.1[code == "1440" & icdv == 9 & dx == 1][, code := "144"],
        pccc_v3.1[code == "1450" & icdv == 9 & dx == 1][, code := "145"],
        pccc_v3.1[code == "1460" & icdv == 9 & dx == 1][, code := "146"],
        pccc_v3.1[code == "1470" & icdv == 9 & dx == 1][, code := "147"],
        pccc_v3.1[code == "1480" & icdv == 9 & dx == 1][, code := "148"],
        pccc_v3.1[code == "1490" & icdv == 9 & dx == 1][, code := "149"],
        pccc_v3.1[code == "1500" & icdv == 9 & dx == 1][, code := "150"],
        pccc_v3.1[code == "1510" & icdv == 9 & dx == 1][, code := "151"],
        pccc_v3.1[code == "1520" & icdv == 9 & dx == 1][, code := "152"],
        pccc_v3.1[code == "1530" & icdv == 9 & dx == 1][, code := "153"],
        pccc_v3.1[code == "1540" & icdv == 9 & dx == 1][, code := "154"],
        pccc_v3.1[code == "1550" & icdv == 9 & dx == 1][, code := "155"],
        pccc_v3.1[code == "1560" & icdv == 9 & dx == 1][, code := "156"],
        pccc_v3.1[code == "1570" & icdv == 9 & dx == 1][, code := "157"],
        pccc_v3.1[code == "1580" & icdv == 9 & dx == 1][, code := "158"],
        pccc_v3.1[code == "1590" & icdv == 9 & dx == 1][, code := "159"],
        pccc_v3.1[code == "1600" & icdv == 9 & dx == 1][, code := "160"],
        pccc_v3.1[code == "1610" & icdv == 9 & dx == 1][, code := "161"],
        pccc_v3.1[code == "1620" & icdv == 9 & dx == 1][, code := "162"],
        pccc_v3.1[code == "1630" & icdv == 9 & dx == 1][, code := "163"],
        pccc_v3.1[code == "1640" & icdv == 9 & dx == 1][, code := "164"],
        pccc_v3.1[code == "1650" & icdv == 9 & dx == 1][, code := "165"],
        pccc_v3.1[code == "1700" & icdv == 9 & dx == 1][, code := "170"],
        pccc_v3.1[code == "1710" & icdv == 9 & dx == 1][, code := "171"],
        pccc_v3.1[code == "1720" & icdv == 9 & dx == 1][, code := "172"],
        pccc_v3.1[grepl('^173', code) & icdv == 9 & dx == 1] [1][, code := "173"],
        pccc_v3.1[grepl('^1730', code) & icdv == 9 & dx == 1][1][, code := "1730"],
        pccc_v3.1[grepl('^1731', code) & icdv == 9 & dx == 1][1][, code := "1731"],
        pccc_v3.1[grepl('^1732', code) & icdv == 9 & dx == 1][1][, code := "1732"],
        pccc_v3.1[grepl('^1733', code) & icdv == 9 & dx == 1][1][, code := "1733"],
        pccc_v3.1[grepl('^1734', code) & icdv == 9 & dx == 1][1][, code := "1734"],
        pccc_v3.1[grepl('^1735', code) & icdv == 9 & dx == 1][1][, code := "1735"],
        pccc_v3.1[grepl('^1736', code) & icdv == 9 & dx == 1][1][, code := "1736"],
        pccc_v3.1[grepl('^1737', code) & icdv == 9 & dx == 1][1][, code := "1737"],
        pccc_v3.1[grepl('^1738', code) & icdv == 9 & dx == 1][1][, code := "1738"],
        pccc_v3.1[grepl('^1739', code) & icdv == 9 & dx == 1][1][, code := "1739"],
        pccc_v3.1[code == "1740" & icdv == 9 & dx == 1][, code := "174"],
        pccc_v3.1[code == "1750" & icdv == 9 & dx == 1][, code := "175"],
        pccc_v3.1[code == "1760" & icdv == 9 & dx == 1][, code := "176"],
        pccc_v3.1[code == "1800" & icdv == 9 & dx == 1][, code := "180"],
        pccc_v3.1[code == "1820" & icdv == 9 & dx == 1][, code := "182"],
        pccc_v3.1[code == "1830" & icdv == 9 & dx == 1][, code := "183"],
        pccc_v3.1[code == "1840" & icdv == 9 & dx == 1][, code := "184"],
        pccc_v3.1[code == "1860" & icdv == 9 & dx == 1][, code := "186"],
        pccc_v3.1[code == "1871" & icdv == 9 & dx == 1][, code := "187"],
        pccc_v3.1[code == "1880" & icdv == 9 & dx == 1][, code := "188"],
        pccc_v3.1[code == "1890" & icdv == 9 & dx == 1][, code := "189"],
        pccc_v3.1[code == "1900" & icdv == 9 & dx == 1][, code := "190"],
        pccc_v3.1[code == "1910" & icdv == 9 & dx == 1][, code := "191"],
        pccc_v3.1[code == "1920" & icdv == 9 & dx == 1][, code := "192"],
        pccc_v3.1[code == "1940" & icdv == 9 & dx == 1][, code := "194"],
        pccc_v3.1[code == "1950" & icdv == 9 & dx == 1][, code := "195"],
        pccc_v3.1[code == "1960" & icdv == 9 & dx == 1][, code := "196"],
        pccc_v3.1[code == "1970" & icdv == 9 & dx == 1][, code := "197"],
        pccc_v3.1[code == "1980" & icdv == 9 & dx == 1][, code := "198"],
        pccc_v3.1[code == "19881" & icdv == 9 & dx == 1][, code := "1988"],
        pccc_v3.1[code == "1990" & icdv == 9 & dx == 1][, code := "199"],
        pccc_v3.1[code == "20000" & icdv == 9 & dx == 1][, code := "200"],
        pccc_v3.1[code == "20000" & icdv == 9 & dx == 1][, code := "2000"],
        pccc_v3.1[code == "20010" & icdv == 9 & dx == 1][, code := "2001"],
        pccc_v3.1[code == "20020" & icdv == 9 & dx == 1][, code := "2002"],
        pccc_v3.1[code == "20030" & icdv == 9 & dx == 1][, code := "2003"],
        pccc_v3.1[code == "20040" & icdv == 9 & dx == 1][, code := "2004"],
        pccc_v3.1[code == "20050" & icdv == 9 & dx == 1][, code := "2005"],
        pccc_v3.1[code == "20060" & icdv == 9 & dx == 1][, code := "2006"],
        pccc_v3.1[code == "20070" & icdv == 9 & dx == 1][, code := "2007"],
        pccc_v3.1[code == "20080" & icdv == 9 & dx == 1][, code := "2008"],
        pccc_v3.1[code == "20100" & icdv == 9 & dx == 1][, code := "201"],
        pccc_v3.1[code == "20100" & icdv == 9 & dx == 1][, code := "2010"],
        pccc_v3.1[code == "20110" & icdv == 9 & dx == 1][, code := "2011"],
        pccc_v3.1[code == "20120" & icdv == 9 & dx == 1][, code := "2012"],
        pccc_v3.1[code == "20140" & icdv == 9 & dx == 1][, code := "2014"],
        pccc_v3.1[code == "20150" & icdv == 9 & dx == 1][, code := "2015"],
        pccc_v3.1[code == "20160" & icdv == 9 & dx == 1][, code := "2016"],
        pccc_v3.1[code == "20170" & icdv == 9 & dx == 1][, code := "2017"],
        pccc_v3.1[code == "20190" & icdv == 9 & dx == 1][, code := "2019"],
        pccc_v3.1[code == "20200" & icdv == 9 & dx == 1][, code := "202"],
        pccc_v3.1[code == "20200" & icdv == 9 & dx == 1][, code := "2020"],
        pccc_v3.1[code == "20210" & icdv == 9 & dx == 1][, code := "2021"],
        pccc_v3.1[code == "20220" & icdv == 9 & dx == 1][, code := "2022"],
        pccc_v3.1[code == "20230" & icdv == 9 & dx == 1][, code := "2023"],
        pccc_v3.1[code == "20240" & icdv == 9 & dx == 1][, code := "2024"],
        pccc_v3.1[code == "20250" & icdv == 9 & dx == 1][, code := "2025"],
        pccc_v3.1[code == "20260" & icdv == 9 & dx == 1][, code := "2026"],
        pccc_v3.1[code == "20270" & icdv == 9 & dx == 1][, code := "2027"],
        pccc_v3.1[code == "20280" & icdv == 9 & dx == 1][, code := "2028"],
        pccc_v3.1[code == "20290" & icdv == 9 & dx == 1][, code := "2029"],
        pccc_v3.1[code == "20300" & icdv == 9 & dx == 1][, code := "203"],
        pccc_v3.1[code == "20300" & icdv == 9 & dx == 1][, code := "2030"],
        pccc_v3.1[code == "20310" & icdv == 9 & dx == 1][, code := "2031"],
        pccc_v3.1[code == "20380" & icdv == 9 & dx == 1][, code := "2038"],
        pccc_v3.1[code == "20400" & icdv == 9 & dx == 1][, code := "204"],
        pccc_v3.1[code == "20400" & icdv == 9 & dx == 1][, code := "2040"],
        pccc_v3.1[code == "20410" & icdv == 9 & dx == 1][, code := "2041"],
        pccc_v3.1[code == "20420" & icdv == 9 & dx == 1][, code := "2042"],
        pccc_v3.1[code == "20480" & icdv == 9 & dx == 1][, code := "2048"],
        pccc_v3.1[code == "20490" & icdv == 9 & dx == 1][, code := "2049"],
        pccc_v3.1[code == "20500" & icdv == 9 & dx == 1][, code := "205"],
        pccc_v3.1[code == "20500" & icdv == 9 & dx == 1][, code := "2050"],
        pccc_v3.1[code == "20510" & icdv == 9 & dx == 1][, code := "2051"],
        pccc_v3.1[code == "20520" & icdv == 9 & dx == 1][, code := "2052"],
        pccc_v3.1[code == "20530" & icdv == 9 & dx == 1][, code := "2053"],
        pccc_v3.1[code == "20580" & icdv == 9 & dx == 1][, code := "2058"],
        pccc_v3.1[code == "20590" & icdv == 9 & dx == 1][, code := "2059"],
        pccc_v3.1[code == "20600" & icdv == 9 & dx == 1][, code := "206"],
        pccc_v3.1[code == "20600" & icdv == 9 & dx == 1][, code := "2060"],
        pccc_v3.1[code == "20610" & icdv == 9 & dx == 1][, code := "2061"],
        pccc_v3.1[code == "20620" & icdv == 9 & dx == 1][, code := "2062"],
        pccc_v3.1[code == "20680" & icdv == 9 & dx == 1][, code := "2068"],
        pccc_v3.1[code == "20690" & icdv == 9 & dx == 1][, code := "2069"],
        pccc_v3.1[code == "20700" & icdv == 9 & dx == 1][, code := "207"],
        pccc_v3.1[code == "20700" & icdv == 9 & dx == 1][, code := "2070"],
        pccc_v3.1[code == "20710" & icdv == 9 & dx == 1][, code := "2071"],
        pccc_v3.1[code == "20720" & icdv == 9 & dx == 1][, code := "2072"],
        pccc_v3.1[code == "20780" & icdv == 9 & dx == 1][, code := "2078"],
        pccc_v3.1[code == "20800" & icdv == 9 & dx == 1][, code := "208"],
        pccc_v3.1[code == "20800" & icdv == 9 & dx == 1][, code := "2080"],
        pccc_v3.1[code == "20810" & icdv == 9 & dx == 1][, code := "2081"],
        pccc_v3.1[code == "20820" & icdv == 9 & dx == 1][, code := "2082"],
        pccc_v3.1[code == "20880" & icdv == 9 & dx == 1][, code := "2088"],
        pccc_v3.1[code == "20890" & icdv == 9 & dx == 1][, code := "2089"],
        pccc_v3.1[code == "20900" & icdv == 9 & dx == 1][, code := "209"],
        pccc_v3.1[code == "20900" & icdv == 9 & dx == 1][, code := "2090"],
        pccc_v3.1[code == "20910" & icdv == 9 & dx == 1][, code := "2091"],
        pccc_v3.1[code == "20920" & icdv == 9 & dx == 1][, code := "2092"],
        pccc_v3.1[code == "20930" & icdv == 9 & dx == 1][, code := "2093"],
        pccc_v3.1[code == "20940" & icdv == 9 & dx == 1][, code := "2094"],
        pccc_v3.1[code == "20950" & icdv == 9 & dx == 1][, code := "2095"],
        pccc_v3.1[code == "20960" & icdv == 9 & dx == 1][, code := "2096"],
        pccc_v3.1[code == "20970" & icdv == 9 & dx == 1][, code := "2097"],
        pccc_v3.1[code == "2300" & icdv == 9 & dx == 1][, code := "230"],
        pccc_v3.1[code == "2310" & icdv == 9 & dx == 1][, code := "231"],
        pccc_v3.1[code == "2320" & icdv == 9 & dx == 1][, code := "232"],
        pccc_v3.1[code == "2330" & icdv == 9 & dx == 1][, code := "233"],
        pccc_v3.1[code == "23330" & icdv == 9 & dx == 1][, code := "2333"],
        pccc_v3.1[code == "2340" & icdv == 9 & dx == 1][, code := "234"],
        pccc_v3.1[code == "2350" & icdv == 9 & dx == 1][, code := "235"],
        pccc_v3.1[code == "2360" & icdv == 9 & dx == 1][, code := "236"],
        pccc_v3.1[code == "23690" & icdv == 9 & dx == 1][, code := "2369"],
        pccc_v3.1[code == "2370" & icdv == 9 & dx == 1][, code := "237"],
        pccc_v3.1[code == "23770" & icdv == 9 & dx == 1][, code := "2377"],
        pccc_v3.1[code == "2380" & icdv == 9 & dx == 1][, code := "238"],
        pccc_v3.1[code == "23870" & icdv == 9 & dx == 1][, code := "2387"],
        pccc_v3.1[code == "2390" & icdv == 9 & dx == 1][, code := "239"],
        pccc_v3.1[code == "23981" & icdv == 9 & dx == 1][, code := "2398"],
        pccc_v3.1[code == "2700" & icdv == 9 & dx == 1][, code := "270"],
        pccc_v3.1[code == "2710" & icdv == 9 & dx == 1][, code := "271"],
        pccc_v3.1[code == "2720" & icdv == 9 & dx == 1][, code := "272"],
        pccc_v3.1[code == "27501" & icdv == 9 & dx == 1][, code := "2750"],
        pccc_v3.1[code == "27701" & icdv == 9 & dx == 1][, code := "2770"],
        pccc_v3.1[code == "27731" & icdv == 9 & dx == 1][, code := "2773"],
        pccc_v3.1[code == "27781" & icdv == 9 & dx == 1][, code := "2778"],
        pccc_v3.1[code == "27901" & icdv == 9 & dx == 1][, code := "279"],
        pccc_v3.1[code == "27901" & icdv == 9 & dx == 1][, code := "2790"],
        pccc_v3.1[code == "27911" & icdv == 9 & dx == 1][, code := "2791"],
        pccc_v3.1[code == "27941" & icdv == 9 & dx == 1][, code := "2794"],
        pccc_v3.1[code == "27951" & icdv == 9 & dx == 1][, code := "2795"],
        pccc_v3.1[code == "28241" & icdv == 9 & dx == 1][, code := "2824"],
        pccc_v3.1[code == "28261" & icdv == 9 & dx == 1][, code := "2826"],
        pccc_v3.1[code == "28401" & icdv == 9 & dx == 1][, code := "284"],
        pccc_v3.1[code == "28401" & icdv == 9 & dx == 1][, code := "2840"],
        pccc_v3.1[code == "28411" & icdv == 9 & dx == 1][, code := "2841"],
        pccc_v3.1[code == "28481" & icdv == 9 & dx == 1][, code := "2848"],
        pccc_v3.1[code == "3300" & icdv == 9 & dx == 1][, code := "330"],
        pccc_v3.1[code == "33111" & icdv == 9 & dx == 1][, code := "3311"],
        pccc_v3.1[code == "33181" & icdv == 9 & dx == 1][, code := "3318"],
        pccc_v3.1[code == "33371" & icdv == 9 & dx == 1][, code := "3337"],
        pccc_v3.1[code == "33390" & icdv == 9 & dx == 1][, code := "3339"],
        pccc_v3.1[code == "3340" & icdv == 9 & dx == 1][, code := "334"],
        pccc_v3.1[code == "3350" & icdv == 9 & dx == 1][, code := "335"],
        pccc_v3.1[code == "33510" & icdv == 9 & dx == 1][, code := "3351"],
        pccc_v3.1[code == "33520" & icdv == 9 & dx == 1][, code := "3352"],
        pccc_v3.1[code == "3430" & icdv == 9 & dx == 1][, code := "343"],
        pccc_v3.1[code == "34400" & icdv == 9 & dx == 1][, code := "3440"],
        pccc_v3.1[code == "42511" & icdv == 9 & dx == 1][, code := "4251"],
        pccc_v3.1[code == "42610" & icdv == 9 & dx == 1][, code := "426"],
        pccc_v3.1[code == "42610" & icdv == 9 & dx == 1][, code := "4261"],
        pccc_v3.1[code == "42650" & icdv == 9 & dx == 1][, code := "4265"],
        pccc_v3.1[code == "42681" & icdv == 9 & dx == 1][, code := "4268"],
        pccc_v3.1[code == "42731" & icdv == 9 & dx == 1][, code := "4273"],
        pccc_v3.1[code == "42741" & icdv == 9 & dx == 1][, code := "4274"],
        pccc_v3.1[code == "42761" & icdv == 9 & dx == 1][, code := "4276"],
        pccc_v3.1[code == "42781" & icdv == 9 & dx == 1][, code := "4278"],
        pccc_v3.1[code == "51900" & icdv == 9 & dx == 1][, code := "5190"],
        pccc_v3.1[code == "53640" & icdv == 9 & dx == 1][, code := "5364"],
        pccc_v3.1[code == "5550" & icdv == 9 & dx == 1][, code := "555"],
        pccc_v3.1[code == "5560" & icdv == 9 & dx == 1][, code := "556"],
        pccc_v3.1[code == "57140" & icdv == 9 & dx == 1][, code := "5714"],
        pccc_v3.1[code == "5851" & icdv == 9 & dx == 1][, code := "585"],
        pccc_v3.1[code == "7400" & icdv == 9 & dx == 1][, code := "740"],
        pccc_v3.1[code == "74100" & icdv == 9 & dx == 1][, code := "741"],
        pccc_v3.1[code == "74100" & icdv == 9 & dx == 1][, code := "7410"],
        pccc_v3.1[code == "74190" & icdv == 9 & dx == 1][, code := "7419"],
        pccc_v3.1[code == "7420" & icdv == 9 & dx == 1][, code := "742"],
        pccc_v3.1[code == "74251" & icdv == 9 & dx == 1][, code := "7425"],
        pccc_v3.1[code == "74731" & icdv == 9 & dx == 1][, code := "7473"],
        pccc_v3.1[code == "7480" & icdv == 9 & dx == 1][, code := "748"],
        pccc_v3.1[code == "74860" & icdv == 9 & dx == 1][, code := "7486"],
        pccc_v3.1[code == "7511" & icdv == 9 & dx == 1][, code := "751"],
        pccc_v3.1[code == "75160" & icdv == 9 & dx == 1][, code := "7516"],
        pccc_v3.1[code == "7530" & icdv == 9 & dx == 1][, code := "753"],
        pccc_v3.1[code == "75610" & icdv == 9 & dx == 1][, code := "7561"],
        pccc_v3.1[code == "75650" & icdv == 9 & dx == 1][, code := "7565"],
        pccc_v3.1[code == "75670" & icdv == 9 & dx == 1][, code := "7567"],
        pccc_v3.1[code == "7580" & icdv == 9 & dx == 1][, code := "758"],
        pccc_v3.1[code == "75981" & icdv == 9 & dx == 1][, code := "7598"],
        pccc_v3.1[code == "76870" & icdv == 9 & dx == 1][, code := "7687"],
        pccc_v3.1[code == "V4450" & icdv == 9 & dx == 1][, code := "V445"],
        pccc_v3.1[code == "V4611" & icdv == 9 & dx == 1][, code := "V461"],

        pccc_v3.1[code == "74510" & icdv == 9 & dx == 1][, code := "7451"],
        pccc_v3.1[code == "74560" & icdv == 9 & dx == 1][, code := "7456"],
        pccc_v3.1[code == "74600" & icdv == 9 & dx == 1][, code := "746"],
        pccc_v3.1[code == "74600" & icdv == 9 & dx == 1][, code := "7460"],
        pccc_v3.1[code == "74680" & icdv == 9 & dx == 1][, code := "7468"],
        pccc_v3.1[code == "74710" & icdv == 9 & dx == 1][, code := "7471"],
        pccc_v3.1[code == "74720" & icdv == 9 & dx == 1][, code := "7472"],
        pccc_v3.1[code == "74730" & icdv == 9 & dx == 1][, code := "7473"],
        pccc_v3.1[code == "74740" & icdv == 9 & dx == 1][, code := "7474"],
        pccc_v3.1[code == "99600" & icdv == 9 & dx == 1][, code := "9960"],
        pccc_v3.1[code == "99640" & icdv == 9 & dx == 1][, code := "9964"],
        pccc_v3.1[code == "99690" & icdv == 9 & dx == 1][, code := "9969"],
        pccc_v3.1[code == "V4321" & icdv == 9 & dx == 1][, code := "V432"],
        pccc_v3.1[code == "V4500" & icdv == 9 & dx == 1][, code := "V450"],
        pccc_v3.1[code == "V4511" & icdv == 9 & dx == 1][, code := "V451"],
        pccc_v3.1[code == "V5331" & icdv == 9 & dx == 1][, code := "V533"],
        pccc_v3.1[code == "V560" & icdv == 9 & dx == 1][, code := "V56"],

        pccc_v3.1[code == "0221" & icdv == 9 & dx == 0][, code := "022"],
        pccc_v3.1[code == "0231" & icdv == 9 & dx == 0][, code := "023"],
        pccc_v3.1[code == "0371" & icdv == 9 & dx == 0][, code := "037"],
        pccc_v3.1[code == "3121" & icdv == 9 & dx == 0][, code := "312"],
        pccc_v3.1[code == "3241" & icdv == 9 & dx == 0][, code := "324"],
        pccc_v3.1[code == "3250" & icdv == 9 & dx == 0][, code := "325"],
        pccc_v3.1[code == "3350" & icdv == 9 & dx == 0][, code := "335"],
        pccc_v3.1[code == "3581" & icdv == 9 & dx == 0][, code := "358"],
        pccc_v3.1[code == "3780" & icdv == 9 & dx == 0][, code := "378"],
        pccc_v3.1[code == "4311" & icdv == 9 & dx == 0][, code := "431"],
        pccc_v3.1[code == "4391" & icdv == 9 & dx == 0][, code := "439"],
        pccc_v3.1[code == "4581" & icdv == 9 & dx == 0][, code := "458"],
        pccc_v3.1[code == "5051" & icdv == 9 & dx == 0][, code := "505"],
        pccc_v3.1[code == "5551" & icdv == 9 & dx == 0][, code := "555"],
        pccc_v3.1[code == "5561" & icdv == 9 & dx == 0][, code := "556"],
        pccc_v3.1[code == "5641" & icdv == 9 & dx == 0][, code := "564"],
        pccc_v3.1[code == "5651" & icdv == 9 & dx == 0][, code := "565"],
        pccc_v3.1[code == "5661" & icdv == 9 & dx == 0][, code := "566"],
        pccc_v3.1[code == "5721" & icdv == 9 & dx == 0][, code := "572"],
        pccc_v3.1[code == "5771" & icdv == 9 & dx == 0][, code := "577"],
        pccc_v3.1[code == "6241" & icdv == 9 & dx == 0][, code := "624"],
        pccc_v3.1[code == "6551" & icdv == 9 & dx == 0][, code := "655"],
        pccc_v3.1[code == "6561" & icdv == 9 & dx == 0][, code := "656"],
        pccc_v3.1[code == "6841" & icdv == 9 & dx == 0][, code := "684"],
        pccc_v3.1[code == "6851" & icdv == 9 & dx == 0][, code := "685"],
        pccc_v3.1[code == "6861" & icdv == 9 & dx == 0][, code := "686"],
        pccc_v3.1[code == "6871" & icdv == 9 & dx == 0][, code := "687"],

        pccc_v3.1[code == "C441321" & icdv == 10 & dx == 1][, code := "C44132"],
        pccc_v3.1[code == "C441391" & icdv == 10 & dx == 1][, code := "C44139"],
        pccc_v3.1[code == "D550" & icdv == 10 & dx == 1][, code := "D55"],
        pccc_v3.1[code == "D560" & icdv == 10 & dx == 1][, code := "D56"],
        pccc_v3.1[code == "D5700" & icdv == 10 & dx == 1][, code := "D57"],
        pccc_v3.1[code == "D57211" & icdv == 10 & dx == 1][, code := "D5721"],
        pccc_v3.1[code == "D580" & icdv == 10 & dx == 1][, code := "D58"],
        pccc_v3.1[code == "D600" & icdv == 10 & dx == 1][, code := "D60"],
        pccc_v3.1[code == "D6101" & icdv == 10 & dx == 1][, code := "D61"],
        pccc_v3.1[code == "D800" & icdv == 10 & dx == 1][, code := "D80"],
        pccc_v3.1[code == "D810" & icdv == 10 & dx == 1][, code := "D81"],
        pccc_v3.1[code == "D820" & icdv == 10 & dx == 1][, code := "D82"],
        pccc_v3.1[code == "D830" & icdv == 10 & dx == 1][, code := "D83"],
        pccc_v3.1[code == "D891" & icdv == 10 & dx == 1][, code := "D89"],
        pccc_v3.1[code == "E7020" & icdv == 10 & dx == 1][, code := "E702"],
        pccc_v3.1[code == "E7030" & icdv == 10 & dx == 1][, code := "E703"],
        pccc_v3.1[code == "E7040" & icdv == 10 & dx == 1][, code := "E704"],
        pccc_v3.1[code == "E71110" & icdv == 10 & dx == 1][, code := "E711"],
        pccc_v3.1[code == "E7130" & icdv == 10 & dx == 1][, code := "E713"],
        pccc_v3.1[code == "E7140" & icdv == 10 & dx == 1][, code := "E714"],
        pccc_v3.1[code == "E7150" & icdv == 10 & dx == 1][, code := "E715"],
        pccc_v3.1[code == "E7200" & icdv == 10 & dx == 1][, code := "E720"],
        pccc_v3.1[code == "E7210" & icdv == 10 & dx == 1][, code := "E721"],
        pccc_v3.1[code == "E7220" & icdv == 10 & dx == 1][, code := "E722"],
        pccc_v3.1[code == "E7400" & icdv == 10 & dx == 1][, code := "E740"],
        pccc_v3.1[code == "E7410" & icdv == 10 & dx == 1][, code := "E741"],
        pccc_v3.1[code == "E7420" & icdv == 10 & dx == 1][, code := "E742"],
        pccc_v3.1[code == "E7431" & icdv == 10 & dx == 1][, code := "E743"],
        pccc_v3.1[code == "E7601" & icdv == 10 & dx == 1][, code := "E760"],
        pccc_v3.1[code == "E76210" & icdv == 10 & dx == 1][, code := "E762"],
        pccc_v3.1[code == "E7870" & icdv == 10 & dx == 1][, code := "E787"],
        pccc_v3.1[code == "E7881" & icdv == 10 & dx == 1][, code := "E788"],
        pccc_v3.1[code == "E8300" & icdv == 10 & dx == 1][, code := "E830"],
        pccc_v3.1[code == "E8310" & icdv == 10 & dx == 1][, code := "E831"],
        pccc_v3.1[code == "E8330" & icdv == 10 & dx == 1][, code := "E833"],
        pccc_v3.1[code == "E8340" & icdv == 10 & dx == 1][, code := "E834"],
        pccc_v3.1[code == "E840" & icdv == 10 & dx == 1][, code := "E84"],
        pccc_v3.1[code == "E850" & icdv == 10 & dx == 1][, code := "E85"],
        pccc_v3.1[code == "E8801" & icdv == 10 & dx == 1][, code := "E880"],
        pccc_v3.1[code == "E8840" & icdv == 10 & dx == 1][, code := "E884"],
        pccc_v3.1[code == "G1220" & icdv == 10 & dx == 1][, code := "G122"],
        pccc_v3.1[code == "G3180" & icdv == 10 & dx == 1][, code := "G318"],
        pccc_v3.1[code == "G710" & icdv == 10 & dx == 1][, code := "G71"],
        pccc_v3.1[code == "G720" & icdv == 10 & dx == 1][, code := "G72"],
        pccc_v3.1[code == "G9381" & icdv == 10 & dx == 1][, code := "G938"],
        pccc_v3.1[code == "H49811" & icdv == 10 & dx == 1][, code := "H498"],
        pccc_v3.1[code == "I420" & icdv == 10 & dx == 1][, code := "I42"],
        pccc_v3.1[code == "I440" & icdv == 10 & dx == 1][, code := "I44"],
        pccc_v3.1[code == "I450" & icdv == 10 & dx == 1][, code := "I45"],
        pccc_v3.1[code == "I470" & icdv == 10 & dx == 1][, code := "I47"],
        pccc_v3.1[code == "I480" & icdv == 10 & dx == 1][, code := "I48"],
        pccc_v3.1[code == "I4901" & icdv == 10 & dx == 1][, code := "I490"],
        pccc_v3.1[code == "I4940" & icdv == 10 & dx == 1][, code := "I494"],
        pccc_v3.1[code == "K5000" & icdv == 10 & dx == 1][, code := "K50"],
        pccc_v3.1[code == "K5100" & icdv == 10 & dx == 1][, code := "K51"],
        pccc_v3.1[code == "K730" & icdv == 10 & dx == 1][, code := "K73"],
        pccc_v3.1[code == "K740" & icdv == 10 & dx == 1][, code := "K74"],
        pccc_v3.1[code == "K7681" & icdv == 10 & dx == 1][, code := "K768"],
        pccc_v3.1[code == "M4100" & icdv == 10 & dx == 1][, code := "M410"],
        pccc_v3.1[code == "N181" & icdv == 10 & dx == 1][, code := "N18"],
        pccc_v3.1[code == "P9160" & icdv == 10 & dx == 1][, code := "P916"],
        pccc_v3.1[code == "Q000" & icdv == 10 & dx == 1][, code := "Q00"],
        pccc_v3.1[code == "Q010" & icdv == 10 & dx == 1][, code := "Q01"],
        pccc_v3.1[code == "Q030" & icdv == 10 & dx == 1][, code := "Q03"],
        pccc_v3.1[code == "Q040" & icdv == 10 & dx == 1][, code := "Q04"],
        pccc_v3.1[code == "Q050" & icdv == 10 & dx == 1][, code := "Q05"],
        pccc_v3.1[code == "Q060" & icdv == 10 & dx == 1][, code := "Q06"],
        pccc_v3.1[code == "Q0700" & icdv == 10 & dx == 1][, code := "Q07"],
        pccc_v3.1[code == "Q200" & icdv == 10 & dx == 1][, code := "Q20"],
        pccc_v3.1[code == "Q220" & icdv == 10 & dx == 1][, code := "Q22"],
        pccc_v3.1[code == "Q230" & icdv == 10 & dx == 1][, code := "Q23"],
        pccc_v3.1[code == "Q240" & icdv == 10 & dx == 1][, code := "Q24"],
        pccc_v3.1[code == "Q2571" & icdv == 10 & dx == 1][, code := "Q257"],
        pccc_v3.1[code == "Q260" & icdv == 10 & dx == 1][, code := "Q26"],
        pccc_v3.1[code == "Q300" & icdv == 10 & dx == 1][, code := "Q30"],
        pccc_v3.1[code == "Q310" & icdv == 10 & dx == 1][, code := "Q31"],
        pccc_v3.1[code == "Q320" & icdv == 10 & dx == 1][, code := "Q32"],
        pccc_v3.1[code == "Q330" & icdv == 10 & dx == 1][, code := "Q33"],
        pccc_v3.1[code == "Q340" & icdv == 10 & dx == 1][, code := "Q34"],
        pccc_v3.1[code == "Q410" & icdv == 10 & dx == 1][, code := "Q41"],
        pccc_v3.1[code == "Q420" & icdv == 10 & dx == 1][, code := "Q42"],
        pccc_v3.1[code == "Q430" & icdv == 10 & dx == 1][, code := "Q43"],
        pccc_v3.1[code == "Q440" & icdv == 10 & dx == 1][, code := "Q44"],
        pccc_v3.1[code == "Q450" & icdv == 10 & dx == 1][, code := "Q45"],
        pccc_v3.1[code == "Q600" & icdv == 10 & dx == 1][, code := "Q60"],
        pccc_v3.1[code == "Q6100" & icdv == 10 & dx == 1][, code := "Q61"],
        pccc_v3.1[code == "Q620" & icdv == 10 & dx == 1][, code := "Q62"],
        pccc_v3.1[code == "Q630" & icdv == 10 & dx == 1][, code := "Q63"],
        pccc_v3.1[code == "Q640" & icdv == 10 & dx == 1][, code := "Q64"],
        pccc_v3.1[code == "Q7220" & icdv == 10 & dx == 1][, code := "Q722"],
        pccc_v3.1[code == "Q76411" & icdv == 10 & dx == 1][, code := "Q764"],
        pccc_v3.1[code == "Q770" & icdv == 10 & dx == 1][, code := "Q77"],
        pccc_v3.1[code == "Q7951" & icdv == 10 & dx == 1][, code := "Q795"],
        pccc_v3.1[code == "Q810" & icdv == 10 & dx == 1][, code := "Q81"],
        pccc_v3.1[code == "Q8711" & icdv == 10 & dx == 1][, code := "Q871"],
        pccc_v3.1[code == "Q8500" & icdv == 10 & dx == 1][, code := "Q850"],
        pccc_v3.1[code == "Q930" & icdv == 10 & dx == 1][, code := "Q93"],
        pccc_v3.1[code == "Q971" & icdv == 10 & dx == 1][, code := "Q97"]
  )

# ICD-9-CM 201.58 is in the documentation for v2, the software for v2, and the
# software for v3.  It is not in the eTable3 for v3.  Add it.  Same for other
# coldes in this section.
pccc_v3.1 <-
  rbind(pccc_v3.1,
        pccc_v3.1[code == "20157" & icdv == 9 & dx == 1][, code := "20158"],
        pccc_v3.1[code == "20254" & icdv == 9 & dx == 1][, code := "20255"]
  )

# ICD-9-CM 331.2 - other 331 codes are in. 331.2 is not in the eTable3 or
# finalxlsx, it's a valid code and was flagged in v2.
if (interactive()) {
  pccc_v3.1[grepl("^331", code)]
}
pccc_v3.1 <-
  rbind(pccc_v3.1 , pccc_v3.1[code == "3314"][, code := "3312"])

# ICD-9-CM 433.01, 433.21, 433.31, 433.81, 433.91,
# 434.01, 434.11, 434.91 map to both cardiovascular and neurologic conditions.
pccc_v3.1 <-
  rbind(pccc_v3.1
    , pccc_v3.1[grepl("^433[02389]1$", code)][, `:=`(condition = "cvd", subcondition = "other")]
    , pccc_v3.1[grepl("^433[02389]1$", code)][, `:=`(condition = "neuromusc", subcondition = "occlusion of cerebral arteries")]
    , pccc_v3.1[grepl("^434[014]1$", code)][, `:=`(condition = "cvd", subcondition = "other")]
    , pccc_v3.1[grepl("^434[014]1$", code)][, `:=`(condition = "neuromusc", subcondition = "occlusion of cerebral arteries")]
  )

# ICD-9-PCS 81.09
# This code is in v2, it just appears to be missing from eTable3 and the
# finalxlsx files that go with V3.  All other 81.0[0-8] are in the eTable3.
if (interactive()) {
  pccc_v3.1[grepl("^810", code)]
}
pccc_v3.1 <-
  rbind(
    pccc_v3.1,
    pccc_v3.1[code == "8100" & icdv == 9 & dx == 0][, code := "8109"]
  )

# ICD-10-CM D57.813 and D57.818 are in the xlsx sheet informing SAS, but they
# are missing from eTable3 (supp3). Add them to v3.1.  Similar mapping in v2.0
# and v2.1
if (interactive()) {
  pccc_v3.0[code == "D57813"]
  pccc_v3.0[code == "D57818"]
  pccc_v3.1[code == "D57813"]
  pccc_v3.1[code == "D57818"]
}
pccc_v3.1 <-
  rbind(pccc_v3.1, pccc_v3.0[code == "D57813"], pccc_v3.0[code == "D57818"])

# ICD-10-CM C83.39 is in the code base.  This was an assignable code through FY
# 2024.  In 2025 codes C83.390 and C83.398 were introduced.  As such, these two
# codes need to be added to the set and C83.39 needs to be retained.
pccc_v3.1 <-
  rbind(pccc_v3.1,
        pccc_v3.1[code == "C8339"][, `:=`(code = "C83390")],
        pccc_v3.1[code == "C8339"][, `:=`(code = "C83398")])

# ICD-10 B20 is in the US and WHO variants.  B21, B22, B23, B24 are only in the
# WHO ICD-10 version.  Add these codes to v3.1 for completeness.  These are all
# header codes.  Assignable codes will be added a following step.
pccc_v3.1 <-
  rbind(pccc_v3.1,
        pccc_v3.1[code == "B20"][, code := "B21"],
        pccc_v3.1[code == "B20"][, code := "B22"],
        pccc_v3.1[code == "B20"][, code := "B23"],
        pccc_v3.1[code == "B20"][, code := "B24"])

# ICD-10-CM Malignancy codes... A lot of three-digit C codes need to be added to
# pccc_v3.1
for (i in c(paste0("0", 0:9), 10:99, "4A", "7A", "7B")) {
  DT <- pccc_v3.1[grepl(paste0("^C", i), code)]
  if (nrow(DT) > 0) {
    DT <- DT[1]
    pccc_v3.1 <- rbind(pccc_v3.1, DT[, code := paste0("C", i)])
  }
}

# need C97 explicitly, it's on its own as of FY 2025.
pccc_v3.1 <- rbind(pccc_v3.1, DT[code == "C00", code := "C97"])

for (i in c(paste0("0", 0:9), 37:49, "3A")) {
  DT <- pccc_v3.1[grepl(paste0("^D", i), code)]
  if (nrow(DT) > 0) {
    DT <- DT[1]
    pccc_v3.1 <- rbind(pccc_v3.1, DT[, code := paste0("D", i)])
  }
}

# E75.0, E75.1, E75.2 is a header and should map to both
#  * neuromusc (cns degeneration and disease)
#  * metabolic (lipid metabolism)
# It appears _all_ E75 codes should have these mappings...
pccc_v3.1 <-
  rbind(pccc_v3.1,
        pccc_v3.1[grepl("^E7500", code)][, code := "E75"],
        pccc_v3.1[grepl("^E7500", code)][, code := "E750"],
        pccc_v3.1[grepl("^E7510", code)][, code := "E751"],
        pccc_v3.1[grepl("^E7521", code)][, code := "E752"]
  )

# ICD-10-CM Q89.81 and Q89.89 were introduced for FY 2026, previously Q89.8 was
# the assignable code
pccc_v3.1 <-
  rbind(pccc_v3.1,
        pccc_v3.1[code == "Q898"][, code := "Q8981"],
        pccc_v3.1[code == "Q898"][, code := "Q8989"])

# ICD-10-CM Q98.2
# It appears that as of fiscal year 2026, Q98.2 is not in the CMS codes, but is
# in cdc mortality and WHO data.  It is consistent with other ICD-10-CM Q98
# codes.  Keep it in pccc_v3.1; it is in v2 becuase the header Q98 is in.
if (interactive()) {
  subset(medicalcoder::get_icd_codes(), grepl("^Q982", code))
  subset(medicalcoder::get_icd_codes(with.descriptions = T), grepl("^Q982", code))
  subset(medicalcoder::get_icd_codes(with.descriptions = T), src == "who" & grepl("^Q98", code))
  pccc_v3.1[grepl("^Q98", code)]
}
pccc_v3.1 <-
  rbind(pccc_v3.1,
        pccc_v3.1[code == "Q980"][, code := "Q98"],
        pccc_v3.1[code == "Q980"][, code := "Q982"])

################################################################################
# Missing codes with more granulatity:
#
# Examples:
#
#   ICD-10-CM D48.1 is listed in the eTable3 and
#   final-v3-with-rev-code-list-02282023.xlsx All of the codes under D48.1 need
#   to be added to v3.1
#
#   ICD-10-CM D57.214 was added for FY 2025, D57.21[1,2,9] in 2014, D57.21[3,8]
#   in 2021.
#
# Based on all known ICD codes, fill in any missing codes via partial string
# matching!
known_icd_codes <- readRDS("../icd/icd_codes.rds")
setDT(known_icd_codes)
set(known_icd_codes, j = "chap_id", value = NULL)
set(known_icd_codes, j = "subchap_id", value = NULL)
if (interactive()) {
  pccc_v3.1
}

foo <- function(i) {
  DT <-
    subset(known_icd_codes,
           icdv == pccc_v3.1[["icdv"]][i] &
             dx  == pccc_v3.1[["dx"]][i]   &
             grepl(paste0("^", pccc_v3.1[["code"]][i]), code))
  merge(DT, pccc_v3.1[i, .(icdv, dx, condition, subcondition, transplant_flag, tech_dep_flag)], by = c("icdv", "dx"))
}

pccc_v3.1 <- pbapply::pblapply(1:nrow(pccc_v3.1), foo, cl = 8L)
pccc_v3.1 <- rbindlist(pccc_v3.1)
pccc_v3.1 <- unique(pccc_v3.1)

################################################################################
# Remove extra codes
#
# ICD-9-CM 516.3 is a header that should be in the set as it was an assignable
# code through fiscal year 2011.  Not all of the five digit codes are included.
# They were added to v3.1 in the above work due to the header code.  Remove
# these five-digit codes.
#
# | Code   | Description                                         | Likely reason for omission                                                                                          |
# | ------ | --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
# | 516.32 | Idiopathic non-specific interstitial pneumonitis    | This can be acute, subacute, or chronic — often reversible with treatment, so not always a complex chronic disease. |
# | 516.33 | Acute interstitial pneumonitis                      | Specifically *acute* and often linked to ARDS; high mortality but not chronic by definition.                        |
# | 516.34 | Respiratory bronchiolitis interstitial lung disease | Often associated with smoking, can improve with cessation, not necessarily progressive.                             |
# | 516.35 | Idiopathic lymphoid interstitial pneumonia          | Rare, variable course, sometimes secondary to autoimmune disease; may respond to treatment.                         |
# | 516.36 | Cryptogenic organizing pneumonia                    | Usually responsive to corticosteroids, not considered a chronic progressive fibrosing ILD.                          |

if (interactive()) {
  pccc_v3.1[grepl("^516\\.3", full_code)]
}
pccc_v3.1 <- pccc_v3.1[!(code %in% c("51632", "51633", "51634", "51635", "51636"))]


# ICD-10-CM G25.3
#
# This code only appears in eTable3 to be removed from V3
#
#                CCC.Category       Subcategory ICD.Code ICDCode.Description             Comments       CF/JF.Comments  CCC.Code.Type ICD9/ICD10  DX/PX
#                      <char>            <char>   <char>              <char>               <char>               <char>         <char>      <num> <char>
# 1: Neurologic/Neuromuscular Movement diseases     G253           Myoclonus In document, not SAS No (Delete Existing) Delete from V3         10     DX
#
# What is interesting about this that under v2, the doc and the R package have
# G25.3 as neuromusc (movement disease) and as neuromusc (cns degeneration).
#
# Notes:
#  - G25.3 itself does not specify whether the tremor is chronic, but it could
#    be, depending on its cause.
#  - It is a neurologic condition rather than a neuromuscular one.
#  - It could be considered a symptom or manifestation in broader movement
#    disorders or even CNS degeneration if there is an underlying condition like
#    Parkinson's disease or another degenerative disease. However, G25.3 by
#    itself is not classified directly under those categories without additional
#    context.
stopifnot("G25.3 is not in pccc_v3.1" = pccc_v3.1[grepl("^G253", code), .N == 0])

################################################################################
# save to disk
pccc_v3.0 <- unique(pccc_v3.0)
pccc_v3.1 <- unique(pccc_v3.1)

setDF(pccc_v3.0)
setDF(pccc_v3.1)
saveRDS(pccc_v3.0, "pccc_v3.0.rds")
saveRDS(pccc_v3.1, "pccc_v3.1.rds")

################################################################################
#                                 End of File                                  #
################################################################################
