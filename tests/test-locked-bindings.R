library(data.table)

# it is possible for a end user to modify the internal objects, this is a R
# problem. For example, if you use data.table::setDT on datasets::mtcars you can
# modify the object. The following example worked as of 29 Aug 2025 in R 4.5.1
# and datasets_4.5.1.
#
#> setDT(datasets::mtcars)
#> set(datasets::mtcars, j = "cyl", value = 1L)
#> stopifnot(all(mtcars[["cyl"]] == 1L))
#> stopifnot(all(datasets::mtcars[["cyl"]] == 1L))

# medicalcoder tries to prevent this for it's lookup tables.  Importally, the
# builds several user friendly data sets in .onLoad.  If a end user tries to
# modify the non-exported internal objects, only accessable via ::: then the
# namespace is loaded _before_ anything else can be done and the data sets used
# within the package should be preserved.
setDT(medicalcoder:::..mdcr_internal_icd_codes..)
x <- medicalcoder:::..mdcr_internal_icd_codes..
x[, icdv := 8L]
stopifnot(medicalcoder:::..mdcr_internal_icd_codes..[, all(icdv == 8L)])  # bad, but...
x <- medicalcoder::get_icd_codes()
stopifnot(x[["icdv"]] %in% c(9L, 10L))

# now, what about getting at the built objects?
# first, the ..mdcr_data_env.. is not accessable other than by :::
library(medicalcoder)
stopifnot(medicalcoder:::..mdcr_internal_icd_codes..[, all(icdv == 8L)])  # still bad, but...

# the environment is hard to get to
x <- tryCatch(..mdcr_data_env.., error = function(e) e)
stopifnot(inherits(x, "error"))
x <- tryCatch(medicalcoder::..mdcr_data_env.., error = function(e) e)
stopifnot(inherits(x, "error"))

x <- medicalcoder:::..mdcr_data_env..
stopifnot(is.environment(x))
# and modifing the data will error
t <- tryCatch(x$icd_codes[["icdv"]] <- 11L, error = function(e) e)
stopifnot(inherits(t, "error"))

# data.table will also fail, at first.  Note that accessing the icd_codes right
# now it is just a data.frame
stopifnot(
   is.data.frame(medicalcoder:::..mdcr_data_env..$icd_codes),
  !is.data.table(medicalcoder:::..mdcr_data_env..$icd_codes)
)

# an error is thrown, but the class has been modified and it is now a data.table
t <- tryCatch(setDT(x$icd_codes), error = function(e) e)
stopifnot(inherits(t, "error"))
stopifnot(
   is.data.frame(medicalcoder:::..mdcr_data_env..$icd_codes),
   is.data.table(medicalcoder:::..mdcr_data_env..$icd_codes)
)

# so now, end user could modify the object and the return from get_icd_codes()
# will reflect this change
stopifnot(all(get_icd_codes()[["icdv"]] %in% c(9L, 10L)))
medicalcoder:::..mdcr_data_env..$icd_codes[, icdv := 98L]
stopifnot(all(get_icd_codes()[["icdv"]] == 98L))

# so, yeah, end users could mess things up but if someone does this that is on
# them.  Importantly, the get_x functions use
#   unserialize(serialize(x, connection = NULL))
# to ensure end users only get deep copies of the internal data sets.  One quick
# check.
detach("package:medicalcoder", unload = TRUE)
library(medicalcoder)
x <- get_icd_codes()
setDT(x)
y <- data.table::copy(x)
x[, icdv := 42L]
z <- get_icd_codes()

stopifnot(
  all(y[["icdv"]] %in% c(9L, 10L)),
  all(z[["icdv"]] %in% c(9L, 10L)),
  all(x[["icdv"]] == 42L)
)

