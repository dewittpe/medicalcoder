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

################################################################################
#                                 End of File                                  #
################################################################################
