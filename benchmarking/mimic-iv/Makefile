include ../../Makevars

.NOPARALLEL: .benchmark

.PHONY: all clean

all: benchmark.rds

mimicivdata.rds: prep-mimic-data.R mimic-iv-clinical-database-demo-2.2.zip
	$(RSCRIPT) $<

grid.tsv: make_grid.sh
	./$<

.benchmark: run_parallel.sh grid.tsv mimicivdata.rds
	./$<
	@touch $@

benchmark.rds: benchmark-summary.R .benchmark
	$(RSCRIPT) $<

clean:
	$(RM) .benchmark
	$(RM) *.svg
	$(RM) *.pdf
	$(RM) *.png
	$(RM) grid.tsv
	$(RM) *.rds
	$(RM) -r logs
	$(RM) -r bench_results
