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

  if (startsWith(method, "elixhauser_ahrq20") | method == "elixhauser_ahrq_icd10") {
    results <- .elixhauser_post2022(ccc, id.vars, iddf, cmrb, poa.var, primarydx.var, method)
  } else {
    results <- .elixhauser_pre2022(ccc, id.vars, iddf, cmrb, poa.var, primarydx.var, method)
  }

  # build the return object
  rtn <- cbind(iddf, as.data.frame(results$X, check.names = FALSE, stringsAsFactors = FALSE))
  rtn <- mdcr_set(rtn, j = "num_cmrb", value = results$num_cmrb)
  rtn <- mdcr_set(rtn, j = "cmrb_flag", value = results$cmrb_flag)
  rtn <- mdcr_set(rtn, j = "mortality_index", value = results$mortality_index)
  rtn <- mdcr_set(rtn, j = "readmission_index", value = results$readmission_index)
  rownames(rtn) <- NULL
  rtn

}

.elixhauser_post2022 <- function(ccc, id.vars, iddf, cmrb, poa.var, primarydx.var, method) {

  conditions <- ..mdcr_internal_elixhauser_codes..[["condition"]][which(..mdcr_internal_elixhauser_codes..[[method]] == 1L)]
  conditions <- sort(unique(conditions))

  # need to consider how the conditions are flagged POA, POAEXEMPT, or ANYPOA.
  XPOA <- matrix(0L, nrow = nrow(iddf), ncol = length(conditions), dimnames = list(NULL, conditions))
  XNPOA <- XPOAEXEMPT <- XANYPOA <- XPOA

  POA       <- mdcr_subset(ccc, ccc[[poa.var]] == 1L)
  POAEXEMPT <- mdcr_subset(ccc, ccc[["poaexempt"]] == 1L)
  NPOA      <- mdcr_subset(ccc, ccc[["poaexempt"]] == 0L & ccc[[poa.var]] == 0L)
  # ANYPOA == ccc

  key_iddf      <- do.call(paste, c(iddf, sep = "\r"))
  key_poa       <- do.call(paste, c(mdcr_select(POA, id.vars), sep = "\r"))
  key_poaexempt <- do.call(paste, c(mdcr_select(POAEXEMPT, id.vars), sep = "\r"))
  key_npoa      <- do.call(paste, c(mdcr_select(NPOA, id.vars), sep = "\r"))
  key_anypoa    <- do.call(paste, c(mdcr_select(ccc, id.vars), sep = "\r"))

  ri <- match(key_poa, key_iddf)
  ci <- match(POA[["condition"]], conditions)
  keep <- !(is.na(ri) | is.na(ci))
  if (any(keep)) {
    XPOA[cbind(ri[keep], ci[keep])] <- 1L
  }

  ri <- match(key_poaexempt, key_iddf)
  ci <- match(POAEXEMPT[["condition"]], conditions)
  keep <- !(is.na(ri) | is.na(ci))
  if (any(keep)) {
    XPOAEXEMPT[cbind(ri[keep], ci[keep])] <- 1L
  }

  ri <- match(key_npoa, key_iddf)
  ci <- match(NPOA[["condition"]], conditions)
  keep <- !(is.na(ri) | is.na(ci))
  if (any(keep)) {
    XNPOA[cbind(ri[keep], ci[keep])] <- 1L
  }

  ri <- match(key_anypoa, key_iddf)
  ci <- match(ccc[["condition"]], conditions)
  keep <- !(is.na(ri) | is.na(ci))
  if (any(keep)) {
    XANYPOA[cbind(ri[keep], ci[keep])] <- 1L
  }

  # Assign comorbidities which are nutral to POA
  from_to <-
    c("DRUG_ABUSEPSYCHOSES" = "DRUG_ABUSE",
      "HFHTN_CX" = "HTN_CX",
      "HTN_CXRENLFL_SEV"= "HTN_CX",
      "HFHTN_CXRENLFL_SEV"= "HTN_CX",
      "ALCOHOLLIVER_MLD" = "ALCOHOL",
      "VALVE_AUTOIMMUNE" = "AUTOIMMUNE"
    )

  for (i in seq_len(length(from_to))) {
    f <- names(from_to)[i]
    t <- unname(from_to[i])
          XPOA[      XPOA[, f] == 1L, t] <- 1L
    XPOAEXEMPT[XPOAEXEMPT[, f] == 1L, t] <- 1L
       XANYPOA[   XANYPOA[, f] == 1L, t] <- 1L
         XNPOA[     XNPOA[, f] == 1L, t] <- 1L
  }

  # flag if poa expempt or POA
  from_to <-
    c("DRUG_ABUSEPSYCHOSES" = "PSYCHOSES",
      "HFHTN_CX" = "HF",
      "HTN_CXRENLFL_SEV"= "RENLFL_SEV",
      "HFHTN_CXRENLFL_SEV"= "HF",
      "HFHTN_CXRENLFL_SEV"= "RENLFL_SEV",
      "CBVD_SQLAPARALYSIS"= "PARALYSIS",
      "CBVD_SQLAPARALYSIS"= "CBVD_SQLA",
      "ALCOHOLLIVER_MLD"= "LIVER_MLD",
      "VALVE_AUTOIMMUNE"= "VALVE"
    )

  for (i in seq_len(length(from_to))) {
    f <- names(from_to)[i]
    t <- unname(from_to[i])
          XPOA[      XPOA[, f] == 1L, t] <- 1L
    XPOAEXEMPT[XPOAEXEMPT[, f] == 1L, t] <- 1L
  }

  # CBVD_NPOA is unique in that it requires that the condition is not POA
  XNPOA <- cbind(XNPOA, "CBVD_NPOA" = rep(0L, nrow(XNPOA)))
  XNPOA[XNPOA[, "CBVD_POA"] == 1L, "CBVD_NPOA"] <- 1L

  ##############################################################################
  # Build one matrix with the conditions
  apoaconditions <-
    ..mdcr_internal_elixhauser_poa..[["condition"]][
      ..mdcr_internal_elixhauser_poa..[[method]] == 1L &
      ..mdcr_internal_elixhauser_poa..[["poa_required"]] == 0L
    ]

  X <- (XPOA | XPOAEXEMPT)
  X[, apoaconditions] <- X[, apoaconditions] | XANYPOA[, apoaconditions]
  # CBVD clean up
  idx <-
    (X[, "CBVD_POA"]) |
    (!X[, "CBVD_POA"] & X[, "CBVD_SQLA"] == 1L & XNPOA[, "CBVD_NPOA"] == 0L)
  X <- cbind(X, "CBVD" = rep(0L, nrow(X)))
  X[idx, "CBVD"] <- 1L

  storage.mode(X) <- "integer"

  ##############################################################################
  # exclusions for for less severe condiitons
  sev_less <-
    c("DIAB_CX" = "DIAB_UNCX",
      "HTN_CX" = "HTN_UNCX",
      "CANCER_METS" = "CANCER_SOLID",
      "CANCER_METS" = "CANCER_NSITU",
      "CANCER_SOLID"= "CANCER_NSITU",
      "LIVER_SEV" = "LIVER_MLD",
      "RENLFL_SEV" = "RENLFL_MOD"
    )
  for (i in seq_len(length(sev_less))) {
    s <- names(sev_less)[i]
    l <- unname(sev_less[i])
    X[X[, s] == 1L, l] <- 0L
  }

  ##############################################################################
  # index weights
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

  mortality_weights   <- mortality_weights[!is.na(mortality_weights)]
  readmission_weights <- readmission_weights[!is.na(readmission_weights)]

  # Set counts, flags, and index scores
  if (nrow(X)) {
    num_cmrb          <- as.integer(rowSums(X[, names(mortality_weights), drop = FALSE]))
    cmrb_flag         <- as.integer(num_cmrb > 0L)
    mortality_index   <- as.integer(as.vector(X[, names(mortality_weights), drop = FALSE] %*% mortality_weights))
    readmission_index <- as.integer(as.vector(X[, names(readmission_weights), drop = FALSE] %*% readmission_weights))
  } else {
    num_cmrb          <- integer(0)
    cmrb_flag         <- integer(0)
    mortality_index   <- integer(0)
    readmission_index <- integer(0)
  }

  list(X = X, num_cmrb = num_cmrb, cmrb_flag = cmrb_flag, mortality_index = mortality_index, readmission_index = readmission_index)
}

