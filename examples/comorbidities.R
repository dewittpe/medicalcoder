pccc_v3.1_results <-
  comorbidities(data = mdcr,
                icd.codes = "code",
                id.vars = "patid",
                dx.var = "dx",
                method = "pccc_v3.1",
                flag.method = 'current',
                poa = 1)
summary(pccc_v3.1_results)

pccc_v3.1_subcondition_results <-
  comorbidities(data = mdcr,
                icd.codes = "code",
                id.vars = "patid",
                dx.var = "dx",
                method = "pccc_v3.1",
                flag.method = 'current',
                poa = 1,
                subconditions = TRUE)
summary(pccc_v3.1_subcondition_results)

charlson_results <-
  comorbidities(data = mdcr,
                icd.codes = "code",
                id.vars = "patid",
                dx.var = "dx",
                method = "charlson_quan2011",
                flag.method = 'current',
                poa = 1)
summary(charlson_results)

elixhauser_results <-
  comorbidities(data = mdcr,
                icd.codes = "code",
                id.vars = "patid",
                dx.var = "dx",
                method = "elixhauser_ahrq2025",
                primarydx = 1,
                flag.method = 'current',
                poa = 1)
summary(elixhauser_results)
