################################################################################
# Tests for the elixhauser comorbidities

library(medicalcoder)

################################################################################
# verify the list of possible charlson methods
m <- grep("elixhauser_", medicalcoder:::comorbidities_methods(), value = TRUE)
stopifnot(
  identical(
    m,
    c("elixhauser_elixhauser1988", "elixhauser_ahrq_web", "elixhauser_quan2005", "elixhauser_ahrq2022", "elixhauser_ahrq2023", "elixhauser_ahrq2024", "elixhauser_ahrq2025")
  )
)

################################################################################
#                                 End of File                                  #
################################################################################
