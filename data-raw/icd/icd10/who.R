################################################################################
# file: icd/icd10/who.R
#
# purpose: Convert WHO ICD-10 code listings into a tidy reference with header
#          flags and calendar-year coverage.
#
# inputs:
#   who/icd10_who_*.txt (WHO ICD-10 code listings exported to text files by
#   manually copying codes from the World Health Organization website)
#
# output: who_icd10.rds (data.frame with code, full_code, desc, calendar_year,
#         header)
#
# deps: data.table
#
# notes:
#   Run from data-raw/icd/icd10/ with the who/ folder populated.
#   Copies the 2016 release forward/backward to cover years missing from WHO
#     downloads.
#
# idempotent: yes (read/transform/write without side effects)
################################################################################
library(data.table)

################################################################################
# WHO Codes
who <-
  sapply(list.files(path = "who", pattern = "icd10_who_\\d{4}\\.txt$", full.names = TRUE),
         scan,
         what = "character",
         sep = "\n",
         quiet = !interactive(),
         skip = 1,
         simplify = FALSE)

# verify some simple assumptions about the structure.
# The 8th column is a space
lapply(who, substr, start = 8, stop = 8) |>
  lapply(function(x) all(x == " ")) |>
  do.call(c, args = _) |>
  all() |>
  stopifnot()

# construct data.tables
who <-
  lapply(who,
         function(x) {
           data.table(full_code = trimws(substr(x, start = 1, stop = 7)),
                      desc      = trimws(substr(x, start = 9, stop = 10000L)))
         }) |>
  rbindlist(idcol = "file")
setkey(who, full_code)

# extract the chapters and code ranges
who_chapters <- who[grepl("^\\D(\\D|$)", full_code)]
who_code_ranges <- who[grepl("\\w\\d{2}-\\w\\d{2}", full_code)]
who <- who[!who_chapters]
who <- who[!who_code_ranges]

who[, code := sub("\\.", "", full_code)]

################################################################################
# year - WHO is calendar year, not fiscal year.
who[, calendar_year := as.integer(sub("^(.+)(\\d{4})\\.txt$", "\\2", file))]
who[, file := NULL]

# 2017 and 2018 do not have published code lists, likely because they mirror
# the 2016 release. Copy the 2016 list and adjust the year for 2017 and 2018 for
# easier merges with CDC and CMS CM/PCS data. Do the same for 2008–2009 and
# 2010–2013.
stopifnot(sort(unique(who$calendar_year)) == c(2008L, 2010L, 2014L, 2015L, 2016L, 2019L))
a09 <- who[calendar_year == 2008L]
a11 <- who[calendar_year == 2010L]
a12 <- copy(a11)
a13 <- copy(a11)
a17 <- who[calendar_year == 2016L]
a18 <- copy(a17)

a09[, calendar_year := 2009L]
a11[, calendar_year := 2011L]
a12[, calendar_year := 2012L]
a13[, calendar_year := 2013L]
a17[, calendar_year := 2017L]
a18[, calendar_year := 2018L]

who <- rbindlist(list(who, a09, a11, a12, a13, a17, a18))

################################################################################
# Find headers
stopifnot(who[, all(nchar(code) %in% 3:5)])

who[nchar(code) == 4, `:=`(h3 = substr(code, 1, 3))]
who[nchar(code) == 5, `:=`(h3 = substr(code, 1, 3), h4 = substr(code, 1, 4))]

headers <- who[!is.na(h3) | !is.na(h4), .(code, h3, h4, calendar_year)]
headers <- unique(headers)

who[headers, header := 1L, on = c("code" = "h3", 'calendar_year')]
who[headers, header := 1L, on = c("code" = "h4", 'calendar_year')]

# all the codes that have not yet been matched are not-headers
who[, header := nafill(header, type = 'const', fill = 0L)]
set(who, j = "h3", value = NULL)
set(who, j = "h4", value = NULL)

if (interactive()) {
  who[nchar(code) == 5]
  who[grepl("^B18\\.0", full_code)][order(calendar_year, nchar(code))] |> print(nrow = Inf)
}

# a simple check for the header
stopifnot(
  who[full_code == "B18.0" & calendar_year < 2019, all(header == 0L)]
  ,
  who[full_code == "B18.0" & calendar_year >= 2019, all(header == 1L)]
  )

################################################################################
setDF(who)
saveRDS(who, file = "who_icd10.rds")

################################################################################
#                                 End of File                                  #
################################################################################
