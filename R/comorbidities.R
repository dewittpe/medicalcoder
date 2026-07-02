#' Comorbidities
#'
#' Apply established comorbidity algorithms to ICD-coded data. Supported
#' methods include several variants of the Charlson comorbidity system,
#' Elixhauser, and the Pediatric Complex Chronic Conditions (PCCC).
#'
#' @template params-comorbidities
#'
#' @details
#' When `flag.method = "current"`, only codes from the index encounter
#' contribute to flags. The experimental `flag.method = "cumulative"` option
#' lets prior encounters for the same `id.vars` combination contribute to
#' condition flags. For the experimental cumulative method to work, `id.vars`
#' needs to be a character vector of length 2 or more. The last element is
#' treated as the encounter identifier and must be sortable. For example, say
#' you have data with a hospital, patient, and encounter id. The `id.vars` could
#' be one of two entries: `c("hospital", "patient", "encounter")` or
#' `c("patient", "hospital", "encounter")`. In both cases the return will be the
#' same because the encounter identifier is unchanged regardless of whether
#' hospital or patient is listed first.
#'
#' It is critically important that the `data[[tail(id.vars, 1)]]` variable can
#' be sorted.  Just because your data is sorted in temporal order does not mean
#' that the results will be correct if the `tail(id.vars, 1)` is not in the same
#' order as the data.  For example, say you had the following:
#'
#' | patid | enc_id   | date     |
#' |:---:  |:---:     | :---:    |
#' | P1    | 10823090 | Aug 2023 |
#' | P1    | 10725138 | Jul 2025 |
#'
#' `id.vars = c("patid", "enc_id")` will give the wrong result as enc_id
#' 10725138 would be sorted to come before enc_id 10823090.  `id.vars =
#' c("patid", "date")` would be sufficient input, assuming that `date` has been
#' correctly stored. Adding a column `enc_seq`, e.g.,
#'
#' | patid | enc_id   | date     | enc_seq |
#' |:---:  |:---:     | :---:    | :---:   |
#' | P1    | 10823090 | Aug 2023 | 1       |
#' | P1    | 10725138 | Jul 2025 | 2       |
#'
#' and calling `comorbidities()` with `id.vars = c("patid", "enc_seq")` will
#' have better performance than using the date and will clear up any possible
#' issues with non-sequential encounter ids from the source data.
#'
#' For `flag.method = "cumulative"`, the encounter order column must not contain
#' missing values, must not be a factor, and must be numeric, character, `Date`,
#' or `POSIXt`. Character encounter order columns are allowed, but they are
#' sorted lexicographically; use an integer sequence, `Date`, or `POSIXt` column
#' when possible.
#'
#' **Experimental cumulative + POA defaults:**
#'
#' When `flag.method = "cumulative"` and neither
#' `poa` nor `poa.var` is supplied, the first encounter for a condition is
#' treated as `poa = 0`. Subsequent encounters for that condition are flagged as
#' `poa = 1`.
#'
#' When `flag.method = "current"` and neither `poa` nor `poa.var` is supplied,
#' then all codes will be considered present-on-admission.  If poa was assumed
#' to be 0, then in this case the only conditions that could be flagged are the
#' Elixhauser conditions which are poa-exempt.
#'
#' The `mapping` option controls how ICD codes are mapped to conditions. The
#' default, `mapping = "precomputed"`, uses a precomputed table that links
#' valid ICD codes to comorbidity conditions. Those links are built from the ICD
#' code sources included with medicalcoder: the United States Centers for
#' Disease Control and Prevention (CDC), the Centers for Medicare and Medicaid
#' Services (CMS), the World Health Organization (WHO), the Independent
#' Health and Aged Care Pricing Authority (IHACPA) ICD-10 Australian
#' Modification (ICD-10-AM) data, and Socialstyrelsen ICD-10-SE data.
#'
#' `mapping = "precomputed"` is generally fastest and is the behavior used by
#' medicalcoder before the `mapping` argument was added. `mapping = "regex"`
#' applies the method's regular expressions directly to the input ICD codes.
#' Regex mapping is currently implemented for Charlson methods and is useful
#' when codes come from an ICD modification that may not be completely covered
#' by the precomputed code-condition links, or when auditing a method.
#'
#' @return
#'
#' The return object will be slightly different depending on the value of
#' `method` and `subconditions`.
#'
#' * When `subconditions = FALSE`, a `medicalcoder_comorbidities` object (a
#'   `data.frame` with attributes) is returned.  Column(s) for `id.vars`, if
#'   defined in the function call.  For all methods there will be the following
#'   columns:
#'   * `num_cmrb` a count of comorbidities/conditions flagged
#'   * `cmrb_flag` a 0/1 integer indicator for at least one
#'   comorbidity/condition.
#'
#'   Additional columns:
#'
#'   * PCCC methods:
#'     * For `method = "pccc_v2.0"` and `method = "pccc_v2.1"`, there is one
#'     indicator column per condition.
#'
#'     * For `method = "pccc_v3.0"` and `method = "pccc_v3.1"`,
#'       there are four columns per condition:
#'       * `<condition>_dxpr_or_tech`: the condition was flagged due to the
#'         presence of either a diagnostic or procedure code, or was flagged due to
#'         the presence of a technology dependence code along with at least one
#'         comorbidity being flagged by a diagnostic or procedure code.
#'       * `<condition>_dxpr_only`: the condition was flagged due to the
#'         presence of a non-technology dependent diagnostic or procedure code
#'         only.
#'       * `<condition>_tech_only`: the condition was flagged due to the
#'         presence of a technology dependent code only and at least one other
#'         comorbidity was flagged by a non-technology dependent code.
#'       * `<condition>_dxpr_and_tech`: The patient had both diagnostic or
#'         procedure codes and a technology dependence code for the condition.
#'
#'   * For Charlson variants, indicator columns are returned for the relevant
#'     conditions, `cci` (Charlson Comorbidity Index), and `age_score`.
#'
#'   * For Elixhauser variants, indicator columns are returned for all relevant
#'     comorbidities, mortality, and readmission indices.
#'
#' * When `subconditions = TRUE` and the method is a PCCC variant,
#'   a list of length two is returned: the first element contains condition
#'   indicators; the second element is a named list of `data.frame`s with
#'   indicators for subconditions within each condition.
#'
#' @references
#'
#' * Pediatric Complex Chronic Conditions:
#'
#'   * Feudtner, C., Feinstein, J.A., Zhong, W. et al. Pediatric complex
#'     chronic conditions classification system version 2: updated for ICD-10
#'     and complex medical technology dependence and transplantation. BMC
#'     Pediatr 14, 199 (2014). https://doi.org/10.1186/1471-2431-14-199
#'
#'   * Feinstein JA, Hall M, Davidson A, Feudtner C. Pediatric Complex Chronic
#'     Condition System Version 3. JAMA Netw Open. 2024;7(7):e2420579.
#'     https://doi.org/10.1001/jamanetworkopen.2024.20579
#'
#' * Charlson Comorbidities:
#'
#'   * Mary E. Charlson, Peter Pompei, Kathy L. Ales, C.Ronald
#'       MacKenzie, A new method of classifying prognostic comorbidity in
#'       longitudinal studies: Development and validation, Journal of Chronic
#'       Diseases, Volume 40, Issue 5, 1987, Pages 373-383, ISSN 0021-9681,
#'       https://doi.org/10.1016/0021-9681(87)90171-8.
#'   * Deyo RA, Cherkin DC, Ciol MA. Adapting a clinical comorbidity index
#'       for use with ICD-9-CM administrative databases. J Clin Epidemiol. 1992
#'       Jun;45(6):613-9. https://doi.org/10.1016/0895-4356(92)90133-8. PMID: 1607900.
#'   * Sundararajan V, Henderson T, Perry C, Muggivan A, Quan H, Ghali WA.
#'       New ICD-10 version of the Charlson comorbidity index predicted
#'       in-hospital mortality. J Clin Epidemiol. 2004 Dec;57(12):1288-94.
#'       https://doi.org/10.1016/j.jclinepi.2004.03.012. PMID: 15617955.
#'   * Quan H, Sundararajan V, Halfon P, Fong A, Burnand B, Luthi JC,
#'       Saunders LD, Beck CA, Feasby TE, Ghali WA. Coding algorithms for defining
#'       comorbidities in ICD-9-CM and ICD-10 administrative data. Med Care. 2005
#'       Nov;43(11):1130-9. https://doi.org/10.1097/01.mlr.0000182534.19832.83. PMID:
#'       16224307.
#'   * Quan H, Li B, Couris CM, Fushimi K, Graham P, Hider P, Januel JM,
#'       Sundararajan V. Updating and validating the Charlson comorbidity index
#'       and score for risk adjustment in hospital discharge abstracts using
#'       data from 6 countries. Am J Epidemiol. 2011 Mar 15;173(6):676-82.
#'       https://doi.org/10.1093/aje/kwq433. Epub 2011 Feb 17. PMID: 21330339.
#'   * Glasheen WP, Cordier T, Gumpina R, Haugh G, Davis J, Renda A.
#'       Charlson Comorbidity Index: ICD-9 Update and ICD-10 Translation. Am Health
#'       Drug Benefits. 2019 Jun-Jul;12(4):188-197. PMID: 31428236; PMCID:
#'       PMC6684052.
#'   * Ludvigsson JF, Appelros P, Askling J, et al. Adaptation of the Charlson
#'       Comorbidity Index for Register-Based Research in Sweden. Clin Epidemiol.
#'       2021;13:21-41. https://doi.org/10.2147/CLEP.S282475.
#'   * Ludvigsson JF, Appelros P, Askling J, et al. Adaptation of the Charlson
#'       Comorbidity Index for Register-Based Research in Sweden \[Corrigendum\].
#'       Clin Epidemiol. 2023;15:753-754. https://doi.org/10.2147/CLEP.S420607.
#'
#' * Elixhauser Comorbidities:
#'
#'   * Agency for Healthcare Research and Quality (AHRQ). Elixhauser
#'     Comorbidity Software Refined for ICD-10-CM Diagnoses, v2026.1 \[Internet\].
#'     2026. Available from:
#'     https://www.hcup-us.ahrq.gov/toolssoftware/comorbidityicd10/comorbidity_icd10.jsp
#'
#' @seealso
#' * `vignettes(topic = "comorbidities", package = "medicalcoder")`
#' * `vignettes(topic = "pccc", package = "medicalcoder")`
#' * `vignettes(topic = "charlson", package = "medicalcoder")`
#' * `vignettes(topic = "elixhauser", package = "medicalcoder")`
#'
#' @example examples/comorbidities.R
#'
#' @export
comorbidities <- function(data,
                          icd.codes,
                          method,
                          id.vars = NULL,
                          icdv.var = NULL, icdv = NULL,
                          dx.var = NULL, dx = NULL,
                          poa.var = NULL,  poa = NULL,
                          age.var = NULL,
                          primarydx.var = NULL, primarydx = NULL,
                          flag.method = c("current", "cumulative"),
                          full.codes = TRUE,
                          compact.codes = TRUE,
                          subconditions = FALSE,
                          mapping = c("precomputed", "regex")
                          ) {
  UseMethod("comorbidities")
}

