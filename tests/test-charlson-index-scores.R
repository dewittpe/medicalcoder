library(medicalcoder)
source('utilities.R')

stopifnot(is.data.frame(medicalcoder:::..mdcr_internal_charlson_index_scores..))

stopifnot(
  identical(
    names(medicalcoder:::..mdcr_internal_charlson_index_scores..),
    c("condition_description", "condition", "charlson_cdmf2019", "charlson_quan2011", "charlson_quan2005", "charlson_deyo1992")
  )
)

stopifnot(
  identical(
    sapply(medicalcoder:::..mdcr_internal_charlson_index_scores.., class),
    c(condition_description = "character",
      condition = "character",
      charlson_cdmf2019 = "integer",
      charlson_quan2011 = "integer",
      charlson_quan2005 = "integer",
      charlson_deyo1992 = "integer"
    )
  )
)


stopifnot(is.data.frame(get_charlson_index_scores()))

stopifnot(
  identical(get_charlson_index_scores(), medicalcoder:::..mdcr_internal_charlson_index_scores..)
)

################################################################################
#                                 End of File                                  #
################################################################################
