# Install Suggests with version pins, honoring an optional CRAN snapshot.
options(
  repos = c(CRAN = "https://cran.rstudio.com"),
  Ncpus = max(1L, parallel::detectCores() - 1L)
)

if (interactive()) {
  to_install <- readRDS("to_install.rds")
  deps <- readRDS("deps.rds")
  mdcr_suggests <- readRDS("mdcr_suggests.rds")
  rver <- "4.1.0" # for dev work
} else {
  rver <- getRversion()
}

# for a given R version
to_install <-
  pkg_history[pkg_date <= rvers[r_version == rver, r_eol_date]][, .SD[pkg_date == max(pkg_date)], by = .(pkg)]
to_install <- unique(to_install, by = c("pkg", "pkg_version"))

deps <-
  split(
    to_install,
    f = list(to_install[["pkg"]], to_install[["pkg_version"]]),
    sep = "___")

  lapply(`[[`, "dependencies") |>
  lapply(`[[`, 1) |>
  data.table::rbindlist(idcol = "pkg")

deps[, c("pkg", "pkg_version") := data.table::tstrsplit(pkg, "___")]
deps <- subset(deps, package != "R")
deps <- subset(deps, package != "R.1")
deps <- subset(deps, !(package %in% base_pkgs))
deps <- subset(deps, type %in% c("Depends", "Imports", "LinkingTo"))






p <- to_install[["pkg"]][1]

while(nrow(to_install) > 0L) {
  v <- to_install[["pkg_version"]][to_install[["pkg"]] == p]
  message(sprintf("considering %s version %s", p, v))
  if (p %in% deps[["pkg"]]) {
    message(sprintf("%s has missing dependencies", p))
    p <- deps[deps[["pkg"]] == p, ][1, "package"]
  } else {
    if (to_install[["latest"]][to_install[["pkg"]] == p]) {
      message(sprintf("installing %s from CRAN", p))
      if (!interactive()) {
        install.packages(p)
      }
    } else {
      url <- sprintf("https://cran.r-project.org/src/contrib/Archive/%s/%s_%s.tar.gz", p, p, v)
      message(sprintf("installing %s from %s", p, url))
      if (!interactive()) {
        install.packages(pkgs = url, type = "source", repos = NULL)
      }
    }
    to_install <- subset(to_install, pkg != p)
    deps <- subset(deps, pkg != p)
    deps <- subset(deps, package != p)
    p <- to_install[["pkg"]][1]
  }
}
