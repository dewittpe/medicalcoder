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
0.3042897
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
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.37 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.26 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.72 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.09 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.17 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.72 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 0.80 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 0.64 </td>
   <td style="text-align:right;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.18 </td>
   <td style="text-align:right;"> 1.08 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.73 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 0.30 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.82 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.35 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.72 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.35 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.82 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.36 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.88 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 3.88 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.44 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.58 </td>
   <td style="text-align:right;"> 0.66 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 2.08 </td>
   <td style="text-align:right;"> 0.54 </td>
   <td style="text-align:right;"> 0.44 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.89 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 3.89 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.45 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.88 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.37 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.90 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.64 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.13 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.61 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.06 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.52 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.64 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.86 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.37 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.94 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.65 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 4.87 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.49 </td>
   <td style="text-align:right;"> 19.52 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.23 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 2.61 </td>
   <td style="text-align:right;"> 0.54 </td>
   <td style="text-align:right;"> 0.52 </td>
   <td style="text-align:right;"> 9.48 </td>
   <td style="text-align:right;"> 0.49 </td>
   <td style="text-align:right;"> 1.23 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 4.69 </td>
   <td style="text-align:right;"> 0.97 </td>
   <td style="text-align:right;"> 0.51 </td>
   <td style="text-align:right;"> 19.75 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 1.23 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.93 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 37.98 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.26 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.35 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.78 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 17.19 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.19 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.98 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.78 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38.34 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.26 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 200,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 16.59 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.26 </td>
   <td style="text-align:right;"> 74.58 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 4.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 7.51 </td>
   <td style="text-align:right;"> 0.46 </td>
   <td style="text-align:right;"> 1.29 </td>
   <td style="text-align:right;"> 31.77 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 4.05 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 16.28 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.29 </td>
   <td style="text-align:right;"> 75.20 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 4.27 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 39.81 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.84 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 186.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 10.24 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 17.33 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.44 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 75.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9.37 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 39.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.86 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 188.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 10.13 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 1,000,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 78.88 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 5.79 </td>
   <td style="text-align:right;"> 379.24 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 20.63 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 34.63 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 5.81 </td>
   <td style="text-align:right;"> 148.65 </td>
   <td style="text-align:right;"> 0.40 </td>
   <td style="text-align:right;"> 18.32 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 79.85 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 5.69 </td>
   <td style="text-align:right;"> 383.84 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 20.22 </td>
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
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.53 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.09 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.84 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.76 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.28 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.20 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 1.05 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.30 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.15 </td>
   <td style="text-align:right;"> 0.77 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.69 </td>
   <td style="text-align:right;"> 0.67 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.20 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 1.05 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.62 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.40 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.69 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.40 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.61 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.40 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.96 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 5.50 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.55 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 0.63 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 3.11 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 0.55 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 5.46 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 0.56 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 10.97 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.89 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.17 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.87 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.98 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 10.96 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.90 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 5.29 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 26.37 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.89 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 2.78 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 13.89 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 1.77 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 5.15 </td>
   <td style="text-align:right;"> 0.98 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 26.73 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 1.91 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9.82 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.88 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 50.73 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.47 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.86 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.84 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 25.19 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.12 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.98 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 51.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.44 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 200,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 18.38 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.49 </td>
   <td style="text-align:right;"> 99.30 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 6.50 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 8.69 </td>
   <td style="text-align:right;"> 0.48 </td>
   <td style="text-align:right;"> 1.39 </td>
   <td style="text-align:right;"> 46.50 </td>
   <td style="text-align:right;"> 0.48 </td>
   <td style="text-align:right;"> 5.66 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 17.97 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 1.47 </td>
   <td style="text-align:right;"> 100.52 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 6.41 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 44.21 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 250.26 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.30 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 20.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.09 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 109.65 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.44 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 12.90 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 43.14 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 249.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.37 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 1,000,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 87.64 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 6.23 </td>
   <td style="text-align:right;"> 513.48 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 30.19 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 39.25 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 6.26 </td>
   <td style="text-align:right;"> 215.76 </td>
   <td style="text-align:right;"> 0.42 </td>
   <td style="text-align:right;"> 25.19 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 85.84 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 6.25 </td>
   <td style="text-align:right;"> 504.87 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 31.42 </td>
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
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.27 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.70 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.16 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.07 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 2.50 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.38 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.16 </td>
   <td style="text-align:right;"> 0.59 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 1.52 </td>
   <td style="text-align:right;"> 0.62 </td>
   <td style="text-align:right;"> 0.38 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 1.05 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 2.52 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.39 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.49 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.53 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.58 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.70 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.17 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.61 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 1.46 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 12.75 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.98 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.63 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 6.17 </td>
   <td style="text-align:right;"> 0.49 </td>
   <td style="text-align:right;"> 0.92 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 1.49 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 12.56 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 1.01 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.40 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 25.49 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.79 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.25 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 11.48 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.61 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.40 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 25.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.85 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 7.64 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.62 </td>
   <td style="text-align:right;"> 62.74 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 4.26 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 3.03 </td>
   <td style="text-align:right;"> 0.40 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 26.50 </td>
   <td style="text-align:right;"> 0.42 </td>
   <td style="text-align:right;"> 3.66 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 7.66 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.62 </td>
   <td style="text-align:right;"> 62.45 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 4.38 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 14.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 121.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.32 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.33 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.93 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 50.89 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.99 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 14.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 122.85 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.30 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 200,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 27.66 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.76 </td>
   <td style="text-align:right;"> 239.68 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 16.37 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 9.52 </td>
   <td style="text-align:right;"> 0.35 </td>
   <td style="text-align:right;"> 1.55 </td>
   <td style="text-align:right;"> 99.35 </td>
   <td style="text-align:right;"> 0.42 </td>
   <td style="text-align:right;"> 13.63 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 26.95 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 1.74 </td>
   <td style="text-align:right;"> 243.83 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 16.01 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 69.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 607.95 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 40.08 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 21.85 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 246.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 33.83 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 66.26 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.97 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 616.73 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 39.18 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 1,000,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 140.69 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 7.26 </td>
   <td style="text-align:right;"> 1256.20 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 79.21 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 42.29 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 6.21 </td>
   <td style="text-align:right;"> 502.29 </td>
   <td style="text-align:right;"> 0.40 </td>
   <td style="text-align:right;"> 68.99 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 133.94 </td>
   <td style="text-align:right;"> 0.96 </td>
   <td style="text-align:right;"> 7.23 </td>
   <td style="text-align:right;"> 1262.62 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 78.35 </td>
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
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.34 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.14 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.80 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.98 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.73 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.33 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.33 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.32 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 2.69 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.41 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.21 </td>
   <td style="text-align:right;"> 0.69 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 1.71 </td>
   <td style="text-align:right;"> 0.65 </td>
   <td style="text-align:right;"> 0.39 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.32 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 2.66 </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 0.41 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.63 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.69 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.60 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.63 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 1.59 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.35 </td>
   <td style="text-align:right;"> 13.16 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.03 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.80 </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 6.87 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 0.96 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 1.59 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 13.20 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 1.03 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 25.84 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.80 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.47 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 12.74 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.69 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.27 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 26.55 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.88 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 8.29 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.62 </td>
   <td style="text-align:right;"> 63.01 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 4.09 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 3.66 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 29.36 </td>
   <td style="text-align:right;"> 0.47 </td>
   <td style="text-align:right;"> 3.91 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 8.18 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 66.69 </td>
   <td style="text-align:right;"> 1.07 </td>
   <td style="text-align:right;"> 4.44 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.53 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 125.06 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.96 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.94 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 56.70 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.77 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.49 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 132.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.07 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.50 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 200,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 29.64 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.75 </td>
   <td style="text-align:right;"> 251.28 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 15.81 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 11.57 </td>
   <td style="text-align:right;"> 0.40 </td>
   <td style="text-align:right;"> 1.58 </td>
   <td style="text-align:right;"> 111.75 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 15.42 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 29.67 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 1.74 </td>
   <td style="text-align:right;"> 264.40 </td>
   <td style="text-align:right;"> 1.06 </td>
   <td style="text-align:right;"> 16.49 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 73.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 646.17 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 39.75 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 26.48 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.37 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 282.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.44 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 37.05 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 72.85 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.76 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 664.81 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.03 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 40.60 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 1,000,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 150.63 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 7.05 </td>
   <td style="text-align:right;"> 1341.64 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 80.41 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 51.26 </td>
   <td style="text-align:right;"> 0.35 </td>
   <td style="text-align:right;"> 6.73 </td>
   <td style="text-align:right;"> 585.30 </td>
   <td style="text-align:right;"> 0.44 </td>
   <td style="text-align:right;"> 71.25 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 146.26 </td>
   <td style="text-align:right;"> 0.98 </td>
   <td style="text-align:right;"> 7.01 </td>
   <td style="text-align:right;"> 1347.54 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 82.00 </td>
  </tr>
</tbody>
</table>


