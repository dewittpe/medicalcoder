# Comorbidities

Apply established comorbidity algorithms to ICD-coded data. Supported
methods include several variants of the Charlson comorbidity system,
Elixhauser, and the Pediatric Complex Chronic Conditions (PCCC).

## Usage

``` r
comorbidities(
  data,
  icd.codes,
  method,
  id.vars = NULL,
  icdv.var = NULL,
  icdv = NULL,
  dx.var = NULL,
  dx = NULL,
  poa.var = NULL,
  poa = NULL,
  age.var = NULL,
  primarydx.var = NULL,
  primarydx = NULL,
  flag.method = c("current", "cumulative"),
  full.codes = TRUE,
  compact.codes = TRUE,
  subconditions = FALSE,
  mapping = c("precomputed", "regex")
)
```

## Arguments

- data:

  A `data.frame` in a "long" format. The input `data.frame` is expected
  to have one column of ICD codes (one code per row) with additional
  (optional) columns for patient/encounter ids, ICD version,
  diagnostic/procedure status, present-on-admission flags, primary
  diagnostic flags, or age.

- icd.codes:

  Character scalar naming the column in `data` that contains ICD codes
  (character strings). Codes may be provided in full form (with decimal
  points, e.g., C84.2), compact form (dots omitted, e.g., C842), or any
  mix of the two. Matching against lookup tables is governed by
  `icdv.var`/`icdv`, `dx.var`/`dx`, and the `full.codes` /
  `compact.codes` flags.

- method:

  Character string indicating the comorbidity algorithm to apply to
  `data`.

- id.vars:

  Optional character vector of column names. When missing, the entire
  input `data` is treated as a single encounter from a single patient.
  If you want to set `flag.method = "cumulative"` then
  `length(id.vars) >= 2` is expected. The last element should be the
  encounter order. It must not contain missing values, must not be a
  factor, and must be numeric, character, `Date`, or `POSIXt`. Character
  encounter order columns are allowed with a warning because they are
  sorted lexicographically.

- icdv.var:

  Character scalar naming the column in `data` that indicates the ICD
  version. If present it must be numeric. Rows with values other than
  `9L` or `10L` will not be used to map ICD codes to comorbidities.
  `icdv.var` takes precedence over `icdv` if both are provided.

- icdv:

  An integer value of `9L` or `10L` indicating that all
  `data[[icd.codes]]` are ICD version 9 or 10, respectively. Ignored
  (with a warning) if `icdv.var` is provided.

- dx.var:

  Character scalar naming the column in `data` that indicates diagnostic
  (`1L`) vs procedural (`0L`) codes. If present it must be numeric. Rows
  with values other than `0L` or `1L` will not be used to map ICD codes
  to comorbidities. `dx.var` takes precedence over `dx` if both are
  provided.

- dx:

  An integer indicating that all `data[[icd.codes]]` are diagnostic
  (`1L`) or procedure (`0L`) codes. Ignored (with a warning) if `dx.var`
  is provided.

- poa.var:

  Character scalar naming the column with present-on-admission flags:
  integer `1L` (present), `0L` (not present), or `NA`. For AHRQ
  SAS-compatible present-on-admission indicators, convert `"Y"` and
  `"W"` to `1L`, convert `"N"` and `"U"` to `0L`, and convert blank or
  missing values to `NA_integer_` before calling `comorbidities()`. PCCC
  and Charlson will only flag conditions when the code is
  present-on-admission. Elixhauser has a mix of conditions; some require
  present-on-admission while others do not. `poa.var` takes precedence
  over `poa` if both are provided.

- poa:

  Integer scalar `0L` or `1L`. Use when all `icd.codes` share the same
  present-on-admission status. Ignored with a warning if `poa` and
  `poa.var` are both provided.

- age.var:

  Character scalar naming the column in `data` that contains patient age
  in years. Only applicable to Charlson comorbidities.

- primarydx.var:

  Character scalar naming the column in `data` that indicates whether
  `data[[icd.codes]]` are primary diagnostic codes (`1L`) or not (`0L`).
  Primary diagnosis is used only for Elixhauser and Charlson
  comorbidities and is ignored when the method is a PCCC variant.
  `primarydx.var` takes precedence over `primarydx` if both are
  provided.

