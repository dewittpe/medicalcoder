# AHRQ Elixhauser (ICD-10-CM) Cross-Checks

This directory contains the helper script, documentation, and the
SAS exported data used to compare `medicalcoder::comorbidities()` with the
official Agency for Healthcare Research and Quality (AHRQ) Elixhauser
Comorbidity Software Refined for ICD-10-CM.

## 1. Prepare SAS inputs in R

The `mdcr` data in the `medicalcoder` package will be formatted as needed for
the AHRQ macros.

```bash
Rscript tests/ahrq/prepare-mdcr-cmr.R [YEAR] # defaults to 2025
```

For each year requested the script will:

* filter the packaged `mdcr` data to ICD-10-CM;
* spread codes to the wide layout expected by the SAS mapping program;
* write `{YEAR}/mdcr_for_sas_{YEAR}.csv`;

## 2. Unzip and modify the SAS scripts








- if `tests/ahrq/mdcr_icd10_with_cmr_v{YEAR}.csv` exists (exported from SAS), convert it to `tests/ahrq/expected/mdcr_elixhauser_ahrq{YEAR}_expected.rds` for automated testing.

Watch the console for the `NUMDX` value (currently 41), which matches the number of diagnosis columns created.

## 2. Unzip the SAS distribution

The HCUP download (already stored in `data-raw/elixhauser/ahrq/`) ships as versioned zip files, e.g. `CMR_v2025.1.zip`.

```bash
unzip data-raw/elixhauser/ahrq/CMR_v2025.1.zip -d data-raw/elixhauser/ahrq
```

Repeat for other years as needed (`CMR_v2024.1.zip`, etc.).

## 3. Run the format program in SAS

Before mapping diagnoses, execute `CMR_Format_Program_v{YEAR}-1.sas` so the `$COMFMT` format catalog is available. Update the `LIBNAME LIBRARY` statement to a writable directory, for example:

```sas
libname library '/full/path/to/data-raw/elixhauser/ahrq/fmtlib';
```

## 4. Configure and run the mapping program

Open `CMR_Mapping_Program_v{YEAR}-1.sas` and edit the macro block near the top:

```sas
libname library '/full/path/to/data-raw/elixhauser/ahrq/fmtlib';
libname in1     '/full/path/to/tests/ahrq';
libname out1    '/full/path/to/tests/ahrq';

%let DXPREFIX = I10_DX;
%let POAPREFIX = ;        * leave blank; POA indicators are unavailable;
%let NUMDX = 41;          * use the value reported by the prep script;
%let NDXVAR = I10_NDX;
%let POA = 0;
%let OBS = MAX;

%let CORE = mdcr_icd10_for_cmr_input_v{YEAR}-1;
%let OUT  = mdcr_icd10_with_cmr_v{YEAR}-1;
```

### Import the CSV into SAS

Use the SAS GUI or `PROC IMPORT` to load the CSV before invoking the `%comorbidity` macro:

```sas
proc import datafile='/full/path/to/tests/ahrq/mdcr_icd10_for_cmr_input_v{YEAR}-1.csv'
    out=in1.mdcr_icd10_for_cmr_input_v{YEAR}-1
    dbms=csv replace;
    guessingrows=MAX;
run;
```

With the dataset in place and macro variables set, run `%comorbidity;`.

## 5. Export the SAS output

After the mapping program finishes, export `out1.mdcr_icd10_with_cmr_v{YEAR}-1` back to CSV:

```sas
proc export data=out1.mdcr_icd10_with_cmr_v{YEAR}-1
    outfile='/full/path/to/tests/ahrq/mdcr_icd10_with_cmr_v{YEAR}-1.csv'
    dbms=csv replace;
run;
```

## 6. Build / refresh the R comparison fixtures

Re-run the preparation script so it detects the exported CSV(s) and produces RDS files in `tests/ahrq/expected/`.

## 7. Run the regression comparison in R

`tests/test-vs-ahrq.R` will check each year for which both an R method (`elixhauser_ahrqYYYY`) and a fixture exist. Missing fixtures or methods are reported as skips instead of failures so the test suite can still run without SAS output.

## 8. Optional: SAS index program

If you need the additional mortality/readmission indices supplied by AHRQ, execute `CMR_Index_Program_v{YEAR}-1.sas` after the mapping step. The current regression test only asserts the comorbidity indicator flags.

