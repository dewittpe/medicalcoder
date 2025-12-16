<!-- README.md is generated from README.Rmd. Please edit that file -->



# Benchmarking `medicalcoder`

The major factors impacting the expected computation time for applying a
comorbidity algorithm to a data set are:

1. Data size: number of subjects and encounters.
2. Data storage class: `medicalcoder` has been built such that no imports of
   other namespaces is required. That said, when a `data.table` is passed to
   `comorbidities()` and the `data.table` namespace is available, then S3
   dispatch for `merge` is used, along with some other methods, to reduce memory
   use and reduce computation time. When a `tibble` is passed and tidyverse
   namespaces are available, the tibble-aware path reduces time relative to a
   base `data.frame`, though `data.table` remains the fastest option.
3. flag.method: "current" will take less time than the "cumulative" method.

<img src="benchmark2-composite.svg"/>



In general, the expected time to apply a comorbidity method is lower for
`tibble`s than for base `data.frame`s, and lower still for `data.table`s. Best
observed case: a `data.table` took
0.37732
the time of a `data.frame`. Best case for `tibble`s was
0.5238504
the time of a `data.frame`.


### Benchmarking Charlson (Quan 2005)

<table>
<caption>Expected time (seconds), relative time (with respect to data.frame), and expected memory use, by flagging method (current or cumulative), number of subjects, average number of total encounters, and input data storage format.</caption>
 <thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">flag.method = 'current'</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">flag.method = 'cumulative'</div></th>
