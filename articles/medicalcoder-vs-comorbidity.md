# medicalcoder vs comorbidity

## Introduction

The purpose of this article is to compare the API and results between
medicalcoder and the R package
[comorbidity](https://cran.r-project.org/package=comorbidity) (Gasparini
2018).

``` r
library(medicalcoder)
library(comorbidity)
packageVersion("comorbidity")
## [1] '1.1.0'
packageDescription("comorbidity")$Title
## [1] "Computing Comorbidity Scores"
cat(packageDescription("comorbidity")$Description)
## Computing comorbidity indices and scores such as the weighted Charlson
##   score (Charlson, 1987 <doi:10.1016/0021-9681(87)90171-8>) and the Elixhauser
##   comorbidity score (Elixhauser, 1998 <doi:10.1097/00005650-199801000-00004>)
##   using ICD-9-CM or ICD-10 codes (Quan, 2005 <doi:10.1097/01.mlr.0000182534.19832.83>).
##   Australian and Swedish modifications of the Charlson Comorbidity Index are available
##   as well (Sundararajan, 2004 <doi:10.1016/j.jclinepi.2004.03.012> and Ludvigsson, 2021 
##   <doi:10.2147/CLEP.S282475>), together with different weighting algorithms for both
##   the Charlson and Elixhauser comorbidity scores.
```

The following table is a partial list of similarities and differences
between medicalcoder and comorbidity.

[TABLE]

## Prepare Data for comorbidity