- primarydx:

  An integer value of `0L` or `1L`. If `0L`, treat all codes as
  non-primary diagnoses; if `1L`, treat all codes as primary diagnoses.
  Ignored, with a warning, if `primarydx.var` is provided.

- flag.method:

  When `flag.method = "current"` (default) only codes associated with
  the current `id.vars` are considered when flagging comorbidities. The
  `flag.method = "cumulative"` option also considers prior encounters
  when flagging comorbidities. See **Details**.

- full.codes, compact.codes:

  Logical; when `TRUE` compare `data[[icd.codes]]` against full and/or
  compact ICD codes in the method’s lookup tables. Full ICD codes
  include a decimal point (when applicable) and compact codes omit the
  decimal point. For example: `B95.0` is the full ICD-10-CM diagnostic
  code for “Streptococcus, group A, as the cause of disease classified
  elsewhere,” whereas `B950` is the associated compact code.

- subconditions:

  Logical scalar; when `TRUE`, report both conditions and subconditions
  (PCCC only).

- mapping:

  Character string specifying how `data[[icd.codes]]` should be mapped
  to comorbidity conditions. `mapping = "precomputed"` uses the
  precomputed ICD code-condition links included with medicalcoder and is
  the default. `mapping = "regex"` applies the method's regular
  expressions directly to the input ICD codes. See Details.

## Value

The return object will be slightly different depending on the value of
`method` and `subconditions`.

- When `subconditions = FALSE`, a `medicalcoder_comorbidities` object (a
  `data.frame` with attributes) is returned. Column(s) for `id.vars`, if
  defined in the function call. For all methods there will be the
  following columns:

  - `num_cmrb` a count of comorbidities/conditions flagged

  - `cmrb_flag` a `0L`/`1L` integer indicator for at least one
    comorbidity/condition.

  Additional columns:

  - PCCC methods:

    - For `method = "pccc_v2.0"` and `method = "pccc_v2.1"`, there is
      one indicator column per condition.

    - For `method = "pccc_v3.0"` and `method = "pccc_v3.1"`, there are
      four columns per condition:

      - `<condition>_dxpr_or_tech`: the condition was flagged due to the
        presence of either a diagnostic or procedure code, or was
        flagged due to the presence of a technology dependence code
        along with at least one comorbidity being flagged by a
        diagnostic or procedure code.

      - `<condition>_dxpr_only`: the condition was flagged due to the
        presence of a non-technology-dependent diagnostic or procedure
        code only.

      - `<condition>_tech_only`: the condition was flagged due to the
        presence of a technology-dependent code only and at least one
        other comorbidity was flagged by a non-technology-dependent
        code.

      - `<condition>_dxpr_and_tech`: The patient had both diagnostic or
        procedure codes and a technology dependence code for the
        condition.

  - For Charlson variants, indicator columns are returned for the
    relevant conditions, `cci` (Charlson Comorbidity Index), and
    `age_score`.

  - For Elixhauser variants, indicator columns are returned for all
    relevant comorbidities, mortality, and readmission indices.

- When `subconditions = TRUE` and the method is a PCCC variant, a list
  of length two is returned: the first element contains condition
  indicators; the second element is a named list of `data.frame`s with
  indicators for subconditions within each condition.

## Details

When `flag.method = "current"`, only codes from the index encounter
contribute to flags. The `flag.method = "cumulative"` option lets prior
encounters for the same `id.vars` combination contribute to condition
flags. For the cumulative method to work, `id.vars` needs to be a
character vector of length 2 or more. The last element is treated as the
encounter identifier and must be sortable. For example, say you have
data with a hospital, patient, and encounter id. The `id.vars` could be
one of two entries: `c("hospital", "patient", "encounter")` or
`c("patient", "hospital", "encounter")`. In both cases the return will
be the same because the encounter identifier is unchanged regardless of
whether hospital or patient is listed first.