</tr>
  <tr>
   <th style="text-align:right;"> Subjects </th>
   <th style="text-align:right;"> Encounters </th>
   <th style="text-align:right;"> Data Class </th>
   <th style="text-align:right;"> Time (seconds) </th>
   <th style="text-align:right;"> Relative time </th>
   <th style="text-align:right;"> Memory (GB) </th>
   <th style="text-align:right;"> Time (seconds) </th>
   <th style="text-align:right;"> Relative time </th>
   <th style="text-align:right;"> Memory (GB) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 28.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 28.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.81 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.22 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 28.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.22 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 20 </td>
   <td style="text-align:right;"> 52.9 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.01 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 52.9 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.01 </td>
   <td style="text-align:right;"> 0.81 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:right;"> 1.19 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 52.9 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 3.99 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 0.11 </td>
   <td style="text-align:right;"> 3.55 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 130.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 130.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.82 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.27 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.27 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 130.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.16 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.26 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 100 </td>
   <td style="text-align:right;"> 284.6 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.04 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 284.6 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.04 </td>
   <td style="text-align:right;"> 0.74 </td>
   <td style="text-align:right;"> 0.27 </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 284.6 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.08 </td>
   <td style="text-align:right;"> 2.12 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.17 </td>
   <td style="text-align:right;"> 2.36 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 200 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 538.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.07 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 538.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.06 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.84 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 538.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.07 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.19 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 500 </td>
   <td style="text-align:right;"> 1370.7 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.08 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 0.18 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 1370.7 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 0.68 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.13 </td>
   <td style="text-align:right;"> 0.71 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 1370.7 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 1.63 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 1.71 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 1,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2747.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2747.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.71 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.64 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2747.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.22 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.09 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:right;"> 5450.0 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.52 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.78 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.32 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 5450.0 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.42 </td>
   <td style="text-align:right;"> 0.73 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.52 </td>
   <td style="text-align:right;"> 0.62 </td>
   <td style="text-align:right;"> 0.30 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 5450.0 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 1.07 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.75 </td>
   <td style="text-align:right;"> 0.86 </td>
   <td style="text-align:right;"> 0.30 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13684.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.25 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.35 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.47 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13684.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.86 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.70 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.35 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.09 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.37 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13684.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.35 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.82 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:right;"> 27383.3 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 2.24 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.48 </td>
   <td style="text-align:right;"> 3.64 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.52 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 27383.3 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 1.38 </td>
   <td style="text-align:right;"> 0.64 </td>
   <td style="text-align:right;"> 0.52 </td>
   <td style="text-align:right;"> 2.03 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 0.54 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 27383.3 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 1.76 </td>
   <td style="text-align:right;"> 0.80 </td>
   <td style="text-align:right;"> 0.49 </td>
   <td style="text-align:right;"> 2.74 </td>
   <td style="text-align:right;"> 0.77 </td>
   <td style="text-align:right;"> 0.51 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 54835.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.78 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.80 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 54835.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.65 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.85 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 54835.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.77 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.84 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.06 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.69 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.92 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:right;"> 137235.8 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 10.43 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.59 </td>
   <td style="text-align:right;"> 17.83 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 2.11 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 137235.8 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 6.56 </td>
   <td style="text-align:right;"> 0.59 </td>
   <td style="text-align:right;"> 1.75 </td>
   <td style="text-align:right;"> 8.82 </td>
   <td style="text-align:right;"> 0.47 </td>
   <td style="text-align:right;"> 2.05 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 137235.8 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 7.72 </td>
   <td style="text-align:right;"> 0.75 </td>
   <td style="text-align:right;"> 1.68 </td>
   <td style="text-align:right;"> 11.32 </td>
   <td style="text-align:right;"> 0.62 </td>
   <td style="text-align:right;"> 1.75 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 274666.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 20.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 34.82 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.44 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 274666.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 12.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.63 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.27 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 16.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.49 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.67 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 274666.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.17 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.74 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 21.95 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.63 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.60 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 200,000 </td>
   <td style="text-align:right;"> 549749.5 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 40.31 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 6.43 </td>
   <td style="text-align:right;"> 69.27 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 7.69 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 549749.5 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 26.52 </td>
   <td style="text-align:right;"> 0.65 </td>
   <td style="text-align:right;"> 6.15 </td>
   <td style="text-align:right;"> 35.07 </td>
   <td style="text-align:right;"> 0.51 </td>
   <td style="text-align:right;"> 7.78 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 549749.5 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 29.97 </td>
   <td style="text-align:right;"> 0.73 </td>
   <td style="text-align:right;"> 6.08 </td>
   <td style="text-align:right;"> 42.83 </td>
   <td style="text-align:right;"> 0.63 </td>
   <td style="text-align:right;"> 7.18 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1375466.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 102.53 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 175.67 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 18.14 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1375466.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 61.53 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 16.21 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 83.13 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.47 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 17.12 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1375466.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 75.21 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.74 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 106.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 17.90 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 1,000,000 </td>
   <td style="text-align:right;"> 2749780.0 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 207.79 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 29.39 </td>
   <td style="text-align:right;"> 367.47 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 33.86 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 2749780.0 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 127.49 </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 30.88 </td>
   <td style="text-align:right;"> 167.46 </td>
   <td style="text-align:right;"> 0.46 </td>
   <td style="text-align:right;"> 33.42 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 2749780.0 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 147.64 </td>
   <td style="text-align:right;"> 0.71 </td>
   <td style="text-align:right;"> 30.99 </td>
   <td style="text-align:right;"> 220.07 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 36.94 </td>
  </tr>
</tbody>
</table>


### Benchmarking Elixhauser (Quan 2005)

<table>
<caption>Expected time (seconds), relative time (with respect to data.frame), and expected memory use, by flagging method (current or cumulative), number of subjects, average number of total encounters, and input data storage format.</caption>
 <thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">flag.method = 'current'</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">flag.method = 'cumulative'</div></th>
