library(medicalcoder)
source("utilities.R")
################################################################################
# testing the internal data sets - both the internal sets and the user visible
# versions.

# The internal sets can to look for: this cannot be done dynamically
# e <- new.env()
# load("../R/sysdata.rda", envir = e)
# dput(sort(ls(all.names = TRUE, envir = e)))

internal_data_sets <-
  c(
    "..mdcr_internal_charlson_codes..",
    "..mdcr_internal_charlson_index_scores..",
    "..mdcr_internal_desc_start_stop..",
    "..mdcr_internal_elixhauser_codes..",
    "..mdcr_internal_elixhauser_index_scores..",
    "..mdcr_internal_elixhauser_poa..",
    "..mdcr_internal_icd_chapters..",
    "..mdcr_internal_icd_codes..",
    "..mdcr_internal_icd_descs..",
    "..mdcr_internal_icd_subchapters..",
    "..mdcr_internal_known_and_assignable_start_stop..",
    "..mdcr_internal_pccc_codes..",
    "..mdcr_internal_pccc_conditions.."
  )

mdcr <- getNamespace("medicalcoder")

# are all the expected sets in the medicalcoder namespace?
stopifnot(all(internal_data_sets %in% names(mdcr)))

# check that there are not unaccounted for data sets.  the ..mdcr_internal_
# prefix and .. suffix is expected.  noted in the data-raw/build_sysdata.R
stopifnot(
  all(
    grep("\\.\\.mdcr_internal_.+\\.\\.$", names(mdcr), value = TRUE) %in% internal_data_sets
  )
)

################################################################################
# verify all the sets are data.frames and only data.frames
t01 <-  all(sapply(sapply(internal_data_sets, get, envir = mdcr), inherits, "data.frame"))
t02 <- !any(sapply(sapply(internal_data_sets, get, envir = mdcr), inherits, "data.table"))
t03 <- !any(sapply(sapply(internal_data_sets, get, envir = mdcr), inherits, "tbl_df"))

stopifnot(t01, t02, t03)

################################################################################
# Verify the names and classes of the internal data sets
expected_internal_names_and_classes <-
  list(
    "..mdcr_internal_charlson_codes.." = c(code_id = "integer", condition = "character", charlson_cdmf2019 = "integer", charlson_deyo1992 = "integer", charlson_quan2005 = "integer", charlson_quan2011 = "integer"),
    "..mdcr_internal_charlson_index_scores.." = c(condition_description = "character", condition = "character", charlson_cdmf2019 = "integer", charlson_quan2011 = "integer", charlson_quan2005 = "integer", charlson_deyo1992 = "integer"),
    "..mdcr_internal_desc_start_stop.." = c(code_id = "integer", desc_id = "integer", src = "factor", desc_start = "integer", desc_end = "integer"),
    "..mdcr_internal_elixhauser_codes.." = c(code_id = "integer", poaexempt = "integer", condition = "character", elixhauser_ahrq_web = "integer", elixhauser_elixhauser1988 = "integer", elixhauser_quan2005 = "integer", elixhauser_ahrq2022 = "integer", elixhauser_ahrq2023 = "integer", elixhauser_ahrq2024 = "integer", elixhauser_ahrq2025 = "integer", elixhauser_ahrq2026 = "integer", elixhauser_ahrq_icd10 = "integer"),
    "..mdcr_internal_elixhauser_index_scores.." = c(condition = "character", index = "character", elixhauser_ahrq_web = "integer", elixhauser_elixhauser1988 = "integer", elixhauser_quan2005 = "integer", elixhauser_ahrq2022 = "integer", elixhauser_ahrq2023 = "integer", elixhauser_ahrq2024 = "integer", elixhauser_ahrq2025 = "integer", elixhauser_ahrq2026 = "integer", elixhauser_ahrq_icd10 = "integer"),
    "..mdcr_internal_elixhauser_poa.." = c(condition = "character", poa_required = "integer", elixhauser_ahrq2022 = "integer", elixhauser_ahrq2023 = "integer", elixhauser_ahrq2024 = "integer", elixhauser_ahrq2025 = "integer", elixhauser_ahrq2026 = "integer", elixhauser_ahrq_icd10 = "integer"),
    "..mdcr_internal_icd_chapters.." = c(chapter = "character", chap_id = "integer"),
    "..mdcr_internal_icd_codes.." = c(icdv = "integer", dx = "integer", full_code = "character", code = "character", code_id = "integer", chap_id = "integer", subchap_id = "integer"),
    "..mdcr_internal_icd_descs.." = c(desc = "character", desc_id = "integer"),
    "..mdcr_internal_icd_subchapters.." = c(subchapter = "character", subchap_id = "integer"),
    "..mdcr_internal_known_and_assignable_start_stop.." = c(code_id = "integer", src = "factor", known_start = "integer", known_end = "integer", assignable_start = "integer", assignable_end = "integer"),
    "..mdcr_internal_pccc_codes.." = c(code_id = "integer", condition = "character", subcondition = "character", transplant_flag = "integer", tech_dep_flag = "integer", pccc_v3.1 = "integer", pccc_v3.0 = "integer", pccc_v2.1 = "integer", pccc_v2.0 = "integer"),
    "..mdcr_internal_pccc_conditions.." = c(condition = "character", subcondition = "character", condition_label = "character", subcondition_label = "character")
  )

