################################################################################
# file: cms.R
#
# purpose: Build CMS ICD-9-CM diagnosis/procedure titles (v23 (FY 2006) through
#          v32 (FY 2015)) into cms.rds
#
# inputs: cms/cms_v{23..32}.zip
#   Data from CMS
#     Version 32 Full and Abbreviated Code Titles – Effective October 1, 2014
#     Version 31 Full and Abbreviated Code Titles - Effective October 1, 2013
#     Version 30 Full and Abbreviated Code Titles - Effective October 1, 2012
#                (05/16/2012: Corrections have been made to the full code
#                descriptions for diagnosis codes 59800, 59801, 65261, and
#                65263.)
#     Version 29 Full and Abbreviated Code Titles - Effective October 1, 2011
#     Version 28 Full and Abbreviated Code Titles - Effective October 1, 2010
#     Version 27 Full and Abbreviated Code Titles - Effective October 1, 2009
#     Version 27 Abbreviated Code Titles -   Effective October 1, 2009
#     Version 26 Effective October 1, 2008
#     Version 25 Effective October 1, 2007
#     Version 24 Effective October 1, 2006
#     Version 23 Effective October 1, 2005
#
# output:  cms.rds (data.frame with columns: code (ICD-9 compact code),
#          long_desc, short_desc, fiscal_year, dxpr
#
# deps:    data.table, readxl
#
# idempotent: yes (unzip to tempdir())
#
################################################################################

################################################################################
# helper functions
read_cms_zip <- function(zip_path, dx_file, pr_file, fy) {
  #' @param zip_path character string, file path to source zip file
  #' @param dx_file,pr_file character string, the name of the diagnosis file and
  #'   procedure files to read from within the zip file
  #' @param fy: integer the fiscal year
  #'
  #' @return a data.table with columns (if they exist):
  #'   * code  (character) compact ICD-9 code
  #'   * long_desc (character) long description of the code
  #'   * short_desc (character) short description of the code
  #'   * fiscal_year (integer)
  #'   * dxpr  (character): "dx" or "pr"

  stopifnot(length(fy) == 1 && is.integer(fy))
  stopifnot(length(zip_path) == 1 && is.character(zip_path))
  stopifnot(length(dx_file) == 1 && is.character(dx_file))
  stopifnot(length(pr_file) == 1 && is.character(pr_file))

  # unzip to a temporary directory
  tmpd <- file.path(tempdir(), paste0("cms_", as.character(fy)))
  utils::unzip(zipfile = zip_path, exdir = tmpd)

  dx <- file.path(tmpd, dx_file)
  pr <- file.path(tmpd, pr_file)
  stopifnot(file.exists(dx), file.exists(pr))

  if (endsWith(dx, "xls")) {
    dx <- readxl::read_xls(dx)
  } else if (endsWith(dx, "xlsx")) {
    dx <- readxl::read_xlsx(dx)
  } else if (endsWith(dx, "txt")) {
    dx <- scan(dx, what = "character", sep = "\n", quiet = TRUE)
  } else {
    stop(sprintf("unknown file type: %s", dx))
  }

  if (endsWith(pr, "xls")) {
    pr <- readxl::read_xls(pr)
  } else if (endsWith(pr, "xlsx")) {
    pr <- readxl::read_xlsx(pr)
  } else if (endsWith(pr, "txt")) {
    pr <- scan(pr, what = "character", sep = "\n", quiet = TRUE)
  } else {
    stop(sprintf("unknown file type: %s", pr))
  }

  if (inherits(dx, "data.frame")) {
    dx <- data.table::as.data.table(dx)
    data.table::setnames(
      dx,
      old = grep("^DIAGNOSIS CODE$", names(dx), value = TRUE),
      new = "code"
    )
  } else {
    dx <- data.table::data.table(
      code = trimws(substr(dx, start = 1, stop = 6)),
      "SHORT DESCRIPTION" = trimws(substr(dx, start = 7, stop = 32))
    )
  }

  if (inherits(pr, "data.frame")) {
    pr <- data.table::as.data.table(pr)
    data.table::setnames(
      pr,
      old = grep("^PROCEDURE CODE$", names(pr), value = TRUE),
      new = "code"
    )
  } else {
    pr <- data.table::data.table(
      code = trimws(substr(pr, start = 1, stop = 5)),
      "SHORT DESCRIPTION" = trimws(substr(pr, start = 6, stop = 32)))
  }

  # standardize desc columns if present under slightly different names
  lx <- grep("(?i)^long",  names(dx), value = TRUE)
  sx <- grep("(?i)^short", names(dx), value = TRUE)
  lp <- grep("(?i)^long",  names(pr), value = TRUE)
  sp <- grep("(?i)^short", names(pr), value = TRUE)

  stopifnot("code" %in% names(dx), "code" %in% names(pr))

  if (length(lx)) {
    dx[, `:=`(long_desc = get(lx[1]))]
  }
  if (length(lp)) {
    pr[, `:=`(long_desc = get(lp[1]))]
  }

  dx[, `:=`(short_desc = get(sx[1]))]
  pr[, `:=`(short_desc = get(sp[1]))]

  dx[, `:=`(fiscal_year = fy, dxpr = "dx")]
  pr[, `:=`(fiscal_year = fy, dxpr = "pr")]

  rtn <- data.table::rbindlist(list(dx = dx, pr = pr))
  keep <- c("code", "long_desc", "short_desc", "fiscal_year", "dxpr")
  keep <- keep[keep %in% names(rtn)]
  rtn[, .SD, .SDcols = keep]
}

