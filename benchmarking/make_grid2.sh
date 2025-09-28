#!/bin/bash

DATA_CLASSES=(DF DT TBL)
SUBJECTS=(1e1 1e2 5e2 1e3 5e3 1e4 5e4 1e5)
METHODS=(pccc_v3.1 pccc_v3.1s charlson_quan2005 elixhauser_quan2005)
FLAG_METHODS=(current cumulative)
SEEDS=$(seq 1 10)
ITERS=$(seq 1 10)

{
  echo -e "data_class\tsubjects\tmethod\tflag_method\tseed\titer"
  for dc in "${DATA_CLASSES[@]}"; do
    for n in "${SUBJECTS[@]}"; do
      for m in "${METHODS[@]}"; do
        for fm in "${FLAG_METHODS[@]}"; do
          for s in ${SEEDS[@]}; do
            for i in ${ITERS}; do
              echo -e "${dc}\t${n}\t${m}\t${fm}\t${s}\t${i}"
            done
          done
        done
      done
    done
  done
} > grid2.tsv
