################################################################################
# file: pccc/pccc_v2.1.R
#
# purpose: Blend document, package, and legacy code sources to extend the PCCC
#          v2 classification.
#
# inputs:
#   ../icd/icd_codes.rds
#   ./pccc_v2.0.rds
#   ./pccc_v2_subconditions.rds
#   ./pccc_v2_r_sas_stata.rds
#
# output: pccc_v2.1.rds
#
# deps: data.table
#
# notes:
#   Normalises condition/subcondition naming, resolves misc vs specific
#     duplicates, and retains provenance flags (docx/r/sas/stata).
#
# idempotent: yes (deterministic data wrangling)
################################################################################

################################################################################
# file: pccc_v2.1.R
#
# Import the code ranges, conditions, and subconditions for pccc v2.  The source
# file was the result of a copy and paste from Word to Excel to tab delim file.
#
# Also import codes from other sources and build a dataset pccc_v2.1
library(data.table)

known_icd_codes <- readRDS("../icd/icd_codes.rds")
setDT(known_icd_codes)

V2 <- readRDS("pccc_v2.0.rds")
setDT(V2)

# because I will be copying rows with a couple overwrites the code_id might not
# be consistent.  Just drop it and get it back later.  The chap_id and
# subchap_id are not part of V2 (see pccc_v2.0.R) and are also not needed for
# this work in any way.
known_icd_codes[, chap_id := NULL]
known_icd_codes[, subchap_id := NULL]
known_icd_codes[, code_id := NULL]
V2[, code_id := NULL]

subconditions <- readRDS("pccc_v2_subconditions.rds")
setDT(subconditions)

rss_codes <- readRDS("pccc_v2_r_sas_stata.rds")
setDT(rss_codes)

# The R, SAS, and Stata codes only report conditions and mapped transplant and
# tech_dep to a condition. This really should be condition = 'misc' with
# subconditions of 'transplant' or 'device and technology use'. Create the
# subcondition column in the rss_codes object.  This will create several
# redundant columns which we will clean up in the next section of this script.
rss_codes[condition == "transplant",
          `:=`(condition = "misc", subcondition = "transplantation")]
rss_codes[condition == "tech_dep",
          `:=`(condition = "misc", subcondition = "device and technology use")]

# merge on more the subconditions
rss_codes <-
  merge(x = rss_codes,
        y = subconditions[, .(condition, dx, icdv, code, subcondition)],
        all.x = TRUE,
        all.y = FALSE,
        by = c("condition", "dx", "icdv", "code"))
rss_codes[, subcondition := fcoalesce(subcondition.x, subcondition.y)]
rss_codes[, subcondition.x := NULL]
rss_codes[, subcondition.y := NULL]
rss_codes <- unique(rss_codes)

# combine the references into one set and look for discrepancies
subconditions[, docx := 1L]
v2ref <-
  merge(subconditions[, .(icdv, dx, full_code, code, condition, subcondition, docx)],
        rss_codes,
        all = TRUE,
        by = c("icdv", "dx", "code", "condition", "subcondition"))

# Build indicators for this work.
#
#  1: code is in the reference
#  0: code is not in the reference and has been reviewed
# -1: code is not in the reference and has not been reviewed

v2ref[, docx  := nafill(docx,  fill = -1L, type = "const")]
v2ref[, r     := nafill(r,     fill = -1L, type = "const")]
v2ref[, sas   := nafill(sas,   fill = -1L, type = "const")]
v2ref[, stata := nafill(stata, fill = -1L, type = "const")]

stopifnot(isTRUE(all(v2ref$docx  %in% c(-1, 1))))
stopifnot(isTRUE(all(v2ref$r     %in% c(-1, 1))))
stopifnot(isTRUE(all(v2ref$sas   %in% c(-1, 1))))
stopifnot(isTRUE(all(v2ref$stata %in% c(-1, 1))))

v2ref <- unique(v2ref)

################################################################################
# Go through the codes and fix anything that is different between the four
# sources.

# ICD-9-PCS 00.50, 00.51, 00.53, 00.54, 00.55, 00.57
#
# These codes are not in the docx but are in R, SAS, and Stata
#
# Looking at the V3 documentation all these codes are listed as misc; device and
# tech use.
#
v2ref[code %in% c("0050", "0051", "0053", "0054", "0055", "0057") & dx == 0 & icdv == 9L,
      `:=`(docx = 0L)]

