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
  ccc <- mdcr_select(cmrb, cols = c(id.vars, "condition", poa.var, primarydx.var))
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

    idx <- ( (ccc[["condition"]] %in% poa[["condition"]]) & (ccc[[poa.var]] == 1L)) |
           (!(ccc[["condition"]] %in% poa[["condition"]]))

    ccc <- mdcr_subset(ccc, i = idx)
  }

  # what are the relevent coniditions
  conditions <-
    unique(..mdcr_internal_elixhauser_index_scores..[["condition"]][ which(!is.na(..mdcr_internal_elixhauser_index_scores..[[method]])) ])

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

  mortality_weights <-
    stats::setNames(
      ..mdcr_internal_elixhauser_index_scores..[[method]],
      ..mdcr_internal_elixhauser_index_scores..[["condition"]]
    )[..mdcr_internal_elixhauser_index_scores..[["index"]] == "mortality"][conditions]

  readmission_weights <-
    stats::setNames(
      ..mdcr_internal_elixhauser_index_scores..[[method]],
      ..mdcr_internal_elixhauser_index_scores..[["condition"]]
    )[..mdcr_internal_elixhauser_index_scores..[["index"]] == "readmission"][conditions]

  # Set counts, flags, and index scores
  storage.mode(X) <- "integer"
  num_cmrb <- as.integer(rowSums(X))
  cmrb_flag <- as.integer(num_cmrb > 0L)
  mortality_index <- as.integer(as.vector(X %*% mortality_weights))
  readmission_index <- as.integer(as.vector(X %*% readmission_weights))

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