################################################################################
# define the files and inputs

plan <- data.table::fread(text =
"
zip_path           | dx_file                                    | pr_file                              | fy
cms/cms_v32.zip    | CMS32_DESC_LONG_SHORT_DX.xlsx              | CMS32_DESC_LONG_SHORT_SG.xlsx        | 2015
cms/cms_v31.zip    | CMS31_DESC_LONG_SHORT_DX.xlsx              | CMS31_DESC_LONG_SHORT_SG.xlsx        | 2014
cms/cms_v30.zip    | CMS30_DESC_LONG_SHORT_DX 080612.xlsx       | CMS30_DESC_LONG_SHORT_SG 051812.xlsx | 2013
cms/cms_v29.zip    | CMS29_DESC_LONG_SHORT_DX 101111u021012.xls | CMS29_DESC_LONG_SHORT_SG.xls         | 2012
cms/cms_v28.zip    | CMS28_DESC_LONG_SHORT_DX.xls               | CMS28_DESC_LONG_SHORT_SG.xls         | 2011
cms/cms_fy2010.zip | V27LONG_SHORT_DX_110909u021012.xls         | CMS27_DESC_LONG_SHORT_SG_092709.xls  | 2010
cms/cms_v26.zip    | V26 I-9 Diagnosis.txt                      | V26  I-9 Procedures.txt              | 2009
cms/cms_v25.zip    | I9diagnosesV25.txt                         | I9proceduresV25.txt                  | 2008
cms/cms_v24.zip    | I9diagnosis.txt                            | I9surgery.txt                        | 2007
cms/cms_v23.zip    | I9DX_DESC.txt                              | I9SG_DESC.txt                        | 2006
")

cms <-
  lapply(
    seq_len(nrow(plan)),
    function(i) {
      do.call(read_cms_zip, as.list(plan[i]))
    }
  )

cms <- data.table::rbindlist(cms, use.names = TRUE, fill = TRUE)
cms <- unique(cms[nzchar(code)][order(dxpr, fiscal_year, code)])

################################################################################
# CMS data does not have the header codes; add them.
cms[
  dxpr == "dx",
  `:=`(
    d3 = data.table::fcase(
      grepl("^\\d", code)  & nchar(code) >= 3, substr(code, 1, 3),
      grepl("^V\\d", code) & nchar(code) >= 3, substr(code, 1, 3)
    ),
    d4 = data.table::fcase(
      grepl("^\\d", code)  & nchar(code) >= 4, substr(code, 1, 4),
      grepl("^V\\d", code) & nchar(code) >= 4, substr(code, 1, 4),
      grepl("^E\\d", code) & nchar(code) >= 4, substr(code, 1, 4)
    ),
    d5 = data.table::fcase(
      grepl("^\\d", code)  & nchar(code) >= 5, substr(code, 1, 5),
      grepl("^V\\d", code) & nchar(code) >= 5, substr(code, 1, 5),
      grepl("^E\\d", code) & nchar(code) >= 5, substr(code, 1, 5)
    )
  )
]

cms[dxpr == "pr", d2 := data.table::fifelse(nchar(code) >= 2, substr(code, 1, 2), NA_character_)]
cms[dxpr == "pr", d3 := data.table::fifelse(nchar(code) >= 3, substr(code, 1, 3), NA_character_)]
cms[dxpr == "pr", d4 := data.table::fifelse(nchar(code) >= 4, substr(code, 1, 4), NA_character_)]

with_headers <- list()

for(x in c("d2", "d3", "d4", "d5")) {
  idx <- !is.na(cms[[x]])
  with_headers[[x]] <-
    data.table::data.table(
      code = cms[[x]],
      fiscal_year = cms[["fiscal_year"]],
      short_desc = data.table::fifelse(cms[["code"]] == cms[[x]], cms[["short_desc"]], NA_character_),
      long_desc  = data.table::fifelse(cms[["code"]] == cms[[x]], cms[["long_desc"]],  NA_character_),
      dxpr = cms[["dxpr"]]
    )[idx]
  with_headers[[x]] <- unique(with_headers[[x]])
}

cms <- data.table::rbindlist(with_headers, use.names = TRUE, fill = TRUE)
data.table::setorder(cms, dxpr, fiscal_year, code)

################################################################################
# sanity checks
stopifnot(!anyNA(cms[["code"]]), all(nzchar(cms[["code"]])))

################################################################################
# save
data.table::setDF(cms)
saveRDS(file = "cms.rds", object = cms)

################################################################################
#                                 End of File                                  #
################################################################################
