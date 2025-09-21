library(medicalcoder)

stopifnot(is.data.frame(medicalcoder:::..mdcr_internal_elixhauser_codes..))

stopifnot(
  identical(
    names(medicalcoder:::..mdcr_internal_elixhauser_codes..),
    c("code_id", "condition", "elixhauser_ahrq_web", "elixhauser_elixhauser1988", "elixhauser_quan2005", "elixhauser_ahrq2022", "elixhauser_ahrq2023", "elixhauser_ahrq2024", "elixhauser_ahrq2025")
  )
)

stopifnot(
  identical(
    sapply(medicalcoder:::..mdcr_internal_elixhauser_codes.., class) ,
    c(code_id = "integer",
      condition = "character",
      elixhauser_ahrq_web = "integer",
      elixhauser_elixhauser1988 = "integer",
      elixhauser_quan2005 = "integer",
      elixhauser_ahrq2022 = "integer",
      elixhauser_ahrq2023 = "integer",
      elixhauser_ahrq2024 = "integer",
      elixhauser_ahrq2025 = "integer"
    )
  )
)


stopifnot(is.data.frame(get_elixhauser_codes()))

stopifnot(
  identical(
    names(get_elixhauser_codes()),
    c("icdv", "dx", "full_code", "code", "condition", "elixhauser_ahrq_web", "elixhauser_elixhauser1988", "elixhauser_quan2005", "elixhauser_ahrq2022", "elixhauser_ahrq2023", "elixhauser_ahrq2024", "elixhauser_ahrq2025")
  )
)

stopifnot(
  identical(
    sapply(medicalcoder:::..mdcr_internal_elixhauser_codes.., class),
    c(code_id = "integer",
      condition = "character",
      elixhauser_ahrq_web = "integer",
      elixhauser_elixhauser1988 = "integer",
      elixhauser_quan2005 = "integer",
      elixhauser_ahrq2022 = "integer",
      elixhauser_ahrq2023 = "integer",
      elixhauser_ahrq2024 = "integer",
      elixhauser_ahrq2025 = "integer"
    )
  )
)


stopifnot(is.data.frame(get_elixhauser_codes()))

stopifnot(
  identical(
    names(get_elixhauser_codes()),
    c("icdv", "dx", "full_code", "code", "condition", "elixhauser_ahrq_web", "elixhauser_elixhauser1988", "elixhauser_quan2005", "elixhauser_ahrq2022", "elixhauser_ahrq2023", "elixhauser_ahrq2024", "elixhauser_ahrq2025")
  )
)

stopifnot(
  identical(
    sapply(get_elixhauser_codes(), class),
    c(icdv = "integer",
      dx = "integer",
      full_code = "character",
      code = "character",
      condition = "character",
      elixhauser_ahrq_web = "integer",
      elixhauser_elixhauser1988 = "integer",
      elixhauser_quan2005 = "integer",
      elixhauser_ahrq2022 = "integer",
      elixhauser_ahrq2023 = "integer",
      elixhauser_ahrq2024 = "integer",
      elixhauser_ahrq2025 = "integer" )
  )
)

stopifnot(
  identical(
    sapply(get_elixhauser_codes(), class),
    c(icdv = "integer",
      dx = "integer",
      full_code = "character",
      code = "character",
      condition = "character",
      elixhauser_ahrq_web = "integer",
      elixhauser_elixhauser1988 = "integer",
      elixhauser_quan2005 = "integer",
      elixhauser_ahrq2022 = "integer",
      elixhauser_ahrq2023 = "integer",
      elixhauser_ahrq2024 = "integer",
      elixhauser_ahrq2025 = "integer"
    )
  )
)


# check that the row names are just sequential integers
ec <- get_elixhauser_codes()
stopifnot(identical(rownames(ec), as.character(seq_len(nrow(ec)))))
