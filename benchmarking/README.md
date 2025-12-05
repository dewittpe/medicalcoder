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
0.3106419
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
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.19 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.48 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.17 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.89 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.81 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.23 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.20 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.20 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.85 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.23 </td>
   <td style="text-align:right;"> 0.83 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 0.72 </td>
   <td style="text-align:right;"> 0.30 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 1.07 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 0.79 </td>
   <td style="text-align:right;"> 0.98 </td>
   <td style="text-align:right;"> 0.30 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.53 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.93 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.20 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.62 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.36 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.49 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.93 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.47 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.77 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.36 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.99 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 4.00 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.48 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.66 </td>
   <td style="text-align:right;"> 0.68 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 2.26 </td>
   <td style="text-align:right;"> 0.57 </td>
   <td style="text-align:right;"> 0.44 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.83 </td>
   <td style="text-align:right;"> 0.84 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 2.70 </td>
   <td style="text-align:right;"> 0.68 </td>
   <td style="text-align:right;"> 0.44 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.93 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.17 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.68 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.62 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.26 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.53 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.61 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.78 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.13 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.63 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.62 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 4.72 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.54 </td>
   <td style="text-align:right;"> 20.42 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.26 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 2.61 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 9.66 </td>
   <td style="text-align:right;"> 0.48 </td>
   <td style="text-align:right;"> 1.12 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 3.33 </td>
   <td style="text-align:right;"> 0.72 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 11.96 </td>
   <td style="text-align:right;"> 0.59 </td>
   <td style="text-align:right;"> 1.16 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.76 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.80 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 38.94 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.33 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.52 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 17.37 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.02 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.66 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.80 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 21.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.20 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 200,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 16.55 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.32 </td>
   <td style="text-align:right;"> 75.52 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 4.43 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 8.00 </td>
   <td style="text-align:right;"> 0.49 </td>
   <td style="text-align:right;"> 1.27 </td>
   <td style="text-align:right;"> 32.04 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 3.84 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 9.75 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 1.29 </td>
   <td style="text-align:right;"> 39.68 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 4.21 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 40.19 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.89 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 189.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 10.35 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 18.37 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.72 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 76.28 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9.39 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 22.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.71 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 94.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9.75 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 1,000,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 80.76 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 5.71 </td>
   <td style="text-align:right;"> 389.11 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 20.00 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 35.76 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 5.33 </td>
   <td style="text-align:right;"> 150.93 </td>
   <td style="text-align:right;"> 0.39 </td>
   <td style="text-align:right;"> 19.53 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 43.54 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 5.15 </td>
   <td style="text-align:right;"> 189.79 </td>
   <td style="text-align:right;"> 0.49 </td>
   <td style="text-align:right;"> 18.45 </td>
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
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.20 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.67 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.89 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.81 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.24 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.22 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.74 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 1.19 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.25 </td>
   <td style="text-align:right;"> 0.84 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.85 </td>
   <td style="text-align:right;"> 0.73 </td>
   <td style="text-align:right;"> 0.32 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.32 </td>
   <td style="text-align:right;"> 1.11 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 1.12 </td>
   <td style="text-align:right;"> 0.97 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.33 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.72 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.76 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.72 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.64 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.97 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.40 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 1.06 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.35 </td>
   <td style="text-align:right;"> 5.55 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.52 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.72 </td>
   <td style="text-align:right;"> 0.69 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 3.23 </td>
   <td style="text-align:right;"> 0.58 </td>
   <td style="text-align:right;"> 0.56 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.92 </td>
   <td style="text-align:right;"> 0.88 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 3.97 </td>
   <td style="text-align:right;"> 0.72 </td>
   <td style="text-align:right;"> 0.54 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 11.14 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.81 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.63 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.86 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.66 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.80 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.40 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.66 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.82 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 5.19 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.54 </td>
   <td style="text-align:right;"> 27.39 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.69 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 2.92 </td>
   <td style="text-align:right;"> 0.57 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 13.76 </td>
   <td style="text-align:right;"> 0.51 </td>
   <td style="text-align:right;"> 1.72 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 3.66 </td>
   <td style="text-align:right;"> 0.71 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 16.85 </td>
   <td style="text-align:right;"> 0.62 </td>
   <td style="text-align:right;"> 1.62 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 9.49 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.81 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 52.73 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.17 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.01 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.85 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 25.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.49 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.07 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.10 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.66 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.82 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 30.70 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.94 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 200,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 17.66 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.33 </td>
   <td style="text-align:right;"> 102.68 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 6.15 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 8.78 </td>
   <td style="text-align:right;"> 0.51 </td>
   <td style="text-align:right;"> 1.40 </td>
   <td style="text-align:right;"> 48.30 </td>
   <td style="text-align:right;"> 0.48 </td>
   <td style="text-align:right;"> 5.73 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 10.56 </td>
   <td style="text-align:right;"> 0.62 </td>
   <td style="text-align:right;"> 1.35 </td>
   <td style="text-align:right;"> 57.25 </td>
   <td style="text-align:right;"> 0.57 </td>
   <td style="text-align:right;"> 5.59 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 42.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.92 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 255.09 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.10 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 19.67 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.47 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.99 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 115.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13.88 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 24.13 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 137.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13.88 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 1,000,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 84.97 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 5.89 </td>
   <td style="text-align:right;"> 517.47 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 30.59 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 37.75 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 5.64 </td>
   <td style="text-align:right;"> 228.19 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 28.42 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 47.85 </td>
   <td style="text-align:right;"> 0.58 </td>
   <td style="text-align:right;"> 5.32 </td>
   <td style="text-align:right;"> 273.80 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 28.96 </td>
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
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.25 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.34 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.19 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.75 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.05 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.78 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.33 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.29 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.52 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.15 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.38 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 2.60 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.41 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.26 </td>
   <td style="text-align:right;"> 0.68 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 1.73 </td>
   <td style="text-align:right;"> 0.68 </td>
   <td style="text-align:right;"> 0.40 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.39 </td>
   <td style="text-align:right;"> 1.03 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 2.40 </td>
   <td style="text-align:right;"> 0.96 </td>
   <td style="text-align:right;"> 0.39 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.77 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.33 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.63 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.44 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.33 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.58 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.68 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.89 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.34 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.76 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.77 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.58 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 1.51 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.37 </td>
   <td style="text-align:right;"> 12.50 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.02 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.77 </td>
   <td style="text-align:right;"> 0.51 </td>
   <td style="text-align:right;"> 0.35 </td>
   <td style="text-align:right;"> 6.61 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 0.92 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 1.20 </td>
   <td style="text-align:right;"> 0.79 </td>
   <td style="text-align:right;"> 0.38 </td>
   <td style="text-align:right;"> 8.65 </td>
   <td style="text-align:right;"> 0.69 </td>
   <td style="text-align:right;"> 0.94 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.02 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.44 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 24.77 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.81 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.46 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 12.24 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.49 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.58 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.18 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.73 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.47 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.96 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.65 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.65 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 7.51 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.67 </td>
   <td style="text-align:right;"> 60.78 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 4.11 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 3.11 </td>
   <td style="text-align:right;"> 0.42 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 27.76 </td>
   <td style="text-align:right;"> 0.46 </td>
   <td style="text-align:right;"> 3.59 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 4.84 </td>
   <td style="text-align:right;"> 0.65 </td>
   <td style="text-align:right;"> 0.73 </td>
   <td style="text-align:right;"> 36.71 </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 3.78 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 14.21 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.08 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 118.87 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.83 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.91 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 51.09 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.44 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.09 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.61 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.16 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 69.71 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.16 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 200,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 27.31 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.87 </td>
   <td style="text-align:right;"> 235.78 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 15.24 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 9.34 </td>
   <td style="text-align:right;"> 0.35 </td>
   <td style="text-align:right;"> 1.49 </td>
   <td style="text-align:right;"> 97.30 </td>
   <td style="text-align:right;"> 0.42 </td>
   <td style="text-align:right;"> 14.05 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 15.28 </td>
   <td style="text-align:right;"> 0.57 </td>
   <td style="text-align:right;"> 1.98 </td>
   <td style="text-align:right;"> 135.19 </td>
   <td style="text-align:right;"> 0.58 </td>
   <td style="text-align:right;"> 13.80 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 67.70 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.14 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 601.65 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 37.74 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 21.48 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.32 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.20 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 243.94 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 34.18 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 36.19 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 336.73 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 33.70 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 1,000,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 137.87 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 8.04 </td>
   <td style="text-align:right;"> 1247.81 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 76.08 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 42.50 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 6.19 </td>
   <td style="text-align:right;"> 510.88 </td>
   <td style="text-align:right;"> 0.41 </td>
   <td style="text-align:right;"> 66.85 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 72.45 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 8.44 </td>
   <td style="text-align:right;"> 690.52 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 67.83 </td>
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
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.27 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.34 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.22 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.17 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.80 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.34 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.40 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.53 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.31 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.74 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.24 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.33 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 2,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 0.42 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 2.84 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.41 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 0.73 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 1.93 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 0.40 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 1.32 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 2.73 </td>
   <td style="text-align:right;"> 1.01 </td>
   <td style="text-align:right;"> 0.40 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 5,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.84 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.33 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.77 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.64 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.62 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.33 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.97 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.59 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.60 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.89 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.07 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.34 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 5.38 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.79 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.61 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 10,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 1.62 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.36 </td>
   <td style="text-align:right;"> 13.61 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.06 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 0.88 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 0.36 </td>
   <td style="text-align:right;"> 7.31 </td>
   <td style="text-align:right;"> 0.54 </td>
   <td style="text-align:right;"> 0.95 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 1.50 </td>
   <td style="text-align:right;"> 0.92 </td>
   <td style="text-align:right;"> 0.37 </td>
   <td style="text-align:right;"> 9.79 </td>
   <td style="text-align:right;"> 0.71 </td>
   <td style="text-align:right;"> 0.97 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 20,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.24 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.44 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 26.82 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.87 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.50 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.42 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 13.54 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.51 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.65 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 2.69 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.83 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 17.90 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.67 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.71 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 50,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 8.09 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 0.67 </td>
   <td style="text-align:right;"> 65.35 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 4.26 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 3.59 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 31.18 </td>
   <td style="text-align:right;"> 0.48 </td>
   <td style="text-align:right;"> 3.78 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 5.95 </td>
   <td style="text-align:right;"> 0.75 </td>
   <td style="text-align:right;"> 0.67 </td>
   <td style="text-align:right;"> 40.48 </td>
   <td style="text-align:right;"> 0.63 </td>
   <td style="text-align:right;"> 3.93 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 100,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 15.56 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.07 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 127.35 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 8.20 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 6.26 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.41 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.92 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 59.44 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.47 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.40 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 10.21 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.67 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.04 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 75.43 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.60 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 7.63 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 200,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 30.28 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 1.84 </td>
   <td style="text-align:right;"> 252.49 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 16.10 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 11.32 </td>
   <td style="text-align:right;"> 0.38 </td>
   <td style="text-align:right;"> 1.53 </td>
   <td style="text-align:right;"> 115.89 </td>
   <td style="text-align:right;"> 0.46 </td>
   <td style="text-align:right;"> 14.68 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 18.18 </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 1.74 </td>
   <td style="text-align:right;"> 145.13 </td>
   <td style="text-align:right;"> 0.58 </td>
   <td style="text-align:right;"> 14.86 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;background-color: rgba(217, 217, 217, 255) !important;" rowspan="3"> 500,000 </td>
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.frame </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 75.12 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 4.06 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 647.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 1.00 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 40.13 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> data.table </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 26.77 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.36 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.39 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 291.30 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.45 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 36.34 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;background-color: rgba(217, 217, 217, 255) !important;"> tibble </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 42.37 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 3.82 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 365.95 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 0.57 </td>
   <td style="text-align:right;background-color: rgba(217, 217, 217, 255) !important;"> 35.56 </td>
  </tr>
  <tr>
   <td style="text-align:center;vertical-align: middle !important;" rowspan="3"> 1,000,000 </td>
   <td style="text-align:center;"> data.frame </td>
   <td style="text-align:right;"> 151.87 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 7.90 </td>
   <td style="text-align:right;"> 1349.61 </td>
   <td style="text-align:right;"> 1.00 </td>
   <td style="text-align:right;"> 81.79 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> data.table </td>
   <td style="text-align:right;"> 53.90 </td>
   <td style="text-align:right;"> 0.36 </td>
   <td style="text-align:right;"> 6.74 </td>
   <td style="text-align:right;"> 602.01 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 72.67 </td>
  </tr>
  <tr>
   
   <td style="text-align:center;"> tibble </td>
   <td style="text-align:right;"> 84.35 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 7.57 </td>
   <td style="text-align:right;"> 764.11 </td>
   <td style="text-align:right;"> 0.57 </td>
   <td style="text-align:right;"> 69.49 </td>
  </tr>
</tbody>
</table>