current_names_and_classes <- sapply(sapply(internal_data_sets, get, envir = mdcr), sapply, class)

stopifnot(identical(length(current_names_and_classes), length(expected_internal_names_and_classes)))

for(n in names(current_names_and_classes)) {
  z <- identical(current_names_and_classes[[n]], expected_internal_names_and_classes[[n]])
  if (!z) {
    stop(sprintf("user visible %s does not have the expected structure", n))
  }
}

################################################################################
# get the data sets via get_ methods

# expected methods
user_visible_get_methods <-
  c(
    "get_charlson_codes",
    "get_charlson_index_scores",
    "get_elixhauser_codes",
    "get_elixhauser_index_scores",
    "get_elixhauser_poa",
    "get_icd_codes",
    "get_pccc_codes",
    "get_pccc_conditions"
  )

# check that the expected methods are accounted for
stopifnot(all(user_visible_get_methods %in% names(mdcr)))
stopifnot(all(grep("get_.+", names(mdcr), value = TRUE) %in% user_visible_get_methods))

# all the get_* methods have zero arguments except for get_icd_codes
for (m in user_visible_get_methods) {
  f <- getExportedValue(name = m, ns = "medicalcoder")
  x <- formals(f)
  if (m != "get_icd_codes") {
    if (!is.null(x)) {
      stop(sprintf("Unexpected function argument in %s()", m))
    }
  } else {
    if (!identical(x, pairlist(with.descriptions = FALSE, with.hierarchy = FALSE))) {
      stop(sprintf("Unexpected function argument in %s()", m))
    }
  }
}

# get the datasets
user_visible <-
  list(
    charlson_codes = get_charlson_codes(),
    charlson_index_scores = get_charlson_index_scores(),
    elixhauser_codes = get_elixhauser_codes(),
    elixhauser_index_scores = get_elixhauser_index_scores(),
    elixhauser_poa = get_elixhauser_poa(),
    icd_codes = get_icd_codes(),
    icd_desc = get_icd_codes(with.descriptions = TRUE),
    icd_hier = get_icd_codes(with.hierarchy = TRUE),
    icd_dh   = get_icd_codes(with.descriptions = TRUE, with.hierarchy = TRUE),
    pccc_codes = get_pccc_codes(),
    pccc_conditions = get_pccc_conditions()
  )

# verify all the sets are data.frames and only data.frames
t04 <-  all(sapply(user_visible, inherits, "data.frame"))
t05 <- !any(sapply(user_visible, inherits, "data.table"))
t06 <- !any(sapply(user_visible, inherits, "tbl_df"))

stopifnot(t04, t05, t06)

