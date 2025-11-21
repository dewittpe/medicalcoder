#' Construct Charlson indicator data.frame and compute CCI
#'
#' Internal.  Called from [`comorbidities()`].  Not expected to be called from
#' any other context.
#'
#' @param id.vars Character vector of ID column names.
#' @param iddf A `data.frame` of unique IDs
#' @param cmrb A `data.frame` containing at least `id.vars` and
#' `condition` columns; i.e., the 'comorbidity' `data.frame`.
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
.charlson <- function(id.vars, iddf, cmrb, primarydx.var, method) {
  ccc <- unique(mdcr_select(cmrb, cols = c(id.vars, "condition", primarydx.var)))

  # omit primary dx
  idx <- which(ccc[[primarydx.var]] == 0L)
  ccc <- mdcr_subset(ccc, i = idx)

  # get the method weights and conditions
  conditions <- mdcr_subset(..mdcr_internal_charlson_index_scores..,
                            i = !is.na(..mdcr_internal_charlson_index_scores..[[method]]),
                            cols = c("condition", method))
  needed <- conditions[["condition"]]
  cci_wt <- stats::setNames(as.integer(conditions[[method]]), needed)

  # build indicator matrix
  X <- matrix(0L, nrow = nrow(iddf), ncol = length(needed))
  colnames(X) <- needed

  key_iddf <- do.call(paste, c(iddf, sep = "\r"))
  key_ccc  <- do.call(paste, c(mdcr_select(ccc, id.vars), sep = "\r"))
  ri <- match(key_ccc, key_iddf)
  ci <- match(ccc[["condition"]], needed)

  keep <- !(is.na(ri) | is.na(ci))
  if (any(keep)) {
    X[cbind(ri[keep], ci[keep])] <- 1L
  }

  # for charlson_cdmf2019 the aids category is 1 hiv and aids are flagged
  if (method == "charlson_cdmf2019") {
    X[, "aids"] <- as.integer(X[, "aids"] * X[, "hiv"])
  }

  # set less severe conditions to zero if the more severe condition is present
  X[X[, "msld"] == 1L, "mld"] <- 0L
  X[X[, "dmc"]  == 1L, "dm"]  <- 0L
  X[X[, "mst"]  == 1L, "mal"] <- 0L

  # num_cmrb, cmrb_flag, cci
  storage.mode(X) <- "integer"
  num_cmrb  <- as.integer(rowSums(X))
  cmrb_flag <- as.integer(num_cmrb > 0L)
  cci      <- as.integer(as.vector(X %*% cci_wt))

  # build the return object
  rtn <- cbind(iddf, as.data.frame(X, check.names = FALSE, stringsAsFactors = FALSE))
  rtn <- mdcr_set(rtn, j = "num_cmrb",  value = num_cmrb)
  rtn <- mdcr_set(rtn, j = "cmrb_flag", value = cmrb_flag)
  rtn <- mdcr_set(rtn, j = "cci",      value = cci)
  rownames(rtn) <- NULL
  rtn
}
