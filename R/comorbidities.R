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
#' contribute to flags. When a longitudinal method is selected (e.g.,
#' `"cumulative"`), prior encounters for the same `id.vars`
#' combination may contribute to condition flags. For the cumulative method to
#' work the `id.vars` need to be a character vector length 2 or more.  The last
#' variable listed in the id.vars will be considered the encounter id and should
#' be sortable. For example, say you have data with a hospital, patient, and
#' encounter id.  The `id.vars` could be one of two entries:  `c("hospital",
#' "patient", "encounter")` or `c("patient", "hospital", "encounter")`.  In both
#' cases the return with be the same as "encounter" within the hospital/patient
#' id interaction is the same as "encounter" within patient/hospital
#' interaction.
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
#' 10725138 would be sorted to come before enc_id 10823090.  `id.var =
#' c("patid", "date")` would be sufficient input, assuming that `date` has been
#' correctly stored.   Adding a column `enc_seq`, e.g.,
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
#' @return
#'
#' The return object will be slightly different depending on the value of
#' `method` and `subconditions`.
#'
#' * When `subconditions = FALSE`, a `medicalcoder_comorbidities` object (a
#'   `data.frame` with attributes) is returned.  Column(s) for `id.vars`, if
#'   defined in the function call.  For all method there will be the following
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
#'       * `<condition>_dxpr_or_tech`: the condition was flag due to the
#'         presence of either a diagnostic or procedure code, or was flag due to
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
#'     doi:10.1001/jamanetworkopen.2024.20579
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
#'       Jun;45(6):613-9. doi: 10.1016/0895-4356(92)90133-8. PMID: 1607900.
#'   * Quan H, Sundararajan V, Halfon P, Fong A, Burnand B, Luthi JC,
#'       Saunders LD, Beck CA, Feasby TE, Ghali WA. Coding algorithms for defining
#'       comorbidities in ICD-9-CM and ICD-10 administrative data. Med Care. 2005
#'       Nov;43(11):1130-9. doi: 10.1097/01.mlr.0000182534.19832.83. PMID:
#'       16224307.
#'   * Quan H, Li B, Couris CM, Fushimi K, Graham P, Hider P, Januel JM,
#'       Sundararajan V. Updating and validating the Charlson comorbidity index and
#'       score for risk adjustment in hospital discharge abstracts using data from 6
#'       countries. Am J Epidemiol. 2011 Mar 15;173(6):676-82. doi:
#'       10.1093/aje/kwq433. Epub 2011 Feb 17. PMID: 21330339.
#'   * Glasheen WP, Cordier T, Gumpina R, Haugh G, Davis J, Renda A.
#'       Charlson Comorbidity Index: ICD-9 Update and ICD-10 Translation. Am Health
#'       Drug Benefits. 2019 Jun-Jul;12(4):188-197. PMID: 31428236; PMCID:
#'       PMC6684052.
#'
#' * Elixhauser Comorbidities:
#'
#'   * Agency for Healthcare Research and Quality (AHRQ). Elixhauser
#'     Comorbidity Software Refined for ICD-10-CM Diagnoses, v2025.1 \[Internet\].
#'     2025. Available from:
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
                          subconditions = FALSE
                          ) {
  UseMethod("comorbidities")
}

#' @export
comorbidities.data.table <- function(data,
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
                          subconditions = FALSE
                          ) {
  NextMethod("comorbidities")
}

