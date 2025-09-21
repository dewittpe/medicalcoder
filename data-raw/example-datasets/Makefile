include ../../Makevars

TARGETS := ../../data/mdcr.rda ../../data/mdcr_longitudinal.rda

.PHONY: all clean

all: $(TARGETS)

../../data/mdcr.rda: mdcr.R mdcr.csv
	$(RSCRIPT) $<

../../data/mdcr_longitudinal.rda: mdcr_longitudinal.R longitudinal_example_data.dat
	$(RSCRIPT) $<

clean:
	$(RM) $(TARGETS)
