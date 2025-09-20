################################################################################
# file: icd/icd10/cdc_allvalid.R
#
# purpose: Assemble CDC 'all valid' ICD-10 mortality code tables across years,
#          normalise statuses, and backfill header rows.
#
# inputs:
#   ftp.cdc.gov/.../allvalid2009(detailed titles headings).xls
#   ftp.cdc.gov/.../allvalid2011 (detailed titles headings).xls
#   ftp.cdc.gov/.../allvalid2020 (detailed_titles_headings).csv
#   ftp.cdc.gov/.../allvalid2023-detailed-titles-headings.csv
#
# output: cdc_allvalid.rds (data.table with full_code, code, desc, year, header)
#
# deps: data.table, pbapply, readxl
#
# notes:
#   Source files are expected to be downloaded under data-
#     raw/icd/icd10/ftp.cdc.gov/ prior to running.
#   Cleans duplicate titles, resolves added/deleted status metadata, and fills
#     in missing header codes.
#
# idempotent: yes (deterministic transformations of static CDC inputs)
################################################################################

library(data.table)
library(pbapply)

################################################################################
if (interactive()) {
  dir("ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10/")
}

# This contains the ICD-10 (international version), as published by the World
# Health Organization (WHO), and slightly adapted for U.S. use for
# cause-of-death coding on death certificates.
#
# Purpose: Primarily used for mortality statistics (death certificate coding).
#
# Publisher: WHO, adopted by CDC/NCHS for U.S. Mortality coding.
#
# Titles: Align closely with WHO terminology and structure.
#
# Key file types:
#
# icd10_all_valid_codes_yyyy.txt: All valid mortality codes and their
# descriptions for year yyyy.
#
# Used in National Vital Statistics System (NVSS).
#
# NOTE:
#   All files claim to include both 3-digit and 4-digit codes and titles. This
#   is not true.  2020 2023 do not have all the 3-digit codes.  A check for A00
#   will provide that.
#
#   This will need to be cleaned up before saving the data, that is the last
#   step in this script.

header2023 <- data.table::fread("ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10/allvalid2023-detailed-titles-headings.csv", nrows = 6)
header2020 <- data.table::fread("ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10/allvalid2020 (detailed_titles_headings).csv", nrows = 6)
header2011 <- suppressMessages(readxl::read_xls("ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10/allvalid2011 (detailed titles headings).xls", col_names = FALSE, n_max = 5))
header2009 <- suppressMessages(readxl::read_xls("ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10/allvalid2009(detailed titles headings).xls", col_names = FALSE, n_max = 5))

cdc_allvalid_2023 <- data.table::fread("ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10/allvalid2023-detailed-titles-headings.csv", skip = 6)
cdc_allvalid_2020 <- data.table::fread("ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10/allvalid2020 (detailed_titles_headings).csv", skip = 6)
cdc_allvalid_2011 <- readxl::read_xls("ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10/allvalid2011 (detailed titles headings).xls", skip = 6)
cdc_allvalid_2009 <- readxl::read_xls("ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10/allvalid2009(detailed titles headings).xls", skip = 6)

setDT(cdc_allvalid_2023)
setDT(cdc_allvalid_2020)
setDT(cdc_allvalid_2011)
setDT(cdc_allvalid_2009)

cdc_allvalid_2023 <- unique(cdc_allvalid_2023)
cdc_allvalid_2020 <- unique(cdc_allvalid_2020)
cdc_allvalid_2011 <- unique(cdc_allvalid_2011)
cdc_allvalid_2009 <- unique(cdc_allvalid_2009)

