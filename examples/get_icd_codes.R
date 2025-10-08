icd_codes <- get_icd_codes()
str(icd_codes)

# Explore the change in the assignable year for C86 code between CMS and
# WHO
subset(get_icd_codes(), grepl("^C86$", full_code))
subset(get_icd_codes(), grepl("^C86\\.\\d$", full_code))
subset(get_icd_codes(), grepl("^C86\\.0(\\d|$)", full_code))

is_icd("C86", headerok = FALSE) # FALSE
is_icd("C86", headerok = TRUE)  # TRUE
is_icd("C86", headerok = TRUE, src = "cdc") # Not a CDC mortality code

lookup_icd_codes("^C86\\.0\\d*", regex = TRUE)
