################################################################################
# file: pccc/write_pccc_v3_sql.R
#
# purpose: Generate SQL lookup DDL/DML for PCCC v3.0 and v3.1 from the package's
#          curated internal data.
#
# output:
#   ../../inst/sql/pccc_v3/00_schema.sql
#   ../../inst/sql/pccc_v3/01_data.sql
#   ../../inst/sql/bigquery/pccc_v3/00_schema.sql
#   ../../inst/sql/bigquery/pccc_v3/01_data_*.sql
#   ../../inst/sql/portable/pccc_v3/00_schema.sql
#   ../../inst/sql/portable/pccc_v3/01_data_*.sql
#
# deps: base R only
################################################################################

load("../../R/sysdata.rda")

icd_codes <- ..mdcr_internal_icd_codes..[, c("code_id", "icdv", "dx", "full_code", "code")]
pccc_codes <- merge(
  x = ..mdcr_internal_pccc_codes..,
  y = icd_codes,
  by = "code_id",
  all.x = TRUE,
  sort = FALSE
)

pccc_codes <- pccc_codes[
  pccc_codes[["pccc_v3.0"]] == 1L | pccc_codes[["pccc_v3.1"]] == 1L,
  c("icdv", "dx", "full_code", "code", "condition", "subcondition",
    "transplant_flag", "tech_dep_flag", "pccc_v3.0", "pccc_v3.1")
]

expand_version <- function(x, version) {
  flag <- paste0("pccc_", version)
  x <- x[x[[flag]] == 1L, ]
  data.frame(
    pccc_version = paste0("pccc_", version),
    icdv = x[["icdv"]],
    dx = x[["dx"]],
    full_code = x[["full_code"]],
    code = x[["code"]],
    condition = x[["condition"]],
    subcondition = x[["subcondition"]],
    transplant_flag = x[["transplant_flag"]],
    tech_dep_flag = x[["tech_dep_flag"]],
    stringsAsFactors = FALSE
  )
}

lookup <- rbind(
  expand_version(pccc_codes, "v3.0"),
  expand_version(pccc_codes, "v3.1")
)
lookup <- unique(lookup)
lookup <- lookup[do.call(order, lookup[c("pccc_version", "icdv", "dx", "code", "condition", "subcondition")]), ]

conditions <- ..mdcr_internal_pccc_conditions..
conditions <- unique(conditions[c("condition", "subcondition", "condition_label", "subcondition_label")])
conditions <- conditions[do.call(order, conditions[c("condition", "subcondition")]), ]

sql_string <- function(x) {
  ifelse(is.na(x), "NULL", paste0("'", gsub("'", "''", x, fixed = TRUE), "'"))
}

value_rows <- function(x) {
  apply(
    x,
    1L,
    function(row) {
      paste0(
        "(",
        paste(
          c(
            sql_string(row[["pccc_version"]]),
            row[["icdv"]],
            row[["dx"]],
            sql_string(row[["full_code"]]),
            sql_string(row[["code"]]),
            sql_string(row[["condition"]]),
            sql_string(row[["subcondition"]]),
            row[["transplant_flag"]],
            row[["tech_dep_flag"]]
          ),
          collapse = ", "
        ),
        ")"
      )
    }
  )
}

condition_value_rows <- function(x) {
  apply(
    x,
    1L,
    function(row) {
      paste0(
        "(",
        paste(
          c(
            sql_string(row[["condition"]]),
            sql_string(row[["subcondition"]]),
            sql_string(row[["condition_label"]]),
            sql_string(row[["subcondition_label"]])
          ),
          collapse = ", "
        ),
        ")"
      )
    }
  )
}

outdir <- "../../inst/sql/pccc_v3"

