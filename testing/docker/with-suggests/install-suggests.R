# Install Suggests with version pins, honoring an optional CRAN snapshot.
options(
  repos = c(CRAN = "https://cran.rstudio.com"),
  Ncpus = max(1L, parallel::detectCores() - 1L)
)

install.packages(pkgs = c("remotes"))

rver <- getRversion()

if (interactive()) {
  r_and_pkg_versions <- dget(file = "r_and_pkg_versions.dput")
  # the else here is to source the file in the Dockerfile
}

pkgs <- unique(r_and_pkg_versions[["pkg"]])
r_and_pkg_versions <-
  subset(
    x = r_and_pkg_versions,
    subset = r_version == rver
  )

if (nrow(r_and_pkg_versions)) {
  for (i in seq_len(nrow(r_and_pkg_versions))) {
    remotes::install_version(
      package = r_and_pkg_versions[["pkg"]][i],
      version = r_and_pkg_versions[["pkg_version"]][i],
      upgrade = "never"
    )
  }
} else {
  install.packages(pkgs = pkgs)
}