#' @export
comorbidities.data.frame <- function(data,
                                     icd.codes,
                                     method,
                                     id.vars = NULL,
                                     icdv.var = NULL, icdv = NULL,
                                     dx.var = NULL, dx = NULL,
                                     poa.var = NULL,  poa = NULL,
                                     age.var = NULL,
                                     primarydx.var = NULL, primarydx = NULL,
                                     flag.method = c("current", "cumulative"),
                                     full.codes = TRUE,
                                     compact.codes = TRUE,
                                     subconditions = FALSE,
                                     mapping = c("precomputed", "regex")
                                     ) {

  ##############################################################################
  # verify input arguments
  assert_scalar_logical(full.codes)
  assert_scalar_logical(compact.codes)
  stopifnot(full.codes | compact.codes)

  method <-
    match.arg(
      method,
      choices = comorbidities_methods(),
      several.ok = FALSE
    )

  mapping <- match.arg(arg = mapping, choices = c("precomputed", "regex"), several.ok = FALSE)

  assert_column(icd.codes, names(data))

  if (!is.null(id.vars)) {
    for (x in id.vars) {
      assert_column(x, names(data))
    }
    pn <- which(id.vars %in% ..protected_names..)
    if (length(pn)) {
      stop(sprintf("The value(s) \"%s\" in 'id.vars' are protected name(s).  It is ill-advised to use a protected name as medicalcoder is expecting to use them internally to apply the comorbidity algorithms.  Sorry for the inconvenience, but you will need to rename the column(s) in your data set.  Protected names that you should not use for 'id.vars' are: %s.",
        paste(id.vars[pn], collapse = ", "),
        paste(..protected_names.., collapse = ", ")
        )
      )
    }
  }

  if (!is.null(poa.var)) {
    assert_column(poa.var, names(data))
    if (!is.numeric(data[[poa.var]])) {
      stop(sprintf("Column '%s' must be numeric (0/1/NA) when supplied as poa.var.", poa.var), call. = FALSE)
    }
    pn <- poa.var %in% ..protected_names..
    if (pn) {
      stop(
        sprintf("The value \"%s\" in 'poa.var' is a protected name.  It is ill-advised to use a protected name as medicalcoder is expecting to use them internally to apply the comorbidity algorithms.  Sorry for the inconvenience, but you will need to rename the column in your data set.  Protected names that you should not use for 'poa.var' are: %s.",
          poa.var,
          paste(..protected_names.., collapse = ", ")
        )
      )
    }
  }

  if ((startsWith(method, "elixhauser") | startsWith(method, "charlson")) & !is.null(primarydx.var)) {
    assert_column(primarydx.var, names(data))
    if (!is.numeric(data[[primarydx.var]])) {
      stop(sprintf("Column '%s' must be numeric (0/1/NA) when supplied as primarydx.var.", primarydx.var), call. = FALSE)
    }
    pn <- primarydx.var %in% ..protected_names..
    if (pn) {
      stop(
        sprintf("The value \"%s\" in 'primarydx.var' is a protected name.  It is ill-advised to use a protected name as medicalcoder is expecting to use them internally to apply the comorbidity algorithms.  Sorry for the inconvenience, but you will need to rename the column in your data set.  Protected names that you should not use for 'primarydx.var' are: %s.",
          primarydx.var,
          paste(..protected_names.., collapse = ", ")
        )
      )
    }
  } else if (startsWith(method, "pccc") & (!is.null(primarydx.var) | !is.null(primarydx))) {
    warning(sprintf("primarydx.var and primarydx are ignored when method = '%s'", method), call. = FALSE)
    primarydx.var <- primarydx <- NULL
  }

  flag.method <- match.arg(flag.method, choices = c("current", "cumulative"), several.ok = FALSE)

  if (startsWith(method, "charlson") && !is.null(age.var)) {
    assert_column(age.var, names(data))
  }

  assert_scalar_logical(subconditions)
  if (subconditions & !startsWith(method, "pccc")) {
    warning("subconditions only implemented for PCCC", call. = FALSE)
    subconditions <- FALSE
  }

  # Cumulative flagging carries a condition forward from its first encounter.
  # Identify the earliest encounter per condition (and subcondition for PCCC),
  # replicate that flag across later encounters for the same id.vars stack, and
  # flip poa to 1L after the first occurrence so downstream methods treat the
  # condition as persistent.
  if (flag.method == "cumulative" & length(id.vars) < 2L) {
    stop("When using `flag.method = 'cumulative'` the `id.vars` are expected to be provided and have a minimum length of 2, e.g., c('subject_id', 'encounter_number')", call. = FALSE)
  }

  if (flag.method == "cumulative") {
    encid <- id.vars[length(id.vars)]
    enc <- data[[encid]]

    if (any(is.na(enc))) {
      stop(
        sprintf(
          "When using `flag.method = 'cumulative'`, the encounter order column '%s' must not contain missing values.",
          encid
        ),
        call. = FALSE
      )
    }

    if (is.factor(enc)) {
      stop(
        sprintf(
          "When using `flag.method = 'cumulative'`, the encounter order column '%s' must not be a factor. Use an integer sequence, Date, POSIXt, or character column with the intended sort order.",
          encid
        ),
        call. = FALSE
      )
    }

    if (!(is.numeric(enc) || is.character(enc) || inherits(enc, "Date") || inherits(enc, "POSIXt"))) {
      stop(
        sprintf(
          "When using `flag.method = 'cumulative'`, the encounter order column '%s' must be numeric, character, Date, or POSIXt.",
          encid
        ),
        call. = FALSE
      )
    }

    if (is.character(enc)) {
      warning(
        sprintf(
          "When using `flag.method = 'cumulative'`, the encounter order column '%s' is character and will be sorted lexicographically. Use an integer sequence, Date, or POSIXt column when possible.",
          encid
        ),
        call. = FALSE
      )
    }
  }

  # Check if icdv.var and/or icdv have been specified and check for expected
  # values.  if icdv is specified and icdv.var is NULL then then the icdv will
  # be used to subset the lookup table of ICD codes and conditions by method
  if (!is.null(icdv.var)) {
    if (!is.null(icdv)) {
      warning("'icdv.var' and 'icdv' were both specified; ignoring 'icdv'", call. = FALSE)
      icdv <- NULL
    } else {
      assert_column(icdv.var, names(data))
      if (!is.numeric(data[[icdv.var]])) {
        stop(sprintf("Column '%s' must be numeric (9/10/NA) when supplied as icdv.var.", icdv.var), call. = FALSE)
      }
    }
  } else {
    if (!is.null(icdv)) {
      stopifnot(inherits(icdv, "numeric") | inherits(icdv, "integer"))
      stopifnot(length(icdv) == 1L)
      icdv <- as.integer(icdv)
      stopifnot(icdv %in% c(9L, 10L))
    } else {
      # both icdv.var and icdv are NULL
      # do nothing
    }
  }

  # Check is dx.var and/or dx have been specified.  If dx has been specified and
  # dx.var is NULL, then the value of dx will be used to subset the lookup
  # table.
  if (!is.null(dx.var)) {
    if (!is.null(dx)) {
      warning("'dx.var' and 'dx' were both specified; ignoring 'dx'", call. = FALSE)
      dx <- NULL
    } else{
      assert_column(dx.var, names(data))
      if (!is.numeric(data[[dx.var]])) {
        stop(sprintf("Column '%s' must be numeric (0/1/NA) when supplied as dx.var.", dx.var), call. = FALSE)
      }
    }
  } else {
    if (!is.null(dx)) {
      stopifnot(inherits(dx, "numeric") | inherits(dx, "integer"))
      stopifnot(length(dx) == 1L)
      dx <- as.integer(dx)
      stopifnot(dx %in% c(0L, 1L))
    } else {
      # both dx.var and dx are NULL
      # do nothing
    }
  }

  ##############################################################################
  # Determine how to join the data and the look up table
  # the by_y will be prepended by full_code or code in the merge calls that
  # follow so here that part of the by_y character vector is not defined.
  by_x <- icd.codes
  by_y <- character(0)
  if (!is.null(icdv.var)) {
    by_x <- c(by_x, icdv.var)
    by_y <- c(by_y, "icdv")
  }
  if (!is.null(dx.var)) {
    by_x <- c(by_x, dx.var)
    by_y <- c(by_y, "dx")
  }

  data_for_lookup <-
    mdcr_select(
      data,
      cols = unique(c(icd.codes, id.vars, icdv.var, dx.var, poa.var, primarydx.var))
    )
  empty_data_for_lookup <- mdcr_subset(data_for_lookup, i = integer(0))

  ##############################################################################
  # Determine the lookup table and the columns for the lookup table to keep
  lookup_to_keep <- c("condition")
  if (startsWith(method, "pccc")) {
    if (mapping == "precomputed") {
      lookup <- get(x = "pccc_codes", envir = ..mdcr_data_env.., inherits = FALSE)
    } else {
      stop('mapping = "regex" for PCCC methods has not yet been implemented', call. = FALSE)
      #lookup <- ..mdcr_internal_pccc_regex..
    }
    lookup_to_keep <- c(lookup_to_keep, "subcondition", "transplant_flag", "tech_dep_flag")
  } else if (startsWith(method, "charlson")) {
    if (mapping == "precomputed") {
      lookup <- get("charlson_codes", envir = ..mdcr_data_env.., inherits = FALSE)
    } else {
      if (method == "charlson_beyrer2021") {
        stop("method = 'charlson_beyrer2021' does not have a regex variant.  Exact ICD codes only to be consistent with the publication.", call. = FALSE)
      }
      lookup <- ..mdcr_internal_charlson_regex..
    }
    lookup_to_keep <- c(lookup_to_keep)
  } else if (startsWith(method, "elixhauser")) {
    if (mapping == "precomputed") {
      lookup <- get("elixhauser_codes", envir = ..mdcr_data_env.., inherits = FALSE)
    } else {
      stop('mapping = "regex" for Elixhauser methods has not yet been implemented', call. = FALSE)
      # lookup <- ..mdcr_internal_elixhauser_regex..
    }
    lookup_to_keep <- c(lookup_to_keep, "poaexempt")
  }

  idx <- lookup[[method]] == 1L

  if (!is.null(dx)) {
    idx <- idx & (lookup[["dx"]] == dx)
  }

  if (!is.null(icdv)) {
    idx <- idx & (lookup[["icdv"]] == icdv)
  }

  lookup <- mdcr_subset(lookup, i = idx)

  ##############################################################################
  # inner join the data with the lookup table
  if (mapping == "precomputed") {
    on_full <-
      mdcr_inner_join(
        x = if (full.codes) {data_for_lookup} else {empty_data_for_lookup},
        y = lookup,
        by.x = by_x,
        by.y = c("full_code", by_y),
        suffixes = c("", ".y")
      )

    on_comp <-
      mdcr_inner_join(
        x = if (compact.codes) {data_for_lookup} else {empty_data_for_lookup},
        y = lookup,
        by.x = by_x,
        by.y = c("code", by_y),
        suffixes = c("", ".y")
      )
  } else {
    # use the names on_comp and on_full
    # As of v0.8.1, the only mapping between icd codes and conditions was done
    # by precomputed link tables of ICD codes and conditions.
    # An extension to use regex is being built, and at least for the initial,
    # "get it done" reuse these names here.  Let on_comp be empty and on_full be
    # based on the regex matching.
    on_comp <-
      mdcr_inner_join(
        x = empty_data_for_lookup,
        y = lookup,
        by.x = by_x[-1],
        by.y = by_y,
        suffixes = c("", ".y")
      )

    if (is.null(dx.var) & is.null(icdv.var)) {
      unique_codes <- mdcr_unique(data_for_lookup, by = icd.codes)
      on_full <- map_by_regex(unique_codes, lookup, icd.codes, by_x, by_y)
    } else if (!is.null(dx.var) & is.null(icdv.var)) {
      unique_codes <- mdcr_unique(data_for_lookup, by = c(icd.codes, dx.var))
      unique_codes <- split(x = unique_codes, f = unique_codes[[dx.var]])
      m0 <- map_by_regex(
        unique_codes[["0"]],
        mdcr_subset(lookup, lookup[["dx"]] == 0L),
        icd.codes,
        by_x,
        by_y
      )
      m1 <- map_by_regex(
        unique_codes[["1"]],
        mdcr_subset(lookup, lookup[["dx"]] == 1L),
        icd.codes,
        by_x,
        by_y
      )
      on_full <- rbind(m0, m1)
    } else if (is.null(dx.var) & !is.null(icdv.var)) {
      unique_codes <- mdcr_unique(data_for_lookup, by = c(icd.codes, icdv.var))
      unique_codes <- split(x = unique_codes, f = unique_codes[[icdv.var]])
      m9 <- map_by_regex(
        unique_codes[["9"]],
        mdcr_subset(lookup, lookup[["icdv"]] == 9L),
        icd.codes,
        by_x,
        by_y
      )
      m10 <- map_by_regex(
        unique_codes[["10"]],
        mdcr_subset(lookup, lookup[["icdv"]] == 10L),
        icd.codes,
        by_x,
        by_y
      )
      on_full <- rbind(m9, m10)
    } else if (!is.null(dx.var) & !is.null(icdv.var)) {
      unique_codes <- mdcr_unique(data_for_lookup, by = c(icd.codes, icdv.var, dx.var))
      unique_codes <- split(x = unique_codes, f = unique_codes[c(icdv.var, dx.var)])
      m9.0 <- map_by_regex(
        uc = unique_codes[["9.0"]],
        ptrns = mdcr_subset(lookup, lookup[["icdv"]] == 9L & lookup[["dx"]] == 0L),
        icd.codes,
        by_x,
        by_y
      )
      m9.1 <- map_by_regex(
        uc = unique_codes[["9.1"]]
        ,
        ptrns = mdcr_subset(lookup, lookup[["icdv"]] == 9L & lookup[["dx"]] == 1L),
        icd.codes,
        by_x,
        by_y
      )
      m10.0 <- map_by_regex(
        unique_codes[["10.0"]],
        mdcr_subset(lookup, lookup[["icdv"]] == 10L & lookup[["dx"]] == 0L),
        icd.codes,
        by_x,
        by_y
      )
      m10.1 <- map_by_regex(
        uc = unique_codes[["10.1"]],
        ptrns = mdcr_subset(lookup, lookup[["icdv"]] == 10L & lookup[["dx"]] == 1L),
        icd.codes = icd.codes,
        by_x = by_x,
        by_y = by_y
      )
      on_full <- rbind(m9.0, m9.1, m10.0, m10.1)
    } else {
      # you should never get here
    }
    if (is.null(on_full)) {
      on_full <- on_comp[0, , drop = FALSE]
    }
    #on_full <-
    #  mdcr_inner_join(
    #    x = data,
    #    y = on_full,
    #    by.x = by_x,
    #    by.y = c("code", by_y)
    #  )
  }

  ##############################################################################
  # Now determine if the id.vars, poa.var, and primarydx.var need to be
  # constructed and added to the on_full and on_comp sets
  id.vars.created <- is.null(id.vars)

  build_name <- function(stem, names) {
    while(stem %in% names) {
      stem <- paste0(".", stem, ".")
    }
    stem
  }
  nms <- unique(c(names(on_full), names(on_comp)))

  if (id.vars.created) {
    id.vars <- build_name("..medicalcoder_id..", nms)
    on_full <- mdcr_set(on_full, j = id.vars, value = rep(1L, nrow(on_full)))
    on_comp <- mdcr_set(on_comp, j = id.vars, value = rep(1L, nrow(on_comp)))
  }

  if (is.null(poa.var) & is.null(poa)) {
    poa <- as.integer(flag.method == "current")
    warning(
      sprintf("'poa.var' and 'poa' are both NULL.  With flag.method = '%s' poa is set to %d.",
        flag.method, poa),
      call. = FALSE
    )
  }

  if (is.null(poa.var)) {
    stopifnot(inherits(poa, "numeric") | inherits(poa, "integer"))
    stopifnot(length(poa) == 1L)
    poa <- as.integer(poa)
    stopifnot(poa %in% c(0L, 1L))
    poa.var <- build_name("..medicalcoder_poa..", nms)
    on_full <- mdcr_set(on_full, j = poa.var, value = rep(poa, nrow(on_full)))
    on_comp <- mdcr_set(on_comp, j = poa.var, value = rep(poa, nrow(on_comp)))
  } else {
    if (!is.null(poa)) {
      warning("'poa.var' and 'poa' were both specified; ignoring 'poa'", call. = FALSE)
    }
    assert_column(poa.var, nms)
  }

  if (startsWith(method, "elixhauser") | startsWith(method, "charlson")) {
    if (is.null(primarydx.var)) {
      if (!is.null(primarydx)) {
        stopifnot(inherits(primarydx, "numeric") | inherits(primarydx, "integer"))
        stopifnot(length(primarydx) == 1L)
        primarydx <- as.integer(primarydx)
        stopifnot(primarydx %in% c(0L, 1L))
      } else {
        warning("Assuming all codes provided are secondary diagnostic codes.  Define `primarydx.var` or `primarydx` if this assumption is incorrect.", call. = FALSE)
        primarydx <- 0L
      }

      primarydx.var <- build_name("..medicalcoder_primarydx..", nms)

      on_full <- mdcr_set(on_full, j = primarydx.var, value = rep(primarydx, nrow(on_full)))
      on_comp <- mdcr_set(on_comp, j = primarydx.var, value = rep(primarydx, nrow(on_comp)))

    } else {
      if (!is.null(primarydx)) {
        warning("'primarydx.var' and 'primarydx' were both specified; ignoring 'primarydx'", call. = FALSE)
      }
      assert_column(primarydx.var, nms)
    }
  }

  cmrb <-
    rbind(
      mdcr_select(on_full, c(id.vars, poa.var, primarydx.var, method, lookup_to_keep)),
      mdcr_select(on_comp, c(id.vars, poa.var, primarydx.var, method, lookup_to_keep))
    )

  # Retain only meaningful rows. If a condition is reported more than once with
  # the same information except for poa, keep one row with poa = 1 when one is
  # available. Primary-diagnosis status is part of the grouping key, so rows
  # with primarydx = 0 and primarydx = 1 are retained separately and POA is
  # resolved independently within each status. Downstream Charlson and
  # Elixhauser processing removes primary-diagnosis rows. Consequently, when a
  # condition is represented by both primary and non-primary diagnoses, it is
  # flagged only when the non-primary row satisfies that method's POA rules.
  cmrb <- mdcr_setorder(cmrb, by = c(names(cmrb)[names(cmrb) != poa.var], poa.var))
  keep <- !mdcr_duplicated(cmrb, by = names(cmrb)[names(cmrb) != poa.var], fromLast = TRUE)
  cmrb <- mdcr_subset(cmrb, keep)

  ##############################################################################
  # create a data.frame with one unique row for the id.vars
  if (!id.vars.created) {
    iddf <- mdcr_unique(mdcr_select(data, cols = id.vars))
  } else {
    iddf <- mdcr_unique(mdcr_select(cmrb, cols = id.vars))
    if (nrow(iddf) == 0) {
      iddf <- stats::setNames(data.frame(1L, stringsAsFactors = FALSE), id.vars)
    }
  }

  iddf <- mdcr_setorder(iddf, id.vars)

  ##############################################################################
  # create additional rows in cmrb based on the flag.method
  #
  # only need the if statement for flag.method cumulative.  The match.arg call
  # above should make sure that only valid and expected arguments for
  # flag.method would get to this point in the code.
  #
  # Also, expected, and verified above, that there are at least two id.vars.
  if (flag.method == "cumulative" & nrow(cmrb) > 0L) {
    id.vars2 <- id.vars[-length(id.vars)]
    encid <- id.vars[length(id.vars)]

    # find the first occurance of each condition
    grps <- c(id.vars2, "condition")
    byconditions <- c("condition")
    if (startsWith(method, "pccc")) {
      grps <- c(grps, "subcondition")
      byconditions <- c(byconditions, "subcondition")
    }
    # identify first occurrence per id/condition then retain encounters on/after it
    tmp <- mdcr_select(cmrb, c(grps, encid))
    tmp <- mdcr_setorder(tmp, c(grps, encid))
    keep <- !mdcr_duplicated(tmp, by = grps)
    foc <- mdcr_subset(tmp, keep)

    # add the first occurrence on to the cmrb data.frame
    foc <-
      mdcr_left_join(
        x = cmrb,
        y = foc,
        by = c(id.vars2, encid, byconditions)
      )
    foc <- mdcr_setnames(foc, old = encid, new = "first_occurrance")

    iddf2 <-
      mdcr_inner_join(
        x = mdcr_unique(mdcr_select(iddf, id.vars)),
        y = mdcr_unique(mdcr_select(foc, id.vars2)),
        by = id.vars2)
    iddf2 <- mdcr_unique(iddf2)

    if (startsWith(method, "pccc")) {
      foc <- split(foc, f = mdcr_select(foc, c("condition", "subcondition")), drop = TRUE)
    } else {
      foc <- split(foc, f = mdcr_select(foc, c("condition")), drop = TRUE)
    }
    foc <- lapply(foc, mdcr_unique)


    foc <-
      lapply(foc,
             function(y) {
               rtn <- mdcr_left_join(x = iddf2, y = y, by = c(id.vars2))
               rtn <- mdcr_subset(rtn, i = !is.na(rtn[["condition"]]))
               i <- rtn[[encid]] >= rtn[["first_occurrance"]]
               mdcr_subset(rtn, i = i)
             })

    cmrb <- do.call(rbind, foc)

    # Carry condition forward after first occurrence: set poa to 1 and
    # primarydx to 0 on later encounters so downstream POA filtering keeps
    # all post-first-occurrence rows and the first-occurrence row only if poa =
    # 1 (via poa.var or poa) for the first-occurrence
    idx <- cmrb[[encid]] > cmrb[["first_occurrance"]]
    cmrb[[poa.var]][idx] <- 1L
    if (!is.null(primarydx.var)) {
      cmrb[[primarydx.var]][cmrb[[encid]] > cmrb[["first_occurrance"]]] <- 0L
    }
    cmrb <- mdcr_set(cmrb, j = "first_occurrance", value =  NULL)

    cmrb <- mdcr_unique(cmrb)
  }

  ##############################################################################
  # retain only the row for present on admission for pccc and charlson.
  # elixhauser conditions may or may not need poa, so do not subset in that
  # case.
  if (startsWith(method, "charlson") | startsWith(method, "pccc")) {
    cmrb <- mdcr_subset(cmrb, i = cmrb[[poa.var]] == 1L)
  }

  ##############################################################################
  # apply the needed method
  if (startsWith(method, "pccc_v2")) {
    ccc <- .pccc_v2(id.vars = id.vars, iddf = iddf, cmrb = cmrb, subconditions = subconditions)
  } else if (startsWith(method, "pccc_v3")) {
    ccc <- .pccc_v3(id.vars = id.vars, iddf = iddf, cmrb = cmrb, subconditions = subconditions)
  } else if (startsWith(method, "charlson")) {
    ccc <- .charlson(id.vars = id.vars, iddf = iddf, cmrb = cmrb, primarydx.var = primarydx.var, method = method)
    if (!is.null(age.var)) {
      if (id.vars.created) {
        ages <- mdcr_unique(mdcr_select(data, cols = c(age.var)))
        ages <- mdcr_set(ages, j = id.vars, value = rep(1L, nrow(ages)))
        warn_about_age <- nrow(ages) > 1
      } else {
        ages <- mdcr_unique(mdcr_select(data, cols = c(id.vars, age.var)))
        warn_about_age <- any(mdcr_duplicated(ages, by = id.vars))
      }

      if (warn_about_age) {
        if (id.vars.created) {
          msg <- "There is more than one unique value for age.  Since `id.vars = NULL` the expectation is there would be one unique age value.  The return will have more than one row, one for each unique age."
        } else {
          msg <- "There is at least one set of id.vars with more than one age value.  The expectation is that there is only one age value for each unique set of id.vars.  The return will have more than one row for each unique set of id.vars."
        }
        warning(msg, call. = FALSE)
      }

      ages[["age_score"]] <- as.integer(cut(ages[[age.var]], breaks = c(-Inf, 50, 60, 70, 80, Inf), right = TRUE)) - 1L
      ccc <- merge(ccc, mdcr_select(ages, cols = c(id.vars, "age_score")), all.x = TRUE, by = id.vars, sort = FALSE)
      nonmissing <- which(!is.na(ccc[["age_score"]]))
      ccc[["cci"]][nonmissing] <- ccc[["cci"]][nonmissing] + ccc[["age_score"]][nonmissing]

    } else {
      ccc[["age_score"]] <- rep(NA_integer_, nrow(ccc))
    }
  } else if (startsWith(method, "elixhauser")) {
    ccc <- .elixhauser(id.vars = id.vars, iddf = iddf, cmrb = cmrb, poa.var = poa.var, primarydx.var = primarydx.var, method = method)
  } else {
    stop(sprintf("method '%s' has not yet been implemented", method))
  }

  ##############################################################################
  # Remove the id.vars if it was created
  if (id.vars.created) {
    if (subconditions) {
      ccc[["conditions"]] <- mdcr_set(ccc[["conditions"]], j = id.vars, value = NULL)
        if (nrow(data) == 0) {
          ccc[["conditions"]] <- ccc[["conditions"]][0, ]
        }
      for (i in seq_along(ccc[["subconditions"]])) {
        ccc[["subconditions"]][[i]] <- mdcr_set(ccc[["subconditions"]][[i]], j = id.vars, value = NULL)
        if (nrow(data) == 0) {
          ccc[["subconditions"]][[i]] <- ccc[["subconditions"]][[i]][0, ]
        }
      }
    } else {
      ccc <- mdcr_set(ccc, j = id.vars, value = NULL)
      if (nrow(data) == 0) {
        ccc <- ccc[0, ]
      }
    }
  }

  ##############################################################################
  # set attributes and return
  attr(ccc, "method") <- method
  attr(ccc, "id.vars") <- id.vars
  attr(ccc, "flag.method") <- flag.method
  class(ccc) <- c("medicalcoder_comorbidities", class(ccc))

  if (subconditions) {
    class(ccc) <- c("medicalcoder_comorbidities_with_subconditions", class(ccc))
    rownames(ccc[["conditions"]]) <- NULL
    for (i in seq_along(ccc[["subconditions"]])) {
      rownames(ccc[["subconditions"]][[i]]) <- NULL
    }
  } else {
    rownames(ccc) <- NULL
  }

  ccc
}