writeLines(
  c(
    "-- PostgreSQL schema for medicalcoder PCCC v3 lookup and staging tables.",
    "-- Generated companion data lives in 01_data.sql.",
    "",
    "CREATE TABLE IF NOT EXISTS medicalcoder_pccc_v3_code_map (",
    "  pccc_version text NOT NULL CHECK (pccc_version IN ('pccc_v3.0', 'pccc_v3.1')),",
    "  icdv smallint NOT NULL CHECK (icdv IN (9, 10)),",
    "  dx smallint NOT NULL CHECK (dx IN (0, 1)),",
    "  full_code text NOT NULL,",
    "  code text NOT NULL,",
    "  condition text NOT NULL,",
    "  subcondition text NOT NULL,",
    "  transplant_flag smallint NOT NULL CHECK (transplant_flag IN (0, 1)),",
    "  tech_dep_flag smallint NOT NULL CHECK (tech_dep_flag IN (0, 1)),",
    "  PRIMARY KEY (pccc_version, icdv, dx, code, condition, subcondition, transplant_flag, tech_dep_flag)",
    ");",
    "",
    "CREATE INDEX IF NOT EXISTS medicalcoder_pccc_v3_code_map_code_idx",
    "  ON medicalcoder_pccc_v3_code_map (pccc_version, code);",
    "",
    "CREATE INDEX IF NOT EXISTS medicalcoder_pccc_v3_code_map_full_code_idx",
    "  ON medicalcoder_pccc_v3_code_map (pccc_version, full_code);",
    "",
    "CREATE TABLE IF NOT EXISTS medicalcoder_pccc_conditions (",
    "  condition text NOT NULL,",
    "  subcondition text NOT NULL,",
    "  condition_label text NOT NULL,",
    "  subcondition_label text NOT NULL,",
    "  PRIMARY KEY (condition, subcondition)",
    ");",
    "",
    "-- Current scoring input: one row per code. result_id is the output grouping key.",
    "-- Leave icdv or dx NULL if that distinction is not available; this matches the",
    "-- package behavior when icdv.var or dx.var is omitted and may increase matches.",
    "CREATE TABLE IF NOT EXISTS medicalcoder_pccc_v3_current_input (",
    "  result_id text NOT NULL,",
    "  icd_code text,",
    "  pccc_version text NOT NULL DEFAULT 'pccc_v3.1' CHECK (pccc_version IN ('pccc_v3.0', 'pccc_v3.1')),",
    "  icdv smallint CHECK (icdv IN (9, 10)),",
    "  dx smallint CHECK (dx IN (0, 1)),",
    "  poa smallint NOT NULL DEFAULT 1 CHECK (poa IN (0, 1))",
    ");",
    "",
    "-- Cumulative scoring input: subject_id is carried forward over encounter_sort.",
    "-- result_id is the output row key, typically an encounter id or a composite key.",
    "CREATE TABLE IF NOT EXISTS medicalcoder_pccc_v3_cumulative_input (",
    "  subject_id text NOT NULL,",
    "  result_id text NOT NULL,",
    "  encounter_sort text NOT NULL,",
    "  icd_code text,",
    "  pccc_version text NOT NULL DEFAULT 'pccc_v3.1' CHECK (pccc_version IN ('pccc_v3.0', 'pccc_v3.1')),",
    "  icdv smallint CHECK (icdv IN (9, 10)),",
    "  dx smallint CHECK (dx IN (0, 1)),",
    "  poa smallint NOT NULL DEFAULT 1 CHECK (poa IN (0, 1))",
    ");"
  ),
  file.path(outdir, "00_schema.sql")
)

writeLines(
  c(
    "-- PCCC v3 lookup data generated from R/sysdata.rda.",
    "-- Source data is curated by data-raw/pccc/pccc_v3.R and data-raw/pccc/pccc_codes.R.",
    "",
    "TRUNCATE TABLE medicalcoder_pccc_v3_code_map;",
    "TRUNCATE TABLE medicalcoder_pccc_conditions;",
    "",
    "INSERT INTO medicalcoder_pccc_conditions",
    "  (condition, subcondition, condition_label, subcondition_label)",
    "VALUES",
    paste0(condition_value_rows(conditions), collapse = ",\n"),
    ";",
    "",
    "INSERT INTO medicalcoder_pccc_v3_code_map",
    "  (pccc_version, icdv, dx, full_code, code, condition, subcondition, transplant_flag, tech_dep_flag)",
    "VALUES",
    paste0(value_rows(lookup), collapse = ",\n"),
    ";"
  ),
  file.path(outdir, "01_data.sql")
)

################################################################################
# BigQuery Standard SQL output

bq_outdir <- "../../inst/sql/bigquery/pccc_v3"
dir.create(bq_outdir, recursive = TRUE, showWarnings = FALSE)

bq_value_rows <- function(x) {
  apply(
    x,
    1L,
    function(row) {
      paste0(
        "(",
        paste(
          c(
            sql_string(row[["pccc_version"]]),
            row[["icdv"]],
            row[["dx"]],
            sql_string(row[["full_code"]]),
            sql_string(row[["code"]]),
            sql_string(row[["condition"]]),
            sql_string(row[["subcondition"]]),
            row[["transplant_flag"]],
            row[["tech_dep_flag"]]
          ),
          collapse = ", "
        ),
        ")"
      )
    }
  )
}

bq_condition_value_rows <- condition_value_rows

chunk_insert <- function(table, columns, rows, chunk_size = 500L) {
  chunks <- split(rows, ceiling(seq_along(rows) / chunk_size))
  unlist(
    lapply(
      chunks,
      function(chunk) {
        c(
          sprintf("INSERT INTO `%s`", table),
          sprintf("  (%s)", paste(columns, collapse = ", ")),
          "VALUES",
          paste0(chunk, collapse = ",\n"),
          ";",
          ""
        )
      }
    ),
    use.names = FALSE
  )
}

