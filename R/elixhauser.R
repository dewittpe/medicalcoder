#' Internal Implementation of the Elixhauser comorbidities
#' medicalcoder
#'
#' Internal.  Called from [`comorbidities()`].  Not expected to be called from
#' any other context.
#'
#' @param id.vars Character vector of ID column names.
#' @param iddf A `data.frame` of unique IDs
#' @param cmrb A `data.frame` containing at least `id.vars` and
#' `condition` columns; i.e., the 'comorbidity' `data.frame`.
#' @param poa.var Character denoting the name of the column in the `cmrb`
#' `data.frame` denoting if the condition was identified by an ICD code that
#' was or was not present on admission.
#' @param primarydx.var Character (scalar) with the name of the column in
#' `cmrb` denoting if the condition was flaged as a primary diagnostic or not.
#' @param method Character scalar; name of the Charlson variant to assess
#'
#' @return A `data.frame` with `id.vars`, per-condition 0/1
#' indicators, `num_cmrb`, `cmrb_flag`, and `cci`.
#'
#' @family internal comorbidity functions
#' @noRd
#' @keywords internal
.elixhauser <- function(id.vars, iddf, cmrb, poa.var, primarydx.var, method) {
  ccc <- mdcr_select(cmrb, cols = c(id.vars, "condition", "poaexempt", poa.var, primarydx.var))
  ccc <- unique(ccc)

  # omit primary dx
  idx <- ccc[[primarydx.var]] == 0L
  ccc <- mdcr_subset(ccc, i = idx)

  # omit the rows for conditions requiring POA when POA = 0
  # Conditions flagged as POA-required are only kept when the source
  # code was present on admission; everything else remains eligible
  # regardless of POA status.
  idx <- Vectorize(isTRUE)(..mdcr_internal_elixhauser_poa..[[method]] == 1 & ..mdcr_internal_elixhauser_poa..[["poa_required"]] == 1L)
  if (length(idx)) {
    poa <- mdcr_subset(..mdcr_internal_elixhauser_poa.., i = idx)

    idx <- ( (ccc[["condition"]] %in% poa[["condition"]]) & (ccc[[poa.var]] == 1L | ccc[["poaexempt"]] == 1)) |
           (!(ccc[["condition"]] %in% poa[["condition"]]))

    ccc <- mdcr_subset(ccc, i = idx)
  }

  # what are the relevent coniditions
  conditions <-
    unique(..mdcr_internal_elixhauser_codes..[["condition"]][which(..mdcr_internal_elixhauser_codes..[[method]] == 1L)])

  # build indicator matrix
  X <- matrix(0L, nrow = nrow(iddf), ncol = length(conditions))
  colnames(X) <- conditions

  key_iddf <- do.call(paste, c(iddf, sep = "\r"))
  key_ccc  <- do.call(paste, c(mdcr_select(ccc, id.vars), sep = "\r"))
  ri <- match(key_ccc, key_iddf)
  ci <- match(ccc[["condition"]], conditions)
  keep <- !(is.na(ri) | is.na(ci))
  if (any(keep)) {
    X[cbind(ri[keep], ci[keep])] <- 1L
  }

  if (startsWith(x = method, prefix = "elixhauser_ahrq20") | startsWith(x = method, prefix = "elixhauser_ahrq_icd10")) {

    X[X[, "DRUG_ABUSEPSYCHOSES"] == 1L,  "DRUG_ABUSE"] <- 1
    X[X[, "HFHTN_CX"] == 1L,             "HTN_CX"]     <- 1
    X[X[, "HTN_CXRENLFL_SEV"] == 1L,     "HTN_CX"]     <- 1
    X[X[, "HFHTN_CXRENLFL_SEV"] == 1L,   "HTN_CX"]     <- 1
    X[X[, "ALCOHOLLIVER_MLD"] == 1L,     "ALCOHOL"]    <- 1
    X[X[, "VALVE_AUTOIMMUNE"] == 1L,     "AUTOIMMUNE"] <- 1         

    X[X[, "DRUG_ABUSEPSYCHOSES"] == 1L,  "PSYCHOSES"]  <- 1
    X[X[, "HFHTN_CX"] == 1L,             "HF"]         <- 1
    X[X[, "HTN_CXRENLFL_SEV"] == 1L,     "RENLFL_SEV"] <- 1
    X[X[, "HFHTN_CXRENLFL_SEV"] == 1L,   "HF"]         <- 1
    X[X[, "HFHTN_CXRENLFL_SEV"] == 1L,   "RENLFL_SEV"] <- 1

    idx <- which(X[, "CBVD_SQLAPARALYSIS"] == 1L)
    X[idx, "PARALYSIS"] <- 1
    X[idx, "CBVD_SQLA"] <- 1

    X[X[, "ALCOHOLLIVER_MLD"] == 1L,     "LIVER_MLD"] <- 1
    X[X[, "VALVE_AUTOIMMUNE"] == 1L,     "VALVE"]     <- 1
    #X[X[, "CBVD_POA"] == 1L,             "CBVD_NPOA"] <- 1

    # exlcusions
    X[X[, "DIAB_CX"] == 1, "DIAB_UNCX"] <- 0L
    X[X[, "HTN_CX"] == 1, "HTN_UNCX"] <- 0L
    mets <- which(X[, "CANCER_METS"] == 1L)
    X[mets, "CANCER_SOLID"] <- 0L
    X[mets, "CANCER_NSITU"] <- 0L
    X[X[, "CANCER_SOLID"] == 1, "CANCER_NSITU"] <- 0L
    X[X[, "LIVER_SEV"] == 1, "LIVER_MLD"] <- 0L
    X[X[, "RENLFL_SEV"] == 1, "RENLFL_MOD"] <- 0L

    idx <- which(
      (X[, "CBVD_POA"] == 1L) |
      #(X[, "CBVD_POA"] == 0L & X[, "CBVD_NPOA"] == 0L & X[, "CBVD_SQLA"] == 1L)
      (X[, "CBVD_SQLA"] == 1L)
    )
    X <- cbind(X, "CBVD" = 0L)
    X[idx, "CBVD"] <- 1L
  } else {
    X <- cbind(X, "HTN_C" = 0L)
    X[X[, "HTN_UNCX"] == 1L | X[, "HTN_CX"] == 1L, "HTN_C"] <- 1L
    X[X[, "DMCX"] == 1, "DM"] <- 0L
  }


  mortality_weights <-
    stats::setNames(
      ..mdcr_internal_elixhauser_index_scores..[[method]],
      ..mdcr_internal_elixhauser_index_scores..[["condition"]]
    )[..mdcr_internal_elixhauser_index_scores..[["index"]] == "mortality"]

  readmission_weights <-
    stats::setNames(
      ..mdcr_internal_elixhauser_index_scores..[[method]],
      ..mdcr_internal_elixhauser_index_scores..[["condition"]]
    )[..mdcr_internal_elixhauser_index_scores..[["index"]] == "readmission"]

  mortality_weights <- mortality_weights[!is.na(mortality_weights)]
  readmission_weights <- readmission_weights[!is.na(readmission_weights)]

  # Set counts, flags, and index scores
  storage.mode(X) <- "integer"
  num_cmrb <- as.integer(rowSums(X[, names(mortality_weights)]))
  cmrb_flag <- as.integer(num_cmrb > 0L)
  mortality_index <- as.integer(as.vector(X[, names(mortality_weights)] %*% mortality_weights))
  readmission_index <- as.integer(as.vector(X[, names(readmission_weights)] %*% readmission_weights))

  # build the return object
  rtn <- cbind(iddf, as.data.frame(X, check.names = FALSE))
  rtn <- mdcr_set(rtn, j = "num_cmrb", value = num_cmrb)
  rtn <- mdcr_set(rtn, j = "cmrb_flag", value = cmrb_flag)
  rtn <- mdcr_set(rtn, j = "mortality_index", value = mortality_index)
  rtn <- mdcr_set(rtn, j = "readmission_index", value = readmission_index)
  rownames(rtn) <- NULL
  rtn

}

################################################################################
#                                 End of File                                  #
################################################################################
