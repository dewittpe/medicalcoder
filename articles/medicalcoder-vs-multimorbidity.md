# medicalcoder vs multimorbidity

## Introduction

The purpose of this article is to compare the API and results between
medicalcoder and the R package
[multimorbidity](https://cran.r-project.org/package=multimorbidity)
(Bensken 2023).

``` r
library(data.table)
library(medicalcoder)
library(multimorbidity)
packageVersion("multimorbidity")
## [1] '0.5.1'
packageDescription("multimorbidity")$Title
## [1] "Harmonizing Various Comorbidity, Multimorbidity, and Frailty\nMeasures"
cat(packageDescription("multimorbidity")$Description)
## Identifying comorbidities, frailty, and multimorbidity in claims 
##     and administrative data is often a duplicative process.
##     The functions contained in this package are meant to first prepare the data to a format
##     acceptable by all other packages, then provide a uniform and simple approach to
##     generate comorbidity and multimorbidity metrics based on these claims data. The package
##     is ever evolving to include new metrics, and is always looking for new measures to include.
##     The citations used in this package include the following publications: 
##     Anne Elixhauser, Claudia Steiner, D. Robert Harris, Rosanna M. Coffey (1998) <doi:10.1097/00005650-199801000-00004>,
##     Brian J Moore, Susan White, Raynard Washington, et al. (2017) <doi:10.1097/MLR.0000000000000735>,
##     Mary E. Charlson, Peter Pompei, Kathy L. Ales, C. Ronald MacKenzie (1987) <doi:10.1016/0021-9681(87)90171-8>,
##     Richard A. Deyo, Daniel C. Cherkin, Marcia A. Ciol (1992) <doi:10.1016/0895-4356(92)90133-8>,
##     Hude Quan, Vijaya Sundararajan, Patricia Halfon, et al. (2005) <doi:10.1097/01.mlr.0000182534.19832.83>,
##     Dae Hyun Kim, Sebastian Schneeweiss, Robert J Glynn, et al. (2018) <doi:10.1093/gerona/glx229>,
##     Melissa Y Wei, David Ratz, Kenneth J Mukamal (2020) <doi:10.1111/jgs.16310>,
##     Kathryn Nicholson, Amanda L. Terry, Martin Fortin, et al. (2015) <doi:10.15256/joc.2015.5.61>,
##     Martin Fortin, José Almirall, and Kathryn Nicholson (2017)<doi:10.15256/joc.2017.7.122>.
```

## Prepare Data for multimorbidity

The example data set `mdcr` within medicalcoder is in a format that is
ideal for
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
and for the
[`multimorbidity::charlson()`](https://rdrr.io/pkg/multimorbidity/man/charlson.html)
call. The only issue that needs to be addressed is that
[`multimorbidity::charlson()`](https://rdrr.io/pkg/multimorbidity/man/charlson.html)
is expecting to only see diagnostic codes so we will omit the procedure
codes from `mdcr`.

``` r
mdcr_dx <- subset(mdcr, dx == 1)

# add any patid omit
mdcr_dx <-
  rbind(
    mdcr_dx,
    data.frame(
      patid = setdiff(mdcr$patid, mdcr_dx$patid),
      icdv = 10L, code = "", dx = 1L
    )
  )
```

## Charlson Comorbidities

A detailed comparison between
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
and the methods in the
[`multimorbidity::charlson()`](https://rdrr.io/pkg/multimorbidity/man/charlson.html)
call is presented here.

``` r
tic <- Sys.time()

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

toc <- Sys.time()

difftime(toc, tic, units = "secs")
## Time difference of 0.6771817 secs
```

Calling
[`multimorbidity::charlson()`](https://rdrr.io/pkg/multimorbidity/man/charlson.html)

``` r
tic <- Sys.time()

multimorbidity_charlson_results <-
  multimorbidity::charlson(
    dat = mdcr_dx,
    id  = patid,
    version = 19, # default - both ICD-9 and ICD-10 data
    version_var = icdv
  )

toc <- Sys.time()

difftime(toc, tic, units = "secs")
## Time difference of 12.83703 secs
```

### Differences in the results

We build a `data.frame` `deltas` to explore the differences in the
results between
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
and
[`multimorbidity::charlson()`](https://rdrr.io/pkg/multimorbidity/man/charlson.html).
One important difference is that
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
returns a `data.frame` with the id variable names as passed to the
function whereas
[`multimorbidity::charlson()`](https://rdrr.io/pkg/multimorbidity/man/charlson.html)
returns a `data.frame` with the id column named id.

Also, there is a difference in the storage mode for the indicator
columns.
[`multimorbidity::charlson()`](https://rdrr.io/pkg/multimorbidity/man/charlson.html)
returns numeric columns whereas
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
return integer columns.

``` r
multimorbidity_charlson_results <-
  multimorbidity_charlson_results |>
  dplyr::mutate_if(is.numeric, as.integer)

deltas <-
  merge(
    x = medicalcoder_charlson_results,
    y = multimorbidity_charlson_results,
    all = TRUE,
    by.x = "patid",
    by.y = "id"
  )
setDT(deltas)
```

We will compare the columns between the two methods. None of the results
are the same.

``` r
dcolumns <- data.table::fread(text = "
medicalcoder | multimorbidity
aidshiv | charlson_hiv
mal | charlson_malig
cebvd |charlson_cerebro
copd | charlson_chronic_pulm
chf | charlson_chf
dem | charlson_dementia
dmc | charlson_diab_c
dm | charlson_diab_uc
hp | charlson_hemi_para
mld | charlson_mild_liv
msld | charlson_mod_sev_liv
mst | charlson_met_solid
mi | charlson_myocar
pud | charlson_peptic_ulcer
pvd | charlson_periph_vasc
rnd | charlson_renal
rhd | charlson_rheum")

Map(
  f = function (x, y) {
    z <- identical(deltas[[x]], deltas[[y]])
    z
  },
  x = dcolumns$medicalcoder,
  y = dcolumns$multimorbidity
) |>
do.call(c, args = _)
## aidshiv     mal   cebvd    copd     chf     dem     dmc      dm      hp     mld 
##   FALSE   FALSE   FALSE   FALSE   FALSE   FALSE   FALSE   FALSE   FALSE   FALSE 
##    msld     mst      mi     pud     pvd     rnd     rhd 
##   FALSE   FALSE   FALSE   FALSE   FALSE   FALSE   FALSE
```

Let’s dig into one of the conditions: Rheumatic disease (“rhd” in
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md),
“charlson_rheum” in
[`multimorbidity::charlson()`](https://rdrr.io/pkg/multimorbidity/man/charlson.html)).

``` r
deltas[rhd != charlson_rheum, .(patid, rhd, charlson_rheum)]
##      patid   rhd charlson_rheum
##      <int> <int>          <int>
##   1: 10093     1              0
##   2: 10216     1              0
##   3: 11319     1              0
##   4: 11388     1              0
##   5: 12029     1              0
##  ---                           
## 132: 93711     1              0
## 133: 93777     1              0
## 134: 94515     1              0
## 135: 97078     1              0
## 136: 99643     1              0
deltas[rhd != charlson_rheum, .N, keyby = .(rhd, charlson_rheum)]
## Key: <rhd, charlson_rheum>
##      rhd charlson_rheum     N
##    <int>          <int> <int>
## 1:     1              0   136
```

All the differences appear to be from
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
flagging the condition and
[`multimorbidity::charlson()`](https://rdrr.io/pkg/multimorbidity/man/charlson.html)
not flagging the condition. Let’s look at the ICD codes
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
flagged in the records

``` r
missingcodes <-
  merge(
    x = subset(mdcr, patid %in% deltas[rhd != charlson_rheum, patid]),
    y = subset(medicalcoder::get_charlson_codes(), charlson_quan2005 == 1L),
    by = c("code", "icdv", "dx")
  )
missingcodes <- subset(missingcodes, condition == "rhd")
missingcodes <- unique(missingcodes[, c("icdv", "dx", "code", "full_code")])
setDT(missingcodes)
missingcodes[, codeid := 1:.N]

missingcodes
##      icdv    dx   code full_code codeid
##     <int> <int> <char>    <char>  <int>
##  1:     9     1   7100     710.0      1
##  2:     9     1   7101     710.1      2
##  3:     9     1   7103     710.3      3
##  4:     9     1   7104     710.4      4
##  5:     9     1   7140     714.0      5
##  6:     9     1    725       725      6
##  7:    10     1   M059     M05.9      7
##  8:    10     1   M069     M06.9      8
##  9:    10     1  M3213    M32.13      9
## 10:    10     1  M3214    M32.14     10
## 11:    10     1  M3219    M32.19     11
## 12:    10     1   M328     M32.8     12
## 13:    10     1   M329     M32.9     13
## 14:    10     1  M3300    M33.00     14
## 15:    10     1  M3313    M33.13     15
## 16:    10     1  M3320    M33.20     16
## 17:    10     1  M3481    M34.81     17
## 18:    10     1   M349     M34.9     18
## 19:    10     1   M351     M35.1     19
```

As we see below, all these codes are flagged by
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
and not flagged by
[`multimorbidity::charlson()`](https://rdrr.io/pkg/multimorbidity/man/charlson.html).

``` r
medicalcoder::comorbidities(
  data = missingcodes,
  id.vars = "codeid",
  icd.codes = "code",
  icdv.var = "icdv",
  dx.var = "dx",
  method = "charlson_quan2005",
  poa = 1L,
  primarydx = 0L
)$rhd
##  [1] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1

multimorbidity::charlson(
  dat = missingcodes,
  id = codeid,
  version = 19,
  version_var = icdv
)$charlson_rheum
##  [1] 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
```

Referencing Table 1 of Quan et al. (2005), we see that the ICD-10 codes
for Rheumatic disease are:

> M05.x, M06.x, M31.5, M32.x–M34.x, M35.1, M35.3, M36.0

And the enhanced ICD-9-CM codes are:

> 446.5, 710.0–710.4, 714.0–714.2, 714.8, 725.x

## Conclusions

[`multimorbidity::charlson()`](https://rdrr.io/pkg/multimorbidity/man/charlson.html)
takes more time to evaluate the same data set than
[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
and
[`multimorbidity::charlson()`](https://rdrr.io/pkg/multimorbidity/man/charlson.html)
reports several false negatives.

[`medicalcoder::comorbidities()`](http://www.peteredewitt.com/medicalcoder/reference/comorbidities.md)
is a preferable utility.

## References

Bensken, Wyatt. 2023. *Multimorbidity: Harmonizing Various Comorbidity,
Multimorbidity, and Frailty Measures*.
<https://doi.org/10.32614/CRAN.package.multimorbidity>.

Quan, Hude, Vijaya Sundararajan, Patricia Halfon, Andrew Fong, Bernard
Burnand, Jean-Christophe Luthi, L Duncan Saunders, Catherine A. Beck,
Thomas E. Feasby, and William A. Ghali. 2005. “Coding Algorithms for
Defining Comorbidities in ICD-9-CM and ICD-10 Administrative Data.”
*Medical Care* 43 (11): 1130–39.
<https://doi.org/10.1097/01.mlr.0000182534.19832.83>.
