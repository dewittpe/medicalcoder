include ../../Makevars

ICD_CODES := ../icd/icd_codes.rds
ICD_KNOWN_AND_ASSIGNABLE := ../icd/known_and_assignable_start_stop.rds

.PHONY: all clean

all: pccc_codes.rds pccc_conditions.rds

pccc_v2.0.rds: pccc_v2.0.R pccc_v2_subconditions.rds $(ICD_CODES) $(ICD_KNOWN_AND_ASSIGNABLE)
	$(RSCRIPT) $<

pccc_v2.1.rds: pccc_v2.1.R pccc_v2.0.rds pccc_v2_subconditions.rds pccc_v2_r_sas_stata.rds $(ICD_CODES)
	$(RSCRIPT) $<

pccc_v3.0.rds pccc_v3.1.rds &: pccc_v3.R $(ICD_CODES)
	$(RSCRIPT) $<

pccc_v2_subconditions.rds: pccc_v2_subconditions.R $(ICD_CODES)
	$(RSCRIPT) $<

pccc_v2_r_sas_stata.rds: pccc_v2_r_sas_stata.R
	$(RSCRIPT) $<

pccc_codes.rds pccc_conditions.rds &: pccc_codes.R pccc_v2.0.rds pccc_v2.1.rds pccc_v3.0.rds pccc_v3.1.rds $(ICD_CODES)
	$(RSCRIPT) $<

clean:
	$(RM) *.rds
