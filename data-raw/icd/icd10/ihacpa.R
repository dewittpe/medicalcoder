################################################################################
# file: icd/icd10/ihacpa.R
#
# purpose: Import the ICD-10-AM codes
#
# inputs: ihacpa/*.txt
#
# output: ihacpa_icd10.rds (data.table with code, desc, header, dx, year, src)
#
# deps: data.table
#
# notes:
#
# idempotent: yes
################################################################################
codes <-
  list.files(
    path = './ihacpa',
    pattern = "\\.txt$",
    full.names = TRUE
  )
codes <- stats::setNames(codes, basename(codes))

codes <-
  lapply(codes, scan, what = character(), sep = "\n", quiet = !interactive()) |>
  lapply(function(x) {
    data.table::data.table(
      full_code = trimws(substr(x = x, start = 1L, stop = 7L)),
      description = trimws(substr(x = x, start = 8L, stop = nchar(x)))
    )
  }) |>
  data.table::rbindlist(idcol = "file")

# Found an error in the codes, X27.1 Contact with a platypus should by X27.0
codes[full_code == "X27.1" & description == "Contact with platypus", full_code := "X27.0"]

#codes[full_code == "G82.50", .N == 0]
codes[full_code == "G82.51" & description == "Tetraplegia, unspecified", full_code := "G82.50"]

#codes[full_code == "S34.70", .N == 0]
codes[full_code == "S34.71" & description == "Functional spinal cord injury, lumbar level unspecified", full_code := "S34.70"]

#codes[full_code == "U55.20", .N == 0]
codes[full_code == "U55.21" & description == "Skiing, alpine and downhill", full_code := "U55.20"]

# There codes W02.7, W02.8, and W02.9 were delted in the fifth edition
#   W02.7 Fall involving baby carriage
#   W02.8 Fall involving baby walker
#   W02.9 Fall involving other and unspecified pedestrian conveyance
#
# Keep the other stem for now
codes <-
  codes[!(
            full_code %in% c("W02.7", "W02.8", "W02.9") &
            description %in% c(
              "Fall involving baby carriage",
              "Fall involving baby walker",
              "Fall involving other and unspecified pedestrian conveyance"
            )
        )]

# build the compact codes
codes[, code := sub("\\.", "", full_code)]

# | Edition    | Start                 | End                    | url                                                                     |
# | :-------   | :-------------------- | :--------------------- | :------------------------------------------------------------------     |
# | First      | 1 July 1998 (FY 1999) | 30 June 2000 (FY 2000) | https://www.ihacpa.gov.au/resources/icd-10-ammbs-eacs-first-edition     |
# | Second     | 1 July 2000 (FY 2001) | 30 June 2002 (FY 2002) | https://www.ihacpa.gov.au/resources/icd-10-ammbs-eacs-second-edition    |
# | Third      | 1 July 2002 (FY 2003) | 30 June 2004 (FY 2004) | https://www.ihacpa.gov.au/resources/icd-10-amachiacs-third-edition      |
# | Fourth     | 1 July 2004 (FY 2005) | 30 June 2006 (FY 2006) | https://www.ihacpa.gov.au/resources/icd-10-amachiacs-fourth-edition     |
# | Fifth      | 1 July 2006 (FY 2007) | 30 June 2008 (FY 2008) | https://www.ihacpa.gov.au/resources/icd-10-amachiacs-fifth-edition      |
# | Sixth      | 1 July 2008 (FY 2009) | 30 June 2010 (FY 2010) | https://www.ihacpa.gov.au/resources/icd-10-amachiacs-sixth-edition      |
# | Seventh    | 1 July 2010 (FY 2011) | 30 June 2013 (FY 2013) | https://www.ihacpa.gov.au/resources/icd-10-amachiacs-seventh-edition    |
# | Eighth     | 1 July 2013 (FY 2014) | 30 June 2015 (FY 2015) | https://www.ihacpa.gov.au/resources/icd-10-amachiacs-eighth-edition     |
# | Ninth      | 1 July 2015 (FY 2015) | 30 June 2017 (FY 2017) | https://www.ihacpa.gov.au/resources/icd-10-amachiacs-ninth-edition      |
# | Tenth      | 1 July 2017 (FY 2018) | 30 June 2019 (FY 2019) | https://www.ihacpa.gov.au/resources/icd-10-amachiacs-tenth-edition      |
# | Eleventh   | 1 July 2019 (FY 2020) | 30 June 2022 (FY 2022) | https://www.ihacpa.gov.au/resources/icd-10-amachiacs-eleventh-edition   |
# | Twelfth    | 1 July 2022 (FY 2023) | 30 June 2025 (FY 2025) | https://www.ihacpa.gov.au/resources/icd-10-amachiacs-twelfth-edition    |
# | Thirteenth | 1 July 2025 (FY 2026) |                        | https://www.ihacpa.gov.au/resources/icd-10-amachiacs-thirteenth-edition |

# set financial year (calendary year the financial year ends)
codes[, year := data.table::fcase(
  startsWith(file, "eleven"), 2020L,
  startsWith(file, "twelfth"), 2023L,
  startsWith(file, "thirteent"), 2026L)
]

# are there any duplicated codes within a year? -- Yes!
#
# It appears that old descriptions of codes persist in the table and there are
# notes in the pdf for changes.
#
if (interactive()) {
  codes[, .N, keyby = .(full_code, year)][N > 1]
}
stopifnot(codes[, .N, keyby = .(full_code, year)][, all(N == 1L)])

# copy data for years in between as was done with WHO and to match yearly
# versions of US codes.
a20 <- codes[year == 2020L]
a21 <- data.table::copy(a20); a21[, year := 2021L]
a22 <- data.table::copy(a20); a22[, year := 2022L]
a23 <- codes[year == 2023L]
a24 <- data.table::copy(a23); a24[, year := 2024L]
a25 <- data.table::copy(a23); a25[, year := 2025L]
a26 <- codes[year == 2026L]

codes <- data.table::rbindlist(list(a20, a21, a22, a23, a24, a25, a26))

################################################################################
# Find headers
stopifnot(codes[, all(nchar(code) %in% 3:5)])

codes[nchar(code) == 4, `:=`(h3 = substr(code, 1, 3))]
codes[nchar(code) == 5, `:=`(h3 = substr(code, 1, 3), h4 = substr(code, 1, 4))]

headers <- codes[!is.na(h3) | !is.na(h4), .(code, h3, h4, year)]
headers <- unique(headers)

codes[headers, header := 1L, on = c("code" = "h3", 'year')]
codes[headers, header := 1L, on = c("code" = "h4", 'year')]

# all the codes that have not yet been matched are not-headers
codes[, header := data.table::nafill(header, type = 'const', fill = 0L)]
data.table::set(codes, j = "h3", value = NULL)
data.table::set(codes, j = "h4", value = NULL)

codes[, file := NULL]


################################################################################
data.table::setDF(codes)
saveRDS(codes, file = "ihacpa_icd10.rds")


################################################################################
#                                 End of File                                  #
################################################################################
