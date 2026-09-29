################################################################################
# file: icd/icd10/utilities.R
#
# purpose: Provide helper functions for parsing ICD-10 order and description
#          files.
#
# inputs: none (function definitions only)
#
# output: Defines orderfile_to_DT() and desc_to_DT() for reuse.
#
# deps: data.table
#
# notes:
#   Sourced by other ICD-10 scripts for consistent parsing of order and
#     description files.
#
# idempotent: yes (pure function definitions)
################################################################################

################################################################################
# Build a data.table from the order files
orderfile_to_DT <- function(x) {
  stopifnot(inherits(x, "character"))
  data.table::data.table(
    code  = trimws(substr(x, start = 7, stop = 13))
    #, order = trimws(substr(x, start = 1, stop = 5))
    , header = 1L - as.integer(trimws(substr(x, start = 15, stop = 15)))
    #, short_desc = trimws(substr(x, start = 17, stop = 77))
    , desc  = trimws(substr(x, start = 78, stop = 10000L))
    )
}

desc_to_DT <- function(x) {
  stopifnot(inherits(x, "character"))
  data.table::data.table(
    code  = trimws(substr(x, start = 1, stop = 8))
    , desc  = trimws(substr(x, start = 9, stop = 10000L))
    )
}

# Read exactly one order-file member by basename, allowing publisher directory
# layouts to vary. No shared extraction directory or silent overwrite policy.
read_order_archive <- function(archive, member) {
  if (!file.exists(archive)) stop("Missing source archive: ", archive)
  entries <- unzip(archive, list = TRUE)$Name
  selected <- entries[basename(entries) == member]
  if (length(selected) != 1L) {
    stop("Expected exactly one ", member, " in ", archive)
  }
  con <- unz(archive, selected, open = "r")
  on.exit(close(con))
  readLines(con, warn = FALSE)
}

################################################################################
#                                 End of File                                  #
################################################################################

