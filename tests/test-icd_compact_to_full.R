source('utilities.R')
library(medicalcoder)

stopifnot(identical(
  icd_compact_to_full(c("E9120","2500","I214"), icdv = c(9,9,10), dx = c(1,1,1)),
  c("E912.0","250.0","I21.4")
))

# already-full codes remain unchanged
stopifnot(identical(
  icd_compact_to_full(c("E912.0","250.0","I21.4"), icdv = c(9,9,10), dx = 1),
  c("E912.0","250.0","I21.4")
))

# ICD-9 procedure codes gain a decimal after the second character; scalars for
# icdv/dx are recycled across the input vector.
stopifnot(identical(
  icd_compact_to_full(c("0309","1712"), icdv = 9, dx = 0),
  c("03.09","17.12")
))

################################################################################
#                                 End of File                                  #
################################################################################
