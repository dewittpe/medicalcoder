################################################################################
# file: icd/icd9/cdc.R
#
# purpose: Parse CDC ICD-9-CM diagnosis and procedure text files, derive header
#          relationships, and build a canonical code table for downstream
#          merges.
#
# inputs:
#   cdc/dtab*.txt (CDC ICD-9-CM diagnosis distributions, one per fiscal year)
#   cdc/ptab*.txt (CDC ICD-9-CM procedure distributions, one per fiscal year)
#
# output: cdc.rds (data.frame with full_code, code, desc, dxpr, fiscal_year,
#         header)
#
# deps: data.table, readxl, utils
#
# notes:
#   Run from data-raw/icd/icd9/ so relative paths resolve.
#   Expands header codes via suffix tables, patches known anomalies (e.g.,
#     E849), and enforces unique code/year combinations.
#
# idempotent: yes (pure read/clean/write of static CDC distributions)
################################################################################

library(data.table)

################################################################################
# Data from the CDC

# dtabXX is for fiscal year 19XX or 20XX
dtabs <-
  list.files(path = "cdc", pattern = "dtab*", full.names = TRUE) |>
  sapply(scan,
         what = "character",
         sep = "\n",
         quiet = !interactive())
ptabs <-
  list.files(path = "cdc", pattern = "ptab*", full.names = TRUE) |>
  sapply(scan,
         what = "character",
         sep = "\n",
         quiet = !interactive())

################################################################################
# Extract numeric, V, and E codes from the dtabs
numeric_codes <-
  dtabs |>
  lapply(function(x) {
           d3 <- grep(x = x, pattern = '^\\d{3}(?![\\d.-]|$)',        value = TRUE, perl = TRUE)
           d4 <- grep(x = x, pattern = '^\\d{3}\\.\\d(?![\\d:),.-]|$)', value = TRUE, perl = TRUE)
           d5 <- grep(x = x, pattern = '^\\d{3}\\.\\d{2}(?![\\d),-]|$)',  value = TRUE, perl = TRUE)
           # extract the code
           c3 <- substr(d3, start = 1, stop = 3)
           c4 <- substr(d4, start = 1, stop = 5)
           c5 <- substr(d5, start = 1, stop = 6)
           # extract the description
           d3 <- trimws(substr(d3, start = 4, stop = max(nchar(d3))))
           d4 <- trimws(substr(d4, start = 6, stop = max(nchar(d4))))
           d5 <- trimws(substr(d5, start = 7, stop = max(nchar(d5))))
           data.table(full_code = c(c3, c4, c5), desc = c(d3, d4, d5))
         }) |>
  lapply(unique) |>
  rbindlist(idcol = "file")

# there is a false positive match to clean up.  "195 (Malignant neoplasm of the
# other and ill-defined sites)." is a false positive, the intended match does
# not have the parenthesis or period
numeric_codes <-
  numeric_codes[!(full_code == "195" & desc == "(Malignant neoplasm of other and ill-defined sites).")]

# Similarly,
numeric_codes <-
  numeric_codes[!(full_code == "199" & desc == "Malignant neoplasms, without specification of site")]

v_codes <-
  dtabs |>
  lapply(function(x) {
           d3 <- grep(x = x, pattern = '^V\\d{2}(?![.:])', value = TRUE, perl = TRUE)
           d4 <- grep(x = x, pattern = '^V\\d{2}\\.\\d(?![\\d-])', value = TRUE, perl = TRUE)
           d5 <- grep(x = x, pattern = '^V\\d{2}\\.\\d{2}(?![\\d])', value = TRUE, perl = TRUE)
           # extract the code
           c3 <- substr(d3, start = 1, stop = 3)
           c4 <- substr(d4, start = 1, stop = 5)
           c5 <- substr(d5, start = 1, stop = 6)
           # extract the description
           d3 <- trimws(substr(d3, start = 4, stop = max(nchar(d3))))
           d4 <- trimws(substr(d4, start = 6, stop = max(nchar(d4))))
           d5 <- trimws(substr(d5, start = 7, stop = max(nchar(d5))))
           data.table(full_code = c(c3, c4, c5), desc = c(d3, d4, d5))
         }) |>
  lapply(unique) |>
  rbindlist(idcol = "file")

e_codes <-
  dtabs |>
  lapply(function(x) {
           d3 <- grep(x = x, pattern = '^E\\d{3}(?![.:,-]|$)', value = TRUE, perl = TRUE)
           d4 <- grep(x = x, pattern = '^E\\d{3}\\.\\d(?![-]|$)', value = TRUE, perl = TRUE)
           # extract codes
           c3 <- substr(d3, start = 1, stop = 4)
           c4 <- substr(d4, start = 1, stop = 6)
           # extract description
           d3 <- trimws(substr(d3, start = 5, stop = max(nchar(d3))))
           d4 <- trimws(substr(d4, start = 7, stop = max(nchar(d4))))
           data.table(full_code = c(c3, c4), desc = c(d3, d4))
         }) |>
  lapply(unique) |>
  rbindlist(idcol = "file")

# NOTE E849 is a valid code but the format of the input files breaks for fiscal
# years 2001 - 2012.  The E894.[0-9] codes are found as expected, but the header
# E849 needs to be added.

#lapply(dtabs, function(x) { grep("^E849", x, value = TRUE)})
#e_codes[grepl("^E849", full_code), unique(full_code)]
#e_codes[grepl("^E849$", full_code)]

e_codes <-
  rbind(e_codes,
        CJ(file = unique(e_codes[grepl("dtab[0-1]", file), file]),
           full_code = "E849",
           desc = "Place of occurrence")
        )

