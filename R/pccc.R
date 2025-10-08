#' Internal Implementation of Pediatric Complex Chronic Conditions (PCCC) V2 and V3
#'
#' Internal.  Called from [`comorbidities()`].  Not expected to be called from
#' any other context.
#'
#' @param id.vars A character vector of the id variables
#'
#' @param iddf A `data.frame` with the unique `id.vars` columns from
#'   the `data` passed to [comorbidities()].
#'
#' @param cmrb A `data.frame` with the unique conditions and possible
#'   subconditions flagged by ICD in [comorbidities()].
#'
#' @param subconditions Logic scalar, if TRUE build subcondition results.
#'
#' @family internal comorbidity functions
#'
#' @noRd
#' @keywords internal
.pccc_v3 <- function(id.vars, iddf, cmrb, subconditions) {
  # The v3 schema tracks four mutually exclusive condition flags: codes flagged
  # by diagnostic/procedure codes only, tech-dependent codes only, the
  # intersection, and the union. Build the matrices separately so tech-only
  # signals can be handled after checking whether a non-tech condition was
  # flagged for the patient.
  any_transplant <- unique(mdcr_subset(x = cmrb, i = cmrb[["transplant_flag"]] == 1L, cols = c(id.vars)))

  # Build ccc indicators based on only non-tech_dep codes
  # _or_ a tech_dep transplant.  There are codes which are both tech_dep and
  # transplant.  since transplant is end stage organ failure these should be
  # flagged too.
  #
  # This will be done in two steps. Build on indicator matrix based on non-tech
  # codes and a second on based on tech and transplant codes.  We also build an
  # indicator matrix for tech related.
  dxpr_iddf <- mdcr_subset(cmrb, i = cmrb[["tech_dep_flag"]] == 0L, cols = id.vars)
  dxpr_cmrb <- mdcr_subset(cmrb, i = cmrb[["tech_dep_flag"]] == 0L, cols = c(id.vars, "condition"))

  techtrans_iddf <-
    mdcr_subset(cmrb,
                i = (cmrb[["tech_dep_flag"]] * cmrb[["transplant_flag"]] == 1L),
                cols = id.vars)

  techtrans_cmrb <-
    mdcr_subset(cmrb,
                i = (cmrb[["tech_dep_flag"]] * cmrb[["transplant_flag"]] == 1L),
                cols = c(id.vars, "condition"))

  tech_iddf <-
    mdcr_subset(cmrb,
                i = (cmrb[["tech_dep_flag"]] == 1L),
                cols = id.vars)

  tech_cmrb <-
    mdcr_subset(cmrb,
                i = (cmrb[["tech_dep_flag"]] == 1L),
                cols = c(id.vars, "condition"))

  conditions <- sort(unique(..mdcr_internal_pccc_conditions..[["condition"]]))

  # build indicator matrix for conditions
  dxpr_X      <- matrix(0L, nrow = nrow(iddf), ncol = length(conditions))
  techtrans_X <- matrix(0L, nrow = nrow(iddf), ncol = length(conditions))
  tech_X      <- matrix(0L, nrow = nrow(iddf), ncol = length(conditions))
  colnames(dxpr_X) <- colnames(techtrans_X) <- colnames(tech_X) <- conditions

  key_iddf      <- do.call(paste, c(iddf, sep = "\r"))
  key_dxpr      <- do.call(paste, c(dxpr_iddf, sep = "\r"))
  key_techtrans <- do.call(paste, c(techtrans_iddf, sep = "\r"))
  key_tech      <- do.call(paste, c(tech_iddf, sep = "\r"))

  ri <- match(key_dxpr, key_iddf)
  ci <- match(dxpr_cmrb[["condition"]], conditions)
  keep <- !(is.na(ri) | is.na(ci))
  if (any(keep)) {
    dxpr_X[cbind(ri[keep], ci[keep])] <- 1L
  }

  ri <- match(key_techtrans, key_iddf)
  ci <- match(techtrans_cmrb[["condition"]], conditions)
  keep <- !(is.na(ri) | is.na(ci))
  if (any(keep)) {
    techtrans_X[cbind(ri[keep], ci[keep])] <- 1L
  }

  ri <- match(key_tech, key_iddf)
  ci <- match(tech_cmrb[["condition"]], conditions)
  keep <- !(is.na(ri) | is.na(ci))
  if (any(keep)) {
    tech_X[cbind(ri[keep], ci[keep])] <- 1L
  }

  # create a dxpr_or_tech matrix
  dxpr_or_tech_X <- (dxpr_X | techtrans_X)

  # If at least one condition is flagged in dxpr_or_tech_X then the tech_X
  # indicator will remain as a 0 or 1.  If there is no condition flagged in
  # dxpr_or_tech_X, then the corresponding rows in tech_X are set to
  # NA_integer_.  For the moment, keep the 0/1 in the tech_X and use it to build
  # the updated dxpr_or_tech_X.
  non_tech_condition <- rowSums(dxpr_or_tech_X) > 0L
  tech_X[!non_tech_condition, ] <- 0L
  dxpr_or_tech_X <- (dxpr_or_tech_X | tech_X)
  storage.mode(dxpr_or_tech_X) <- "integer"

  tech_X <- (techtrans_X | tech_X)
  storage.mode(tech_X) <- "integer"
  any_tech_dep <- as.integer(rowSums(tech_X) > 0L)

  dxpr_and_tech_X <- (dxpr_X & tech_X)
  storage.mode(dxpr_and_tech_X) <- "integer"

  tech_X <- xor(tech_X, dxpr_and_tech_X)
  dxpr_X <- xor(dxpr_X, dxpr_and_tech_X)
  storage.mode(dxpr_X) <- "integer"
  storage.mode(tech_X) <- "integer"

  colnames(dxpr_X) <- paste0(colnames(dxpr_X), "_dxpr_only")
  colnames(tech_X) <- paste0(colnames(tech_X), "_tech_only")
  colnames(dxpr_or_tech_X) <- paste0(colnames(dxpr_or_tech_X), "_dxpr_or_tech")
  colnames(dxpr_and_tech_X) <- paste0(colnames(dxpr_and_tech_X), "_dxpr_and_tech")

  X <- cbind(dxpr_X, tech_X, dxpr_and_tech_X, dxpr_or_tech_X, any_tech_dep)
  X <- cbind(X, any_transplant = rep(0L, nrow(X)))
  X <- cbind(X, num_cmrb = rep(NA_integer_, nrow(X)))
  X <- cbind(X, cmrb_flag = rep(NA_integer_, nrow(X)))

  key_tran <- do.call(paste, c(any_transplant, sep = "\r"))
  X[match(key_tran, key_iddf), "any_transplant"] <- 1L

  X[, "num_cmrb"] <- as.integer(rowSums(dxpr_or_tech_X))
  X[, "cmrb_flag"] <- as.integer(X[, "num_cmrb"] > 0L)

  colorder <-
    c(
      paste0(rep(conditions, each = 4L),
             c("_dxpr_only", "_tech_only", "_dxpr_and_tech", "_dxpr_or_tech"))
      , "any_tech_dep", "any_transplant", "num_cmrb", "cmrb_flag")

  X <- X[, colorder, drop = FALSE]

  rtn <- cbind(iddf, as.data.frame(X, check.names = FALSE))

  if (subconditions) {
    rtn <- list(conditions = rtn, subconditions = list())
    for (cnd in conditions) {
      scnd <- unique(mdcr_subset(cmrb, i = cmrb[["condition"]] == cnd, cols = c(id.vars, "subcondition")))

      # subset the uiddf to the set of those with the condition
      uiddf <- mdcr_subset(rtn[["conditions"]],
                           i = rtn[["conditions"]][[paste0(cnd, "_dxpr_or_tech")]] == 1,
                           cols = id.vars)

      key_uiddf <- do.call(paste, c(uiddf, sep = "\r"))

      key_ciddf <- do.call(paste, c(mdcr_select(scnd, id.vars), sep = "\r"))
      ri <- match(key_ciddf, key_uiddf)

      scnds <- sort(unique(..mdcr_internal_pccc_conditions..[..mdcr_internal_pccc_conditions..[["condition"]] == cnd, "subcondition"]))
      ci <- match(scnd[["subcondition"]], scnds)
      X <- matrix(0L, nrow = nrow(uiddf), ncol = length(scnds))
      colnames(X) <- scnds

      keep <- !(is.na(ri) | is.na(ci))
      if (any(keep)) {
        X[cbind(ri[keep], ci[keep])] <- 1L
      }

      rtn[["subconditions"]][[cnd]] <- cbind(uiddf, as.data.frame(X, check.names = FALSE))
    }
  }

  rtn
}

