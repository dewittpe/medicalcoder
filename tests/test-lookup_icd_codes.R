source('utilities.R')
library(medicalcoder)

# lookup exact vs regex consistency
lx <- lookup_icd_codes(c("E11.9","I50.9"), regex = FALSE)
lr <- lookup_icd_codes(c("^E11\\.9$","^I50\\.9$"), regex = TRUE)
stopifnot(all(lx$full_code %in% lr$full_code),
          all(lr$full_code %in% lx$full_code))

# the following used to give an error:
#   Error in merge.data.frame(x = input, y = matches, all.x = TRUE, by = c(ifelse(regex,  :
#     negative length vectors are not allowed
m <- tryCatchError(lookup_icd_codes(x = "", regex = TRUE))
stopifnot(inherits(m, "error"))

# out of the data.frame should be the same columns with or without matches
m1 <- lookup_icd_codes(x = "", regex = FALSE)
m2 <- lookup_icd_codes(x = "^$", regex = TRUE)
m3 <- lookup_icd_codes(x = "C84", regex = FALSE)
m4 <- lookup_icd_codes(x = "^C84$", regex = TRUE)

expected_regex_false_names <-
  c("input_code",  "match_type", "icdv", "dx", "full_code", "code", "src", "known_start", "known_end", "assignable_start", "assignable_end")
expected_regex_true_names <-
  c("input_regex", "match_type", "icdv", "dx", "full_code", "code", "src", "known_start", "known_end", "assignable_start", "assignable_end")

stopifnot(
  identical(names(m1), expected_regex_false_names),
  identical(names(m2), expected_regex_true_names),
  identical(names(m3), expected_regex_false_names),
  identical(names(m4), expected_regex_true_names)
)

################################################################################
#                                 End of File                                  #
################################################################################
