########################################################################
# find the pccc flags for a set of dx and pr codes.  match against both
# ICD-9 and ICD-10 codes using the example dataset mdcr
#
# see vignette(medicalcoder::pccc) for examples and details on identifying
# ICD-9 and ICD-10 codes within the mdcr dataset

mdcr_pccc_v3_flags <-
  comorbidities(mdcr, id.vars = "patid", icd.codes = "code", dxpr.var = "dxpr")

summary(mdcr_pccc_v3_flags)

mdcr_pccc_v2_flags <-
  comorbidities(mdcr, id.vars = "patid", icd.codes = "code", dxpr.var = "dxpr", method = "pccc_v2.0")

summary(mdcr_pccc_v2_flags)

########################################################################
# flag.method example

# Current - only flag the condition if it is POA for the current encounter.
# since there is no POA flag in the data, the default here will be to set POA =
# 1L for all codes.  A warning will be given to this effect.
comorbidities(data = mdcr_longitudinal,
     icd.codes = "code",
     id.vars = c("patid", "date"),
     icdv.var = "icdv",
     dxpr = "dx",
     method = "pccc_v2.0",
     flag.method = "current" # default
    )

# Say you only want a condition to be flagged if it occurred on a prior
# encounter.  Since the POA value is not known for the mdcr_longitudinal data,
# we can get this behavior by setting flag.method to cumulative and poa to 0L
# (the default if poa.var and poa are both NULL)
comorbidities(data = mdcr_longitudinal,
     icd.codes = "code",
     id.vars = c("patid", "date"),
     icdv.var = "icdv",
     dxpr = "dx",
     method = "pccc_v2.0",
     flag.method = "cumulative",
     poa = 0L
    )

# To flag a comorbidity if it appeared before or during the current encounter,
# set flag.method to cumulative and poa = 1L.
comorbidities(data = mdcr_longitudinal,
     icd.codes = "code",
     id.vars = c("patid", "date"),
     icdv.var = "icdv",
     dxpr = "dx",
     method = "pccc_v2.0",
     poa = 1L,
     flag.method = "cumulative"
    )