# a bit of clean up, some false positive matches to remove
e_codes <-
  e_codes[!(full_code == "E004" & desc == "Activities involving climbing, rappelling, and jumping off")]

################################################################################
# extract the codes and descriptions from the ptabs
pr_codes <-
  ptabs |>
  lapply(function(x) {
           d2 <- grep(x = x, pattern = '^\\d{2}(?![.:-]|$)',        value = TRUE, perl = TRUE)
           d3 <- grep(x = x, pattern = '^\\d{2}\\.\\d(?![\\d,]|$)',  value = TRUE, perl = TRUE)
           d4 <- grep(x = x, pattern = '^\\d{2}\\.\\d{2}(?![),-]|$)', value = TRUE, perl = TRUE)
           c2 <- substr(d2, start = 1, stop = 2)
           c3 <- substr(d3, start = 1, stop = 4)
           c4 <- substr(d4, start = 1, stop = 5)
           d2 <- trimws(substr(d2, start = 3, stop = max(nchar(d2))))
           d3 <- trimws(substr(d3, start = 5, stop = max(nchar(d3))))
           d4 <- trimws(substr(d4, start = 6, stop = max(nchar(d4))))
           data.table(full_code = c(c2, c3, c4), desc = c(d2, d3, d4))
         }) |>
    lapply(unique) |>
    rbindlist(idcol = "file")
set(pr_codes, j = "dxpr", value = "pr")

# there are some false positive findings that need to be omitted from pr_codes
pr_codes <- pr_codes[!(full_code == "14" & desc == "C-Urea breath test")]

################################################################################
# build as one data set
cdc <- rbind(cbind(rbind(numeric_codes, v_codes, e_codes), "dxpr" = "dx"), pr_codes)

# sanity check.  a code should not appear more than the number of input files.
stopifnot(length(dtabs) == length(ptabs))
stopifnot(
  nrow(
    cdc[, .N, keyby = .(full_code)][N > length(dtabs)]
  ) == 0L
)

################################################################################
# build fiscal_year
cdc[, fiscal_year := sub("^cdc/(p|d)tab(\\d{2})\\.txt$", "\\2", file)]
cdc[, fiscal_year := fifelse(grepl("^9", fiscal_year), paste0("19", fiscal_year), paste0("20", fiscal_year))]
cdc[, fiscal_year := as.integer(fiscal_year)]
cdc[, file := NULL]

################################################################################
# the documentation includes alot of sections were a fourth and/or fifth digit
# is to be added.

add_rows <- function(pattern, suffixes, data) {
  # pattern:  a regex to match rows of cdc
  # suffixes: a data.table with the suffix (fourth, likely fifth, digit) to add
  #           to all the codes matched by pattern and the description to be
  #           appended to the description of the header code.
  # data:     a subset of the cdc data.table
  #
  # return: the new rows
  data[grepl(pattern, full_code)] |>
    split(by = c('full_code', 'fiscal_year')) |>
    lapply(function(DT, sf) {
             data.table(full_code = paste0(DT[["full_code"]], sf$suffix),
                        desc = paste(DT[["desc"]], sf$desc),
                        dxpr = DT[["dxpr"]],
                        fiscal_year = DT[["fiscal_year"]])
        }, sf = suffixes) |>
    rbindlist()
}


# 010-018 have fifth digit 0:6
SF <- fread(text = "
  suffix | desc
  0 | unspecified
  1 | bacteriological or histological examination not done
  2 | bacteriological or histological examination unknown (at present)
  3 | tubercle bacilli found (in sputum) by microscopy
  4 | tubercle bacilli not found (in sputum) by microscopy, but found by bacterial culture
  5 | tubercle bacilli not found by bacteriological examination, but tuberculosis confirmed histologically
  6 | tubercle bacilli not found by bacteriological or histological examination, but tuberculosis confirmed by other methods [inoculation of animals]",
)
cdc <- rbindlist(list(cdc, add_rows("^01[0-8]\\.\\d$", SF, cdc)), use.names = TRUE)

