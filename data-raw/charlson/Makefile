include ../../Makevars

.PHONY: all clean

all: charlson_regex.rds charlson_codes.rds charlson_index_scores.rds

../icd/icd_codes.rds:
	$(MAKE) -C ../icd $(@F)

charlson_codes.rds charlson_index_scores.rds &: charlson.R ../icd/icd_codes.rds deyo1992.txt cdmf2019.txt quan2005.txt charlson.txt sundararajan2004.txt charlson_ludvigsson2021.txt
	$(RSCRIPT) $<

charlson_regex.rds: charlson_regex_for_package.R regex_for_package.txt
	$(RSCRIPT) $<

clean:
	$(RM) *.rds