#' @export
print.medicalcoder_comorbidities <- function(x, ...) {
  cat(sprintf("\nComorbidities via %s\n\n", attr(x, "method")))
  NextMethod(generic = "print", object = x, ...)
  invisible(x)
}

#' @export
print.medicalcoder_comorbidities_with_subconditions <- function(x, ...) {
  cat(sprintf("\nComorbidities and Subconditions via %s\n\n", attr(x, "method")))
  l1 <- utils::capture.output(utils::str(x, max.level = 1, give.attr = FALSE))
  l2 <- utils::capture.output(utils::str(x[["subconditions"]], max.level = 1, give.attr = FALSE))
  l2 <- sub("^\\s\\$", "  ..$", l2)
  cat(c(l1, l2[-1], "\n"), sep = "\n")
  invisible(x)
}

################################################################################
# Non-exported functions
#
comorbidities_methods <- function() {
    c("pccc_v2.0", "pccc_v2.1", "pccc_v3.0", "pccc_v3.1",
      "charlson_deyo1992", "charlson_quan2011", "charlson_quan2005",
      "charlson_cdmf2019", "charlson_sundararajan2004", "charlson_ludvigsson2021",
      "charlson_beyrer2021", "charlson_mimicivcode",
      "elixhauser_elixhauser1988", "elixhauser_ahrq_web", "elixhauser_quan2005",
      "elixhauser_ahrq2022", "elixhauser_ahrq2023", "elixhauser_ahrq2024",
      "elixhauser_ahrq2025", "elixhauser_ahrq2026", "elixhauser_ahrq_icd10")
}

