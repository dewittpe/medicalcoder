..mdcr_data_env.. <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  # Build icd_codes
  idx <- match(..mdcr_internal_known_and_assignable_start_stop..$code_id,
               ..mdcr_internal_icd_codes..$code_id)
  cols <- c("icdv","dx","full_code","code","chap_id","subchap_id")
  icd_codes <- cbind(..mdcr_internal_known_and_assignable_start_stop..,
                     ..mdcr_internal_icd_codes..[idx, cols, drop = FALSE])
  icd_codes <- icd_codes[, c("code_id", cols, "src","known_start","known_end",
                           "assignable_start","assignable_end"), drop = FALSE]

  # build icd_codes_with_desc
  dkeys <- do.call(paste, c(..mdcr_internal_desc_start_stop..[c("code_id", "src")], sep = "\r"))
  ckeys <- do.call(paste, c(icd_codes[c("code_id", "src")], sep = "\r"))
  idx <- match(dkeys, unique(ckeys))

  icd_codes_with_desc <- cbind(..mdcr_internal_desc_start_stop..,
                               icd_codes[idx, setdiff(names(icd_codes), c("code_id", "src")), drop = FALSE])

  idx <- match(icd_codes_with_desc$desc_id, ..mdcr_internal_icd_descs..$desc_id)
  icd_codes_with_desc <- cbind(icd_codes_with_desc,
                               ..mdcr_internal_icd_descs..[idx, "desc", drop = FALSE])

  # place the icd_codes and icd_codes_with_desc in the cache
  icd_codes[["src"]] <- as.character(icd_codes[["src"]])
  icd_codes_with_desc[["src"]] <- as.character(icd_codes_with_desc[["src"]])

  rownames(icd_codes) <- NULL
  assign(x = "icd_codes", value = icd_codes, envir = ..mdcr_data_env..)
  lockBinding("icd_codes", env = ..mdcr_data_env..)

  rownames(icd_codes_with_desc) <- NULL
  assign(x = "icd_codes_with_desc", value = icd_codes_with_desc, envir = ..mdcr_data_env..)
  lockBinding("icd_codes_with_desc", env = ..mdcr_data_env..)

  # build the pccc codes and load into the cache
  ix <- match(..mdcr_internal_pccc_codes..$code_id, ..mdcr_internal_icd_codes..$code_id)
  pccc_codes <-
    cbind(..mdcr_internal_icd_codes..[ix, c("icdv", "dx", "full_code", "code"), drop = FALSE],
          ..mdcr_internal_pccc_codes..[, setdiff(names(..mdcr_internal_pccc_codes..), "code_id"), drop = FALSE])
  rownames(pccc_codes) <- NULL
  assign(x = "pccc_codes", value = pccc_codes, envir = ..mdcr_data_env..)
  lockBinding("pccc_codes", env = ..mdcr_data_env..)

  # build the charlson_codes and load into the cache
  ix <- match(..mdcr_internal_charlson_codes..$code_id, ..mdcr_internal_icd_codes..$code_id)
  charlson_codes <-
    cbind(..mdcr_internal_icd_codes..[ix, c("icdv", "dx", "full_code", "code"), drop = FALSE],
          ..mdcr_internal_charlson_codes..[, setdiff(names(..mdcr_internal_charlson_codes..), "code_id"), drop = FALSE])
  rownames(charlson_codes) <- NULL
  assign(x = "charlson_codes", value = charlson_codes, envir = ..mdcr_data_env..)
  lockBinding("charlson_codes", env = ..mdcr_data_env..)

  # build the elixhauser_codes and load into the cache
  ix <- match(..mdcr_internal_elixhauser_codes..$code_id, ..mdcr_internal_icd_codes..$code_id)
  elixhauser_codes <-
    cbind(..mdcr_internal_icd_codes..[ix, c("icdv", "dx", "full_code", "code"), drop = FALSE],
          ..mdcr_internal_elixhauser_codes..[, setdiff(names(..mdcr_internal_elixhauser_codes..), "code_id"), drop = FALSE])
  rownames(elixhauser_codes) <- NULL
  assign(x = "elixhauser_codes", value = elixhauser_codes, envir = ..mdcr_data_env..)
  lockBinding("elixhauser_codes", env = ..mdcr_data_env..)

  lockEnvironment(..mdcr_data_env.., bindings = TRUE)
}

