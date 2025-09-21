include ../../Makevars

ELIXHAUSER_AHRQ_ICD10_INPUTS := ./ahrq/CMR_v2022-1.zip ./ahrq/CMR_v2023-1.zip ./ahrq/CMR_v2024-1.zip ./ahrq/CMR_v2025.1.zip ../icd/icd_codes.rds
ELIXHAUSER_AHRQ_ICD10_TARGETS := elixhauser_codes_ahrq_icd10.rds elixhauser_index_scores_ahrq_icd10.rds elixhauser_poa_ahrq_icd10.rds 

ELIXHAUSER_QUAN2005_INPUTS := ./regex_based_on_quan2005.txt ./ahrq/comindex2012-2015.txt ../icd/icd_codes.rds
ELIXHAUSER_QUAN2005_TARGETS := elixhauser_codes_quan2005.rds elixhauser_index_scores_quan2005.rds

FINAL_TARGETS := elixhauser_codes.rds elixhauser_index_scores.rds elixhauser_poa.rds

.INTERMEDIATE: $(ELIXHAUSER_QUAN2005_TARGETS) $(ELIXHAUSER_AHRQ_ICD10_TARGETS)

.PHONY: all clean

all: $(FINAL_TARGETS)

$(ELIXHAUSER_AHRQ_ICD10_TARGETS) &: elixhauser_ahrq_icd10.R $(ELIXHAUSER_AHRQ_ICD10_INPUTS)
	$(RSCRIPT) $<

$(ELIXHAUSER_QUAN2005_TARGETS) &: elixhauser_quan2005.R $(ELIXHAUSER_QUAN2005_INPUTS)
	$(RSCRIPT) $<

$(FINAL_TARGETS) &: elixhauser.R elixhauser_codes_ahrq_icd10.rds elixhauser_index_scores_ahrq_icd10.rds elixhauser_poa_ahrq_icd10.rds elixhauser_codes_quan2005.rds elixhauser_index_scores_quan2005.rds
	$(RSCRIPT) $<

clean:
	$(RM) *.rds

