################################################################################
# file: pccc/pccc_v2_r_sas_stata.R
#
# purpose: Extract PCCC v2 code lists from historical R, SAS, and Stata
#          implementations for comparison.
#
# inputs:
#   ./pccc_v2/pccc_1.0.6.tar.gz (source package archive)
#
# output: pccc_v2_r_sas_stata.rds
#
# deps: data.table, pbapply
#
# notes:
#   Untars into tempdir(), parses language-specific code blocks, and records
#     presence per source.
#
# idempotent: yes (deterministic parsing of static sources)
################################################################################

library(data.table)
library(pbapply)

################################################################################
# import known ICD codes.
#
# New implementations for v2 within the medicalcoder package will use exact
# codes and database-like joins to improve speed and accuracy. Having a set of
# the known codes is need to build the set of icd codes needed for this
# conceptual transition.
#
#known_icd_codes  <- readRDS("../icd/icd_codes.rds")
#setDT(known_icd_codes)

################################################################################
# Extract the codes from the latest version of the pccc package before starting
# a massive redesign for version 3 of pccc.
# R codes in 1.0.4 and 1.0.5 are the same
# R codes in 1.0.6 have been extended.
untar(tarfile = "./pccc_v2/pccc_1.0.6.tar.gz", exdir = tempdir())

sas_codes <- scan(file = paste0(tempdir(), "/pccc/inst/pccc_references/ccc_version2_sas.sas"),
                  what = "character",
                  sep = "\n",
                  skip = 55,
                  quiet = !interactive())

stata_codes <- scan(file = paste0(tempdir(), "/pccc/inst/pccc_references/ccc.do"),
                  what = "character",
                  sep = "\n",
                  skip = 55,
                  quiet = !interactive())

r_codes <- scan(file = paste0(tempdir(), "/pccc/src/pccc.cpp"),
                what = "character",
                sep = "\n",
                quiet = !interactive())

################################################################################
# extract the codes from the stata file
stata_codes <- trimws(stata_codes)
# blocks of code
blocks <- which(grepl("ANALYZE ICD", stata_codes))
names(blocks) <- stata_codes[blocks]

# lines starting with 'local' contain icd codes.  if the line ends with /// then
# the codes continue onto the next line
starts <- which(grepl("^local", stata_codes))
ends   <- integer(0)
for (i in starts) {
  j <- i
  while(grepl("///$", stata_codes[j])) {
    j <- j + 1L
  }
  ends <- c(ends, j)
}

stata_codes <-
  lapply(seq_along(starts), function(i) { stata_codes[seq(starts[i], ends[i])] })

stata_codes <-
  stata_codes |>
  lapply(sub, pattern = "local", replacement = "") |>
  lapply(sub, pattern = "\t", replacement = "") |>
  lapply(sub, pattern = "///", replacement = "") |>
  lapply(trimws) |>
  lapply(strsplit, " ") |>
  lapply(unlist, recursive = FALSE)

stata_codes <-
  lapply(seq_along(stata_codes),
         function(i) {
           x <- stata_codes[[i]]
           if (starts[i] >= blocks[3]) {
             icdv <- 10L
             if (starts[i] >= blocks[4]) {
               dx <- 0L
             } else {
               dx <- 1L
             }
           } else {
             icdv <- 9L
             if (starts[i] >= blocks[2]) {
               dx <- 0L
             } else {
               dx <- 1L
             }
           }
           data.table(stata_variable = x[1],
                      code = x[-1],
                      icdv = icdv,
                      dx = dx)
         })

stata_codes <- rbindlist(stata_codes, idcol = TRUE)
stata_codes <- stata_codes[stata_variable != "ccc_class"]
stata_codes[, condition := fcase(grepl("^nm_", stata_variable), "neuromusc",
                               grepl("^cv_", stata_variable), "cvd",
                               grepl("^rp_", stata_variable), "respiratory",
                               grepl("^rn_", stata_variable), "renal",
                               grepl("^gi_", stata_variable), "gi",
                               grepl("^hi_", stata_variable), "hemato_immu",
                               grepl("^mb_", stata_variable), "metabolic",
                               grepl("^mg_", stata_variable), "malignancy",
                               grepl("^cg_", stata_variable), "congeni_genetic",
                               grepl("^nn_", stata_variable), "neonatal",
                               grepl("^td_", stata_variable), "tech_dep",
                               grepl("^tx_", stata_variable), "transplant"
                               )]

stata_codes[, .id := NULL]
stata_codes[, stata_variable := NULL]

stata_codes <- unique(stata_codes)

################################################################################
# extract the codes from the sas file
sas_codes <- trimws(sas_codes)

