source('utilities.R')
library(medicalcoder)

################################################################################
# Prep data I want to test the output without loading or attaching the
# data.table or the dplyr namespaces.  So, the following commented out code is
# run once, and only run when needed to update the data, so that a data.frame,
# data.table, and dplyr are all available.
#
# To keep the disk space use down, use only a subset of the mdcr data set

### c1 <- comorbidities(data = mdcr, id.vars = "patid", icd.codes = "code", icdv.var = "icdv", dx.var = "dx", poa = 1, method = "charlson_quan2005")
### c2 <- comorbidities(data = mdcr, id.vars = "patid", icd.codes = "code", icdv.var = "icdv", dx.var = "dx", poa = 1, primarydx = 0, method = "elixhauser_quan2005")
### c3 <- comorbidities(data = mdcr, id.vars = "patid", icd.codes = "code", icdv.var = "icdv", dx.var = "dx", poa = 1, method = "pccc_v3.1")
###
### set.seed(42)
### foo <- function(n, size = 100) {
###   if (n <= 2) {
###     x <-
###       intersect(
###         intersect(which(c1[["conditions"]]$num_cmrb == n), which(c2[["conditions"]]$num_cmrb == n)),
###         intersect(which(c1[["conditions"]]$num_cmrb == n), which(c3[["conditions"]]$num_cmrb == n))
###       )
###   } else {
###     x <-
###       intersect(
###         intersect(which(c1[["conditions"]]$num_cmrb >= n), which(c2[["conditions"]]$num_cmrb >= n)),
###         intersect(which(c1[["conditions"]]$num_cmrb >= n), which(c3[["conditions"]]$num_cmrb >= n))
###       )
###   }
###   sample(x, size = min(c(size, length(x))))
### }
###
### x <- mdcr[mdcr$patid %in% c1[["conditions"]][c(foo(0), foo(1), foo(2), foo(3), foo(4)), "patid"], ]
###
### saveRDS(x, file = "mdcr_subset_DF.rds", compress = "xz")
### saveRDS(dplyr::as_tibble(x), file = "mdcr_subset_TBL.rds", compress = "xz")
### data.table::setDT(x)
### saveRDS(x, file = "mdcr_subset_DT.rds", compress = "xz")

################################################################################
# load the data from disk
mdcrDT  <- readRDS(file = "mdcr_subset_DT.rds")
mdcrDF  <- readRDS(file = "mdcr_subset_DF.rds")
mdcrTBL <- readRDS(file = "mdcr_subset_TBL.rds")

################################################################################
# apply the comorbidities_methods to the three data sets
common_args <-
  list(id.vars = "patid", icdv.var = "icdv", icd.codes = "code", dx.var = "dx", poa = 1)

DFS  <- new.env()
TBLS <- new.env()
DTS  <- new.env()

methods <- medicalcoder:::comorbidities_methods()

set_results <- function(target_env, method, data, subconditions = FALSE) {
  if (startsWith(method, "pccc")) {
    v <- do.call(comorbidities, c(common_args, list(data = data, method = method, subconditions = subconditions)))
  } else {
    v <- do.call(comorbidities, c(common_args, list(data = data, method = method, subconditions = subconditions, primarydx = 0L)))
  }
  assign(
    x = if (subconditions) paste0(method, "_with_subconditions") else method,
    value = v,
    envir = target_env
  )
}

for (m in methods) {
  set_results(DFS,  method = m, data = mdcrDF,  subconditions = FALSE)
  set_results(DTS,  method = m, data = mdcrDT,  subconditions = FALSE)
  set_results(TBLS, method = m, data = mdcrTBL, subconditions = FALSE)

  if (grepl("pccc", m)) {
    set_results(DFS,  m, mdcrDF,  subconditions = TRUE)
    set_results(DTS,  m, mdcrDT,  subconditions = TRUE)
    set_results(TBLS, m, mdcrTBL, subconditions = TRUE)
  }
}

# same objects in each environment
stopifnot(
  identical(sort(ls(envir = DFS, all.names = TRUE)), sort(ls(envir = DTS, all.names = TRUE))),
  identical(sort(ls(envir = DFS, all.names = TRUE)), sort(ls(envir = TBLS, all.names = TRUE)))
)