# define the expected structure
user_visible_expected_structures <-
  list(
    charlson_codes = c(icdv = "integer", dx = "integer", full_code = "character", code = "character", condition = "character", charlson_cdmf2019 = "integer", charlson_deyo1992 = "integer", charlson_quan2005 = "integer", charlson_quan2011 = "integer"),
    charlson_index_scores = expected_internal_names_and_classes$..mdcr_internal_charlson_index_scores..,
    elixhauser_codes = c(icdv = "integer", dx = "integer", full_code = "character", code = "character", poaexempt = "integer", condition = "character", elixhauser_ahrq_web = "integer", elixhauser_elixhauser1988 = "integer", elixhauser_quan2005 = "integer", elixhauser_ahrq2022 = "integer", elixhauser_ahrq2023 = "integer", elixhauser_ahrq2024 = "integer", elixhauser_ahrq2025 = "integer", elixhauser_ahrq2026 = "integer", elixhauser_ahrq_icd10 = "integer"),
    elixhauser_index_scores = expected_internal_names_and_classes$..mdcr_internal_elixhauser_index_scores..,
    elixhauser_poa = expected_internal_names_and_classes$..mdcr_internal_elixhauser_poa..,
    icd_codes = c(icdv = "integer", dx = "integer", full_code = "character", code = "character", src = "character", known_start = "integer", known_end = "integer", assignable_start = "integer", assignable_end = "integer"),
    icd_desc = c(icdv = "integer", dx = "integer", full_code = "character", code = "character", src = "character", known_start = "integer", known_end = "integer", assignable_start = "integer", assignable_end = "integer", desc = "character", desc_start = "integer", desc_end = "integer"),
    icd_hier = c(icdv = "integer", dx = "integer", full_code = "character", code = "character", src = "character", known_start = "integer", known_end = "integer", assignable_start = "integer", assignable_end = "integer", chapter = "character", subchapter = "character", category = "character", subcategory = "character", subclassification = "character", subsubclassification = "character", extension = "character"),
    icd_dh = c(icdv = "integer", dx = "integer", full_code = "character", code = "character", src = "character", known_start = "integer", known_end = "integer", assignable_start = "integer", assignable_end = "integer", desc = "character", desc_start = "integer", desc_end = "integer", chapter = "character", subchapter = "character", category = "character", subcategory = "character", subclassification = "character", subsubclassification = "character", extension = "character"),
    pccc_codes = c(icdv = "integer", dx = "integer", full_code = "character", code = "character", condition = "character", subcondition = "character", transplant_flag = "integer", tech_dep_flag = "integer", pccc_v3.1 = "integer", pccc_v3.0 = "integer", pccc_v2.1 = "integer", pccc_v2.0 = "integer"),
    pccc_conditions = expected_internal_names_and_classes$..mdcr_internal_pccc_conditions..
  )

user_visible_current_structures <- lapply(user_visible, sapply, class)

for(n in names(user_visible_current_structures)) {
  z <- identical(user_visible_current_structures[[n]], user_visible_expected_structures[[n]])
  if (!z) {
    stop(sprintf("user visible %s does not have the expected structure", n))
  }
}

# check that the row names are just sequential integers
for (n in names(user_visible)) {
  expected <- as.character(seq_len(nrow(user_visible[[n]])))
  current  <- rownames(user_visible[[n]])
  if (!identical(expected, current)) {
    stop(sprintf("rownames(user_visible[[%s]]) are not sequential integers", n))
  }
}

################################################################################
# verify *_codes are all valid codes
for (n in grep("_codes$", names(user_visible), value = TRUE)) {
  z <- is_icd(x = user_visible[[n]][["code"]],
    icdv = user_visible[[n]][["icdv"]],
    dx   = user_visible[[n]][["dx"]],
    headerok = TRUE,
    ever.assignable = TRUE,
    warn.ambiguous = FALSE
  )
  if (!all(z)) {
    stop(sprintf("not all user_visible[['%s']][['code']] are valid ever.assignable ICD codes", n))
  }
  z <- is_icd(x = user_visible[[n]][["full_code"]],
    icdv = user_visible[[n]][["icdv"]],
    dx   = user_visible[[n]][["dx"]],
    headerok = TRUE,
    ever.assignable = TRUE,
    warn.ambiguous = FALSE
  )
  if (!all(z)) {
    stop(sprintf("not all user_visible[['%s']][['full_code']] are valid ever.assignable ICD codes", n))
  }
}
################################################################################
# PCCC specific checks
#
# * verify no more than two rows for a code by pccc variant
variants <- grep("^pccc_", names(user_visible[["pccc_codes"]]), value = TRUE)
ns <-
  stats::aggregate(
    x = user_visible[["pccc_codes"]][variants],
    by = user_visible[["pccc_codes"]][c("icdv", "dx", "code")],
    FUN = sum
  )
stopifnot(unlist(ns[variants]) %in% c(0L, 1L, 2L))

################################################################################
# ICD code specific checks

# assignable_start is NA then assignable_end should be NA
for (n in grep("^icd_", names(user_visible), value = TRUE)) {
  x <- is.na(user_visible[[n]][["assignable_start"]])
  y <- is.na(user_visible[[n]][["assignable_end"]])
  z <- identical(x, y)
  if (!z) {
    stop(sprintf("is.na status of assignable_start and assignable_end are not identical for %s", n))
  }
}

# verify that columns which are expected to be fully populated are
for (n in grep("^icd_", names(user_visible), value = TRUE)) {
  for (j in c("icdv", "dx", "full_code", "code", "known_start", "known_end", "src")) {
    z <- all(Negate(is.na)(user_visible[[n]][[j]]))
    if (!z) {
      stop(sprintf("user_visible[['%s']][['%s']] has missing values", n, j))
    }
  }
}

# Verify that the src column is as expected
for (n in grep("^icd_", names(user_visible), value = TRUE)) {
  stopifnot(
    identical(c("cdc", "cms", "who"), sort(unique(user_visible[[n]][["src"]])))
  )
}



################################################################################
#                                 End of File                                  #
################################################################################
