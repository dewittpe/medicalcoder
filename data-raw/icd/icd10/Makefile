include ../../../Makevars

WHO_SOURCE := $(wildcard who/icd10_who_*.txt)

.INTERMEDIATE: cdc_allvalid.rds cdc_icd10.rds cms_icd10.rds icd10_cm_pcs.rds who_icd10.rds

.PHONY: all clean

all: icd10.rds

icd10.rds: icd10.R icd10_cm_pcs.rds who_icd10.rds cdc_allvalid.rds
	$(RSCRIPT) $<

icd10_cm_pcs.rds: icd10_cm_pcs.R cdc_icd10.rds cms_icd10.rds
	$(RSCRIPT) $<

cdc_icd10.rds: cdc_icd10_cm.R utilities.R .download_stamp
	$(RSCRIPT) $<

cms_icd10.rds: cms_icd10_cm_and_pcs.R utilities.R .download_stamp
	$(RSCRIPT) $<

who_icd10.rds: who.R $(WHO_SOURCE)
	$(RSCRIPT) $<

cdc_allvalid.rds: cdc_allvalid.R .download_stamp
	$(RSCRIPT) $<

.download_stamp: download.sh
	./download.sh > $@ 2>&1

clean:
	$(RM) *.rds