# 045 has fifth digit 0:3
SF <- fread(text = "
  suffix | desc
  0 |poliovirus, unspecified type
  1 |poliovirus type I
  2 |poliovirus type II
  3 |poliovirus type III")
cdc <- rbindlist(list(cdc, add_rows("^045\\.\\d$", SF, cdc)), use.names = TRUE)

# 070.[2-3] have fifth digits of 0:3
SF <- fread(text ="
  suffix | desc
  0 | acute or unspecified, without mention of hepatitis delta
  1 | acute or unspecified, with hepatitis delta
  2 | chronic, without mention of hepatitis delta
  3 | chronic, with hepatitis delta
")
cdc <- rbindlist(list(cdc, add_rows("^070\\.[2-3]$", SF, cdc)), use.names = TRUE)

# 115 has fifth digits
SF <- fread(text = "
  suffix | desc
  0 |without mention of manifestation
  1 |meningitis
  2 |retinitis
  3 |pericarditis
  4 |endocarditis
  5 |pneumonia
  9 |other")
cdc <- rbindlist(list(cdc, add_rows("^115\\.\\d$", SF, cdc)), use.names = TRUE)

# 200-202 have fifth digits
SF <- fread(text = "
  suffix | desc
  0 | unspecified site, extranodal and solid organ sites
  1 | lymph nodes of head, face, and neck
  2 | intrathoracic lymph nodes
  3 | intra-abdominal lymph nodes
  4 | lymph nodes of axilla and upper limb
  5 | lymph nodes of inguinal region and lower limb
  6 | intrapelvic lymph nodes
  7 | spleen
  8 | lymph nodes of multiple sites")
cdc <- rbindlist(list(cdc, add_rows("^20[0-2]\\.\\d$", SF, cdc)), use.names = TRUE)

# 20[3-8] fifth digit of 0:1
# starting in FY 2009 fifth digit 2 was added
SF <- fread(text = "
  suffix | desc
  0 | without mention of remission
  1 | in remission
  2 |in relapse")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^20[3-8]\\.\\d$", SF[1:2], cdc[fiscal_year <  2009]),
      add_rows("^20[3-8]\\.\\d$", SF,      cdc[fiscal_year >= 2009])
    ),
    use.names = TRUE
  )

# 242 fifth digits of 0:1
SF <- fread(text = "
  suffix | desc
  0 | without mention of thyrotoxic crisis or storm
  1 | with mention of thyrotoxic crisis or storm")
cdc <-
  rbindlist(
    list(cdc, add_rows("^242\\.\\d$", SF, cdc)),
    use.names = TRUE
  )

# 249 added in FY 2009
SF <- fread(text = "
            suffix | desc
            0 | not stated as uncontrolled
            1 | uncontrolled")

cdc <-
  rbindlist(
    list(cdc, add_rows("^249\\.\\d$", SF, cdc)),
    use.names = TRUE
  )

# 250 fifth digits of 0:3
SF <- fread(text = "
            suffix | desc
            0 | type II or unspecified type, not stated as uncontrolled
            1 | type I [juvenile type], not stated as uncontrolled
            2 | type II or unspecified type, uncontrolled
            3 | type I [juvenile type], uncontrolled")
cdc <-
  rbindlist(
    list(cdc, add_rows("^250\\.\\d$", SF, cdc)),
    use.names = TRUE
  )

# 295 have fifth digits of 0:5
SF <- fread(text = "
            suffix | desc
            0 | unspecified
            1 | subchronic
            2 | chronic
            3 | subchronic with acute exacerbation
            4 | chronic with acute exacerbation
            5 | in remission")
cdc <-
  rbindlist(
    list(cdc, add_rows("^295\\.\\d$", SF, cdc)),
    use.names = TRUE
  )

# 296.[0-6] have fifth digits of 0:6
SF <- fread(text = "
            suffix | desc
            0 | unspecified
            1 | mild
            2 | moderate
            3 | severe, without mention of psychotic behavior
            4 | severe, specified as with psychotic behavior
            5 | in partial or unspecified remission
            6 | in full remission")
cdc <-
  rbindlist(
    list(cdc,
         add_rows("^296\\.[0-6]$", SF, cdc))
    ,
    use.names = TRUE
  )

# 299 fifth digits 0:1
SF <- fread(text ="
            suffix | desc
            0 | current or active state
            1 | residual state")
cdc <-
  rbindlist(
    list(cdc,
         add_rows("^299\\.\\d$", SF, cdc))
    ,
    use.names = TRUE
  )

# 303 fifth digits 0:3
# 304 fifth digits 0:3
# 305.[0,2-9] fifth digits 0:3
SF <- fread(text = "
            suffix | desc
            0 | unspecified
            1 | continuous
            2 | episodic
            3 | in remission")
cdc <-
  rbindlist(
    list(cdc,
         add_rows("^((303\\.\\d)|(304\\.\\d)|(305\\.[0,2-9]))$", SF, cdc))
    ,
    use.names = TRUE
  )

# 312.[0-2] fifth 0:3
SF <- fread(text = "
            suffix | desc
            0 | unspecified
            1 | mild
            2 | moderate
            3 | severe")
cdc <-
  rbindlist(
    list(cdc,
         add_rows("^312\\.[0-2]$", SF, cdc))
    ,
    use.names = TRUE
  )

# 342 fifth 0:2
SF <- fread(text = "
            suffix | desc
            0 | affecting unspecified side
            1 | affecting dominant side
            2 | affecting nondominant side")
cdc <-
  rbindlist(
    list(cdc,
         add_rows("^342\\.\\d$", SF, cdc))
    ,
    use.names = TRUE
  )

# 345.[0-1,4-9] fifth 0:1
SF <- fread(text = "
            suffix | desc
            0 | without mention of intractable epilepsy
            1 | with intractable epilepsy")
cdc <-
  rbindlist(
    list(cdc,
         add_rows("^345\\.[0-1,4-9]$", SF, cdc))
    ,
    use.names = TRUE
  )

# 346 fifth 0:1
# in FY 2009 fifth digits 2:3 were added
SF <- fread(text ="
            suffix | desc
            0 | without mention of intractable migraine without mention of status migrainosus
            1 | with intractable migraine, so stated,without mention of status migrainosus
            2 | without mention of intractable migraine with status migrainosus
            3 | with intractable migraine, so stated, with status migrainosus")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^346\\.\\d$", SF[1:2], cdc[fiscal_year <  2009]),
      add_rows("^346\\.\\d$", SF,      cdc[fiscal_year >= 2009])
    ),
    use.names = TRUE
  )

# 403 fifth 0:1
SF <- fread(text ="
            suffix | desc
            0 | with chronic kidney disease stage I through stage IV, or unspecified
            1 | with chronic kidney disease stage V or end stage renal disease")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^403\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 404 fifth 0:3
SF <- fread(text ="
            suffix | desc
            0 | without heart failure and with chronic kidney disease stage I through stage IV, or unspecified
            1 | with heart failure and with chronic kidney disease stage I through stage IV, or unspecified
            2 | without heart failure and with chronic kidney disease stage V or end stage renal disease
            3 | with heart failure and chronic kidney disease stage V or end stage renal disease")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^404\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 410 fifth digits 0:2
SF <- fread(text ="
            suffix | desc
            0 | episode of care unspecified
            1 | initial episode of care
            2 | subsequent episode of care")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^410\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )


# 433 fifth digits 0:1
# 434 fifth digits 0:1
SF <- fread(text ="
            suffix | desc
            0 | without mention of cerebral infarction
            1 | with cerebral infarction")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^43[3-4]\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 493 fifth digits 0:1
# omit 493.8 from this as that coded, with its fifth digits, was introduced for
# fiscal_year 2004
# also, for fiscal_year 2001 and beyond, the fifth digit 2 was added.
SF <- fread(text ="
            suffix | desc
            0 | unspecified
            1 | with status asthmaticus
            2 | with (acute) exacerbation")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^493\\.[0-7,9]$", SF[0:2 + 1], cdc[fiscal_year <  2001]),
      add_rows("^493\\.[0-7,9]$", SF,          cdc[fiscal_year >= 2001])
    ),
    use.names = TRUE
  )

# 531 fifth digit 0:1
# 532 fifth digit 0:1
# 533 fifth digit 0:1
# 534 fifth digit 0:1
# 574 fifth digit 0:1
SF <- fread(text =" suffix | desc \n 0 | without mention of obstruction \n 1 | with obstruction")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^53[1-4]\\.\\d$", SF, cdc),
      add_rows("^574\\.\\d$",     SF, cdc)
    ),
    use.names = TRUE
  )

## # 535 fifth digit 0:1
SF <- fread(text =" suffix | desc \n 0 | without mention of hemorrhage \n 1 | with hemorrhage")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^535\\.\\d$",     SF, cdc)
    ),
    use.names = TRUE
  )

# 550 fifth digit 0:3
SF <- fread(text =" suffix | desc \n 0 | unilateral or unspecified (not specified as recurrent) \n 1 | unilateral or unspecified, recurrent \n 2 | bilateral (not specified as recurrent) \n 3 | bilateral, recurrent")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^550\\.\\d$",     SF, cdc)
    ),
    use.names = TRUE
  )

# 634 fifth digit 0:2
# 635 fifth digit 0:2
# 636 fifth digit 0:2
# 637 fifth digit 0:2
SF <- fread(text =" suffix | desc \n 0 | unspecified \n 1 | incomplete \n 2 | complete")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^63[4-7]\\.\\d$",     SF, cdc)
    ),
    use.names = TRUE
  )

# 640-649
# note: 645 in FY 97-99 needs to have the fourth digit 0 added
SF <- fread(text =' suffix | desc \n .0 | " " ', colClasses = "character")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^645$", SF, cdc[fiscal_year <= 1999])
    ),
    use.names = TRUE
  )

SF <- fread(text =" suffix | desc \n 0 | unspecified as to episode of care or not applicable \n 1 | delivered, with or without mention of antepartum condition \n 2 | delivered, with mention of postpartum complication \n 3 | antepartum condition or complication \n 4 | postpartum condition or complication")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^640\\.[0,8,9]$", SF[c(0,1,3)+1], cdc),
      add_rows("^641\\.[0-3,8-9]$", SF[c(0,1,3)+1], cdc),
      add_rows("^642\\.\\d$", SF, cdc),
      add_rows("^643\\.[0-2,8-9]$", SF[c(0,1,3)+1], cdc),
      add_rows("^644\\.[0,1]$", SF[c(0,3)+1], cdc),
      add_rows("^644\\.2$", SF[c(0,1)+1], cdc),
      add_rows("^645\\.\\d$", SF[c(0,1,3)+1], cdc),
      add_rows("^646\\.[0,3,7,9]$", SF[c(0,1,3)+1], cdc),
      add_rows("^646\\.[1-2,4-6,8]$", SF, cdc),
      add_rows("^64[7-8]\\.\\d$", SF, cdc),
      add_rows("^649\\.[0-4,6,9]$", SF, cdc),
      add_rows("^649\\.5$", SF[c(0,1,3)+1], cdc),
      add_rows("^649\\.7$", SF, cdc[fiscal_year < 2009]),
      add_rows("^649\\.7$", SF[-(c(2,4)+1)], cdc[fiscal_year >= 2009]),
      add_rows("^649\\.8$", SF[c(1,2)+1], cdc)
    ),
    use.names = TRUE
  )

