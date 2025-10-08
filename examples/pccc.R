########################################################################
# find the pccc flags for a set of dx and pr codes.  match against both
# ICD-9 and ICD-10 codes using the example data set mdcr
#
# see vignette(medicalcoder::pccc) for examples and details on identifing
# ICD-9 and ICD-10 codes within the mdcr data set

mdcr_pccc_v3_flags <-
  comorbidities(mdcr, id.vars = "patid", icd.codes = "code", dxpr.var = "dxpr")

summary(mdcr_pccc_v3_flags)

mdcr_pccc_v2_flags <-
  comorbidities(mdcr, id.vars = "patid", icd.codes = "code", dxpr.var = "dxpr", method = "pccc_v2.0")

summary(mdcr_pccc_v2_flags)

########################################################################
# flag.method example

# Current - only flag the condiditon if it is POA for the current encounter.
# since there is no POA flag in the data, the default here will be to set POA =
# 1 for all codes.  A warning will be given to this effect.
comorbidities(data = mdcr_longitudinal,
     icd.codes = "code",
     id.vars = c("patid", "date"),
     icdv.var = "icdv",
     dxpr = "dx",
     method = "pccc_v2.0",
     flag.method = "current" # default
    )

# Say you only want a condition to be flagged if it had occured on a prior
# encounter.  Since the POA value is not known for the mdcr_longitudinal data,
# we can get this behavior by setting flag.method to cumulative and poa to 0
# (the default if poa.var and poa are both NULL)
comorbidities(data = mdcr_longitudinal,
     icd.codes = "code",
     id.vars = c("patid", "date"),
     icdv.var = "icdv",
     dxpr = "dx",
     method = "pccc_v2.0",
     flag.method = "cumulative",
     poa = 0
    )

# To flag a commorbidity if appeared before or during the current encounter set
# flag.method to cumulative and poa = 1
comorbidities(data = mdcr_longitudinal,
     icd.codes = "code",
     id.vars = c("patid", "date"),
     icdv.var = "icdv",
     dxpr = "dx",
     method = "pccc_v2.0",
     poa = 1,
     flag.method = "cumulative"
    )
