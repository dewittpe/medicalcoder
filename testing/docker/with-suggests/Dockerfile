ARG R_TAG=latest
FROM r-base:${R_TAG}

ARG DEBIAN_FRONTEND=noninteractive
ENV	_R_CHECK_FORCE_SUGGESTS_=false

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

RUN R -q -e 'install.packages(c("knitr", "kableExtra", "data.table", "tibble"), repo = "https://cran.rstudio.com", Ncpus = max(1L, parallel::detectCores() - 1L))'

# (Optional but nice) A helper script to run checks inside the container.
# Usage:
#   docker run --rm -v "$PWD:/work" medicalcoder-test:4.4.1 check /work
# You can pass flags via R_CMD_CHECK_ARGS, e.g. --no-manual or --ignore-vignettes
#RUN printf '%s\n' \
#  '#!/usr/bin/env bash' \
#  'set -euo pipefail' \
#  'PKG_PATH="${1:-/work}"' \
#  'ARGS="${R_CMD_CHECK_ARGS:-}"' \
#  'echo "Running rcmdcheck on ${PKG_PATH} ${ARGS}"' \
#  'R -q -e "rcmdcheck::rcmdcheck(path = '\''${PKG_PATH}'\'', args = strsplit('\''${ARGS}'\'', '\''[[:space:]]+'\'' )[[1]], error_on = '\''warning'\'', check_dir = '\''/tmp/check'\'')" \
#  > /usr/local/bin/check && chmod +x /usr/local/bin/check

# Make a workspace mount point
WORKDIR /work