# Look for duplicated information about a code
if (interactive()) {
  cdc_allvalid_2023[duplicated(Code) | duplicated(Code, fromLast = TRUE)]
  cdc_allvalid_2020[duplicated(Code) | duplicated(Code, fromLast = TRUE)]
  cdc_allvalid_2011[duplicated(Code) | duplicated(Code, fromLast = TRUE)]
  cdc_allvalid_2009[duplicated(Code) | duplicated(Code, fromLast = TRUE)]

  cdc_allvalid_2023[Code == "B99"]
  cdc_allvalid_2020[Code == "B99"]
  cdc_allvalid_2011[Code == "B99"]
  cdc_allvalid_2009[Code == "B99"]

  cdc_allvalid_2023[Code == "N99"]
  cdc_allvalid_2020[Code == "N99"]
  cdc_allvalid_2011[Code == "N99"]
  cdc_allvalid_2009[Code == "N99"]

  cdc_allvalid_2023[Code == "T79"]
  cdc_allvalid_2020[Code == "T79"]
  cdc_allvalid_2011[Code == "T79"]
  cdc_allvalid_2009[Code == "T79"]
}

# remove some rows
cdc_allvalid_2011 <- cdc_allvalid_2011[!(Code == "B99" & `ICD Title` == "Other infectious diseases")]
cdc_allvalid_2009 <- cdc_allvalid_2009[!(Code == "B99" & `ICD Title` == "Other infectious diseases")]

cdc_allvalid_2011 <- cdc_allvalid_2011[!(Code == "N99" & `ICD Title` == "Other disorders of the genitorurinary system")]
cdc_allvalid_2009 <- cdc_allvalid_2009[!(Code == "N99" & `ICD Title` == "Other disorders of the genitorurinary system")]

cdc_allvalid_2011 <- cdc_allvalid_2011[!(Code == "T79" & `ICD Title` == "Certain early complications of trauma")]
cdc_allvalid_2009 <- cdc_allvalid_2009[!(Code == "T79" & `ICD Title` == "Certain early complications of trauma")]

setnames(cdc_allvalid_2023, old = c("ICD Title", "Code"), new = c("desc", "full_code"))
setnames(cdc_allvalid_2020, old = c("ICD Title", "Code"), new = c("desc", "full_code"))
setnames(cdc_allvalid_2011, old = c("ICD Title", "Code"), new = c("desc", "full_code"))
setnames(cdc_allvalid_2009, old = c("ICD Title", "Code"), new = c("desc", "full_code"))

setkey(cdc_allvalid_2023, full_code)
setkey(cdc_allvalid_2020, full_code)
setkey(cdc_allvalid_2011, full_code)
setkey(cdc_allvalid_2009, full_code)

cdc_allvalid_2023[is.na(Status), Status := ""]
cdc_allvalid_2020[is.na(Status), Status := ""]
cdc_allvalid_2011[is.na(Status), Status := ""]
cdc_allvalid_2009[is.na(Status), Status := ""]

cdc_allvalid_2023[, Status := trimws(Status)]
cdc_allvalid_2020[, Status := trimws(Status)]
cdc_allvalid_2011[, Status := trimws(Status)]
cdc_allvalid_2009[, Status := trimws(Status)]

cdc_allvalid_2023[, desc := trimws(desc)]
cdc_allvalid_2020[, desc := trimws(desc)]
cdc_allvalid_2011[, desc := trimws(desc)]
cdc_allvalid_2009[, desc := trimws(desc)]

# any row where full_code has a - is not a code, it is a set of codes
cdc_allvalid_2009_sets <- cdc_allvalid_2009[grepl("-", full_code)]
cdc_allvalid_2009      <- cdc_allvalid_2009[!cdc_allvalid_2009_sets]

cdc_allvalid_2011_sets <- cdc_allvalid_2011[grepl("-", full_code)]
cdc_allvalid_2011      <- cdc_allvalid_2011[!cdc_allvalid_2011_sets]

cdc_allvalid_2020_sets <- cdc_allvalid_2020[grepl("-", full_code)]
cdc_allvalid_2020      <- cdc_allvalid_2020[!cdc_allvalid_2020_sets]

