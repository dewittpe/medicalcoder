library(medicalcoder)

DF <- data.frame(code = c("B", "A"), patid = 1:2)[0, ]

out <- comorbidities(DF, icd.codes = "code", method = "charlson_quan2005")
stopifnot(
  inherits(out, "medicalcoder_comorbidities"),
  inherits(out, "data.frame"),
  nrow(out) == 0L,
  identical(names(out), c("aidshiv", "mal", "cebvd", "copd", "chf", "dem", "dmc", "dm", "hp", "mld", "msld", "mst", "mi", "pud", "pvd", "rnd", "rhd", "num_cmrb", "cmrb_flag", "cci", "age_score"))
)

out <- comorbidities(DF, icd.codes = "code", method = "elixhauser_ahrq2025")
stopifnot(
  inherits(out, "medicalcoder_comorbidities"),
  inherits(out, "data.frame"),
  nrow(out) == 0L,
  identical(
    names(out),
    c("AIDS", "ALCOHOL", "ANEMDEF", "AUTOIMMUNE", "BLDLOSS", "CANCER_LEUK",
      "CANCER_LYMPH", "CANCER_METS", "CANCER_NSITU", "CANCER_SOLID", "CBVD",
      "COAG", "DEMENTIA", "DEPRESS", "DIAB_CX", "DIAB_UNCX", "DRUG_ABUSE", "HF",
      "HTN_CX", "HTN_UNCX", "LIVER_MLD", "LIVER_SEV", "LUNG_CHRONIC",
      "NEURO_MOVT", "NEURO_OTH", "NEURO_SEIZ", "OBESE", "PARALYSIS", "PERIVASC",
      "PSYCHOSES", "PULMCIRC", "RENLFL_MOD", "RENLFL_SEV", "THYROID_HYPO",
      "THYROID_OTH", "ULCER_PEPTIC", "VALVE", "WGHTLOSS", "num_cmrb",
      "cmrb_flag", "mortality_index", "readmission_index")
  )
)

out <- comorbidities(DF, icd.codes = "code", method = "pccc_v3.1")
stopifnot(
  inherits(out, "medicalcoder_comorbidities"),
  inherits(out, "data.frame"),
  nrow(out) == 0L,
  identical(
    names(out),
    c("congeni_genetic_dxpr_only", "congeni_genetic_tech_only",
      "congeni_genetic_dxpr_and_tech", "congeni_genetic_dxpr_or_tech",
      "cvd_dxpr_only", "cvd_tech_only", "cvd_dxpr_and_tech", "cvd_dxpr_or_tech",
      "gi_dxpr_only", "gi_tech_only", "gi_dxpr_and_tech", "gi_dxpr_or_tech",
      "hemato_immu_dxpr_only", "hemato_immu_tech_only",
      "hemato_immu_dxpr_and_tech", "hemato_immu_dxpr_or_tech",
      "malignancy_dxpr_only", "malignancy_tech_only",
      "malignancy_dxpr_and_tech", "malignancy_dxpr_or_tech",
      "metabolic_dxpr_only", "metabolic_tech_only", "metabolic_dxpr_and_tech",
      "metabolic_dxpr_or_tech", "misc_dxpr_only", "misc_tech_only",
      "misc_dxpr_and_tech", "misc_dxpr_or_tech", "neonatal_dxpr_only",
      "neonatal_tech_only", "neonatal_dxpr_and_tech", "neonatal_dxpr_or_tech",
      "neuromusc_dxpr_only", "neuromusc_tech_only", "neuromusc_dxpr_and_tech",
      "neuromusc_dxpr_or_tech", "renal_dxpr_only", "renal_tech_only",
      "renal_dxpr_and_tech", "renal_dxpr_or_tech", "respiratory_dxpr_only",
      "respiratory_tech_only", "respiratory_dxpr_and_tech",
      "respiratory_dxpr_or_tech", "any_tech_dep", "any_transplant", "num_cmrb",
      "cmrb_flag")
  )
)

out <- comorbidities(DF, icd.codes = "code", method = "pccc_v3.1", subconditions = TRUE)
stopifnot(
  inherits(out, "medicalcoder_comorbidities_with_subconditions"),
  inherits(out, "medicalcoder_comorbidities"),
  inherits(out[[1]], "data.frame"),
  inherits(out[[2]], "list"),
  nrow(out[[1]]) == 0L,
  length(out[[2]]) == 11L,
  sapply(out[[2]], nrow) == 0L
)

################################################################################
#                                 End of File                                  #
################################################################################
