#!/bin/bash
set -euo pipefail

mkdir -p bench1_results logs

# Detect cores (Linux + macOS)
if command -v nproc >/dev/null 2>&1; then
  CORES=$(nproc)
else
  CORES=$(sysctl -n hw.ncpu)
fi

# Default concurrency: on dragontail 80% of machine cores (>=1)
JOBS=$(( 4 * CORES / 5 ))
if [ "$JOBS" -lt 1 ]; then JOBS=1; fi

# Memory safeguard: require 2 GiB free before starting another job.
# Tweak this per box; you can also use 4G/8G on small/large machines.
MEMFREE="2G"

# Export per-job env to force single-threaded math/libs:
export OPENBLAS_NUM_THREADS=1
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export VECLIB_MAXIMUM_THREADS=1
export GOTO_NUM_THREADS=1
export R_DATATABLE_NUM_THREADS=1

# Run!
parallel \
  --colsep '\t' \
  --header : \
  --jobs "$JOBS" \
  --memfree "$MEMFREE" \
  --shuf \
  --bar \
  --eta \
  --joblog logs/joblog.tsv \
  --results logs/out \
  '
    OUT="bench1_results/{data_class}__{subjects}__{method}__{seed}__{iter}.rds"
    # Idempotent: skip if file exists and is non-empty
    test -s "$OUT" && exit 0

    Rscript benchmark1.R "$(basename "$OUT")"
  ' \
  :::: grid.tsv