</tr>
  <tr>
   <th style="text-align:right;"> Subjects </th>
   <th style="text-align:right;"> Encounters </th>
   <th style="text-align:right;"> Data Class </th>
   <th style="text-align:right;"> Time (seconds) </th>
   <th style="text-align:right;"> Relative time </th>
   <th style="text-align:right;"> Memory (GB) </th>
   <th style="text-align:right;"> Time (seconds) </th>
   <th style="text-align:right;"> Relative time </th>
   <th style="text-align:right;"> Memory (GB) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 28.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 28.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.80 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.25 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 28.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.76 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.17 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 20 </td>
   <td style="text-align:right;"> 52.9 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.02 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 52.9 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.01 </td>
   <td style="text-align:right;"> 0.72 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.06 </td>
   <td style="text-align:right;"> 1.16 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 52.9 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 3.11 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 0.19 </td>
   <td style="text-align:right;"> 3.65 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 130.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.06 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 130.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.65 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 130.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.89 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.24 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.64 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 100 </td>
   <td style="text-align:right;"> 284.6 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 284.6 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.04 </td>
   <td style="text-align:right;"> 0.69 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 0.90 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 284.6 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.09 </td>
   <td style="text-align:right;"> 1.64 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.25 </td>
   <td style="text-align:right;"> 2.13 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 200 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 538.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.17 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 538.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.74 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.13 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.73 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 538.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.63 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.80 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 500 </td>
   <td style="text-align:right;"> 1370.7 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.15 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 0.36 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.30 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 1370.7 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 0.75 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 0.19 </td>
   <td style="text-align:right;"> 0.62 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 1370.7 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.17 </td>
   <td style="text-align:right;"> 1.43 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 1.28 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 1,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2747.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.72 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2747.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.21 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.71 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.48 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2747.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.20 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.71 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:right;"> 5450.0 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.69 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 1.36 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.35 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 5450.0 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> 0.67 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.74 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 0.32 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 5450.0 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.64 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 1.19 </td>
   <td style="text-align:right;"> 0.83 </td>
   <td style="text-align:right;"> 0.34 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13684.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.82 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.44 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.36 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.49 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13684.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.09 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.62 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.71 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13684.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.84 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.50 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:right;"> 27383.3 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 3.64 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.62 </td>
   <td style="text-align:right;"> 6.84 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.71 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 27383.3 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 2.12 </td>
   <td style="text-align:right;"> 0.59 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 3.23 </td>
   <td style="text-align:right;"> 0.48 </td>
   <td style="text-align:right;"> 0.61 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 27383.3 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 2.99 </td>
   <td style="text-align:right;"> 0.80 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 4.75 </td>
   <td style="text-align:right;"> 0.71 </td>
   <td style="text-align:right;"> 0.65 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 54835.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.11 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 54835.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.09 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.06 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 54835.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.67 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.22 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:right;"> 137235.8 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 16.73 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.73 </td>
   <td style="text-align:right;"> 32.17 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 2.02 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 137235.8 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 9.54 </td>
   <td style="text-align:right;"> 0.57 </td>
   <td style="text-align:right;"> 2.12 </td>
   <td style="text-align:right;"> 14.19 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 2.10 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 137235.8 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 12.84 </td>
   <td style="text-align:right;"> 0.78 </td>
   <td style="text-align:right;"> 2.37 </td>
   <td style="text-align:right;"> 20.41 </td>
   <td style="text-align:right;"> 0.63 </td>
   <td style="text-align:right;"> 2.77 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 274666.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 33.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.78 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 63.80 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.02 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 274666.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 18.25 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.34 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 25.36 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.40 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 274666.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 24.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38.43 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.61 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.88 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 200,000 </td>
   <td style="text-align:right;"> 549749.5 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 65.18 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 8.72 </td>
   <td style="text-align:right;"> 126.49 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 8.54 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 549749.5 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 36.69 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 9.00 </td>
   <td style="text-align:right;"> 54.31 </td>
   <td style="text-align:right;"> 0.41 </td>
   <td style="text-align:right;"> 9.42 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 549749.5 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 47.11 </td>
   <td style="text-align:right;"> 0.72 </td>
   <td style="text-align:right;"> 7.20 </td>
   <td style="text-align:right;"> 76.31 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 6.82 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1375466.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 169.97 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 20.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 332.77 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 21.23 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1375466.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 90.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.53 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 17.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 130.70 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.40 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 17.72 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1375466.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 120.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.71 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 19.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 192.81 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 22.26 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 1,000,000 </td>
   <td style="text-align:right;"> 2749780.0 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 348.58 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 38.95 </td>
   <td style="text-align:right;"> 711.16 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 40.77 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 2749780.0 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 180.56 </td>
   <td style="text-align:right;"> 0.52 </td>
   <td style="text-align:right;"> 35.14 </td>
   <td style="text-align:right;"> 280.31 </td>
   <td style="text-align:right;"> 0.39 </td>
   <td style="text-align:right;"> 34.44 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 2749780.0 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 236.68 </td>
   <td style="text-align:right;"> 0.68 </td>
   <td style="text-align:right;"> 34.49 </td>
   <td style="text-align:right;"> 395.66 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 35.64 </td>
  </tr>
