ARG R_TAG=latest
ARG SNAPSHOT=""
FROM rocker/r-ver:${R_TAG}

ARG DEBIAN_FRONTEND=noninteractive
ENV _R_CHECK_FORCE_SUGGESTS_=false \
    CRAN_SNAPSHOT=${SNAPSHOT:-} \
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

COPY docker/with-suggests/install-suggests.R /opt/install-suggests.R
RUN R -q -e "source('/opt/install-suggests.R')"

WORKDIR /work
