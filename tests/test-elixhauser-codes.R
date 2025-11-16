source('utilities.R')
library(medicalcoder)

################################################################################
# test the structure of the internal object

stopifnot(is.data.frame(medicalcoder:::..mdcr_internal_elixhauser_codes..))

stopifnot(
  identical(
    names(medicalcoder:::..mdcr_internal_elixhauser_codes..),
    c("code_id",
      "poaexempt",
      "condition",
      "elixhauser_ahrq_web",
      "elixhauser_elixhauser1988",
      "elixhauser_quan2005",
      "elixhauser_ahrq2022",
      "elixhauser_ahrq2023",
      "elixhauser_ahrq2024",
      "elixhauser_ahrq2025",
      "elixhauser_ahrq_icd10"
    )
  )
)

stopifnot(
  identical(
    sapply(medicalcoder:::..mdcr_internal_elixhauser_codes.., class),
    c(code_id = "integer",
      poaexempt = "integer",
      condition = "character",
      elixhauser_ahrq_web = "integer",
      elixhauser_elixhauser1988 = "integer",
      elixhauser_quan2005 = "integer",
      elixhauser_ahrq2022 = "integer",
      elixhauser_ahrq2023 = "integer",
      elixhauser_ahrq2024 = "integer",
      elixhauser_ahrq2025 = "integer",
      elixhauser_ahrq_icd10 = "integer"
    )
  )
)

################################################################################
# Test the structure of the object returned by get_elixhauser_codes()

stopifnot(is.data.frame(get_elixhauser_codes()))

stopifnot(
  identical(
    names(get_elixhauser_codes()),
    c("icdv", "dx", "full_code", "code",
      "poaexempt",
      "condition",
      "elixhauser_ahrq_web",
      "elixhauser_elixhauser1988",
      "elixhauser_quan2005",
      "elixhauser_ahrq2022",
      "elixhauser_ahrq2023",
      "elixhauser_ahrq2024",
      "elixhauser_ahrq2025",
      "elixhauser_ahrq_icd10"
    )
  )
)


stopifnot(
  identical(
    sapply(get_elixhauser_codes(), class),
    c(icdv = "integer",
      dx = "integer",
      full_code = "character",
      code = "character",
      poaexempt = "integer",
      condition = "character",
      elixhauser_ahrq_web = "integer",
      elixhauser_elixhauser1988 = "integer",
      elixhauser_quan2005 = "integer",
      elixhauser_ahrq2022 = "integer",
      elixhauser_ahrq2023 = "integer",
      elixhauser_ahrq2024 = "integer",
      elixhauser_ahrq2025 = "integer",
      elixhauser_ahrq_icd10 = "integer"
    )
  )
)

# check that the row names are just sequential integers
ec <- get_elixhauser_codes()
stopifnot(identical(rownames(ec), as.character(seq_len(nrow(ec)))))

################################################################################
#                                 End of File                                  #
################################################################################
