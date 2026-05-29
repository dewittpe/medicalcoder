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


codes[, year := data.table::fcase(
  startsWith(file, "eleven"), 2019L,
  startsWith(file, "twelfth"), 2022L,
  startsWith(file, "thirteent"), 2025L)
]

codes[, code := sub("\\.", "", full_code)]

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