# ICD-9-PCS 02.2[12] are neuromusc; device and technology use.  There are rows for
# condition = "misc" coming from the rss_codes.  This is an issue that will
# affect a lot of codes.
#
# let's omit the misc; device and technology use iff there is a non-misc condition
# with device and technology use subcondtion
devices <- v2ref[subcondition == "device and technology use"]
devices[, ismisc := condition == "misc"]
setkey(devices, icdv, dx, code, ismisc)
devices[, dup := duplicated(.SD, by = c("icdv", "dx", "code"))]
miscdup <- devices[(ismisc) & (dup)]
v2ref <- v2ref[!miscdup, on = c("icdv", "dx", "code", "condition", "subcondition")]

# Similar issue for transplants
transplants <- v2ref[subcondition == "transplantation"]
transplants[, ismisc := condition == "misc"]
setkey(transplants, icdv, dx, code, ismisc)
transplants[, dup := duplicated(.SD, by = c("icdv", "dx", "code"))]
miscdup <- transplants[(ismisc) & (dup)]
v2ref <- v2ref[!miscdup, on = c("icdv", "dx", "code", "condition", "subcondition")]

# ICD-9-PCS 02.2
if (interactive()) {
  v2ref[grepl("^022", code) & icdv == 9 & dx == 0]
  known_icd_codes[grepl("^022", code) & icdv == 9 & dx == 0]
}
# Because all known four digit ICD-9-PCS codes under 02.2 are in v2ref set the
# indicators for r sas and stata to 0 for the three digit code 02.2
#
v2ref[code == "022" & icdv == 9 & dx == 0, `:=`(r = 0, sas = 0, stata = 0)]

# ICD-9-PCS 02.3
if (interactive()) {
  v2ref[grepl("^023", code) & icdv == 9 & dx == 0]
  known_icd_codes[grepl("^023", code) & icdv == 9 & dx == 0]
}
# because all known four digit ICD-9-PSC codes under the three digit 02.3 are in
# the v2ref, keep the three digit, set the indicators for r, sas, and stata to 0
v2ref[code == "023" & icdv == 9 & dx == 0, `:=`(r = 0, sas = 0, stata = 0)]

# ICD-9-PCS 02.4
if (interactive()) {
  v2ref[grepl("^024", code) & icdv == 9 & dx == 0]
  known_icd_codes[grepl("^024", code) & icdv == 9 & dx == 0]
}
# The docx has the three digit 02.4 and the four digit 02.41, 02.42.
# The four digit code 02.43 is a valid code but is not listed when other four
# digit codes are listed.
#
# subset(get_icd_codes(with.description = T), grepl("^024", code) & icdv == 9 & dx == 0)
# #       icdv dx full_code code    src known_start known_end assignable_start assignable_end                                                   desc desc_start desc_end
# #  1864    9  0      02.4  024 cm_pcs        1997      2015               NA             NA Revision, removal, and irrigation of ventricular shunt       1997     2015
# #  1865    9  0     02.41 0241 cm_pcs        1997      2015             1997           2015                        Irrigation of ventricular shunt       1997     2002
# #  1866    9  0     02.41 0241 cm_pcs        1997      2015             1997           2015        Irrigation and exploration of ventricular shunt       2003     2015
# #  1867    9  0     02.42 0242 cm_pcs        1997      2015             1997           2015                       Replacement of ventricular shunt       1997     2015
# #  1868    9  0     02.43 0243 cm_pcs        1997      2015             1997           2015                           Removal of ventricular shunt       1997     2015
#
# With 02.43 being the _removal_ of the shunt, it seems to me that the kid had,
# but no longer has, the neuromusc condition and tech_dep.
#
# Remove the header code since not all subcodes are in.
v2ref <- v2ref[!(code %in% c("024", "0243") & icdv == 9 & dx == 0)]

# ICD-9-PCS 03.7
if (interactive()) {
  v2ref[grepl("^037", code) & icdv == 9 & dx == 0]
  known_icd_codes[grepl("^037", code) & icdv == 9 & dx == 0]
}
# With all known subcodes flagged keep the header
v2ref[code == "037" & icdv == 9 & dx == 0,
      `:=`(r = 0, sas = 0, stata = 0)]

