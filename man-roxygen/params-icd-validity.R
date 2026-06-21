#' @param year Integer scalar used when determining validity. CMS and CDC
#'   ICD-9-CM/PCS use U.S. fiscal years, IHACPA uses Australian financial years,
#'   and WHO, CDC ICD-10 mortality, and Socialstyrelsen use calendar years. If
#'   missing, the most recent year available for the given source(s) is used.
#'
#' @param headerok Logical scalar. If `FALSE` (default), only assignable (most
#'   granular) codes are considered valid; if `TRUE`, header codes are also
#'   accepted.
#'
#' @param ever.assignable Logical scalar. If `TRUE`, ignore `year` and return
#'   results based on whether a code was *ever* assignable in the source.
#'
#' @param warn.ambiguous Logical scalar. If `TRUE` (default), warn when a code
#'   matches more than one ICD version or type (e.g., CM and PCS).