writeLines(
  c(
    "-- BigQuery Standard SQL schema for medicalcoder PCCC v3 lookup and staging tables.",
    "-- Set your default dataset before running, or replace unqualified table names.",
    "-- Generated companion data lives in 01_data_*.sql.",
    "",
    "CREATE TABLE IF NOT EXISTS `medicalcoder_pccc_v3_code_map` (",
    "  pccc_version STRING NOT NULL,",
    "  icdv INT64 NOT NULL,",
    "  dx INT64 NOT NULL,",
    "  full_code STRING NOT NULL,",
    "  code STRING NOT NULL,",
    "  condition STRING NOT NULL,",
    "  subcondition STRING NOT NULL,",
    "  transplant_flag INT64 NOT NULL,",
    "  tech_dep_flag INT64 NOT NULL",
    ")",
    "CLUSTER BY pccc_version, code, full_code, condition;",
    "",
    "CREATE TABLE IF NOT EXISTS `medicalcoder_pccc_conditions` (",
    "  condition STRING NOT NULL,",
    "  subcondition STRING NOT NULL,",
    "  condition_label STRING NOT NULL,",
    "  subcondition_label STRING NOT NULL",
    ")",
    "CLUSTER BY condition, subcondition;",
    "",
    "-- Current scoring input: one row per code. result_id is the output grouping key.",
    "-- Leave icdv or dx NULL if that distinction is not available; this matches the",
    "-- package behavior when icdv.var or dx.var is omitted and may increase matches.",
    "CREATE TABLE IF NOT EXISTS `medicalcoder_pccc_v3_current_input` (",
    "  result_id STRING NOT NULL,",
    "  icd_code STRING,",
    "  pccc_version STRING NOT NULL,",
    "  icdv INT64,",
    "  dx INT64,",
    "  poa INT64 NOT NULL",
    ");",
    "",
    "-- Cumulative scoring input: subject_id is carried forward over encounter_sort.",
    "-- result_id is the output row key, typically an encounter id or a composite key.",
    "CREATE TABLE IF NOT EXISTS `medicalcoder_pccc_v3_cumulative_input` (",
    "  subject_id STRING NOT NULL,",
    "  result_id STRING NOT NULL,",
    "  encounter_sort STRING NOT NULL,",
    "  icd_code STRING,",
    "  pccc_version STRING NOT NULL,",
    "  icdv INT64,",
    "  dx INT64,",
    "  poa INT64 NOT NULL",
    ");"
  ),
  file.path(bq_outdir, "00_schema.sql")
)

bq_data_files <- list.files(bq_outdir, pattern = "^01_data.*\\.sql$", full.names = TRUE)
if (length(bq_data_files)) {
  unlink(bq_data_files)
}

writeLines(
  c(
    "-- BigQuery Standard SQL PCCC v3 lookup reset.",
    "-- Run before the 01_data_* insert files.",
    "",
    "TRUNCATE TABLE `medicalcoder_pccc_v3_code_map`;",
    "TRUNCATE TABLE `medicalcoder_pccc_conditions`;"
  ),
  file.path(bq_outdir, "01_data_00_reset.sql")
)

writeLines(
  c(
    "-- BigQuery Standard SQL PCCC v3 condition labels generated from R/sysdata.rda.",
    "",
    chunk_insert(
      table = "medicalcoder_pccc_conditions",
      columns = c("condition", "subcondition", "condition_label", "subcondition_label"),
      rows = bq_condition_value_rows(conditions),
      chunk_size = 500L
    )
  ),
  file.path(bq_outdir, "01_data_01_conditions.sql")
)

code_rows <- bq_value_rows(lookup)
code_chunks <- split(code_rows, ceiling(seq_along(code_rows) / 500L))
for (i in seq_along(code_chunks)) {
  writeLines(
    c(
      "-- BigQuery Standard SQL PCCC v3 lookup data generated from R/sysdata.rda.",
      "-- Source data is curated by data-raw/pccc/pccc_v3.R and data-raw/pccc/pccc_codes.R.",
      "",
      chunk_insert(
        table = "medicalcoder_pccc_v3_code_map",
        columns = c("pccc_version", "icdv", "dx", "full_code", "code", "condition",
                    "subcondition", "transplant_flag", "tech_dep_flag"),
        rows = code_chunks[[i]],
        chunk_size = 500L
      )
    ),
    file.path(bq_outdir, sprintf("01_data_%02d_code_map.sql", i + 1L))
  )
}

################################################################################
# Portable DBI SQL output

portable_outdir <- "../../inst/sql/portable/pccc_v3"
dir.create(portable_outdir, recursive = TRUE, showWarnings = FALSE)

