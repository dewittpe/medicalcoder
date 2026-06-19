# Pediatric Complex Chronic Conditions

``` r

library(medicalcoder)
```

## Introduction

The Pediatric Complex Chronic Condition (PCCC) coding schema version 2
was published in 2014 (Feudtner et al. 2014) and updated to version 3 in
2024 (Feinstein et al. 2024). Both versions identify 11 conditions, each
with multiple subconditions.

|     | condition       | condition_label                         |
|:----|:----------------|:----------------------------------------|
| 1   | congeni_genetic | Other Congenital or Genetic Defect      |
| 2   | cvd             | Cardiovascular                          |
| 3   | gi              | Gastrointestinal                        |
| 4   | hemato_immu     | Hematologic or Immunologic              |
| 5   | malignancy      | Malignancy                              |
| 6   | metabolic       | Metabolic                               |
| 7   | misc            | Miscellaneous, Not Elsewhere Classified |
| 8   | neonatal        | Premature & Neonatal                    |
| 9   | neuromusc       | Neurologic or Neuromuscular             |
| 10  | renal           | Renal Urologic                          |
| 11  | respiratory     | Respiratory                             |

Syntactically valid names for complex chronic conditions {.table .table
.table-striped
style="font-size: 10px; width: auto !important; margin-left: auto; margin-right: auto;"}

The PCCC system provides a standardized approach to identifying children
with complex chronic conditions using administrative data. This has
several important implications:

- **Research comparability**: Standard definitions allow findings to be
  compared across studies and institutions.
- **Policy and planning**: Accurate identification of populations with
  high medical needs supports resource allocation and health policy
  decisions.
- **Clinical insight**: Coding consistency helps clinicians and
  researchers understand disease burden and outcomes in pediatric
  populations.

Without a common framework such as the PCCC, studies of chronic
pediatric conditions would be fragmented, limiting their impact on both
research and practice.

## PCCC Version 2.0 vs PCCC Version 3.0

Versions 2 and 3 differ mainly in how technology dependence is treated.
Many ICD codes map to both a primary condition and either technology
dependence or transplant.

In both versions, transplant-related codes indicate organ system
failure. A patient with such a code is flagged as having both a
transplant and the related condition.

Technology dependence, however, diverges between versions. In version 2,
the presence of a technology dependence code classifies the patient as
having both the associated condition and technology dependence. For
example, ICD-10 Z46.81 is both a metabolic and technology dependence
code. A patient with this code is classified as having a metabolic
condition and technology dependence.

Version 3 refines this rule: technology dependence codes are assessed
conditionally, recognizing that many do not reflect chronic conditions.

Example: ICD-10 Z46.81 (Encounter for fitting and adjustment of insulin
pump) is a metabolic and technology dependence code. If a patient had
this code in their medical records then they would be classified as
having a metabolic condition and a tech dependence. Under version 2,
this patient would be flagged as having a metabolic condition and
technology dependence. Under version 3, the patient would only be
flagged with a metabolic condition and technology dependence if at least
one non-technology condition is flagged.

### ICD Codes for PCCC

