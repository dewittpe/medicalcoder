pkgs <- c(
  "data.table",
  "dplyr",
  "knitr",
  "kableExtra",
  "tibble",
  "rmarkdown",
  "R.utils"
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
available_pkgs <- available.packages()

# use the tools::package_dependencies function to generate a list of the
# packages dependencies, and dependencies of dependencies, and so on, ...
pkgs_to_download <- pkgs
i <- 1L
while(i <= length(pkgs_to_download)) {
  deps <-
    unlist(tools::package_dependencies(packages = pkgs_to_download[i],
                                       which = c("Depends", "Imports", "LinkingTo"),
                                       db = available_pkgs,
                                       recursive = FALSE),
           use.names = FALSE)
  deps <- deps[!(deps %in% base_pkgs)]
  pkgs_to_download <- append(pkgs_to_download, deps, i)
  i <- i + 1L
}
pkgs_to_download <- unique(rev(pkgs_to_download))


# R vesions and dates
rvers <- data.table::copy(rversions::available())
data.table::setDT(rvers)
rvers <- rvers[, .(r_version = version, r_date = date)]
rvers <- rvers[r_version >= "3.5.0" & r_version < getRversion()]

# get the versions and dates for the needed packages
pvers <-
  lapply(pkgs_to_download, pak::pkg_history) |>
  lapply(data.table::as.data.table) |>
  data.table::rbindlist(use.names = TRUE, fill = TRUE)
pvers <-
  pvers[,
   .(
     pkg = Package,
     pkg_version = Version,
     pkg_date = as.POSIXct(crandb_file_date)
   )
  ]

pvers[, current_version := pkg_date == max(pkg_date), by = .(pkg)]

v <-
  split(rvers, by = "r_version") |>
  lapply(function(rv) {
    pvers[pkg_date <= rv[["r_date"]]][, .SD[pkg_date == max(pkg_date)], by = .(pkg)]
   }) |>
  data.table::rbindlist(idcol = "r_version")

v[, pkg := factor(pkg, levels = pkgs_to_download)]
data.table::setkey(v, r_version, pkg)

data.table::setDF(v)
dput(v, file = "r_and_pkg_versions.dput")
