# No need to load and attach the namespace, everything in this test script is
# non-exported
# library(medicalcoder)
source('utilities.R')

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
# set colummns - change the order of the columns
DF  <- getFromNamespace(x = "mdcr_select", ns = "medicalcoder")(DF,  col = c("D", "B", "C", "A"))
TBL <- getFromNamespace(x = "mdcr_select", ns = "medicalcoder")(TBL, col = c("D", "B", "C", "A"))
DT  <- getFromNamespace(x = "mdcr_select", ns = "medicalcoder")(DT,  col = c("D", "B", "C", "A"))

stopifnot(
  identical(names(DF),  c("D", "B", "C", "A")),
  identical(names(TBL), c("D", "B", "C", "A")),
  identical(names(DT),  c("D", "B", "C", "A"))
)

# retun the object if col is missing
stopifnot(
  identical(getFromNamespace(x = "mdcr_select", ns = "medicalcoder")(DF), DF),
  identical(getFromNamespace(x = "mdcr_select", ns = "medicalcoder")(TBL), TBL),
  identical(getFromNamespace(x = "mdcr_select", ns = "medicalcoder")(DT), DT)
)

################################################################################
# testing mdcr_subset

# if arg i and cols are missing then the object is retruned
stopifnot(
  identical(getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(DF), DF),
  identical(getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(TBL), TBL),
  identical(getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(DT), DT)
)

# with no row specfied, it is the same as calling mdcr_select
stopifnot(
  identical(
    getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(DF,  col = c("D", "B", "C", "A")),
    getFromNamespace(x = "mdcr_select", ns = "medicalcoder")(DF,  col = c("D", "B", "C", "A"))
  ),
  identical(
    getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(TBL, col = c("D", "B", "C", "A")),
    getFromNamespace(x = "mdcr_select", ns = "medicalcoder")(TBL, col = c("D", "B", "C", "A"))
  ),
  identical(
    getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(DT,  col = c("D", "B", "C", "A")),
    getFromNamespace(x = "mdcr_select", ns = "medicalcoder")(DT,  col = c("D", "B", "C", "A"))
  )
)

# select one column and a subset of rows
DF0 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(DF, i = seq(1, 10, by = 2), cols = c("B"))
DF1 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(DF, i = seq(2, 10, by = 2), cols = c("B"))
TBL0 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(TBL, i = seq(1, 10, by = 2), cols = c("B"))
TBL1 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(TBL, i = seq(2, 10, by = 2), cols = c("B"))
DT0 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(DT, i = seq(1, 10, by = 2), cols = c("B"))
DT1 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(DT, i = seq(2, 10, by = 2), cols = c("B"))

stopifnot(
  inherits(DF0, "data.frame"),
  inherits(DF1, "data.frame"),
  inherits(TBL0, "data.frame"),
  inherits(TBL1, "data.frame"),
  inherits(DT0, "data.frame"),
  inherits(DT1, "data.frame"),
  identical(names(DF0), "B"),
  identical(names(DF1), "B"),
  identical(names(TBL0), "B"),
  identical(names(TBL1), "B"),
  identical(names(DT0), "B"),
  identical(names(DT1), "B")
)

if (requireNamespace("data.table", quietly = TRUE)) {
  stopifnot(inherits(DT0, "data.table"), inherits(DT1, "data.table"))
}

if (requireNamespace("tibble", quietly = TRUE)) {
  stopifnot(inherits(TBL0, "tbl_df"), inherits(TBL1, "tbl_df"))
}

# select two columns
DF0 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(DF, i = seq(1, 10, by = 2), cols = c("B", "A"))
DF1 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(DF, i = seq(2, 10, by = 2), cols = c("B", "A"))
TBL0 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(TBL, i = seq(1, 10, by = 2), cols = c("B", "A"))
TBL1 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(TBL, i = seq(2, 10, by = 2), cols = c("B", "A"))
DT0 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(DT, i = seq(1, 10, by = 2), cols = c("B", "A"))
DT1 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(DT, i = seq(2, 10, by = 2), cols = c("B", "A"))

stopifnot(
  inherits(DF0, "data.frame"),
  inherits(DF1, "data.frame"),
  inherits(TBL0, "data.frame"),
  inherits(TBL1, "data.frame"),
  inherits(DT0, "data.frame"),
  inherits(DT1, "data.frame"),
  identical(names(DF0), c("B", "A")),
  identical(names(DF1), c("B", "A")),
  identical(names(TBL0), c("B", "A")),
  identical(names(TBL1), c("B", "A")),
  identical(names(DT0), c("B", "A")),
  identical(names(DT1), c("B", "A"))
)

if (requireNamespace("data.table", quietly = TRUE)) {
  stopifnot(inherits(DT0, "data.table"), inherits(DT1, "data.table"))
}

