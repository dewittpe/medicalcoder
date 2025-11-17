library(medicalcoder)
source('utilities.R')

# testing the non-exported data frame tools

dataframetools <-
  c("mdcr_set",
    "mdcr_select",
    "mdcr_subset",
    "mdcr_setorder",
    "mdcr_setnames",
    "mdcr_duplicated"
  )

mdcr <- getNamespace("medicalcoder")

# are all the dataframetools in the namespcae
stopifnot(all(dataframetools %in% names(mdcr)))

# check that there are not unaccounted for data sets.  the ..mdcr_internal_
# prefix and .. suffix is expected.  noted in the data-raw/build_sysdata.R
stopifnot(
  all(
    grep("^mdcr_", names(mdcr), value = TRUE) %in% dataframetools
  )
)

################################################################################
# Set up data for testing
DF <- data.frame(A = 1:10, C = NA_integer_, B = LETTERS[1:10])
if (requireNamespace("tibble", quietly = TRUE)) {
  TBL <- getExportedValue(name = "as_tibble", ns = "tibble")(DF)
} else {
  TBL <- DF
}
if (requireNamespace("data.table", quietly = TRUE)) {
  DT <- getExportedValue(name = "copy", ns = "data.table")(DF)
  getExportedValue(name = "setDT", ns = "data.table")(DT)
} else {
  DT <- DF
}

################################################################################
# set the value of column C in row 5
DF  <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(DF,  i = 5L, j = "C", value = 3L)
TBL <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(TBL, i = 5L, j = "C", value = 3L)
DT  <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(DT,  i = 5L, j = "C", value = 3L)

stopifnot(
  identical(DF[["C"]],  c(rep(NA_integer_, 4L), 3L, rep(NA_integer_, 5L))),
  identical(TBL[["C"]], c(rep(NA_integer_, 4L), 3L, rep(NA_integer_, 5L))),
  identical(DT[["C"]],  c(rep(NA_integer_, 4L), 3L, rep(NA_integer_, 5L)))
)

# set the value in two rows at a time with one value
DF  <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(DF,  i = c(1L, 10L), j = "C", value = 8L)
TBL <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(TBL, i = c(1L, 10L), j = "C", value = 8L)
DT  <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(DT,  i = c(1L, 10L), j = "C", value = 8L)

stopifnot(
  identical(DF[["C"]],  c(8L, rep(NA_integer_, 3L), 3L, rep(NA_integer_, 4L), 8L)),
  identical(TBL[["C"]], c(8L, rep(NA_integer_, 3L), 3L, rep(NA_integer_, 4L), 8L)),
  identical(DT[["C"]],  c(8L, rep(NA_integer_, 3L), 3L, rep(NA_integer_, 4L), 8L))
)

# set the value in three rows at a time with three values
DF  <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(DF,  i = c(2L, 3L, 4L), j = "C", value = c(21L, 22L, 23L))
TBL <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(TBL, i = c(2L, 3L, 4L), j = "C", value = c(21L, 22L, 23L))
DT  <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(DT,  i = c(2L, 3L, 4L), j = "C", value = c(21L, 22L, 23L))

stopifnot(
  identical(DF[["C"]],  c(8L, 21L, 22L, 23L, 3L, rep(NA_integer_, 4L), 8L)),
  identical(TBL[["C"]], c(8L, 21L, 22L, 23L, 3L, rep(NA_integer_, 4L), 8L)),
  identical(DT[["C"]],  c(8L, 21L, 22L, 23L, 3L, rep(NA_integer_, 4L), 8L))
)

# set a full column
DF  <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(DF,  j = "A", value = as.integer(11:20))
TBL <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(TBL, j = "A", value = as.integer(11:20))
DT  <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(DT,  j = "A", value = as.integer(11:20))

stopifnot(
  identical(DF[["A"]],  as.integer(11:20)),
  identical(TBL[["A"]], as.integer(11:20)),
  identical(DT[["A"]],  as.integer(11:20))
)

# create a new column
x <- paste("v", c(0:5, 5, 6:8))
DF  <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(DF,  j = "D", value = x)
TBL <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(TBL, j = "D", value = x)
DT  <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(DT,  j = "D", value = x)

stopifnot(
  identical(DF[["D"]],  x),
  identical(TBL[["D"]], x),
  identical(DT[["D"]],  x)
)

################################################################################
# testing mdcr_select

################################################################################
# testing mdcr_subset

################################################################################
# testing mdcr_setorder

################################################################################
# testing mdcr_setnames

################################################################################
# testing mdcr_duplicated

stopifnot(
  !any(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(DF)),
  !any(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(TBL)),
  !any(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(DT))
)

expected <- rep(FALSE, 10)
expected[7] <- TRUE
stopifnot(
  identical(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(DF, by = "D"), expected)
  ,
  identical(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(TBL, by = "D"), expected)
  ,
  identical(
    getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(DT, by = "D")
    #duplicated(DT, by = "D")
    #medicalcoder:::mdcr_duplicated.data.table(DT)
    , expected)
)

x <- DT
base::duplicated(x, by = "D")
getFromNamespace(x = 'duplicated.data.table', ns = "data.table")(x, by = "D")
medicalcoder:::mdcr_duplicated(DT, by = "D")

################################################################################
#                                 End of File                                  #
################################################################################
