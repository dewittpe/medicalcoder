include ../Makevars

.NOPARALLEL: .bench

.PHONY: all clean

all: README.md

grid.tsv: make_grid.sh
	./$<

mimicdata.rds: prep-mimic-data.R mimic-iv-clinical-database-demo-2.2.zip
	$(RSCRIPT) $<

#.bench_data: run_parallel_data.sh grid_data.tsv build_data.R benchmark-utilities.R
#	./run_parallel_data.sh
#	@touch $@

.benchmark: run_parallel.sh grid.tsv
	./$<
	@touch $@

bench.rds relative.rds &: benchmark-summary.R .benchmark
	$(RSCRIPT) $<

README.md: README.Rmd bench.rds
	$(R) -e "knitr::knit('$<', output = '$@')"

clean:
	$(RM) .bench*
	$(RM) *.svg
	$(RM) *.pdf
	$(RM) grid.tsv
	$(RM) output.rds
	$(RM) -r logs
	$(RM) -r bench_results