# 651 - 659, 660-669, 670-676, 678-679
# note: 657 and 670 needs the fourth digit 0 added
SF <- fread(text =' suffix | desc \n .0 | " " ', colClasses = "character")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^657$", SF, cdc),
      add_rows("^670$", SF, cdc[fiscal_year < 2010]),
      add_rows("^672$", SF, cdc)
    ),
    use.names = TRUE
  )

SF <- fread(text =" suffix | desc \n 0 | unspecified as to episode of care or not applicable \n 1 | delivered, with or without mention of antepartum condition \n 2 | delivered, with mention of postpartum complication \n 3 | antepartum condition or complication \n 4 | postpartum condition or complication")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^65[1-3,5-9]\\.\\d$", SF[c(0,1,3)+1], cdc),
      add_rows("^654\\.2$", SF[c(0,1,3)+1], cdc),
      add_rows("^654\\.[0-1,3-9]$", SF, cdc),
      add_rows("^66[0-3]\\.\\d$", SF[c(0,1,3)+1], cdc),
      add_rows("^664\\.\\d$", SF[c(0,1,4)+1], cdc),
      add_rows("^665\\.0$", SF[c(0,1,3)+1], cdc),
      add_rows("^665\\.1$", SF[c(0,1)+1], cdc),
      add_rows("^665\\.2$", SF[c(0,2,4)+1], cdc),
      add_rows("^665\\.[3-6]$", SF[c(0,1,4)+1], cdc),
      add_rows("^665\\.7$", SF[c(0,1,2,4)+1], cdc),
      add_rows("^665\\.[8-9]$", SF[c(0,1,2,3,4)+1], cdc),
      add_rows("^666\\.[0-3]$", SF[c(0,2,4)+1], cdc),
      add_rows("^667\\.[0-1]$", SF[c(0,2,4)+1], cdc),
      add_rows("^668\\.\\d$", SF[c(0:4)+1], cdc),
      add_rows("^669\\.[0-2,4,8-9]$", SF[c(0:4)+1], cdc),
      add_rows("^669\\.3$", SF[c(0,2,4)+1], cdc),
      add_rows("^669\\.[5-7]$", SF[c(0,1)+1], cdc),
      add_rows("^670\\.\\d$", SF[c(0,2,4)+1], cdc),
      add_rows("^671\\.[0-2,5,8,9]$", SF[c(0:4)+1], cdc),
      add_rows("^671\\.3$", SF[c(0,1,3)+1], cdc),
      add_rows("^671\\.4$", SF[c(0,2,4)+1], cdc),
      add_rows("^672\\.\\d$", SF[c(0,2,4)+1], cdc),
      add_rows("^673\\.\\d$", SF[c(0:4)+1], cdc),
      add_rows("^674\\.[0,5]$", SF[c(0:4)+1], cdc),
      add_rows("^674\\.[1-4,8-9]$", SF[c(0,2,4)+1], cdc),
      add_rows("^675\\.[0-2,8-9]$", SF[c(0:4)+1], cdc),
      add_rows("^676\\.\\d$", SF[c(0:4)+1], cdc),
      add_rows("^678\\.\\d$", SF[c(0,1,3)+1], cdc),
      add_rows("^679\\.\\d$", SF[c(0:4)+1], cdc)
    ),
    use.names = TRUE
  )

