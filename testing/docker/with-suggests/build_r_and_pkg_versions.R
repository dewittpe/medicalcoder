options(repos =
  c(CRAN = "https://cran.rstudio.com", BIOC = "https://bioconductor.org/packages/release/bioc/")
)

# Define the packages suggested for medicalcoder
mdcr_suggests <- c(
  "data.table",
  "dplyr",
  "knitr",
  "kableExtra",
  "tibble",
  "rmarkdown",
  "R.utils"
)

# extend to include the dependencies, imports, and linkingTo packages needed for
# the medicalcoder suggested packages
pkgs <-
  c(mdcr_suggests,
    c("ref", "reshape2", "chron", "assertthat", "Rcpp", "BH", "magrittr", "Lahman", "hflights", "R6", "lazyeval", "DBI", "tibble", "bindrcpp", "glue", "pkgconfig", "rlang", "plogr", "tidyselect", "ellipsis", "generics", "lifecycle", "vctrs", "pillar", "cli", "evaluate", "digest", "formatR", "stringr", "highlight", "markdown", "highr", "yaml", "xfun", "knitr", "xml2", "rvest", "rmarkdown", "readr", "magick", "scales", "viridisLite", "htmltools", "rstudioapi", "webshot", "svglite", "crayon", "fansi", "caTools", "base64enc", "jsonlite", "rprojroot", "mime", "tinytex", "jquerylib", "bslib", "fontawesome", "R.oo", "R.methodsS3"),
    c("plyr", "inline", "int64", "bindr", "purrr", "withr", "backports", "zeallot", "utf8", "gWidgets", "animation", "gWidgetsRGtk2", "parser", "stringi", "commonmark", "litedown", "httr", "XML", "selectr", "curl", "hms", "clipr", "cpp11", "vroom", "tzdb", "RColorBrewer", "dichromat", "munsell", "labeling", "farver", "fastmap", "processx", "callr", "gdtools", "systemfonts", "textshaping", "memoise", "bitops", "sass", "cachem", "pointblank"),
    c("itertools", "iterators", "RGtk2", "cairoDevice", "testthat", "RCurl", "openssl", "progress", "bit64", "ggplot2", "colorspace", "debugme", "ps", "gfonts", "fontquiver", "fs", "rappdirs", "Hmisc", "lazyWeave", "lubridate", "mailR", "pixiedust", "rJava", "tidyr", "RMySQL", "RPostgreSQL", "messaging", "blastula", "dbplyr", "ggforce", "gt", "log4r"),
    c("mutatr", "praise", "pkgload", "brio", "desc", "waldo", "askpass", "prettyunits", "bit", "reshape", "proto", "gtable", "isoband", "S7", "shiny", "crul", "usethis", "fontBitstreamVera", "fontLiberation", "acepack", "Formula", "latticeExtra", "gridExtra", "htmlTable", "viridis", "base64", "labelVector", "timechange", "ArgumentCheck", "broom", "checkmate", "downloader", "getPass", "here", "uuid", "blob", "tweenr", "units", "polyclip", "RcppEigen", "bigD", "juicyjuice", "htmlwidgets", "reactable"),
    c("pkgbuild", "diffobj", "rematch2", "sys", "websockets", "RJSONIO", "xtable", "httpuv", "sourcetools", "later", "promises", "urltools", "httpcode", "clisymbols", "gh", "git2r", "whisker", "styler", "gert", "png", "jpeg", "interp", "psych", "udunits2", "V8", "reactR"),
    c("otel", "triebeard", "ini", "gitcreds", "httr2", "enc", "R.cache", "credentials", "zip", "deldir", "mnormt", "GPArotation"),
    c("tmvnsim")
  )

# Define the base packages.  These are packages which come with R upon install
# of R.  These packages include: "base", "compiler", "datasets", "graphics",
# "grDevices", "grid", "methods", "parallel", "splines", "stats", "stats4",
# "tcltk", "tools", and "utils".
#
# NOTE: there are Priority = "recommended" packages as well.  If these packages
# are missing from the system install, this script might fail.  Downloading and
# installing the 'recommended' packages can be difficult between R versions.
base_pkgs <-
  unname(utils::installed.packages()[utils::installed.packages()[, "Priority"] %in% c("base", "recommended"), "Package"])

# get a list of the available packages from CRAN and BioConductor
#available_pkgs <- available.packages()
#biocondutor_pkgs <- available.packages(repos = options()$repos["BIOC"])

# After spending a couple days trying to automate this process it is clear to me
# that it will be better to just manually build a data base and script for
# installing the needed packages for each version of R.
#
# the rversions and pak pakages will help with collecting the needed meta data.
rvers <- data.table::copy(rversions::available())
data.table::setDT(rvers)
rvers <- rvers[, .(r_version = version, r_release_date = date)]
rvers <- rvers[r_version >= "3.5.0"]

get_pkg_history <- function(pkg) {
  f <- sprintf("./pkg_histories/%s.history", pkg)
  if (file.exists(f)) {
    message(sprintf("loading history for %s", pkg))
    rtn <- readRDS(file = f)
  } else {
    message(sprintf("getting history for %s", pkg))
    rtn <- pak::pkg_history(pkg)
    rtn <- as.data.frame(rtn)
    saveRDS(rtn, file = f)
  }
  rtn
}

pkg_history <-
  lapply(pkgs, get_pkg_history) |>
  lapply(data.table::as.data.table) |>
  data.table::rbindlist(use.names = TRUE, fill = TRUE)

more <- do.call(rbind, pkg_history[["dependencies"]])
more <- subset(more, package != "R")
more <- subset(more, package != "R.1") # this is an issue due parser_0.1 (2012-11-02)
more <- subset(more, package != "mva") # this is due to Hmisc_2.0-0 (2003-07-10)
more <- subset(more, package != "Daniel Veillard's libxml") # this is due to XML_0.2 (2000/06/22)
more <- subset(more, type %in% c("Depends", "Imports", "LinkingTo"))
more <- subset(more, !(package %in% base_pkgs))
more <- subset(more, !(package %in% pkgs))

if (length(unique(more[["package"]])) > 0L) {
  dput(unique(more[["package"]]))
  stop("there are more packages to add to pkgs")
}

# the next couple lines are helpful to find odd things in the history
#for(i in seq_len(nrow(pkg_history))) {
#  x <- pkg_history[["dependencies"]][[i]]
#  if (any(x$package == "R.1")) {
#    print(pkg_history[i])
#    stop()
#  }
#}

pkg_history <-
  pkg_history[, .(pkg = Package, pkg_version = Version, pkg_date = crandb_file_date, dependencies)]

pkg_history[, latest := as.integer(pkg_date == max(pkg_date)), by = .(pkg)]

rvers <- data.table::copy(rversions::available())
data.table::setDT(rvers)
rvers <- rvers[, .(r_version = version, r_release_date = date)]
rvers <- rvers[r_version >= "3.5.0"]

# for each R version, get the eol date (date of the next version)
rvers[, r_eol_date := data.table::shift(r_release_date, type = "lead")]
rvers <- rvers[!is.na(r_eol_date)]


data.table::setDF(to_install)
saveRDS(to_install, file = "to_install.rds")
data.table::setDF(deps)
saveRDS(deps, file = "deps.rds")
saveRDS(mdcr_suggests, file = "mdcr_suggests.rds")

