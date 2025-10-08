################################################################################
# file: rpkgs.R
#
# purpose: Install CRAN and local dependencies required to rebuild data-raw
#          artifacts.
#
# inputs:
#   CRAN packages: Rcpp, data.table, tidyverse, pbapply, readxl, zoo, qwraps2,
#     usethis
#   pccc/pccc_v2/pccc_1.0.6.tar.gz (local tarball install)
#
# output: Installs/updates packages in the active library (no files written).
#
# deps: utils::install.packages
#
# notes:
#   Skips already-installed packages and ensures pccc 1.0.6 tarball is
#     available. Some of the needed packages are already installed via the
#     .install_dev_deps.Rout in ../Makefile and thus the list of packages here
#     might be incomplete if that has not been evaluated.
#
# idempotent: yes (re-running only installs missing packages)
################################################################################


options(repos=c(CRAN='https://cran.rstudio.com'))

pkgs <- c("Rcpp", "data.table", "tidyverse", "pbapply", "readxl", "zoo", "qwraps2", "usethis")

to_install <- setdiff(pkgs, rownames(installed.packages()))

if (length(to_install)) {
  install.packages(pkgs = to_install, Ncpus = 4L)
}

if (!(("pccc" %in% rownames(installed.packages())) && (packageVersion("pccc") == "1.0.6"))) {
  install.packages(pkgs = "pccc/pccc_v2/pccc_1.0.6.tar.gz", repos = NULL, type = "source")
}

################################################################################
#                                 End of File                                  #
################################################################################
