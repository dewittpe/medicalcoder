<!-- README.md is generated from README.Rmd. Please edit that file -->



# Benchmarking `medicalcoder`

The major factors impacting the expected computation time for applying a
comorbidity algorithm to a data set are:

1. Data size: number of subjects/encounters.
2. Data storage class: `medicalcoder` has been built such that no imports of
   other namespaces is required.  That said, when a `data.table` is passed to
   `comorbidities()` and the `data.table` namespace is available, then S3
   dispatch for `merge` is used, along with some other methods, to reduce memory
   use and reduce computation time.
3. flag.method: "current" will take less time than the "cumulative" method.

<img src="benchmark2-composite.svg"/>



In general, the expected time to apply a comorbidity method is the same between
`data.frame`s and `tibble`s.  There is a notable decrease in time required when
`data.table`s are passed to `comorbidities()`.  Best observed case: a
`data.table` took
0.3900702
the time of a `data.frame`.


### Benchmarking Charlson (Quan 2005)

<table>
<caption>Expected time (seconds), relative time (with respect to data.frame), and expected memory use, by flagging method (current or cumulative), number of encounters, and input data storage format.</caption>
 <thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">flag.method = 'current'</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">flag.method = 'cumulative'</div></th>
</tr>
  <tr>
   <th style="text-align:center;"> Encounters </th>
   <th style="text-align:center;"> Data Class </th>
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
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 1,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.34 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.88 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.24 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.73 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.35 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.17 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.68 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 0.82 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.42 </td>
   <td style="text-align:right;"> 0.64 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.17 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.68 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.74 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.34 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.94 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.34 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.72 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.35 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.87 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 3.80 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.42 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 1.90 </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> 0.41 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.86 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 3.74 </td>
   <td style="text-align:right;"> 0.98 </td>
   <td style="text-align:right;"> 0.43 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.84 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.21 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.66 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.77 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.48 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.57 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.37 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.81 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.61 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 4.70 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 19.15 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.12 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 2.88 </td>
   <td style="text-align:right;"> 0.63 </td>
   <td style="text-align:right;"> 0.54 </td>
   <td style="text-align:right;"> 8.95 </td>
   <td style="text-align:right;"> 0.47 </td>
   <td style="text-align:right;"> 1.05 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 4.72 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 19.57 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 1.15 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 36.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.07 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.81 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 16.21 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.90 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.74 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.82 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 36.74 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.08 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 200,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 16.10 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.39 </td>
   <td style="text-align:right;"> 70.51 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 3.95 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 8.89 </td>
   <td style="text-align:right;"> 0.57 </td>
   <td style="text-align:right;"> 1.34 </td>
   <td style="text-align:right;"> 29.81 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 3.53 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 16.22 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 1.38 </td>
   <td style="text-align:right;"> 70.14 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 3.89 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 174.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9.32 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 19.96 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 69.96 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.96 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38.19 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.96 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 173.65 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9.16 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 1,000,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 74.39 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 5.71 </td>
   <td style="text-align:right;"> 353.93 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 18.22 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 38.00 </td>
   <td style="text-align:right;"> 0.52 </td>
   <td style="text-align:right;"> 6.28 </td>
   <td style="text-align:right;"> 136.10 </td>
   <td style="text-align:right;"> 0.39 </td>
   <td style="text-align:right;"> 14.77 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 74.70 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 5.64 </td>
   <td style="text-align:right;"> 353.71 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 18.24 </td>
  </tr>
</tbody>
</table>


### Benchmarking Elixhauser (Quan 2005)

<table>
<caption>Expected time (seconds), relative time (with respect to data.frame), and expected memory use, by flagging method (current or cumulative), number of encounters, and input data storage format.</caption>
 <thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">flag.method = 'current'</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">flag.method = 'cumulative'</div></th>