# ICD-9-PCS 31.2
if (interactive()) {
  v2ref[grepl("^312", code) & icdv == 9 & dx == 0]
  known_icd_codes[grepl("^312", code) & icdv == 9 & dx == 0]
}
# all sub codes are listed, keep header
v2ref[code == "312" & icdv == 9 & dx == 0,
      `:=`(r = 0, sas = 0, stata = 0)]

# ICD-9-PCS 32.4
if (interactive()) {
  v2ref[grepl("^324", code) & icdv == 9 & dx == 0]
  known_icd_codes[grepl("^324", code) & icdv == 9 & dx == 0]
}
# all sub codes are listed, keep header
v2ref[code == "324" & icdv == 9 & dx == 0,
      `:=`(r = 0, sas = 0, stata = 0)]

# ICD-9-PCS 32.5
if (interactive()) {
  v2ref[grepl("^325", code) & icdv == 9 & dx == 0]
  known_icd_codes[grepl("^325", code) & icdv == 9 & dx == 0]
}
# all sub codes are listed, keep header
v2ref[code == "325" & icdv == 9 & dx == 0,
      `:=`(r = 0, sas = 0, stata = 0)]

# ICD-9-PCS 33.5
if (interactive()) {
  v2ref[grepl("^335", code) & icdv == 9 & dx == 0]
  known_icd_codes[grepl("^335", code) & icdv == 9 & dx == 0]
}
# Respiratory transplant, 33.5 is the header with all assignable codes in the R,
# SAS, and Stata
v2ref[code == "335" & icdv == 9 & dx == 0,
      `:=`(r = 0, sas = 0, stata = 0)]

# ICD-9-PCS 35.8
if (interactive()) {
  v2ref[grepl("^358", code) & icdv == 9 & dx == 0]
  known_icd_codes[grepl("^358", code) & icdv == 9 & dx == 0]
}
# header with all asssignable
v2ref[code == "358" & icdv == 9 & dx == 0,
      `:=`(r = 0, sas = 0, stata = 0)]

# ICD-9-PCS 37.5
if (interactive()) {
  v2ref[grepl("^375", code) & icdv == 9 & dx == 0]
  known_icd_codes[grepl("^375", code) & icdv == 9 & dx == 0]
}
#
# This is interesting.  From the docx file:
# 37.52, 37.53, 37.54, 37.55 - cvd; device
# 37.5, 37.51 - cvd; transplant
#
# Looks right.  set the r, sas, stata indicators to 0
#
# subset(get_icd_codes(with.description = T), grepl("^375", code) & icdv == 9 & dx == 0)
# #        icdv dx full_code code    src known_start known_end assignable_start assignable_end                                                                                     desc
# #  12438    9  0      37.5  375 cm_pcs        1997      2015             1997           2003                                                                    Heart transplantation
# #  12439    9  0     37.51 3751 cm_pcs        2004      2015             2004           2015                                                                    Heart transplantation
# #  12440    9  0      37.5  375 cm_pcs        1997      2015             1997           2003                                                             Heart replacement procedures
# #  12467    9  0     37.52 3752 cm_pcs        2004      2015             2004           2015                                           Implantation of total replacement heart system
# #  12468    9  0     37.52 3752 cm_pcs        2004      2015             2004           2015                    Implantation of total internal biventricular heart replacement system
# #  12478    9  0     37.53 3753 cm_pcs        2004      2015             2004           2015                 Replacement or repair of thoracic unit of total replacement heart system
# #  12479    9  0     37.53 3753 cm_pcs        2004      2015             2004           2015               Replacement or repair of thoracic unit of (total) replacement heart system
# #  12490    9  0     37.54 3754 cm_pcs        2004      2015             2004           2015   Replacement or repair of other implantable component of total replacement heart system
# #  12491    9  0     37.54 3754 cm_pcs        2004      2015             2004           2015 Replacement or repair of other implantable component of (total) replacement heart system
# #  12500    9  0     37.55 3755 cm_pcs        2009      2015             2009           2015                               Removal of internal biventricular heart replacement system
v2ref[code == "375" & icdv == 9 & dx == 0,
      `:=`(r = 0, sas = 0, stata = 0)]

