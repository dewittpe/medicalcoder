# Comorbidities

``` r

library(medicalcoder)
packageVersion("medicalcoder")
## [1] '0.9.0'
```

## Comorbidity Algorithms

There are three comorbidity algorithms, each with several variants,
implemented in the *medicalcoder* package:

1.  Pediatric Complex Chronic Condition System (PCCC)
    1.  Version 2.0 (Feudtner et al. 2014)
        1.  `pccc_v2.0` is consistent with the older R package *pccc*
            (v1.0.7) (Feinstein et al. 2018; DeWitt et al. 2026).
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
    1.  `charlson_deyo1992`: Deyo’s original set of codes (Deyo et al.
        1992; Quan et al. 2005)
    2.  `charlson_quan2005` and `charlson_quan2011`: Codes and index
        scoring (Quan et al. 2005, 2011)
    3.  `charlson_sundararajan2004`: Australian ICD-10-AM adaptation
        (Sundararajan et al. 2004)
    4.  `charlson_cdmf2019`: (Glasheen et al. 2019)
    5.  `charlson_ludvigsson2021`: Swedish ICD-10-SE adaptation
        (Ludvigsson et al. 2021, 2023)
    6.  `charlson_beyrer2021`: U.S. ICD-10-CM and ICD-10-PCS adaptation
        (Beyrer et al. 2021, 2020)
    7.  `charlson_mimicivcode`: mapping used by the MIMIC-IV Charlson
        SQL in [`mimic-code`](https://github.com/MIT-LCP/mimic-code)
3.  Elixhauser
    1.  Based on codes provided by the Agency for Healthcare Research
        and Quality (AHRQ) for fiscal years 2022 through 2026
        (Healthcare Research and (AHRQ) 2025)
        1.  `elixhauser_ahrq2022`
        2.  `elixhauser_ahrq2023`
        3.  `elixhauser_ahrq2024`
        4.  `elixhauser_ahrq2025`
        5.  `elixhauser_ahrq2026`
        6.  `elixhauser_ahrq_icd10`: uses all codes from all the
            specific years
    2.  Codes from Table 2 of Quan et al. (2005)
        1.  `elixhauser_elixhauser1988`: (Elixhauser et al. 1998; Quan
            et al. 2005)
        2.  `elixhauser_ahrq_web`: (Quan et al. 2005; Healthcare Cost
            and Utilization Project (HCUP) 2017)
        3.  `elixhauser_quan2005`: (Quan et al. 2005)

**IMPORTANT NOTE:** Elixhauser 1998 and AHRQ Web used diagnosis-related
group (DRG) codes as part of the methods. The *medicalcoder* package
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
##  [9] "charlson_sundararajan2004" "charlson_ludvigsson2021"  
## [11] "charlson_beyrer2021"       "charlson_mimicivcode"     
## [13] "elixhauser_elixhauser1988" "elixhauser_ahrq_web"      
## [15] "elixhauser_quan2005"       "elixhauser_ahrq2022"      
## [17] "elixhauser_ahrq2023"       "elixhauser_ahrq2024"      
## [19] "elixhauser_ahrq2025"       "elixhauser_ahrq2026"      
## [21] "elixhauser_ahrq_icd10"
```

Vignettes for each of the major methods are available.

``` r

vignette(topic = "pccc",       package = "medicalcoder")
vignette(topic = "charlson",   package = "medicalcoder")
vignette(topic = "elixhauser", package = "medicalcoder")
```

The focus of this vignette is to highlight the general use of the
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
function.

Details of the function arguments call are in the manual.

``` r

help(topic = "comorbidities", package = "medicalcoder")
```

``` r

args(comorbidities)
## function (data, icd.codes, method, id.vars = NULL, icdv.var = NULL, 
##     icdv = NULL, dx.var = NULL, dx = NULL, poa.var = NULL, poa = NULL, 
##     age.var = NULL, primarydx.var = NULL, primarydx = NULL, flag.method = c("current", 
##         "cumulative"), full.codes = TRUE, compact.codes = TRUE, 
##     subconditions = FALSE, mapping = c("precomputed", "regex")) 
## NULL
```

We highlight a general concept for the arguments. Note that several
arguments are in pairs, e.g., `dx.var` and `dx` (used for denoting if
codes are diagnostic or procedural), or `poa.var` and `poa` (used for
denoting whether codes are present-on-admission). The `.var` version is
the name of a variable within the `data.frame` passed into the `data`
argument. The version without `.var` is a default value to be applied to
the entirety of `data`. We will see some examples where this is useful.

The `data` element is expected to be a `data.frame`, or at least
something that inherits the `data.frame` class. The format is expected
to be a ‘long’ format: one ICD code per row. Two example datasets in the
package show the general expected form of the `data`.

``` r

head(mdcr)
##   patid icdv  code dx
## 1 71412    9 99931  1
## 2 71412    9 75169  1
## 3 71412    9 99591  1
## 4 71412    9 V5865  1
## 5 71412    9  V427  1
## 6 17087   10  V441  1
head(mdcr_longitudinal)
##     patid       date icdv     code
## 1 9663901 2016-03-18   10   Z77.22
## 2 9663901 2016-03-24   10  IMO0002
## 3 9663901 2016-03-24   10 V87.7XXA
## 4 9663901 2016-03-25   10  J95.851
## 5 9663901 2016-03-30   10  IMO0002
## 6 9663901 2016-03-30   10    Z93.0
```

## When are conditions flagged?

Whether or not the code is present-on-admission (POA) is useful when
applying the comorbidity algorithms and considering if the patient has a
comorbidity at the start of an encounter, or if the condition is a
result of the current hospitalization.

Implementation of Elixhauser comorbidities for 2022 and beyond
(Healthcare Research and (AHRQ) 2025) explicitly define the use of
present-on-admission flags for specific conditions (see the
`poa_required` flag reported in the dataset returned by
[`get_elixhauser_poa()`](http://www.peteredewitt.com/medicalcoder/reference/get_elixhauser_poa.md)).

``` r

str(get_elixhauser_poa())
## 'data.frame':    50 obs. of  8 variables:
##  $ condition            : chr  "AIDS" "ALCOHOL" "ANEMDEF" "AUTOIMMUNE" ...
##  $ poa_required         : int  0 0 1 0 1 0 0 0 0 0 ...
##  $ elixhauser_ahrq2022  : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ elixhauser_ahrq2023  : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ elixhauser_ahrq2024  : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ elixhauser_ahrq2025  : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ elixhauser_ahrq2026  : int  1 1 1 1 1 1 1 1 1 1 ...
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

PCCC does not explicitly state whether POA is required.

*medicalcoder* has been built to consider POA for all comorbidity
algorithms.

End users can use a `0L`/`1L` indicator variable in the dataset to
report which codes are POA via the function argument `poa.var`. If all
the codes are to be considered POA or not, the functional argument `poa`
can be used to set a common status without adding a column to the input
dataset.

Additionally, *medicalcoder* provides a `flag.method` argument for
longitudinal datasets. The default `flag.method = "current"` evaluates
each encounter on its own. The `flag.method = "cumulative"` option also
considers prior encounters for the same patient or grouping.

**Example:** Let’s assume we have a patient record for six encounters.
We use ICD-10 diagnostic codes C78.4 and I50.40 which maps to a cancer
and heart failure (cardiovascular disease) comorbidity respectively for
PCCC, Charlson, and Elixhauser. For demonstration, we also flag POA with
the second report of I50.40 intentionally marked as not
present-on-admission.

We will call
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
for the three methods using static POA flags and dynamic POA flags, the
default current-encounter flagging method, and the cumulative flagging
method. Results are shown in the following table.

[TABLE]

Indicators for when a comorbidity is flagged based on the algorithm,
present-on-admission (poa), and flag.method. The two ICD codes, C78.4
and I50.40, map to cancer and cardiovascular disease respectively.
{.table .table .table-striped .table-bordered
style="NAborder-bottom: 0; font-size: 8px; width: auto !important; margin-left: auto; margin-right: auto;"}

#### Flag method and POA defaults

When `flag.method = "cumulative"` is used and you do *not* supply `poa`
or `poa.var`,
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
treats the first encounter where a condition appears as `poa = 0L` and
carries that condition forward with `poa = 1L` on later encounters.

When `flag.method = "current"` and you do *not* supply `poa` or
`poa.var`,
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
treats all ICD codes as `poa = 1L`.

For `flag.method = "cumulative"`, the last column named in `id.vars` is
the encounter order column. It must not contain missing values, must not
be a factor, and must be numeric, character, `Date`, or `POSIXt`.
Character encounter order columns are allowed with a warning because
they are sorted lexicographically.

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
## 'data.frame':    8900 obs. of  12 variables:
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
## 'data.frame':    9248 obs. of  13 variables:
##  $ icdv                     : int  9 9 9 9 9 9 9 9 9 9 ...
##  $ dx                       : int  0 1 1 1 1 1 1 1 1 1 ...
##  $ full_code                : chr  "38.48" "003.1" "007.2" "007.4" ...
##  $ code                     : chr  "3848" "0031" "0072" "0074" ...
##  $ condition                : chr  "pvd" "aids" "aids" "aids" ...
##  $ charlson_beyrer2021      : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ charlson_cdmf2019        : int  0 1 1 1 1 1 1 1 1 1 ...
##  $ charlson_deyo1992        : int  1 0 0 0 0 0 0 0 0 0 ...
##  $ charlson_ludvigsson2021  : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ charlson_mimicivcode     : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ charlson_quan2005        : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ charlson_sundararajan2004: int  0 0 0 0 0 0 0 0 0 0 ...
##  $ charlson_quan2011        : int  0 0 0 0 0 0 0 0 0 0 ...
str(get_elixhauser_codes())
## 'data.frame':    11294 obs. of  15 variables:
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
##  $ elixhauser_ahrq2026      : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ elixhauser_ahrq_icd10    : int  NA NA NA NA NA NA NA NA NA NA ...
```

End users should be aware that just because an ICD code exists in a
dataset does not mean that the patient has the condition. For AHRQ
variants of Elixhauser, the present-on-admission status of the ICD is
considered. For PCCC version 3.0 and 3.1, tech dependencies on their own
are insufficient to flag a condition (see
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
                   charlson_cdmf2019 == 1L),
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

Beyrer, Julie, Janna Manjelievskaia, Machaon Bonafede, et al. 2020.
*Codes Used to Identify Hospital Complications in Validation of Charlson
Comorbidity Index ICD-10 for the US*. Zenodo.
<https://doi.org/10.5281/zenodo.3968784>.

Beyrer, Julie, Janna Manjelievskaia, Machaon Bonafede, et al. 2021.
“Validation of an International Classification of Disease, 10th Revision
Coding Adaptation for the Charlson Comorbidity Index in United States
Healthcare Claims Data.” *Pharmacoepidemiology and Drug Safety* 30 (5):
582–93. https://doi.org/<https://doi.org/10.1002/pds.5204>.

DeWitt, Peter, James Feinstein, and Seth Russell. 2026. *Pccc: Pediatric
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

Feinstein, James A., Seth Russell, Peter E. DeWitt, Chris Feudtner,
Dingwei Dai, and Tellen D. Bennett. 2018. “R Package for Pediatric
Complex Chronic Condition Classification.” *JAMA Pediatrics* 172 (6):
596–98. <https://doi.org/10.1001/jamapediatrics.2018.0256>.

Feudtner, Chris, James A Feinstein, Wenjun Zhong, Matt Hall, and Dingwei
Dai. 2014. “Pediatric Complex Chronic Conditions Classification System
Version 2: Updated for ICD-10 and Complex Medical Technology Dependence
and Transplantation.” *BMC Pediatrics* 14: 1–7.
<https://doi.org/10.1186/1471-2431-14-199>.

Glasheen, William P, Tristan Cordier, Rajiv Gumpina, Gil Haugh, Jared
Davis, and Andrew Renda. 2019. “Charlson Comorbidity Index: ICD-9 Update
and ICD-10 Translation.” *American Health & Drug Benefits* 12 (4): 188.
<https://pubmed.ncbi.nlm.nih.gov/31428236/>.

Healthcare Cost and Utilization Project (HCUP). 2017. *Elixhauser
Comorbidity Software for ICD-9-CM*.
[Https://hcup-us.ahrq.gov/toolssoftware/comorbidity/comorbidity.jsp](https://hcup-us.ahrq.gov/toolssoftware/comorbidity/comorbidity.jsp).

Healthcare Research, Agency for, and Quality (AHRQ). 2025. *Elixhauser
Comorbidity Software Refined for ICD-10-CM Healthcare Cost and
Utilization Project (HCUP)*.
<https://hcup-us.ahrq.gov/toolssoftware/comorbidityicd10/comorbidity_icd10.jsp>.

Ludvigsson, Jonas F, Peter Appelros, Johan Askling, et al. 2021.
“Adaptation of the Charlson Comorbidity Index for Register-Based
Research in Sweden.” *Clinical Epidemiology*, 21–41.
https://doi.org/<https://doi.org/10.2147/CLEP.S282475>.

Ludvigsson, Jonas F, Peter Appelros, Johan Askling, et al. 2023.
“Adaptation of the Charlson Comorbidity Index for Register-Based
Research in Sweden \[Corrigendum\].” *Clinical Epidemiology* 15: 753–54.
https://doi.org/<https://doi.org/10.2147/clep.s425901>.

Quan, Hude, Bo Li, Colette M. Couris, et al. 2011. “Updating and
Validating the Charlson Comorbidity Index and Score for Risk Adjustment
in Hospital Discharge Abstracts Using Data from 6 Countries.” *American
Journal of Epidemiology* 173 (6): 676–82.
<https://doi.org/10.1093/aje/kwq433>.

Quan, Hude, Vijaya Sundararajan, Patricia Halfon, et al. 2005. “Coding
Algorithms for Defining Comorbidities in ICD-9-CM and ICD-10
Administrative Data.” *Medical Care* 43 (11): 1130–39.
<https://doi.org/10.1097/01.mlr.0000182534.19832.83>.

Sundararajan, Vijaya, Toni Henderson, Catherine Perry, Amanda Muggivan,
Hude Quan, and William A Ghali. 2004. “New ICD-10 Version of the
Charlson Comorbidity Index Predicted in-Hospital Mortality.” *Journal of
Clinical Epidemiology* 57 (12): 1288–94.
