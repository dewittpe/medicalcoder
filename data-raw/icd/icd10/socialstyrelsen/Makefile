include ../../../../Makevars

all: icd-10-se.rds

icd-10-se.rds: icd-10-se.R icd-10-se.tsv
	$(RSCRIPT) $<

clean:
	$(RM) icd-10-se.rds