</tr>
  <tr>
   <th style="text-align:center;"> Encounters </th>
   <th style="text-align:center;"> Data Class </th>
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
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 1,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.49 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.37 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.78 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.20 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.30 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.16 </td>
   <td style="text-align:right;"> 0.83 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.65 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 0.30 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.19 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.98 </td>
   <td style="text-align:right;"> 1.04 </td>
   <td style="text-align:right;"> 0.30 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.34 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.77 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.61 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.44 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 5.06 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.52 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.69 </td>
   <td style="text-align:right;"> 0.73 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 2.87 </td>
   <td style="text-align:right;"> 0.57 </td>
   <td style="text-align:right;"> 0.50 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.94 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 5.20 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 0.49 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.97 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 10.49 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.80 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.70 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.53 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.76 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 10.61 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 4.94 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.54 </td>
   <td style="text-align:right;"> 26.60 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.62 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 3.30 </td>
   <td style="text-align:right;"> 0.67 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 13.01 </td>
   <td style="text-align:right;"> 0.49 </td>
   <td style="text-align:right;"> 1.54 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 5.19 </td>
   <td style="text-align:right;"> 1.06 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 26.19 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 1.53 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.81 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 51.85 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.03 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.70 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.64 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.85 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 23.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.92 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.81 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 50.33 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.98 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.87 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 200,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 16.86 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.35 </td>
   <td style="text-align:right;"> 101.04 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 5.86 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 10.02 </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 1.43 </td>
   <td style="text-align:right;"> 44.06 </td>
   <td style="text-align:right;"> 0.44 </td>
   <td style="text-align:right;"> 5.53 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 17.79 </td>
   <td style="text-align:right;"> 1.07 </td>
   <td style="text-align:right;"> 1.35 </td>
   <td style="text-align:right;"> 97.81 </td>
   <td style="text-align:right;"> 0.98 </td>
   <td style="text-align:right;"> 5.61 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 41.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.97 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 246.93 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 14.39 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 22.67 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 103.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 12.40 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 41.69 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.96 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 242.61 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 14.03 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 1,000,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 83.11 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 5.87 </td>
   <td style="text-align:right;"> 490.34 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 29.04 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 43.80 </td>
   <td style="text-align:right;"> 0.54 </td>
   <td style="text-align:right;"> 6.65 </td>
   <td style="text-align:right;"> 199.48 </td>
   <td style="text-align:right;"> 0.41 </td>
   <td style="text-align:right;"> 22.77 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 81.07 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 5.84 </td>
   <td style="text-align:right;"> 489.56 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 29.17 </td>
  </tr>
</tbody>
</table>


### Benchmarking PCCC v3.1 (without subconditions)

<table>
<caption>Expected time (seconds), relative time (with respect to data.frame), and expected memory use, by flagging method (current or cumulative), number of encounters, and input data storage format.</caption>
 <thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">flag.method = 'current'</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">flag.method = 'cumulative'</div></th>
</tr>
  <tr>
   <th style="text-align:center;"> Encounters </th>
   <th style="text-align:center;"> Data Class </th>
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
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 1,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.25 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.13 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.86 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.92 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.16 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 2.46 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.39 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.23 </td>
   <td style="text-align:right;"> 0.81 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 1.63 </td>
   <td style="text-align:right;"> 0.67 </td>
   <td style="text-align:right;"> 0.38 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 2.54 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 0.39 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.60 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.62 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.57 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.20 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.60 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 1.47 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 12.48 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.98 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 0.35 </td>
   <td style="text-align:right;"> 6.96 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 0.90 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 1.48 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 12.60 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.99 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.40 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 24.81 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.79 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.07 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.67 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13.17 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.53 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.59 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.40 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 25.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.78 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 7.74 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 60.66 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 4.20 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 4.95 </td>
   <td style="text-align:right;"> 0.64 </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 30.38 </td>
   <td style="text-align:right;"> 0.51 </td>
   <td style="text-align:right;"> 3.66 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 7.90 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 0.59 </td>
   <td style="text-align:right;"> 61.57 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 4.12 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 14.49 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.98 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 118.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.04 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.61 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 56.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.48 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.03 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 14.84 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.97 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 119.40 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.78 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 200,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 27.48 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.72 </td>
   <td style="text-align:right;"> 234.02 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 15.65 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 15.71 </td>
   <td style="text-align:right;"> 0.58 </td>
   <td style="text-align:right;"> 1.77 </td>
   <td style="text-align:right;"> 106.93 </td>
   <td style="text-align:right;"> 0.46 </td>
   <td style="text-align:right;"> 13.67 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 28.19 </td>
   <td style="text-align:right;"> 1.04 </td>
   <td style="text-align:right;"> 1.72 </td>
   <td style="text-align:right;"> 235.23 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 15.08 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 67.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.89 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 594.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38.66 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 36.16 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 261.26 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.44 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 33.35 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 68.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.91 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 597.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 37.76 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 1,000,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 134.46 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 7.74 </td>
   <td style="text-align:right;"> 1229.21 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 78.00 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 69.70 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 9.55 </td>
   <td style="text-align:right;"> 532.00 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 67.04 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 136.95 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 7.85 </td>
   <td style="text-align:right;"> 1235.82 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 77.17 </td>
  </tr>
