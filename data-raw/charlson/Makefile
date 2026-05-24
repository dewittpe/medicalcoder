include ../../Makevars

.PHONY: all clean

all: charlson_regex.rds charlson_codes.rds charlson_index_scores.rds

charlson_regex.rds charlson_codes.rds charlson_index_scores.rds &: charlson.R ../icd/icd_codes.rds deyo1992.txt cdmf2019.txt quan2005.txt charlson.txt
	$(RSCRIPT) $<

clean:
	$(RM) *.rds