# ICD-9-PCS 37.6
if (interactive()) {
  v2ref[grepl("^376", code) & icdv == 9 & dx == 0]
  known_icd_codes[grepl("^376", code) & icdv == 9 & dx == 0]
}
#stopifnot(v2ref[, all(docx >= 0 & r >= 0 & sas >= 0 & stata >= 0)])

# ICD-9-PCS 37.7
# It appears that 37.7 is in the documentation, but not all the subcodes are in
# the software.  Looking at the documentation for v3 the mappings in r, sas, and
# stata are correct and the use of the header 37.7 should not be used.
if (interactive()) {
  known_icd_codes[grepl("^377", code) & icdv == 9 & dx == 0]
  v2ref[grepl("^377", code) & icdv == 9 & dx == 0] |> print(nrow = Inf)
}
v2ref <- v2ref[!(grepl("^377", code) & icdv == 9 & dx == 0 & r == -1 & sas == -1 & stata == -1)]

# ICD-9-PCS 42.1
# 42.1 is a header in the codes, but 42.12 and 42.19 are not in any of the
# software and that seems the same in docs for v3
if (interactive()) {
  known_icd_codes[grepl("^421", code) & icdv == 9 & dx == 0]
  v2ref[grepl("^421", code) & icdv == 9 & dx == 0] |> print(nrow = Inf)
}
v2ref <- v2ref[!(grepl("^421", code) & icdv == 9 & dx == 0 & r == -1 & sas == -1 & stata == -1)]

# ICD-9-PCS 44.3 and 44.31
# It appears that 44.3 is an errant header code in the docs for v2.  44.3 and
# 44.31 are not in the software and this is the same in v3 docs
if (interactive()) {
  known_icd_codes[grepl("^443", code) & icdv == 9 & dx == 0]
  v2ref[grepl("^443", code) & icdv == 9 & dx == 0] |> print(nrow = Inf)
}
v2ref <- v2ref[!(grepl("^443", code) & icdv == 9 & dx == 0 & r == -1 & sas == -1 & stata == -1)]

# ICD-9-PCS 46.1 is a header code in the docs but only 46.13 is in the mappings
# in the software, similar for v3 docs
if (interactive()) {
  known_icd_codes[grepl("^461", code) & icdv == 9 & dx == 0]
  v2ref[grepl("^461", code) & icdv == 9 & dx == 0] |> print(nrow = Inf)
}
v2ref <- v2ref[!(grepl("^461", code) & icdv == 9 & dx == 0 & r == -1 & sas == -1 & stata == -1)]

# ICD-9-PCS 46.2 is another header code that shouldn't be in the mappings as
# only a couple of the four-digit codes are in the software and a similar set of
# maps for v3
if (interactive()) {
  known_icd_codes[grepl("^462", code) & icdv == 9 & dx == 0]
  v2ref[grepl("^462", code) & icdv == 9 & dx == 0] |> print(nrow = Inf)
}
v2ref <- v2ref[!(grepl("^462", code) & icdv == 9 & dx == 0 & r == -1 & sas == -1 & stata == -1)]

# ICD-9-PCS 46.3 is another header code that shouldn't be in the mappings as
# only a couple of the four-digit codes are in the software and a similar set of
# maps for v3
if (interactive()) {
  known_icd_codes[grepl("^463", code) & icdv == 9 & dx == 0]
  v2ref[grepl("^463", code) & icdv == 9 & dx == 0] |> print(nrow = Inf)
}
v2ref <- v2ref[!(grepl("^463", code) & icdv == 9 & dx == 0 & r == -1 & sas == -1 & stata == -1)]

# ICD-9-PCS 46.4 is another header code that shouldn't be in the mappings as
# only a couple of the four-digit codes are in the software and a similar set of
# maps for v3
if (interactive()) {
  known_icd_codes[grepl("^464", code) & icdv == 9 & dx == 0]
  v2ref[grepl("^464", code) & icdv == 9 & dx == 0] |> print(nrow = Inf)
}
v2ref <- v2ref[!(grepl("^464", code) & icdv == 9 & dx == 0 & r == -1 & sas == -1 & stata == -1)]

