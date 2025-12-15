include ../Makevars

.NOPARALLEL: .bench

.PHONY: all clean

all: README.md

grid.tsv grid_data.tsv &: make_grid.sh
	./$<

.bench_data: run_parallel_data.sh grid_data.tsv build_data.R benchmark-utilities.R
	./run_parallel_data.sh
	@touch $@

.bench: run_parallel.sh grid.tsv .bench_data
	./$<
	@touch $@

bench.rds relative.rds &: benchmark-summary.R .bench
	$(RSCRIPT) $<

README.md: README.Rmd outtable.rds
	$(R) -e "knitr::knit('$<', output = '$@')"

clean:
	$(RM) .bench*
	$(RM) *.svg
	$(RM) *.pdf
	$(RM) grid.tsv
	$(RM) output.rds
	$(RM) -r logs
	$(RM) -r bench_results