#' @family internal comorbidity functions
#' @noRd
#' @keywords internal
.pccc_v2 <- function(id.vars, iddf, cmrb, subconditions) {
  any_tech_dep   <- unique(mdcr_subset(cmrb, i = cmrb[["tech_dep_flag"]] == 1L,   cols = c(id.vars)))
  any_transplant <- unique(mdcr_subset(cmrb, i = cmrb[["transplant_flag"]] == 1L, cols = c(id.vars)))

  CMRB <- mdcr_select(cmrb, cols = c(id.vars, "condition"))
  CMRB <- unique(CMRB)

  conditions <- sort(unique(..mdcr_internal_pccc_conditions..[["condition"]]))

  # build indicator matrix for conditions
  X <- matrix(0L, nrow = nrow(iddf), ncol = length(conditions))
  colnames(X) <- conditions

  key_iddf <- do.call(paste, c(iddf, sep = "\r"))
  key_CMRB <- do.call(paste, c(mdcr_select(CMRB, id.vars), sep = "\r"))
  key_tech <- do.call(paste, c(any_tech_dep, sep = "\r"))
  key_tran <- do.call(paste, c(any_transplant, sep = "\r"))
  ri <- match(key_CMRB, key_iddf)
  ci <- match(CMRB[["condition"]], conditions)
  keep <- !(is.na(ri) | is.na(ci))
  if (any(keep)) {
    X[cbind(ri[keep], ci[keep])] <- 1L
  }

  num_cmrb <- as.integer(rowSums(X))
  cmrb_flag <- as.integer(num_cmrb > 0L)

  X <- cbind(X, any_tech_dep = rep(0L, nrow(X)), any_transplant = rep(0L, nrow(X)))

  X[match(key_tech, key_iddf), "any_tech_dep"] <- 1L
  X[match(key_tran, key_iddf), "any_transplant"] <- 1L
  X <- cbind(X, num_cmrb, cmrb_flag)

  rtn <- cbind(iddf, as.data.frame(X, check.names = FALSE))

  if (subconditions) {
    rtn <- list(conditions = rtn, subconditions = list())
    for (cnd in conditions) {
      scnd <- unique(mdcr_subset(cmrb, i = cmrb[["condition"]] == cnd, cols = c(id.vars, "subcondition")))

      # subset the uiddf to the set of those with the condition
      uiddf <- mdcr_subset(rtn[["conditions"]],
                           i = rtn[["conditions"]][[cnd]] == 1,
                           cols = id.vars)
      key_uiddf <- do.call(paste, c(uiddf, sep = "\r"))

      key_ciddf <- do.call(paste, c(mdcr_select(scnd, id.vars), sep = "\r"))
      ri <- match(key_ciddf, key_uiddf)

      scnds <- sort(unique(..mdcr_internal_pccc_conditions..[..mdcr_internal_pccc_conditions..[["condition"]] == cnd, "subcondition"]))
      ci <- match(scnd[["subcondition"]], scnds)
      X <- matrix(0L, nrow = nrow(uiddf), ncol = length(scnds))
      colnames(X) <- scnds

      keep <- !(is.na(ri) | is.na(ci))
      if (any(keep)) {
        X[cbind(ri[keep], ci[keep])] <- 1L
      }

      rtn[["subconditions"]][[cnd]] <- cbind(uiddf, as.data.frame(X, check.names = FALSE))
    }
  }

  rtn
}