Let’s look at the codes that are in the PCCC schema. Calling
[`get_pccc_codes()`](http://www.peteredewitt.com/medicalcoder/reference/get_pccc_codes.md)
returns a data.frame.

``` r

pccc_codes <- get_pccc_codes()
str(pccc_codes)
## 'data.frame':    7906 obs. of  12 variables:
##  $ icdv           : int  9 9 9 9 9 9 9 9 9 9 ...
##  $ dx             : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ full_code      : chr  "00.10" "00.50" "00.51" "00.53" ...
##  $ code           : chr  "0010" "0050" "0051" "0053" ...
##  $ condition      : chr  "malignancy" "cvd" "cvd" "cvd" ...
##  $ subcondition   : chr  "neoplasms" "device_and_technology_use" "device_and_technology_use" "device_and_technology_use" ...
##  $ transplant_flag: int  0 0 0 0 0 0 0 1 1 1 ...
##  $ tech_dep_flag  : int  0 1 1 1 1 1 1 0 0 0 ...
##  $ pccc_v3.1      : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ pccc_v3.0      : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ pccc_v2.1      : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ pccc_v2.0      : int  1 1 1 1 1 1 1 1 1 1 ...
```

The columns are:

- `icdv`: integer, ICD version
- `dx`: 1 for diagnostic (ICD-9-CM or ICD-10-CM) codes, 0 for procedure
  (ICD-9-PCS or ICD-10-PCS) codes.
- `full_code`: character, the ICD code retaining any applicable decimal
  point.
- `code`: character, the compact ICD code; any applicable decimal point
  omitted. Examples: ICD-9-CM full code 553.3 is represented as 5533 as
  a compact code. ICD-10-CM full code C96.9 is represented as compact
  code C969.
- `condition`: character, the pccc condition with syntactically valid
  names.
- `subcondition`: character, the pccc subcondition with syntactically
  valid names.
- `transplant_flag`: integer, 1L if the ICD code is associated with a
  transplant, 0L otherwise
- `tech_dep_flag`: integer, 1L if the ICD code is associated with
  technology dependence, 0L otherwise.
- `pccc_vX.Y`: integer, 1L if the code is part of variant `X.Y`, 0L
  otherwise

### Examples

Example: Consider a patient with the following four diagnostic and two
procedure ICD-9 codes:

``` r

pat1 <-
  data.frame(
    dx = c(1, 1, 1, 1, 0, 0),
    icdv = 9L,
    code = c("34590", "78065", "3432", "78065", "9929", "8606")
  )
```

An inner join between the `pccc_codes` and `pat1` will yield the
conditions this patient has.

``` r

merge(x = pccc_codes, y = pat1, all = FALSE, by = c("icdv", "dx", "code"))
##   icdv dx code full_code condition              subcondition transplant_flag
## 1    9  0 8606     86.06 metabolic device_and_technology_use               0
## 2    9  1 3432     343.2 neuromusc  infantile_cerebral_palsy               0
##   tech_dep_flag pccc_v3.1 pccc_v3.0 pccc_v2.1 pccc_v2.0
## 1             1         1         1         1         1
## 2             0         1         1         1         1
```

For all PCCC variants, there is one matching dx code, 343.2, for
infantile cerebral palsy, which matches a neuromuscular condition. The
procedure code 86.06 matches a technology-dependent metabolic condition.

Under version 2.0 of PCCC (variants `pccc_v2.0` and `pccc_v2.1`), this
patient has two conditions: neuromuscular and metabolic. This patient
also has a flag for device and technology use.

``` r

pat1_pccc_v2.0 <-
  comorbidities(
    data = pat1,
    icd.codes = "code",
    dx.var = "dx",
    icdv = 9,
    method = "pccc_v2.0",
    flag.method = "current", # default
    poa = 1                  # default for flag.method = 'current'
  )

pat1_pccc_v2.1 <-
  comorbidities(
    data = pat1,
    icd.codes = "code",
    dx.var = "dx",
    icdv = 9,
    method = "pccc_v2.1",
    flag.method = "current",
    poa = 1
  )

all.equal(pat1_pccc_v2.0, pat1_pccc_v2.1, check.attributes = FALSE)
## [1] TRUE
pat1_pccc_v2.1
## 
## Comorbidities via pccc_v2.1
## 
##   congeni_genetic cvd gi hemato_immu malignancy metabolic misc neonatal
## 1               0   0  0           0          0         1    0        0
##   neuromusc renal respiratory any_tech_dep any_transplant num_cmrb cmrb_flag
## 1         1     0           0            1              0        2         1
```

Under version 3 of the PCCC, this patient has two conditions:
neuromuscular and metabolic. The technology dependence flags are also 1
for this patient, but are not counted in the total number of conditions.

``` r

pat1_pccc_v3.0 <-
  comorbidities(
    data = pat1,
    icd.codes = "code",
    dx.var = "dx",
    icdv = 9,
    method = "pccc_v3.0",
    flag.method = 'current',
    poa = 1
  )

pat1_pccc_v3.1 <-
  comorbidities(
    data = pat1,
    icd.codes = "code",
    dx.var = "dx",
    icdv = 9,
    method = "pccc_v3.1",
    flag.method = 'current',
    poa = 1
  )

all.equal(pat1_pccc_v3.0, pat1_pccc_v3.1, check.attributes = FALSE)
## [1] TRUE

# retain the needed columns, there are four columns for each condition in v3
pat1_pccc_v3.0[, grep("^(cmrb_flag|num_cmrb|neuromus|metabolic|tech_dep_flag)", names(pat1_pccc_v3.0))]
##   metabolic_dxpr_only metabolic_tech_only metabolic_dxpr_and_tech
## 1                   0                   1                       0
##   metabolic_dxpr_or_tech neuromusc_dxpr_only neuromusc_tech_only
## 1                      1                   1                   0
##   neuromusc_dxpr_and_tech neuromusc_dxpr_or_tech num_cmrb cmrb_flag
## 1                       0                      1        2         1
```

In the output from version 3, we have four 0/1 indicator columns for
each of the conditions.

- `<condition>_dxpr_only`: the `<condition>` has been flagged due to
  diagnostic

  510. or procedure (pr) codes only.

- `<condition>_tech_only`: the `<condition>` has been flagged due to the
  presence of a technology dependence code *and* at least one other
  condition has been flagged by dx or pr codes.

- `<condition>_dxpr_and_tech`: the `<condition>` has been flagged due to
  the presence of a dx or pr code that is not associated with a
  technology dependence *and* another dx or pr code which is associated
  with technology dependence.

- `<condition>_dxpr_or_tech`: the `<condition>` has been flagged.
  **These columns answer the question “does `<condition>` exist for this
  patient/encounter.”**

The details in the list above might be easier to understand in a tabular
form of possible sets. In the case of no conditions, only the
`<condition>_dxpr_or_tech` columns are flagged as 0/1 with the
`<condition>_dxpr_only`, `<condition>_tech_only`, and
`<condition>_dxpr_and_tech` columns set to `NA`. When at least one
condition is flagged, all the columns will be populated as 0/1.

[TABLE]

Now, consider another patient, pat2, with the same codes as pat1 except
for 3432, the code mapping to a neuromuscular condition.

``` r

pat2 <- subset(pat1, code != "3432")
```

Under version 2 of the PCCC this patient will still have metabolic and
technology dependence conditions because of the code 86.06 is in the
record, but will not have the neuromuscular condition.

``` r

pat2_pccc_v2.1 <-
  comorbidities(
    data = pat2,
    icd.codes = "code",
    dx.var = "dx",
    icdv = 9,
    method = "pccc_v2.1",
    flag.method = 'current',
    poa = 1
  )
Filter(f = function(x) x > 0, pat2_pccc_v2.1)
##   metabolic any_tech_dep num_cmrb cmrb_flag
## 1         1            1        1         1
```

Under version 3 of the PCCC, this patient will have no conditions. This
is because no condition was identified based on non-technology dependent
codes and thus the one technology dependent code is ignored.

``` r

pat2_pccc_v3.1 <-
  comorbidities(
    data = pat2,
    icd.codes = "code",
    dx.var = "dx",
    icdv = 9,
    method = "pccc_v3.1",
    flag.method = 'current',
    poa = 1
  )
Filter(f = function(x) x > 0, pat2_pccc_v3.1)
## data frame with 0 columns and 1 row
```

## Expected Data Structures

The expected input data format for
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
is a “long” format. The only mandatory column is one column of ICD
codes. These codes can be full codes (include the decimal point) or
compact codes (omitting the decimal point). Additionally, column(s) for
identifying patients, encounters, and any other important groups are
encouraged. A column to indicate the ICD version (9 or 10), and another
column for identifying the code as a diagnostic or procedure code are
also encouraged. The example `mdcr` data set has three columns, a
patient id (patid), the ICD compact codes (code), and a column to
indicate if the ICD code is a diagnostic or procedure code, (dx: 1 for
diagnostic, 0 for procedure).

The `mdcr` data is provided with columns for

- patient id,
- ICD version,
- compact code, and
- diagnostic/procedure indicator.

``` r

head(mdcr)
##   patid icdv  code dx
## 1 71412    9 99931  1
## 2 71412    9 75169  1
## 3 71412    9 99591  1
## 4 71412    9 V5865  1
## 5 71412    9  V427  1
## 6 17087   10  V441  1
str(mdcr)
## 'data.frame':    319856 obs. of  4 variables:
##  $ patid: int  71412 71412 71412 71412 71412 17087 64424 64424 84361 84361 ...
##  $ icdv : int  9 9 9 9 9 10 9 9 9 9 ...
##  $ code : chr  "99931" "75169" "99591" "V5865" ...
##  $ dx   : int  1 1 1 1 1 1 1 0 1 1 ...
```

## Assessing PCCC

### Ignoring ICD Version and diagnostic/procedure codes

Applying `pccc_v2.1` and `pccc_v3.1` methods to `mdcr` without
accounting for ICD version or the diagnostic/procedure status of the
code can be done as follows:

``` r

mdcr_results_v2.1_01 <-
  comorbidities(
    data = mdcr,
    icd.codes = "code",
    id.vars = "patid",
    poa = 1,
    flag.method = 'current',
    method = "pccc_v2.1"
  )

mdcr_results_v3.1_01 <-
  comorbidities(
    data = mdcr,
    icd.codes = "code",
    id.vars = "patid",
    poa = 1,
    flag.method = 'current',
    method = "pccc_v3.1"
  )
```

A useful summary of the object returned from
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
is gained by calling [`summary()`](https://rdrr.io/r/base/summary.html).
The return is a `data.frame` with columns for the count and percentages.
For `pccc_v2.0` and `pccc_v2.1` the condition, label, count, and
percentage, are reported. For `pccc_v3.0` and `pccc_v3.1` the columns
are extended to provide the counts and percentages for `_dxpr_or_tech`,
`_dxpr_only`, `_tech_only`, and `_dxpr_and_tech`.

``` r

str(summary(mdcr_results_v2.1_01))
## 'data.frame':    24 obs. of  4 variables:
##  $ condition: chr  "congeni_genetic" "cvd" "gi" "hemato_immu" ...
##  $ label    : chr  "Other Congenital or Genetic Defect" "Cardiovascular" "Gastrointestinal" "Hematologic or Immunologic" ...
##  $ count    : int  3490 5034 6946 2887 4057 3348 1079 1572 5968 3033 ...
##  $ percent  : num  9.12 13.16 18.15 7.55 10.6 ...
str(summary(mdcr_results_v3.1_01))
## 'data.frame':    24 obs. of  10 variables:
##  $ condition            : chr  "congeni_genetic" "cvd" "gi" "hemato_immu" ...
##  $ label                : chr  "Other Congenital or Genetic Defect" "Cardiovascular" "Gastrointestinal" "Hematologic or Immunologic" ...
##  $ dxpr_or_tech_count   : int  3225 5185 5808 2943 4075 3466 774 1529 5917 2933 ...
##  $ dxpr_or_tech_percent : num  8.43 13.55 15.18 7.69 10.65 ...
##  $ dxpr_only_count      : int  3225 4526 1520 2943 4075 3415 126 1529 4605 1991 ...
##  $ dxpr_only_percent    : num  8.43 11.83 3.97 7.69 10.65 ...
##  $ tech_only_count      : int  0 318 3897 0 0 40 647 0 359 580 ...
##  $ tech_only_percent    : num  0 0.831 10.185 0 0 ...
##  $ dxpr_and_tech_count  : int  0 341 391 0 0 11 1 0 953 362 ...
##  $ dxpr_and_tech_percent: num  0 0.891 1.022 0 0 ...
```

Since the summary tables are `data.frame`s the end user may manipulate
the results for reporting as they want, see the following table.

``` r

x <-
  merge(
    summary(mdcr_results_v2.1_01),
    summary(mdcr_results_v3.1_01),
    all = TRUE,
    by = c("condition", "label"),
    sort = FALSE
  )
x[["condition"]] <- NULL
```

[TABLE]

Summary Table for `mdcr_results_v2.1_01` and `mdcr_results_v3.1_01`.
{.table .table .table-striped
style="font-size: 10px; margin-left: auto; margin-right: auto;"}

### Accounting for Diagnostic/Procedure

There are additional details we should consider with respect to the ICD
codes. The ICD version, 9 or 10, and if the code is a diagnostic or a
procedure code. For example, code ICD-9 diagnostic code 332.1 has the
same compact code as ICD-9 procedure code 33.21, 3321. In the case of
the `mdcr` data where we have only compact codes, the need to
distinguish between ICD-9 diagnostic and ICD-9 procedure is critically
important. In the `mdcr` data the code 3321 does appear as both
diagnostic and procedure.

``` r

pccc_codes[pccc_codes$code == "3321", ]
##      icdv dx full_code code   condition              subcondition
## 59      9  0     33.21 3321 respiratory device_and_technology_use
## 1453    9  1     332.1 3321   neuromusc         movement_diseases
##      transplant_flag tech_dep_flag pccc_v3.1 pccc_v3.0 pccc_v2.1 pccc_v2.0
## 59                 0             1         1         1         1         1
## 1453               0             0         1         1         1         1
table(mdcr[mdcr$code == "3321", "dx"])
## 
##  0  1 
## 77  1
```

To account for the diagnostic or procedure status of the codes specify a
value for the `dx.var` argument.

``` r

mdcr_results_v2.1_02 <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    dx.var = "dx",
    flag.method = 'current',
    poa = 1,
    method = "pccc_v2.1"
  )

mdcr_results_v3.1_02 <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    dx.var = "dx",
    flag.method = 'current',
    poa = 1,
    method = "pccc_v3.1"
  )
```

Specificity is increased by using the diagnostic/procedure flag. Using
`pccc_v2.1` there are 278 false positive flags when the
diagnostic/procedure flag is omitted from the
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
call. Using `pccc_v3.1` there are 256 false positive flags when the
diagnostic/procedure flag is omitted from the
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
call.

``` r

# verify that the cmrb_flag and number of conditions is the same or less after
# accounting for the diagnostic/procedure flag in the comorbidities call
stopifnot(all(mdcr_results_v2.1_02$cmrb_flag <= mdcr_results_v2.1_01$cmrb_flag))
stopifnot(all(mdcr_results_v2.1_02$num_cmrb  <= mdcr_results_v2.1_01$num_cmrb))

sum(mdcr_results_v2.1_02$cmrb_flag != mdcr_results_v2.1_01$cmrb_flag)
## [1] 278
sum(mdcr_results_v2.1_02$num_cmrb  != mdcr_results_v2.1_01$num_cmrb)
## [1] 989

stopifnot(all(mdcr_results_v3.1_02$cmrb_flag <= mdcr_results_v3.1_01$cmrb_flag))
stopifnot(all(mdcr_results_v3.1_02$num_cmrb  <= mdcr_results_v3.1_01$num_cmrb))

sum(mdcr_results_v3.1_02$cmrb_flag != mdcr_results_v3.1_01$cmrb_flag)
## [1] 256
sum(mdcr_results_v3.1_02$num_cmrb  != mdcr_results_v3.1_01$num_cmrb)
## [1] 923
```

Let’s explore the record for patient 87420.

``` r

subset(mdcr, patid == "87420")
##      patid icdv  code dx
## 4073 87420    9 78321  1
## 4074 87420    9  5641  1
subset(get_pccc_codes(), code %in% c("78321", "5641"))
##     icdv dx full_code code condition subcondition transplant_flag tech_dep_flag
## 185    9  0     56.41 5641     renal        other               0             0
##     pccc_v3.1 pccc_v3.0 pccc_v2.1 pccc_v2.0
## 185         1         1         1         1
```

``` r

subset(mdcr_results_v2.1_01, patid == "87420", select = c("cmrb_flag", "renal"))
##       cmrb_flag renal
## 32849         1     1
subset(mdcr_results_v2.1_02, patid == "87420", select = c("cmrb_flag", "renal"))
##       cmrb_flag renal
## 32849         0     0

subset(mdcr_results_v3.1_01, patid == "87420", select = c("cmrb_flag", "renal_dxpr_or_tech"))
##       cmrb_flag renal_dxpr_or_tech
## 32849         1                  1
subset(mdcr_results_v3.1_02, patid == "87420", select = c("cmrb_flag", "renal_dxpr_or_tech"))
##       cmrb_flag renal_dxpr_or_tech
## 32849         0                  0

subset(get_icd_codes(with.descriptions = TRUE), full_code %in% c("56.41", "564.1"))
##       icdv dx full_code code src known_start known_end assignable_start
## 17502    9  0     56.41 5641 cdc        1997      2012             1997
## 17503    9  0     56.41 5641 cms        2006      2015             2006
## 17504    9  1     564.1 5641 cdc        1997      2012             1997
## 17505    9  1     564.1 5641 cms        2006      2015             2006
## 17506    9  1     564.1 5641 cdc        1997      2012             1997
##       assignable_end                     desc desc_start desc_end
## 17502           2012     Partial ureterectomy       1997     2012
## 17503           2015     Partial ureterectomy       2010     2015
## 17504           2012 Irritable bowel syndrome       2001     2012
## 17505           2015 Irritable bowel syndrome       2010     2015
## 17506           2012          Irritable colon       1997     1999
```

In the above, the compact code “5641” matches procedure code 56.41 for a
renal condition. In `mdcr_results_v2.1_01` and `mdcr_results_v3.1_01`
where no distinction was made between diagnostic and procedure codes
this patient was flagged as having a renal condition. However, when
reviewing the patient record, the compact code “5641” is listed as a
diagnostic criteria and the full code 564.1 is for Irritable bowel
syndrome. This is an example of where discriminating between diagnostic
and procedure codes is critically important when looking for complex
chronic conditions.

If we explicitly look at an inner join between this patient’s data and
the pccc lookup table we see that the code 5641 matches the procedure
code in the pccc lookup table. By not accounting for diagnostic and
procedure codes, the overlaps between the two coding structures can lead
to false positives.

``` r

merge(
  x = subset(mdcr, patid == "87420"),
  y = pccc_codes,
  by.x = c("code"),
  by.y = c("code"),
  suffixes = c(".mdcr", ".pccc_codes")
)
##   code patid icdv.mdcr dx.mdcr icdv.pccc_codes dx.pccc_codes full_code
## 1 5641 87420         9       1               9             0     56.41
##   condition subcondition transplant_flag tech_dep_flag pccc_v3.1 pccc_v3.0
## 1     renal        other               0             0         1         1
##   pccc_v2.1 pccc_v2.0
## 1         1         1
```

### Full and Compact ICD codes

Using full codes can prevent false positives too. Here are several
different ways that
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
could be called resulting in different outcomes.

Note: this is a good example of how medicalcoder can handle full and
compact codes within a single record.

``` r

DF <-
  data.frame(
    id = c("full dx", "full pr", "compact dx", "compact pr"),
    code = c("564.1", "56.41", "5641", "5641"),
    dx = c(1, 0, 1, 0)
  )

# ideal: using the dx/pr status and matching on full and compact codes.
comorbidities(
  data = DF,
  id.vars = "id",
  dx.var = "dx",
  icd.codes = "code",
  poa = 1,
  method = "pccc_v3.1"
)[, c("id", "cmrb_flag", "renal_dxpr_or_tech")]
##           id cmrb_flag renal_dxpr_or_tech
## 1 compact dx         0                  0
## 2 compact pr         1                  1
## 3    full dx         0                  0
## 4    full pr         1                  1

# false positive for the compact dx
comorbidities(
  data = DF,
  id.vars = "id",
  icd.codes = "code",
  poa = 1,
  method = "pccc_v3.1"
)[, c("id", "cmrb_flag", "renal_dxpr_or_tech")]
##           id cmrb_flag renal_dxpr_or_tech
## 1 compact dx         1                  1
## 2 compact pr         1                  1
## 3    full dx         0                  0
## 4    full pr         1                  1

# false negative for compact pr
comorbidities(
  data = DF,
  id.vars = "id",
  icd.codes = "code",
  poa = 1,
  full.code = TRUE,
  compact.codes = FALSE,
  method = "pccc_v3.1"
)[, c("id", "cmrb_flag", "renal_dxpr_or_tech")]
##           id cmrb_flag renal_dxpr_or_tech
## 1 compact dx         0                  0
## 2 compact pr         0                  0
## 3    full dx         0                  0
## 4    full pr         1                  1

# false positive for compact dx
comorbidities(
  data = DF,
  id.vars = "id",
  icd.codes = "code",
  poa = 1,
  full.code = FALSE,
  compact.codes = TRUE,
  method = "pccc_v3.1"
)[, c("id", "cmrb_flag", "renal_dxpr_or_tech")]
##           id cmrb_flag renal_dxpr_or_tech
## 1 compact dx         1                  1
## 2 compact pr         1                  1
## 3    full dx         0                  0
## 4    full pr         0                  0

# false negatives for compact and full pr
comorbidities(
  data = DF,
  id.vars = "id",
  icd.codes = "code",
  dx.var = "dx",
  poa = 1,
  full.code = FALSE,
  compact.codes = TRUE,
  method = "pccc_v3.1"
)[, c("id", "cmrb_flag", "renal_dxpr_or_tech")]
##           id cmrb_flag renal_dxpr_or_tech
## 1 compact dx         0                  0
## 2 compact pr         1                  1
## 3    full dx         0                  0
## 4    full pr         0                  0
```

### Accounting for ICD Version

Another consideration is the version of ICD, 9 or 10.

The record for patid 95471 is a great example of the problem that a
compact code can cause. “E030” matches ICD-9 dx compact and full code
E030 (no decimal point), and matches the ICD-10 dx compact code for full
code E03.0 with only the ICD-10 version being related to a chronic
complex condition.

Inputs to the
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
call for the ICD version will impact the output. When calling
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
with a variable to indicate the ICD version `NA` values will not be
joined against and the codes are ignored resulting in no condition being
flagged. If we know that we only want to compare against ICD-9 or ICD-10
values then using the `icdv` argument can simplify the call and in this
case, no condition for ICD-9 and a condition is flagged for ICD-10.

``` r

subset(mdcr, patid == "95471")
##        patid icdv code dx
## 125330 95471   10 E030  1

# no flag becuse icdv = 9 which treats all input codes as ICD-9
comorbidities(
  data = subset(mdcr, patid == "95471"),
  icd.codes = "code",
  id.vars = 'patid',
  dx.var = "dx",
  icdv = 9L,
  poa = 1,
  method = "pccc_v3.1"
)[, c('patid', 'cmrb_flag')]
##   patid cmrb_flag
## 1 95471         0

# flag because icdv = 10 - same as using `icdv.var = "icdv"`
comorbidities(
  data = subset(mdcr, patid == "95471"),
  icd.codes = "code",
  id.vars = 'patid',
  dx.var = "dx",
  icdv = 10L,
  poa = 1,
  method = "pccc_v3.1"
)[, c('patid', 'cmrb_flag')]
##   patid cmrb_flag
## 1 95471         1

comorbidities(
  data = subset(mdcr, patid == "95471"),
  icd.codes = "code",
  id.vars = 'patid',
  dx.var = "dx",
  icdv.var = "icdv",
  poa = 1,
  method = "pccc_v3.0"
)[, c('patid', 'cmrb_flag')]
##   patid cmrb_flag
## 1 95471         1
```

Lastly, it should be noted that a lot of the ambiguity resulting from
compact codes can be avoided when full codes are available. medicalcoder
can handle both forms. In the example below we again use the “E030” and
assess it against all full and compact codes (default), against only
full codes, and lastly against only compact codes. Note in this example
that we are not specifying the ICD version nor the diagnostic/procedure
status of the code.

``` r

lookup_icd_codes("E030")
##   input_code   match_type icdv dx full_code code src known_start known_end
## 1       E030    full_code    9  1      E030 E030 cdc        2010      2012
## 2       E030    full_code    9  1      E030 E030 cms        2010      2015
## 3       E030 compact_code   10  1     E03.0 E030 cdc        2001      2025
## 4       E030 compact_code   10  1     E03.0 E030 cms        2014      2026
## 5       E030 compact_code   10  1     E03.0 E030 who        2008      2019
##   assignable_start assignable_end
## 1             2010           2012
## 2             2010           2015
## 3             2001           2025
## 4             2014           2026
## 5             2008           2019
data <- data.frame(id = c("Ambiguous compact code", "Full ICD-9 code", "Full ICD-10 code"),
                   code  = c("E030", "E030", "E03.0"))
data
##                       id  code
## 1 Ambiguous compact code  E030
## 2        Full ICD-9 code  E030
## 3       Full ICD-10 code E03.0

args <-
  list(
    data = data,
    id.vars = "id",
    icd.codes = "code",
    poa = 1,
    method = "pccc_v3.1"
  )

default <-
  do.call(comorbidities, c(args, list(full.codes = TRUE,  compact.codes = TRUE )))
full_only <-
  do.call(comorbidities, c(args, list(full.codes = TRUE,  compact.codes = FALSE)))
compact_only <-
  do.call(comorbidities, c(args, list(full.codes = FALSE, compact.codes = TRUE )))

default[,       c("id", "cmrb_flag")]
##                       id cmrb_flag
## 1 Ambiguous compact code         1
## 2       Full ICD-10 code         1
## 3        Full ICD-9 code         1
full_only[,     c("id", "cmrb_flag")]
##                       id cmrb_flag
## 1 Ambiguous compact code         0
## 2       Full ICD-10 code         1
## 3        Full ICD-9 code         0
compact_only[,  c("id", "cmrb_flag")]
##                       id cmrb_flag
## 1 Ambiguous compact code         1
## 2       Full ICD-10 code         0
## 3        Full ICD-9 code         1
```

With no information about the “E030” being ICD-9 or ICD-10, full or
compact, (can only be a diagnostic code in either ICD-9 or ICD-10) we
get different flags. The default, the most liberal approach flags this
example patient as having a condition in all cases. When only
considering the code to be a full code, then only the ICD-10 version
matches. When only considering the compact codes the flag is true for
the ambiguous version and the ICD-9 full version since ICD-9 E030 is a
full code with the same compact form.

## Longitudinal Conditions

The medicalcoder package includes the example data set,
`mdcr_longitudinal`, with ICD-9 and ICD-10 codes for 3 synthetic
patients with multiple encounters. Each row has a date (encounter) for
when the ICD code was reported.

``` r

head(mdcr_longitudinal)
##     patid       date icdv     code
## 1 9663901 2016-03-18   10   Z77.22
## 2 9663901 2016-03-24   10  IMO0002
## 3 9663901 2016-03-24   10 V87.7XXA
## 4 9663901 2016-03-25   10  J95.851
## 5 9663901 2016-03-30   10  IMO0002
## 6 9663901 2016-03-30   10    Z93.0
```

### PCCC V2

Let’s look at the `pccc_v2.1` flags for each patient, using all the
information from all the encounters. This can easily be done by
specifying `id.vars = c("patid")` such that the
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
method considers all codes as occurring on one encounter.

``` r

longitudinal_v2_patid <-
  comorbidities(
    data = mdcr_longitudinal,
    icd.codes = "code",
    id.vars = c("patid"),
    icdv.var = "icdv",
    method = "pccc_v2.1",
    flag.method = "current",
    poa = 1
  )
tab <- kableExtra::kbl(longitudinal_v2_patid)
tab <- kableExtra::kable_styling(tab, bootstrap_options = c("striped"), font_size = 10)
tab
```

| patid | congeni_genetic | cvd | gi | hemato_immu | malignancy | metabolic | misc | neonatal | neuromusc | renal | respiratory | any_tech_dep | any_transplant | num_cmrb | cmrb_flag |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 231597 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 1 | 1 | 1 | 1 | 1 | 4 | 1 |
| 650838 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 0 | 1 | 0 | 5 | 1 |
| 9663901 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 1 | 0 | 3 | 1 |

We can look at the conditions flagged at each encounter by specifying
the `id.vars = c("patid", "date")`.

``` r

longitudinal_v2_patid_date <-
  comorbidities(data = mdcr_longitudinal,
    icd.codes = "code",
    id.vars = c("patid", "date"),
    icdv.var = "icdv",
    method = "pccc_v2.1",
    flag.method = "current",
    poa = 1
  )
```

| patid | date | congeni_genetic | cvd | gi | hemato_immu | malignancy | metabolic | misc | neonatal | neuromusc | renal | respiratory | any_tech_dep | any_transplant | num_cmrb | cmrb_flag |
|---:|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 9663901 | 2016-03-18 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 9663901 | 2016-03-24 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 9663901 | 2016-03-25 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 9663901 | 2016-03-30 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 2 | 1 |
| 9663901 | 2016-05-19 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 9663901 | 2016-07-09 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 1 | 0 | 2 | 1 |
| 9663901 | 2017-01-31 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 9663901 | 2017-02-16 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 9663901 | 2018-03-29 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 1 | 1 |

Looking at patid 9663901 at an encounter level we see that the
conditions occur at different moments in time and the condition the
patient has change overtime. Because these are chronic conditions, once
the condition is observed, it should be considered to exist in
perpetuity.

For `pccc_v2.1` a simple carry-forward method can be applied to the data
set to mark the presence of a condition at the time of reporting and
thereafter.

``` r

longitudinal_v2_patid_date_cumulative_poa0 <-
  comorbidities(
    data = mdcr_longitudinal,
    icd.codes = "code",
    id.vars = c("patid", "date"),
    icdv.var = "icdv",
    method = "pccc_v2.1",
    flag.method = "cumulative",
    poa = 0
  )
```

| patid | date | congeni_genetic | cvd | gi | hemato_immu | malignancy | metabolic | misc | neonatal | neuromusc | renal | respiratory | any_tech_dep | any_transplant | num_cmrb | cmrb_flag |
|---:|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 9663901 | 2016-03-18 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 9663901 | 2016-03-24 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 9663901 | 2016-03-25 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 9663901 | 2016-03-30 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 9663901 | 2016-05-19 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 2 | 1 |
| 9663901 | 2016-07-09 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 2 | 1 |
| 9663901 | 2017-01-31 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 1 | 0 | 3 | 1 |
| 9663901 | 2017-02-16 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 1 | 0 | 3 | 1 |
| 9663901 | 2018-03-29 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 1 | 0 | 3 | 1 |

``` r

longitudinal_v2_patid_date_cumulative_poa1 <-
  comorbidities(
    data = mdcr_longitudinal,
    icd.codes = "code",
    id.vars = c("patid", "date"),
    icdv.var = "icdv",
    method = "pccc_v2.1",
    flag.method = "cumulative",
    poa = 1
  )
```

| patid | date | congeni_genetic | cvd | gi | hemato_immu | malignancy | metabolic | misc | neonatal | neuromusc | renal | respiratory | any_tech_dep | any_transplant | num_cmrb | cmrb_flag |
|---:|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 9663901 | 2016-03-18 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 9663901 | 2016-03-24 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 9663901 | 2016-03-25 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 9663901 | 2016-03-30 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 2 | 1 |
| 9663901 | 2016-05-19 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 2 | 1 |
| 9663901 | 2016-07-09 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 1 | 0 | 3 | 1 |
| 9663901 | 2017-01-31 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 1 | 0 | 3 | 1 |
| 9663901 | 2017-02-16 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 1 | 0 | 3 | 1 |
| 9663901 | 2018-03-29 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 1 | 0 | 3 | 1 |

### PCCC V3

For `pccc_v3.0` and `pccc_v3.1` a simple carry-forward method would not
be easy to use as information about technology dependent codes is
omitted when non-technology dependent codes do not exist.

Let’s use three ICD-10 diagnostic codes for this example and we will
explore all six possible permutations of the codes. We’ll generate a
data set with seven encounters and one code appearing on each of
encounters 2, 4, and 6.

The codes we’ll use are:

- H49.811: metabolic (other metabolic disorders),
- J84.111: respiratory (chronic respiratory diseases), and
- Z96.41: metabolic (device and technology use).

``` r

codes <- c("H49.811", "J84.111", "Z96.41")
subset(get_pccc_codes(), full_code %in% codes)
##      icdv dx full_code   code   condition                 subcondition
## 6438   10  1   H49.811 H49811   metabolic    other_metabolic_disorders
## 6705   10  1   J84.111 J84111 respiratory chronic_respiratory_diseases
## 7898   10  1    Z96.41  Z9641   metabolic    device_and_technology_use
##      transplant_flag tech_dep_flag pccc_v3.1 pccc_v3.0 pccc_v2.1 pccc_v2.0
## 6438               0             0         1         1         1         1
## 6705               0             0         1         1         0         0
## 7898               0             1         1         1         1         1
```

The constructed data and permutations are:

``` r

permutations <-
  data.table::data.table(
    permutation = rep(1:6, each = 7),
    encounter_id = rep(1:7, times = 6),
    code =
      codes[c(NA, 1, NA, 2, NA, 3, NA,
              NA, 1, NA, 3, NA, 2, NA,
              NA, 2, NA, 1, NA, 3, NA,
              NA, 2, NA, 3, NA, 1, NA,
              NA, 3, NA, 1, NA, 2, NA,
              NA, 3, NA, 2, NA, 1, NA)]
  )

permutations[, plabel := paste(na.omit(code), collapse = ", "), by = .(permutation)]
permutations[, plabel := paste0("Permutation ", permutation, ": ", plabel)]
str(permutations, vec.len = 1)
## Classes 'data.table' and 'data.frame':   42 obs. of  4 variables:
##  $ permutation : int  1 1 ...
##  $ encounter_id: int  1 2 ...
##  $ code        : chr  NA ...
##  $ plabel      : chr  "Permutation 1: H49.811, J84.111, Z96.41" ...
##  - attr(*, ".internal.selfref")=<pointer: 0x564718ed2ee0>
```

- Permutation 1: H49.811, J84.111, Z96.41
- Permutation 2: H49.811, Z96.41, J84.111
- Permutation 3: J84.111, H49.811, Z96.41
- Permutation 4: J84.111, Z96.41, H49.811
- Permutation 5: Z96.41, H49.811, J84.111
- Permutation 6: Z96.41, J84.111, H49.811

We’ll apply the `pccc_v3.1` to this code set with
`flag.method = "cumulative"` and all codes considered to be
present-on-admission.

``` r

rtn <-
  comorbidities(
    data = permutations,
    icd.codes = "code",
    id.vars = c("permutation", "plabel", "encounter_id"),
    icdv = 10L,
    compact.codes = FALSE,
    method = "pccc_v3.1",
    flag.method = "cumulative",
    poa = 1
  )
```

Let’s walk through the results for each permutation.

**Permutation 1**

[TABLE]

The first code to appear in this permutation is H49.811, metabolic
(other). This is a diagnostic code and will flag the metabolic condition
for encounters 2 through 7 as `_dxpr_or_tech`. The Z96.41 code,
metabolic (tech), appears on encounter 6. Thus, for encounters 2 through
5 metabolic should be flagged as `_dxpr_or_tech = 1`, `dxpr_only = 1`,
`tech_only = 0`, and `dxpr_and_tech = 0`. Encounters 6 and 7 then have
`dxpr_only = 0` and `tech_only = 0` with `dxpr_and_tech = 1`. The
J84.111 for respiratory is a non-tech code appearing on encounter 4 and
should flag as `dxpr_or_tech = 1`, `dxpr_only = 1`, `tech_only = 0`, and
`dxpr_and_tech = 0` for encounters 4 through 7.

**Permutation 2**

[TABLE]

As with permutation 1, having the non-tech dependent metabolic code
H49.811 appearing on encounter 2 means that metabolic is flagged for
encounters 2 through 7. What should differ is that `dxpr_only` is 1 for
encounters 2 and 3, with `dxpr_and_tech` flagging for encounters 4
through 7. Lastly, the non-tech code J84.111 for respiratory condition
flagging as `dxpr_or_tech = dxpr_only = 1` for encounters 6 and 7.

**Permutation 3**

[TABLE]

Permutation three has respiratory flagged for encounters 2 through 7.
The non-tech metabolic code on encounter 4 results in the flagging of
metabolic for encounters 4 through 7.

**Permutation 4**

[TABLE]

Permutation 4 is notable as presence of the respiratory condition on
encounters 2 through 7 means that when the technology dependent
metabolic code appears on encounter 4, a metabolic is flagged for
encounters 4 through 7. Compare this with permutations 5 and 6.

**Permutation 5**

[TABLE]

For permutation 5 the first code is a tech dependent metabolic code on
encounter 2. Because the *only* code for flagging a condition is a
technology dependent code the PCCC version 3 algorithm results in *no*
condition being flagged for encounters 2 and 3. On encounter 4, when the
non-tech metabolic code appears then the metabolic condition is flagged
and the past history of the technology dependent code persists.

**Permutation 6**

[TABLE]

As with permutation 5, since the only code in the record for encounter 2
and 3 is the technology dependent metabolic code, there is no flagged
condition. On encounter 4, when the dxpr code for a respiratory
condition is reported then the respiratory condition *and* the metabolic
condition is flagged as technology dependent. Note that technology only
conditions are flagged if at least one other condition is flagged.

## Subconditions

The documentation for PCCC version 2 (Feudtner et al. 2014) and version
3 (Feinstein et al. 2024) include subconditions under each of the major
conditions. However, to our knowledge, no software prior to medicalcoder
implemented flagging for the subconditions.

The subconditions for each condition are shown in the next table.

| subcondition | subcondition_label |
|----|----|
| **congeni_genetic: Other Congenital or Genetic Defect** |  |
| bone_and_joint_anomalies | Bone And Joint Anomalies |
| chromosomal_anomalies | Chromosomal Anomalies |
| diaphragm_and_abdominal_wall_anomalies | Diaphragm And Abdominal Wall Anomalies |
| other_congenital_anomalies | Other Congenital Anomalies |
| **cvd: Cardiovascular** |  |
| cardiomyopathies | Cardiomyopathies |
| conduction_disorder | Conduction Disorder |
| device_and_technology_use | Device And Technology Use |
| dysrhythmias | Dysrhythmias |
| endocardium_diseases | Endocardium Diseases |
| heart_and_great_vessel_malformations | Heart And Great Vessel Malformations |
| other | Other |
| transplantation | Transplantation |
| **gi: Gastrointestinal** |  |
| chronic_liver_disease_and_cirrhosis | Chronic Liver Disease And Cirrhosis |
| congenital_anomalies | Congenital Anomalies |
| device_and_technology_use | Device And Technology Use |
| inflammatory_bowel_disease | Inflammatory Bowel Disease |
| other | Other |
| transplantation | Transplantation |
| **hemato_immu: Hematologic or Immunologic** |  |
| acquired_immunodeficiency | Acquired Immunodeficiency |
| aplastic_anemias | Aplastic Anemias |
| coagulation_hemorrhagic | Coagulation Hemorrhagic |
| diffuse_diseases_of_connective_tissue | Diffuse Diseases Of Connective Tissue |
| hemophagocytic_syndromes | Hemophagocytic Syndromes |
| hereditary_anemias | Hereditary Anemias |
| hereditary_immunodeficiency | Hereditary Immunodeficiency |
| leukopenia | Leukopenia |
| other | Other |
| polyarteritis_nodosa_and_related_conditions | Polyarteritis Nodosa And Related Conditions |
| sarcoidosis | Sarcoidosis |
| transplantation | Transplantation |
| **malignancy: Malignancy** |  |
| neoplasms | Neoplasms |
| transplantation | Transplantation |
| **metabolic: Metabolic** |  |
| amino_acid_metabolism | Amino Acid Metabolism |
| carbohydrate_metabolism | Carbohydrate Metabolism |
| device_and_technology_use | Device And Technology Use |
| endocrine_disorders | Endocrine Disorders |
| lipid_metabolism | Lipid Metabolism |
| other_metabolic_disorders | Other Metabolic Disorders |
| storage_disorders | Storage Disorders |
| **misc: Miscellaneous, Not Elsewhere Classified** |  |
| device_and_technology_use | Device And Technology Use |
| transplantation | Transplantation |
| **neonatal: Premature & Neonatal** |  |
| birth_asphyxia | Birth Asphyxia |
| cerebral_hemorrhage_at_birth | Cerebral Hemorrhage At Birth |
| extreme_immaturity | Extreme Immaturity |
| fetal_malnutrition | Fetal Malnutrition |
| hypoxic_ischemic_encephalopathy | Hypoxic Ischemic Encephalopathy |
| other | Other |
| respiratory_diseases | Respiratory Diseases |
| spinal_cord_injury_at_birth | Spinal Cord Injury At Birth |
| **neuromusc: Neurologic or Neuromuscular** |  |
| brain_and_spinal_cord_malformations | Brain And Spinal Cord Malformations |
| cns_degeneration_and_diseases | Cns Degeneration And Diseases |
| device_and_technology_use | Device And Technology Use |
| epilepsy | Epilepsy |
| infantile_cerebral_palsy | Infantile Cerebral Palsy |
| intellectual_disabilities | Intellectual Disabilities |
| movement_diseases | Movement Diseases |
| muscular_dystrophies_and_myopathies | Muscular Dystrophies And Myopathies |
| occlusion_of_cerebral_arteries | Occlusion Of Cerebral Arteries |
| other_neurologic_disorders | Other Neurologic Disorders |
| **renal: Renal Urologic** |  |
| chronic_bladder_diseases | Chronic Bladder Diseases |
| chronic_renal_failure | Chronic Renal Failure |
| congenital_anomalies | Congenital Anomalies |
| device_and_technology_use | Device And Technology Use |
| other | Other |
| transplantation | Transplantation |
| **respiratory: Respiratory** |  |
| chronic_respiratory_diseases | Chronic Respiratory Diseases |
| cystic_fibrosis | Cystic Fibrosis |
| device_and_technology_use | Device And Technology Use |
| other | Other |
| respiratory_malformations | Respiratory Malformations |
| transplantation | Transplantation |

To get the subconditions all you need to do is use the
`subconditions = TRUE` argument in the
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
call. For this example we will apply `pccc_v3.1` with and without
comorbidities.

``` r

without_subconditions <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    icdv.var = "icdv",
    dx.var = "dx",
    poa = 1,
    method = "pccc_v3.1",
    subconditions = FALSE
  )

with_subconditions <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    icdv.var = "icdv",
    dx.var = "dx",
    poa = 1,
    method = "pccc_v3.1",
    subconditions = TRUE
  )
```

The structure of the return object `with_subconditions` is a list with
two elements. The first element, `conditions`, is identical to the
results of calling
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
with `subconditions = FALSE`.

``` r

with_subconditions
## 
## Comorbidities and Subconditions via pccc_v3.1
## 
## List of 2
##  $ conditions   :'data.frame':   38262 obs. of  49 variables:
##  $ subconditions:List of 11
##   ..$ congeni_genetic:'data.frame':  3225 obs. of  5 variables:
##   ..$ cvd            :'data.frame':  5122 obs. of  9 variables:
##   ..$ gi             :'data.frame':  5602 obs. of  7 variables:
##   ..$ hemato_immu    :'data.frame':  2832 obs. of  13 variables:
##   ..$ malignancy     :'data.frame':  3784 obs. of  3 variables:
##   ..$ metabolic      :'data.frame':  3109 obs. of  8 variables:
##   ..$ misc           :'data.frame':  762 obs. of  3 variables:
##   ..$ neonatal       :'data.frame':  1516 obs. of  9 variables:
##   ..$ neuromusc      :'data.frame':  5826 obs. of  11 variables:
##   ..$ renal          :'data.frame':  2768 obs. of  7 variables:
##   ..$ respiratory    :'data.frame':  3200 obs. of  7 variables:

all.equal(
  with_subconditions$conditions,
  without_subconditions,
  check.attributes = FALSE
)
## [1] TRUE
```

The second element of `with_subconditions` is list of `data.frame`s, one
for each condition, with indicators for only those with the condition.

A quick and easy way to get a summary of the subconditions is to call
[`summary()`](https://rdrr.io/r/base/summary.html).

``` r

str(summary(with_subconditions))
## 'data.frame':    82 obs. of  5 variables:
##  $ condition                      : chr  "congeni_genetic" "congeni_genetic" "congeni_genetic" "congeni_genetic" ...
##  $ subcondition                   : chr  NA "bone_and_joint_anomalies" "chromosomal_anomalies" "diaphragm_and_abdominal_wall_anomalies" ...
##  $ count                          : num  3225 825 1544 300 754 ...
##  $ percent_of_cohort              : num  8.429 2.156 4.035 0.784 1.971 ...
##  $ percent_of_those_with_condition: num  NA 25.6 47.9 9.3 23.4 ...
```

The subconditions are available for all pccc variants. A summary is
presented in the following tables.

### Congenital or Genetic

[TABLE]

### Cardiovascular

[TABLE]

### Gastrointestinal

[TABLE]

### Hematologic

[TABLE]

### Malignancy

[TABLE]

### Metabolic

[TABLE]

### Miscellaneous

[TABLE]

### Neonatal

[TABLE]

### Neuromuscular

[TABLE]

### Renal

[TABLE]

### Respiratory

[TABLE]

### Longitudinal

The longitudinal assessment for subconditions work as well. Using the
same `permutations` data set from above we will look at the metabolic
and respiratory conditions and subconditions.

``` r

rslts <-
  comorbidities(
    data = permutations,
    icd.codes = "code",
    id.vars = c("permutation", "plabel", "encounter_id"),
    icdv = 10L,
    compact.codes = FALSE,
    method = "pccc_v3.1",
    flag.method = "cumulative",
    poa = 1,
    subconditions = TRUE
  )
```

Let’s start by looking at the respiratory results. The only subcondition
that should be, and is, flagged is chronic respiratory diseases. A
reminder: the `data.frame` for a subcondition only report rows for when
the primary condition was flagged. We see in the following encounters
where the chronic respiratory disease is flagged is consistent with when
the primary respiratory condition is flagged.

``` r

all(rslts$subconditions$respiratory$chronic_respiratory_diseases == 1)
## [1] TRUE
sapply(rslts$subconditions$respiratory[, -(1:3)], max)
## chronic_respiratory_diseases              cystic_fibrosis 
##                            1                            0 
##    device_and_technology_use                        other 
##                            0                            0 
##    respiratory_malformations              transplantation 
##                            0                            0

# which encounters flag for primary condition respiratory?
cnd <-
  rslts$conditions[
    respiratory_dxpr_or_tech == 1,
    .(cencid = paste(encounter_id, collapse = ", ")),
    by = .(plabel)
  ]


# which encounters flag for the subcondition chronic_respiratory_diseases?
scnd <-
  rslts$subconditions$respiratory[
    ,
    .(sencid = paste(encounter_id, collapse = ", ")),
    by = .(plabel)
  ]
```

[TABLE]

Encounters flagging for respiratory condition and the chronic
respiratory disease subcondition. {.table .table .table-striped
style="font-size: 10px; margin-left: auto; margin-right: auto;"}

For the metabolic condition we have two subconditions to look at, 1)
device and technology use, and 2) other metabolic disorders.

``` r

# which encounters flag for primary condition metabolic?
cnd <-
  rslts$conditions[
    metabolic_dxpr_or_tech == 1,
    .(cencid = paste(encounter_id, collapse = ", ")),
    by = .(plabel)
  ]

# which encounters flag for the subconditions?
scnd <-
  data.table::melt(
    rslts$subconditions$metabolic,
    id.vars = c("plabel", "encounter_id"),
    measure.vars = c("device_and_technology_use", "other_metabolic_disorders"),
    variable.factor = FALSE,
    variable.name = "subcondition"
  )
scnd <- scnd[value == 1]
scnd <-
  scnd[
    ,
    .(sencid = paste(encounter_id, collapse = ", ")),
    by = .(plabel, subcondition)
  ]

scnd <-
  data.table::dcast(
    scnd,
    plabel ~ subcondition,
    value.var = "sencid"
  )
```

[TABLE]

Encounters flagging for a metabolic condition and the encounters
flagging for subconidtions device and technology use and/or other
metabolic disorders. {.table .table .table-striped
style="font-size: 10px; margin-left: auto; margin-right: auto;"}

## References

Feinstein, James A, Matt Hall, Amber Davidson, and Chris Feudtner. 2024.
“Pediatric Complex Chronic Condition System Version 3.” *JAMA Network
Open* 7 (7): e2420579–79.
<https://doi.org/10.1001/jamanetworkopen.2024.20579>.

Feudtner, Chris, James A Feinstein, Wenjun Zhong, Matt Hall, and Dingwei
Dai. 2014. “Pediatric Complex Chronic Conditions Classification System
Version 2: Updated for ICD-10 and Complex Medical Technology Dependence
and Transplantation.” *BMC Pediatrics* 14: 1–7.
<https://doi.org/10.1186/1471-2431-14-199>.
