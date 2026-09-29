include ../../Makevars

ICD_DATA_SETS := icd_codes.rds\
								 desc_tokens.rds\
								 icd_desc_token_ids.rds\
								 known_and_assignable_start_stop.rds\
								 desc_start_stop.rds\
								 icd_chapters.rds\
								 icd_subchapters.rds

.PHONY: all clean icd-sources

all: $(ICD_DATA_SETS)

# Consult child dependency graphs even when their outputs already exist.
# Order-only prerequisites keep an unchanged child from rebuilding parent data.
icd-sources:
	$(MAKE) -C icd9 icd9.rds
	$(MAKE) -C icd10 icd10.rds

icd9/icd9.rds icd10/icd10.rds: | icd-sources
	@test -e "$@"

$(ICD_DATA_SETS) &: icd_codes.R icd9/icd9.rds icd10/icd10.rds icd_chapters_subchapters.dat ../../R/icd_compact_to_full.R
	$(RSCRIPT) $<

clean:
	$(RM) *.rds
	$(MAKE) -C icd9 clean
	$(MAKE) -C icd10 clean
