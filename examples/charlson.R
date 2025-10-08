mdcr_charlson_flags <-
  comorbidities(data = mdcr, id.vars = "patid", icd.codes = "code", poa = 1, method = "charlson_quan2005")

#charlson_index_scores

#charlson_summary_table(mdcr_charlson_flags)


#data          = mdcr
#id.vars       = c("patid")
#icd.codes     = "code"
#icdv.var      = "icdv"
#icdv          = NULL
#dxpr.var      = "dxpr"
#dxpr          = NULL
#age.var       = "age"
#primarydx     = NULL
#primarydx.var = NULL
##method        = "quan05"
#method        = "charlson_quan2005"
#full.codes    = FALSE
#compact.codes = TRUE
#flag.method   = "current"
#poa.var       = NULL
#poa           = 1