# ICD-9-PCS 52.8 is another header code that shouldn't be in the mappings as
# 50.81 should not be in the mappings while all other four-digit codes under
# 50.8 should be in the mappings
if (interactive()) {
  known_icd_codes[grepl("^528", code) & icdv == 9 & dx == 0]
  v2ref[grepl("^528", code) & icdv == 9 & dx == 0] |> print(nrow = Inf)
}
v2ref <- v2ref[!(grepl("^528", code) & icdv == 9 & dx == 0 & r == -1 & sas == -1 & stata == -1)]

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
# set the renal
#
if (interactive()) {
  known_icd_codes[grepl("^567", code) & icdv == 9 & dx == 0]
  v2ref[grepl("^567", code) & icdv == 9 & dx == 0] |> print(nrow = Inf)
}
# omit the header
v2ref <- v2ref[!(grepl("^567", code) & icdv == 9 & dx == 0 & r == -1 & sas == -1 & stata == -1)]
# remove unwanted renal (device) mappings
v2ref <- v2ref[!(grepl("^567[19]", code) & icdv == 9 & dx == 0 & grepl("device", subcondition))]
# remove unwanted renal (other)
v2ref <- v2ref[!(grepl("^567[2345]", code) & icdv == 9 & dx == 0 & grepl("other", subcondition))]

# ICD-9-PCS 89.45
# Not listed in the documentation, it is listed in the procedure codes for cvd
# in the software and ad device
# Codes 89.4[6-9] are all CVD device and technology use
# v2ref[grepl("^8945", code) & icdv == 9 & dx == 0]
v2ref[grepl("^8945", code) & icdv == 9 & dx == 0,
          `:=`(condition = "cvd", subcondition = "device and technology use") ]
v2ref <- unique(v2ref)

# ICD-9-CM 359.24
# This code is documented in v3 to be removed.  It is missing from sas and
# stata, in R.  Omit this code and the header 359.2
if (interactive()) {
  known_icd_codes[grepl("^3592", code) & icdv == 9 & dx == 1]
  v2ref[grepl("^3592", code) & icdv == 9 & dx == 1] |> print(nrow = Inf)
}
v2ref <- v2ref[!(code %in% c("3592", "35924") & icdv == 9 & dx == 1)]

# ICD-9-CM 757.39
# This code only appears in the documentation for v2.  It is not in any of the
# software, and it is not in the documentation for v3.
# 757.39 is for Other specified anomalies of skin, unlikely to be a correct
# code.  It is worth notting that this is the only 757 code in v2
# Omit it.
if (interactive()) {
  known_icd_codes[grepl("^75739", code) & icdv == 9 & dx == 1]
  v2ref[grepl("^75739", code) & icdv == 9 & dx == 1] |> print(nrow = Inf)
  v2ref[grepl("^757", code) & icdv == 9 & dx == 1] |> print(nrow = Inf)
}
v2ref <- v2ref[!(code == "75739" & icdv == 9 & dx == 1)]

# ICD-9-CM 767
# This header is in the v2 docs but very few of the codes are used in the
# software.  Same in v3.
#
# 767.4 is mapped to two subconditions, 767.0 to one subcondition
if (interactive()) {
  known_icd_codes[grepl("^767", code) & icdv == 9 & dx == 1]
  v2ref[grepl("^767", code) & icdv == 9 & dx == 1] |> print(nrow = Inf)
}
v2ref <- v2ref[!(grepl("^767", code) & icdv == 9 & dx == 1 & r == -1 & sas == -1 & stata == -1)]

# ICD-10-CM I49.2 - per v3 docs, this code was errantly listed in the docs and
# should be omitted.
if (interactive()) {
  known_icd_codes[grepl("^I492", code) & icdv == 10 & dx == 1]
  v2ref[grepl("^I492", code) & icdv == 10 & dx == 1] |> print(nrow = Inf)
}
v2ref <- v2ref[!(grepl("^I492", code) & icdv == 10 & dx == 1 & r == -1 & sas == -1 & stata == -1)]

# ICD-10-CM Z94.2
# This should be respiratory (transplantation).  The R, Stata, and SAS software
# has this as respiratory (transplantation) and misc (device and technology
# use).  The documentation only notes respiratory (transplantation).  FIX: drop
# the errant row
if (interactive()) {
  rss_codes[code == "Z942"]
  v2ref[code == "Z942"]
}
v2ref <- v2ref[!(code == "Z942" & condition == "misc")]

