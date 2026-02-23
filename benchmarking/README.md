<!-- README.md is generated from README.Rmd. Please edit that file -->



# Benchmarking `medicalcoder`

The major factors impacting the expected computation time for applying a
comorbidity algorithm to a data set are:

1. Data size: number of encounters.
2. Data storage class: `medicalcoder` has been built such that no imports of
   other namespaces is required. That said, when a `data.table` is passed to
   `comorbidities()` and the `data.table` namespace is available, then S3
   dispatch for `merge` is used, along with some other methods, to reduce memory
   use and reduce computation time. When a `tibble` is passed and tidyverse
   namespaces are available, the tibble-aware path reduces time relative to a
   base `data.frame`, though `data.table` remains the fastest option.
3. flag.method: "current" will take less time than the "cumulative" method.

In the following examples, each generated data set was benchmark by

* `method`:
    * charlson_quan2005
    * elixhauser_quan2005
    * pccc_v3.1 without subconditions
    * pccc_v3.1 with subconditions
* data class:
    * data.frame
    * tibble
    * data.table
* `flag.method`
    * current
    * cumulative










## MIMIC-IV Demo Data

The following summary is based on resampling the [MIMIC-IV Clinical Database
Demo](https://physionet.org/content/mimic-iv-demo/2.2/) data set provided by
PhysioNet.[^1][^2] Using the MIMIC-IV Clinical Database Demo set will allow others to benchmark
`medicalcoder` on their system with the same data as used here.

[^1]: Johnson, A., Bulgarelli, L., Pollard, T., Horng, S., Celi, L. A., & Mark, R. (2023). MIMIC-IV Clinical Database Demo (version 2.2). PhysioNet. RRID:SCR_007345. https://doi.org/10.13026/dp1f-ex47

[^2]: Goldberger, A., Amaral, L., Glass, L., Hausdorff, J., Ivanov, P. C., Mark, R., ... & Stanley, H. E. (2000). PhysioBank, PhysioToolkit, and PhysioNet: Components of a new research resource for complex physiologic signals. Circulation [Online]. 101 (23), pp. e215–e220. RRID:SCR_007345.

The MIMIC-IV demo data consists of
100 subjects and a total of
275
encounters.  A mix of ICD-9 and ICD-10 diagnostic and procedure codes are in the
data.

85 (85.00\%) of the subjects had at least
one PCCC comorbidity,
80 (80.00\%)
of the subjects had at least one Charlson comorbidity, and
97 (97.00\%)
of the subjects had at least one Elixhauser comorbidity.

The subjects were resampled to generate data sets with upto 1,000,000 subjects.

<img src="benchmark_mimiciv_composite.svg"/>

In general, the expected time to apply a comorbidity method is lower for
`tibble`s than for base `data.frame`s, and lower still for `data.table`s. Best
observed case: a `data.table` took
0.0729237
the time of a `data.frame`. Best case for `tibble`s was
0.2046715
the time of a `data.frame`.

## All Comorbidities

Some of the computational expense in building the indicators for the
comorbidities is due to the number of subjects/encounters with at least one
comorbidity. We generated data sets where all subjects on all encounters had at
least one ICD code mapping to a comorbidity.  The benchmarking results are
summarized in the following graphic.

<img src="benchmark_all_cmrb_composite.svg"/>
