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


codes[, code := sub("\\.", "", full_code)]

# The Tenth edition was valid from 1 July 2017 through 30 June 2019   (https://www.ihacpa.gov.au/resources/icd-10-amachiacs-tenth-edition)
# The Elevnth edition was valid from 1 July 2019 through 30 June 2022 (https://www.ihacpa.gov.au/resources/icd-10-amachiacs-eleventh-edition)
# The Twelfth edition was valid from 1 July 2022 through 30 June 2025 (https://www.ihacpa.gov.au/resources/icd-10-amachiacs-twelfth-edition)
# The Thirteenth edition is valid since 1 July 2025....               (https://www.ihacpa.gov.au/resources/icd-10-amachiacs-thirteenth-edition)

# set financial year (calendary year the financial year ends)
codes[, year := data.table::fcase(
  startsWith(file, "eleven"), 2020L,
  startsWith(file, "twelfth"), 2023L,
  startsWith(file, "thirteent"), 2026L)
]



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