# 711-712 have fifth digit 0:9
# 715
# 716
# 718
# 719.[0-6,8-9]
# 730
SF <- fread(text =" suffix | desc \n 0 | site unspecified \n 1 | shoulder region \n 2 | upper arm \n 3 | forearm \n 4 | hand \n 5 | pelvic region and thigh \n 6 | lower leg \n 7 | ankle and foot \n 8 | other specified sites \n 9 | multiple sites")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^71[1-2]\\.\\d$", SF, cdc),
      add_rows("^715\\.0$", SF[c(0,4,9)+1], cdc),
      add_rows("^715\\.[1-3,9]$", SF[c(0:8)+1], cdc),
      add_rows("^715\\.8$", SF[c(0,9)+1], cdc),
      add_rows("^716\\.[0-5,8-9]$", SF[c(0:9)+1], cdc),
      add_rows("^716\\.6$", SF[c(0:8)+1], cdc),
      add_rows("^718\\.[0-1]$", SF[c(0:5,7:9)+1], cdc),
      add_rows("^718\\.[2-5,7-8]$", SF[c(0:9)+1], cdc),
      add_rows("^718\\.6$", SF[c(0,5)+1], cdc[fiscal_year < 2012]),
      add_rows("^718\\.6$", SF[c(5)+1], cdc[fiscal_year >= 2012]),
      add_rows("^718\\.9$", SF[c(0:5,7:9)+1], cdc),
      add_rows("^719\\.[0-6,8-9]$", SF[c(0:9)+1], cdc),
      # it appears that the fifth digit codes for 719.7 were removed starting in
      # fiscal year 2004
      add_rows("^719\\.7$", SF[c(0,5:9)+1], cdc[fiscal_year < 2004]),
      add_rows("^730\\.\\d$", SF[c(0:9)+1], cdc)
    ),
    use.names = TRUE
  )

# 741
SF <- fread(text =" suffix | desc \n 0 | unspecified region \n 1 | cervical region \n 2 | dorsal (thoracic) region \n 3 | lumbar region")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^741\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 764,  765.0, 765.1
SF <- fread(text =" suffix | desc \n 0 | unspecified [weight] \n 1 | less than 500 grams \n 2 | 500-749 grams \n 3 | 750-999 grams \n 4 | 1,000-1,249 grams \n 5 | 1,250-1,499 grams \n 6 | 1,500-1,749 grams \n 7 | 1,750-1,999 grams \n 8 | 2,000-2,499 grams \n 9 | 2,500 grams and over")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^764\\.\\d$", SF, cdc),
      add_rows("^765\\.[0,1]$", SF, cdc)
    ),
    use.names = TRUE
  )

# 789
SF <- fread(text =" suffix | desc \n 0 | unspecified site \n 1 | right upper quadrant \n 2 | left upper quadrant \n 3 | right lower quadrant \n 4 | left lower quadrant \n 5 | periumbilic \n 6 | epigastric \n 7 | generalized \n 9 | other specified site")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^789\\.[0,3,4,6]$", SF, cdc)
    ),
    use.names = TRUE
  )

# 800, 801, 803, 804
SF <- fread(text =" suffix | desc \n 0 | unspecified state of consciousness \n 1 | with no loss of consciousness \n 2 | with brief [less than one hour] loss of consciousness \n 3 | with moderate [1-24 hours] loss of consciousness \n 4 | with prolonged [more than 24 hours] loss of consciousness and return to pre-existing conscious level \n 5 | with prolonged [more than 24 hours] loss of consciousness, without return to pre-existing conscious level \n 6 | with loss of consciousness of unspecified duration \n 9 | with concussion, unspecified")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^80[0-1,3-4]\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 805
SF <- fread(text =" suffix | desc \n 0 | cervical vertebra, unspecified level \n 1 | first cervical vertebra \n 2 | second cervical vertebra \n 3 | third cervical vertebra \n 4 | fourth cervical vertebra \n 5 | fifth cervical vertebra \n 6 | sixth cervical vertebra \n 7 | seventh cervical vertebra \n 8 | multiple cervical vertebrae")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^805\\.[0-1]$", SF, cdc)
    ),
    use.names = TRUE
  )