if (requireNamespace("tibble", quietly = TRUE)) {
  stopifnot(inherits(TBL0, "tbl_df"), inherits(TBL1, "tbl_df"))
}

# if only i is supplied, all the columns are returned
DF0 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(DF, i = seq(1, 10, by = 2))
DF1 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(DF, i = seq(2, 10, by = 2))
TBL0 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(TBL, i = seq(1, 10, by = 2))
TBL1 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(TBL, i = seq(2, 10, by = 2))
DT0 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(DT, i = seq(1, 10, by = 2))
DT1 <- getFromNamespace(x = "mdcr_subset", ns = "medicalcoder")(DT, i = seq(2, 10, by = 2))

stopifnot(
  inherits(DF0, "data.frame"),
  inherits(DF1, "data.frame"),
  inherits(TBL0, "data.frame"),
  inherits(TBL1, "data.frame"),
  inherits(DT0, "data.frame"),
  inherits(DT1, "data.frame"),
  identical(names(DF0), c("D", "B", "C", "A")),
  identical(names(DF1), c("D", "B", "C", "A")),
  identical(names(TBL0), c("D", "B", "C", "A")),
  identical(names(TBL1), c("D", "B", "C", "A")),
  identical(names(DT0), c("D", "B", "C", "A")),
  identical(names(DT1), c("D", "B", "C", "A"))
)

if (requireNamespace("data.table", quietly = TRUE)) {
  stopifnot(inherits(DT0, "data.table"), inherits(DT1, "data.table"))
}

if (requireNamespace("tibble", quietly = TRUE)) {
  stopifnot(inherits(TBL0, "tbl_df"), inherits(TBL1, "tbl_df"))
}


################################################################################
# testing mdcr_setorder
DF <- rbind(DF0, DF1)
TBL <- rbind(TBL0, TBL1)
DT <- rbind(DT0, DT1)

# verify that the data.frames are not currently ordered by "A"

stopifnot(
  identical(DF[["A"]],  as.integer(c(11, 13, 15, 17, 19, 12, 14, 16, 18, 20))),
  identical(TBL[["A"]], as.integer(c(11, 13, 15, 17, 19, 12, 14, 16, 18, 20))),
  identical(DT[["A"]],  as.integer(c(11, 13, 15, 17, 19, 12, 14, 16, 18, 20))),
  identical(DF[["D"]],  paste("v", c(0, 2, 4, 5, 7, 1, 3, 5, 6, 8))),
  identical(TBL[["D"]], paste("v", c(0, 2, 4, 5, 7, 1, 3, 5, 6, 8))),
  identical(DT[["D"]],  paste("v", c(0, 2, 4, 5, 7, 1, 3, 5, 6, 8)))
)

DF <-  getFromNamespace(x = "mdcr_setorder", ns = "medicalcoder")(DF, by = c("A"))
TBL <- getFromNamespace(x = "mdcr_setorder", ns = "medicalcoder")(TBL, by = c("A"))
DT <-  getFromNamespace(x = "mdcr_setorder", ns = "medicalcoder")(DT, by = c("A"))

stopifnot(
  identical(DF[["A"]],  as.integer(11:20)),
  identical(TBL[["A"]], as.integer(11:20)),
  identical(DT[["A"]],  as.integer(11:20)),
  identical(DF[["D"]],  paste("v", c(0:5, 5, 6:8))),
  identical(TBL[["D"]], paste("v", c(0:5, 5, 6:8))),
  identical(DT[["D"]],  paste("v", c(0:5, 5, 6:8)))
)

################################################################################
# testing mdcr_setnames
DF  <- getFromNamespace(x = "mdcr_setnames", ns = "medicalcoder")(DF,  old = "A", new = "Column A")
TBL <- getFromNamespace(x = "mdcr_setnames", ns = "medicalcoder")(TBL, old = "A", new = "Column A")
DT  <- getFromNamespace(x = "mdcr_setnames", ns = "medicalcoder")(DT,  old = "A", new = "Column A")

stopifnot(
  identical(names(DF),  c("D", "B", "C", "Column A")),
  identical(names(TBL), c("D", "B", "C", "Column A")),
  identical(names(DT),  c("D", "B", "C", "Column A"))
)

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
  identical(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(DF, by = "D"), expected),
  identical(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(TBL, by = "D"), expected),
  identical(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(DT, by = "D"), expected)
)

# check fromLast
expected[6:7] <- !expected[6:7]
stopifnot(
  identical(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(DF, by = "D", fromLast = TRUE), expected),
  identical(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(TBL, by = "D", fromLast = TRUE), expected),
  identical(getFromNamespace(x = "mdcr_duplicated", ns = "medicalcoder")(DT, by = "D", fromLast = TRUE), expected)
)


################################################################################
#                                 End of File                                  #
################################################################################