</tbody>
</table>


### Benchmarking PCCC v3.1 (with subconditions)

<table>
<caption>Expected time (seconds), relative time (with respect to data.frame), and expected memory use, by flagging method (current or cumulative), number of encounters, and input data storage format.</caption>
 <thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">flag.method = 'current'</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">flag.method = 'cumulative'</div></th>
</tr>
  <tr>
   <th style="text-align:center;"> Encounters </th>
   <th style="text-align:center;"> Data Class </th>
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
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 1,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.36 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.33 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.17 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.97 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.78 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.33 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.33 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.32 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 2.67 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.41 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.89 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 1.86 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 0.40 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.32 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 2.69 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.41 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.63 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.80 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.62 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.60 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.64 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 1.61 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 13.45 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.03 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 1.21 </td>
   <td style="text-align:right;"> 0.75 </td>
   <td style="text-align:right;"> 0.35 </td>
   <td style="text-align:right;"> 7.86 </td>
   <td style="text-align:right;"> 0.58 </td>
   <td style="text-align:right;"> 0.94 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 1.61 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 13.35 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.04 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.35 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.40 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 26.90 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.87 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.72 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 14.85 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.65 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.34 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.40 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 26.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.86 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 8.40 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 66.19 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 4.46 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 5.77 </td>
   <td style="text-align:right;"> 0.69 </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 34.28 </td>
   <td style="text-align:right;"> 0.52 </td>
   <td style="text-align:right;"> 3.80 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 8.38 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 64.54 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 4.35 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.67 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.06 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 128.19 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.61 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 10.22 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.66 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 63.92 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.44 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.63 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 126.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.46 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 200,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 29.85 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.94 </td>
   <td style="text-align:right;"> 252.38 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 16.73 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 18.36 </td>
   <td style="text-align:right;"> 0.63 </td>
   <td style="text-align:right;"> 1.77 </td>
   <td style="text-align:right;"> 121.90 </td>
   <td style="text-align:right;"> 0.49 </td>
   <td style="text-align:right;"> 14.65 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 29.60 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 1.91 </td>
   <td style="text-align:right;"> 250.86 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 16.72 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 74.48 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.37 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 642.84 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 40.35 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 42.11 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.24 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 300.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.47 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 35.40 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 72.35 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 642.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 41.82 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 1,000,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 152.98 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 8.44 </td>
   <td style="text-align:right;"> 1334.56 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 78.96 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 81.12 </td>
   <td style="text-align:right;"> 0.54 </td>
   <td style="text-align:right;"> 8.84 </td>
   <td style="text-align:right;"> 612.92 </td>
   <td style="text-align:right;"> 0.46 </td>
   <td style="text-align:right;"> 69.18 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 145.63 </td>
   <td style="text-align:right;"> 0.96 </td>
   <td style="text-align:right;"> 8.37 </td>
   <td style="text-align:right;"> 1331.92 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 84.77 </td>
  </tr>
</tbody>
</table>