# 807
SF <- fread(text =" suffix | desc \n 0 | rib(s), unspecified \n 1 | one rib \n 2 | two ribs \n 3 | three ribs \n 4 | four ribs \n 5 | five ribs \n 6 | six ribs \n 7 | seven ribs \n 8 | eight or more ribs \n 9 | multiple ribs, unspecified")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^807\\.[0-1]$", SF, cdc)
    ),
    use.names = TRUE
  )

# 810
SF <- fread(text = " suffix | desc \n 0 | unspecified part \n 1 | sternal end of clavicle \n 2 | shaft of clavicle \n 3 | acromial end of clavicle")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^810\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 811
SF <- fread(text = " suffix | desc \n 0 | unspecified part \n 1 | acromial process \n 2 | coracoid process \n 3 | glenoid cavity and neck of scapula \n 9 | other")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^811\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 814
SF <- fread(text = " suffix | desc \n 0 | carpal bone, unspecified \n 1 | navicular [scaphoid] of wrist \n 2 | lunate [semilunar] bone of wrist \n 3 | triquetral [cuneiform] bone of wrist \n 4 | pisiform \n 5 | trapezium bone [larger multangular] \n 6 | trapezoid bone [smaller multangular] \n 7 | capitate bone [os magnum] \n 8 | hamate [unciform] bone \n 9 | other")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^814\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 815
SF <- fread(text = " suffix | desc \n 0 | metacarpal bone(s), site unspecified \n 1 | base of thumb [first] metacarpal \n 2 | base of other metacarpal bone(s) \n 3 | shaft of metacarpal bone(s) \n 4 | neck of metacarpal bone(s) \n 9 | multiple sites of metacarpus")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^815\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 816
SF <- fread(text = " suffix | desc \n 0 | phalanx or phalanges, unspecified \n 1 | middle or proximal phalanx or phalanges \n 2 | distal phalanx or phalanges \n 3 | multiple sites")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^816\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 823
SF <- fread(text = " suffix | desc \n 0 | tibia alone \n 1 | fibula alone \n 2 | fibula with tibia")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^823\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 831
SF <- fread(text = " suffix | desc \n 0 | shoulder, unspecified \n 1 | anterior dislocation of humerus \n 2 | posterior dislocation of humerus \n 3 | inferior dislocation of humerus \n 4 | acromioclavicular (joint) \n 9 | other")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^831\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 832
SF <- fread(text = " suffix | desc \n 0 | elbow unspecified \n 1 | anterior dislocation of elbow \n 2 | posterior dislocation of elbow \n 3 | medial dislocation of elbow \n 4 | lateral dislocation of elbow \n 9 | other")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^832\\.[0-1]$", SF, cdc)
    ),
    use.names = TRUE
  )

# 833
SF <- fread(text = " suffix | desc \n 0 | wrist, unspecified part \n 1 | radioulnar (joint), distal \n 2 | radiocarpal (joint) \n 3 | midcarpal (joint) \n 4 | carpometacarpal (joint) \n 5 | metacarpal (bone), proximal end \n 9 | other")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^833\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