# NOTE: There are going to be a lot of codes to deal with later.  Let's get the
# method running and then edit the codes

v2ref[, docx := NULL]
v2ref[, r := NULL]
v2ref[, sas := NULL]
v2ref[, stata := NULL]
v2ref <- unique(v2ref)

v2ref <- v2ref[!is.na(subcondition)]

# clean up some of the subconditions to be consistent with other sources
v2ref[subcondition == "storage disorder", subcondition := "storage disorders"]
v2ref[subcondition == "device & technology use", subcondition := "device and technology use"]
v2ref[subcondition == "mental retardation", subcondition := "intellectual disabilities"]
v2ref[subcondition == "other disorders of cns", subcondition := "other neurologic disorders"]
v2ref[subcondition == "inflammatory bowel diseases", subcondition := "inflammatory bowel disease"]
v2ref[subcondition == "diaphragm and abdominal wall", subcondition := "diaphragm and abdominal wall anomalies"]

# set flags
v2ref[, tech_dep_flag := as.integer(subcondition == "device and technology use")]
v2ref[, transplant_flag := as.integer(subcondition == "transplantation")]
v2ref[, tech_dep_flag := max(tech_dep_flag), by = .(icdv, dx, code)]
v2ref[, transplant_flag := max(transplant_flag), by = .(icdv, dx, code)]

# Codes which are device and tech in misc should only be retained if not in
# another conidtion.  same for transplant.
non_misc_tech <- v2ref[condition != "misc" & subcondition == "device and technology use"]
non_misc_tran <- v2ref[condition != "misc" & subcondition == "transplantation"]

# remove the "misc" rows
v2ref <-
  v2ref[!(condition    ==   "misc" &
          subcondition ==   "device and technology use" &
          code         %in% non_misc_tech$code)]

v2ref <-
  v2ref[!(condition    ==   "misc" &
          subcondition ==   "transplantation" &
          code         %in% non_misc_tran$code)]

################################################################################
# Needed edits

# ICD-9-CM 235.9 is listed in the word document as Metabolic (endocrine
# disorders)  However, it appears to me that is a typo.  253.2, 253.6, and 235.9
# are listed and I think that 235.9 should be 253.9.  This also will fix having
# 235.9 mapping to malignancy and metabolic which doesn't seem right.
v2ref[code == "2359" & condition == "metabolic", `:=`(code = "2539", full_code = "253.9")]

# ICD-9-CM 331 is a header code that can/should be part of this set.  Also,
# 331.0 was missing from the docs, but the 331 in the souce code for the
# software flagged it.  331.1 also needs to be here as it was assignable and
# then became a header.
#
# 331.5 as in the v2 software, but was removed for v3, so keep it out for v2.1
#
# Since 331.5 is out v2.1, then 331 needs to be out too!
v2ref <-
  rbind(v2ref,
        rbind(
          V2[code == "331" & icdv == 9][, `:=`(code = "3310", full_code = "331.0")],
          V2[code == "331" & icdv == 9][, `:=`(code = "3311", full_code = "331.1")],
          V2[code == "331" & icdv == 9][, `:=`(code = "3312", full_code = "331.2")],
          V2[code == "331" & icdv == 9][, `:=`(code = "3316", full_code = "331.6")],
          V2[code == "331" & icdv == 9][, `:=`(code = "3317", full_code = "331.7")],
          V2[code == "331" & icdv == 9][, `:=`(code = "3317", full_code = "331.8")]
        )[, .SD, .SDcols = names(v2ref)],
        use.names = TRUE
        )

# ICD-9-CM 416.0 is missing from the documentation but is in the software and
# based on the v3 docs should have been in the set as respiratory, the same as
# 416.2
v2ref <-
  rbind(v2ref,
        v2ref[code == "4162" & condition == "respiratory"][, `:=`(code = "4160", full_code = "416.0")]
        )

# ICD-9-CM V08 is in the software for v2.0, and in v3.0  It is not in the
# documentation for V2.  It is documented in V3 as missing in the V2 docs.
v2ref <-
  rbind(
    v2ref,
    V2[code == "V08", .(icdv, dx, code, condition, subcondition, full_code, tech_dep_flag, transplant_flag)]
  )

