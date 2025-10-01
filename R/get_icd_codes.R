#' Get ICD Codes
#'
#' Retrieve a copy of the internal look up table for all known ICD codes.
#'
#' @details
#'
#' ## Sources
#' There are three sources of ICD codes.
#' * `cms`: Codes from the ICD-9-CM, ICD-9-PCS, ICD-10-CM, and ICD-10-PCS standards.
#' * `who`: Codes from World Health Organization.
#' * `cdc`: Codes from CDC Mortality coding standard.
#'
#' ## Fiscal and Calendar Years
#'
#' When reporting years there is a mix of fiscal and calendar years.
#'
#' Fiscal years are the United States Federal Government fiscal years, running
#' from October 1 to September 30. For example, fiscal year 2013 started October
#' 1 2012 and ended on September 30 2013.
#'
#' Calendar years run January 1 to December 31.
#'
#' Within the ICD data there are columns
#' `known_start`, `known_end`, `assignable_start`, `assignable_end`,
#' `desc_start` and `desc_end`.  For ICD codes with `src == "cms"`, these are
#' fiscal years.  For codes with `src == "cdc"` or `src == "who"` these are
#' calendar years.
#'
#' `known_start` is the first fiscal or calendar year (depending on source) that
#' the medicalcoder package as definitive source data for.  ICD-9-CM started in
#' the United States in fiscal year 1980.  Source information that could be
#' downloaded from the CDC and CMS and added to the source code for the
#' medicalcoder package goes back to 1997.  As such 1997 is the "known start"
#'
#' `known_end` is the last fiscal or calendar year (depending on source)
#' for which we have definitive source data for.  For ICD-9-CM and ICD-9-PCS
#' that is 2015.  For ICD-10-CM and ICD-10-PCS, which are active, it is just the
#' last year of known data.  ICD-10 from the WHO ends in 2019.
#'
#' ## Header and Assignable Codes
#'
#' "Assignable" indicates that the code is the most granular for the source.
#' Ideally codes are reported with the greatest level of detail but that is not
#' always the case.  Also, the greatest level of detail can differ between
#' sources.
#
#' Example: C86 is a header code for `cms` and `who` because codes C86.0, C86.1,
#' C86.2, C86.3, C86.4, C86.5, and C86.6 all exist in both standards.  No code
#' with a fifth digit exists in the `who` so all these four digit codes are
#' 'assignable.'  In the `cms` standard, C86.0 was assignable through fiscal
#' year 2024. In fiscal year 2025 codes C86.00 and C86.01 were added making
#' C86.0 a header code and C86.00 and C86.01 assignable codes.
#'
#' @param with.descriptions Logical scalar, if `TRUE` include the
#'   description of the codes.
#' @param with.hierarchy Logical scalar, if `TRUE` include the ICD
#'   hierarchy.
#'
#' @seealso [is_icd()], [lookup_icd_codes()],
#'   `vignette(topic = "icd", package = "medicalcoder")`
#'
#' @family icd tools
#'
#' @returns a `data.frame`
#'
#' The default return has the following columns:
#'
#' * `icdv`: Integer vector indicating if the code is from ICD-9 or ICD-10
#' * `dx`: Integer vector.  1 if the code is a diagnostic, (ICD-9-CM, ICD-10-CM, WHO, CDC Mortality), or 0 if the code is procedural (ICD-9-PCS, ICD-10-PCS)
#' * `full_code`: Character vector with the ICD code and any relevant decimal point
#' * `code`: Character vector with the compact ICD code omitting any relevant decimal point
#' * `src`: Character vector reporting the source of the information.  See Details.
#' * `known_start`: Integer vector reporting the first known year of use.  See Details.
#' * `known_end`: Integer vector reporting the last known year of use.  See Details.
#' * `assignable_start`: Integer vector reporting the first known year the code was assignable.  See Details.
#' * `assignable_end`: Integer vector reporting the last known year the code was assignable.  See Details.
#'
#' When `with.descriptions = TRUE` there are the following additional columns:
#'
#' * `desc`: Character vector of descriptions.  For `cms` codes descriptions from CMS are used preferentially over CDC.
#' * `desc_start`: Integer vector of the first year the description was used.
#' * `desc_end`: Integer vector of the last year the description was used.
#'
#' When `with.hierarchy = TRUE` there are the following additional columns:
#'
#' * `chapter`
#' * `subchapter`
#' * `category`
#' * `subcategory`
#' * `subclassification`
#' * `subsubclassification`
#' * `extension`
#'
#' @example examples/get_icd_codes.R
#'
#' @export
get_icd_codes <- function(with.descriptions = FALSE, with.hierarchy = FALSE) {
  assert_scalar_logical(with.descriptions)
  assert_scalar_logical(with.hierarchy)

  column_order <-
    c("icdv", "dx", "full_code", "code", "src",
      "known_start", "known_end", "assignable_start", "assignable_end",
      "desc", "desc_start", "desc_end",
      "chapter", "subchapter", "category", "subcategory", "subclassification", "subsubclassification", "extension")

  if (!with.hierarchy) {
    if (!with.descriptions) {
      x <- get("icd_codes", envir = ..mdcr_data_env.., inherits = FALSE)
    } else {
      x <- get("icd_codes_with_desc", envir = ..mdcr_data_env.., inherits = FALSE)
    }
  } else {
    hier  <- icd_hierarchy()
    z <- get_icd_codes(with.descriptions = with.descriptions, with.hierarchy = FALSE)
    x <- merge(z, hier, all = TRUE, by = intersect(names(z), names(hier)))
  }

  x <- x[, column_order[column_order %in% names(x)], drop = FALSE]
  unserialize(serialize(x, connection = NULL))
}