## # 834
SF <- fread(text = " suffix | desc \n 0 | finger, unspecified part \n 1 | metacarpophalangeal (joint) \n 2 | interphalangeal (joint), hand")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^834\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 835
SF <- fread(text = " suffix | desc \n 0 | dislocation of hip, unspecified \n 1 | posterior dislocation \n 2 | obturator dislocation \n 3 | other anterior dislocation")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^835\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 838
SF <- fread(text = " suffix | desc \n 0 | foot, unspecified \n 1 | tarsal (bone), joint unspecified \n 2 | midtarsal (joint) \n 3 | tarsometatarsal (joint) \n 4 | metatarsal (bone), joint unspecified \n 5 | metatarsophalangeal (joint) \n 6 | interphalangeal (joint), foot \n 9 | other")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^838\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 851 - 854
SF <- fread(text = " suffix | desc \n 0 | unspecified state of consciousness \n 1 | with no loss of consciousness \n 2 | with brief [less than one hour] loss of consciousness \n 3 | with moderate [1-24 hours] loss of consciousness \n 4 | with prolonged [more than 24 hours] loss of consciousness and return to pre-existing conscious level \n 5 | with prolonged [more than 24 hours] loss of consciousness without return to pre-existing conscious level \n 6 | with loss of consciousness of unspecified duration \n 9 | with concussion, unspecified")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^85[1-4]\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 864
SF <- fread(text = " suffix | desc \n 0 | unspecified injury \n 1 | hematoma and contusion \n 2 | laceration, minor \n 3 | laceration, moderate \n 4 | laceration, major \n 5 | laceration, unspecified \n 9 | other")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^864\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 865
SF <- fread(text = " suffix | desc \n 0 | unspecified injury \n 1 | hematoma without rupture of capsule \n 2 | capsular tears, without major disruption of parenchyma \n 3 | laceration extending into parenchyma \n 4 | massive parenchymal disruption \n 9 | other")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^865\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 866
SF <- fread(text = " suffix | desc \n 0 | unspecified injury \n 1 | hematoma without rupture of capsule \n 2 | laceration \n 3 | complete disruption of kidney parenchyma")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^866\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 868
SF <- fread(text = " suffix | desc \n 0 | unspecified intra-abdominal organ \n 1 | adrenal gland \n 2 | bile duct and gallbladder \n 3 | peritoneum \n 4 | retroperitoneum \n 9 | other and multiple intra-abdominal organs")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^868\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 880
SF <- fread(text = " suffix | desc \n 0 | shoulder region \n 1 | scapular region \n 2 | axillary region \n 3 | upper arm \n 9 | multiple sites")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^880\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 881
SF <- fread(text = " suffix | desc \n 0 | forearm \n 1 | elbow \n 2 | wrist")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^881\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 941
SF <- fread(text = " suffix | desc \n 0 | face and head, unspecified site \n 1 | ear [any part] \n 2 | eye (with other parts of face, head, and neck) \n 3 | lip(s) \n 4 | chin \n 5 | nose (septum) \n 6 | scalp [any part] \n 7 | forehead and cheek \n 8 | neck \n 9 | multiple sites [except with eye] of face, head, and neck")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^941\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 942
SF <- fread(text = " suffix | desc \n 0 | trunk, unspecified site \n 1 | breast \n 2 | chest wall, excluding breast and nipple \n 3 | abdominal wall \n 4 | back [any part] \n 5 | genitalia \n 9 | other and multiple sites of trunk")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^942\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 943
SF <- fread(text = " suffix | desc \n 0 | upper limb, unspecified site \n 1 | forearm \n 2 | elbow \n 3 | upper arm \n 4 | axilla \n 5 | shoulder \n 6 | scapular region \n 9 | multiple sites of upper limb, except wrist and hand")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^943\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 944
SF <- fread(text = " suffix | desc \n 0 | hand, unspecified site \n 1 | single digit [finger (nail)] other than thumb \n 2 | thumb (nail) \n 3 | two or more digits, not including thumb \n 4 | two or more digits including thumb \n 5 | palm \n 6 | back of hand \n 7 | wrist \n 8 | multiple sites of wrist(s) and hand(s)")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^944\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 945
SF <- fread(text = " suffix | desc \n 0 | lower limb [leg], unspecified site \n 1 | toe(s) (nail) \n 2 | foot \n 3 | ankle \n 4 | lower leg \n 5 | knee \n 6 | thigh [any part] \n 9 | multiple sites of lower limb(s)")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^945\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 948
SF <- fread(text = " suffix | desc \n 0 | less than 10 percent or unspecified \n 1 | 10-19% \n 2 | 20-29% \n 3 | 30-39% \n 4 | 40-49% \n 5 | 50-59% \n 6 | 60-69% \n 7 | 70-79% \n 8 | 80-89% \n 9 | 90% or more of body surface")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^948\\.0", SF[c(0) + 1], cdc),
      add_rows("^948\\.1", SF[c(0:1) + 1], cdc),
      add_rows("^948\\.2", SF[c(0:2) + 1], cdc),
      add_rows("^948\\.3", SF[c(0:3) + 1], cdc),
      add_rows("^948\\.4", SF[c(0:4) + 1], cdc),
      add_rows("^948\\.5", SF[c(0:5) + 1], cdc),
      add_rows("^948\\.6", SF[c(0:6) + 1], cdc),
      add_rows("^948\\.7", SF[c(0:7) + 1], cdc),
      add_rows("^948\\.8", SF[c(0:8) + 1], cdc),
      add_rows("^948\\.9", SF[c(0:9) + 1], cdc)
    ),
    use.names = TRUE
  )

# E800 - E807
SF <- fread(text = " suffix | desc \n 0 | Railway employee \n 1 | Passenger on railway \n 2 | Pedestrian \n 3 | Pedal cyclist \n 8 | Other specified person \n 9 | Unspecified person")
SF$suffix <- paste0(".", SF$suffix)
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^E80[0-7]$", SF, cdc)
    ),
    use.names = TRUE
  )

# E810 - E819
SF <- fread(text = " suffix | desc \n 0 | Driver of motor vehicle other than motorcycle \n 1 | Passenger in motor vehicle other than motorcycle \n 2 | Motorcyclist \n 3 | Passenger on motorcycle \n 4 | Occupant of streetcar \n 5 | Rider of animal; occupant of animal-drawn vehicle \n 6 | Pedal cyclist \n 7 | Pedestrian \n 8 | Other specified person \n 9 | Unspecified person")
SF$suffix <- paste0(".", SF$suffix)
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^E81[0-9]$", SF, cdc)
    ),
    use.names = TRUE
  )

# E820 - E829
SF <- fread(text = " suffix | desc \n 0 | Driver of motor vehicle other than motorcycle \n 1 | Passenger in motor vehicle other than motorcycle \n 2 | Motorcyclist \n 3 | Passenger on motorcycle \n 4 | Occupant of streetcar \n 5 | Rider of animal; occupant of animal-drawn vehicle \n 6 | Pedal cyclist \n 7 | Pedestrian \n 8 | Other specified person \n 9 | Unspecified person")
SF$suffix <- paste0(".", SF$suffix)
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^E82[0-5]$", SF, cdc),
      add_rows("^E826$", SF[c(0:4,8:9)+1], cdc),
      add_rows("^E827$", SF[c(0,2:4,8:9)+1], cdc),
      add_rows("^E828$", SF[c(0,2,4,8,9)+1], cdc),
      add_rows("^E829$", SF[c(0,4,8,9)+1], cdc)
    ),
    use.names = TRUE
  )

# E830 - E839 fifth digits 0:6, 8:9 through 2009, 7 add in 2010
SF <- fread(text = " suffix | desc \n 0 | Occupant of small boat, unpowered \n 1 | Occupant of small boat, powered \n 2 | Occupant of other watercraft­crew \n 3 | Occupant of other watercraft -- other than crew \n 4 | Water skier \n 5 | Swimmer \n 6 | Dockers, stevedores \n 7 | Occupant of military watercraft, any type \n 8 | Other specified person \n 9 | Unspecified person")
SF$suffix <- paste0(".", SF$suffix)
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^E83[0-9]$", SF[c(0:6,8:9)+1], cdc[fiscal_year <  2010]),
      add_rows("^E83[0-9]$", SF,               cdc[fiscal_year >= 2010])
    ),
    use.names = TRUE
  )

