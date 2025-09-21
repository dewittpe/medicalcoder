library(medicalcoder)
library(data.table)
library(tibble)

stopifnot(is.data.frame(medicalcoder:::..mdcr_internal_charlson_codes..))
stopifnot(!is_tibble(medicalcoder:::..mdcr_internal_charlson_codes..))
stopifnot(!is.data.table(medicalcoder:::..mdcr_internal_charlson_codes..))

stopifnot(
  identical(
    names(medicalcoder:::..mdcr_internal_charlson_codes..),
    c("code_id", "condition", "charlson_cdmf2019", "charlson_deyo1992", "charlson_quan2005", "charlson_quan2011")
  )
)

stopifnot(
  identical(
    sapply(medicalcoder:::..mdcr_internal_charlson_codes.., class),
    c(code_id = "integer",
      condition = "character",
      charlson_cdmf2019 = "integer",
      charlson_deyo1992 = "integer",
      charlson_quan2005 = "integer",
      charlson_quan2011 = "integer"
    )
  )
)


stopifnot(is.data.frame(get_charlson_codes()))
stopifnot(!is_tibble(get_charlson_codes()))
stopifnot(!is.data.table(get_charlson_codes()))

stopifnot(
  identical(
    names(get_charlson_codes()),
    c("icdv", "dx", "full_code", "code", "condition", "charlson_cdmf2019", "charlson_deyo1992", "charlson_quan2005", "charlson_quan2011")
  )
)

stopifnot(
  identical(
    sapply(get_charlson_codes(), class),
    c(icdv = "integer",
      dx = "integer",
      full_code = "character",
      code = "character",
      condition = "character",
      charlson_cdmf2019 = "integer",
      charlson_deyo1992 = "integer",
      charlson_quan2005 = "integer",
      charlson_quan2011 = "integer"
    )
  )
)

# check that the row names are just sequential integers
cc <- get_charlson_codes()
ci <- get_charlson_index_scores()
stopifnot(identical(rownames(cc), as.character(seq_len(nrow(cc)))))
stopifnot(identical(rownames(ci), as.character(seq_len(nrow(ci)))))