sas_icd9_block_start <- which(grepl("if &icdv=9", sas_codes))
sas_icd10_block_start <- which(grepl("if &icdv=10", sas_codes))
sas_dx_code_starts <- which(grepl("dxc", sas_codes))
sas_pr_code_starts <- which(grepl("pcc", sas_codes))
sas_dx_code_ends <- integer(0)
sas_pr_code_ends <- integer(0)

for (i in sas_dx_code_starts) {
  j <- i
  while(!grepl(";$", sas_codes[j])) {
    j <- j + 1L
  }
  sas_dx_code_ends <- c(sas_dx_code_ends, j)
}
for (i in sas_pr_code_starts) {
  j <- i
  while(!grepl(";$", sas_codes[j])) {
    j <- j + 1L
  }
  sas_pr_code_ends <- c(sas_pr_code_ends, j)
}

sas_dx_code <-
  lapply(seq_along(sas_dx_code_starts), function(i) { sas_codes[seq(sas_dx_code_starts[i], sas_dx_code_ends[i])] })

sas_pr_code <-
  lapply(seq_along(sas_pr_code_starts), function(i) { sas_codes[seq(sas_pr_code_starts[i], sas_pr_code_ends[i])] })

f <- function(x) {
  condition <- sub(".*\\s*then\\s*(.*)_ccc=1;", "\\1", x[length(x)])
  x[length(x)] <- sub("\\s*then\\s*.*_ccc=1;", "", x[length(x)])
  if (nchar(x[length(x)]) == 0) {
    x <- x[-length(x)]
  }
  data.table(condition = condition, code = trimws(x))
}

sas_dx_code <-
  sas_dx_code |>
  lapply(gsub, pattern = "\"", replacement = "") |>
  lapply(gsub, pattern = "\'", replacement = "") |>
  lapply(gsub, pattern = "if .* in \\(", replacement = "") |>
  lapply(gsub, pattern = "if .* in: \\(", replacement = "") |>
  lapply(gsub, pattern = "\\)",  replacement = "") |>
  lapply(gsub, pattern = "else", replacement = "") |>
  lapply(trimws) |>
  lapply(strsplit, ",") |>
  lapply(unlist, recursive = FALSE) |>
  lapply(FUN = f)

sas_pr_code <-
  sas_pr_code |>
  lapply(gsub, pattern = "\"", replacement = "") |>
  lapply(gsub, pattern = "\'", replacement = "") |>
  lapply(gsub, pattern = "if .* in \\(", replacement = "") |>
  lapply(gsub, pattern = "if .* in:* \\(", replacement = "") |>
  lapply(gsub, pattern = "\\)",  replacement = "") |>
  lapply(gsub, pattern = "else", replacement = "") |>
  lapply(trimws) |>
  lapply(strsplit, ",") |>
  lapply(unlist, recursive = FALSE) |>
  lapply(FUN = f)

for (i in seq_along(sas_dx_code_starts)) {
  if (sas_dx_code_starts[i] > sas_icd10_block_start) {
    sas_dx_code[[i]][, icdv := 10L]
  } else {
    sas_dx_code[[i]][, icdv := 9L]
  }
}

for (i in seq_along(sas_pr_code_starts)) {
  if (sas_pr_code_starts[i] > sas_icd10_block_start) {
    sas_pr_code[[i]][, icdv := 10L]
  } else {
    sas_pr_code[[i]][, icdv := 9L]
  }
}

sas_codes <- rbindlist(list("dx" = rbindlist(sas_dx_code), "pr" = rbindlist(sas_pr_code)), idcol = "dxpr")
sas_codes[, condition := tolower(condition)]

if (interactive()) {
  sas_codes[, unique(condition)]
}

sas_codes[, dx := as.integer(dxpr == "dx")]
sas_codes[, dxpr := NULL]
sas_codes <- unique(sas_codes)

################################################################################
# extract the codes from the cpp file that stored the codes for the R package
r_codes <- trimws(r_codes)

r_icd9_block_start <- which(grepl("if \\(version == 9", r_codes))
r_icd10_block_start <- which(grepl("if \\(version == 10", r_codes))
r_dx_code_starts <- which(grepl("^dx_", r_codes))
r_pr_code_starts <- which(grepl("^pc_", r_codes))
r_dx_code_ends <- integer(0)
r_pr_code_ends <- integer(0)

for (i in r_dx_code_starts) {
  j <- i
  while(!grepl(";$", r_codes[j])) {
    j <- j + 1L
  }
  r_dx_code_ends <- c(r_dx_code_ends, j)
}
for (i in r_pr_code_starts) {
  j <- i
  while(!grepl(";$", r_codes[j])) {
    j <- j + 1L
  }
  r_pr_code_ends <- c(r_pr_code_ends, j)
}