It is critically important that the `data[[tail(id.vars, 1)]]` variable
can be sorted. Just because your data is sorted in temporal order does
not mean that the results will be correct if the `tail(id.vars, 1)` is
not in the same order as the data. For example, say you had the
following:

|       |          |          |
|-------|----------|----------|
| patid | enc_id   | date     |
| P1    | 10823090 | Aug 2023 |
| P1    | 10725138 | Jul 2025 |

`id.vars = c("patid", "enc_id")` will give the wrong result as enc_id
10725138 would be sorted to come before enc_id 10823090.
`id.vars = c("patid", "date")` would be sufficient input, assuming that
`date` has been correctly stored. Adding a column `enc_seq`, e.g.,

|       |          |          |         |
|-------|----------|----------|---------|
| patid | enc_id   | date     | enc_seq |
| P1    | 10823090 | Aug 2023 | 1       |
| P1    | 10725138 | Jul 2025 | 2       |

and calling `comorbidities()` with `id.vars = c("patid", "enc_seq")`
will have better performance than using the date and will clear up any
possible issues with non-sequential encounter ids from the source data.

For `flag.method = "cumulative"`, the encounter order column must not
contain missing values, must not be a factor, and must be numeric,
character, `Date`, or `POSIXt`. Character encounter order columns are
allowed, but they are sorted lexicographically; use an integer sequence,
`Date`, or `POSIXt` column when possible.

**Cumulative flagging + POA defaults:**

When `flag.method = "cumulative"` and neither `poa` nor `poa.var` is
supplied, the first encounter for a condition is treated as `poa = 0L`.
Subsequent encounters for that condition are flagged as `poa = 1L`.

When `flag.method = "current"` and neither `poa` nor `poa.var` is
supplied, then all codes will be considered present-on-admission. If poa
was assumed to be 0, then in this case the only conditions that could be
flagged are the Elixhauser conditions which are poa-exempt.

The `mapping` option controls how ICD codes are mapped to conditions.
The default, `mapping = "precomputed"`, uses a precomputed table that
links valid ICD codes to comorbidity conditions. Those links are built
from the ICD code sources included with medicalcoder: the United States
Centers for Disease Control and Prevention (CDC), the Centers for
Medicare and Medicaid Services (CMS), the World Health Organization
(WHO), the Independent Health and Aged Care Pricing Authority (IHACPA)
ICD-10 Australian Modification (ICD-10-AM) data, and Socialstyrelsen
ICD-10-SE data.

`mapping = "precomputed"` is generally fastest and is the behavior used
by medicalcoder before the `mapping` argument was added.
`mapping = "regex"` applies the method's regular expressions directly to
the input ICD codes. Regex mapping is currently implemented for Charlson
methods and is useful when codes come from an ICD modification that may
not be completely covered by the precomputed code-condition links, or
when auditing a method.

## References

- Pediatric Complex Chronic Conditions:

  - Feudtner, C., Feinstein, J.A., Zhong, W. et al. Pediatric complex
    chronic conditions classification system version 2: updated for
    ICD-10 and complex medical technology dependence and
    transplantation. BMC Pediatr 14, 199 (2014).
    https://doi.org/10.1186/1471-2431-14-199

  - Feinstein JA, Hall M, Davidson A, Feudtner C. Pediatric Complex
    Chronic Condition System Version 3. JAMA Netw Open.
    2024;7(7):e2420579.
    https://doi.org/10.1001/jamanetworkopen.2024.20579

