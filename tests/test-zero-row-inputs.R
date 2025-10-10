library(medicalcoder)
source('utilities.R')

# Verify that when a data.frame with zero rows is passed to comorbidities() the
# return will be a zero row data.frame with the same general structure that
# would be returned if a data.frame with at least one row was passed to
# comorbidities().

# build a zero-row data.frame for
DF <- data.frame(code = c("B", "A"), patid = 1:2)[0, ]
common_args <-
  list(
    data = DF,
    icd.codes = "code",
    poa = 1,
    primarydx = 0
  )

rtn_charlson <-
  do.call(comorbidities, c(common_args, list(method = "charlson_quan2005")))

rtn_elixhauser <-
  do.call(comorbidities, c(common_args, list(method = "elixhauser_ahrq2025")))

rtn_pccc_v2.1 <-
  do.call(comorbidities, c(common_args, list(method = "pccc_v2.1")))

rtn_pccc_v2.1s <-
  do.call(comorbidities, c(common_args, list(method = "pccc_v2.1", subconditions = TRUE)))

rtn_pccc_v3.1 <-
  do.call(comorbidities, c(common_args, list(method = "pccc_v3.1")))

rtn_pccc_v3.1s <-
  do.call(comorbidities, c(common_args, list(method = "pccc_v3.1", subconditions = TRUE)))

stopifnot(
   inherits(rtn_charlson, "medicalcoder_comorbidities"),
  !inherits(rtn_charlson, "medicalcoder_comorbidities_with_subconditions"),
   inherits(rtn_elixhauser, "medicalcoder_comorbidities"),
  !inherits(rtn_elixhauser, "medicalcoder_comorbidities_with_subconditions"),
   inherits(rtn_pccc_v2.1, "medicalcoder_comorbidities"),
  !inherits(rtn_pccc_v2.1, "medicalcoder_comorbidities_with_subconditions"),
   inherits(rtn_pccc_v2.1s, "medicalcoder_comorbidities"),
   inherits(rtn_pccc_v2.1s, "medicalcoder_comorbidities_with_subconditions"),
   inherits(rtn_pccc_v3.1, "medicalcoder_comorbidities"),
  !inherits(rtn_pccc_v3.1, "medicalcoder_comorbidities_with_subconditions"),
   inherits(rtn_pccc_v3.1s, "medicalcoder_comorbidities"),
   inherits(rtn_pccc_v3.1s, "medicalcoder_comorbidities_with_subconditions"),
   inherits(rtn_charlson, "data.frame"),
   inherits(rtn_elixhauser, "data.frame"),
   inherits(rtn_pccc_v2.1, "data.frame"),
   inherits(rtn_pccc_v2.1s[[1]], "data.frame"),
   inherits(rtn_pccc_v2.1s[[2]], "list"),
   inherits(rtn_pccc_v3.1, "data.frame"),
   inherits(rtn_pccc_v3.1s[[1]], "data.frame"),
   inherits(rtn_pccc_v3.1s[[2]], "list"),
   identical(nrow(rtn_charlson), 0L),
   identical(nrow(rtn_elixhauser), 0L),
   identical(nrow(rtn_pccc_v2.1), 0L),
   identical(nrow(rtn_pccc_v2.1s[[1]]), 0L),
   identical(unname(sapply(rtn_pccc_v2.1s[[2]], nrow)), rep_len(0L, 11L)),
   identical(nrow(rtn_pccc_v3.1), 0L),
   identical(nrow(rtn_pccc_v3.1s[[1]]), 0L),
   identical(unname(sapply(rtn_pccc_v3.1s[[2]], nrow)), rep_len(0L, 11L))
)

expected_charlson_names <-
  c("aidshiv", "mal", "cebvd", "copd", "chf", "dem", "dmc", "dm", "hp", "mld",
    "msld", "mst", "mi", "pud", "pvd", "rnd", "rhd", "num_cmrb", "cmrb_flag",
    "cci", "age_score")

expected_elixhauser_names <-
  c("AIDS", "ALCOHOL", "ANEMDEF", "AUTOIMMUNE", "BLDLOSS", "CANCER_LEUK",
    "CANCER_LYMPH", "CANCER_METS", "CANCER_NSITU", "CANCER_SOLID", "CBVD",
    "COAG", "DEMENTIA", "DEPRESS", "DIAB_CX", "DIAB_UNCX", "DRUG_ABUSE", "HF",
    "HTN_CX", "HTN_UNCX", "LIVER_MLD", "LIVER_SEV", "LUNG_CHRONIC",
    "NEURO_MOVT", "NEURO_OTH", "NEURO_SEIZ", "OBESE", "PARALYSIS", "PERIVASC",
    "PSYCHOSES", "PULMCIRC", "RENLFL_MOD", "RENLFL_SEV", "THYROID_HYPO",
    "THYROID_OTH", "ULCER_PEPTIC", "VALVE", "WGHTLOSS", "num_cmrb", "cmrb_flag",
    "mortality_index", "readmission_index")

