################################################################################
# file: mdcr_longitudinal.R
#
# purpose: Build a simple longitudinal example dataset for package examples; set
#          column names to (icdv, code) and save as internal example data.
#
# inputs:  longitudinal_example_data.dat (columns: icd_type, icd_code, …)
#
# output:  ../../data/mdcr_longitudinal.rda
#
# deps:    data.table (fread, setnames); base R
#
# notes:   Expects to be run from the directory containing the .dat file.
#          Produces a data.frame object named mdcr_longitudinal.
#
# idempotent: yes (pure read/rename/save)
#
################################################################################
mdcr_longitudinal <- data.table::fread("longitudinal_example_data.dat")
data.table::setnames(mdcr_longitudinal, old = c("icd_type", "icd_code"), new = c("icdv", "code"))
data.table::setDF(mdcr_longitudinal)
save(mdcr_longitudinal, file = "../../data/mdcr_longitudinal.rda", ascii = FALSE, version = 3, compress = "xz", compression_level = 9)

################################################################################
#                                 End of File                                  #
################################################################################
