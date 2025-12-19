source('utilities.R')
library(medicalcoder)

################################################################################
# verify the list of possible elixhauser methods
m <- grep("elixhauser_", medicalcoder:::comorbidities_methods(), value = TRUE)
stopifnot(
  identical(
    m,
    c("elixhauser_elixhauser1988",
      "elixhauser_ahrq_web",
      "elixhauser_quan2005",
      "elixhauser_ahrq2022",
      "elixhauser_ahrq2023",
      "elixhauser_ahrq2024",
      "elixhauser_ahrq2025",
      "elixhauser_ahrq2026",
      "elixhauser_ahrq_icd10"
    )
  )
)

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
