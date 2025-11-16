# Pediatric Complex Chronic Condition and Subconditions

Retrieve a copy of internal lookup tables for the syntax valid and human
readable labels of the Pediatric Complex Chronic Conditions (PCCC)
conditions and subconditions.

## Usage

``` r
get_pccc_conditions()
```

## Value

a `data.frame` with the following columns

- `condition`: (character) syntax valid name for the condition

- `subconditions`: (character) syntax valid name for the subcondition

- `conditions_label.`: (character) human readable label for the
  condition

- `subconditions_label`: (character) human readable label for the
  subcondition

## See also

- [`get_pccc_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_pccc_codes.md)
  for the lookup table of ICD codes used for the PCCC.

- [`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
  for applying comorbidity algorithms to a data set.

## Examples

``` r
get_pccc_conditions()
#>          condition                                subcondition
#> 1       malignancy                                   neoplasms
#> 2              cvd                   device_and_technology_use
#> 3             misc                             transplantation
#> 4        neuromusc                  other_neurologic_disorders
#> 5        neuromusc                   device_and_technology_use
#> 6        metabolic                         endocrine_disorders
#> 7               gi                                       other
#> 8      respiratory                                       other
#> 9      respiratory                   device_and_technology_use
#> 10     respiratory                             transplantation
#> 11             cvd        heart_and_great_vessel_malformations
#> 12             cvd                             transplantation
#> 13           renal                   device_and_technology_use
#> 14     hemato_immu                             transplantation
#> 15     hemato_immu                                       other
#> 16              gi                   device_and_technology_use
#> 17              gi                             transplantation
#> 18           renal                                       other
#> 19           renal                             transplantation
#> 20            misc                   device_and_technology_use
#> 21       metabolic                   device_and_technology_use
#> 22     hemato_immu                   acquired_immunodeficiency
#> 23     hemato_immu                                 sarcoidosis
#> 24 congeni_genetic                    bone_and_joint_anomalies
#> 25       metabolic                       amino_acid_metabolism
#> 26       metabolic                     carbohydrate_metabolism
#> 27       metabolic                            lipid_metabolism
#> 28       metabolic                   other_metabolic_disorders
#> 29     respiratory                             cystic_fibrosis
#> 30       metabolic                           storage_disorders
#> 31     hemato_immu                 hereditary_immunodeficiency
#> 32     hemato_immu                          hereditary_anemias
#> 33     hemato_immu                            aplastic_anemias
#> 34     hemato_immu                     coagulation_hemorrhagic
#> 35     hemato_immu                                  leukopenia
#> 36     hemato_immu                    hemophagocytic_syndromes
#> 37       neuromusc                   intellectual_disabilities
#> 38     respiratory                chronic_respiratory_diseases
#> 39       neuromusc               cns_degeneration_and_diseases
#> 40       neuromusc                           movement_diseases
#> 41       neuromusc                    infantile_cerebral_palsy
#> 42           renal                    chronic_bladder_diseases
#> 43       neuromusc                                    epilepsy
#> 44       neuromusc         muscular_dystrophies_and_myopathies
#> 45             cvd                                       other
#> 46             cvd                        endocardium_diseases
#> 47             cvd                            cardiomyopathies
#> 48             cvd                         conduction_disorder
#> 49             cvd                                dysrhythmias
#> 50       neuromusc              occlusion_of_cerebral_arteries
#> 51     hemato_immu polyarteritis_nodosa_and_related_conditions
#> 52 congeni_genetic      diaphragm_and_abdominal_wall_anomalies
#> 53              gi                  inflammatory_bowel_disease
#> 54              gi         chronic_liver_disease_and_cirrhosis
#> 55           renal                       chronic_renal_failure
#> 56     hemato_immu       diffuse_diseases_of_connective_tissue
#> 57       neuromusc         brain_and_spinal_cord_malformations
#> 58     respiratory                   respiratory_malformations
#> 59              gi                        congenital_anomalies
#> 60           renal                        congenital_anomalies
#> 61 congeni_genetic                       chromosomal_anomalies
#> 62 congeni_genetic                  other_congenital_anomalies
#> 63        neonatal                          fetal_malnutrition
#> 64        neonatal                          extreme_immaturity
#> 65        neonatal                cerebral_hemorrhage_at_birth
#> 66        neonatal                 spinal_cord_injury_at_birth
#> 67        neonatal                              birth_asphyxia
#> 68        neonatal             hypoxic_ischemic_encephalopathy
#> 69        neonatal                        respiratory_diseases
#> 70        neonatal                                       other
#> 71      malignancy                             transplantation
#>                            condition_label
#> 1                               Malignancy
#> 2                           Cardiovascular
#> 3  Miscellaneous, Not Elsewhere Classified
#> 4              Neurologic or Neuromuscular
#> 5              Neurologic or Neuromuscular
#> 6                                Metabolic
#> 7                         Gastrointestinal
#> 8                              Respiratory
#> 9                              Respiratory
#> 10                             Respiratory
#> 11                          Cardiovascular
#> 12                          Cardiovascular
#> 13                          Renal Urologic
#> 14              Hematologic or Immunologic
#> 15              Hematologic or Immunologic
#> 16                        Gastrointestinal
#> 17                        Gastrointestinal
#> 18                          Renal Urologic
#> 19                          Renal Urologic
#> 20 Miscellaneous, Not Elsewhere Classified
#> 21                               Metabolic
#> 22              Hematologic or Immunologic
#> 23              Hematologic or Immunologic
#> 24      Other Congenital or Genetic Defect
#> 25                               Metabolic
#> 26                               Metabolic
#> 27                               Metabolic
#> 28                               Metabolic
#> 29                             Respiratory
#> 30                               Metabolic
#> 31              Hematologic or Immunologic
#> 32              Hematologic or Immunologic
#> 33              Hematologic or Immunologic
#> 34              Hematologic or Immunologic
#> 35              Hematologic or Immunologic
#> 36              Hematologic or Immunologic
#> 37             Neurologic or Neuromuscular
#> 38                             Respiratory
#> 39             Neurologic or Neuromuscular
#> 40             Neurologic or Neuromuscular
#> 41             Neurologic or Neuromuscular
#> 42                          Renal Urologic
#> 43             Neurologic or Neuromuscular
#> 44             Neurologic or Neuromuscular
#> 45                          Cardiovascular
#> 46                          Cardiovascular
#> 47                          Cardiovascular
#> 48                          Cardiovascular
#> 49                          Cardiovascular
#> 50             Neurologic or Neuromuscular
#> 51              Hematologic or Immunologic
#> 52      Other Congenital or Genetic Defect
#> 53                        Gastrointestinal
#> 54                        Gastrointestinal
#> 55                          Renal Urologic
#> 56              Hematologic or Immunologic
#> 57             Neurologic or Neuromuscular
#> 58                             Respiratory
#> 59                        Gastrointestinal
#> 60                          Renal Urologic
#> 61      Other Congenital or Genetic Defect
#> 62      Other Congenital or Genetic Defect
#> 63                    Premature & Neonatal
#> 64                    Premature & Neonatal
#> 65                    Premature & Neonatal
#> 66                    Premature & Neonatal
#> 67                    Premature & Neonatal
#> 68                    Premature & Neonatal
#> 69                    Premature & Neonatal
#> 70                    Premature & Neonatal
#> 71                              Malignancy
#>                             subcondition_label
#> 1                                    Neoplasms
#> 2                    Device And Technology Use
#> 3                              Transplantation
#> 4                   Other Neurologic Disorders
#> 5                    Device And Technology Use
#> 6                          Endocrine Disorders
#> 7                                        Other
#> 8                                        Other
#> 9                    Device And Technology Use
#> 10                             Transplantation
#> 11        Heart And Great Vessel Malformations
#> 12                             Transplantation
#> 13                   Device And Technology Use
#> 14                             Transplantation
#> 15                                       Other
#> 16                   Device And Technology Use
#> 17                             Transplantation
#> 18                                       Other
#> 19                             Transplantation
#> 20                   Device And Technology Use
#> 21                   Device And Technology Use
#> 22                   Acquired Immunodeficiency
#> 23                                 Sarcoidosis
#> 24                    Bone And Joint Anomalies
#> 25                       Amino Acid Metabolism
#> 26                     Carbohydrate Metabolism
#> 27                            Lipid Metabolism
#> 28                   Other Metabolic Disorders
#> 29                             Cystic Fibrosis
#> 30                           Storage Disorders
#> 31                 Hereditary Immunodeficiency
#> 32                          Hereditary Anemias
#> 33                            Aplastic Anemias
#> 34                     Coagulation Hemorrhagic
#> 35                                  Leukopenia
#> 36                    Hemophagocytic Syndromes
#> 37                   Intellectual Disabilities
#> 38                Chronic Respiratory Diseases
#> 39               Cns Degeneration And Diseases
#> 40                           Movement Diseases
#> 41                    Infantile Cerebral Palsy
#> 42                    Chronic Bladder Diseases
#> 43                                    Epilepsy
#> 44         Muscular Dystrophies And Myopathies
#> 45                                       Other
#> 46                        Endocardium Diseases
#> 47                            Cardiomyopathies
#> 48                         Conduction Disorder
#> 49                                Dysrhythmias
#> 50              Occlusion Of Cerebral Arteries
#> 51 Polyarteritis Nodosa And Related Conditions
#> 52      Diaphragm And Abdominal Wall Anomalies
#> 53                  Inflammatory Bowel Disease
#> 54         Chronic Liver Disease And Cirrhosis
#> 55                       Chronic Renal Failure
#> 56       Diffuse Diseases Of Connective Tissue
#> 57         Brain And Spinal Cord Malformations
#> 58                   Respiratory Malformations
#> 59                        Congenital Anomalies
#> 60                        Congenital Anomalies
#> 61                       Chromosomal Anomalies
#> 62                  Other Congenital Anomalies
#> 63                          Fetal Malnutrition
#> 64                          Extreme Immaturity
#> 65                Cerebral Hemorrhage At Birth
#> 66                 Spinal Cord Injury At Birth
#> 67                              Birth Asphyxia
#> 68             Hypoxic Ischemic Encephalopathy
#> 69                        Respiratory Diseases
#> 70                                       Other
#> 71                             Transplantation
```
