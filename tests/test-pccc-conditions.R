source('utilities.R')
library(medicalcoder)

stopifnot(is.data.frame(medicalcoder:::..mdcr_internal_pccc_conditions..))

stopifnot(
  identical(
    names(medicalcoder:::..mdcr_internal_pccc_conditions..),
    c("condition", "subcondition", "condition_label", "subcondition_label")
  )
)

stopifnot(
  identical(
    sapply(medicalcoder:::..mdcr_internal_pccc_conditions.., class),
    c(condition = "character",
      subcondition = "character",
      condition_label = "character",
      subcondition_label = "character"
    )
  )
)

stopifnot(identical(get_pccc_conditions(), medicalcoder:::..mdcr_internal_pccc_conditions..))

################################################################################
#                                 End of File                                  #
################################################################################
