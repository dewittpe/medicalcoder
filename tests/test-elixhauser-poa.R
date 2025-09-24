library(medicalcoder)

stopifnot(is.data.frame(medicalcoder:::..mdcr_internal_elixhauser_poa..))

stopifnot(identical(get_elixhauser_poa(), medicalcoder:::..mdcr_internal_elixhauser_poa..))

stopifnot(
  identical(
    sapply(get_elixhauser_poa(), class),
    c(condition          = "character",
      desc               = "character",
      poa_required        = "integer",
      elixhauser_ahrq2022 = "integer",
      elixhauser_ahrq2023 = "integer",
      elixhauser_ahrq2024 = "integer",
      elixhauser_ahrq2025 = "integer"
    )
  )
)


ep <- get_elixhauser_poa()
stopifnot(identical(rownames(ep), as.character(seq_len(nrow(ep)))))

################################################################################
#                                 End of File                                  #
################################################################################
