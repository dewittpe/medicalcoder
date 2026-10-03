################################################################################
# verify that the elixhauser_ahrq_icd10 covers all the codes for prior
# elixhauser_ahrqYYYY methods
ec <- get_elixhauser_codes()

ahrqYYYY <- ec[, grep("elixhauser_ahrq\\d{4}", names(ec), value = TRUE)]
stopifnot(
  sum(as.integer(rowSums(ahrqYYYY, na.rm = TRUE) > 0)) == sum(ec[["elixhauser_ahrq_icd10"]], na.rm = TRUE)
)

################################################################################
#                                 End of File                                  #
################################################################################