- Charlson Comorbidities:

  - Mary E. Charlson, Peter Pompei, Kathy L. Ales, C.Ronald MacKenzie, A
    new method of classifying prognostic comorbidity in longitudinal
    studies: Development and validation, Journal of Chronic Diseases,
    Volume 40, Issue 5, 1987, Pages 373-383, ISSN 0021-9681,
    https://doi.org/10.1016/0021-9681(87)90171-8.

  - Deyo RA, Cherkin DC, Ciol MA. Adapting a clinical comorbidity index
    for use with ICD-9-CM administrative databases. J Clin Epidemiol.
    1992 Jun;45(6):613-9. https://doi.org/10.1016/0895-4356(92)90133-8.
    PMID: 1607900.

  - Sundararajan V, Henderson T, Perry C, Muggivan A, Quan H, Ghali WA.
    New ICD-10 version of the Charlson comorbidity index predicted
    in-hospital mortality. J Clin Epidemiol. 2004 Dec;57(12):1288-94.
    https://doi.org/10.1016/j.jclinepi.2004.03.012. PMID: 15617955.

  - Quan H, Sundararajan V, Halfon P, Fong A, Burnand B, Luthi JC,
    Saunders LD, Beck CA, Feasby TE, Ghali WA. Coding algorithms for
    defining comorbidities in ICD-9-CM and ICD-10 administrative data.
    Med Care. 2005 Nov;43(11):1130-9.
    https://doi.org/10.1097/01.mlr.0000182534.19832.83. PMID: 16224307.

  - Quan H, Li B, Couris CM, Fushimi K, Graham P, Hider P, Januel JM,
    Sundararajan V. Updating and validating the Charlson comorbidity
    index and score for risk adjustment in hospital discharge abstracts
    using data from 6 countries. Am J Epidemiol. 2011 Mar
    15;173(6):676-82. https://doi.org/10.1093/aje/kwq433. Epub 2011
    Feb 17. PMID: 21330339.

  - Glasheen WP, Cordier T, Gumpina R, Haugh G, Davis J, Renda A.
    Charlson Comorbidity Index: ICD-9 Update and ICD-10 Translation. Am
    Health Drug Benefits. 2019 Jun-Jul;12(4):188-197. PMID: 31428236;
    PMCID: PMC6684052.

  - Ludvigsson JF, Appelros P, Askling J, et al. Adaptation of the
    Charlson Comorbidity Index for Register-Based Research in Sweden.
    Clin Epidemiol. 2021;13:21-41. https://doi.org/10.2147/CLEP.S282475.

  - Ludvigsson JF, Appelros P, Askling J, et al. Adaptation of the
    Charlson Comorbidity Index for Register-Based Research in Sweden
    \[Corrigendum\]. Clin Epidemiol. 2023;15:753-754.
    https://doi.org/10.2147/CLEP.S420607.

- Elixhauser Comorbidities:

  - Agency for Healthcare Research and Quality (AHRQ). Elixhauser
    Comorbidity Software Refined for ICD-10-CM Diagnoses, v2026.1
    \[Internet\]. 2026. Available from:
    https://www.hcup-us.ahrq.gov/toolssoftware/comorbidityicd10/comorbidity_icd10.jsp

## See also

- `vignettes(topic = "comorbidities", package = "medicalcoder")`

- `vignettes(topic = "pccc", package = "medicalcoder")`

- `vignettes(topic = "charlson", package = "medicalcoder")`

- `vignettes(topic = "elixhauser", package = "medicalcoder")`

## Examples

