include ../../../Makevars

WHO_SOURCE := $(wildcard who/icd10_who_*.txt)

.PHONY: all clean

all: icd10.rds

icd10.rds: icd10.R cms_icd10.rds who_icd10.rds cdc_allvalid.rds ihacpa_icd10.rds icd-10-se.rds
	$(RSCRIPT) $<

cdc_icd10.rds: cdc_icd10_cm.R utilities.R .download_stamp
	$(RSCRIPT) $<

cms_icd10.rds: cms_icd10_cm_and_pcs.R utilities.R .download_stamp
	$(RSCRIPT) $<

who_icd10.rds: who.R $(WHO_SOURCE)
	$(RSCRIPT) $<

cdc_allvalid.rds: cdc_allvalid.R .download_stamp
	$(RSCRIPT) $<

ihacpa_icd10.rds: ihacpa.R
	$(RSCRIPT) $<

icd-10-se.rds: icd-10-se.R socialstyrelsen/icd-10-se.tsv
	$(RSCRIPT) $<

.download_stamp: download.sh
	./download.sh > $@ 2>&1

clean:
	$(RM) *.rds
