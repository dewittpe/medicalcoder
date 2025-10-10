source('utilities.R')
library(medicalcoder)

ICDCODES     <- get_icd_codes()
ICDDESCS     <- get_icd_codes(with.descriptions = TRUE,  with.hierarchy = FALSE)
ICDHIER      <- get_icd_codes(with.descriptions = FALSE, with.hierarchy = TRUE)
ICDDH        <- get_icd_codes(with.descriptions = TRUE,  with.hierarchy = TRUE)

# The way these functions should work is to build the needed user friendly data
# set from the internal look up tables and save the result in the a package
# envrionment.  This is done so the initial call may take some time to build the
# data, subsequent calls will retrive the cached data.  The next four lines
# verify that the return from the subsequent call is identical to the initial
# call.
ICDCODES2    <- get_icd_codes()
ICDDESCS2    <- get_icd_codes(with.descriptions = TRUE,  with.hierarchy = FALSE)
ICDHIER2     <- get_icd_codes(with.descriptions = FALSE, with.hierarchy = TRUE)
ICDDH2       <- get_icd_codes(with.descriptions = TRUE,  with.hierarchy = TRUE)

stopifnot(isTRUE(identical(ICDCODES, ICDCODES2)))
stopifnot(isTRUE(identical(ICDDESCS, ICDDESCS2)))
stopifnot(isTRUE(identical(ICDHIER,  ICDHIER2)))
stopifnot(isTRUE(identical(ICDDH,    ICDDH2)))

# verify that the ICD codes are data.frames, nothing more.
stopifnot(class(ICDCODES) == "data.frame")
stopifnot(class(ICDDESCS) == "data.frame")
stopifnot(class(ICDHIER)  == "data.frame")
stopifnot(class(ICDDH)    == "data.frame")

# verify that the row names are just integers
stopifnot(identical(rownames(ICDCODES), as.character(seq_len(nrow(ICDCODES)))))
stopifnot(identical(rownames(ICDDESCS), as.character(seq_len(nrow(ICDDESCS)))))
stopifnot(identical(rownames(ICDHIER),  as.character(seq_len(nrow(ICDHIER)))))
stopifnot(identical(rownames(ICDDH),    as.character(seq_len(nrow(ICDDH)))))

# verify the names are as expected, the order shouldn't matter, but this test
# will verify the order is as expected too.
expected_icd_code_columns <- c("icdv", "dx", "full_code", "code", "src", "known_start", "known_end", "assignable_start", "assignable_end")
expected_icd_desc_columns <- c("desc", "desc_start", "desc_end")
expected_icd_hier_columns <- c("chapter", "subchapter", "category", "subcategory", "subclassification", "subsubclassification", "extension")
stopifnot(isTRUE(identical(names(ICDCODES),   expected_icd_code_columns)))
stopifnot(isTRUE(identical(names(ICDDESCS), c(expected_icd_code_columns, expected_icd_desc_columns))))
stopifnot(isTRUE(identical(names(ICDHIER),  c(expected_icd_code_columns, expected_icd_hier_columns))))
stopifnot(isTRUE(identical(names(ICDDH),    c(expected_icd_code_columns, expected_icd_desc_columns, expected_icd_hier_columns))))

# Verify the column classes are as expected
nc <-
  c(
    "icdv" = "integer",
    "dx" = "integer",
    "full_code" = "character",
    "code" = "character",
    "src" = "character",
    "known_start" = "integer",
    "known_end" = "integer",
    "assignable_start" = "integer",
    "assignable_end" = "integer",
    "desc" = "character",
    "desc_start" = "integer",
    "desc_end" = "integer",
    "chapter" = "character",
    "subchapter" = "character",
    "category" = "character",
    "subcategory" = "character",
    "subclassification" = "character",
    "subsubclassification" = "character",
    "extension" = "character"
  )

for(j in names(ICDCODES)) {
  stopifnot(isTRUE(inherits(ICDCODES[[j]], nc[j])))
}

for(j in names(ICDDESCS)) {
  stopifnot(isTRUE(inherits(ICDDESCS[[j]], nc[j])))
}

for(j in names(ICDHIER)) {
  stopifnot(isTRUE(inherits(ICDHIER[[j]], nc[j])))
}

for(j in names(ICDDH)) {
  stopifnot(isTRUE(inherits(ICDDH[[j]], nc[j])))
}

# if assignable_start is NA then assignable_end should be NA
idx <- which(is.na(ICDCODES[["assignable_start"]]))
stopifnot(all(is.na(ICDCODES[["assignable_end"]][idx])))

idx <- which(is.na(ICDHIER[["assignable_start"]]))
stopifnot(all(is.na(ICDHIER[["assignable_end"]][idx])))

# Verify that columns are populated
stopifnot(all(Negate(is.na)(ICDCODES[["icdv"]])))
stopifnot(all(Negate(is.na)(ICDCODES[["dx"]])))
stopifnot(all(Negate(is.na)(ICDCODES[["full_code"]])))
stopifnot(all(Negate(is.na)(ICDCODES[["code"]])))
stopifnot(all(Negate(is.na)(ICDCODES[["known_start"]])))
stopifnot(all(Negate(is.na)(ICDCODES[["known_end"]])))

stopifnot(all(Negate(is.na)(ICDHIER[["icdv"]])))
stopifnot(all(Negate(is.na)(ICDHIER[["dx"]])))
stopifnot(all(Negate(is.na)(ICDHIER[["full_code"]])))
stopifnot(all(Negate(is.na)(ICDHIER[["code"]])))
stopifnot(all(Negate(is.na)(ICDHIER[["chapter"]])))
stopifnot(all(Negate(is.na)(ICDHIER[["known_start"]])))
stopifnot(all(Negate(is.na)(ICDHIER[["known_end"]])))

# Verify that the src column is as expected
stopifnot(
  identical(c("cdc", "cms", "who"), sort(unique(ICDCODES[["src"]]))),
  identical(c("cdc", "cms", "who"), sort(unique(ICDDESCS[["src"]]))),
  identical(c("cdc", "cms", "who"), sort(unique(ICDHIER[["src"]]))),
  identical(c("cdc", "cms", "who"), sort(unique(ICDDH[["src"]])))
)

################################################################################
#                                 End of File                                  #
################################################################################
