# Comorbidities

``` r
library(medicalcoder)
packageVersion("medicalcoder")
## [1] '0.7.0.9001'
```

## Comorbidity Algorithms

There are three comorbidity algorithms, each with several variants,
implemented in the medicalcoder package:

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
        and Quality (AHRQ) for fiscal years 2022 through 2026
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
group (DRG) codes as part of the methods. The medicalcoder package *does
not* use DRG codes. This is consistent with the way these methods were
implemented in Quan et al. (2005).

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
## [15] "elixhauser_ahrq2025"       "elixhauser_ahrq2026"      
## [17] "elixhauser_ahrq_icd10"
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
##     subconditions = FALSE) 
## NULL
```

We highlight a general concept for the arguments. Note that several
arguments are in pairs, e.g., `dx.var` and `dx` (used for denoting if
codes are diagnostic or procedural), or `poa.var` and `poa` (used for
denoting if a codes are present on admission). The `.var` version is the
name of a variable within the `data.frame` passed into the `data`
argument. The version without `.var` is a default value to be applied to
the entirety of `data`. We will see some examples where this is useful.

The `data` element is expected to be a `data.frame`, or at least
something that inherits the `data.frame` class. The format is expected
to be a ‘long’ format: one ICD code per row. Two example data sets in
the package show the general expected form of the `data`.

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

Whether or not the code is present on admission (POA) is useful when
applying the comorbidity algorithms and considering if the patient has a
comorbidity at the start of an encounter, or if the condition is a
result of the current hospitalization.

Implementation of Elixhauser comorbidities for 2022 and beyond
(Healthcare Research and (AHRQ) 2025) explicitly define the use of
present on admission flags for specific conditions (see the
`poa_required` flag reported in the data set returned by
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

PCCC does not explicitly note the if POA is required.

medicalcoder has been built to consider POA for all comorbidity
algorithms.

End users can use a 0/1 indicator variable in the data set to report
which codes are POA via the function argument `poa.var`. If all the
codes are to be considered POA or not, the functional argument `poa` can
be used to set a common status without adding a column to the input data
set.

Additionally, medicalcoder provides a `flag.method` argument for
longitudinal data sets.

**Example:** Let’s assume we have a patient record for six encounters.
We use ICD-10 diagnostic codes C78.4 and I50.40 which maps to a cancer
and heart failure (cardiovascular disease) comorbidity respectively for
PCCC, Charlson, and Elixhauser. For demonstration, we also flag POA with
the second report of I50.40 intentionally marked as not present on
admission.

We will call
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
for the three methods using static POA flags and dynamic POA flags, and
both flag methods. Results are shown in the following table.

[TABLE]

Indicators for when a comorbidity is flagged based on the algorithm,
present on admission (poa), and flag.method. The two ICD codes, C78.4
and I50.40, map to cancer and cardiovascular disease respectively.

#### Flag method and POA defaults

When `flag.method = "cumulative"` and you do *not* supply `poa` or
`poa.var`,
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
treats the first encounter where a condition appears as `poa = 0` and
carries that condition forward with `poa = 1` on later encounters.

When `flag.method = "current"` and you do *not* supply `poa` or
`poa.var`,
[`comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
treates all ICD codes as `poa = 1`.

## Mapping ICD Codes to Comorbidities

End users can quickly assess the lookup table for all the ICD codes
associated with a comorbidity algorithm using the
`get_<comorbidity>_codes` functions. Each `data.frame` has columns for
the ICD version, diagnostic or procedure flag, the compact code, and the
full code. A column for the condition and other method specific flags
are provided. Lastly, there are indicator columns for the variant of
each method

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
## 'data.frame':    10451 obs. of  15 variables:
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