``` r
pccc_v3.1_results <-
  comorbidities(data = mdcr,
                icd.codes = "code",
                id.vars = "patid",
                dx.var = "dx",
                method = "pccc_v3.1",
                flag.method = 'current',
                poa = 1L)
summary(pccc_v3.1_results)
#>          condition                                   label dxpr_or_tech_count
#> 1  congeni_genetic      Other Congenital or Genetic Defect               3225
#> 2              cvd                          Cardiovascular               5147
#> 3               gi                        Gastrointestinal               5652
#> 4      hemato_immu              Hematologic or Immunologic               2832
#> 5       malignancy                              Malignancy               3784
#> 6        metabolic                               Metabolic               3407
#> 7             misc Miscellaneous, Not Elsewhere Classified                764
#> 8         neonatal                    Premature & Neonatal               1516
#> 9        neuromusc             Neurologic or Neuromuscular               5828
#> 10           renal                          Renal Urologic               2787
#> 11     respiratory                             Respiratory               3260
#> 12    any_tech_dep               Any Technology Dependence               7012
#> 13  any_transplant                     Any Transplantation               1585
#> 14       cmrb_flag                           Any Condition              20871
#> 15        num_cmrb                         >= 2 conditions              10657
#> 16        num_cmrb                         >= 3 conditions               4582
#> 17        num_cmrb                         >= 4 conditions               1571
#> 18        num_cmrb                         >= 5 conditions                418
#> 19        num_cmrb                         >= 6 conditions                 88
#> 20        num_cmrb                         >= 7 conditions                 13
#> 21        num_cmrb                         >= 8 conditions                  2
#> 22        num_cmrb                         >= 9 conditions                  0
#> 23        num_cmrb                        >= 10 conditions                  0
#> 24        num_cmrb                        >= 11 conditions                  0
#>    dxpr_or_tech_percent dxpr_only_count dxpr_only_percent tech_only_count
#> 1           8.428728242            3225         8.4287282               0
#> 2          13.451988919            4560        11.9178297             283
#> 3          14.771836287            1420         3.7112540            3855
#> 4           7.401599498            2832         7.4015995               0
#> 5           9.889707804            3784         9.8897078               0
#> 6           8.904396006            3356         8.7711045              40
#> 7           1.996759187             121         0.3162407             643
#> 8           3.962155664            1516         3.9621557               0
#> 9          15.231822696            4564        11.9282839             316
#> 10          7.283989337            1876         4.9030370             555
#> 11          8.520202812            1848         4.8298573             755
#> 12         18.326276724              NA                NA              NA
#> 13          4.142491245              NA                NA              NA
#> 14         54.547592912              NA                NA              NA
#> 15         27.852699807              NA                NA              NA
#> 16         11.975328002              NA                NA              NA
#> 17          4.105901417              NA                NA              NA
#> 18          1.092467723              NA                NA              NA
#> 19          0.229993205              NA                NA              NA
#> 20          0.033976269              NA                NA              NA
#> 21          0.005227118              NA                NA              NA
#> 22          0.000000000              NA                NA              NA
#> 23          0.000000000              NA                NA              NA
#> 24          0.000000000              NA                NA              NA
#>    tech_only_percent dxpr_and_tech_count dxpr_and_tech_percent
#> 1          0.0000000                   0            0.00000000
#> 2          0.7396372                 304            0.79452198
#> 3         10.0752705                 377            0.98531180
#> 4          0.0000000                   0            0.00000000
#> 5          0.0000000                   0            0.00000000
#> 6          0.1045424                  11            0.02874915
#> 7          1.6805185                   0            0.00000000
#> 8          0.0000000                   0            0.00000000
#> 9          0.8258847                 948            2.47765407
#> 10         1.4505253                 356            0.93042706
#> 11         1.9732372                 657            1.71710836
#> 12                NA                  NA                    NA
#> 13                NA                  NA                    NA
#> 14                NA                  NA                    NA
#> 15                NA                  NA                    NA
#> 16                NA                  NA                    NA
#> 17                NA                  NA                    NA
#> 18                NA                  NA                    NA
#> 19                NA                  NA                    NA
#> 20                NA                  NA                    NA
#> 21                NA                  NA                    NA
#> 22                NA                  NA                    NA
#> 23                NA                  NA                    NA
#> 24                NA                  NA                    NA

pccc_v3.1_subcondition_results <-
  comorbidities(data = mdcr,
                icd.codes = "code",
                id.vars = "patid",
                dx.var = "dx",
                method = "pccc_v3.1",
                flag.method = 'current',
                poa = 1L,
                subconditions = TRUE)
summary(pccc_v3.1_subcondition_results)
#>          condition                                subcondition count
#> 1  congeni_genetic                                        <NA>  3225
#> 2  congeni_genetic                    bone_and_joint_anomalies   825
#> 3  congeni_genetic                       chromosomal_anomalies  1544
#> 4  congeni_genetic      diaphragm_and_abdominal_wall_anomalies   300
#> 5  congeni_genetic                  other_congenital_anomalies   754
#> 6              cvd                                        <NA>  5147
#> 7              cvd                            cardiomyopathies   240
#> 8              cvd                         conduction_disorder   653
#> 9              cvd                   device_and_technology_use   587
#> 10             cvd                                dysrhythmias  1130
#> 11             cvd                        endocardium_diseases   278
#> 12             cvd        heart_and_great_vessel_malformations  2320
#> 13             cvd                                       other  1247
#> 14             cvd                             transplantation   271
#> 15              gi                                        <NA>  5652
#> 16              gi         chronic_liver_disease_and_cirrhosis   290
#> 17              gi                        congenital_anomalies   709
#> 18              gi                   device_and_technology_use  4232
#> 19              gi                  inflammatory_bowel_disease   264
#> 20              gi                                       other   295
#> 21              gi                             transplantation   343
#> 22     hemato_immu                                        <NA>  2832
#> 23     hemato_immu                   acquired_immunodeficiency    11
#> 24     hemato_immu                            aplastic_anemias   823
#> 25     hemato_immu                     coagulation_hemorrhagic   100
#> 26     hemato_immu       diffuse_diseases_of_connective_tissue   125
#> 27     hemato_immu                    hemophagocytic_syndromes    59
#> 28     hemato_immu                          hereditary_anemias   771
#> 29     hemato_immu                 hereditary_immunodeficiency   909
#> 30     hemato_immu                                  leukopenia    28
#> 31     hemato_immu                                       other    12
#> 32     hemato_immu polyarteritis_nodosa_and_related_conditions    46
#> 33     hemato_immu                                 sarcoidosis     3
#> 34     hemato_immu                             transplantation   181
#> 35      malignancy                                        <NA>  3784
#> 36      malignancy                                   neoplasms  3525
#> 37      malignancy                             transplantation   452
#> 38       metabolic                                        <NA>  3407
#> 39       metabolic                       amino_acid_metabolism   194
#> 40       metabolic                     carbohydrate_metabolism   130
#> 41       metabolic                   device_and_technology_use    51
#> 42       metabolic                         endocrine_disorders   884
#> 43       metabolic                            lipid_metabolism   354
#> 44       metabolic                   other_metabolic_disorders  1870
#> 45       metabolic                           storage_disorders    82
#> 46            misc                                        <NA>   764
#> 47            misc                   device_and_technology_use   643
#> 48            misc                             transplantation   121
#> 49        neonatal                                        <NA>  1516
#> 50        neonatal                              birth_asphyxia    11
#> 51        neonatal                cerebral_hemorrhage_at_birth    84
#> 52        neonatal                          extreme_immaturity   349
#> 53        neonatal                          fetal_malnutrition    45
#> 54        neonatal             hypoxic_ischemic_encephalopathy   130
#> 55        neonatal                                       other   247
#> 56        neonatal                        respiratory_diseases   950
#> 57        neonatal                 spinal_cord_injury_at_birth     0
#> 58       neuromusc                                        <NA>  5828
#> 59       neuromusc         brain_and_spinal_cord_malformations  1767
#> 60       neuromusc               cns_degeneration_and_diseases  1474
#> 61       neuromusc                   device_and_technology_use  1264
#> 62       neuromusc                                    epilepsy   833
#> 63       neuromusc                    infantile_cerebral_palsy  1322
#> 64       neuromusc                   intellectual_disabilities   161
#> 65       neuromusc                           movement_diseases   146
#> 66       neuromusc         muscular_dystrophies_and_myopathies   147
#> 67       neuromusc              occlusion_of_cerebral_arteries    92
#> 68       neuromusc                  other_neurologic_disorders   848
#> 69           renal                                        <NA>  2787
#> 70           renal                    chronic_bladder_diseases   519
#> 71           renal                       chronic_renal_failure   627
#> 72           renal                        congenital_anomalies   915
#> 73           renal                   device_and_technology_use   911
#> 74           renal                                       other   217
#> 75           renal                             transplantation   322
#> 76     respiratory                                        <NA>  3260
#> 77     respiratory                chronic_respiratory_diseases  1092
#> 78     respiratory                             cystic_fibrosis   400
#> 79     respiratory                   device_and_technology_use  1412
#> 80     respiratory                                       other    22
#> 81     respiratory                   respiratory_malformations  1091
#> 82     respiratory                             transplantation    39
#>    percent_of_cohort percent_of_those_with_condition
#> 1        8.428728242                              NA
#> 2        2.156186294                      25.5813953
#> 3        4.035335320                      47.8759690
#> 4        0.784067743                       9.3023256
#> 5        1.970623595                      23.3798450
#> 6       13.451988919                              NA
#> 7        0.627254195                       4.6629104
#> 8        1.706654122                      12.6870021
#> 9        1.534159218                      11.4047018
#> 10       2.953321834                      21.9545366
#> 11       0.726569442                       5.4012046
#> 12       6.063457216                      45.0748009
#> 13       3.259108254                      24.2277055
#> 14       0.708274528                       5.2652030
#> 15      14.771836287                              NA
#> 16       0.757932152                       5.1309271
#> 17       1.853013434                      12.5442321
#> 18      11.060582301                      74.8761500
#> 19       0.689979614                       4.6709130
#> 20       0.770999948                       5.2193914
#> 21       0.896450787                       6.0686483
#> 22       7.401599498                              NA
#> 23       0.028749151                       0.3884181
#> 24       2.150959176                      29.0607345
#> 25       0.261355914                       3.5310734
#> 26       0.326694893                       4.4138418
#> 27       0.154199990                       2.0833333
#> 28       2.015054101                      27.2245763
#> 29       2.375725263                      32.0974576
#> 30       0.073179656                       0.9887006
#> 31       0.031362710                       0.4237288
#> 32       0.120223721                       1.6242938
#> 33       0.007840677                       0.1059322
#> 34       0.473054205                       6.3912429
#> 35       9.889707804                              NA
#> 36       9.212795986                      93.1553911
#> 37       1.181328733                      11.9450317
#> 38       8.904396006                              NA
#> 39       0.507030474                       5.6941591
#> 40       0.339762689                       3.8156736
#> 41       0.133291516                       1.4969181
#> 42       2.310386284                      25.9465806
#> 43       0.925199937                      10.3903728
#> 44       4.887355601                      54.8869974
#> 45       0.214311850                       2.4068095
#> 46       1.996759187                              NA
#> 47       1.680518530                      84.1623037
#> 48       0.316240657                      15.8376963
#> 49       3.962155664                              NA
#> 50       0.028749151                       0.7255937
#> 51       0.219538968                       5.5408971
#> 52       0.912132142                      23.0211082
#> 53       0.117610162                       2.9683377
#> 54       0.339762689                       8.5751979
#> 55       0.645549109                      16.2928760
#> 56       2.482881188                      62.6649077
#> 57       0.000000000                              NA
#> 58      15.231822696                              NA
#> 59       4.618159009                      30.3191489
#> 60       3.852386179                      25.2916953
#> 61       3.303538759                      21.6884008
#> 62       2.177094768                      14.2930679
#> 63       3.455125189                      22.6835964
#> 64       0.420783022                       2.7625257
#> 65       0.381579635                       2.5051476
#> 66       0.384193194                       2.5223061
#> 67       0.240447441                       1.5785861
#> 68       2.216298155                      14.5504461
#> 69       7.283989337                              NA
#> 70       1.356437196                      18.6221744
#> 71       1.638701584                      22.4973089
#> 72       2.391406618                      32.8310011
#> 73       2.380952381                      32.6874776
#> 74       0.567142334                       7.7861500
#> 75       0.841566045                      11.5536419
#> 76       8.520202812                              NA
#> 77       2.854006586                      33.4969325
#> 78       1.045423658                      12.2699387
#> 79       3.690345513                      43.3128834
#> 80       0.057498301                       0.6748466
#> 81       2.851393027                      33.4662577
#> 82       0.101928807                       1.1963190

charlson_results <-
  comorbidities(data = mdcr,
                icd.codes = "code",
                id.vars = "patid",
                dx.var = "dx",
                method = "charlson_quan2011",
                flag.method = 'current',
                poa = 1L)
#> Warning: Assuming all codes provided are secondary diagnostic codes.  Define `primarydx.var` or `primarydx` if this assumption is incorrect.
summary(charlson_results)
#> $conditions
#>                     condition_description condition count      percent
#> 1                                AIDS/HIV   aidshiv     7  0.018294914
#> 2                          Any malignancy       mal  2301  6.013799592
#> 3                 Cerebrovascular disease     cebvd   411  1.074172809
#> 4               Chronic pulmonary disease      copd  3415  8.925304480
#> 5                Congestive heart failure       chf   684  1.787674455
#> 6                                Dementia       dem    13  0.033976269
#> 7     Diabetes with chronic complications       dmc    13  0.033976269
#> 8  Diabetes without chronic complications        dm   441  1.152579583
#> 9                Hemiplegia or paraplegia        hp  1177  3.076159113
#> 10                    Liver disease, mild       mld   593  1.549840573
#> 11      Liver disease, moderate to severe      msld   206  0.538393184
#> 12                 Metastatic solid tumor       mst   453  1.183942293
#> 13                  Myocardial infarction        mi    10  0.026135591
#> 14                   Peptic ulcer disease       pud    45  0.117610162
#> 15            Peripheral vascular disease       pvd   217  0.567142334
#> 16                          Renal disease       rnd   898  2.346976112
#> 17                      Rheumatic disease       rhd   136  0.355444044
#> 18                                   >= 1      <NA>  9841 25.720035544
#> 19                                   >= 2      <NA>  1075  2.809576081
#> 20                                   >= 3      <NA>    94  0.245674560
#> 21                                   >= 4      <NA>     9  0.023522032
#> 22                                   >= 5      <NA>     1  0.002613559
#> 
#> $age_summary
#>   age_score count percent
#> 1      <NA> 38262     100
#> 
#> $index_summary
#>   min q1 median q3 max
#> 1   0  0      0  0  10
#> 

elixhauser_results <-
  comorbidities(data = mdcr,
                icd.codes = "code",
                id.vars = "patid",
                dx.var = "dx",
                method = "elixhauser_ahrq2025",
                primarydx = 1L,
                flag.method = 'current',
                poa = 1L)
summary(elixhauser_results)
#> $conditions
#>       condition count percent
#> 1          AIDS     0       0
#> 2       ALCOHOL     0       0
#> 3       ANEMDEF     0       0
#> 4    AUTOIMMUNE     0       0
#> 5       BLDLOSS     0       0
#> 6   CANCER_LEUK     0       0
#> 7  CANCER_LYMPH     0       0
#> 8   CANCER_METS     0       0
#> 9  CANCER_NSITU     0       0
#> 10 CANCER_SOLID     0       0
#> 11         CBVD     0       0
#> 12         COAG     0       0
#> 13     DEMENTIA     0       0
#> 14      DEPRESS     0       0
#> 15      DIAB_CX     0       0
#> 16    DIAB_UNCX     0       0
#> 17   DRUG_ABUSE     0       0
#> 18           HF     0       0
#> 19       HTN_CX     0       0
#> 20     HTN_UNCX     0       0
#> 21    LIVER_MLD     0       0
#> 22    LIVER_SEV     0       0
#> 23 LUNG_CHRONIC     0       0
#> 24   NEURO_MOVT     0       0
#> 25    NEURO_OTH     0       0
#> 26   NEURO_SEIZ     0       0
#> 27        OBESE     0       0
#> 28    PARALYSIS     0       0
#> 29     PERIVASC     0       0
#> 30    PSYCHOSES     0       0
#> 31     PULMCIRC     0       0
#> 32   RENLFL_MOD     0       0
#> 33   RENLFL_SEV     0       0
#> 34 THYROID_HYPO     0       0
#> 35  THYROID_OTH     0       0
#> 36 ULCER_PEPTIC     0       0
#> 37        VALVE     0       0
#> 38     WGHTLOSS     0       0
#> 39         >= 1     0       0
#> 
#> $index_summary
#>         index min q1 median q3 max
#> 1 readmission   0  0      0  0   0
#> 2   mortality   0  0      0  0   0
#> 
```
