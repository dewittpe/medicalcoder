include ../Makevars

all: README.md

benchmark-composite.svg: benchmarks.R
	$(RSCRIPT) $<

README.md: README.Rmd benchmark-composite.svg
	$(R) -e "knitr::knit('$<', output = '$@')"
