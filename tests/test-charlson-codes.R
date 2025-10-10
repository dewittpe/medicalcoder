source('utilities.R')
library(medicalcoder)

internal_codes <- medicalcoder:::..mdcr_internal_charlson_codes..
public_codes   <- get_charlson_codes()
index_scores   <- get_charlson_index_scores()

expected_internal_cols <- c('code_id', 'condition', 'charlson_cdmf2019', 'charlson_deyo1992', 'charlson_quan2005', 'charlson_quan2011')
expected_public_cols   <- c('icdv', 'dx', 'full_code', 'code', 'condition', 'charlson_cdmf2019', 'charlson_deyo1992', 'charlson_quan2005', 'charlson_quan2011')
expected_internal_classes <- c(code_id = 'integer', condition = 'character', charlson_cdmf2019 = 'integer', charlson_deyo1992 = 'integer', charlson_quan2005 = 'integer', charlson_quan2011 = 'integer')
expected_public_classes   <- c(icdv = 'integer', dx = 'integer', full_code = 'character', code = 'character', condition = 'character', charlson_cdmf2019 = 'integer', charlson_deyo1992 = 'integer', charlson_quan2005 = 'integer', charlson_quan2011 = 'integer')

stopifnot(inherits(internal_codes, 'data.frame'))
stopifnot(!inherits(internal_codes, 'data.table'))
stopifnot(!inherits(internal_codes, 'tbl_df'))
stopifnot(inherits(public_codes, 'data.frame'))
stopifnot(!inherits(public_codes, 'data.table'))
stopifnot(!inherits(public_codes, 'tbl_df'))

stopifnot(identical(names(internal_codes), expected_internal_cols))
stopifnot(identical(names(public_codes), expected_public_cols))
stopifnot(identical(sapply(internal_codes, class), expected_internal_classes))
stopifnot(identical(sapply(public_codes, class), expected_public_classes))

stopifnot(nrow(internal_codes) > 0L)
stopifnot(nrow(public_codes) > 0L)
stopifnot(length(unique(internal_codes$code_id)) == nrow(internal_codes))
stopifnot(length(unique(public_codes$full_code)) == nrow(public_codes))
stopifnot(all(public_codes$dx %in% c(0L, 1L)))

stopifnot(identical(rownames(internal_codes), as.character(seq_len(nrow(internal_codes)))))
stopifnot(identical(rownames(public_codes),   as.character(seq_len(nrow(public_codes)))))
stopifnot(identical(rownames(index_scores),   as.character(seq_len(nrow(index_scores)))))

# verify get_charlson_codes() returns a copy, not the internal table
public_codes$condition[1] <- '__tmp__'
stopifnot(identical(get_charlson_codes(), internal_codes))

# reset public R objects after copy check
public_codes <- get_charlson_codes()
index_scores <- get_charlson_index_scores()

################################################################################
#                                 End of File                                  #
################################################################################
