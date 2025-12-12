#!/bin/bash
set -euo pipefail

mkdir -p bench_data logs

# Detect cores (Linux + macOS)
if command -v nproc >/dev/null 2>&1; then
  CORES=$(nproc)
else
  CORES=$(sysctl -n hw.ncpu)
fi

# Default concurrency: 80% of machine cores (>=1)
JOBS=$(( 4 * CORES / 5 ))
if [ "$JOBS" -lt 1 ]; then JOBS=1; fi

export OPENBLAS_NUM_THREADS=1
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export VECLIB_MAXIMUM_THREADS=1
export GOTO_NUM_THREADS=1
export R_DATATABLE_NUM_THREADS=1

# Build datasets in parallel; skip any already present
parallel \
  --colsep '\t' \
  --header : \
  --jobs "$JOBS" \
  --bar \
  --shuf \
  --eta \
  --joblog logs/joblog_data.tsv \
  '
    OUT="bench_data/{subjects}__{seed}.rds"
    test -s "$OUT" && exit 0
    Rscript build_data.R "$OUT"
  ' \
  :::: grid_data.tsv
