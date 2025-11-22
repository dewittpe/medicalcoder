# Comorbidities

``` r
library(medicalcoder)
packageVersion("medicalcoder")
## [1] '0.7.0'
```

## Comorbidity Algorithms

There are three comorbidity algorithms, each with several variants,
implemented in the `medicalcoder` package:

1.  Pediatric Complex Chronic Condition System (PCCC)
    1.  Version 2.0 (Feudtner et al. 2014)
        1.  `pccc_v2.0` is consistent with the older R package pccc
            (v1.0.6) (DeWitt, Feinstein, and Russell 2025).
        2.  `pccc_v2.1` modifies the set of ICD codes to be more
            consistent with documentation and other implementations of
            v2.0.
    2.  Version 3.0 (Feinstein et al. 2024)
        1.  `pccc_v3.0` is consistent with the SAS software published on
            the [Children’s Hospital
            Association](https://www.childrenshospitals.org/content/analytics/toolkit/complex-chronic-conditions)
            website in conjunction with Feinstein et al. (2024).
        2.  `pccc_v3.1` modifies the set of ICD codes to be more
            consistent with documentation.
2.  Charlson
    1.  `charlson_deyo1992`: Deyo’s original set of codes (Deyo,
        Cherkin, and Ciol 1992; Quan et al. 2005)
    2.  `charlson_quan2005` and `charlson_quan2011`: Codes and index
        scoring (Quan et al. 2005, 2011)
    3.  `charlson_cdmf2019`: (Glasheen et al. 2019)
3.  Elixhauser
    1.  Based on codes provided by the Agency for Healthcare Research
        and Quality (AHRQ) for fiscal years 2022 through 2025
        (Healthcare Research and (AHRQ) 2025)
        1.  `elixhauser_ahrq2022`
        2.  `elixhauser_ahrq2023`
        3.  `elixhauser_ahrq2024`
        4.  `elixhauser_ahrq2025`
    2.  Codes from Table 2 of Quan et al. (2005)
        1.  `elixhauser_elixhauser1988`: (Elixhauser et al. 1998; Quan
            et al. 2005)
        2.  `elixhauser_ahrq_web`: (Quan et al. 2005; Healthcare Cost
            and Utilization Project (HCUP) 2017)
        3.  `elixhauser_quan2005`: (Quan et al. 2005)

**IMPORTANT NOTE:** Elixhauser 1998 and AHRQ Web used diagnostic related
group (DRG) codes as part of the methods. The `medicalcoder` package
*does not* use DRG codes. This is consistent with the way these methods
were implemented in Quan et al. (2005).

A list of the valid methods for the package can be accessed via a
non-exported function. In general, the methods are listed in the form of
`<algorithm>_<version>`.

``` r
medicalcoder:::comorbidities_methods()
##  [1] "pccc_v2.0"                 "pccc_v2.1"                
##  [3] "pccc_v3.0"                 "pccc_v3.1"                
##  [5] "charlson_deyo1992"         "charlson_quan2011"        
##  [7] "charlson_quan2005"         "charlson_cdmf2019"        
##  [9] "elixhauser_elixhauser1988" "elixhauser_ahrq_web"      
## [11] "elixhauser_quan2005"       "elixhauser_ahrq2022"      
## [13] "elixhauser_ahrq2023"       "elixhauser_ahrq2024"      
## [15] "elixhauser_ahrq2025"       "elixhauser_ahrq_icd10"
```

Vignettes for each of the major methods are available.

``` r
vignette(topic = "pccc",       package = "medicalcoder")
vignette(topic = "charlson",   package = "medicalcoder")
vignette(topic = "elixhauser", package = "medicalcoder")
```

The focus of this vignette is to highlight the general use of the
`comorbidities` function.

``` r
args(comorbidities)
## function (data, icd.codes, method, id.vars = NULL, icdv.var = NULL, 
##     icdv = NULL, dx.var = NULL, dx = NULL, poa.var = NULL, poa = NULL, 
##     age.var = NULL, primarydx.var = NULL, primarydx = NULL, flag.method = c("current", 
##         "cumulative"), full.codes = TRUE, compact.codes = TRUE, 
##     subconditions = FALSE) 
## NULL
```

We highlight a general concept for the arguments. Note that several
arguments are in pairs, e.g., `dx.var` and `dx` (used for denoting if
codes are diagnostic or procedural), or `poa.var` and `poa` (used for
denoting if a codes are present on admission). The `.var` version is the
name of a variable within the `data.frame` passed into the `data`
argument. The version without `.var` is a default value to be applied to
the entirety of `data`.

Details of the function arguments call are in the manual.

``` r
help(topic = "comorbidities", package = "medicalcoder")
```

The `data` element is expected to be a `data.frame`, or at least
something that inherits the `data.frame` class. The format is expected
to be a ‘long’ format. One row per code. Two example data sets in the
package show the general expected form of the `data`.

``` r
str(mdcr)
## 'data.frame':    319856 obs. of  4 variables:
##  $ patid: int  71412 71412 71412 71412 71412 17087 64424 64424 84361 84361 ...
##  $ icdv : int  9 9 9 9 9 10 9 9 9 9 ...
##  $ code : chr  "99931" "75169" "99591" "V5865" ...
##  $ dx   : int  1 1 1 1 1 1 1 0 1 1 ...
str(mdcr_longitudinal)
## 'data.frame':    60 obs. of  4 variables:
##  $ patid: int  9663901 9663901 9663901 9663901 9663901 9663901 9663901 9663901 9663901 9663901 ...
##  $ date : IDate, format: "2016-03-18" "2016-03-24" ...
##  $ icdv : int  10 10 10 10 10 10 10 10 10 10 ...
##  $ code : chr  "Z77.22" "IMO0002" "V87.7XXA" "J95.851" ...
```

The `mdcr` data set has columns \* `patid`: patient id \* `icdv`:
integer denoting if the ICD code is ICD-9 or ICD-10 \* `code`: character
string, a compact ICD code \* `dx`: if 1 then the ICD is a diagnostic
code (ICD-9-CM or ICD-10-CM), if 0 then the ICD code is a procedure code
(ICD-9-PCS or ICD-10-PCS).

The `mdcr_longitudinal` data set is distinct from `mdcr`. The columns
are the same save the `date` column to show longitudinal diagnoses for a
`patid`.

A simple example of flagging Elixhauser comorbidities:

``` r
ecmrb <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    icdv.var = "icdv",
    method = "elixhauser_ahrq_icd10",
    poa = 1L, # consider all codes to be present on admission
    primarydx = 0L # consider all codes to be secondary diagnoses
  )
summary(ecmrb)
## $conditions
##       condition count      percent
## 1          AIDS     3  0.007840677
## 2       ALCOHOL    11  0.028749151
## 3       ANEMDEF   700  1.829491401
## 4    AUTOIMMUNE   170  0.444305055
## 5       BLDLOSS    33  0.086247452
## 6   CANCER_LEUK   381  0.995766034
## 7  CANCER_LYMPH    76  0.198630495
## 8   CANCER_METS   213  0.556688098
## 9  CANCER_NSITU     0  0.000000000
## 10 CANCER_SOLID   477  1.246667712
## 11         CBVD   117  0.305786420
## 12         COAG   877  2.292091370
## 13     DEMENTIA    35  0.091474570
## 14      DEPRESS   321  0.838952485
## 15      DIAB_CX   123  0.321467775
## 16    DIAB_UNCX   184  0.480894883
## 17   DRUG_ABUSE    77  0.201244054
## 18           HF   246  0.642935550
## 19       HTN_CX   286  0.747477915
## 20     HTN_UNCX   395  1.032355862
## 21    LIVER_MLD   179  0.467827087
## 22    LIVER_SEV   159  0.415555904
## 23 LUNG_CHRONIC  1359  3.551826878
## 24   NEURO_MOVT   139  0.363284721
## 25    NEURO_OTH   948  2.477654069
## 26   NEURO_SEIZ  1490  3.894203126
## 27        OBESE   315  0.823271131
## 28    PARALYSIS   767  2.004599864
## 29     PERIVASC   209  0.546233861
## 30    PSYCHOSES    96  0.250901678
## 31     PULMCIRC   332  0.867701636
## 32   RENLFL_MOD   107  0.279650828
## 33   RENLFL_SEV   247  0.645549109
## 34 THYROID_HYPO   371  0.969630443
## 35  THYROID_OTH    36  0.094088129
## 36 ULCER_PEPTIC    23  0.060111860
## 37        VALVE   572  1.494955831
## 38     WGHTLOSS   616  1.609952433
## 39         >= 1  7869 20.566096911
## 40         >= 2  3186  8.326799435
## 41         >= 3  1135  2.966389629
## 42         >= 4   347  0.906905023
## 43         >= 5   120  0.313627097
## 44         >= 6    25  0.065338979
## 45         >= 7     7  0.018294914
## 46         >= 8     1  0.002613559
## 
## $index_summary
##         index min q1 median q3 max
## 1 readmission  -2  0      0  0  35
## 2   mortality -24  0      0  0  75
```

## When are conditions flagged?

Whether or not the code is present on admission (POA) is useful when
applying the comorbidity algorithms and considering if the patient has a
comorbidity at the time of encounter start or if the condition is a
result of the current hospitalization.

Implementation of Elixhauser comorbidities for 2022 and beyond
(Healthcare Research and (AHRQ) 2025) explicitly define the use of
present on admission flags for specific conditions (see the
`poa_required` flag reported in the data set returned by
[`get_elixhauser_poa()`](http://www.peteredewitt.com/medicalcoder/reference/get_elixhauser_poa.md),
and there are also ICD codes which are POA exempt).

``` r
str(get_elixhauser_poa())
## 'data.frame':    49 obs. of  7 variables:
##  $ condition            : chr  "AIDS" "ALCOHOL" "ANEMDEF" "AUTOIMMUNE" ...
##  $ poa_required         : int  0 0 1 0 1 0 0 0 0 0 ...
##  $ elixhauser_ahrq2022  : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ elixhauser_ahrq2023  : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ elixhauser_ahrq2024  : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ elixhauser_ahrq2025  : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ elixhauser_ahrq_icd10: int  1 1 1 1 1 1 1 1 1 1 ...
```

For Charlson comorbidities, from Quan et al. (2011):

> We defined comorbidities in the previous admissions using major and
> secondary diagnoses, without consideration of diagnosis type. The
> presence of a comorbid condition was assigned to a patient when it was
> present in index or previous admission records. Otherwise, the absence
> of the condition was assigned to the patient.

From Quan et al. (2005):

> The decision of whether to include or exclude specific codes or
> conditions from a coding algorithm depends to a large extent on a
> given study’s objectives. The original Charlson index used conditions
> present in hospitalized medical patients (regardless of whether the
> condition was present at baseline or arose after admission) to predict
> survival over an ensuing year. For such a study, a decision to exclude
> conditions arising after admission would not be ideal, as it would
> result in a loss of prognostic information relevant to long-term
> survival, and an ‘under-adjustment’ in risk-adjusted survival
> analyses. In contrast, in the context of studying in-hospital outcomes
> of a surgical procedure, researchers would be best advised to confine
> their risk adjustment to variables that are predominantly present at
> baseline. In jurisdictions that have diagnosis type indicators, the
> methodological decision is simply one of deciding, based on study
> objectives, whether to use or not use the indicators. In regions or
> countries without diagnosis type indicators, meanwhile, the data that
> we present … can help researchers make decisions on a
> condition-by-condition basis of whether to include particular
> variables, depending on their study objectives.

PCCC does not explicitly note if POA is required.

`medicalcoder` has been built to consider POA for all comorbidity
algorithms.

End users can use a 0/1 indicator variable in the data set to report
which codes are POA via the function argument `poa.var`. If all the
codes are to be considered POA or not, the functional argument `poa` can
be used to set a common status without adding a column to the input data
set.

Additionally, `medicalcoder` provides a `flag.method` argument for
longitudinal data sets.

**Example:** Let’s assume we have a patient record with six encounters.
We use ICD-10 diagnostic codes C78.4 and I50.40 which map to a cancer
and heart failure (cardiovascular disease) comorbidity respectively for
PCCC, Charlson, and Elixhauser. For demonstration, we also flag POA with
the second report of I50.40 intentionally marked as not present on
admission.

``` r
record
##   patid encid   code poa
## 1     A     1   <NA>  NA
## 2     A     2  C78.4   0
## 3     A     3 I50.40   1
## 4     A     4   <NA>  NA
## 5     A     5  C78.4   1
## 6     A     5 I50.40   0
## 7     A     6   <NA>  NA
```

We will call
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
for the three methods using static POA flags and dynamic POA flags, and
both flag methods. Results are shown in the following table.

[TABLE]

Indicators for when a comorbidity is flagged based on the algorithm,
present on admission (poa), and flag.method. The two ICD codes,C78.4 and
I50.40, map to cancer and cardiovascular disease respectively.

## Mapping ICD Codes to Comorbidities

End users can quickly assess the lookup table for all the ICD codes
associated with a comorbidity algorithm using the
`get_<comorbidity>_codes` functions. Each `data.frame` has columns for
the ICD version, diagnostic or procedure flag, the compact code, and the
full code. A column for the condition and other method-specific flags
are provided. Lastly, there are indicator columns for the variant of
each method.

``` r
str(get_pccc_codes())
## 'data.frame':    7913 obs. of  12 variables:
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
str(get_charlson_codes())
## 'data.frame':    7410 obs. of  9 variables:
##  $ icdv             : int  9 9 9 9 9 9 9 9 9 9 ...
##  $ dx               : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ full_code        : chr  "003.1" "007.2" "007.4" "010" ...
##  $ code             : chr  "0031" "0072" "0074" "010" ...
##  $ condition        : chr  "aids" "aids" "aids" "aids" ...
##  $ charlson_cdmf2019: int  1 1 1 1 1 1 1 1 1 1 ...
##  $ charlson_deyo1992: int  0 0 0 0 0 0 0 0 0 0 ...
##  $ charlson_quan2005: int  0 0 0 0 0 0 0 0 0 0 ...
##  $ charlson_quan2011: int  0 0 0 0 0 0 0 0 0 0 ...
str(get_elixhauser_codes())
## 'data.frame':    10428 obs. of  14 variables:
##  $ icdv                     : int  9 9 9 9 9 9 9 9 9 9 ...
##  $ dx                       : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ full_code                : chr  "042" "070.22" "070.23" "070.32" ...
##  $ code                     : chr  "042" "07022" "07023" "07032" ...
##  $ poaexempt                : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ condition                : chr  "AIDS" "LIVER" "LIVER" "LIVER" ...
##  $ elixhauser_ahrq_web      : int  1 1 1 1 1 1 1 0 0 0 ...
##  $ elixhauser_elixhauser1988: int  1 0 0 1 1 0 1 0 0 0 ...
##  $ elixhauser_quan2005      : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ elixhauser_ahrq2022      : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ elixhauser_ahrq2023      : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ elixhauser_ahrq2024      : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ elixhauser_ahrq2025      : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ elixhauser_ahrq_icd10    : int  NA NA NA NA NA NA NA NA NA NA ...
```

End users should be aware that just because an ICD code exists in a data
set does not mean that the patient has the condition. For Elixhauser,
the presence on admission is important to consider. For PCCC version 3.0
and 3.1, tech dependencies on their own are insufficient to flag a
condition (see
[`vignette(topic = "pccc", package = "medicalcoder")`](http://www.peteredewitt.com/medicalcoder/articles/pccc.md)).

For the `charlson_cdmf2019` method (Glasheen et al. 2019), the AIDS
categories are defined by the presence of HIV and an opportunistic
infection. In the following example, if only considering ICD codes which
flag ‘aids’, there would be several thousand cases of AIDS, but only six
cases of HIV.

``` r
cdmf_eg <-
  merge(x = mdcr,
        y = subset(get_charlson_codes(),
                   condition %in% c("aids", "hiv") &
                   charlson_cdmf2019 == 1),
        by = c("icdv", "dx", "code"))
data.table::setDT(cdmf_eg)

cdmf_eg <-
  data.table::dcast(data = cdmf_eg,
                    patid ~ condition,
                    value.var = "charlson_cdmf2019",
                    fun.aggregate = function(x) {as.integer(sum(x) > 0)})

cdmf_eg[, .N, keyby = .(hiv, aids)]
## Key: <hiv, aids>
##      hiv  aids     N
##    <int> <int> <int>
## 1:     0     1  2716
## 2:     1     0     6
## 3:     1     1     1
```

When calling
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
we get the expected result.

``` r
cmdf_mdcr <-
  comorbidities(data = mdcr,
                icd.codes = "code",
                id.vars = "patid",
                icdv.var = "icdv",
                dx.var = "dx",
                method = "charlson_cdmf2019",
                flag.method = "current",
                primarydx = 0L,
                poa = 1L)
data.table::setDT(cmdf_mdcr)

cmdf_mdcr[, .N, keyby = .(hiv, aids)]
## Key: <hiv, aids>
##      hiv  aids     N
##    <int> <int> <int>
## 1:     0     0 38255
## 2:     1     0     6
## 3:     1     1     1
```

## References

DeWitt, Peter, James Feinstein, and Seth Russell. 2025. *Pccc: Pediatric
Complex Chronic Conditions*. <https://github.com/CUD2V/pccc>.

Deyo, Richard A, Daniel C Cherkin, and Marcia A Ciol. 1992. “Adapting a
Clinical Comorbidity Index for Use with ICD-9-CM Administrative
Databases.” *Journal of Clinical Epidemiology* 45 (6): 613–19.
https://doi.org/<https://doi.org/10.1016/0895-4356(92)90133-8>.

Elixhauser, Anne, Claudia Steiner, D Robert Harris, and Rosanna M
Coffey. 1998. “Comorbidity Measures for Use with Administrative Data.”
*Medical Care* 36 (1): 8–27.
<https://doi.org/10.1097/00005650-199801000-00004>.

Feinstein, James A, Matt Hall, Amber Davidson, and Chris Feudtner. 2024.
“Pediatric Complex Chronic Condition System Version 3.” *JAMA Network
Open* 7 (7): e2420579–79.
<https://doi.org/10.1001/jamanetworkopen.2024.20579>.

Feudtner, Chris, James A Feinstein, Wenjun Zhong, Matt Hall, and Dingwei
Dai. 2014. “Pediatric Complex Chronic Conditions Classification System
Version 2: Updated for ICD-10 and Complex Medical Technology Dependence
and Transplantation.” *BMC Pediatrics* 14: 1–7.
<https://doi.org/10.1186/1471-2431-14-199>.

Glasheen, William P, Tristan Cordier, Rajiv Gumpina, Gil Haugh, Jared
Davis, and Andrew Renda. 2019. “Charlson Comorbidity Index: ICD-9 Update
and ICD-10 Translation.” *American Health & Drug Benefits* 12 (4): 188.
<https://pubmed.ncbi.nlm.nih.gov/31428236/>.

Healthcare Cost and Utilization Project (HCUP). 2017. “Elixhauser
Comorbidity Software for ICD-9-CM.”
<https://hcup-us.ahrq.gov/toolssoftware/comorbidity/comorbidity.jsp>.

Healthcare Research, Agency for, and Quality (AHRQ). 2025. “Elixhauser
Comorbidity Software Refined for ICD-10-CM Healthcare Cost and
Utilization Project (HCUP).”
<https://hcup-us.ahrq.gov/toolssoftware/comorbidityicd10/comorbidity_icd10.jsp>.

Quan, Hude, Bo Li, Colette M. Couris, Kiyohide Fushimi, Peter Graham,
Philip Hider, Jean-Michel Januel, and Vijaya Sundararajan. 2011.
“Updating and Validating the Charlson Comorbidity Index and Score for
Risk Adjustment in Hospital Discharge Abstracts Using Data from 6
Countries.” *American Journal of Epidemiology* 173 (6): 676–82.
<https://doi.org/10.1093/aje/kwq433>.

Quan, Hude, Vijaya Sundararajan, Patricia Halfon, Andrew Fong, Bernard
Burnand, Jean-Christophe Luthi, L Duncan Saunders, Catherine A. Beck,
Thomas E. Feasby, and William A. Ghali. 2005. “Coding Algorithms for
Defining Comorbidities in ICD-9-CM and ICD-10 Administrative Data.”
*Medical Care* 43 (11): 1130–39.
<https://doi.org/10.1097/01.mlr.0000182534.19832.83>.