# ICD-9-CM V53.3 is a header code, should be part of v2.1, is part of v2.0
v2ref <-
  rbind(
    v2ref,
    V2[code == "V533", .(icdv, dx, code, condition, subcondition, full_code, tech_dep_flag, transplant_flag)]
  )

# ICD-9-CM V45.85 and V53.91 are marked in the R, SAS, and Stata code as
# transplant when it should be tech dependence
# rss_codes[code %in% c("V4585", "V5391")]
v2ref <- v2ref[!(code %in% c("V4585", "V5391") & condition == "misc")]
v2ref[code %in% c("V4585", "V5391"), transplant_flag := 0L]

# ICD-9-CM 277 is a header listed in the documentation for respiratory
# (cystic_fibrosis).  However, that is not how it is implimented.  Some of 277
# maps to respiratory, some maps to metabolic.  Also, in the
# documentation for v3 none of the 277 codes are duplicated.
# FIX: drop 277 form v2ref
#
# This issue, also requries 2771, 2773, 2777, and 2778 to be removed
v2ref <- v2ref[!(code == "277" & dx == 1 & icdv == 9)]
v2ref <- v2ref[!(code == "2771" & dx == 1 & icdv == 9)]
v2ref <- v2ref[!(code == "2773" & dx == 1 & icdv == 9)]
v2ref <- v2ref[!(code == "2777" & dx == 1 & icdv == 9)]
v2ref <- v2ref[!(code == "2778" & dx == 1 & icdv == 9)]

v2ref <- v2ref[!(grepl("^2772", code) & dx == 1 & icdv == 9 & condition == "respiratory")]
v2ref <- v2ref[!(grepl("^2773", code) & dx == 1 & icdv == 9 & condition == "respiratory")]
v2ref <- v2ref[!(grepl("^2774", code) & dx == 1 & icdv == 9 & condition == "respiratory")]
v2ref <- v2ref[!(grepl("^2775", code) & dx == 1 & icdv == 9 & condition == "respiratory")]
v2ref <- v2ref[!(grepl("^2776", code) & dx == 1 & icdv == 9 & condition == "respiratory")]
v2ref <- v2ref[!(grepl("^2778", code) & dx == 1 & icdv == 9 & condition == "respiratory")]
v2ref <- v2ref[!(grepl("^2779", code) & dx == 1 & icdv == 9 & condition == "respiratory")]

# ICD-9-PCS 37.6, 37.62, 37.64 need to be omitted, same issue as ICD-9-CM 277
v2ref <- v2ref[!(code == "376" & dx == 0 & icdv == 9)]
v2ref <- v2ref[!(code == "3762" & dx == 0 & icdv == 9)]
v2ref <- v2ref[!(code == "3764" & dx == 0 & icdv == 9)]

# ICD-9-PCS 37.5 is a header code that shouldn't be in the set.  37.5x maps cvd,
# but to different subconditions
v2ref <- v2ref[!(code == "375" & dx == 0 & icdv == 9)]

# ICD-9-CM 277.3 and 277.8 are both headers that can/should be part of v2.1 and
# v3.1
if (interactive()) {
  known_icd_codes[grepl("^2773", code) & icdv == 9 & dx == 1]
  v2ref[grepl("^2773", code) & icdv == 9 & dx == 1] |> print(nrow = Inf)
  V2[grepl("^2773", code)]

  known_icd_codes[grepl("^2778", code) & icdv == 9 & dx == 1]
  v2ref[grepl("^2778", code) & icdv == 9 & dx == 1] |> print(nrow = Inf)
  V2[grepl("^2778", code)]
}
v2ref <- rbind(v2ref, V2[grepl("^277[38]", code) & icdv == 9 & dx == 1])

