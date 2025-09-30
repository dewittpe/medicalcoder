<!-- README.md is generated from README.Rmd. Please edit that file -->



# `medicalcoder`: An R package for working with ICD codes and Comorbidity Algorithms <img src="man/figures/medicalcoder_600x600_hex.png" width="150px" align="right" alt = "medicalcoder hex logo"/>

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
       [`data.table](https://cran.r-project.org/package=data.table) to the
       `comorbidities()` function compared to a base `data.frame` or the
       Tidyverse's `tibble`.  (See benchmarking section).

   - Internal lookup tables
     - All required data are included in the package. If you have the .tar.gz
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

- Unified access to multiple comorbidity algorithms through a single function
  (`comorbidities()`).
- Support for both ICD-9 and ICD-10 diagnostic and procedure codes.
- Longitudinal patient-level comorbidity flagging using present-on-admission indicators.
- Fully self-contained package (no external dependencies).

## Benchmarking

The major factors impacting the expected computation time for applying a
comorbidity algorithm to a data set are:

1. Data size: number of subjects/encounters.
2. Data storage class: `medicalcoder` has been built such that no imports of
   other namespaces is required.  That said, when a `data.table` is passed to
   `comorbidities()` and the `data.table` namespace is available, then S3
   dispatch for `merge` is used, along with some other methods, to reduce memory
   use and reduce computation time.
3. flag.method: "current" will take less time than the "cumulative" method.

Details on the benchmarking can be found on the
[`medicalcoder` GitHub](https://github.com/dewittpe/medicalcoder/tree/main/benchmarking).
There you can view a
[graphic](https://github.com/dewittpe/medicalcoder/tree/main/benchmarking/benchmark2-composite.svg)
showing the expected time, relative time, and expected memory usage for several
comorbidity algorithms, flagging methods, and input data structrue.
<!-- NOTE: Graphic is omitted from the README because the graphic is too large
to be part of the package that is provided to CRAN -->

In general, the expected time to apply a comorbidity method is the same between
`data.frame`s and `tibble`s.



<table>
 <thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="6"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Charlson (Quan 2005)</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="6"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Elixhauser (Quan 2005)</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="6"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">PCCC v3.1</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="6"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">PCCC v3.1 (with subconditions)</div></th>
</tr>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">current</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">cummulative</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">current</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">cummulative</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">current</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">cummulative</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">current</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">cummulative</div></th>
</tr>
  <tr>
   <th style="text-align:left;"> Encounters </th>
   <th style="text-align:right;"> Time (seconds) </th>
   <th style="text-align:right;"> Relative time </th>
   <th style="text-align:right;"> Memory (GB) </th>
   <th style="text-align:right;"> Time (seconds) </th>
   <th style="text-align:right;"> Relative time </th>
   <th style="text-align:right;"> Memory (GB) </th>
   <th style="text-align:right;"> Time (seconds) </th>
   <th style="text-align:right;"> Relative time </th>
   <th style="text-align:right;"> Memory (GB) </th>
   <th style="text-align:right;"> Time (seconds) </th>
   <th style="text-align:right;"> Relative time </th>
   <th style="text-align:right;"> Memory (GB) </th>
   <th style="text-align:right;"> Time (seconds) </th>
   <th style="text-align:right;"> Relative time </th>
   <th style="text-align:right;"> Memory (GB) </th>
   <th style="text-align:right;"> Time (seconds) </th>
   <th style="text-align:right;"> Relative time </th>
   <th style="text-align:right;"> Memory (GB) </th>
   <th style="text-align:right;"> Time (seconds) </th>
   <th style="text-align:right;"> Relative time </th>
   <th style="text-align:right;"> Memory (GB) </th>
   <th style="text-align:right;"> Time (seconds) </th>
   <th style="text-align:right;"> Relative time </th>
   <th style="text-align:right;"> Memory (GB) </th>
  </tr>
 </thead>
<tbody>
  <tr grouplength="4"><td colspan="25" style="border-bottom: 1px solid;"><strong>data.frame</strong></td></tr>
<tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> 1,000 </td>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.11 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.49 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.15 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 1.25 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.32 </td>
   <td style="text-align:right;"> 0.18 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 1.36 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.33 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> 10,000 </td>
   <td style="text-align:right;"> 0.87 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 3.80 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.42 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 5.06 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.52 </td>
   <td style="text-align:right;"> 1.47 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 12.48 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.98 </td>
   <td style="text-align:right;"> 1.61 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 13.45 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.03 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> 100,000 </td>
   <td style="text-align:right;"> 8.68 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.83 </td>
   <td style="text-align:right;"> 36.51 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 2.07 </td>
   <td style="text-align:right;"> 9.03 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.81 </td>
   <td style="text-align:right;"> 51.85 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 3.03 </td>
   <td style="text-align:right;"> 14.49 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.98 </td>
   <td style="text-align:right;"> 118.32 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 8.04 </td>
   <td style="text-align:right;"> 15.67 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.06 </td>
   <td style="text-align:right;"> 128.19 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 8.61 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> 1,000,000 </td>
   <td style="text-align:right;"> 74.39 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 5.71 </td>
   <td style="text-align:right;"> 353.93 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 18.22 </td>
   <td style="text-align:right;"> 83.11 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 5.87 </td>
   <td style="text-align:right;"> 490.34 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 29.04 </td>
   <td style="text-align:right;"> 134.46 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 7.74 </td>
   <td style="text-align:right;"> 1229.21 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 78.00 </td>
   <td style="text-align:right;"> 152.98 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 8.44 </td>
   <td style="text-align:right;"> 1334.56 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 78.96 </td>
  </tr>
  <tr grouplength="4"><td colspan="25" style="border-bottom: 1px solid;"><strong>data.table</strong></td></tr>
<tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> 1,000 </td>
   <td style="text-align:right;"> 0.08 </td>
   <td style="text-align:right;"> 0.88 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.24 </td>
   <td style="text-align:right;"> 0.73 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 0.87 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.37 </td>
   <td style="text-align:right;"> 0.78 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.13 </td>
   <td style="text-align:right;"> 0.86 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.92 </td>
   <td style="text-align:right;"> 0.75 </td>
   <td style="text-align:right;"> 0.32 </td>
   <td style="text-align:right;"> 0.17 </td>
   <td style="text-align:right;"> 0.97 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 1.05 </td>
   <td style="text-align:right;"> 0.78 </td>
   <td style="text-align:right;"> 0.33 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> 10,000 </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 1.90 </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> 0.41 </td>
   <td style="text-align:right;"> 0.69 </td>
   <td style="text-align:right;"> 0.73 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 2.87 </td>
   <td style="text-align:right;"> 0.57 </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 0.35 </td>
   <td style="text-align:right;"> 6.96 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 0.90 </td>
   <td style="text-align:right;"> 1.21 </td>
   <td style="text-align:right;"> 0.75 </td>
   <td style="text-align:right;"> 0.35 </td>
   <td style="text-align:right;"> 7.86 </td>
   <td style="text-align:right;"> 0.58 </td>
   <td style="text-align:right;"> 0.94 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> 100,000 </td>
   <td style="text-align:right;"> 5.04 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 0.81 </td>
   <td style="text-align:right;"> 16.21 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 1.90 </td>
   <td style="text-align:right;"> 5.70 </td>
   <td style="text-align:right;"> 0.64 </td>
   <td style="text-align:right;"> 0.85 </td>
   <td style="text-align:right;"> 23.79 </td>
   <td style="text-align:right;"> 0.46 </td>
   <td style="text-align:right;"> 2.92 </td>
   <td style="text-align:right;"> 8.75 </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 56.39 </td>
   <td style="text-align:right;"> 0.48 </td>
   <td style="text-align:right;"> 7.03 </td>
   <td style="text-align:right;"> 10.22 </td>
   <td style="text-align:right;"> 0.66 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 63.92 </td>
   <td style="text-align:right;"> 0.51 </td>
   <td style="text-align:right;"> 7.44 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> 1,000,000 </td>
   <td style="text-align:right;"> 38.00 </td>
   <td style="text-align:right;"> 0.52 </td>
   <td style="text-align:right;"> 6.28 </td>
   <td style="text-align:right;"> 136.10 </td>
   <td style="text-align:right;"> 0.39 </td>
   <td style="text-align:right;"> 14.77 </td>
   <td style="text-align:right;"> 43.80 </td>
   <td style="text-align:right;"> 0.54 </td>
   <td style="text-align:right;"> 6.65 </td>
   <td style="text-align:right;"> 199.48 </td>
   <td style="text-align:right;"> 0.41 </td>
   <td style="text-align:right;"> 22.77 </td>
   <td style="text-align:right;"> 69.70 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 9.55 </td>
   <td style="text-align:right;"> 532.00 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 67.04 </td>
   <td style="text-align:right;"> 81.12 </td>
   <td style="text-align:right;"> 0.54 </td>
   <td style="text-align:right;"> 8.84 </td>
   <td style="text-align:right;"> 612.92 </td>
   <td style="text-align:right;"> 0.46 </td>
   <td style="text-align:right;"> 69.18 </td>
  </tr>
  <tr grouplength="4"><td colspan="25" style="border-bottom: 1px solid;"><strong>tibble</strong></td></tr>
<tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> 1,000 </td>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.35 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.11 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.51 </td>
   <td style="text-align:right;"> 1.04 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.16 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 1.32 </td>
   <td style="text-align:right;"> 1.05 </td>
   <td style="text-align:right;"> 0.32 </td>
   <td style="text-align:right;"> 0.18 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 1.39 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 0.33 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> 10,000 </td>
   <td style="text-align:right;"> 0.86 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 3.74 </td>
   <td style="text-align:right;"> 0.98 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 0.94 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 5.20 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 0.49 </td>
   <td style="text-align:right;"> 1.48 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 12.60 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 1.61 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 13.35 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.04 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> 100,000 </td>
   <td style="text-align:right;"> 8.74 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.82 </td>
   <td style="text-align:right;"> 36.74 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 2.08 </td>
   <td style="text-align:right;"> 9.60 </td>
   <td style="text-align:right;"> 1.08 </td>
   <td style="text-align:right;"> 0.81 </td>
   <td style="text-align:right;"> 50.33 </td>
   <td style="text-align:right;"> 0.98 </td>
   <td style="text-align:right;"> 2.87 </td>
   <td style="text-align:right;"> 14.84 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 0.97 </td>
   <td style="text-align:right;"> 119.40 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 7.78 </td>
   <td style="text-align:right;"> 15.63 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 1.05 </td>
   <td style="text-align:right;"> 126.29 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 8.46 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> 1,000,000 </td>
   <td style="text-align:right;"> 74.70 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 5.64 </td>
   <td style="text-align:right;"> 353.71 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 18.24 </td>
   <td style="text-align:right;"> 81.07 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 5.84 </td>
   <td style="text-align:right;"> 489.56 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 29.17 </td>
   <td style="text-align:right;"> 136.95 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 7.85 </td>
   <td style="text-align:right;"> 1235.82 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 77.17 </td>
   <td style="text-align:right;"> 145.63 </td>
   <td style="text-align:right;"> 0.96 </td>
   <td style="text-align:right;"> 8.37 </td>
   <td style="text-align:right;"> 1331.92 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 84.77 </td>
  </tr>
</tbody>
</table>




## Install

### CRAN - Coming soon!

### From Github


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

### Comorbidity Algorithms

* Pediatric Complex Chronic Conditions (PCCC)

  * Version 2.0
    - BMC Pediatrics: [Feudtner et.al. (2014)](https://doi.org/10.1186/1471-2431-14-199)
    - Consistent with R package [pccc](https://cran.r-project.org/package=pccc)

  * Version 2.1
    - Updated code base with the same assessment algorithm as version 2.0.

  * Version 3.0
    - JAMA Network Open: [Feinstein et.al. (2024)](https://doi.org/10.1001/jamanetworkopen.2024.20579)
    - Children's Hospital Association [Toolkit](https://www.childrenshospitals.org/content/analytics/toolkit/complex-chronic-conditions)

  * Version 3.1
    - Updated code base with same assessment algorithm as version 3.0.

* Charlson Comorbidities
  * [Deyo, Cherkin, and Ciol (1992)](https://doi.org/10.1016/0895-4356(92)90133-8)
  * [Quan et.al. (2005)](https://doi.org/10.1097/01.mlr.0000182534.19832.83)
  * [Quan et.al. (2011)](https://doi.org/10.1093/aje/kwq433)
  * [Glasheen (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6684052/)

* Elixhauser Comorbidities
  * [Elixhauser et.al. (1998)](https://doi.org/10.1097/00005650-199801000-00004)
  * [Quan et.al. (2005)](https://doi.org/10.1097/01.mlr.0000182534.19832.83)
  * AHRQ (2017, 2022, 2023, 2024, 2025)
    * [For ICD-9 codes](https://hcup-us.ahrq.gov/toolssoftware/comorbidity/comorbidity.jsp)
    * [For ICD-10 codes](https://www.hcup-us.ahrq.gov/toolssoftware/comorbidityicd10/comorbidity_icd10.jsp)

All of the methods are available from the same function call `comorbidities`.
There is support for age scores in Charlson, present on admission flags for all
methods, and support for longitudinal data.

See more examples in the vignettes.

``` r
vignette(topic = "comorbidities", package = "medicalcoder")
vignette(topic = "pccc", package = "medicalcoder")
vignette(topic = "charlson", package = "medicalcoder")
vignette(topic = "elixhauser", package = "medicalcoder")
```

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
head(mdcr_longitudinal)
#>     patid       date icdv     code
#> 1 9663901 2016-03-18   10   Z77.22
#> 2 9663901 2016-03-24   10  IMO0002
#> 3 9663901 2016-03-24   10 V87.7XXA
#> 4 9663901 2016-03-25   10  J95.851
#> 5 9663901 2016-03-30   10  IMO0002
#> 6 9663901 2016-03-30   10    Z93.0
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

* `known_end`: The latest (fiscal) year when the code was part of the ICD
  system.

* Assignable codes.  Some codes are header codes, e.g., ICD-10-CM three-digit
  code Z94 is a header code because the four-digit codes Z94.0, Z94.1, Z94.2,
  Z94.3, Z94.4, Z94.5, Z94.6, Z94.7, Z94.8, and Z94.9 exist. All but Z94.8 are
  assignable codes because no five-digit codes with the same initial four-digits
  exist.  Z94.8 is a header code because the five-digit codes Z94.81, Z94.82,
  Z94.83, Z94.84, and Z94.89 exist.
    * `assignable_start`: Earliest (fiscal) year when the code was assignable.
    * `assignable_end`: Latest (fiscal) year when the code was assignable.

Additionally, the `get_icd_codes()` method can provide descriptions and the ICD
hierarchy by using the `with.descriptions` and/or `with.hierarchy` arguments.

Functions `lookup_icd_codes`, `is_icd`, and `icd_compact_to_full` are also
provided for working with ICD codes.

More details and examples are in the vignette:

``` r
vignette(topic = "icd", package = "medicalcoder")
```