# E840 - E849
SF <- fread(text = " suffix | desc \n 0 | Occupant of spacecraft \n 1 | Occupant of military aircraft, any \n 2 | Crew of commercial aircraft (powered) in surface-to-surface transport \n 3 | Other occupant of commercial aircraft (powered) in surface-to-surface transport \n 4 | Occupant of commercial aircraft (powered) in surface-to-air transport \n 5 | Occupant of other powered aircraft \n 6 | Occupant of unpowered aircraft, except parachutist \n 7 | Parachutist (military) (other) \n 8 | Ground crew, airline employee \n 9 | Other person")
SF$suffix <- paste0(".", SF$suffix)
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^E84[0-1,3-4]$", SF, cdc),
      add_rows("^E842$", SF[c(6:9)+1], cdc),
      add_rows("^E845$", SF[c(0,8,9)+1], cdc)
    ),
    use.names = TRUE
  )

# V30 - V39 use 0-2 for fourth code
SF <- fread(text = " suffix | desc \n 0 | Born in hospital \n 1 | Born before admission to hospital \n 2 | Born outside hospital and not hospitalized")
SF$suffix <- paste0(".", SF$suffix)
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^V3[0-9]$", SF, cdc)
    ),
    use.names = TRUE
  )

SF <- fread(text = " suffix | desc \n 0 | delivered without mention of cesarean delivery \n 1 | delivered by cesarean delivery")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^V3[0-9]\\.0$", SF, cdc)
    ),
    use.names = TRUE
  )

# Additional digits for Procedure Codes
# 38

SF <- fread(text = "
            suffix | desc
            0 | unspecified site
            1 | intracranial vessels
            2 | other vessels of head and neck
            3 | upper limb vessels
            4 | aorta
            5 | other thoracic vessels
            6 | abdominal arteries
            7 | abdominal veins
            8 | lower limb arteries
            9 | lower limb veins")
cdc <-
  rbindlist(
    list(cdc,
         add_rows("^38\\.1$", SF[c(0:6,8)+1], cdc),
         add_rows("^38\\.5$", SF[c(0:3,5,7,9)+1], cdc),
         add_rows("^38\\.[0,3,4,6,8]$", SF, cdc)
    ),
    use.names = TRUE
  )

# 77
# 78
SF <- fread(text = " suffix | desc \n 0 | unspecified site \n 1 | scapula, clavicle, and thorax [ribs and sternum] \n 2 | humerus \n 3 | radius and ulna \n 4 | carpals and metacarpals \n 5 | femur \n 6 | patella \n 7 | tibia and fibula \n 8 | tarsals and metatarsals \n 9 | other")
cdc <-
  rbindlist(
    list(cdc,
         add_rows("^77\\.[0-4,6-9]$", SF, cdc),
         add_rows("^78\\.[0-1,4-9]$", SF, cdc),
         add_rows("^78\\.[2-3]$", SF[c(0,2:5,7:9)+1], cdc)
    ),
    use.names = TRUE
  )

# 79
SF <- fread(text = " suffix | desc \n 0 | unspecified site \n 1 | humerus \n 2 | radius and ulna \n 3 | carpals and metacarpals \n 4 | phalanges of hand \n 5 | femur \n 6 | tibia and fibula \n 7 | tarsals and metatarsals \n 8 | phalanges of foot \n 9 | other specified bone")
cdc <-
  rbindlist(
    list(cdc,
         add_rows("^79\\.[0-3,6,9]$", SF, cdc),
         add_rows("^79\\.[4-5]$", SF[c(0:2,5,6,9)+1], cdc)
    ),
    use.names = TRUE
  )

# 80
SF <- fread(text = " suffix | desc \n 0 | unspecified site \n 1 | shoulder \n 2 | elbow \n 3 | wrist \n 4 | hand and finger \n 5 | hip \n 6 | knee \n 7 | ankle \n 8 | foot and toe \n 9 | other specified sites")
cdc <-
  rbindlist(
    list(cdc,
         add_rows("^80\\.[0-4,7-9]$", SF, cdc)
    ),
    use.names = TRUE
  )

# 90
SF <- fread(text = " suffix | desc \n 1 | bacterial smear \n 2 | culture \n 3 | culture and sensitivity \n 4 | parasitology \n 5 | toxicology \n 6 | cell block and Papanicolaou smear \n 9 | other microscopic examination")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^90\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

# 91
SF <- fread(text = " suffix | desc \n 1 | bacterial smear \n 2 | culture \n 3 | culture and sensitivity \n 4 | parasitology \n 5 | toxicology \n 6 | cell block and Papanicolaou smear \n 9 | other microscopic examination")
cdc <-
  rbindlist(
    list(
      cdc,
      add_rows("^91\\.\\d$", SF, cdc)
    ),
    use.names = TRUE
  )

################################################################################
# test for duplicated rows
test <- cdc[, .N, keyby = .(full_code, fiscal_year)][N > 1]
stopifnot(nrow(test) == 0L)

################################################################################
# Save data.frames, not data.tables, to disk.
cdc[, code := sub("\\.", "", full_code)]
cdc[, full_code := NULL]
cdc <- unique(cdc)
setDF(cdc)
saveRDS(file = "cdc.rds", object = cdc)

################################################################################
#                                 End of File                                  #
################################################################################