################################################################################
# NON-Exported Functions
#
# Add more hierarchy to the data set
#
# FROM https://www.medicalbillingandcoding.org/
#
# ICD-9-CM codes are three-to-five digit numeric and, in certain cases, alpha-
# numeric codes. The first three digits in a code are called the “category.”
# The category describes the general illness, injury, or condition of the
# patient. In many cases, the category is not specific enough to describe the
# full extent of the patient’s condition. Take dementia, for example. The
# basic ICD-9-CM code for dementia is 290. These first three numbers are the
# category, but since dementia is such a complicated condition, you would
# almost never stop coding at this level.
#
# In cases where more specificity is needed, a decimal point is added after
# the category and one or two more digits are added. The fourth digit of the
# ICD-9 code is called the “subcategory,” and the fifth digit is called the
# “subclassification.”
#
# FROM https://www.medicalbillingandcoding.org/icd-10-cm/
#
# Layout and Organization
#
# ICD-10-CM is a seven-character, alphanumeric code. Each code begins with a
# letter, and that letter is followed by two numbers. The first three characters
# of ICD-10-CM are the “category.” The category describes the general type of
# the injury or disease. The category is followed by a decimal point and the
# subcategory. This is followed by up to two subclassifications, which further
# explain the cause, manifestation, location, severity, and type of injury or
# disease. The last character is the extension.
#
# The extension describes the type of encounter this is. That is, if this is the
# first time a healthcare provider has seen the patient for this
# condition/injury/disease, it’s listed as the “initial encounter.” Every
# encounter after the first is listed as a “subsequent encounter.” Patient
# visits related to the effects of a previous injury or disease are listed with
# the term “sequela.”
#
# To review: the first digit of an ICD-10-CM code is always an alpha, the second
# digit is always numeric, and digits three through seven may be alpha or
# numeric. Here’s a simplified look at ICD-10-CM’s format.
#
# A01 – {Disease}
#
# A01.0 {Disease] of the lungs
# A01.01 … simple
# A01.02 … complex
# A01.020 … affecting the trachea
# A01.021 … affecting the cardiopulmonary system
# A01.021A … initial encounter
# A01.021D … subsequent encounter
# A01.021S … sequela
#'
#' @keywords internal
icd_hierarchy <- function() {
  codes <- ..mdcr_internal_icd_codes..

  codes <- merge(x = codes, y = ..mdcr_internal_icd_chapters.., all = TRUE, by = "chap_id")
  codes <- merge(x = codes, y = ..mdcr_internal_icd_subchapters.., all = TRUE, by = "subchap_id")
  codes[["chap_id"]] <- NULL
  codes[["subchap_id"]] <- NULL

  codes[["category"]]             <- NA_character_
  codes[["subcategory"]]          <- NA_character_
  codes[["subclassification"]]    <- NA_character_
  codes[["subsubclassification"]] <- NA_character_
  codes[["extension"]]            <- NA_character_

  nchars <- nchar(codes[["code"]])

  icd10 <- codes[["icdv"]] == 10L

  i <- icd10 & nchars > 2; codes[["category"]][i]             <- substr(codes[["code"]][i], start = 1L, stop = 3L)
  i <- icd10 & nchars > 3; codes[["subcategory"]][i]          <- substr(codes[["code"]][i], start = 1L, stop = 4L)
  i <- icd10 & nchars > 4; codes[["subclassification"]][i]    <- substr(codes[["code"]][i], start = 1L, stop = 5L)
  i <- icd10 & nchars > 5; codes[["subsubclassification"]][i] <- substr(codes[["code"]][i], start = 1L, stop = 6L)
  i <- icd10 & nchars > 6; codes[["extension"]][i]            <- substr(codes[["code"]][i], start = 1L, stop = 7L)

  icd9dx <- codes[["icdv"]] == 9L & codes[["dx"]] == 1L

  i <- icd9dx & nchars > 2; codes[["category"]][i]          <- substr(codes[["code"]][i], start = 1L, stop = 3L)
  i <- icd9dx & nchars > 3; codes[["subcategory"]][i]       <- substr(codes[["code"]][i], start = 1L, stop = 4L)
  i <- icd9dx & nchars > 4; codes[["subclassification"]][i] <- substr(codes[["code"]][i], start = 1L, stop = 5L)

  icd9pr <- codes[["icdv"]] == 9L & codes[["dx"]] == 0L
  i <- icd9pr & nchars > 1; codes[["category"]][i]          <- substr(codes[["code"]][i], start = 1L, stop = 2L)
  i <- icd9pr & nchars > 2; codes[["subcategory"]][i]       <- substr(codes[["code"]][i], start = 1L, stop = 3L)
  i <- icd9pr & nchars > 3; codes[["subclassification"]][i] <- substr(codes[["code"]][i], start = 1L, stop = 4L)

  codes
}

################################################################################
#                                 End of File                                  #
################################################################################
