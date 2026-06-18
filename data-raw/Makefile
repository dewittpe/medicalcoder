include ../Makevars

DATASETS := ./charlson/charlson_regex.rds\
						./charlson/charlson_codes.rds\
						./charlson/charlson_index_scores.rds\
						./elixhauser/elixhauser_codes.rds\
						./elixhauser/elixhauser_index_scores.rds\
						./elixhauser/elixhauser_poa.rds\
						./icd/icd_chapters.rds\
						./icd/icd_codes.rds\
						./icd/icd_desc_token_ids.rds\
						./icd/desc_tokens.rds\
						./icd/icd_subchapters.rds\
						./pccc/pccc_codes.rds\
						./pccc/pccc_conditions.rds

.PHONY: all clean datasets example-datasets

all: datasets example-datasets ../R/sysdata.rda

datasets: | rpkgs.Rout
	$(MAKE) -C icd
	$(MAKE) -C pccc
	$(MAKE) -C charlson
	$(MAKE) -C elixhauser

example-datasets: | rpkgs.Rout
	$(MAKE) -C example-datasets

rpkgs.Rout: rpkgs.R
	$(RCMDBATCH) $< $@

# These files are owned by the component makefiles above.  The order-only
# prerequisite ensures a direct request for sysdata also builds missing inputs.
$(DATASETS): | datasets
	@test -e "$@"

../R/sysdata.rda: build_sysdata.R $(DATASETS)
	$(RSCRIPT) $<

clean:
	$(MAKE) -C icd clean
	$(MAKE) -C pccc clean
	$(MAKE) -C charlson clean
	$(MAKE) -C elixhauser clean
	$(MAKE) -C example-datasets clean