</tbody>
</table>


### Benchmarking PCCC v3.1 (without subconditions)

<table>
<caption>Expected time (seconds), relative time (with respect to data.frame), and expected memory use, by flagging method (current or cumulative), number of subjects, average number of total encounters, and input data storage format.</caption>
 <thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">flag.method = 'current'</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">flag.method = 'cumulative'</div></th>
</tr>
  <tr>
   <th style="text-align:right;"> Subjects </th>
   <th style="text-align:right;"> Encounters </th>
   <th style="text-align:right;"> Data Class </th>
   <th style="text-align:right;"> Time (seconds) </th>
   <th style="text-align:right;"> Relative time </th>
   <th style="text-align:right;"> Memory (GB) </th>
   <th style="text-align:right;"> Time (seconds) </th>
   <th style="text-align:right;"> Relative time </th>
   <th style="text-align:right;"> Memory (GB) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 28.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 28.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.21 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 28.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.06 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.65 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.13 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.70 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 20 </td>
   <td style="text-align:right;"> 52.9 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.02 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.04 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 52.9 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.01 </td>
   <td style="text-align:right;"> 0.72 </td>
   <td style="text-align:right;"> 0.27 </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 1.18 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 52.9 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.06 </td>
   <td style="text-align:right;"> 3.03 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 0.18 </td>
   <td style="text-align:right;"> 3.62 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 130.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.06 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 130.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 130.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.25 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 100 </td>
   <td style="text-align:right;"> 284.6 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.08 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 284.6 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.02 </td>
   <td style="text-align:right;"> 0.63 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.08 </td>
   <td style="text-align:right;"> 0.92 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 284.6 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 1.88 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.24 </td>
   <td style="text-align:right;"> 2.38 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 200 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 538.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.16 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 538.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.13 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 538.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.86 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 500 </td>
   <td style="text-align:right;"> 1370.7 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.12 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.30 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 1370.7 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 0.59 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 0.18 </td>
   <td style="text-align:right;"> 0.59 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 1370.7 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.15 </td>
   <td style="text-align:right;"> 1.45 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 0.44 </td>
   <td style="text-align:right;"> 1.35 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 1,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2747.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.19 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2747.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.13 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.63 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.53 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2747.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:right;"> 5450.0 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 1.05 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.34 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 5450.0 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.41 </td>
   <td style="text-align:right;"> 0.66 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 0.51 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 5450.0 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.91 </td>
   <td style="text-align:right;"> 0.83 </td>
   <td style="text-align:right;"> 0.32 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13684.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.48 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13684.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.84 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.66 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.37 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.21 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.43 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13684.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.19 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.89 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.37 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.46 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:right;"> 27383.3 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 2.49 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 5.15 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.57 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 27383.3 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 1.43 </td>
   <td style="text-align:right;"> 0.62 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 2.35 </td>
   <td style="text-align:right;"> 0.47 </td>
   <td style="text-align:right;"> 0.56 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 27383.3 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 2.02 </td>
   <td style="text-align:right;"> 0.86 </td>
   <td style="text-align:right;"> 0.54 </td>
   <td style="text-align:right;"> 3.52 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 0.57 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 54835.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9.92 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.92 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 54835.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.76 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.86 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.33 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.95 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 54835.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.21 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.81 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.64 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.90 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:right;"> 137235.8 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 11.34 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.77 </td>
   <td style="text-align:right;"> 24.25 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 2.33 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 137235.8 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 6.86 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 1.60 </td>
   <td style="text-align:right;"> 9.69 </td>
   <td style="text-align:right;"> 0.40 </td>
   <td style="text-align:right;"> 1.65 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 137235.8 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 8.87 </td>
   <td style="text-align:right;"> 0.78 </td>
   <td style="text-align:right;"> 1.79 </td>
   <td style="text-align:right;"> 14.10 </td>
   <td style="text-align:right;"> 0.58 </td>
   <td style="text-align:right;"> 1.78 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 274666.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 22.26 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.25 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 48.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.40 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 274666.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 18.69 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.40 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.39 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 274666.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 17.64 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.78 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 26.96 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.63 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 200,000 </td>
   <td style="text-align:right;"> 549749.5 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 44.80 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 6.24 </td>
   <td style="text-align:right;"> 92.30 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 7.05 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 549749.5 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 27.33 </td>
   <td style="text-align:right;"> 0.63 </td>
   <td style="text-align:right;"> 6.10 </td>
   <td style="text-align:right;"> 38.64 </td>
   <td style="text-align:right;"> 0.41 </td>
   <td style="text-align:right;"> 8.19 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 549749.5 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 33.72 </td>
   <td style="text-align:right;"> 0.77 </td>
   <td style="text-align:right;"> 6.20 </td>
   <td style="text-align:right;"> 52.07 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 6.48 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1375466.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 114.25 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 14.65 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 240.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 18.37 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1375466.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 68.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 16.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 95.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.40 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 20.06 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1375466.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 82.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.72 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 128.94 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 16.53 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 1,000,000 </td>
   <td style="text-align:right;"> 2749780.0 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 237.08 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 28.44 </td>
   <td style="text-align:right;"> 514.43 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 38.48 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 2749780.0 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 138.66 </td>
   <td style="text-align:right;"> 0.59 </td>
   <td style="text-align:right;"> 31.98 </td>
   <td style="text-align:right;"> 194.59 </td>
   <td style="text-align:right;"> 0.38 </td>
   <td style="text-align:right;"> 39.65 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 2749780.0 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 168.47 </td>
   <td style="text-align:right;"> 0.71 </td>
   <td style="text-align:right;"> 28.17 </td>
   <td style="text-align:right;"> 274.31 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 34.85 </td>
  </tr>
