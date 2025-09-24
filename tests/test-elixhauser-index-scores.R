library(medicalcoder)

stopifnot(is.data.frame(medicalcoder:::..mdcr_internal_elixhauser_index_scores..))

stopifnot(identical(get_elixhauser_index_scores(), medicalcoder:::..mdcr_internal_elixhauser_index_scores..))

stopifnot(
  identical(
    sapply(get_elixhauser_index_scores(), class),
    c(
      condition                 = "character",
      index                     = "character",
      elixhauser_ahrq_web       = "integer",
      elixhauser_elixhauser1988 = "integer",
      elixhauser_quan2005       = "integer",
      elixhauser_ahrq2022       = "integer",
      elixhauser_ahrq2023       = "integer",
      elixhauser_ahrq2024       = "integer",
      elixhauser_ahrq2025       = "integer"
     )
  )
)

eis <- get_elixhauser_index_scores()
stopifnot(identical(rownames(eis), as.character(seq_len(nrow(eis)))))

################################################################################
#                                 End of File                                  #
################################################################################
