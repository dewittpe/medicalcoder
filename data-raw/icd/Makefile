include ../../Makevars

ICD_DATA_SETS := icd_codes.rds\
								 icd_descs.rds\
								 known_and_assignable_start_stop.rds\
								 desc_start_stop.rds\
								 icd_chapters.rds\
								 icd_subchapters.rds

.PHONY: all clean

all:
	$(MAKE) -C icd9
	$(MAKE) -C icd10
	$(MAKE) $(ICD_DATA_SETS)

$(ICD_DATA_SETS) &: icd_codes.R icd9/icd9_cm_pcs.rds icd10/icd10.rds icd_chapters_subchapters.dat ../../R/icd_compact_to_full.R
	$(RSCRIPT) $<

clean:
	$(RM) *.rds
	$(MAKE) -C icd9 clean
	$(MAKE) -C icd10 clean