</tbody>
</table>


### Benchmarking PCCC v3.1 (with subconditions)

<table>
<caption>Expected time (seconds), relative time (with respect to data.frame), and expected memory use, by flagging method (current or cumulative), number of subjects, average number of total encounters, and input data storage format.</caption>
 <thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">flag.method = 'current'</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">flag.method = 'cumulative'</div></th>
</tr>
  <tr>
   <th style="text-align:right;"> Subjects </th>
   <th style="text-align:right;"> Encounters </th>
   <th style="text-align:right;"> Data Class </th>
   <th style="text-align:right;"> Time (seconds) </th>
   <th style="text-align:right;"> Relative time </th>
   <th style="text-align:right;"> Memory (GB) </th>
   <th style="text-align:right;"> Time (seconds) </th>
   <th style="text-align:right;"> Relative time </th>
   <th style="text-align:right;"> Memory (GB) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 28.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 28.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.06 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 28.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.21 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.43 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 20 </td>
   <td style="text-align:right;"> 52.9 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.02 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 52.9 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:right;"> 1.23 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 1.32 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 52.9 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.12 </td>
   <td style="text-align:right;"> 4.79 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 0.23 </td>
   <td style="text-align:right;"> 4.47 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 130.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.07 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 130.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.07 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 130.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.16 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.85 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 100 </td>
   <td style="text-align:right;"> 284.6 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.04 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.09 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 284.6 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.04 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 284.6 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.13 </td>
   <td style="text-align:right;"> 2.99 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 2.70 </td>
   <td style="text-align:right;"> 0.28 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 200 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 538.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.16 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 538.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.89 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 538.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.22 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.35 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 500 </td>
   <td style="text-align:right;"> 1370.7 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.30 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 1370.7 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 0.67 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 0.19 </td>
   <td style="text-align:right;"> 0.66 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 1370.7 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.20 </td>
   <td style="text-align:right;"> 1.98 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 0.48 </td>
   <td style="text-align:right;"> 1.55 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 1,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2747.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.24 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2747.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.64 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> NA </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2747.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.64 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.07 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:right;"> 5450.0 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.58 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 1.09 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.34 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 5450.0 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 0.66 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.64 </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 5450.0 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.62 </td>
   <td style="text-align:right;"> 0.92 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.86 </td>
   <td style="text-align:right;"> 0.32 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13684.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.36 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.69 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.48 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13684.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.95 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.70 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.37 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.43 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13684.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.94 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.98 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.76 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.46 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:right;"> 27383.3 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 2.58 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 5.24 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.57 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 27383.3 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 1.59 </td>
   <td style="text-align:right;"> 0.66 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 2.40 </td>
   <td style="text-align:right;"> 0.48 </td>
   <td style="text-align:right;"> 0.56 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 27383.3 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 2.16 </td>
   <td style="text-align:right;"> 0.92 </td>
   <td style="text-align:right;"> 0.54 </td>
   <td style="text-align:right;"> 3.64 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 0.57 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 54835.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.17 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 10.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.92 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 54835.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.90 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.86 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.43 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.95 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 54835.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.34 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.66 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.64 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.90 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:right;"> 137235.8 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 11.82 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.77 </td>
   <td style="text-align:right;"> 24.96 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 2.33 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 137235.8 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 7.38 </td>
   <td style="text-align:right;"> 0.57 </td>
   <td style="text-align:right;"> 1.60 </td>
   <td style="text-align:right;"> 10.03 </td>
   <td style="text-align:right;"> 0.40 </td>
   <td style="text-align:right;"> 1.65 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 137235.8 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 9.40 </td>
   <td style="text-align:right;"> 0.77 </td>
   <td style="text-align:right;"> 1.80 </td>
   <td style="text-align:right;"> 14.54 </td>
   <td style="text-align:right;"> 0.58 </td>
   <td style="text-align:right;"> 1.78 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 274666.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 23.16 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.25 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 48.88 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.40 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 274666.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 14.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.62 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 19.89 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.39 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 274666.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 18.66 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 28.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.63 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 200,000 </td>
   <td style="text-align:right;"> 549749.5 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 46.57 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 6.24 </td>
   <td style="text-align:right;"> 94.71 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 7.05 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 549749.5 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 29.39 </td>
   <td style="text-align:right;"> 0.65 </td>
   <td style="text-align:right;"> 6.10 </td>
   <td style="text-align:right;"> 40.23 </td>
   <td style="text-align:right;"> 0.42 </td>
   <td style="text-align:right;"> 8.19 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 549749.5 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 35.70 </td>
   <td style="text-align:right;"> 0.80 </td>
   <td style="text-align:right;"> 6.38 </td>
   <td style="text-align:right;"> 54.59 </td>
   <td style="text-align:right;"> 0.57 </td>
   <td style="text-align:right;"> 6.48 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1375466.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 120.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 14.70 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 246.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 18.37 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1375466.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 72.22 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 16.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 101.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 20.07 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1375466.2 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 88.44 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.72 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.06 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 134.88 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 16.51 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 1,000,000 </td>
   <td style="text-align:right;"> 2749780.0 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 252.05 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 28.78 </td>
   <td style="text-align:right;"> 527.57 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 38.47 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 2749780.0 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 152.29 </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 32.17 </td>
   <td style="text-align:right;"> 213.77 </td>
   <td style="text-align:right;"> 0.40 </td>
   <td style="text-align:right;"> 39.65 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 2749780.0 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 181.51 </td>
   <td style="text-align:right;"> 0.72 </td>
   <td style="text-align:right;"> 28.10 </td>
   <td style="text-align:right;"> 276.53 </td>
   <td style="text-align:right;"> 0.52 </td>
   <td style="text-align:right;"> 34.85 </td>
  </tr>
</tbody>
</table>


