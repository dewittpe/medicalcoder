source('utilities.R')
################################################################################
# test that the output when using a data.frame, tibble, or data.table are all
# the same.
if (!requireNamespace("data.table", quietly = TRUE)) {
  message("SKIP: data.table not available; skipping test-tibble-datatable.R")
  quit(save = "no", status = 0, runLast = FALSE)
}

if (!requireNamespace("tibble", quietly = TRUE)) {
  message("SKIP: tibble not available; skipping test-tibble-datatable.R")
  quit(save = "no", status = 0, runLast = FALSE)
}

library(medicalcoder)
library(tibble)
library(data.table)
old_threads <- getDTthreads()
setDTthreads(threads = 1L) # to prevent CPU time exceeding elapsed time on CRAN
on.exit(setDTthreads(old_threads), add = TRUE)
mdcrDF  <- mdcr
mdcrTBL <- as_tibble(mdcr)
mdcrDT  <- as.data.table(copy(mdcr))

stopifnot(is.data.frame(mdcrDF))
stopifnot(is_tibble(mdcrTBL))
stopifnot(is.data.table(mdcrDT))


################################################################################
common_args <-
  list(id.vars = "patid", icdv.var = "icdv", icd.codes = "code",
       dx.var = "dx", poa = 1, primarydx = 0)

DFS  <- new.env()
TBLS <- new.env()
DTS  <- new.env()

methods <- medicalcoder:::comorbidities_methods()

set_results <- function(target_env, method, data, subconditions = FALSE) {
  assign(
    x = if (subconditions) paste0(method, "_with_subconditions") else method,
    value = do.call(
      comorbidities,
      c(common_args, list(data = data, method = method, subconditions = subconditions))
    ),
    envir = target_env
  )
}

for (m in methods) {
  set_results(DFS,  m, mdcrDF)
  set_results(DTS,  m, mdcrDT)
  set_results(TBLS, m, mdcrTBL)

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

# All objects should be medicalcoder_comorbidities objects
# only those with the _with_subconditions suffix should be
# medicalcoder_comorbidities_with_subconditions objects
for (obj in ls(envir = DFS, all.names = TRUE)) {
  xDF  <- DFS[[obj]]
  xDT  <- DTS[[obj]]
  xTBL <- TBLS[[obj]]

  stopifnot(inherits(xDF,  "medicalcoder_comorbidities"))
  stopifnot(inherits(xDT,  "medicalcoder_comorbidities"))
  stopifnot(inherits(xTBL, "medicalcoder_comorbidities"))

  sbcnd <- endsWith(obj, "_with_subconditions")

  stopifnot(identical(sbcnd, inherits(get(x = obj, envir = DFS),  "medicalcoder_comorbidities_with_subconditions")))
  stopifnot(identical(sbcnd, inherits(get(x = obj, envir = DTS),  "medicalcoder_comorbidities_with_subconditions")))
  stopifnot(identical(sbcnd, inherits(get(x = obj, envir = TBLS), "medicalcoder_comorbidities_with_subconditions")))
}

# All the DF and TBL results should be identical.
for (obj in ls(envir = DFS, all.names = TRUE)) {
  xDF  <- DFS[[obj]]
  xTBL <- TBLS[[obj]]
  stopifnot(identical(xDF, xTBL))
}

# All the DTS results would be different because of the data.table specific
# attributes.  So, check that everything is a data.table and then set to a
# data.frame

for (obj in ls(envir = DTS, all.names = TRUE)) {
  if (grepl("_with_subconditions", obj)) {
    stopifnot(data.table::is.data.table(DTS[[obj]][["conditions"]]))
    setDF(DTS[[obj]][["conditions"]])
    for (sc in names(DTS[[obj]][["subconditions"]])) {
      stopifnot(data.table::is.data.table(DTS[[obj]][["subconditions"]][[sc]]))
      setDF(DTS[[obj]][["subconditions"]][[sc]])
    }
  } else {
    stopifnot(data.table::is.data.table(DTS[[obj]]))
    setDF(DTS[[obj]])
    class(DTS[[obj]]) <- c("medicalcoder_comorbidities", class(DTS[[obj]]))
  }
}

# now that the outputs are data.frames, not data.tables, the results should all
# be identical to the DFs
for (obj in ls(envir = DFS, all.names = TRUE)) {
  xDF <- DFS[[obj]]
  xDT <- DTS[[obj]]
  stopifnot(identical(class(xDT), class(xDF)))
  stopifnot(identical(xDF, xDT))
}

################################################################################
#                                 End of File                                  #
################################################################################
