include ../Makevars

DATASETS := ./charlson/charlson_codes.rds\
						./charlson/charlson_index_scores.rds\
						./elixhauser/elixhauser_codes.rds\
						./elixhauser/elixhauser_index_scores.rds\
						./elixhauser/elixhauser_poa.rds\
						./icd/icd_chapters.rds\
						./icd/icd_codes.rds\
						./icd/icd_descs.rds\
						./icd/icd_subchapters.rds\
						./pccc/pccc_codes.rds

.PHONY: all clean

all: | rpkgs.Rout
	$(MAKE) -C icd
	$(MAKE) -C pccc
	$(MAKE) -C charlson
	$(MAKE) -C elixhauser
	$(MAKE) -C example-datasets
	$(MAKE) ../R/sysdata.rda

rpkgs.Rout: rpkgs.R
	$(RCMDBATCH) $< $@

../R/sysdata.rda: build_sysdata.R $(DATASETS)
	$(RSCRIPT) $<

clean:
	$(MAKE) -C icd clean
	$(MAKE) -C pccc clean
	$(MAKE) -C charlson clean
	$(MAKE) -C elixhauser clean
	$(MAKE) -C example-datasets clean