The example data set `mdcr` within medicalcoder is in a format that is
ideal for
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md).
To prepare that data set for use in the
[`comorbidity::comorbidity()`](https://ellessenne.github.io/comorbidity/reference/comorbidity.html)
call we need to split the data in ICD-9 and ICD-10 version. Also,
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
can handle diagnostic and procedure codes simultaneously; a necessary
feature for PCCC.
[`comorbidity::comorbidity()`](https://ellessenne.github.io/comorbidity/reference/comorbidity.html)
only applies comorbidity algorithms based on diagnostic codes and thus
does not expect to see any procedure codes.

``` r
mdcr_icd9dx  <- subset(mdcr, icdv ==  9L & dx == 1L)
mdcr_icd10dx <- subset(mdcr, icdv == 10L & dx == 1L)
```

To make sure we have a fair comparison, we will add rows without a code
for each patid not in the subsets.

``` r
mdcr_icd9dx <-
  rbind(
    mdcr_icd9dx,
    data.frame(patid = setdiff(mdcr$patid, mdcr_icd9dx$patid), icdv = 9L, code = "", dx = 1L)
  )
mdcr_icd10dx <-
  rbind(
    mdcr_icd10dx,
    data.frame(patid = setdiff(mdcr$patid, mdcr_icd10dx$patid), icdv = 10L, code = "", dx = 1L)
  )
```

## Charlson Comorbidities

Applying the Charlson comorbidities to the `mdcr` data set via
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
is done as follows. Important note: the ICD codes used to assess the
Charlson comorbidities between Quan et al. (2005) and Quan et al. (2011)
are the same. The scoring is not. To match the scoring used in
[`comorbidity::comorbidity()`](https://ellessenne.github.io/comorbidity/reference/comorbidity.html)
we need to use the `method = "charlson_quan2011"` in
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md).

``` r
medicalcoder_charlson_results <-
  medicalcoder::comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    dx.var = "dx",
    icdv.var = "icdv",
    poa = 1L, # assume all codes are present on admission
    primarydx = 0L, # assume all codes are secondary diagnoses
    method = "charlson_quan2011"
  )
```

For
[`comorbidity::comorbidity()`](https://ellessenne.github.io/comorbidity/reference/comorbidity.html),
we will need to make two calls, one for the ICD-9 codes and one for the
ICD-10 codes. We will then need to combine the results and then apply a
scoring function.

``` r
comorbidity_charlson_icd9_results <-
  comorbidity::comorbidity(
    x = mdcr_icd9dx,
    id = "patid",
    code = "code",
    map = "charlson_icd9_quan",
    assign0 = TRUE # set less severe comorbidities flags to 0 when more severe comorbidities is also flagged
  )

comorbidity_charlson_icd10_results <-
  comorbidity::comorbidity(
    x = mdcr_icd10dx,
    id = "patid",
    code = "code",
    map = "charlson_icd10_quan",
    assign0 = TRUE
  )

# combine the ICD-9 and ICD-10 results into one set
comorbidity_charlson_results <-
  rbind(comorbidity_charlson_icd9_results, comorbidity_charlson_icd10_results)

comorbidity_charlson_results <-
  aggregate(. ~ patid, data = comorbidity_charlson_results, FUN = max)

# add the attributes to the combine set
attributes(comorbidity_charlson_results)[c("class", "variable.labels", "map")] <-
  attributes(comorbidity_charlson_icd9_results)[c("class", "variable.labels", "map")]

comorbidity_charlson_results[["score"]] <-
  comorbidity::score(
    x = comorbidity_charlson_results,
    weights = "quan",
    assign0 = TRUE
  )

# the score return is a numeric value, setting to integer to match the storage
# mode of medicalcoder
comorbidity_charlson_results[["score"]] <-
  as.integer(comorbidity_charlson_results[["score"]])
```

We can now compare the comorbidity flags between the two packages. First
we check that we have the same number of rows and all the patid are
accounted for.

``` r
nrow(medicalcoder_charlson_results) == nrow(comorbidity_charlson_results)
## [1] TRUE

all(mdcr$patid %in% medicalcoder_charlson_results$patid)
## [1] TRUE
all(medicalcoder_charlson_results$patid %in% mdcr$patid)
## [1] TRUE

all(mdcr$patid %in% comorbidity_charlson_results$patid)
## [1] TRUE
all(comorbidity_charlson_results$patid %in% mdcr$patid)
## [1] TRUE
```

There are differences in the results in terms of the names and numbers
of columns returned.

``` r
dim(medicalcoder_charlson_results)
## [1] 38262    22
names(medicalcoder_charlson_results)
##  [1] "patid"     "aidshiv"   "mal"       "cebvd"     "copd"      "chf"      
##  [7] "dem"       "dmc"       "dm"        "hp"        "mld"       "msld"     
## [13] "mst"       "mi"        "pud"       "pvd"       "rnd"       "rhd"      
## [19] "num_cmrb"  "cmrb_flag" "cci"       "age_score"

dim(comorbidity_charlson_results)
## [1] 38262    19
names(comorbidity_charlson_results)
##  [1] "patid"    "mi"       "chf"      "pvd"      "cevd"     "dementia"
##  [7] "cpd"      "rheumd"   "pud"      "mld"      "diab"     "diabwc"  
## [13] "hp"       "rend"     "canc"     "msld"     "metacanc" "aids"    
## [19] "score"
```

We will compare results column by column. First, we merge the data sets
together by patid.

``` r
charlson_delta <-
  merge(
    x = comorbidity_charlson_results,
    y = medicalcoder_charlson_results,
    all = TRUE,
    by = "patid"
  )
```

The relevant columns:

The following data.frame reports the condition and the corresponding
column from
[`comorbidity::comorbidity()`](https://ellessenne.github.io/comorbidity/reference/comorbidity.html)
and from
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md).

``` r
charlson_columns
##                             Condition comorbidity medicalcoder
## 1                                AIDS        aids      aidshiv
## 2             Cancer (Any malignancy)        canc          mal
## 3     Cancer (Metastatic solid tumor)    metacanc          mst
## 4             Cerebrovascular disease        cevd        cebvd
## 5           Chronic pulmonary disease         cpd         copd
## 6            Congestive heart failure         chf          chf
## 7                            Dementia    dementia          dem
## 8            Hemiplegia or paraplegia          hp           hp
## 9               Myocardial infarction          mi           mi
## 10        Peripheral vascular disease         pvd          pvd
## 11               Peptic ulcer disease         pud          pud
## 12                  Rheumatic disease      rheumd          rhd
## 13           Diabetes (uncomplicated)        diab           dm
## 14             Diabetes (complicated)      diabwc          dmc
## 15                      Renal disease        rend          rnd
## 16               Liver disease (mild)         mld          mld
## 17 Liver disease (moderate or severe)        msld         msld
## 18         Score (based on Quan 2011)       score          cci
```

For each row in `charlson_columns` we will verify that the results are
identical in `charlson_delta` and remove the columns.

``` r
for (i in seq_len(nrow(charlson_columns))) {
  x <- charlson_columns[["comorbidity"]][i]
  y <- charlson_columns[["medicalcoder"]][i]
  if (x == y) {
    x <- paste0(x, ".x")
    y <- paste0(y, ".y")
  }
  e <- base::substitute(identical(charlson_delta[[X]], charlson_delta[[Y]]), list(X = x, Y = y))
  print(e)
  r <- eval(e)
  print(r)
  stopifnot(r)
  charlson_delta[[x]] <- NULL
  charlson_delta[[y]] <- NULL
}
## identical(charlson_delta[["aids"]], charlson_delta[["aidshiv"]])
## [1] TRUE
## identical(charlson_delta[["canc"]], charlson_delta[["mal"]])
## [1] TRUE
## identical(charlson_delta[["metacanc"]], charlson_delta[["mst"]])
## [1] TRUE
## identical(charlson_delta[["cevd"]], charlson_delta[["cebvd"]])
## [1] TRUE
## identical(charlson_delta[["cpd"]], charlson_delta[["copd"]])
## [1] TRUE
## identical(charlson_delta[["chf.x"]], charlson_delta[["chf.y"]])
## [1] TRUE
## identical(charlson_delta[["dementia"]], charlson_delta[["dem"]])
## [1] TRUE
## identical(charlson_delta[["hp.x"]], charlson_delta[["hp.y"]])
## [1] TRUE
## identical(charlson_delta[["mi.x"]], charlson_delta[["mi.y"]])
## [1] TRUE
## identical(charlson_delta[["pvd.x"]], charlson_delta[["pvd.y"]])
## [1] TRUE
## identical(charlson_delta[["pud.x"]], charlson_delta[["pud.y"]])
## [1] TRUE
## identical(charlson_delta[["rheumd"]], charlson_delta[["rhd"]])
## [1] TRUE
## identical(charlson_delta[["diab"]], charlson_delta[["dm"]])
## [1] TRUE
## identical(charlson_delta[["diabwc"]], charlson_delta[["dmc"]])
## [1] TRUE
## identical(charlson_delta[["rend"]], charlson_delta[["rnd"]])
## [1] TRUE
## identical(charlson_delta[["mld.x"]], charlson_delta[["mld.y"]])
## [1] TRUE
## identical(charlson_delta[["msld.x"]], charlson_delta[["msld.y"]])
## [1] TRUE
## identical(charlson_delta[["score"]], charlson_delta[["cci"]])
## [1] TRUE
```

The only columns left in the `charlson_delta` object are from
medicalcoder

``` r
str(charlson_delta)
## 'data.frame':    38262 obs. of  4 variables:
##  $ patid    : int  10000 10002 10005 10006 10008 10010 10014 10015 10017 10018 ...
##  $ num_cmrb : int  1 0 1 0 0 0 0 1 0 0 ...
##  $ cmrb_flag: int  1 0 1 0 0 0 0 1 0 0 ...
##  $ age_score: int  NA NA NA NA NA NA NA NA NA NA ...
```

- `num_cmrb`: number of comorbidities flagged
- `cmrb_flag`: a 0/1 indicator for any comorbidity
- `age_score`: a score adjustment based on age *if* age is provided.

``` r
stopifnot(
  identical(
    names(charlson_delta),
    c("patid", "num_cmrb", "cmrb_flag", "age_score")
  )
)
```

An addition feature the medicalcoder package provides that the
comorbidity package does not, is a summary method for the results, which
can be used to build nice tables via
[kableExtra](https://CRAN.R-project.org/package=kableExtra).

``` r
x <- summary(medicalcoder_charlson_results)[[1]][, c("condition_description", "count", "percent")]

kbl(
  x = x,
  digits = 2,
  col.names = c("", "Count", "Percentage")
) |>
pack_rows("Comorbidity", start_row = 1, end_row = 17) |>
pack_rows("Number of Comorbidities", start_row = 18, end_row = nrow(x))
```

|                                        | Count | Percentage |
|----------------------------------------|-------|------------|
| **Comorbidity**                        |       |            |
| AIDS/HIV                               | 7     | 0.02       |
| Any malignancy                         | 2301  | 6.01       |
| Cerebrovascular disease                | 411   | 1.07       |
| Chronic pulmonary disease              | 3415  | 8.93       |
| Congestive heart failure               | 684   | 1.79       |
| Dementia                               | 13    | 0.03       |
| Diabetes with chronic complications    | 13    | 0.03       |
| Diabetes without chronic complications | 441   | 1.15       |
| Hemiplegia or paraplegia               | 1177  | 3.08       |
| Liver disease, mild                    | 562   | 1.47       |
| Liver disease, moderate to severe      | 206   | 0.54       |
| Metastatic solid tumor                 | 453   | 1.18       |
| Myocardial infarction                  | 10    | 0.03       |
| Peptic ulcer disease                   | 45    | 0.12       |
| Peripheral vascular disease            | 217   | 0.57       |
| Renal disease                          | 877   | 2.29       |
| Rheumatic disease                      | 136   | 0.36       |
| **Number of Comorbidities**            |       |            |
| \>= 1                                  | 9789  | 25.58      |
| \>= 2                                  | 1075  | 2.81       |
| \>= 3                                  | 94    | 0.25       |
| \>= 4                                  | 9     | 0.02       |
| \>= 5                                  | 1     | 0.00       |

## Elixhauser Comorbidities

Applying the Elixhauser comorbidities to the `mdcr` data set via
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
is done as follows.

``` r
medicalcoder_elixhauser_results <-
  medicalcoder::comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    dx.var = "dx",
    icdv.var = "icdv",
    poa = 1L,       # assume all codes are present on admission
    primarydx = 0L, # assume all codes are secondary diagnoses
    method = "elixhauser_quan2005"
  )
```

For
[`comorbidity::comorbidity()`](https://ellessenne.github.io/comorbidity/reference/comorbidity.html),
we will need to make two calls, one for the ICD-9 codes and one for the
ICD-10 codes. We will then need to combine the results and then apply a
scoring function.

``` r
comorbidity_elixhauser_icd9_results <-
  comorbidity::comorbidity(
    x = mdcr_icd9dx,
    id = "patid",
    code = "code",
    map = "elixhauser_icd9_quan",
    assign0 = TRUE # set less severe comorbidities flags to 0 when more severe comorbidities is also flagged
  )

comorbidity_elixhauser_icd10_results <-
  comorbidity::comorbidity(
    x = mdcr_icd10dx,
    id = "patid",
    code = "code",
    map = "elixhauser_icd10_quan",
    assign0 = TRUE
  )

# combine the ICD-9 and ICD-10 results into one set
comorbidity_elixhauser_results <-
  rbind(comorbidity_elixhauser_icd9_results, comorbidity_elixhauser_icd10_results)

comorbidity_elixhauser_results <-
  aggregate(. ~ patid, data = comorbidity_elixhauser_results, FUN = max)
```

We can now compare the comorbidity flags between the two packages. First
we check that we have the same number of rows and all the patid are
accounted for.

``` r
nrow(medicalcoder_elixhauser_results) == nrow(comorbidity_elixhauser_results)
## [1] TRUE

all(mdcr$patid %in% medicalcoder_elixhauser_results$patid)
## [1] TRUE
all(medicalcoder_elixhauser_results$patid %in% mdcr$patid)
## [1] TRUE

all(mdcr$patid %in% comorbidity_elixhauser_results$patid)
## [1] TRUE
all(comorbidity_elixhauser_results$patid %in% mdcr$patid)
## [1] TRUE
```

There are differences in the results in terms of the names and numbers
of columns returned.

``` r
dim(medicalcoder_elixhauser_results)
## [1] 38262    37
names(medicalcoder_elixhauser_results)
##  [1] "patid"               "AIDS"                "LIVER"              
##  [4] "PERIVASC"            "VALVE"               "TUMOR"              
##  [7] "METS"                "LYMPH"               "HYPOTHY"            
## [10] "DM"                  "DMCX"                "LYTES"              
## [13] "WGHTLOSS"            "ALCOHOL"             "OBESE"              
## [16] "BLDLOSS"             "ANEMDEF"             "COAG"               
## [19] "DRUG"                "PSYCH"               "DEPRESS"            
## [22] "NEURO"               "PARA"                "CHF"                
## [25] "HTN_UNCX"            "HTN_CX"              "RENLFAIL"           
## [28] "PULMCIRC"            "CHRNLUNG"            "CARDIAC_ARRHYTHMIAS"
## [31] "ARTH"                "ULCER"               "HTN_C"              
## [34] "num_cmrb"            "cmrb_flag"           "mortality_index"    
## [37] "readmission_index"

dim(comorbidity_elixhauser_results)
## [1] 38262    32
names(comorbidity_elixhauser_results)
##  [1] "patid"    "chf"      "carit"    "valv"     "pcd"      "pvd"     
##  [7] "hypunc"   "hypc"     "para"     "ond"      "cpd"      "diabunc" 
## [13] "diabc"    "hypothy"  "rf"       "ld"       "pud"      "aids"    
## [19] "lymph"    "metacanc" "solidtum" "rheumd"   "coag"     "obes"    
## [25] "wloss"    "fed"      "blane"    "dane"     "alcohol"  "drug"    
## [31] "psycho"   "depre"
```

We will compare results column by column. First, we merge the data sets
together by patid.

``` r
elixhauser_delta <-
  merge(
    x = comorbidity_elixhauser_results,
    y = medicalcoder_elixhauser_results,
    all = TRUE,
    by = "patid"
  )
```

The relevant columns:

The following data.frame reports the condition and the corresponding
column from
[`comorbidity::comorbidity()`](https://ellessenne.github.io/comorbidity/reference/comorbidity.html)
and from
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md).

``` r
elixhauser_columns
##                                        Condition comorbidity
## 1                                       AIDS/HIV        aids
## 2                                  Alcohol abuse     alcohol
## 3                   Anemias (Blood loss anaemia)       blane
## 4                   Anemias (Deficiency anaemia)        dane
## 5                            Cardiac Arrhythmias       carit
## 6       Cancer (Solid tummor without metastasis)    solidtum
## 7                            Cancer (Metastatic)    metacanc
## 8                      Chronic pulmonary disease         cpd
## 9                                   Coagulopathy        coag
## 10                      Congestive Heart Failure         chf
## 11                                    Depression       depre
## 12                        Diabetes (Complicated)       diabc
## 13                      Diabetes (Uncomplicated)     diabunc
## 14                                    Drug abuse        drug
## 15               Fluid and electrolyte disorders         fed
## 16                    Hypertension (Complicated)        hypc
## 17                  Hypertension (Uncomplicated)      hypunc
## 18                                Hypothyroidism     hypothy
## 19                                 Liver disease          ld
## 20                                      Lymphoma       lymph
## 21                                       Obesity        obes
## 22                    Other neurological disease         ond
## 23                                     Paralysis        para
## 24       Peptic ulcer disease excluding bleeding         pud
## 25                 Peripheral Vascular Disorders         pvd
## 26                                     Psychoses      psycho
## 27               Pulmonary Circulation Disorders         pcd
## 28                                 Renal Failure          rf
## 29 Rheumatoid artritis/collaged vascular disease      rheumd
## 30                              Valvular disease        valv
## 31                                   Weight loss       wloss
##           medicalcoder
## 1                 AIDS
## 2              ALCOHOL
## 3              BLDLOSS
## 4              ANEMDEF
## 5  CARDIAC_ARRHYTHMIAS
## 6                TUMOR
## 7                 METS
## 8             CHRNLUNG
## 9                 COAG
## 10                 CHF
## 11             DEPRESS
## 12                DMCX
## 13                  DM
## 14                DRUG
## 15               LYTES
## 16              HTN_CX
## 17            HTN_UNCX
## 18             HYPOTHY
## 19               LIVER
## 20               LYMPH
## 21               OBESE
## 22               NEURO
## 23                PARA
## 24               ULCER
## 25            PERIVASC
## 26               PSYCH
## 27            PULMCIRC
## 28            RENLFAIL
## 29                ARTH
## 30               VALVE
## 31            WGHTLOSS
```

For each row in `elixhauser_columns` we will verify that the results are
identical in `elixhauser_delta` and remove the columns.

``` r
for (i in seq_len(nrow(elixhauser_columns))) {
  x <- elixhauser_columns[["comorbidity"]][i]
  y <- elixhauser_columns[["medicalcoder"]][i]
  if (x == y) {
    x <- paste0(x, ".x")
    y <- paste0(y, ".y")
  }
  e <- base::substitute(identical(elixhauser_delta[[X]], elixhauser_delta[[Y]]), list(X = x, Y = y))
  print(e)
  r <- eval(e)
  print(r)
  stopifnot(r)
  elixhauser_delta[[x]] <- NULL
  elixhauser_delta[[y]] <- NULL
}
## identical(elixhauser_delta[["aids"]], elixhauser_delta[["AIDS"]])
## [1] TRUE
## identical(elixhauser_delta[["alcohol"]], elixhauser_delta[["ALCOHOL"]])
## [1] TRUE
## identical(elixhauser_delta[["blane"]], elixhauser_delta[["BLDLOSS"]])
## [1] TRUE
## identical(elixhauser_delta[["dane"]], elixhauser_delta[["ANEMDEF"]])
## [1] TRUE
## identical(elixhauser_delta[["carit"]], elixhauser_delta[["CARDIAC_ARRHYTHMIAS"]])
## [1] TRUE
## identical(elixhauser_delta[["solidtum"]], elixhauser_delta[["TUMOR"]])
## [1] TRUE
## identical(elixhauser_delta[["metacanc"]], elixhauser_delta[["METS"]])
## [1] TRUE
## identical(elixhauser_delta[["cpd"]], elixhauser_delta[["CHRNLUNG"]])
## [1] TRUE
## identical(elixhauser_delta[["coag"]], elixhauser_delta[["COAG"]])
## [1] TRUE
## identical(elixhauser_delta[["chf"]], elixhauser_delta[["CHF"]])
## [1] TRUE
## identical(elixhauser_delta[["depre"]], elixhauser_delta[["DEPRESS"]])
## [1] TRUE
## identical(elixhauser_delta[["diabc"]], elixhauser_delta[["DMCX"]])
## [1] TRUE
## identical(elixhauser_delta[["diabunc"]], elixhauser_delta[["DM"]])
## [1] TRUE
## identical(elixhauser_delta[["drug"]], elixhauser_delta[["DRUG"]])
## [1] TRUE
## identical(elixhauser_delta[["fed"]], elixhauser_delta[["LYTES"]])
## [1] TRUE
## identical(elixhauser_delta[["hypc"]], elixhauser_delta[["HTN_CX"]])
## [1] TRUE
## identical(elixhauser_delta[["hypunc"]], elixhauser_delta[["HTN_UNCX"]])
## [1] TRUE
## identical(elixhauser_delta[["hypothy"]], elixhauser_delta[["HYPOTHY"]])
## [1] TRUE
## identical(elixhauser_delta[["ld"]], elixhauser_delta[["LIVER"]])
## [1] TRUE
## identical(elixhauser_delta[["lymph"]], elixhauser_delta[["LYMPH"]])
## [1] TRUE
## identical(elixhauser_delta[["obes"]], elixhauser_delta[["OBESE"]])
## [1] TRUE
## identical(elixhauser_delta[["ond"]], elixhauser_delta[["NEURO"]])
## [1] TRUE
## identical(elixhauser_delta[["para"]], elixhauser_delta[["PARA"]])
## [1] TRUE
## identical(elixhauser_delta[["pud"]], elixhauser_delta[["ULCER"]])
## [1] TRUE
## identical(elixhauser_delta[["pvd"]], elixhauser_delta[["PERIVASC"]])
## [1] TRUE
## identical(elixhauser_delta[["psycho"]], elixhauser_delta[["PSYCH"]])
## [1] TRUE
## identical(elixhauser_delta[["pcd"]], elixhauser_delta[["PULMCIRC"]])
## [1] TRUE
## identical(elixhauser_delta[["rf"]], elixhauser_delta[["RENLFAIL"]])
## [1] TRUE
## identical(elixhauser_delta[["rheumd"]], elixhauser_delta[["ARTH"]])
## [1] TRUE
## identical(elixhauser_delta[["valv"]], elixhauser_delta[["VALVE"]])
## [1] TRUE
## identical(elixhauser_delta[["wloss"]], elixhauser_delta[["WGHTLOSS"]])
## [1] TRUE
```

The remaining columns in the `elixhauser_delta` object are specific to
medicalcoder, save patid.

``` r
str(elixhauser_delta)
## 'data.frame':    38262 obs. of  6 variables:
##  $ patid            : int  10000 10002 10005 10006 10008 10010 10014 10015 10017 10018 ...
##  $ HTN_C            : int  0 0 0 0 0 0 1 0 0 0 ...
##  $ num_cmrb         : int  1 2 1 0 0 2 3 1 0 1 ...
##  $ cmrb_flag        : int  1 1 1 0 0 1 1 1 0 1 ...
##  $ mortality_index  : int  3 -10 14 0 0 16 19 5 0 -5 ...
##  $ readmission_index: int  8 1 21 0 0 15 17 6 0 4 ...
```

``` r
stopifnot(identical(names(elixhauser_delta), c("patid", "HTN_C", "num_cmrb", "cmrb_flag", "mortality_index", "readmission_index")))
```

- `HTN_C`: *any* hypertension - added to simplify the calculation of the
  mortality and readmission indices based on weights from AHRQ.

- `num_cmrb`: Number of comorbidities flagged

- `cmrb_flag`: a 0/1 indicator for *any* comorbidity being flagged

- `mortality_index` and `readmission_index`: index scores based on the
  AHRQ weights (Healthcare Cost and Utilization Project (HCUP) 2017).

An addition feature of the medicalcoder package provides that the
comorbidity package does not, is a summary method for the results, which
can be used to build nice tables via
[kableExtra](https://CRAN.R-project.org/package=kableExtra).

``` r
x <- summary(medicalcoder_elixhauser_results)[[1]][, c("condition", "count", "percent")]

kbl(
  x = x,
  digits = 2,
  col.names = c("", "Count", "Percentage")
) |>
pack_rows("Comorbidity", start_row = 1, end_row = which(x$condition == ">= 1") - 1L) |>
pack_rows("Number of Comorbidities", start_row = which(x$condition == ">= 1"), end_row = nrow(x))
```

|                             | Count | Percentage |
|-----------------------------|-------|------------|
| **Comorbidity**             |       |            |
| AIDS                        | 7     | 0.02       |
| ALCOHOL                     | 34    | 0.09       |
| ANEMDEF                     | 303   | 0.79       |
| ARTH                        | 359   | 0.94       |
| BLDLOSS                     | 76    | 0.20       |
| CHF                         | 684   | 1.79       |
| CHRNLUNG                    | 3415  | 8.93       |
| COAG                        | 1165  | 3.04       |
| DEPRESS                     | 855   | 2.23       |
| DM                          | 350   | 0.91       |
| DMCX                        | 104   | 0.27       |
| DRUG                        | 251   | 0.66       |
| HTN_C                       | 1459  | 3.81       |
| HYPOTHY                     | 683   | 1.79       |
| LIVER                       | 795   | 2.08       |
| LYMPH                       | 195   | 0.51       |
| LYTES                       | 4763  | 12.45      |
| METS                        | 453   | 1.18       |
| NEURO                       | 4028  | 10.53      |
| OBESE                       | 573   | 1.50       |
| PARA                        | 1177  | 3.08       |
| PERIVASC                    | 217   | 0.57       |
| PSYCH                       | 52    | 0.14       |
| PULMCIRC                    | 692   | 1.81       |
| RENLFAIL                    | 862   | 2.25       |
| TUMOR                       | 1144  | 2.99       |
| ULCER                       | 26    | 0.07       |
| VALVE                       | 771   | 2.02       |
| WGHTLOSS                    | 1050  | 2.74       |
| **Number of Comorbidities** |       |            |
| \>= 1                       | 17316 | 45.26      |
| \>= 2                       | 6224  | 16.27      |
| \>= 3                       | 2055  | 5.37       |
| \>= 4                       | 662   | 1.73       |
| \>= 5                       | 204   | 0.53       |
| \>= 6                       | 62    | 0.16       |
| \>= 7                       | 14    | 0.04       |
| \>= 8                       | 4     | 0.01       |
| \>= 9                       | 2     | 0.01       |

## Benchmarking

The medicalcoder package was built to use base R methods and has zero
imports. That said, if the input data set to
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
is a [`data.table`](https://cran.r-project.org/package=data.table) and
the `data.table` namespace is available, the S3 methods for `data.table`
will be used and there will be a performance improvement.

comorbidity imports several namespaces, including `data.table`, and uses
`data.table` for efficiency.

In the following benchmark we will look at the time required to apply
the Charlson comorbidity method to the `mdcr` data set via
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
and
[`comorbidity::comorbidity()`](https://ellessenne.github.io/comorbidity/reference/comorbidity.html).
We will consider the cases when inputting a data.frame and when
inputting a data.table. To support that work we make some copies of the
input data and set the copies to be `data.tables`.

Code (click to toggle view/fold)

``` r
mdcrDT <- data.table::copy(mdcr)
data.table::setDT(mdcrDT)
mdcr_icd9dxDT <- data.table::copy(mdcr_icd9dx)
mdcr_icd10dxDT <- data.table::copy(mdcr_icd10dx)
data.table::setDT(mdcr_icd9dxDT)
data.table::setDT(mdcr_icd10dxDT)
```

Next we define four functions to simplify calling the code multiple
times.

Code (click to toggle view/fold)

``` r
medicalcoder_charlson_results <- function() {
  medicalcoder::comorbidities(
    data = mdcr,
    id.vars = "patid",
    icd.codes = "code",
    dx.var = "dx",
    icdv.var = "icdv",
    poa = 1L,
    primarydx = 0L,
    method = "charlson_quan2011"
  )
}

medicalcoder_charlson_results_DT <- function() {
  medicalcoder::comorbidities(
    data = mdcrDT,
    id.vars = "patid",
    icd.codes = "code",
    dx.var = "dx",
    icdv.var = "icdv",
    poa = 1L,
    primarydx = 0L,
    method = "charlson_quan2011"
  )
}

comorbidity_charlson_results <- function() {
  comorbidity_charlson_icd9_results <-
    comorbidity::comorbidity(
      x = mdcr_icd9dx,
      id = "patid",
      code = "code",
      map = "charlson_icd9_quan",
      assign0 = TRUE # set less severe comorbidities flags to 0 when more severe comorbidities is also flagged
    )

  comorbidity_charlson_icd10_results <-
    comorbidity::comorbidity(
      x = mdcr_icd10dx,
      id = "patid",
      code = "code",
      map = "charlson_icd10_quan",
      assign0 = TRUE
    )

# combine the ICD-9 and ICD-10 results into one set
  comorbidity_charlson_results <-
    rbind(comorbidity_charlson_icd9_results, comorbidity_charlson_icd10_results)

  comorbidity_charlson_results <-
    aggregate(. ~ patid, data = comorbidity_charlson_results, FUN = max)

# add the attributes to the combine set
  attributes(comorbidity_charlson_results)[c("class", "variable.labels", "map")] <-
    attributes(comorbidity_charlson_icd9_results)[c("class", "variable.labels", "map")]

  comorbidity_charlson_results[["score"]] <-
    comorbidity::score(
      x = comorbidity_charlson_results,
      weights = "quan",
      assign0 = TRUE
    )

# the score return is a numeric value, setting to integer to match the storage
# mode of medicalcoder
  comorbidity_charlson_results[["score"]] <-
    as.integer(comorbidity_charlson_results[["score"]])
}

comorbidity_charlson_results_DT <- function() {
  comorbidity_charlson_icd9_results <-
    comorbidity::comorbidity(
      x = mdcr_icd9dxDT,
      id = "patid",
      code = "code",
      map = "charlson_icd9_quan",
      assign0 = TRUE # set less severe comorbidities flags to 0 when more severe comorbidities is also flagged
    )

  comorbidity_charlson_icd10_results <-
    comorbidity::comorbidity(
      x = mdcr_icd10dxDT,
      id = "patid",
      code = "code",
      map = "charlson_icd10_quan",
      assign0 = TRUE
    )

# combine the ICD-9 and ICD-10 results into one set
  comorbidity_charlson_results <-
    rbind(comorbidity_charlson_icd9_results, comorbidity_charlson_icd10_results)

  comorbidity_charlson_results <-
    aggregate(. ~ patid, data = comorbidity_charlson_results, FUN = max)

# add the attributes to the combine set
  attributes(comorbidity_charlson_results)[c("class", "variable.labels", "map")] <-
    attributes(comorbidity_charlson_icd9_results)[c("class", "variable.labels", "map")]

  comorbidity_charlson_results[["score"]] <-
    comorbidity::score(
      x = comorbidity_charlson_results,
      weights = "quan",
      assign0 = TRUE
    )

# the score return is a numeric value, setting to integer to match the storage
# mode of medicalcoder
  comorbidity_charlson_results[["score"]] <-
    as.integer(comorbidity_charlson_results[["score"]])
}
```

Next we evaluate each function 20 times and record the total execution
time, in seconds, for each evaluation.

Code (click to toggle view/fold)

``` r
medicalcoder_times <- numeric(0)
medicalcoder_times_DT <- numeric(0)
comorbidity_times <- numeric(0)
comorbidity_times_DT <- numeric(0)

for (i in 1:20) {
  tic <- Sys.time()
  x <- medicalcoder_charlson_results()
  toc <- Sys.time()
  medicalcoder_times <- c(medicalcoder_times, as.numeric(difftime(toc, tic, units = "secs")))

  tic <- Sys.time()
  x <- medicalcoder_charlson_results_DT()
  toc <- Sys.time()
  medicalcoder_times_DT <- c(medicalcoder_times_DT, as.numeric(difftime(toc, tic, units = "secs")))

  tic <- Sys.time()
  x <- comorbidity_charlson_results()
  toc <- Sys.time()
  comorbidity_times <- c(comorbidity_times, as.numeric(difftime(toc, tic, units = "secs")))

  tic <- Sys.time()
  x <- comorbidity_charlson_results_DT()
  toc <- Sys.time()
  comorbidity_times_DT <- c(comorbidity_times_DT, as.numeric(difftime(toc, tic, units = "secs")))
}
```

The table below reports the summary of the time required to run each
method.
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
with a `data.table` input requires the least time to compute. Due in
part to the need to aggregate multiple calls for
[`comorbidity::comorbidity()`](https://ellessenne.github.io/comorbidity/reference/comorbidity.html),
the call to
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
with a `data.frame` is still much faster than
[`comorbidity::comorbidity()`](https://ellessenne.github.io/comorbidity/reference/comorbidity.html).

[TABLE]

## References

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

Gasparini, Alessandro. 2018. “Comorbidity: An r Package for Computing
Comorbidity Scores.” *Journal of Open Source Software* 3: 648.
<https://doi.org/10.21105/joss.00648>.

Glasheen, William P, Tristan Cordier, Rajiv Gumpina, Gil Haugh, Jared
Davis, and Andrew Renda. 2019. “Charlson Comorbidity Index: ICD-9 Update
and ICD-10 Translation.” *American Health & Drug Benefits* 12 (4): 188.
<https://pubmed.ncbi.nlm.nih.gov/31428236/>.

Healthcare Cost and Utilization Project (HCUP). 2017. “Elixhauser
Comorbidity Software for ICD-9-CM.”
<https://hcup-us.ahrq.gov/toolssoftware/comorbidity/comorbidity.jsp>.

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