# ICD-9-CM 516.3 and related codes
# 516.3 was an assignable code through fiscal year 2011.
#
# Codes 516.30, 516.31, and 516.37 are included in the software.  The other
# five-digit codes are omitted as they may not be chronic conditions
#
# | Code   | Description                                         | Likely reason for omission                                                                                          |
# | ------ | --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
# | 516.32 | Idiopathic non-specific interstitial pneumonitis    | This can be acute, subacute, or chronic — often reversible with treatment, so not always a complex chronic disease. |
# | 516.33 | Acute interstitial pneumonitis                      | Specifically *acute* and often linked to ARDS; high mortality but not chronic by definition.                        |
# | 516.34 | Respiratory bronchiolitis interstitial lung disease | Often associated with smoking, can improve with cessation, not necessarily progressive.                             |
# | 516.35 | Idiopathic lymphoid interstitial pneumonia          | Rare, variable course, sometimes secondary to autoimmune disease; may respond to treatment.                         |
# | 516.36 | Cryptogenic organizing pneumonia                    | Usually responsive to corticosteroids, not considered a chronic progressive fibrosing ILD.                          |
if (interactive()) {
  known_icd_codes[grepl("^5163", code) & icdv == 9 & dx == 1]
  v2ref[grepl("^5163", code) & icdv == 9 & dx == 1] |> print(nrow = Inf)
  V2[grepl("^5163", code)]
}
v2ref <- v2ref[!(code %in% c("51632", "51633", "51634", "51635", "51636"))]

# ICD-9-CM V56, V56.3 are both header codes which should be added since all
# codes within V56 are in the mappings
if (interactive()) {
  known_icd_codes[grepl("^V56", code) & icdv == 9 & dx == 1]
  v2ref[grepl("^V56", code) & icdv == 9 & dx == 1] |> print(nrow = Inf)
  V2[grepl("^V56", code)]
}
v2ref <- rbind(v2ref, V2[grepl("^V56", code)])

# ICD-10-CM E75.3, E75.5, E75.6
# These should map to both neurologic (CNS degeneration and diseases) and
# metabolic (lipid metabolism) -- all E75 codes should for v2.1 and v3.1
v2ref <-
  rbind(
    v2ref,
    v2ref[code == "E75"  & icdv == 10 & dx == 1][, `:=`(condition = "neuromusc", subcondition = "cns degeneration and diseases")],
    v2ref[code == "E753" & icdv == 10 & dx == 1][, `:=`(condition = "neuromusc", subcondition = "cns degeneration and diseases")],
    v2ref[code == "E755" & icdv == 10 & dx == 1][, `:=`(condition = "neuromusc", subcondition = "cns degeneration and diseases")],
    v2ref[code == "E756" & icdv == 10 & dx == 1][, `:=`(condition = "neuromusc", subcondition = "cns degeneration and diseases")]
  )

# ICD-10-CM I43.0, I43.1, I43.2, I43.8
# Listed in the documents is I43 for both respiratory
# (chronic_respiratory_diseases) and cvd (cardiomyopathies).
#
# In the pccc_1.0.6, and all the v3 documentation only cvd (cardiomyopathies) is
# mapped.
v2ref <-
  v2ref[!(grepl("^I43", code) & dx == 1 & icdv == 10 & condition == "respiratory")]

# ICD-10-CM D00, D3A
#v2ref[grepl("^D3A", code)]
D00 <- known_icd_codes[grepl("^D00", code) & icdv == 10 & dx == 1]
v2ref <-
  rbind(v2ref,
        D00[, .(icdv, dx, code, condition = "malignancy", subcondition = "neoplasms", full_code, tech_dep_flag = 0L, transplant_flag = 0L)]
  )

D3A <- known_icd_codes[grepl("^D3A", code) & icdv == 10 & dx == 1]
v2ref <-
  rbind(v2ref,
        D3A[, .(icdv, dx, code, condition = "malignancy", subcondition = "neoplasms", full_code, tech_dep_flag = 0L, transplant_flag = 0L)]
  )

# Some missing codes for v2.1 which are in v2
v2ref <-
  rbind(v2ref,
        V2[full_code %in%
           c("331.3", "349.1", "E70.5",
             "Q89.8", "Q89.81", "Q89.89",
             "V56.0", "V56.1", "V56.2",
             "V56.31", "V56.32", "V56.8", "Z21", "Z49.01", "Z49.02", "Z49.31",
             "Z49.32", "Z79.4")])

v2ref <- unique(v2ref)
################################################################################

setDF(v2ref)
saveRDS(v2ref, file = "pccc_v2.1.rds")

################################################################################
#                                 End of File                                  #
################################################################################
