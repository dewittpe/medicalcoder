include ../Makevars

.NOPARALLEL: .bench1 .bench2

.PHONY: all clean

all: benchmark2.svg

grid%.tsv: make_grid%.sh
	./$<

.bench%: run_parallel%.sh grid%.tsv
	./$<
	@touch $@

benchmark%.svg: benchmark%-summary.R .bench%
	$(RSCRIPT) $<

clean:
	$(RM) .bench*
	$(RM) benchmark*.svg
	$(RM) *.pdf
	$(RM) grid1.tsv grid2.tsv
	$(RM) -r logs1
	$(RM) -r logs2
	$(RM) -r bench1_results
	$(RM) -r bench2_results

