# Install Suggests with version pins, honoring an optional CRAN snapshot.

snap <- Sys.getenv("CRAN_SNAPSHOT", "")
cran <- if (nzchar(snap)) {
  sprintf("https://cran.microsoft.com/snapshot/%s", snap)
} else {
  "https://cran.r-project.org"
}
Ncpus <- max(1L, parallel::detectCores() - 1L)

install.packages("remotes", repos = cran, Ncpus = Ncpus)

rver <- getRversion()

pkgs <- list(
  knitr      = NA_character_,
  kableExtra = NA_character_,
  data.table = NA_character_,
  tibble     = NA_character_,
  rmarkdown  = NA_character_,
  R.utils    = NA_character_
)

if (rver < "4.0.0") {
  pkgs$knitr      <- "1.40"
  pkgs$kableExtra <- "1.3.4"
  pkgs$data.table <- "1.14.10"
  pkgs$tibble     <- "3.1.8"
  pkgs$rmarkdown  <- "2.21"
  pkgs$R.utils    <- "2.12.2"
} else if (rver < "4.2.0") {
  pkgs$knitr      <- "1.41"
  pkgs$kableExtra <- "1.4.0"
  pkgs$data.table <- "1.14.10"
  pkgs$tibble     <- "3.2.1"
  pkgs$rmarkdown  <- "2.24"
  pkgs$R.utils    <- "2.12.2"
} else if (rver < "4.4.0") {
  pkgs$knitr      <- "1.45"
  pkgs$kableExtra <- "1.4.0"
  pkgs$data.table <- "1.15.0"
  pkgs$tibble     <- "3.2.1"
  pkgs$rmarkdown  <- "2.26"
  pkgs$R.utils    <- "2.12.2"
} else {
  # Current CRAN versions for latest R releases
  pkgs[] <- NA_character_
}

for (nm in names(pkgs)) {
  ver <- pkgs[[nm]]
  if (is.na(ver)) {
    install.packages(nm, repos = cran, Ncpus = Ncpus)
  } else {
    remotes::install_version(nm, version = ver, repos = cran, Ncpus = Ncpus, upgrade = "never")
  }
}