.elixhauser_pre2022 <- function(ccc, id.vars, iddf, cmrb, poa.var, primarydx.var, method) {

  # what are the relevent coniditions
  conditions <-
    unique(..mdcr_internal_elixhauser_codes..[["condition"]][which(..mdcr_internal_elixhauser_codes..[[method]] == 1L)])

  # build indicator matrix
  X <- matrix(0L, nrow = nrow(iddf), ncol = length(conditions) + 1L)
  colnames(X) <- c(conditions, "HTN_C")

  key_iddf <- do.call(paste, c(iddf, sep = "\r"))
  key_ccc  <- do.call(paste, c(mdcr_select(ccc, id.vars), sep = "\r"))
  ri <- match(key_ccc, key_iddf)
  ci <- match(ccc[["condition"]], conditions)
  keep <- !(is.na(ri) | is.na(ci))
  if (any(keep)) {
    X[cbind(ri[keep], ci[keep])] <- 1L
  }

  # severity corrections
  X[X[, "HTN_UNCX"] == 1L | X[, "HTN_CX"] == 1L, "HTN_C"] <- 1L
  X[X[, "HTN_CX"] == 1L, "HTN_UNCX"] <- 0L
  X[X[, "DMCX"] == 1, "DM"] <- 0L
  X[X[, "METS"] == 1, "TUMOR"] <- 0L

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
  if (nrow(X)) {
    num_cmrb          <- as.integer(rowSums(X[, names(mortality_weights), drop = FALSE]))
    cmrb_flag         <- as.integer(num_cmrb > 0L)
    mortality_index   <- as.integer(as.vector(X[, names(mortality_weights), drop = FALSE] %*% mortality_weights))
    readmission_index <- as.integer(as.vector(X[, names(readmission_weights), drop = FALSE] %*% readmission_weights))
  } else {
    num_cmrb          <- integer(0)
    cmrb_flag         <- integer(0)
    mortality_index   <- integer(0)
    readmission_index <- integer(0)
  }

  list(X = X, num_cmrb = num_cmrb, cmrb_flag = cmrb_flag, mortality_index = mortality_index, readmission_index = readmission_index)
}

################################################################################
#                                 End of File                                  #
################################################################################