expected_pccc_v2.1_names <-
  c("congeni_genetic", "cvd", "gi", "hemato_immu", "malignancy",
    "metabolic", "misc", "neonatal", "neuromusc", "renal", "respiratory",
    "any_tech_dep", "any_transplant", "num_cmrb", "cmrb_flag")

expected_pccc_v3.1_names <-
  c("congeni_genetic_dxpr_only", "congeni_genetic_tech_only",
    "congeni_genetic_dxpr_and_tech", "congeni_genetic_dxpr_or_tech",
    "cvd_dxpr_only", "cvd_tech_only", "cvd_dxpr_and_tech", "cvd_dxpr_or_tech",
    "gi_dxpr_only", "gi_tech_only", "gi_dxpr_and_tech", "gi_dxpr_or_tech",
    "hemato_immu_dxpr_only", "hemato_immu_tech_only",
    "hemato_immu_dxpr_and_tech", "hemato_immu_dxpr_or_tech",
    "malignancy_dxpr_only", "malignancy_tech_only", "malignancy_dxpr_and_tech",
    "malignancy_dxpr_or_tech", "metabolic_dxpr_only", "metabolic_tech_only",
    "metabolic_dxpr_and_tech", "metabolic_dxpr_or_tech", "misc_dxpr_only",
    "misc_tech_only", "misc_dxpr_and_tech", "misc_dxpr_or_tech",
    "neonatal_dxpr_only", "neonatal_tech_only", "neonatal_dxpr_and_tech",
    "neonatal_dxpr_or_tech", "neuromusc_dxpr_only", "neuromusc_tech_only",
    "neuromusc_dxpr_and_tech", "neuromusc_dxpr_or_tech", "renal_dxpr_only",
    "renal_tech_only", "renal_dxpr_and_tech", "renal_dxpr_or_tech",
    "respiratory_dxpr_only", "respiratory_tech_only",
    "respiratory_dxpr_and_tech", "respiratory_dxpr_or_tech", "any_tech_dep",
    "any_transplant", "num_cmrb", "cmrb_flag")

expected_pccc_subcondition_names <-
  list(
    congeni_genetic = c("bone_and_joint_anomalies", "chromosomal_anomalies", "diaphragm_and_abdominal_wall_anomalies", "other_congenital_anomalies"),
    cvd = c("cardiomyopathies", "conduction_disorder", "device_and_technology_use", "dysrhythmias", "endocardium_diseases", "heart_and_great_vessel_malformations", "other", "transplantation"),
    gi = c("chronic_liver_disease_and_cirrhosis", "congenital_anomalies", "device_and_technology_use", "inflammatory_bowel_disease", "other", "transplantation"),
    hemato_immu = c("acquired_immunodeficiency", "aplastic_anemias", "coagulation_hemorrhagic", "diffuse_diseases_of_connective_tissue", "hemophagocytic_syndromes", "hereditary_anemias", "hereditary_immunodeficiency", "leukopenia", "other", "polyarteritis_nodosa_and_related_conditions", "sarcoidosis", "transplantation"),
    malignancy = c("neoplasms", "transplantation"),
    metabolic = c("amino_acid_metabolism", "carbohydrate_metabolism", "device_and_technology_use", "endocrine_disorders", "lipid_metabolism", "other_metabolic_disorders", "storage_disorders"),
    misc = c("device_and_technology_use", "transplantation"),
    neonatal = c("birth_asphyxia", "cerebral_hemorrhage_at_birth", "extreme_immaturity", "fetal_malnutrition", "hypoxic_ischemic_encephalopathy", "other", "respiratory_diseases", "spinal_cord_injury_at_birth"),
    neuromusc = c("brain_and_spinal_cord_malformations", "cns_degeneration_and_diseases", "device_and_technology_use", "epilepsy", "infantile_cerebral_palsy", "intellectual_disabilities", "movement_diseases", "muscular_dystrophies_and_myopathies", "occlusion_of_cerebral_arteries", "other_neurologic_disorders"),
    renal = c("chronic_bladder_diseases", "chronic_renal_failure", "congenital_anomalies", "device_and_technology_use", "other", "transplantation"),
    respiratory = c("chronic_respiratory_diseases", "cystic_fibrosis", "device_and_technology_use", "other", "respiratory_malformations", "transplantation")
  )

stopifnot(
  identical(names(rtn_charlson), expected_charlson_names),
  identical(names(rtn_elixhauser), expected_elixhauser_names),
  identical(names(rtn_pccc_v2.1), expected_pccc_v2.1_names),
  identical(names(rtn_pccc_v2.1s[[1]]), expected_pccc_v2.1_names),
  identical(lapply(rtn_pccc_v2.1s[[2]], names), expected_pccc_subcondition_names),
  identical(names(rtn_pccc_v3.1), expected_pccc_v3.1_names),
  identical(names(rtn_pccc_v3.1s[[1]]), expected_pccc_v3.1_names),
  identical(lapply(rtn_pccc_v3.1s[[2]], names), expected_pccc_subcondition_names)
)

################################################################################
#                                 End of File                                  #
################################################################################
