include ../../../Makevars

CMS_SOURCE := $(shell awk 'NR > 1 {print $$3}' cms-releases.tsv)
CDC_DIR := ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10
CDC_MORTALITY_SOURCE := $(CDC_DIR)/allvalid2009(detailed\ titles\ headings).xls $(CDC_DIR)/allvalid2011\ (detailed\ titles\ headings).xls $(CDC_DIR)/allvalid2020\ (detailed_titles_headings).csv $(CDC_DIR)/allvalid2023-detailed-titles-headings.csv
CDC_CM_2027 := ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10CM/2027/icd10cm-code-descriptions-2027.zip

WHO_SOURCE := $(wildcard who/icd10_who_*.txt)

.PHONY: all clean check-sources download

all: icd10.rds

icd10.rds: icd10.R cms_icd10.rds who_icd10.rds cdc_allvalid.rds ihacpa_icd10.rds icd-10-se.rds
	$(RSCRIPT) $<

cdc_icd10.rds: cdc_icd10_cm.R utilities.R .download_stamp
	$(RSCRIPT) $<

cms_icd10.rds: cms_icd10_cm_and_pcs.R utilities.R cms-releases.tsv $(CMS_SOURCE)
	$(RSCRIPT) $<

who_icd10.rds: who.R $(WHO_SOURCE)
	$(RSCRIPT) $<

cdc_allvalid.rds: cdc_allvalid.R $(CDC_MORTALITY_SOURCE)
	$(RSCRIPT) $<

ihacpa_icd10.rds: ihacpa.R
	$(RSCRIPT) $<

icd-10-se.rds: icd-10-se.R socialstyrelsen/icd-10-se.tsv
	$(RSCRIPT) $<

# Downloads are explicit; ordinary rebuilds use the recorded local sources.
download:
	./download.sh > .download_stamp.tmp 2>&1
	mv .download_stamp.tmp .download_stamp

check-sources: cms_icd10.rds check-sources.R utilities.R $(CDC_CM_2027)
	$(RSCRIPT) check-sources.R

.download_stamp: download.sh
	./download.sh > $@.tmp 2>&1
	mv $@.tmp $@

clean:
	$(RM) *.rds
