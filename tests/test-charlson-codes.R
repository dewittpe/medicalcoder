library(medicalcoder)

# verify that the internal data set is a data.frame, and only a data.frame, not
# a data.table, not a tibble
stopifnot( inherits(medicalcoder:::..mdcr_internal_charlson_codes.., "data.frame"))
stopifnot(!inherits(medicalcoder:::..mdcr_internal_charlson_codes.., "data.table"))
stopifnot(!inherits(medicalcoder:::..mdcr_internal_charlson_codes.., "tbl_df"))

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

stopifnot( inherits(get_charlson_codes(), "data.frame"))
stopifnot(!inherits(get_charlson_codes(), "data.table"))
stopifnot(!inherits(get_charlson_codes(), "tbl_df"))

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
