#!/bin/bash
set -euo pipefail

mkdir -p bench2_results logs2 logs2/mem

# Detect cores (Linux + macOS)
if command -v nproc >/dev/null 2>&1; then
  CORES=$(nproc)
else
  CORES=$(sysctl -n hw.ncpu)
fi

# Default concurrency: on dragontail 80% of machine cores (>=1)
JOBS=$(( 4 * CORES / 5 ))
if [ "$JOBS" -lt 1 ]; then JOBS=1; fi

# Memory safeguard: require this much free RAM before starting another job
MEMFREE="150G"

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
  --joblog logs2/joblog1.tsv \
  --results logs2/out \
  '
    OUT="bench2_results/{data_class}__{subjects}__{method}__{flag_method}__{seed}__{iter}.rds"
    MEMRAW="logs2/mem/{data_class}__{subjects}__{method}__{flag_method}__{seed}__{iter}.raw"
    MEMTSV="logs2/mem/{data_class}__{subjects}__{method}__{flag_method}__{seed}__{iter}.tsv"

    # Idempotent: skip if result already exists and non-empty
    test -s "$OUT" && exit 0

    # Run and capture peak RSS cross-platform
    if /usr/bin/time -v true >/dev/null 2>&1; then
      # Linux/GNU time: write verbose stats to MEMRAW
      /usr/bin/time -v -o "$MEMRAW" Rscript benchmark2.R "$(basename "$OUT")"
      PEAK_KIB=$(awk -F: "/Maximum resident set size/ {gsub(/^[[:space:]]+|[[:space:]]+$/,\"\",\$2); print \$2}" "$MEMRAW")
    else
      # macOS/BSD time: -l prints "maximum resident set size" in bytes to stderr
      /usr/bin/time -l Rscript benchmark2.R "$(basename "$OUT")" 2> "$MEMRAW"
      # Convert bytes -> KiB (rounded)
      PEAK_KIB=$(awk "/maximum resident set size/ {kb=int(\$1/1024+0.5); print kb}" "$MEMRAW")
    fi

    printf "data_class\tsubjects\tmethod\tflag_method\tseed\titer\tout\tmax_rss_kib\n" > "$MEMTSV"
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
      "{data_class}" "{subjects}" "{method}" "{flag_method}" "{seed}" "{iter}" "$OUT" "$PEAK_KIB" >> "$MEMTSV"
  ' \
  :::: grid2.tsv

# Aggregate per-job mem into one table (overwrite each run)
{
  echo -e "data_class\tsubjects\tmethod\tflag_method\tseed\titer\tout\tmax_rss_kib"
  awk 'FNR==1 && NR!=1 { next } { print }' logs2/mem/*.tsv 2>/dev/null || true
} > logs2/peak_mem.tsv

