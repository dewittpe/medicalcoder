include ../Makevars

.NOPARALLEL: .bench

.PHONY: all clean

all: README.md

grid.tsv: make_grid.sh
	./$<

.bench: run_parallel.sh grid.tsv
	./$<
	@touch $@

outtable.rds: benchmark-summary.R .bench
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