r_dx_code <-
  lapply(seq_along(r_dx_code_starts), function(i) { r_codes[seq(r_dx_code_starts[i], r_dx_code_ends[i])] })

r_pr_code <-
  lapply(seq_along(r_pr_code_starts), function(i) { r_codes[seq(r_pr_code_starts[i], r_pr_code_ends[i])] })


f <- function(x) {
  condition <- substr(x[1], start = 4, stop = regexpr(" = \\{", x[1]) - 1)
  x[1] <- substr(x[1], start = regexpr(" = \\{", x[1]) + 4, stop = 10000)
  x <- gsub("};", "", x)
  x <- gsub("\\\"", "", x)
  x <- paste(x, collapse ="")
  x <- strsplit(x, ",")[[1]]
  data.table(condition = condition, code = trimws(x))
}

r_dx_code <- lapply(r_dx_code, FUN = f)
r_pr_code <- lapply(r_pr_code, FUN = f)

for (i in seq_along(r_dx_code_starts)) {
  if (r_dx_code_starts[i] > r_icd10_block_start) {
    r_dx_code[[i]][, icdv := 10L]
  } else {
    r_dx_code[[i]][, icdv := 9L]
  }
}

for (i in seq_along(r_pr_code_starts)) {
  if (r_pr_code_starts[i] > r_icd10_block_start) {
    r_pr_code[[i]][, icdv := 10L]
  } else {
    r_pr_code[[i]][, icdv := 9L]
  }
}

r_codes <- rbindlist(list("dx" = rbindlist(r_dx_code), "pr" = rbindlist(r_pr_code)), idcol = "dxpr")
r_codes[, condition := tolower(condition)]

if (interactive()) {
  r_codes[, unique(condition)]
}

r_codes[, dx := as.integer(dxpr == "dx")]
r_codes[, dxpr := NULL]

# clean up codes to remove some comments from
if (interactive()) {
  r_codes[grepl("//", code)]
}
r_codes[, code := sub(" // transplant too", "", code)]
r_codes[, code := sub("// transplant", "", code)]
r_codes[, code := sub("//transplant", "", code)]

################################################################################
# look for odd things between the three code sources
rss_codes <- rbindlist(list(r = r_codes, sas = sas_codes, stata = stata_codes),
                       use.names = TRUE,
                       idcol = "src")
rss_codes[, dummy := 1L]
rss_codes[, condition := sub("fixed_", "", condition)]

# do not fill in missing values.  expecting missing values to be present when
# using this object in the pccc_v2.1.R script
rss_codes <-
  dcast(rss_codes, condition + dx + icdv + code ~ src, value.var = 'dummy')

################################################################################
# save to disk
setDF(rss_codes)
saveRDS(rss_codes, "pccc_v2_r_sas_stata.rds")

