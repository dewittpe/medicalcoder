<!-- README.md is generated from README.Rmd. Please edit that file -->



# `medicalcoder`: An R package for working with ICD codes and Comorbidity Algorithms <img src="man/figures/hex.svg" width="200px" align="right" alt = "medicalcoder hex logo"/>

<!-- badges: start -->
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/dewittpe/medicalcoder/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dewittpe/medicalcoder/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/dewittpe/medicalcoder/graph/badge.svg)](https://app.codecov.io/gh/dewittpe/medicalcoder)
[![CRAN status](https://www.r-pkg.org/badges/version-last-release/medicalcoder)](https://CRAN.R-project.org/package=medicalcoder)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/medicalcoder)](https://www.r-pkg.org/pkg/medicalcoder)
[![downloads](https://cranlogs.r-pkg.org/badges/grand-total/medicalcoder)](https://www.r-pkg.org/pkg/medicalcoder)
<!-- badges: end -->

`medicalcoder` is a lightweight, base-R package for working with ICD-9 and
ICD-10 diagnosis and procedure codes. It provides fast, dependency-free tools to
look up, validate, and manipulate ICD codes, while also implementing widely used
comorbidity algorithms such as Charlson, Elixhauser, and the Pediatric Complex
Chronic Conditions (PCCC). Designed for portability and reproducibility, the
package avoids external dependencies—requiring only R ≥ 3.5.0—yet offers a rich
set of curated ICD code libraries from the United States' Centers for Medicare
and Medicaid Services (CMS), Centers for Disease Control (CDC), and the World
Health Organization (WHO).

The package balances performance with elegance: its internal caching, efficient
joins, and compact data structures make it practical for large-scale health data
analyses, while its clean design makes it easy to extend or audit. Whether you
need to flag comorbidities, explore ICD hierarchies, or standardize clinical
coding workflows, `medicalcoder` provides a robust, transparent foundation for
research and applied work in biomedical informatics.

The primary objectives of `medicalcoder` are:

1. **Fully self-contained**
   - Minimal Dependencies
     - No dependencies other than base R.
     - Requires R version ≥ 3.5.0 due to a [change in data
       serialization](https://cran.r-project.org/src/base/NEWS.3#:~:text=R%20has%20new,to%20version%203.5.0).
       R 3.5.0 was released in April 2018. The initial public release of
       `medicalcoder` was in 2025.
     - Several packages are listed in the *Suggests* section of the
       `DESCRIPTION` file. These are only needed for building vignettes, other
       documentation, and testing. They are not required to install the package.

   - No Imports
     - `medicalcoder` does not import any non-base namespaces. This improves
       ease of maintenance and usability.
     - Suggested packages are needed only for development work and building
       vignettes. They are not required for installation or use.
     - That said, there are non-trivial performance gains when passing a
       [`data.table`](https://cran.r-project.org/package=data.table) to the
       `comorbidities()` function compared to passing a base `data.frame` or a
       `tibble` from the tidyverse.
       (See [benchmarking](https://github.com/dewittpe/medicalcoder/tree/main/benchmarking)).

   - Internal lookup tables
     - All required data are included in the package. If you have the `.tar.gz`
       source file and R ≥ 3.5.0, that is all you need to install and use the
       package.

2. **Efficient implementation of multiple comorbidity algorithms**
   - Implements three general algorithms, each with multiple variants. Details
     are provided below.
   - Supports flagging of subconditions within PCCC.
   - Supports longitudinal flagging of comorbidities. `medicalcoder` will flag
     comorbidities based on present-on-admission indicators for the
     current encounter and can look back in time for a patient to flag a
     comorbidity if reported in a prior encounter. See examples.

3. **Tools for working with ICD codes**
   - Lookup tables.
   - Ability to work with both full codes (ICD codes with decimal points) and
     compact codes (ICD codes with decimal points omitted).

## Why use `medicalcoder`

There are several tools for working with ICD codes and comorbidity algorithms.
`medicalcoder` provides novel features:

- Unified access to multiple comorbidity algorithms through a single function:
  `comorbidities()`.
- Support for both ICD-9 and ICD-10 diagnostic and procedure codes.
- Longitudinal patient-level comorbidity flagging using present-on-admission indicators.
- Fully self-contained package (no external dependencies).

## Install

### CRAN

``` r
install.packages("medicalcoder")
```

### From GitHub


``` r
remotes::install_github("dewittpe/medicalcoder")
```

### From source

If you have the .tar.gz file for version X.Y.Z, e.g., `medicalcoder_X.Y.Z.tar.gz`
you can install from within R via:


``` r
install.packages(
  pkgs = "medicalcoder_X.Y.Z.tar.gz", # replace file name with the file you have
  repos = NULL,
  type = "source"
)
```

From the command line:

```
R CMD INSTALL medicalcoder_X.Y.Z.tar.gz
```

## Tools:

### Example Data

Input data for `comorbidities()` is expected to be in a 'long' format.  Each row
is one code with additional columns for patient and/or encounter id.


``` r
data(mdcr, mdcr_longitudinal, package = "medicalcoder")
str(mdcr)
#> 'data.frame':	319856 obs. of  4 variables:
#>  $ patid: int  71412 71412 71412 71412 71412 17087 64424 64424 84361 84361 ...
#>  $ icdv : int  9 9 9 9 9 10 9 9 9 9 ...
#>  $ code : chr  "99931" "75169" "99591" "V5865" ...
#>  $ dx   : int  1 1 1 1 1 1 1 0 1 1 ...
head(mdcr)
#>   patid icdv  code dx
#> 1 71412    9 99931  1
#> 2 71412    9 75169  1
#> 3 71412    9 99591  1
#> 4 71412    9 V5865  1
#> 5 71412    9  V427  1
#> 6 17087   10  V441  1
str(mdcr_longitudinal)
#> 'data.frame':	60 obs. of  4 variables:
#>  $ patid: int  9663901 9663901 9663901 9663901 9663901 9663901 9663901 9663901 9663901 9663901 ...
#>  $ date : IDate, format: "2016-03-18" "2016-03-24" ...
#>  $ icdv : int  10 10 10 10 10 10 10 10 10 10 ...
#>  $ code : chr  "Z77.22" "IMO0002" "V87.7XXA" "J95.851" ...
head(mdcr_longitudinal)
#>     patid       date icdv     code
#> 1 9663901 2016-03-18   10   Z77.22
#> 2 9663901 2016-03-24   10  IMO0002
#> 3 9663901 2016-03-24   10 V87.7XXA
#> 4 9663901 2016-03-25   10  J95.851
#> 5 9663901 2016-03-30   10  IMO0002
#> 6 9663901 2016-03-30   10    Z93.0
```

### Comorbidity Algorithms

There are three comorbidity methods, each with several variants, available in
`medicalcoder`.

* Pediatric Complex Chronic Conditions (PCCC)

  * Version 2.0
    - BMC Pediatrics: [Feudtner et al. (2014)](https://doi.org/10.1186/1471-2431-14-199)
    - Consistent with R package [pccc](https://cran.r-project.org/package=pccc)

  * Version 2.1
    - Updated code base with the same assessment algorithm as version 2.0.

  * Version 3.0
    - JAMA Network Open: [Feinstein et al. (2024)](https://doi.org/10.1001/jamanetworkopen.2024.20579)
    - Children's Hospital Association [Toolkit](https://www.childrenshospitals.org/content/analytics/toolkit/complex-chronic-conditions)

  * Version 3.1
    - Updated code base with same assessment algorithm as version 3.0.

  * All variants can flag conditions and subconditions.


``` r
# PCCC v3.1 example
cmrbs <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    dx.var = "dx",
    poa = 1,
    method = "pccc_v3.1"
  )
str(cmrbs, max.level = 0)
#> Classes 'medicalcoder_comorbidities' and 'data.frame':	38262 obs. of  49 variables:
#>  - attr(*, "method")= chr "pccc_v3.1"
#>  - attr(*, "id.vars")= chr "patid"
#>  - attr(*, "flag.method")= chr "current"
```


|condition       |label                                   | dxpr_or_tech_count| dxpr_or_tech_percent| dxpr_only_count| dxpr_only_percent| tech_only_count| tech_only_percent| dxpr_and_tech_count| dxpr_and_tech_percent|
|:---------------|:---------------------------------------|------------------:|--------------------:|---------------:|-----------------:|---------------:|-----------------:|-------------------:|---------------------:|
|congeni_genetic |Other Congenital or Genetic Defect      |               3225|            8.4287282|            3225|         8.4287282|               0|         0.0000000|                   0|             0.0000000|
|cvd             |Cardiovascular                          |               5147|           13.4519889|            4560|        11.9178297|             283|         0.7396372|                 304|             0.7945220|
|gi              |Gastrointestinal                        |               5652|           14.7718363|            1420|         3.7112540|            3855|        10.0752705|                 377|             0.9853118|
|hemato_immu     |Hematologic or Immunologic              |               2832|            7.4015995|            2832|         7.4015995|               0|         0.0000000|                   0|             0.0000000|
|malignancy      |Malignancy                              |               3784|            9.8897078|            3784|         9.8897078|               0|         0.0000000|                   0|             0.0000000|
|metabolic       |Metabolic                               |               3407|            8.9043960|            3356|         8.7711045|              40|         0.1045424|                  11|             0.0287492|
|misc            |Miscellaneous, Not Elsewhere Classified |                764|            1.9967592|             121|         0.3162407|             643|         1.6805185|                   0|             0.0000000|
|neonatal        |Premature & Neonatal                    |               1516|            3.9621557|            1516|         3.9621557|               0|         0.0000000|                   0|             0.0000000|
|neuromusc       |Neurologic or Neuromuscular             |               5828|           15.2318227|            4564|        11.9282839|             316|         0.8258847|                 948|             2.4776541|
|renal           |Renal Urologic                          |               2787|            7.2839893|            1876|         4.9030370|             555|         1.4505253|                 356|             0.9304271|
|respiratory     |Respiratory                             |               3260|            8.5202028|            1848|         4.8298573|             755|         1.9732372|                 657|             1.7171084|
|any_tech_dep    |Any Technology Dependence               |               7012|           18.3262767|              NA|                NA|              NA|                NA|                  NA|                    NA|
|any_transplant  |Any Transplantation                     |               1585|            4.1424912|              NA|                NA|              NA|                NA|                  NA|                    NA|
|cmrb_flag       |Any Condition                           |              20871|           54.5475929|              NA|                NA|              NA|                NA|                  NA|                    NA|
|num_cmrb        |>= 2 conditions                         |              10657|           27.8526998|              NA|                NA|              NA|                NA|                  NA|                    NA|
|num_cmrb        |>= 3 conditions                         |               4582|           11.9753280|              NA|                NA|              NA|                NA|                  NA|                    NA|
|num_cmrb        |>= 4 conditions                         |               1571|            4.1059014|              NA|                NA|              NA|                NA|                  NA|                    NA|
|num_cmrb        |>= 5 conditions                         |                418|            1.0924677|              NA|                NA|              NA|                NA|                  NA|                    NA|
|num_cmrb        |>= 6 conditions                         |                 88|            0.2299932|              NA|                NA|              NA|                NA|                  NA|                    NA|
|num_cmrb        |>= 7 conditions                         |                 13|            0.0339763|              NA|                NA|              NA|                NA|                  NA|                    NA|
|num_cmrb        |>= 8 conditions                         |                  2|            0.0052271|              NA|                NA|              NA|                NA|                  NA|                    NA|
|num_cmrb        |>= 9 conditions                         |                  0|            0.0000000|              NA|                NA|              NA|                NA|                  NA|                    NA|
|num_cmrb        |>= 10 conditions                        |                  0|            0.0000000|              NA|                NA|              NA|                NA|                  NA|                    NA|
|num_cmrb        |>= 11 conditions                        |                  0|            0.0000000|              NA|                NA|              NA|                NA|                  NA|                    NA|



* Charlson Comorbidities
  * [Deyo, Cherkin, and Ciol (1992)](https://doi.org/10.1016/0895-4356(92)90133-8)
  * [Quan et al. (2005)](https://doi.org/10.1097/01.mlr.0000182534.19832.83)
  * [Quan et al. (2011)](https://doi.org/10.1093/aje/kwq433)
  * [Glasheen (2019)](https://pubmed.ncbi.nlm.nih.gov/31428236/)


``` r
# Charlson example
cmrbs <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    dx.var = "dx",
    poa = 1,
    primarydx = 0L,
    method = "charlson_quan2005"
  )
str(cmrbs, max.level = 0)
#> Classes 'medicalcoder_comorbidities' and 'data.frame':	38262 obs. of  22 variables:
#>  - attr(*, "method")= chr "charlson_quan2005"
#>  - attr(*, "id.vars")= chr "patid"
#>  - attr(*, "flag.method")= chr "current"
```

``` r
summary(cmrbs)
```


<table class="kable_wrapper">
<tbody>
  <tr>
   <td> 

|condition_description                  |condition | count|    percent|
|:--------------------------------------|:---------|-----:|----------:|
|AIDS/HIV                               |aidshiv   |     7|  0.0182949|
|Any malignancy                         |mal       |  2577|  6.7351419|
|Cerebrovascular disease                |cebvd     |   411|  1.0741728|
|Chronic pulmonary disease              |copd      |  3415|  8.9253045|
|Congestive heart failure               |chf       |   684|  1.7876745|
|Dementia                               |dem       |    13|  0.0339763|
|Diabetes with chronic complications    |dmc       |    13|  0.0339763|
|Diabetes without chronic complications |dm        |   445|  1.1630338|
|Hemiplegia or paraplegia               |hp        |  1177|  3.0761591|
|Liver disease, mild                    |mld       |   663|  1.7327897|
|Liver disease, moderate to severe      |msld      |   206|  0.5383932|
|Metastatic solid tumor                 |mst       |   453|  1.1839423|
|Myocardial infarction                  |mi        |    10|  0.0261356|
|Peptic ulcer disease                   |pud       |    45|  0.1176102|
|Peripheral vascular disease            |pvd       |   217|  0.5671423|
|Renal disease                          |rnd       |   898|  2.3469761|
|Rheumatic disease                      |rhd       |   136|  0.3554440|
|>= 1                                   |NA        |  9841| 25.7200355|
|>= 2                                   |NA        |  1368|  3.5753489|
|>= 3                                   |NA        |   138|  0.3606712|
|>= 4                                   |NA        |    20|  0.0522712|
|>= 5                                   |NA        |     3|  0.0078407|

 </td>
   <td> 

|age_score | count| percent|
|:---------|-----:|-------:|
|NA        | 38262|     100|

 </td>
   <td> 

| min| q1| median| q3| max|
|---:|--:|------:|--:|---:|
|   0|  0|      0|  1|  12|

 </td>
  </tr>
</tbody>
</table>



* Elixhauser Comorbidities
  * [Elixhauser et al. (1998)](https://doi.org/10.1097/00005650-199801000-00004)
  * [Quan et al. (2005)](https://doi.org/10.1097/01.mlr.0000182534.19832.83)
  * AHRQ (2017, 2022, 2023, 2024, 2025)
    * [For ICD-9 codes](https://hcup-us.ahrq.gov/toolssoftware/comorbidity/comorbidity.jsp)
    * [For ICD-10 codes](https://hcup-us.ahrq.gov/toolssoftware/comorbidityicd10/comorbidity_icd10.jsp)


``` r
# Elixhauser example
cmrbs <-
  comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    dx.var = "dx",
    poa = 1,
    primarydx = 0L,
    method = "elixhauser_ahrq_icd10"
  )
str(cmrbs, max.level = 0)
#> Classes 'medicalcoder_comorbidities' and 'data.frame':	38262 obs. of  54 variables:
#>  - attr(*, "method")= chr "elixhauser_ahrq_icd10"
#>  - attr(*, "id.vars")= chr "patid"
#>  - attr(*, "flag.method")= chr "current"
```

``` r
summary(cmrbs)
```


<table class="kable_wrapper">
<tbody>
  <tr>
   <td> 

|condition    | count|    percent|
|:------------|-----:|----------:|
|AIDS         |     3|  0.0078407|
|ALCOHOL      |    11|  0.0287492|
|ANEMDEF      |   700|  1.8294914|
|AUTOIMMUNE   |   170|  0.4443051|
|BLDLOSS      |    33|  0.0862475|
|CANCER_LEUK  |   381|  0.9957660|
|CANCER_LYMPH |    76|  0.1986305|
|CANCER_METS  |   213|  0.5566881|
|CANCER_NSITU |     0|  0.0000000|
|CANCER_SOLID |   477|  1.2466677|
|CBVD         |   117|  0.3057864|
|COAG         |   877|  2.2920914|
|DEMENTIA     |    35|  0.0914746|
|DEPRESS      |   321|  0.8389525|
|DIAB_CX      |   123|  0.3214678|
|DIAB_UNCX    |   184|  0.4808949|
|DRUG_ABUSE   |    77|  0.2012441|
|HF           |   246|  0.6429355|
|HTN_CX       |   286|  0.7474779|
|HTN_UNCX     |   395|  1.0323559|
|LIVER_MLD    |   179|  0.4678271|
|LIVER_SEV    |   159|  0.4155559|
|LUNG_CHRONIC |  1359|  3.5518269|
|NEURO_MOVT   |   139|  0.3632847|
|NEURO_OTH    |   948|  2.4776541|
|NEURO_SEIZ   |  1490|  3.8942031|
|OBESE        |   315|  0.8232711|
|PARALYSIS    |   767|  2.0045999|
|PERIVASC     |   209|  0.5462339|
|PSYCHOSES    |    96|  0.2509017|
|PULMCIRC     |   332|  0.8677016|
|RENLFL_MOD   |   107|  0.2796508|
|RENLFL_SEV   |   247|  0.6455491|
|THYROID_HYPO |   393|  1.0271287|
|THYROID_OTH  |    36|  0.0940881|
|ULCER_PEPTIC |    23|  0.0601119|
|VALVE        |   572|  1.4949558|
|WGHTLOSS     |   616|  1.6099524|
|>= 1         |  7891| 20.6235952|
|>= 2         |  3186|  8.3267994|
|>= 3         |  1135|  2.9663896|
|>= 4         |   347|  0.9069050|
|>= 5         |   120|  0.3136271|
|>= 6         |    25|  0.0653390|
|>= 7         |     7|  0.0182949|
|>= 8         |     1|  0.0026136|

 </td>
   <td> 

|index       | min| q1| median| q3| max|
|:-----------|---:|--:|------:|--:|---:|
|readmission |  -2|  0|      0|  0|  35|
|mortality   | -24|  0|      0|  0|  75|

 </td>
  </tr>
</tbody>
</table>



See more examples in the vignettes.

``` r
vignette(topic = "comorbidities", package = "medicalcoder")
vignette(topic = "pccc",          package = "medicalcoder")
vignette(topic = "charlson",      package = "medicalcoder")
vignette(topic = "elixhauser",    package = "medicalcoder")
```

### ICD

The package contains internal data sets with references for ICD-9 and ICD-10 US
based diagnostic and procedure codes. These codes are supplemented with
additional codes from the World Health Organization.

You can get a table of ICD codes via `get_icd_codes()`.

``` r
str(medicalcoder::get_icd_codes())
#> 'data.frame':	227534 obs. of  9 variables:
#>  $ icdv            : int  9 9 9 9 9 9 9 9 9 9 ...
#>  $ dx              : int  0 0 0 0 0 0 1 0 1 0 ...
#>  $ full_code       : chr  "00" "00.0" "00.01" "00.02" ...
#>  $ code            : chr  "00" "000" "0001" "0002" ...
#>  $ src             : chr  "cms" "cms" "cms" "cms" ...
#>  $ known_start     : int  2003 2003 2003 2003 2003 2003 1997 2003 1997 2003 ...
#>  $ known_end       : int  2015 2015 2015 2015 2015 2015 2015 2015 2015 2015 ...
#>  $ assignable_start: int  NA NA 2003 2003 2003 2003 NA NA 1997 2003 ...
#>  $ assignable_end  : int  NA NA 2015 2015 2015 2015 NA NA 2015 2015 ...
```

The columns are:

* `icdv`: integer value 9 or 10; for ICD-9 or ICD-10

* `dx`:   integer 0 or 1; 0 = procedure code, 1 = diagnostic code

* `full_code`: character string for the ICD code with any appropriate decimal point.

* `code`: characters string for the compact ICD code, that is, the ICD code
  without any decimal point, e.g., the full code C00.1 has the compact code form
  C001.

* `src`: character string denoting the source of the ICD code information.
    * `cms`: The ICD-9-CM, ICD-9-PCS, ICD-10-CM, or ICD-10-PCS codes curated
      by the Centers for Medicare and Medicaid Services (CMS).
    * `cdc`: CDC mortality coding.
    * `who`: World Health Organization.

* `known_start`: The earliest (fiscal) year when source data for the code was
  available in the source code for `medicalcoder`.  Codes from CMS are for the
  United States fiscal year.  Codes from CDC and WHO are calendar year.  The
  United States fiscal year starts October 1 and concludes September 30.  For
  example, fiscal year 2013 started October 1 2012 and concluded September 30 2013.

  To reemphasize that the year is for the data within `medicalcoder`.  For
  ICD-9-CM, the codes went into effect for fiscal year 1980.  The source code
  only has documented source files for the codes dating back to
  1997.

* `known_end`: The latest (fiscal) year when the code was part of the ICD
  system and/or known within the `medicalcoder` lookup tables.

* Assignable codes.  Some codes are header codes, e.g., ICD-10-CM three-digit
  code Z94 is a header code because the four-digit codes Z94.0, Z94.1, Z94.2,
  Z94.3, Z94.4, Z94.5, Z94.6, Z94.7, Z94.8, and Z94.9 exist. All but Z94.8 are
  assignable codes because no five-digit codes with the same initial four-digits
  exist.  Z94.8 is a header code because the five-digit codes Z94.81, Z94.82,
  Z94.83, Z94.84, and Z94.89 exist.
    * `assignable_start`: Earliest (fiscal) year when the code was assignable.
    * `assignable_end`: Latest (fiscal) year when the code was assignable.


``` r
subset(
  x = lookup_icd_codes("^Z94", regex = TRUE, full.codes = TRUE, compact.codes = FALSE),
  subset = src == "cms",
  select = c("full_code", "known_start", "known_end", "assignable_start", "assignable_end")
)
#>    full_code known_start known_end assignable_start assignable_end
#> 1        Z94        2014      2026               NA             NA
#> 5      Z94.0        2014      2026             2014           2026
#> 9      Z94.1        2014      2026             2014           2026
#> 14     Z94.2        2014      2026             2014           2026
#> 17     Z94.3        2014      2026             2014           2026
#> 22     Z94.4        2014      2026             2014           2026
#> 25     Z94.5        2014      2026             2014           2026
#> 29     Z94.6        2014      2026             2014           2026
#> 33     Z94.7        2014      2026             2014           2026
#> 38     Z94.8        2014      2026               NA             NA
#> 41    Z94.81        2014      2026             2014           2026
#> 42    Z94.82        2014      2026             2014           2026
#> 43    Z94.83        2014      2026             2014           2026
#> 44    Z94.84        2014      2026             2014           2026
#> 45    Z94.89        2014      2026             2014           2026
#> 46     Z94.9        2014      2026             2014           2026
```

Additionally, the `get_icd_codes()` method can provide descriptions and the ICD
hierarchy by using the `with.descriptions` and/or `with.hierarchy` arguments.

Functions `lookup_icd_codes()`, `is_icd()`, and `icd_compact_to_full()` are also
provided for working with ICD codes.

More details and examples are in the vignette:

``` r
vignette(topic = "icd", package = "medicalcoder")
```

## Benchmarking

The major factors impacting the expected computation time for applying a
comorbidity algorithm to a data set are:

1. Data size: number of subjects/encounters.
2. Data storage class: `medicalcoder` has been built such that no imports of
   other namespaces is required.  That said, when a `data.table` is passed to
   `comorbidities()` and the `data.table` namespace is available, then S3
   dispatch for `merge` is used, along with some other methods, to reduce memory
   use and reduce computation time.
3. `flag.method`: "current" will take less time than the "cumulative" method.

Details on the benchmarking method, summary graphics, and tables,  can be found
on the `medicalcoder` GitHub
[benchmarking](https://github.com/dewittpe/medicalcoder/tree/main/benchmarking)
directory.

## Testing
