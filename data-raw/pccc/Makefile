include ../../Makevars

.INTERMEDIATE: pccc_v2.0.rds pccc_v2_subconditions.rds pccc_v2.0.rds pccc_v2.1.rds pccc_v2_r_sas_stata.rds pccc_v2_subconditions.rds pccc_v3.0.rds pccc_v3.1.rds

.PHONY: all clean

all: pccc_codes.rds pccc_conditions.rds

pccc_v2.0.rds: pccc_v2.0.R pccc_v2_subconditions.rds | ../icd/icd_codes.rds
	$(RSCRIPT) $<

pccc_v2.1.rds: pccc_v2.1.R pccc_v2.0.rds pccc_v2_subconditions.rds pccc_v2_r_sas_stata.rds | ../icd/icd_codes.rds
	$(RSCRIPT) $<

pccc_v3.0.rds pccc_v3.1.rds &: pccc_v3.R
	$(RSCRIPT) $<

pccc_v2_subconditions.rds: pccc_v2_subconditions.R | ../icd/icd_codes.rds
	$(RSCRIPT) $<

pccc_v2_r_sas_stata.rds: pccc_v2_r_sas_stata.R
	$(RSCRIPT) $<

pccc_codes.rds pccc_conditions.rds &: pccc_codes.R pccc_v2.0.rds pccc_v2.1.rds pccc_v3.0.rds pccc_v3.1.rds | ../icd/icd_codes.rds
	$(RSCRIPT) $<

clean:
	$(RM) *.rds