# map_by_regex is used to...
# @param uc a data.frame with unique codes
# @param ptrns a data.frame with regex ptrns mapping to conditions
# @param icd.codes name of the column in uc with the ICD codes
# @param by_x,by_y the columns to join the uc and found conditions by
map_by_regex <- function(uc, ptrns, icd.codes, by_x, by_y) {
  if (is.null(uc) || nrow(uc) == 0L || is.null(ptrns) || nrow(ptrns) == 0L) {
    return(NULL)
  }
  mapped <- lapply(uc[[icd.codes]], function(x) {
    y <- sapply(ptrns[["pattern"]], grepl, x)
    if (length(y) > 0L) {
      which(y)
    } else {
      integer(0)
    }
  })
  mapped <- stats::setNames(mapped, uc[[icd.codes]])
  mapped <- Filter(length, mapped)
  mapped <-
    Map(
      f = function(nm, i) {
        rtn <- mdcr_subset(ptrns, i = i)
        rtn <- mdcr_set(rtn, j = "code_via_regex", value = nm)
        rtn
      },
      nm = names(mapped),
      i = mapped
    )
  mapped <- do.call(rbind, mapped)
  if (length(mapped) > 0L) {
    mdcr_inner_join(
      x = uc,
      y = mapped,
      by.x = by_x,
      by.y = c("code_via_regex", by_y)
    )
  }
}

# protected names... throw and error and tell end users that it is ill-advised
# to use these names for id.vars, poa.var, primarydx.var
# dput(unique( c( names(get_icd_codes()), names(get_pccc_codes()), names(get_elixhauser_codes()), names(get_charlson_codes()))))
..protected_names.. <-
  c("icdv", "dx", "full_code", "code", "src", "known_start", "known_end",
    "assignable_start", "assignable_end", "condition", "subcondition",
    "transplant_flag", "tech_dep_flag",
    "pccc_v3.1", "pccc_v3.0", "pccc_v2.1", "pccc_v2.0",
    "elixhauser_ahrq_web", "elixhauser_elixhauser1988", "elixhauser_quan2005",
    "elixhauser_ahrq2022", "elixhauser_ahrq2023", "elixhauser_ahrq2024", "elixhauser_ahrq2025", "elixhauser_ahrq2026",
    "elixhauser_ahrq_icd10",
    "charlson_cdmf2019", "charlson_deyo1992", "charlson_ludvigsson2021",
    "charlson_quan2005", "charlson_quan2011", "charlson_sundararajan2004"
  )
