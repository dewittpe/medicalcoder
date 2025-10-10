source('utilities.R')
library(medicalcoder)

################################################################################
# check the internal data set
stopifnot(is.data.frame(medicalcoder:::..mdcr_internal_icd_codes..))

stopifnot(
  identical(
    names(medicalcoder:::..mdcr_internal_icd_codes..),
    c("icdv", "dx", "full_code", "code", "code_id", "chap_id", "subchap_id")
  )
)

stopifnot(
  identical(
    sapply(medicalcoder:::..mdcr_internal_icd_codes.., class),
    c(icdv = "integer",
      dx = "integer",
      full_code = "character",
      code = "character",
      code_id = "integer",
      chap_id = "integer",
      subchap_id = "integer")
  )
)

# see test-get_icd.R


################################################################################
#                                 End of File                                  #
################################################################################