#' @export
comorbidities.tbl_df <- function(data,
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
                          subconditions = FALSE
                          ) {
  NextMethod("comorbidities")
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
                                     subconditions = FALSE) {

  ##############################################################################
  # verify input arguments
  stopifnot(isTRUEorFALSE(full.codes),
            isTRUEorFALSE(compact.codes),
            full.codes | compact.codes)

  flag.method <- match.arg(flag.method, several.ok = FALSE)

  # check that the variables are in data, if they are passed in.
  stopifnot(is.character(icd.codes) &&
            length(icd.codes) == 1L &&
            all(icd.codes %in% names(data)))

  id.vars.created <-
    check_and_set_id_vars(
      data_names = names(data),
      id.vars    = id.vars,
      envir      = environment()
    )

  # Check if icdv.var and/or icdv have been specified and check for expected
  # values.  if icdv is specified and icdv.var is NULL then then the icdv will
  # be used to subset the lookup table of ICD codes and conditions by method
  if (!is.null(icdv.var)) {
    if (!is.null(icdv)) {
      warning("'icdv.var' and 'icdv' were both specified; ignoring 'icdv'", call. = FALSE)
      icdv <- NULL
    } else {
      stopifnot(length(icdv.var) == 1L && is.character(icdv.var))
      stopifnot(icdv.var %in% names(data))
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
      stopifnot(length(dx.var) == 1L)
      stopifnot(dx.var %in% names(data))
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

  check_and_set_poa_var(
    data_names  = names(data),
    poa.var     = poa.var,
    poa         = poa,
    flag.method = flag.method,
    method      = method,
    envir       = environment()
  )

  check_and_set_primarydx_var(
    data_names    = names(data),
    primarydx.var = primarydx.var,
    primarydx     = primarydx,
    method        = method,
    envir         = environment()
  )

  # Check method
  method <- match.arg(method, choices = comorbidities_methods(), several.ok = FALSE)

  if (startsWith(method, "charlson") && !is.null(age.var)) {
    stopifnot(age.var %in% names(data))
  }

  stopifnot(isTRUEorFALSE(subconditions))
  if (subconditions & !grepl("pccc", method)) {
    warning("subconditions only implimented for PCCC")
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

  ##############################################################################
  # Gcols_to_keep <- c(id.vars, "condition",et the needed lookup table and set the cols to keep
  cols_to_keep <- c(id.vars, "condition", poa.var)
  if (grepl("^pccc", method)) {
    lookup <- get_pccc_codes()
    cols_to_keep <- c(cols_to_keep, "subcondition", "transplant_flag", "tech_dep_flag")
  } else if (grepl("^charlson", method)) {
    lookup <- get_charlson_codes()
  } else if (grepl("^elixhauser", method)) {
    lookup <- get_elixhauser_codes()
    cols_to_keep <- c(cols_to_keep, primarydx.var, method)
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
  if (full.codes) {
    on_full <-
      merge(
        x = data,
        y = lookup,
        all = FALSE,
        by.x = by_x,
        by.y = c("full_code", by_y),
        suffixes = c("", ".y"),
        sort = FALSE
      )
  }

  if (compact.codes) {
    on_comp <-
      merge(
        x = data,
        y = lookup,
        all = FALSE,
        by.x = by_x,
        by.y = c("code", by_y),
        suffixes = c("", ".y"),
        sort = FALSE
      )
  }

  if (full.codes & compact.codes) {
    cmrb <- rbind(mdcr_select(on_full, cols = cols_to_keep),
                  mdcr_select(on_comp, cols = cols_to_keep))
  } else if (!full.codes & compact.codes) {
    cmrb <- mdcr_subset(on_comp, cols = cols_to_keep)
  } else if (full.codes & !compact.codes) {
    cmrb <- mdcr_subset(on_full, cols = cols_to_keep)
  }

  # retain only meaningful rows, that is, unique rows.  If a condition is
  # reported more than once with the same information except for poa, then keep
  # a row for poa = 1 and omit the other poa = 1 row(s) and any poa = 0 row(s).
  cmrb <- mdcr_setorder(cmrb, by = c(names(cmrb)[names(cmrb) != poa.var], poa.var))
  keep <- !mdcr_duplicated(cmrb, by = names(cmrb)[names(cmrb) != poa.var], fromLast = TRUE)
  cmrb <- mdcr_subset(cmrb, keep)

  # create a data.frame with one unique row for the id.vars
  iddf <- unique(mdcr_select(data, cols = id.vars))
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
    tmp <- mdcr_select(cmrb, c(grps, encid))
    tmp <- mdcr_setorder(tmp, c(grps, encid))
    keep <- !mdcr_duplicated(tmp, by = grps)
    foc <- mdcr_subset(tmp, keep)
    foc <- mdcr_setnames(foc, old = encid, new = "first_occurrance")

    # merge on the poa.var
    foc <-
      merge(x = foc,
            y = cmrb,
            all = TRUE,
            by.x = c(id.vars2, "first_occurrance", byconditions),
            by.y = c(id.vars2, encid, byconditions),
            sort = FALSE
      )

    if (startsWith(method, "pccc")) {
      foc <- split(foc, f = mdcr_select(foc, c("condition", "subcondition")), drop = TRUE)
    } else {
      foc <- split(foc, f = mdcr_select(foc, c("condition")), drop = TRUE)
    }

    foc <- lapply(foc, unique)

    foc <-
      lapply(foc,
             function(y) {
               rtn <- merge(x = iddf, y = y, all.x = TRUE, by = c(id.vars2), allow.cartesian = TRUE, sort = FALSE)
               rtn <- mdcr_subset(rtn, i = !is.na(rtn$condition))
               i <- rtn[[encid]] >= rtn[["first_occurrance"]]
               mdcr_subset(rtn, i = i)
             })

    cmrb <- do.call(rbind, foc)

    cmrb[[poa.var]][cmrb[[encid]] > cmrb[["first_occurrance"]]] <- 1L
    cmrb <- mdcr_set(cmrb, j = "first_occurrance", value =  NULL)

    cmrb <- unique(cmrb)
  }

  # retain only the row for present on admission for pccc and charlson.
  # elixhauser conditions may or may not need poa, so do not subset in that
  # case.
  if (!startsWith(method, "elixhauser")) {
    cmrb <- mdcr_subset(cmrb, i = cmrb[[poa.var]] == 1L)
  }

  ##############################################################################
  # apply the needed method
  if (startsWith(method, "pccc_v2")) {
    ccc <- .pccc_v2(id.vars = id.vars, iddf = iddf, cmrb = cmrb, subconditions = subconditions)
  } else if (startsWith(method, "pccc_v3")) {
    ccc <- .pccc_v3(id.vars = id.vars, iddf = iddf, cmrb = cmrb, subconditions = subconditions)
  } else if (startsWith(method, "charlson")) {
    ccc <- .charlson(id.vars = id.vars, iddf = iddf, cmrb = cmrb, method)
    if (!is.null(age.var)) {
      ages <- unique(mdcr_select(data, cols = c(id.vars, age.var)))
      ages[["age_score"]] <- as.integer(cut(ages[[age.var]], breaks = c(-Inf, 50, 60, 70, 80, Inf), right = FALSE)) - 1L
      ccc <- merge(ccc, mdcr_select(ages, cols = c(id.vars, "age_score")), all.x = TRUE, by = id.vars, sort = FALSE)
      ccc[["cci"]] <- ccc[["cci"]] + ccc[["age_score"]]
    } else {
      ccc[["age_score"]] <- NA_integer_
    }
  } else if (startsWith(method, "elixhauser")) {
    ccc <- .elixhauser(id.vars = id.vars, iddf = iddf, cmrb = cmrb, poa.var = poa.var, primarydx.var = primarydx.var, method)
  } else {
    stop(sprintf("method '%s' has not yet been implemented", method))
  }

  ##############################################################################
  # Remove the id.vars if it was created
  if (id.vars.created) {
    if (subconditions) {
      ccc$conditions <- mdcr_set(ccc$conditions, j = id.vars, value = NULL)
      for (i in seq_along(ccc$subcondition)) {
        ccc$subconditions[[i]] <- mdcr_set(ccc$subconditions[[i]], j = id.vars, value = NULL)
      }
    } else {
      ccc <- mdcr_set(ccc, j = id.vars, value = NULL)
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
    rownames(ccc$conditions) <- NULL
    for (i in seq_along(ccc$subconditions)) {
      rownames(ccc$subconditions[[i]]) <- NULL
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
}

#' @export
print.medicalcoder_comorbidities_with_subconditions <- function(x, ...) {
  cat(sprintf("\nComorbidities and Subconditions via %s\n\n", attr(x, "method")))
  l1 <- utils::capture.output(utils::str(x, max.level = 1, give.attr = FALSE))
  l2 <- utils::capture.output(utils::str(x$subconditions, max.level = 1, give.attr = FALSE))
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
      "charlson_cdmf2019",
      "elixhauser_elixhauser1988", "elixhauser_ahrq_web", "elixhauser_quan2005",
      "elixhauser_ahrq2022", "elixhauser_ahrq2023", "elixhauser_ahrq2024",
      "elixhauser_ahrq2025")
}
