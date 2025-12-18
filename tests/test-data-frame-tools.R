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
    "mdcr_duplicated",
    "mdcr_unique",
    "mdcr_inner_join",
    "mdcr_full_outer_join",
    "mdcr_left_join",
    "mdcr_cbind"
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
DF <- data.frame(A = 1:10, C = NA_integer_, B = LETTERS[1:10], stringsAsFactors = FALSE)
if (requireNamespace("dplyr", quietly = TRUE)) {
  TBL <- getExportedValue(name = "as_tibble", ns = "dplyr")(DF)
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

# create a new column and only add a value to rows 2, 5, and 7
x <- c(NA_character_, "first", NA_character_, NA_character_, "second", NA_character_, "third", rep(NA_character_, nrow(DF) - 7L))
DF  <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(DF,  i = c(2L, 5L, 7L), j = "newC", value = c("first", "second", "third"))
TBL <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(TBL, i = c(2L, 5L, 7L), j = "newC", value = c("first", "second", "third"))
DT  <- getFromNamespace(x = "mdcr_set", ns = "medicalcoder")(DT,  i = c(2L, 5L, 7L), j = "newC", value = c("first", "second", "third"))

stopifnot(
  identical(DF[["newC"]],  x),
  identical(TBL[["newC"]], x),
  identical(DT[["newC"]],  x)
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

# check for one column
DFD  <- getFromNamespace(x = "mdcr_select", ns = "medicalcoder")(DF,  col = c("D"))
TBLD <- getFromNamespace(x = "mdcr_select", ns = "medicalcoder")(TBL, col = c("D"))
DTD  <- getFromNamespace(x = "mdcr_select", ns = "medicalcoder")(DT,  col = c("D"))

stopifnot(
  identical(names(DFD),  c("D")),
  identical(names(TBLD), c("D")),
  identical(names(DTD),  c("D")),
  identical(DFD[["D"]], paste("v", c(0:5, 5:8))),
  identical(TBLD[["D"]], paste("v", c(0:5, 5:8))),
  identical(DTD[["D"]], paste("v", c(0:5, 5:8))),
  identical(class(DFD), class(DF)),
  identical(class(TBLD), class(TBL)),
  identical(class(DTD), class(DT))
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

if (requireNamespace("dplyr", quietly = TRUE)) {
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

if (requireNamespace("dplyr", quietly = TRUE)) {
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

if (requireNamespace("dplyr", quietly = TRUE)) {
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
# testing mdcr_inner_join
#
# without specifying the by
t0 <- getFromNamespace(x = "mdcr_inner_join", ns = "medicalcoder")(DF, DF[2, ])
t1 <- getFromNamespace(x = "mdcr_inner_join", ns = "medicalcoder")(DT, DT[2, ])
t2 <- getFromNamespace(x = "mdcr_inner_join", ns = "medicalcoder")(TBL, TBL[2, ])

stopifnot(
  isTRUE( all.equal(t0, DF[2, ], check.attributes = FALSE)),
  isTRUE( all.equal(t1, DT[2, ], check.attributes = FALSE)),
  isTRUE( all.equal(t2, TBL[2, ], check.attributes = FALSE))
)

t3 <- getFromNamespace(x = "mdcr_inner_join", ns = "medicalcoder")(DF, DF[c(2, 5, 1), ])
t4 <- getFromNamespace(x = "mdcr_inner_join", ns = "medicalcoder")(DT, DT[c(2, 5, 1), ])
t5 <- getFromNamespace(x = "mdcr_inner_join", ns = "medicalcoder")(TBL, TBL[c(2, 5, 1), ])

stopifnot(
  isTRUE( all.equal( t3, DF[c(1, 2, 5), ], check.attributes = FALSE)),
  isTRUE( all.equal( t4, DT[c(1, 2, 5), ], check.attributes = FALSE)),
  isTRUE( all.equal( t5, TBL[c(1, 2, 5), ], check.attributes = FALSE))
  )

# test with a by statement and suffixes statement
expected_df <-
  data.frame(
    x1 = c(1L, 2L, 8L),
    x2.right = c("A", "B", "C"),
    x2.left  = c("a", "b", "c"),
    stringsAsFactors = FALSE
  )
r <- data.frame(
  x1 = as.integer(1:10),
  x2 = c("A", "B", "D", "E", "F", "T", "A", "C", "9", "ten"),
  stringsAsFactors = FALSE
)
l <- data.frame(
  x1 = as.integer(c(1, 2, 33, 44, 55, 66, 77, 8, 99, 1100)),
  x2 = c("a", "b", "d", "e", "f", "t", "a", "c", "9", "TEN"),
  stringsAsFactors = FALSE
)
outDF <- getFromNamespace(x = "mdcr_inner_join", ns = "medicalcoder")(r, l, by = "x1", suffixes = c(".right", ".left"))
stopifnot(identical(outDF, expected_df))

if (requireNamespace("data.table", quietly = TRUE)) {
  data.table::setDT(r)
  data.table::setDT(l)
  expected_dt <- data.table::copy(expected_df)
  data.table::setDT(expected_dt)
} else {
  r <- as.data.frame(r, stringsAsFactors = FALSE)
  l <- as.data.frame(l, stringsAsFactors = FALSE)
  expected_dt <- expected_df
}
outDT <- getFromNamespace(x = "mdcr_inner_join", ns = "medicalcoder")(r, l, by = "x1", suffixes = c(".right", ".left"))
stopifnot(identical(outDT, expected_dt))

if (requireNamespace("dplyr", quietly = TRUE)) {
  r <- dplyr::as_tibble(r)
  l <- dplyr::as_tibble(l)
  expected_tb <- dplyr::as_tibble(expected_df)
} else {
  r <- as.data.frame(r, stringsAsFactors = FALSE)
  l <- as.data.frame(l, stringsAsFactors = FALSE)
  expected_tb <- expected_df
}
outTBL <- getFromNamespace(x = "mdcr_inner_join", ns = "medicalcoder")(r, l, by = "x1", suffixes = c(".right", ".left"))
stopifnot(identical(outTBL, expected_tb))

# test with by.x and by.y statements
r <- data.frame(
  x1 = as.integer(1:10),
  x2 = c("A", "B", "D", "E", "F", "T", "A", "C", "9", "ten"),
  stringsAsFactors = FALSE
)
l <- data.frame(
  z = as.integer(c(1, 2, 33, 44, 55, 66, 77, 8, 99, 1100)),
  x2 = c("a", "b", "d", "e", "f", "t", "a", "c", "9", "TEN"),
  stringsAsFactors = FALSE
)
outDF <- getFromNamespace(x = "mdcr_inner_join", ns = "medicalcoder")(r, l, by.x = "x1", by.y = "z", suffixes = c(".right", ".left"))
stopifnot(identical(outDF, expected_df))

if (requireNamespace("data.table", quietly = TRUE)) {
  data.table::setDT(r)
  data.table::setDT(l)
  expected_dt <- data.table::copy(expected_df)
  data.table::setDT(expected_dt)
} else {
  r <- as.data.frame(r, stringsAsFactors = FALSE)
  l <- as.data.frame(l, stringsAsFactors = FALSE)
  expected_dt <- expected_df
}
outDT <- getFromNamespace(x = "mdcr_inner_join", ns = "medicalcoder")(r, l, by.x = "x1", by.y = "z", suffixes = c(".right", ".left"))
stopifnot(identical(outDT, expected_dt))

if (requireNamespace("dplyr", quietly = TRUE)) {
  r <- dplyr::as_tibble(r)
  l <- dplyr::as_tibble(l)
  expected_tb <- dplyr::as_tibble(expected_df)
} else {
  r <- as.data.frame(r, stringsAsFactors = FALSE)
  l <- as.data.frame(l, stringsAsFactors = FALSE)
  expected_tb <- expected_df
}
outTBL <- getFromNamespace(x = "mdcr_inner_join", ns = "medicalcoder")(r, l, by.x = "x1", by.y = "z", suffixes = c(".right", ".left"))
stopifnot(identical(outTBL, expected_tb))

################################################################################
# testing mdcr_left_join

# These wrappers around merge have sort = FALSE and dplyr::left_join doesn't
# sort the return by default.  So, build the merge, sort the result, and then
# test for the outcome.  The first set of tests for a single

t0 <- getFromNamespace(x = "mdcr_left_join", ns = "medicalcoder")(DF, DF[2, ])
t0 <- t0[do.call(order, t0), ]

t1 <- getFromNamespace(x = "mdcr_left_join", ns = "medicalcoder")(DF, DF[c(2, 5, 2), ])
t1 <- t1[do.call(order, t1), ]

t2 <- getFromNamespace(x = "mdcr_left_join", ns = "medicalcoder")(DT, DT[2, ])
t2 <- t2[do.call(order, t2), ]

t3 <- getFromNamespace(x = "mdcr_left_join", ns = "medicalcoder")(DT, DT[c(2, 5, 2), ])
t3 <- t3[do.call(order, t3), ]

t4 <- getFromNamespace(x = "mdcr_left_join", ns = "medicalcoder")(TBL, TBL[2, ])
t4 <- t4[do.call(order, t4), ]

t5 <- getFromNamespace(x = "mdcr_left_join", ns = "medicalcoder")(TBL, TBL[c(2, 5, 2), ])
t5 <- t5[do.call(order, t5), ]

# without specifying the by
stopifnot(
  isTRUE( all.equal( t0, DF, check.attributes = FALSE)),
  isTRUE( all.equal( t1, DF[c(1, 2, 2, 3:nrow(DF)), ], check.attributes = FALSE)),
  isTRUE( all.equal( t2, DT, check.attributes = FALSE)),
  isTRUE( all.equal( t3, DT[c(1, 2, 2, 3:nrow(DF)), ], check.attributes = FALSE)),
  isTRUE( all.equal( t4, TBL, check.attributes = FALSE)),
  isTRUE( all.equal( t5, TBL[c(1, 2, 2, 3:nrow(DF)), ], check.attributes = FALSE))
)

# tests with by statements and suffixes
expected_df <-
  data.frame(
    x1 = as.integer(1:10),
    x2.right = c("A", "B", "D", "E", "F", "T", "A", "C", "9", "ten"),
    x2.left  = c("a", "b", rep(NA_character_, 5), "c", rep(NA_character_, 2)),
    stringsAsFactors = FALSE
  )
r <- data.frame(
  x1 = as.integer(1:10),
  x2 = c("A", "B", "D", "E", "F", "T", "A", "C", "9", "ten"),
  stringsAsFactors = FALSE
)
l <- data.frame(
  x1 = as.integer(c(1, 2, 33, 44, 55, 66, 77, 8, 99, 1100)),
  x2 = c("a", "b", "d", "e", "f", "t", "a", "c", "9", "TEN"),
  stringsAsFactors = FALSE
)
outDF <- getFromNamespace(x = "mdcr_left_join", ns = "medicalcoder")(r, l, by = "x1", suffixes = c(".right", ".left"))
outDF <- outDF[order(outDF$x1), ]
rownames(outDF) <- NULL
stopifnot(identical(outDF, expected_df))

if (requireNamespace("data.table", quietly = TRUE)) {
  data.table::setDT(r)
  data.table::setDT(l)
  expected_dt <- data.table::copy(expected_df)
  data.table::setDT(expected_dt)
} else {
  r <- as.data.frame(r, stringsAsFactors = FALSE)
  l <- as.data.frame(l, stringsAsFactors = FALSE)
  expected_dt <- expected_df
}
outDT <- getFromNamespace(x = "mdcr_left_join", ns = "medicalcoder")(r, l, by = "x1", suffixes = c(".right", ".left"))
outDT <- outDT[order(outDT$x1), ]
rownames(outDT) <- NULL
stopifnot(identical(outDT, expected_dt))

if (requireNamespace("dplyr", quietly = TRUE)) {
  r <- dplyr::as_tibble(r)
  l <- dplyr::as_tibble(l)
  expected_tb <- dplyr::as_tibble(expected_df)
} else {
  r <- as.data.frame(r, stringsAsFactors = FALSE)
  l <- as.data.frame(l, stringsAsFactors = FALSE)
  expected_tb <- expected_df
}
outTBL <- getFromNamespace(x = "mdcr_left_join", ns = "medicalcoder")(r, l, by = "x1", suffixes = c(".right", ".left"))
outTBL <- outTBL[order(outTBL$x1), ]
rownames(outTBL) <- NULL
stopifnot(identical(outTBL, expected_tb))

# tests with by.x and by.x statements and suffixes
expected_df <-
  data.frame(
    x1 = as.integer(1:10),
    x2.right = c("A", "B", "D", "E", "F", "T", "A", "C", "9", "ten"),
    x2.left  = c("a", "b", rep(NA_character_, 5), "c", rep(NA_character_, 2)),
    stringsAsFactors = FALSE
  )
r <- data.frame(
  x1 = as.integer(1:10),
  x2 = c("A", "B", "D", "E", "F", "T", "A", "C", "9", "ten"),
  stringsAsFactors = FALSE
)
l <- data.frame(
  l1 = as.integer(c(1, 2, 33, 44, 55, 66, 77, 8, 99, 1100)),
  x2 = c("a", "b", "d", "e", "f", "t", "a", "c", "9", "TEN"),
  stringsAsFactors = FALSE
)
outDF <- getFromNamespace(x = "mdcr_left_join", ns = "medicalcoder")(r, l, by.x = "x1", by.y = "l1", suffixes = c(".right", ".left"))
outDF <- outDF[order(outDF$x1), ]
rownames(outDF) <- NULL
stopifnot(identical(outDF, expected_df))

if (requireNamespace("data.table", quietly = TRUE)) {
  data.table::setDT(r)
  data.table::setDT(l)
  expected_dt <- data.table::copy(expected_df)
  data.table::setDT(expected_dt)
} else {
  r <- as.data.frame(r, stringsAsFactors = FALSE)
  l <- as.data.frame(l, stringsAsFactors = FALSE)
  expected_dt <- expected_df
}
outDT <- getFromNamespace(x = "mdcr_left_join", ns = "medicalcoder")(r, l, by.x = "x1", by.y = "l1", suffixes = c(".right", ".left"))
outDT <- outDT[order(outDT$x1), ]
rownames(outDT) <- NULL
stopifnot(identical(outDT, expected_dt))

if (requireNamespace("dplyr", quietly = TRUE)) {
  r <- dplyr::as_tibble(r)
  l <- dplyr::as_tibble(l)
  expected_tb <- dplyr::as_tibble(expected_df)
} else {
  r <- as.data.frame(r, stringsAsFactors = FALSE)
  l <- as.data.frame(l, stringsAsFactors = FALSE)
  expected_tb <- expected_df
}
outTBL <- getFromNamespace(x = "mdcr_left_join", ns = "medicalcoder")(r, l, by.x = "x1", by.y = "l1", suffixes = c(".right", ".left"))
outTBL <- outTBL[order(outTBL$x1), ]
rownames(outTBL) <- NULL
stopifnot(identical(outTBL, expected_tb))

################################################################################
# testing mdcr_full_outer_join

expected_df <-
  data.frame(
    x1 = c(1L, 1L, 1L, 2L, 2L, 3L, 4L, 5L, 6L, 7L, 8L, 8L, 9L, 10L, 33L, 44L, 55L, 66L, 77L, 99L, 1100L),
    x2 = c("A", "a", "a1", "B", "b", "D", "E", "F", "T", "A", "C", "c", "9", "ten", "d", "e", "f", "t", "a", "9", "TEN"),
    stringsAsFactors = FALSE
  )
r <- data.frame(
  x1 = as.integer(1:10),
  x2 = c("A", "B", "D", "E", "F", "T", "A", "C", "9", "ten"),
  stringsAsFactors = FALSE
)
l <- data.frame(
  x1 = as.integer(c(1, 1, 2, 33, 44, 55, 66, 77, 8, 99, 1100)),
  x2 = c("a", "a1", "b", "d", "e", "f", "t", "a", "c", "9", "TEN"),
  stringsAsFactors = FALSE
)
outDF <- getFromNamespace(x = "mdcr_full_outer_join", ns = "medicalcoder")(r, l)
outDF <- outDF[order(outDF$x1), ]
rownames(outDF) <- NULL
stopifnot(identical(outDF, expected_df))

if (requireNamespace("data.table", quietly = TRUE)) {
  data.table::setDT(r)
  data.table::setDT(l)
  expected_dt <- data.table::copy(expected_df)
  data.table::setDT(expected_dt)
} else {
  r <- as.data.frame(r, stringsAsFactors = FALSE)
  l <- as.data.frame(l, stringsAsFactors = FALSE)
  expected_dt <- expected_df
}
outDT <- getFromNamespace(x = "mdcr_full_outer_join", ns = "medicalcoder")(r, l)
outDT <- outDT[order(outDT$x1), ]
rownames(outDT) <- NULL
stopifnot(identical(outDT, expected_dt))

if (requireNamespace("dplyr", quietly = TRUE)) {
  r <- dplyr::as_tibble(r)
  l <- dplyr::as_tibble(l)
  expected_tb <- dplyr::as_tibble(expected_df)
} else {
  r <- as.data.frame(r, stringsAsFactors = FALSE)
  l <- as.data.frame(l, stringsAsFactors = FALSE)
  expected_tb <- expected_df
}
outTBL <- getFromNamespace(x = "mdcr_full_outer_join", ns = "medicalcoder")(r, l)
outTBL <- outTBL[order(outTBL$x1), ]
rownames(outTBL) <- NULL
stopifnot(identical(outTBL, expected_tb))

# tests with by statements and suffixes
expected_df <-
  data.frame(
    x1 = as.integer(c(1, 1:10, 33, 44, 55, 66, 77, 99, 1100)),
    x2.right = c("A", "A", "B", "D", "E", "F", "T", "A", "C", "9", "ten", rep(NA_character_, 7)),
    x2.left  = c("a", "a1", "b", rep(NA_character_, 5), "c", rep(NA_character_, 2), "d", "e", "f", "t", "a", "9", "TEN"),
    stringsAsFactors = FALSE
  )
r <- data.frame(
  x1 = as.integer(1:10),
  x2 = c("A", "B", "D", "E", "F", "T", "A", "C", "9", "ten"),
  stringsAsFactors = FALSE
)
l <- data.frame(
  x1 = as.integer(c(1, 1, 2, 33, 44, 55, 66, 77, 8, 99, 1100)),
  x2 = c("a", "a1", "b", "d", "e", "f", "t", "a", "c", "9", "TEN"),
  stringsAsFactors = FALSE
)
outDF <- getFromNamespace(x = "mdcr_full_outer_join", ns = "medicalcoder")(r, l, by = "x1", suffixes = c(".right", ".left"))
outDF <- outDF[order(outDF$x1), ]
rownames(outDF) <- NULL
stopifnot(identical(outDF, expected_df))

if (requireNamespace("data.table", quietly = TRUE)) {
  data.table::setDT(r)
  data.table::setDT(l)
  expected_dt <- data.table::copy(expected_df)
  data.table::setDT(expected_dt)
} else {
  r <- as.data.frame(r, stringsAsFactors = FALSE)
  l <- as.data.frame(l, stringsAsFactors = FALSE)
  expected_dt <- expected_df
}
outDT <- getFromNamespace(x = "mdcr_full_outer_join", ns = "medicalcoder")(r, l, by = "x1", suffixes = c(".right", ".left"))
outDT <- outDT[order(outDT$x1), ]
rownames(outDT) <- NULL
stopifnot(identical(outDT, expected_dt))

if (requireNamespace("dplyr", quietly = TRUE)) {
  r <- dplyr::as_tibble(r)
  l <- dplyr::as_tibble(l)
  expected_tb <- dplyr::as_tibble(expected_df)
} else {
  r <- as.data.frame(r, stringsAsFactors = FALSE)
  l <- as.data.frame(l, stringsAsFactors = FALSE)
  expected_tb <- expected_df
}
outTBL <- getFromNamespace(x = "mdcr_full_outer_join", ns = "medicalcoder")(r, l, by = "x1", suffixes = c(".right", ".left"))
outTBL <- outTBL[order(outTBL$x1), ]
rownames(outTBL) <- NULL
stopifnot(identical(outTBL, expected_tb))

################################################################################
# testing mdcr_unique
DF <- expand.grid(x1 = LETTERS, x2 = LETTERS)
DF <- rbind(DF, DF, DF, DF, DF, DF)
DF <- DF[sample(seq_len(nrow(DF))), ]
rownames(DF) <- NULL
if (requireNamespace("dplyr", quietly = TRUE)) {
  TBL <- getExportedValue(ns = "dplyr", name = "as_tibble")(DF)
} else {
  TBL <- DF
  class(TBL) <- c("tbl_df", class(TBL))
}
if (requireNamespace("data.table", quietly = TRUE)) {
  DT <- getExportedValue(name = "copy", ns = "data.table")(DF)
  getExportedValue(name = "setDT", ns = "data.table")(DT)
} else {
  DT <- DF
  class(DT) <- c("data.table", class(DT))
}

uDF <- unique(DF)

stopifnot(
  all.equal(uDF, getFromNamespace(x = "mdcr_unique", ns = "medicalcoder")(DF), check.attributes = FALSE),
  all.equal(uDF, getFromNamespace(x = "mdcr_unique", ns = "medicalcoder")(DT), check.attributes = FALSE),
  all.equal(uDF, getFromNamespace(x = "mdcr_unique", ns = "medicalcoder")(TBL), check.attributes = FALSE)
)


################################################################################
# testing mdcr_cbind

################################################################################
#                                 End of File                                  #
################################################################################