#####  stop()
#####  # create and expression that will update rss_code as edits are made
#####  update_rss <- expression({
#####    rss_codes <- rss_codes[, `:=`(r = max(r), sas = max(sas), stata = max(stata)), by = .(condition, dx, icdv, code)]
#####    rss_codes <- unique(rss_codes)
#####  })
#####
#####  ################
#####  ## Typeos to fix
#####  #
#####  # ICD-10 dx code M4330 is not a valid code, M433 is a valid code.  This was
#####  # fixed in the old R package between v1.0.5 and v1.0.6.  It needs to be fixed in
#####  # the sas and stata code
#####  if (interactive()) {
#####    rss_codes[grepl("^M433", code)]
#####  }
#####  rss_codes[, code := gsub("M4330", "M433", code)]
#####  eval(update_rss)
#####
#####  # ICD-10-CM P25.2 as of FY 2025, does not have a fifth digit.  The P25.21 and
#####  # P25.22 are not valid ICD codes and appear only in the sas and stata code sets.
#####  if (interactive()) {
#####    rss_codes[grepl("^P252", code)]
#####  }
#####  rss_codes[(icdv == 10 & dx == 1 & code == "P2521"), code := "P252"]
#####  rss_codes[(icdv == 10 & dx == 1 & code == "P2522"), code := "P252"]
#####  eval(update_rss)
#####
#####  # ICD-10-CM Z45.4 does not have sixth digits.  The code Z45.441 and Z45.442
#####  # appear to be errors with an extra 4.  The correct codes are Z45.41 and Z45.42
#####  if (interactive()) {
#####    rss_codes[grepl("^Z454", code)]
#####  }
#####  rss_codes[(icdv == 10 & dx == 1 & code == "Z45441"), code := "Z4541"]
#####  rss_codes[(icdv == 10 & dx == 1 & code == "Z45442"), code := "Z4542"]
#####  eval(update_rss)
#####
#####  # ICD-10-CM Z44.6 is part of dx_renal and dx_tech_dep but that is not a valid
#####  # code, it should be Z46.6
#####  if (interactive()) {
#####    rss_codes[grepl("^Z4[4,6]6", code)]
#####  }
#####  rss_codes[, code := gsub("^Z446", "Z466", code)]
#####  eval(update_rss)
#####
#####  # ICD-9-CM 235.9 or 253.9
#####  #
#####  # V2 documentation has 235.9 listed as metabolic
#####  # V2 documentation does not map 253.9.
#####  #
#####  # However, in the documentation the codes 253.[2,5,6] and then 235.9 are listed
#####  # for metabolic which suggests that 235.9 is a typeo and should be 253.9.
#####  #
#####  # Then again, 253.9 is listed in the R code for metabolic and 235.9 is not in
#####  # the R code.  The opposite is true for SAS and Stata sources.
#####  #
#####  # There are other 253.\\d codes mapping to metabolic in all three languages.
#####  #
#####  # V3 documentation only complicates this more with 235.9 mapping to malignancy
#####  # and 253.9 mapping to metabolic.
#####  #
#####  #     icdv    dx full_code   code    src assignable_start assignable_end                                                                       desc desc_start desc_end
#####  #    <int> <int>    <char> <char> <char>            <int>          <int>                                                                     <char>      <int>    <int>
#####  # 1:     9     1     235.9   2359 cm_pcs             1997           2015                                   Other and unspecified respiratory organs       1997     2009
#####  # 2:     9     1     235.9   2359 cm_pcs             1997           2015 Neoplasm of uncertain behavior of other and unspecified respiratory organs       2010     2015
#####  # 3:     9     1     253.9   2539 cm_pcs             1997           2015                                                                Unspecified       1997     2009
#####  # 4:     9     1     253.9   2539 cm_pcs             1997           2015   Unspecified disorder of the pituitary gland and its hypothalamic control       2010     2015
#####
#####  if (interactive()) {
#####    rss_codes[grepl("^23", code)]
#####    rss_codes[grepl("^25", code)]
#####    rss_codes[grepl("^235", code)]
#####    rss_codes[grepl("^253", code)]
#####    rss_codes[grepl("^2359", code)]
#####    rss_codes[grepl("^2539", code)]
#####  }
#####
#####  # For v2.1 235.9 mapping to metabolic is considered a typeo and the code is
#####  # replaced by 253.9
#####  rss_codes[code == "2359" & condition == "metabolic", code := "2539"]
#####  eval(update_rss)
#####
#####  # ICD-10-CM I43
#####  #
#####  # In the documentation for V2 this is a cvd code AND a respiratory code.
#####  # It is only cvd in R and both in SAS and Stata.
#####  # Add it back for pccc_v2.1.
#####  if (interactive()) {
#####    rss_codes[code == "I43"]
#####  }
#####  rss_codes <- rss_codes[code == "I43" & condition == "respiratory", r := 1L]
#####  eval(update_rss)
#####
#####  # ICD-10-CM D84
#####  #
#####  # All three languages have D84 mapping to metabolic.
#####  #
#####  # The documentation for V2 only has D84.1 also mapping to metabolic.
#####  #
#####  # V3 docs have
#####  #  - D841 mapping to metabolic
#####  #  - D840, D841, D848, D8481, D84821, D84822, D8489, D849 mapping to hemato_immu
#####  #
#####  # It appears for v2 that D84.1 for metabolic is missing from the R code
#####  #
#####  if (interactive()) {
#####    rss_codes[grepl("^D84", code)]
#####  }
#####  rss_codes <- rss_codes[code == "D841" & condition == "metabolic", r := 1L]
#####  eval(update_rss)
#####
#####  # code 9782
#####  # This is in the stata codes for neuromusc, but not in r or sas.  978.2 is
#####  # poisoning by cholera vaccine. It is a likely typeo in the stata code.  978 is
#####  # not in the V2 docs and not in the V3 docs.  Further, this coded is listed as a
#####  # ICD-10-CM code which isn't possible.  Omit this code
#####  if (interactive()) {
#####    rss_codes[grepl("^978", code)]
#####    rss_codes[grepl("^9782", code)]
#####  }
#####  rss_codes <- rss_codes[!(code == "9782" & r == 0 & sas == 0 & stata == 1)]
#####
#####  # ICD-10-CM G31.8
#####  # This is a header and is in all three languages
#####  # The code G31.89 is explicitly in stata and SAS.
#####  # Using partical string matching the G3189 codes will be match because of G31.8.
#####  # For simplicity and reducing a small amount of computation work later, omit the
#####  # G31.89 row.
#####  if (interactive()) {
#####    rss_codes[grepl("^G318", code)]
#####  }
#####  rss_codes <- rss_codes[code != "G3189"]
#####
#####  # ICD-9-CM 7751
#####  # in stata just seems wrong, it is not in r or sas
#####  # It is not in the V2 documentation
#####  # It is not in the V3 documentation
#####  # stata has the code mapping to metabolic.
#####  #
#####  # icdv dx full_code code    src                       desc
#####  #    9  1     775.1 7751 cm_pcs Neonatal diabetes mellitus
#####  #
#####  # 775 is not in the V2 Docs either.
#####  if (interactive()) {
#####    rss_codes[grepl("^7751", code)]
#####    #subset(get_icd_codes(with.description = TRUE), code == "7751")
#####  }
#####  rss_codes <- rss_codes[code != "7751"]
#####
#####  # ICD-9-CM header codes 043 and 044
#####  #
#####  # the set of codes, but these do not
#####  # appear to be valid ICD-9-CM codes.  Likely reason for these codes being there
#####  # is that hemato_immu; acquired immunodeficiency lists 042-044.
#####  #
#####  # ICD-9-CM 043 and 044 — Never officially implemented
#####  #   * 043: Proposed for HIV infection resulting in specified conditions
#####  #   * 044: Proposed for other HIV-related conditions
#####  #
#####  # These codes appeared in early versions of ICD-9-CM documentation drafts but
#####  # were never active or valid for reporting or billing in the U.S.
#####  #
#####  # If you see 043 or 044 in historical data, it's usually:
#####  #   * An artifact of early or unofficial coding systems
#####  #   * A data entry or software error
#####  #   * Or a legacy system placeholder
#####  #
#####  # Omit them.
#####  if (interactive()) {
#####    rss_codes[grepl("^04[3,4]", code)]
#####    #subset(get_icd_codes(with.description = TRUE), grepl("^04[3,4]", code) & dx == 1)
#####  }
#####  rss_codes <- rss_codes[!(grepl("^04[34]", code) & dx == 1)]
#####
#####  # ICD-9-CM 427.[0-6,8-9] are valid codes, but the 4277 is not.
#####  if (interactive()) {
#####    rss_codes[grepl("^427", code)]
#####    #subset(get_icd_codes(with.description = TRUE), grepl("^427\\.\\d", full_code) & dx == 1)
#####  }
#####  rss_codes <- rss_codes[!(code == "4277" & dx == 1)]
#####
#####  # ICD-9-CM 428.[0-4,9] are valid ICD-9-CM codes.
#####  # 428.8, and any fifth digit, are not a valid ICD-9-CM codes.
#####  if (interactive()) {
#####    rss_codes[grepl("^428", code)]
#####    #subset(get_icd_codes(with.description = TRUE), grepl("^428\\.\\d$", full_code) & dx == 1)
#####  }
#####  rss_codes <- rss_codes[!(grepl("^4288", code) & dx == 1)]
#####
#####  # ICD-9-CM 571.7, and any fifth digit, are not a valid ICD-9-CM codes
#####  # 571.[0-6,8-9] are all valid ICD-9-CM codes
#####  # NOTE: ICD-9-PCS 57.17 is a valid code for Percutaneous cystostomy.
#####  if (interactive()) {
#####    rss_codes[grepl("^5717", code)]
#####    # subset(get_icd_codes(with.description = TRUE), grepl("^571\\.\\d$", full_code) & dx == 1)
#####  }
#####  rss_codes <- rss_codes[!(grepl("^5717", code) & dx == 1)]
#####
#####  # ICD-10-CM D08, and any fourth or fifth digit, are not valid ICD-10-CM codes
#####  # D0[0-7,9] are valid, at least as of 2025.
#####  if (interactive()) {
#####    rss_codes[grepl("^D08", code)]
#####    #subset(get_icd_codes(with.description = TRUE), grepl("^D0\\d$", full_code) & dx == 1)$full_code |> unique() |> sort()
#####  }
#####  rss_codes <- rss_codes[!(grepl("^D08", code) & dx == 1)]
#####
#####  # ICD-10-CM D85, and any fourth or fifth digit, are not valid
#####  # D8[0-4,6,9] are valid, at least as of 2025.
#####  if (interactive()) {
#####    rss_codes[grepl("^D8\\d$", code)]
#####    #subset(get_icd_codes(with.description = TRUE), grepl("^D8\\d$", full_code) & dx == 1)$full_code |> unique() |> sort()
#####  }
#####  rss_codes <- rss_codes[!(grepl("^D8[5,7,8]", code) & dx == 1)]
#####
#####  # ICD-10-CM D86
#####  # mapped to hemato_immu
#####  # D869 also mapped to hemato_immu in SAS and Stata
#####  # This is redundant once partical string matching is implemented
#####  if (interactive()) {
#####    rss_codes[grepl("^D86", code)]
#####  }
#####  stopifnot(rss_codes[code == "D86", condition == "hemato_immu"])
#####  rss_codes <- rss_codes[code != "D869"]
#####
#####  # ICD-10-CM G82
#####  # As of FY 2025, ICD-10-CM G82.[0-5] are valid codes
#####  # The listed G82.90 in the documentation is not a valid code.
#####  # V2 Docs only have G82.50-G82.54
#####  # Same for V3 docs
#####  #
#####  # Omit the errant G82.90
#####  if (interactive()) {
#####    rss_codes[grepl("^G82", code)]
#####    rss_codes[grepl("^G82[^9]", code)]
#####    #subset(get_icd_codes(with.description = TRUE), grepl("^G82", full_code) & dx == 1)$full_code |> unique() |> sort()
#####    #subset(get_icd_codes(with.description = TRUE), grepl("^G82", full_code) & dx == 1 & src == "cm_pcs")
#####  }
#####  rss_codes <- rss_codes[!(code == "G8290" & dx == 1)]
#####
#####  # ICD-9-CM V56
#####  # is not part of the docx file, but is in the code base.
#####  # Looking at the code it is for "Encounter for dialysis and dialysis catheter
#####  # care."  I ran into this issue when mapping subconditions in for v2.0.  Leave
#####  # this code in the set.
#####  #
#####  if (interactive()) {
#####    rss_codes[grepl("V56", code)]
#####  }
#####
#####  # ICD-10-CM G47.53 vs G47.35
#####  # In the V2 documentation G47.35 maps to respiratory
#####  # G47.53 does not map to any condition. It appears that the SAS code transposed
#####  # the fourth and fifth digits.  G47.35 is for a '... hypoventilation syndrome'
#####  # and G47.53 for 'recurrent isolated sleep paralysis'.
#####  #
#####  #     icdv    dx full_code   code    src assignable_start assignable_end                                                 desc desc_start desc_end
#####  #    <int> <int>    <char> <char> <char>            <int>          <int>                                               <char>      <int>    <int>
#####  # 1:    10     1    G47.35  G4735 cm_pcs             2014           2025 Congenital central alveolar hypoventilation syndrome       2014     2025
#####  # 2:    10     1    G47.53  G4753 cm_pcs             2014           2025                   Recurrent isolated sleep paralysis       2014     2025
#####  #
#####  # Fix the apparent error in the sas source
#####  #
#####  if (interactive()) {
#####    rss_codes[grepl("^G47", code)]
#####    #subset(get_icd_codes(with.description = TRUE), grepl("^G47\\.(5|3)(5|3)", full_code) & dx == 1)
#####  }
#####  rss_codes <- rss_codes[code == "G4753", code := "G4735"]
#####  eval(update_rss)
#####
#####  # ICD-9-CM 331 is listed in R.  Distinct sub codes are listed in SAS and Stata.
#####  # Partial string matching means that the sub codes are not needed.
#####  if (interactive()) {
#####    rss_codes[grepl("^331", code)]
#####  }
#####  rss_codes <- rss_codes[!grepl("^331\\d", code)]
#####  rss_codes[code == "331", `:=`(sas = 1L, stata = 1L)]
#####
#####  # ICD-10-CM 9620  -- Not a valid code -- omit it
#####  #
#####  # It is listed in the sas code for respiratory.
#####  #
#####  # ICD-9-CM  962.0: Poisoning by iron and its compounds
#####  # ICD-9-CM  962.4: Poisoning by anticoagulants
#####  # ICD-9-PCS 96.42: Irrigation of pancreatic tube
#####  #
#####  # ICD-9-PCS 96.24 is in all three sources for gi and tech_dep.
#####  if (interactive()) {
#####    rss_codes[grepl("^962", code)]
#####  }
#####  rss_codes <- rss_codes[!(code == "9620" & icdv == 10)]
#####
#####  # ICD-9-CM 416
#####  #
#####  # Part of the R and Stata code mappng to cvd. not in SAS.
#####  #
#####  # 416.2 is respiratory in the V2 docx
#####  # 416.1, 416.8, 416.9 are listed as cvd in the V2 docx
#####  # 416.0 was not listed in the V2 docx;  Stata and R  use it for respiratory
#####  #
#####  # From the V3 doc
#####  #   * 416.0 and 416.2 map to respiratory
#####  #   * 416.1, 416.8, 416.9 map to cvd
#####  #
#####  # Due to partial string matching the 416 header needs to be omitted from the
#####  # rss_codes object.  If left the cvd will be errantly mapped to 4160 4162 to cvd
#####  if (interactive()) {
#####    rss_codes[grepl("^416", code)]
#####    #subset(get_icd_codes(with.description = TRUE), grepl("^416\\.\\d", full_code) & dx == 1)
#####  }
#####  rss_codes <- rss_codes[code != "416"]
#####  rss_codes[code == "4160", sas := 1L]
#####  eval(update_rss)
#####
#####  # ICD-9-CM 996.82
#####  #
#####  # In the V2 docx for gi transplant
#####  #
#####  # Listed only in R for gi and transplant.
#####  # Listed as only transplant in SAS and Stata.
#####  #
#####  # update indictors
#####  if (interactive()) {
#####    rss_codes[grepl("^99682", code)]
#####  }
#####  rss_codes[code == "99682", `:=`(sas = 1L, stata = 1L)]
#####  eval(update_rss)
#####
#####  # ICD-9-CM 996.83
#####  #
#####  # In the V2 docx for cdv transplant
#####  #
#####  # Listed only in R for cvd and transplant.
#####  # Listed as only transplant in SAS and Stata.
#####  #
#####  # update indictors
#####  if (interactive()) {
#####    rss_codes[grepl("^99683", code)]
#####  }
#####  rss_codes[code == "99683", `:=`(sas = 1L, stata = 1L)]
#####  eval(update_rss)
#####
#####  # ICD-9-CM 996.84
#####  #
#####  # In the V2 docx for respiratory transplant
#####  #
#####  # Listed only in R for respiratory and transplant.
#####  # Listed as only transplant in SAS and Stata.
#####  #
#####  # update indictors
#####  if (interactive()) {
#####    rss_codes[grepl("^99684", code)]
#####  }
#####  rss_codes[code == "99684", `:=`(sas = 1L, stata = 1L)]
#####  eval(update_rss)
#####
#####  # ICD-9-CM 996.86
#####  #
#####  # In the V2 docx for gi transplant
#####  #
#####  # Listed only in R for gi and transplant.
#####  # Listed as only transplant in SAS and Stata.
#####  #
#####  # update indictors
#####  if (interactive()) {
#####    rss_codes[grepl("^99686", code)]
#####  }
#####  rss_codes[code == "99686", `:=`(sas = 1L, stata = 1L)]
#####  eval(update_rss)
#####
#####  # ICD-9-CM 996.87
#####  #
#####  # In the V2 docx for gi transplant
#####  #
#####  # Listed only in R for gi and transplant.
#####  # Listed as only transplant in SAS and Stata.
#####  #
#####  # update indictors
#####  if (interactive()) {
#####    rss_codes[grepl("^99687", code)]
#####  }
#####  rss_codes[code == "99687", `:=`(sas = 1L, stata = 1L)]
#####  eval(update_rss)
#####
#####  # ICD-10-CM Q21
#####  #
#####  # Q21.2-Q24 listed in the V2 docx for cvd heart and great vessel malformations
#####  #
#####  # Q21.9 is listed in R and Stata, not in SAS.
#####  #
#####  # Q21.9 is listed in the V3 docx for cvd
#####  #
#####  # update the sas flag in the rss_codes object
#####  if (interactive()) {
#####    rss_codes[grepl("^Q21", code)]
#####    subset(get_icd_codes(with.description = TRUE), grepl("^Q21", full_code) & dx == 1 & src == "cm_pcs")
#####  }
#####  rss_codes[code == "Q219", `:=`(sas = 1L)]
#####  eval(update_rss)
#####
#####  # ICD-10-CM Q25
#####  #
#####  # Q25.8 and Q25.9 are in R and Stata, not in SAS
#####  #
#####  # These codes are covered in the V2 docx under cvd heart and great vessel
#####  # malformations via the code range Q25.1-Q26
#####  #
#####  # The both codes are in the V3 docx
#####  #
#####  if (interactive()) {
#####    rss_codes[grepl("^Q25", code)]
#####    subset(get_icd_codes(with.description = TRUE), grepl("^Q25", full_code) & dx == 1 & src == "cm_pcs")
#####  }
#####  rss_codes[code == "Q258", `:=`(sas = 1L)]
#####  rss_codes[code == "Q259", `:=`(sas = 1L)]
#####  eval(update_rss)
#####
#####  # ICD-10-CM Q26.8
#####  #
#####  # Code Q26 is in the set for all three languages and the docx.  The Q268 is
#####  # redundant after partial string matching is done.
#####  if (interactive()) {
#####    rss_codes[grepl("^Q26", code)]
#####  }
#####  rss_codes <- rss_codes[code != "Q268"]
#####
#####  # ICD-10-CM T82.121A
#####  # In R and SAS, missing in Stata
#####  # In V2 docx for cvd adn tech_dep
#####  # update stata flag
#####  if (interactive()) {
#####    rss_codes[grepl("^T8212", code)]
#####  }
#####  rss_codes[code == "T82121A", `:=`(stata = 1L)]
#####
#####  # ICD-10-CM T86.2
#####  #
#####  # T86.20, T86.21, and T86.21 are all in the V2 docx for CVD transplant, and for
#####  # misc, device.
#####  #
#####  # R has this code for CVD, transplant, and tech_dep
#####  # SAS and Stata only have transplant and tech_dep
#####  #
#####  # Update flags
#####  if (interactive()) {
#####    rss_codes[grepl("^T862", code)]
#####  }
#####  rss_codes[grepl("^T862[0,1,2]", code), `:=`(sas = 1L, stata = 1L)]
#####
#####  # ICD-9-CM 359.2
#####  #
#####  # 359.0-359.3 is listed in the V2 docx for neuromusc, muscular dystrophies and
#####  # myopathies.  The fifth digit codes for 359.2[1-3,9] are in the R code but not
#####  # in the SAS or Stata code.  Partial string maching on the "359" that is in all
#####  # three will result in these four and five digit codes being matched.
#####  #
#####  # One notable problem, valid 359 four digit codes are 359\\.[0-9]
#####  #
#####  # Solution - omit the 359 header and use only the wanted four digit codes
#####  #
#####  if (interactive()) {
#####    rss_codes[grepl("^359", code)]
#####    subset(get_icd_codes(with.description = TRUE), grepl("^359\\.\\d$", full_code) & dx == 1)
#####  }
#####  rss_codes <- rss_codes[code != "359"]
#####  rss_codes <- rss_codes[!grepl("^3592\\d$", code)]
#####
#####
#####  # ICD-10-CM Z94.0
#####  #
#####  # In V2 docx for renal, transplant
#####  #
#####  # It is listed in the R, SAS, and Stata code as renal, tech_dep.
#####  # Only R has it as transplant.
#####  #
#####  # Fix: remove tech_dep, add flag for transplant in sas and stata
#####  #
#####  # It is listed in
#####  if (interactive()) {
#####    rss_codes[grepl("^Z94", code)] |> print(nrow = Inf)
#####    rss_codes[grepl("^Z940", code)]
#####    subset(get_icd_codes(with.description = TRUE), grepl("^359\\.\\d$", full_code) & dx == 1)
#####  }
#####  rss_codes <- rss_codes[!(code == "Z940" & condition == "tech_dep")]
#####  rss_codes[code == "Z940", `:=`(sas = 1L, stata = 1L)]
#####
#####  # ICD-10-CM Z94.2
#####  #
#####  # When looking at Z94.0 I saw that Z94.2 was also mapped to tech_dep.
#####  #
#####  # This is not accurate per V2 docs.  It should just be respiratory transplant.
#####  #
#####  # fix: change the condition from tech_dep to transplant
#####  if (interactive()) {
#####    rss_codes[grepl("^Z94", code)] |> print(nrow = Inf)
#####    rss_codes[grepl("^Z942", code)]
#####    subset(get_icd_codes(with.description = TRUE), grepl("^359\\.\\d$", full_code) & dx == 1)
#####  }
#####  rss_codes[(code == "Z942" & condition == "tech_dep"), condition := "transplant"]
#####
#####  # Find any code that is not consistent between all three sources
#####  eval(update_rss)
#####  if (interactive()) {
#####    rss_codes[r != sas | r != stata | sas != stata]
#####  }
#####  stopifnot(rss_codes[, all(r == sas) & all(sas == stata)])
#####
#####
#####
#####  ################################################################################
#####  # save to disk
#####  setDF(rss_codes)
#####  saveRDS(rss_codes, "pccc_v2_r_sas_stata.rds")

################################################################################
#                                 End of File                                  #
################################################################################
