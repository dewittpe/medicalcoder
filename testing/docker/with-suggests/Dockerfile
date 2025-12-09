ARG R_TAG=latest
FROM rocker/r-ver:${R_TAG}

ARG DEBIAN_FRONTEND=noninteractive
ENV _R_CHECK_FORCE_SUGGESTS_=false \
    TZ=Etc/UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git make g++ pkg-config \
    pandoc texinfo \
    texlive-latex-base texlive-latex-recommended texlive-latex-extra \
    texlive-fonts-recommended texlive-fonts-extra lmodern \
    libxml2-dev libcurl4-openssl-dev libssl-dev libgit2-dev \
    libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev \
    libpng-dev libjpeg-dev libtiff5-dev libwebp-dev \
    zlib1g-dev libicu-dev libbz2-dev liblzma-dev \
  && rm -rf /var/lib/apt/lists/*

#COPY docker/with-suggests/install-suggests.R /opt/install-suggests.R
#COPY docker/with-suggests/to_install.rds /opt/to_install.rds
#COPY docker/with-suggests/deps.rds /opt/deps.rds
#COPY docker/with-suggests/mdcr_suggests.rds /opt/mdcr_suggests.rds
#RUN R -q -e "to_install <- readRDS('/opt/to_install.rds')"\
#  -e "deps <- readRDS('/opt/deps.rds')"\
#  -e "mdcr_suggests <- readRDS('/opt/mdcr_suggests.rds')"\
#  -e "source('/opt/install-suggests.R', echo = TRUE)"
#
# RUN R -q -e "install.packages(c('data.table', 'dplyr','kableExtra', 'knitr', 'rmarkdown', 'R.utils', 'tibble'), repo = 'https://cran.rstudio.com')"

WORKDIR /work
