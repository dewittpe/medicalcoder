library(medicalcoder)
################################################################################
# check the internal data set
stopifnot(is.data.frame(medicalcoder:::..mdcr_internal_pccc_codes..))

stopifnot(
  identical(
    names(medicalcoder:::..mdcr_internal_pccc_codes..),
    c("code_id", "condition", "subcondition", "transplant_flag",
      "tech_dep_flag", "pccc_v3.1", "pccc_v3.0", "pccc_v2.1", "pccc_v2.0")
  )
)

stopifnot(
  identical(
    sapply(medicalcoder:::..mdcr_internal_pccc_codes.., class),
    c(code_id = "integer",
      condition = "character",
      subcondition = "character",
      transplant_flag = "integer",
      tech_dep_flag = "integer",
      pccc_v3.1 = "integer",
      pccc_v3.0 = "integer",
      pccc_v2.1 = "integer",
      pccc_v2.0 = "integer"
    )
  )
)

################################################################################
# Verify that the pccc codes are retrievable as a data.frame
pccc_codes <- get_pccc_codes()

stopifnot("pccc_codes are a data.frame" = identical(class(pccc_codes), "data.frame"))
stopifnot(
  identical(
    names(pccc_codes),
    c("icdv", "dx", "full_code", "code", "condition", "subcondition", "transplant_flag", "tech_dep_flag", "pccc_v3.1", "pccc_v3.0", "pccc_v2.1", "pccc_v2.0")
  )
)

################################################################################
# Verify that all the ICD codes in the data set are valid codes
x <- is_icd(pccc_codes$code, headerok = TRUE, ever.assignable = TRUE, warn.ambiguous = FALSE)
stopifnot("all compact pccc_codes are valid ever.assignable icd codes" = all(x))

x <- is_icd(pccc_codes$full_code, headerok = TRUE, ever.assignable = TRUE, warn.ambiguous = FALSE)
stopifnot("all full pccc_codes are valid ever.assignable icd codes" = all(x))

x <-
  pccc_codes[pccc_codes$icdv == 9 & pccc_codes$dx == 1, "full_code"] |>
  is_icd(icdv = 9, dx = 1, headerok = TRUE, ever.assignable = TRUE, warn.ambiguous = FALSE)
stopifnot("all icdv 9 dx full codes are valid ever.assignable icd codes" = all(x))

x <-
  pccc_codes[pccc_codes$icdv == 9 & pccc_codes$dx == 0, "full_code"] |>
  is_icd(icdv = 9, dx = 0, headerok = TRUE, ever.assignable = TRUE, warn.ambiguous = FALSE)
stopifnot("all icdv 9 pr full codes are valid ever.assignable icd codes" = all(x))

x <-
  pccc_codes[pccc_codes$icdv == 10 & pccc_codes$dx == 1, "full_code"] |>
  is_icd(icdv = 10, dx = 1L, headerok = TRUE, ever.assignable = TRUE, warn.ambiguous = FALSE)
stopifnot("all icdv 10 dx full codes are valid ever.assignable icd codes" = all(x))

x <-
  pccc_codes[pccc_codes$icdv == 10 & pccc_codes$dx == 0L, "full_code"] |>
  is_icd(icdv = 10, dx = 0L, headerok = TRUE, ever.assignable = TRUE)
stopifnot("all icdv 10 pr full codes are valid ever.assignable icd codes" = all(x))

################################################################################
# verify no more than two rows for a code by pccc variant
variants <- grep("^pccc_", names(pccc_codes), value = TRUE)
codes <-
  aggregate(
    pccc_codes[variants],
    by = pccc_codes[c("icdv", "dx", "code")],
    FUN = sum
  )
stopifnot(
  max(unlist(codes[variants])) == 2
)

################################################################################
# check that the row names are just sequential integers
pc <- get_pccc_codes()
stopifnot(identical(rownames(pc), as.character(seq_len(nrow(pc)))))

################################################################################
#                                 End of File                                  #
################################################################################