portable_chunk_insert <- function(table, columns, rows, chunk_size = 500L) {
  chunks <- split(rows, ceiling(seq_along(rows) / chunk_size))
  unlist(
    lapply(
      chunks,
      function(chunk) {
        c(
          sprintf("INSERT INTO %s", table),
          sprintf("  (%s)", paste(columns, collapse = ", ")),
          "VALUES",
          paste0(chunk, collapse = ",\n"),
          ";",
          ""
        )
      }
    ),
    use.names = FALSE
  )
}

writeLines(
  c(
    "-- Portable DBI SQL schema for medicalcoder PCCC v3 lookup and staging tables.",
    "-- Intended for engines such as DuckDB and RSQLite.",
    "-- Generated companion data lives in 01_data_*.sql.",
    "",
    "CREATE TABLE IF NOT EXISTS medicalcoder_pccc_v3_code_map (",
    "  pccc_version VARCHAR(16),",
    "  icdv INTEGER,",
    "  dx INTEGER,",
    "  full_code VARCHAR(16),",
    "  code VARCHAR(16),",
    "  condition VARCHAR(64),",
    "  subcondition VARCHAR(128),",
    "  transplant_flag INTEGER,",
    "  tech_dep_flag INTEGER",
    ");",
    "",
    "CREATE TABLE IF NOT EXISTS medicalcoder_pccc_conditions (",
    "  condition VARCHAR(64),",
    "  subcondition VARCHAR(128),",
    "  condition_label VARCHAR(128),",
    "  subcondition_label VARCHAR(128)",
    ");",
    "",
    "-- Current scoring input: one row per code. result_id is the output grouping key.",
    "-- Leave icdv or dx NULL if that distinction is not available; this matches the",
    "-- package behavior when icdv.var or dx.var is omitted and may increase matches.",
    "CREATE TABLE IF NOT EXISTS medicalcoder_pccc_v3_current_input (",
    "  result_id VARCHAR(128),",
    "  icd_code VARCHAR(16),",
    "  pccc_version VARCHAR(16),",
    "  icdv INTEGER,",
    "  dx INTEGER,",
    "  poa INTEGER",
    ");",
    "",
    "-- Cumulative scoring input: subject_id is carried forward over encounter_sort.",
    "-- result_id is the output row key, typically an encounter id or a composite key.",
    "CREATE TABLE IF NOT EXISTS medicalcoder_pccc_v3_cumulative_input (",
    "  subject_id VARCHAR(128),",
    "  result_id VARCHAR(128),",
    "  encounter_sort VARCHAR(128),",
    "  icd_code VARCHAR(16),",
    "  pccc_version VARCHAR(16),",
    "  icdv INTEGER,",
    "  dx INTEGER,",
    "  poa INTEGER",
    ");"
  ),
  file.path(portable_outdir, "00_schema.sql")
)

portable_data_files <- list.files(portable_outdir, pattern = "^01_data.*\\.sql$", full.names = TRUE)
if (length(portable_data_files)) {
  unlink(portable_data_files)
}

writeLines(
  c(
    "-- Portable DBI SQL PCCC v3 lookup reset.",
    "-- DELETE is used instead of TRUNCATE for SQLite compatibility.",
    "",
    "DELETE FROM medicalcoder_pccc_v3_code_map;",
    "DELETE FROM medicalcoder_pccc_conditions;"
  ),
  file.path(portable_outdir, "01_data_00_reset.sql")
)

writeLines(
  c(
    "-- Portable DBI SQL PCCC v3 condition labels generated from R/sysdata.rda.",
    "",
    portable_chunk_insert(
      table = "medicalcoder_pccc_conditions",
      columns = c("condition", "subcondition", "condition_label", "subcondition_label"),
      rows = condition_value_rows(conditions),
      chunk_size = 500L
    )
  ),
  file.path(portable_outdir, "01_data_01_conditions.sql")
)

for (i in seq_along(code_chunks)) {
  writeLines(
    c(
      "-- Portable DBI SQL PCCC v3 lookup data generated from R/sysdata.rda.",
      "-- Source data is curated by data-raw/pccc/pccc_v3.R and data-raw/pccc/pccc_codes.R.",
      "",
      portable_chunk_insert(
        table = "medicalcoder_pccc_v3_code_map",
        columns = c("pccc_version", "icdv", "dx", "full_code", "code", "condition",
                    "subcondition", "transplant_flag", "tech_dep_flag"),
        rows = code_chunks[[i]],
        chunk_size = 500L
      )
    ),
    file.path(portable_outdir, sprintf("01_data_%02d_code_map.sql", i + 1L))
  )
}

################################################################################
#                                 End of File                                  #
################################################################################