for (obj in ls(envir = DFS, all.names = TRUE)) {
  stopifnot(
    inherits(DFS[[obj]], "medicalcoder_comorbidities"),
    inherits(DTS[[obj]], "medicalcoder_comorbidities"),
    inherits(TBLS[[obj]], "medicalcoder_comorbidities")
  )
}

# All the results should be identical save the attributes (class).
for (obj in ls(envir = DFS, all.names = TRUE)) {
  xDF  <- DFS[[obj]]
  xTBL <- TBLS[[obj]]
  xDT  <- DTS[[obj]]
  stopifnot(isTRUE(all.equal(xDF, xTBL, check.attributes = FALSE)))
  stopifnot(isTRUE(all.equal(xDF, xDT, check.attributes = FALSE)))
}

# check that the print method returns the input object
for (obj in ls(envir = DFS, all.names = TRUE)) {
  capture.output(x <- print(DFS[[obj]]))
  z <- identical(x, DFS[[obj]])
  if (!z) {
    stop(sprintf("print(DFS[['%s']]) does not return identical %s", obj, obj))
  }
  capture.output(x <- print(TBLS[[obj]]))
  z <- identical(x, TBLS[[obj]])
  if (!z) {
    stop(sprintf("print(TBLS[['%s']]) does not return identical %s", obj, obj))
  }
  capture.output(x <- print(DTS[[obj]]))
  z <- identical(x, DTS[[obj]])
  if (!z) {
    stop(sprintf("print(DTS[['%s']]) does not return identical %s", obj, obj))
  }
}

################################################################################
# Now, if the data.table namespace is available, then test that the elements in
# DTS are data.tables and after setting to data.frames, then the objects are
# identical.

if (requireNamespace("data.table", quietly = TRUE)) {
  stopifnot(is.data.frame(mdcrDF))
  stopifnot(is.data.frame(mdcrDT))
  stopifnot(data.table::is.data.table(mdcrDT))
  for (obj in ls(envir = DTS, all.names = TRUE)) {
    stopifnot(data.table::is.data.table(DTS[[obj]][["conditions"]]))
    data.table::setDF(DTS[[obj]][["conditions"]])
    if (!is.null(DTS[[obj]][["subconditions"]])) {
      for (sc in names(DTS[[obj]][["subconditions"]])) {
        stopifnot(data.table::is.data.table(DTS[[obj]][["subconditions"]][[sc]]))
        data.table::setDF(DTS[[obj]][["subconditions"]][[sc]])
      }
    }
  }
}

# regardless of having data.table available, the elements should be identical to
# the results for a data.frame

for (obj in ls(envir = DFS, all.names = TRUE)) {
  xDF <- DFS[[obj]]
  xDT <- DTS[[obj]]
  stopifnot(identical(class(xDT), class(xDF)))
  stopifnot(identical(xDF, xDT))
}


################################################################################
# For tibbles

if (requireNamespace("dplyr", quietly = TRUE)) {
  stopifnot(is.data.frame(mdcrDF))
  stopifnot(is.data.frame(mdcrTBL))
  stopifnot(inherits(mdcrTBL, "tbl_df"))
  for (obj in ls(envir = TBLS, all.names = TRUE)) {
    stopifnot(inherits(TBLS[[obj]][["conditions"]], "tbl_df"))
    TBLS[[obj]][["conditions"]] <- as.data.frame(TBLS[[obj]][["conditions"]])
    if (!is.null(TBLS[[obj]][["subconditions"]])) {
      for (sc in names(TBLS[[obj]][["subconditions"]])) {
        stopifnot(inherits(TBLS[[obj]][["subconditions"]][[sc]], "tbl_df"))
        TBLS[[obj]][["subconditions"]][[sc]] <- as.data.frame(TBLS[[obj]][["subconditions"]][[sc]])
      }
    }
  }
}

for (obj in ls(envir = DFS, all.names = TRUE)) {
  xDF <- DFS[[obj]]
  xTBL <- TBLS[[obj]]
  stopifnot(identical(class(xTBL), class(xDF)))
  stopifnot(identical(xTBL, xDF))
}



################################################################################
#                                 End of File                                  #
################################################################################