cdc_allvalid_2023_sets <- cdc_allvalid_2023[grepl("-", full_code)]
cdc_allvalid_2023      <- cdc_allvalid_2023[!cdc_allvalid_2023_sets]

# copy the data so there is a version for each calendar
cdc_allvalid_2001 <- copy(cdc_allvalid_2009)
cdc_allvalid_2002 <- copy(cdc_allvalid_2009)
cdc_allvalid_2003 <- copy(cdc_allvalid_2009)
cdc_allvalid_2004 <- copy(cdc_allvalid_2009)
cdc_allvalid_2005 <- copy(cdc_allvalid_2009)
cdc_allvalid_2006 <- copy(cdc_allvalid_2009)
cdc_allvalid_2007 <- copy(cdc_allvalid_2009)
cdc_allvalid_2008 <- copy(cdc_allvalid_2009)
cdc_allvalid_2009 <- copy(cdc_allvalid_2009)
#cdc_allvalid_2009
cdc_allvalid_2010 <- copy(cdc_allvalid_2009)
#cdc_allvalid_2011
cdc_allvalid_2012 <- copy(cdc_allvalid_2011)
cdc_allvalid_2013 <- copy(cdc_allvalid_2011)
cdc_allvalid_2014 <- copy(cdc_allvalid_2011)
cdc_allvalid_2015 <- copy(cdc_allvalid_2011)
cdc_allvalid_2016 <- copy(cdc_allvalid_2011)
cdc_allvalid_2017 <- copy(cdc_allvalid_2011)
cdc_allvalid_2018 <- copy(cdc_allvalid_2011)
cdc_allvalid_2019 <- copy(cdc_allvalid_2011)
#cdc_allvalid_2020
cdc_allvalid_2021 <- copy(cdc_allvalid_2020)
cdc_allvalid_2022 <- copy(cdc_allvalid_2020)
#cdc_allvalid_2023
cdc_allvalid_2024 <- copy(cdc_allvalid_2023)
cdc_allvalid_2025 <- copy(cdc_allvalid_2023)

cdc_allvalid_2001[, year := 2001L]
cdc_allvalid_2002[, year := 2002L]
cdc_allvalid_2003[, year := 2003L]
cdc_allvalid_2004[, year := 2004L]
cdc_allvalid_2005[, year := 2005L]
cdc_allvalid_2006[, year := 2006L]
cdc_allvalid_2007[, year := 2007L]
cdc_allvalid_2008[, year := 2008L]
cdc_allvalid_2009[, year := 2009L]
cdc_allvalid_2010[, year := 2010L]
cdc_allvalid_2011[, year := 2011L]
cdc_allvalid_2012[, year := 2012L]
cdc_allvalid_2013[, year := 2013L]
cdc_allvalid_2014[, year := 2014L]
cdc_allvalid_2015[, year := 2015L]
cdc_allvalid_2016[, year := 2016L]
cdc_allvalid_2017[, year := 2017L]
cdc_allvalid_2018[, year := 2018L]
cdc_allvalid_2019[, year := 2019L]
cdc_allvalid_2020[, year := 2020L]
cdc_allvalid_2021[, year := 2021L]
cdc_allvalid_2022[, year := 2022L]
cdc_allvalid_2023[, year := 2023L]
cdc_allvalid_2024[, year := 2024L]
cdc_allvalid_2025[, year := 2025L]

################################################################################
# As one data set
cdc_allvalid <-
  rbind(
    cdc_allvalid_2001,
    cdc_allvalid_2002,
    cdc_allvalid_2003,
    cdc_allvalid_2004,
    cdc_allvalid_2005,
    cdc_allvalid_2006,
    cdc_allvalid_2007,
    cdc_allvalid_2008,
    cdc_allvalid_2009,
    cdc_allvalid_2010,
    cdc_allvalid_2011,
    cdc_allvalid_2012,
    cdc_allvalid_2013,
    cdc_allvalid_2014,
    cdc_allvalid_2015,
    cdc_allvalid_2016,
    cdc_allvalid_2017,
    cdc_allvalid_2018,
    cdc_allvalid_2019,
    cdc_allvalid_2020,
    cdc_allvalid_2021,
    cdc_allvalid_2022,
    cdc_allvalid_2023,
    cdc_allvalid_2024,
    cdc_allvalid_2025
  )

