#' ## Fiscal, financial, and calendar years
#'
#' WHO, CDC ICD-10 mortality, and Socialstyrelsen years are calendar years. CMS
#' and CDC ICD-9-CM/PCS years are U.S. federal fiscal years, which start on
#' October 1 (e.g., fiscal year 2024 runs 2023-10-01 to 2024-09-30). IHACPA
#' years are Australian financial years, which start on July 1 and end on June
#' 30.
#'
#' WHO last published the ICD-10 code list used here in 2019. Because WHO
#' transitioned to ICD-11 on January 1, 2022, medicalcoder carries the 2019
#' ICD-10 list forward for calendar years 2020 and 2021. Thus WHO rows may have
#' `known_end` or `assignable_end` equal to 2021; this does not indicate that WHO
#' published new ICD-10 lists in 2020 or 2021.
