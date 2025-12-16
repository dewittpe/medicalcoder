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
0.3044387
the time of a `data.frame`. Best case for `tibble`s was
0.5178572
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
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 197.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.07 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 197.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.07 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.94 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 197.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.49 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.22 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.95 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 20 </td>
   <td style="text-align:right;"> 380.6 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.08 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.16 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 380.6 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 0.93 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 0.86 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 380.6 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.11 </td>
   <td style="text-align:right;"> 1.39 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.23 </td>
   <td style="text-align:right;"> 1.43 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1958.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.63 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1958.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.63 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.43 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1958.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.94 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 200 </td>
   <td style="text-align:right;"> 3897.0 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.34 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 3897.0 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.18 </td>
   <td style="text-align:right;"> 0.66 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.68 </td>
   <td style="text-align:right;"> 0.63 </td>
   <td style="text-align:right;"> 0.33 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 3897.0 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.84 </td>
   <td style="text-align:right;"> 0.82 </td>
   <td style="text-align:right;"> 0.33 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9668.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.71 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.44 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9668.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.67 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9668.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.86 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.70 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.43 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 1,000 </td>
   <td style="text-align:right;"> 19272.9 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 1.32 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 5.47 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.61 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 19272.9 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 0.59 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 2.74 </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> 0.54 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 19272.9 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.96 </td>
   <td style="text-align:right;"> 0.75 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 3.54 </td>
   <td style="text-align:right;"> 0.63 </td>
   <td style="text-align:right;"> 0.54 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38315.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.43 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 10.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.98 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38315.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.44 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.53 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.13 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.47 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38315.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.82 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.90 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:right;"> 96308.0 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 6.08 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.72 </td>
   <td style="text-align:right;"> 26.98 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 2.20 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 96308.0 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 2.91 </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> 0.82 </td>
   <td style="text-align:right;"> 12.13 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 2.12 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 96308.0 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 3.63 </td>
   <td style="text-align:right;"> 0.63 </td>
   <td style="text-align:right;"> 0.78 </td>
   <td style="text-align:right;"> 14.85 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 2.09 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 192253.6 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 11.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.34 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 51.92 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.48 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 192253.6 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.47 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.40 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 21.86 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.43 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 192253.6 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 28.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.05 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:right;"> 383801.3 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 23.31 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 2.41 </td>
   <td style="text-align:right;"> 104.28 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 8.18 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 383801.3 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 9.96 </td>
   <td style="text-align:right;"> 0.44 </td>
   <td style="text-align:right;"> 2.05 </td>
   <td style="text-align:right;"> 40.55 </td>
   <td style="text-align:right;"> 0.39 </td>
   <td style="text-align:right;"> 6.65 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 383801.3 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 12.77 </td>
   <td style="text-align:right;"> 0.57 </td>
   <td style="text-align:right;"> 2.36 </td>
   <td style="text-align:right;"> 54.48 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 6.49 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 30,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 574161.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 33.14 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 152.65 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 11.54 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 574161.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 14.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.43 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.22 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 60.94 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 10.49 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 574161.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 19.13 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 81.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.53 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 11.32 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:right;"> 957052.5 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 54.21 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 5.16 </td>
   <td style="text-align:right;"> 248.58 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 19.99 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 957052.5 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 23.25 </td>
   <td style="text-align:right;"> 0.44 </td>
   <td style="text-align:right;"> 5.93 </td>
   <td style="text-align:right;"> 100.77 </td>
   <td style="text-align:right;"> 0.41 </td>
   <td style="text-align:right;"> 16.92 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 957052.5 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 31.29 </td>
   <td style="text-align:right;"> 0.58 </td>
   <td style="text-align:right;"> 5.28 </td>
   <td style="text-align:right;"> 133.67 </td>
   <td style="text-align:right;"> 0.54 </td>
   <td style="text-align:right;"> 17.42 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1912569.1 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 96.22 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9.94 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 515.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 41.58 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1912569.1 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 47.97 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 11.09 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 218.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 37.36 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1912569.1 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 59.71 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.62 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 10.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 280.98 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 37.89 </td>
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
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 197.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.07 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 197.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.07 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.98 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 197.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.27 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 20 </td>
   <td style="text-align:right;"> 380.6 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.08 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.20 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 380.6 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.18 </td>
   <td style="text-align:right;"> 0.89 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 380.6 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 1.77 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.32 </td>
   <td style="text-align:right;"> 1.61 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1958.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.77 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1958.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.76 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.74 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1958.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.19 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.74 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.96 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 200 </td>
   <td style="text-align:right;"> 3897.0 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.32 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 1.51 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.36 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 3897.0 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.20 </td>
   <td style="text-align:right;"> 0.69 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 0.66 </td>
   <td style="text-align:right;"> 0.36 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 3897.0 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.93 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 1.19 </td>
   <td style="text-align:right;"> 0.82 </td>
   <td style="text-align:right;"> 0.35 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9668.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.53 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9668.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.52 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.63 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9668.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.64 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.86 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.67 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.72 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.47 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 1,000 </td>
   <td style="text-align:right;"> 19272.9 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 1.44 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 7.05 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.85 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 19272.9 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.83 </td>
   <td style="text-align:right;"> 0.59 </td>
   <td style="text-align:right;"> 0.36 </td>
   <td style="text-align:right;"> 3.82 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 0.88 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 19272.9 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 1.12 </td>
   <td style="text-align:right;"> 0.77 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 4.67 </td>
   <td style="text-align:right;"> 0.65 </td>
   <td style="text-align:right;"> 0.84 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38315.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.49 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 14.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.46 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38315.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.52 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.21 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38315.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.90 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.69 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.69 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.61 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.15 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:right;"> 96308.0 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 6.66 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.77 </td>
   <td style="text-align:right;"> 35.84 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 3.09 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 96308.0 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 3.29 </td>
   <td style="text-align:right;"> 0.52 </td>
   <td style="text-align:right;"> 0.89 </td>
   <td style="text-align:right;"> 17.74 </td>
   <td style="text-align:right;"> 0.49 </td>
   <td style="text-align:right;"> 3.17 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 96308.0 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 4.35 </td>
   <td style="text-align:right;"> 0.66 </td>
   <td style="text-align:right;"> 0.83 </td>
   <td style="text-align:right;"> 21.38 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 3.08 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 192253.6 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 12.33 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.49 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 68.95 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.00 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 192253.6 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.48 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 32.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.47 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.74 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 192253.6 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.16 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.65 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 41.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.68 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:right;"> 383801.3 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 24.09 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 2.86 </td>
   <td style="text-align:right;"> 138.74 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 12.21 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 383801.3 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 11.79 </td>
   <td style="text-align:right;"> 0.49 </td>
   <td style="text-align:right;"> 2.73 </td>
   <td style="text-align:right;"> 62.29 </td>
   <td style="text-align:right;"> 0.44 </td>
   <td style="text-align:right;"> 10.93 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 383801.3 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 14.95 </td>
   <td style="text-align:right;"> 0.63 </td>
   <td style="text-align:right;"> 2.82 </td>
   <td style="text-align:right;"> 79.46 </td>
   <td style="text-align:right;"> 0.57 </td>
   <td style="text-align:right;"> 11.32 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 30,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 574161.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 36.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.95 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 211.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 17.15 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 574161.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 16.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.47 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.89 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 89.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.43 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.74 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 574161.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 22.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.61 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.94 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 116.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 17.07 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:right;"> 957052.5 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 59.38 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 5.87 </td>
   <td style="text-align:right;"> 356.12 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 30.80 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 957052.5 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 26.83 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 5.53 </td>
   <td style="text-align:right;"> 156.58 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 28.11 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 957052.5 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 35.27 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 5.73 </td>
   <td style="text-align:right;"> 194.17 </td>
   <td style="text-align:right;"> 0.54 </td>
   <td style="text-align:right;"> 26.40 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1912569.1 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 108.52 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9.61 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 725.92 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 60.45 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1912569.1 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 55.20 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 10.17 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 312.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.43 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 52.84 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1912569.1 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 73.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.67 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.69 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 409.89 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 48.27 </td>
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
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 197.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 197.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 197.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.14 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 20 </td>
   <td style="text-align:right;"> 380.6 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.09 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.48 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 380.6 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.08 </td>
   <td style="text-align:right;"> 0.91 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.41 </td>
   <td style="text-align:right;"> 0.85 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 380.6 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.17 </td>
   <td style="text-align:right;"> 1.89 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 1.49 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1958.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.25 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.70 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1958.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.16 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.63 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.66 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1958.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.26 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.92 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 200 </td>
   <td style="text-align:right;"> 3897.0 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 3.15 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.54 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 3897.0 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.24 </td>
   <td style="text-align:right;"> 0.52 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 1.86 </td>
   <td style="text-align:right;"> 0.59 </td>
   <td style="text-align:right;"> 0.51 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 3897.0 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.51 </td>
   <td style="text-align:right;"> 0.91 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 2.59 </td>
   <td style="text-align:right;"> 0.83 </td>
   <td style="text-align:right;"> 0.52 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9668.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.19 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.36 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.07 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9668.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.44 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.33 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.19 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.53 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.91 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9668.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.81 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.76 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.36 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.76 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.73 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.92 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 1,000 </td>
   <td style="text-align:right;"> 19272.9 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 2.05 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 16.19 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.77 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 19272.9 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.94 </td>
   <td style="text-align:right;"> 0.44 </td>
   <td style="text-align:right;"> 0.35 </td>
   <td style="text-align:right;"> 8.11 </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> 1.54 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 19272.9 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 1.58 </td>
   <td style="text-align:right;"> 0.71 </td>
   <td style="text-align:right;"> 0.39 </td>
   <td style="text-align:right;"> 11.11 </td>
   <td style="text-align:right;"> 0.68 </td>
   <td style="text-align:right;"> 1.57 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38315.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.16 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 32.52 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38315.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.67 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.35 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.48 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.54 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38315.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.67 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.62 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 20.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.64 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.98 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:right;"> 96308.0 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 9.52 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 81.16 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 7.99 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 96308.0 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 3.55 </td>
   <td style="text-align:right;"> 0.37 </td>
   <td style="text-align:right;"> 0.91 </td>
   <td style="text-align:right;"> 37.81 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 6.98 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 96308.0 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 5.60 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 1.21 </td>
   <td style="text-align:right;"> 48.78 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 6.84 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 192253.6 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 19.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 164.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.47 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 192253.6 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.89 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.34 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 68.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13.27 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 192253.6 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 11.49 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.92 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 94.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13.73 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:right;"> 383801.3 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 38.27 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 3.22 </td>
   <td style="text-align:right;"> 333.63 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 30.50 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 383801.3 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 12.43 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 2.86 </td>
   <td style="text-align:right;"> 132.94 </td>
   <td style="text-align:right;"> 0.40 </td>
   <td style="text-align:right;"> 26.20 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 383801.3 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 20.99 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 3.00 </td>
   <td style="text-align:right;"> 185.51 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 27.32 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 30,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 574161.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 56.43 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.27 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 514.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 45.36 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 574161.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 17.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 204.34 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 39.64 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 574161.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 30.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.71 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 278.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 39.97 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:right;"> 957052.5 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 91.93 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 8.66 </td>
   <td style="text-align:right;"> 853.94 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 75.34 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 957052.5 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 28.31 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 6.09 </td>
   <td style="text-align:right;"> 338.76 </td>
   <td style="text-align:right;"> 0.40 </td>
   <td style="text-align:right;"> 64.95 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 957052.5 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 49.79 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 9.02 </td>
   <td style="text-align:right;"> 472.70 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 63.35 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1912569.1 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 182.21 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1827.73 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 154.10 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1912569.1 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 56.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 11.44 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 773.19 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 127.79 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1912569.1 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 94.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.52 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1068.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 134.01 </td>
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
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 197.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 197.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.09 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.09 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.33 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 197.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.21 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.70 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.34 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 20 </td>
   <td style="text-align:right;"> 380.6 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.11 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 380.6 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.09 </td>
   <td style="text-align:right;"> 0.93 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 0.85 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 380.6 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.22 </td>
   <td style="text-align:right;"> 2.12 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.78 </td>
   <td style="text-align:right;"> 1.49 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1958.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.82 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1958.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.69 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1958.8 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.34 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.74 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.96 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 200 </td>
   <td style="text-align:right;"> 3897.0 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 0.59 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 3.42 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.57 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 3897.0 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.51 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 2.09 </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 0.52 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 3897.0 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 0.98 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 2.87 </td>
   <td style="text-align:right;"> 0.85 </td>
   <td style="text-align:right;"> 0.55 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9668.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.35 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.36 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.77 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.11 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9668.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.64 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.47 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.33 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.77 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.92 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9668.3 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.81 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.36 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.74 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.93 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 1,000 </td>
   <td style="text-align:right;"> 19272.9 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 2.22 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 17.19 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.86 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 19272.9 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 1.16 </td>
   <td style="text-align:right;"> 0.49 </td>
   <td style="text-align:right;"> 0.35 </td>
   <td style="text-align:right;"> 9.14 </td>
   <td style="text-align:right;"> 0.52 </td>
   <td style="text-align:right;"> 1.64 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 19272.9 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 1.83 </td>
   <td style="text-align:right;"> 0.79 </td>
   <td style="text-align:right;"> 0.39 </td>
   <td style="text-align:right;"> 12.04 </td>
   <td style="text-align:right;"> 0.69 </td>
   <td style="text-align:right;"> 1.63 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38315.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.48 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 34.73 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.38 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38315.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.07 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.49 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 17.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.56 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38315.5 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.62 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 22.64 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.66 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.03 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:right;"> 96308.0 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 10.29 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 86.75 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 8.26 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 96308.0 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 4.48 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 0.91 </td>
   <td style="text-align:right;"> 42.31 </td>
   <td style="text-align:right;"> 0.47 </td>
   <td style="text-align:right;"> 7.38 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 96308.0 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 6.68 </td>
   <td style="text-align:right;"> 0.65 </td>
   <td style="text-align:right;"> 1.21 </td>
   <td style="text-align:right;"> 52.99 </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 7.33 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 192253.6 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 21.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 174.19 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.64 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 192253.6 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 76.90 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13.61 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 192253.6 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13.06 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.92 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 105.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13.88 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:right;"> 383801.3 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 42.37 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 3.22 </td>
   <td style="text-align:right;"> 360.85 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 31.11 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 383801.3 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 15.67 </td>
   <td style="text-align:right;"> 0.37 </td>
   <td style="text-align:right;"> 2.86 </td>
   <td style="text-align:right;"> 151.31 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 27.34 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 383801.3 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 24.05 </td>
   <td style="text-align:right;"> 0.58 </td>
   <td style="text-align:right;"> 3.01 </td>
   <td style="text-align:right;"> 205.70 </td>
   <td style="text-align:right;"> 0.58 </td>
   <td style="text-align:right;"> 28.84 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 30,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 574161.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 60.37 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.27 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 532.16 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 46.79 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 574161.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 22.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.37 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 234.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.43 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 40.85 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 574161.7 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 35.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.70 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 305.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 41.51 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:right;"> 957052.5 </td>
   <td style="text-align:right;"> data.frame </td>
   <td style="text-align:right;"> 100.11 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 8.66 </td>
   <td style="text-align:right;"> 935.63 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 79.07 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 957052.5 </td>
   <td style="text-align:right;"> data.table </td>
   <td style="text-align:right;"> 36.85 </td>
   <td style="text-align:right;"> 0.37 </td>
   <td style="text-align:right;"> 6.09 </td>
   <td style="text-align:right;"> 396.47 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 64.94 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;"> 957052.5 </td>
   <td style="text-align:right;"> tibble </td>
   <td style="text-align:right;"> 56.57 </td>
   <td style="text-align:right;"> 0.57 </td>
   <td style="text-align:right;"> 9.02 </td>
   <td style="text-align:right;"> 526.35 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 63.78 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1912569.1 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 193.63 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1909.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 157.70 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1912569.1 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 72.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 11.44 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 881.76 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 130.37 </td>
  </tr>
  <tr>
   
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1912569.1 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 116.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1124.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 141.96 </td>
  </tr>
</tbody>
</table>