cdc_allvalid <- cdc_allvalid[!(Status == "" & full_code == "" & desc == "")]
cdc_allvalid <- unique(cdc_allvalid)

cdc_allvalid[, full_code := gsub("^\\*", "", full_code)]

################################################################################
# Clean up codes

# Look for an remove codes which have been deleted "in" a year.  My
# understanding is "deleted in 2009" means the code was valid to use in 2009, it
# was deleted during the year and thus not valid in 2010.
if (interactive()) {
  cdc_allvalid[grepl("^Deleted in \\d{4}$", Status)][order(full_code)]
}

deleted_codes <- data.table::fread(text =
"
full_code | year
A09       | 2009
F10.0     | 2007
F11.0     | 2009
F12.0     | 2009
F13.0     | 2009
F14.0     | 2009
F15.0     | 2009
F16.0     | 2009
F17.0     | 2009
F18.0     | 2009
F19.0     | 2009
H54.7     | 2011
I25.2     | 2006
K35.0     | 2011
K35.1     | 2011
K35.9     | 2011
K51.1     | 2009
K85       | 2006
L89       | 2011
M72.3     | 2003
M72.5     | 2003
N18.0     | 2011
N18.8     | 2011
O96       | 2011
O97       | 2011
Q31.4     | 2003
Q35.6     | 2003
R50.0     | 2006
R50.1     | 2006
X34       | 2011
X59       | 2007
")

for (i in seq_len(nrow(deleted_codes))) {
  cidx <- cdc_allvalid[["full_code"]] == deleted_codes[["full_code"]][i]
  yidx <- cdc_allvalid[["year"]]      >  deleted_codes[["year"]][i]
  cdc_allvalid[cidx, Status := ""]
  cdc_allvalid <- cdc_allvalid[!(cidx & yidx)]
}

# added, it looks like "added" means keep if >=
if (interactive()) {
  cdc_allvalid[grepl("Added in \\d{4}", Status, ignore.case = TRUE)][order(full_code)]
}

added_codes <- data.table::fread(text =
"
full_code | year
A09.0     | 2009
A09.9     | 2009
B17.9     | 2011
B33.4     | 2006
D68.5     | 2011
D68.6     | 2011
D89.3     | 2011
E16.4     | 2003
E88.3     | 2011
G14       | 2011
G21.4     | 2011
G90.4     | 2006
H54.9     | 2011
I15       | 2006
I15.0     | 2006
I15.9     | 2006
I27.2     | 2003
I72.5     | 2011
J09       | 2007
J12.3     | 2011
J21.1     | 2011
K12.3     | 2011
K22.7     | 2006
K31.7     | 2003
K35.2     | 2011
K35.3     | 2011
K35.8     | 2011
K52.3     | 2009
K63.5     | 2003
K75.4     | 2003
K85.0     | 2006
K85.1     | 2006
K85.2     | 2006
K85.3     | 2006
K85.8     | 2006
K85.9     | 2006
L89.0     | 2011
L89.1     | 2011
L89.2     | 2011
L89.3     | 2011
L89.9     | 2011
M31.7     | 2006
M72.6     | 2003
M79.7     | 2006
N18.1     | 2011
N18.2     | 2011
N18.3     | 2011
N18.4     | 2011
N18.5     | 2011
N42.3     | 2011
O14.2     | 2011
O43.2     | 2011
O96.0     | 2011
O96.1     | 2011
O96.9     | 2011
O97.0     | 2011
O97.1     | 2011
O97.9     | 2011
O98.7     | 2011
P91.6     | 2006
Q31.5     | 2003
R26.3     | 2009
R29.6     | 2006
R50.2     | 2006
R50.8     | 2006
R63.6     | 2009
U01       | 2001
U01.0     | 2001
U01.1     | 2001
U01.2     | 2001
U01.3     | 2001
U01.4     | 2001
U01.5     | 2001
U01.6     | 2001
U01.7     | 2001
U01.8     | 2001
U01.9     | 2001
U02       | 2001
U03       | 2001
U03.0     | 2001
U03.9     | 2001
U04       | 2007
U04.9     | 2007
U07.0     | 2019
U07.1     | 2020
U09.9     | 2023
W46       | 2006
X34.0     | 2011
X34.1     | 2011
X34.8     | 2011
X34.9     | 2011
X59.0     | 2007
X59.9     | 2007
")

for (i in seq_len(nrow(added_codes))) {
  cidx <- cdc_allvalid[["full_code"]] == added_codes[["full_code"]][i]
  yidx <- cdc_allvalid[["year"]] < added_codes[["year"]][i]
  if (!any(yidx)) {
    yidx <- cdc_allvalid[["year"]] <= cdc_allvalid[cidx, min(year)]
  }
  cdc_allvalid[cidx & yidx, year := added_codes[["year"]][i]]
  cdc_allvalid[cidx, Status := ""]
}

if (interactive()) {
  cdc_allvalid[grepl("Added in \\d{4}", Status, ignore.case = TRUE)][order(full_code)]
}
stopifnot(
  cdc_allvalid[grepl("Added in \\d{4}", Status, ignore.case = TRUE)][, .N == 0L]
)

cdc_allvalid[Status == "MC ONLY",               Status := ""]
cdc_allvalid[Status == "Title updated in 2017", Status := ""]
cdc_allvalid[Status == "Title updated in 2023", Status := ""]

################################################################################
# header codes are missing from the 2020 and 2023 files.
cdc_allvalid[, code := sub("\\.", "", full_code)]
stopifnot(cdc_allvalid[, all(nchar(code) %in% 3:4)])

cdc_allvalid[nchar(code) == 4, h3 := substr(x = code, 1, 3)]
header_codes <- cdc_allvalid[nchar(code) == 4, unique(h3)]

headers <- cdc_allvalid[!is.na(h3), .(min(year), max(year)), by = .(h3)]
headers <-
  headers |>
  split(by = "h3") |>
  lapply(function(x) {
    data.table(code = x$h3, full_code = x$h3, year = seq(x$V1, x$V2))
    }) |>
  rbindlist()

headers <-
  merge(
    x = unique(cdc_allvalid[, .(code, desc, year)]),
    y = headers,
    all.y = TRUE,
    by = c("code", "year")
  )

setkey(headers, code, year)
headers[, desc := zoo::na.locf(desc), by = .(code)]

cdc_allvalid <- rbind(headers, cdc_allvalid, use.names = TRUE, fill = TRUE)
cdc_allvalid[, Status := NULL]
cdc_allvalid[, h3 := NULL]
cdc_allvalid[, header := as.integer(code %in% header_codes)]

################################################################################
cdc_allvalid <- unique(cdc_allvalid)

# Look for duplicated code/year combinations
if (interactive()) {
  cdc_allvalid[, .SD[duplicated(.SD, by = c("full_code", "year")) |
                     duplicated(.SD, by = c("full_code", "year"), fromLast = TRUE)]]# |> print(nrow = Inf)
}

stopifnot(
  cdc_allvalid[, .SD[duplicated(.SD, by = c("full_code", "year")) |
                     duplicated(.SD, by = c("full_code", "year"), fromLast = TRUE)]][, .N == 0]
)


################################################################################
setDF(cdc_allvalid)
saveRDS(cdc_allvalid, file = "cdc_allvalid.rds")

################################################################################
#                                 End of File                                  #
################################################################################
