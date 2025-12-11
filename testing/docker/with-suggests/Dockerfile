ARG R_TAG=latest
FROM rocker/r-ver:${R_TAG}

ARG DEBIAN_FRONTEND=noninteractive
ENV _R_CHECK_FORCE_SUGGESTS_=false \
    TZ=Etc/UTC

# system libs, but no pandoc / pandoc-citeproc here
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libgit2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libjpeg-dev \
    libtiff5-dev \
    libwebp-dev \
    zlib1g-dev \
    libicu-dev \
    libbz2-dev \
    liblzma-dev \
    curl \
    git \
    make \
    g++ \
    pkg-config \
    texinfo \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    lmodern \
    && rm -rf /var/lib/apt/lists/*

# one Pandoc version for all R/OS combos
ARG PANDOC_VERSION=3.1.12.2

RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64|arm64) ;; \
      *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
    esac; \
    deb="pandoc-${PANDOC_VERSION}-1-${arch}.deb"; \
    curl -L "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/${deb}" \
      -o /tmp/pandoc.deb; \
    dpkg -i /tmp/pandoc.deb; \
    rm /tmp/pandoc.deb

RUN R -q -e " \
  cores <- parallel::detectCores(logical = FALSE); \
  cores <- if (is.na(cores) || cores < 1) 1L else cores; \
  install.packages( \
    pkgs = c('data.table', 'dplyr','kableExtra', 'knitr', 'rmarkdown', 'R.utils'), \
    repos = 'https://cran.rstudio.com', \
    Ncpus = cores \
  )"

WORKDIR /work
