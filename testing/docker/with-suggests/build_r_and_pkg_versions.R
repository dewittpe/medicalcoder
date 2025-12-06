pkgs <- c(
  "data.table",
  "dplyr",
  "knitr",
  "kableExtra",
  "tibble",
  "rmarkdown",
  "R.utils"
)

rvers <- data.table::copy(rversions::available())
data.table::setDT(rvers)
rvers <- rvers[, .(r_version = version, r_date = date)]
rvers <- rvers[r_version >= "3.5.0" & r_version < getRversion()]

pkgs <-
  lapply(pkgs, pak::pkg_history) |>
  lapply(data.table::as.data.table) |>
  data.table::rbindlist(use.names = TRUE, fill = TRUE)
pkgs <-
  pkgs[,
   .(
     pkg = Package,
     pkg_version = Version, 
     pkg_date = as.POSIXct(crandb_file_date)
   )
  ]

v <-
  split(rvers, by = "r_version") |>
  lapply(function(rv) {
    pkgs[pkg_date <= rv[["r_date"]]][, .SD[pkg_date == max(pkg_date)], by = .(pkg)]
   }) |>
  data.table::rbindlist(idcol = "r_version")
data.table::setkey(v, r_version, pkg_date)
data.table::setDF(v)
dput(v, file = "r_and_pkg_versions.dput")
