################################################################################
# objective - the pccc_v2.0 in medicalcoder should reproduce the results from
# pccc version 1.0.6 _almost_ identically.
#
# There are a few differences.  The reason for this difference is that the old
# pccc package only mapped to conditions and did not map subconditions.  this
# creates a problem with a few codes that were not documented but in the
# software.  Those will be noted in this script.
library(medicalcoder)
library(data.table)
setDTthreads(threads = 1L) # to prevent CPU time exceeding elapsed time on CRAN

# get the ICD codes from the medicalcoder package and add a code_id column
icd_codes <- get_icd_codes()
setDT(icd_codes)
icd_codes[, code_id := 1:.N]

# pccc_1.0.6 requires the input to be in a wide format and can only apply logic
# for ICD-9 or ICD-10 in one call.  Split the codes into the four sets ICD-9-CM,
# ICD-9-PCS, ICD-10-CM, and ICD-10-PCS.  Apply pccc::ccc to each and bind the
# results so we know when ICD codes map to which conditions.
#
# The following code generates the output object which is saved in the test
# directory such that the pccc_v1.0.6 package is not needed in the SUGGESTS
# section of the DESCRIPTION file.

###  library(pccc)
###  stopifnot(packageVersion("pccc") == "1.0.6")
###
###  oldpccc <- rbind(
###    pccc::ccc(data = icd_codes[icdv ==  9 & dx == 1, .(code_id,  code)],
###               id = code_id, dx_cols = "code", icdv = 9)
###    ,
###    pccc::ccc(data = icd_codes[icdv ==  9 & dx == 0, .(code_id,  code)],
###               id = code_id, pc_cols = "code", icdv = 9)
###    ,
###    pccc::ccc(data = icd_codes[icdv ==  10 & dx == 1, .(code_id,  code)],
###               id = code_id, dx_cols = "code", icdv = 10)
###    ,
###    pccc::ccc(data = icd_codes[icdv ==  10 & dx == 0, .(code_id,  code)],
###               id = code_id, pc_cols = "code", icdv = 10)
###  )
###
###  saveRDS(oldpccc, file = "results_pccc_1.0.6.rds")

oldpccc <- readRDS(file = "results_pccc_1.0.6.rds")
setDT(oldpccc)

newpccc <-
  medicalcoder::comorbidities(
      data = icd_codes
    , icd.codes = "full_code"
    , id.vars = "code_id"
    , icdv.var = "icdv"
    , icdv = NULL
    , dx.var = "dx"
    , dx = NULL
    , poa = 1
    , poa.var = NULL
    , age.var = NULL
    , primarydx = NULL
    , primarydx.var = NULL
    , flag.method = "current"
    , full.codes = TRUE
    , compact.codes = TRUE
    , method = "pccc_v2.0"
  )


old_vs_mdcr <-
  merge(x = oldpccc,
        y = newpccc,
        all = TRUE,
        by = "code_id",
        suffixes = c("_old", "_mdcr"))

old_vs_mdcr <- merge(x = old_vs_mdcr,
              y = icd_codes[, .(code_id, icdv, dx, full_code)],
              all = TRUE,
              by = "code_id")

stopifnot(!any(is.na(old_vs_mdcr)))

# We expect there are no difference in the neuromusc flag
stopifnot(
  old_vs_mdcr[neuromusc_old != neuromusc_mdcr][, .N == 0]
)

# we expect there is no difference in the cvd flag
stopifnot(
  old_vs_mdcr[cvd_old != cvd_mdcr][, .N == 0]
)

# we expect there is no difference in the respiratory flag
stopifnot(
  old_vs_mdcr[respiratory_old != respiratory_mdcr][, .N == 0]
)

# we expect there is no difference in the renal flag
stopifnot(
  old_vs_mdcr[renal_old != renal_mdcr][, .N == 0]
)

# we expect there is no difference in the gi flag
stopifnot(
  old_vs_mdcr[gi_old != gi_mdcr][, .N == 0]
)

# we expect there is no difference in the hemato_immu flag
stopifnot(
  old_vs_mdcr[hemato_immu_old != hemato_immu_mdcr][, .N == 0]
)

# we expect there is no difference in the metabolic flag
stopifnot(
  old_vs_mdcr[metabolic_old != metabolic_mdcr][, .N == 0]
)

# we expect there is no difference in the congeni_genetic flag
stopifnot(
  old_vs_mdcr[congeni_genetic_old != congeni_genetic_mdcr][, .N == 0]
)

# we expect there is no difference in the malignancy flag
stopifnot(
  old_vs_mdcr[malignancy_old != malignancy_mdcr][, .N == 0]
)

# we expect there is no difference in the neonatal flag
stopifnot(
  old_vs_mdcr[neonatal_old != neonatal_mdcr][, .N == 0]
)

# we expect there are some differences in the tech_dep flag

# ICD-9-CM 349.1 - not in the v2 document, but in the software for neuromusc
# only. This raises an problem that the subcondtion is not defined.  To allow
# for the methods in medicalcoder to work, a non missing subcondition is needed.
# device and technology use was seems appropriate
#
# ICD-9-CM V56 - same, not in v2 documents, in the software
#
# ICD-10-CM Z49 - same, not in v2 documents, in the software
#
# ICD-9-PCS 86.06 - this is in the document as metabolic (devices) but is only
# listed under metabolic in the software.  Again, becuase of the use of the
# subconditions in the implimentation in medicalcoder the corrected mapping is
# needed in medicalcoder and thus the difference.
#
# ICD-9-CM V45.85 - same as ICD-9-PCS 86.06
#
# ICD-9-CM V53.3 - great, this is a header code using in cvd, the assignable
# codes, V53.31, V53.32, V53.39 are explicitly mapped to tech dep.  The result,
# the V53.3 needs to also have a tech dep flag
# subset(get_icd_codes(), grepl("^V53\\.3", full_code) & icdv == 9)
#
# ICD-9-CM V53.91 "Fitting and adjustment of insulin pump"
# This is listed in the documentation as metabolic (devices) by has been
# implanted in R as metabolic (transplant).  One major issue with this error is
# that there are no codes for metabolic (transplant). It doesn't make since to
# retain this error so, method=pccc_v2.0 will differ from the R package
# pccc_1.0.6 for this code.
#
# subset(get_icd_codes(with.descriptions = TRUE), grepl("^V53\\.9", full_code) & icdv == 9)
#
# ICD-9-CM V65, and specifically V65.46 (encounter for insulin pump training),
# is not in the documentation but is in the R pccc_v1.0.6 implimentation as
# metabolic.  The device flag as been added to this code.
# subset(get_icd_codes(with.descriptions = TRUE), grepl("^V65\\.4", full_code) & icdv == 9)

mismatch_tech_dep <- old_vs_mdcr[tech_dep != any_tech_dep]
stopifnot(nrow(mismatch_tech_dep) == 18L)
stopifnot(
          isTRUE(identical(sort(mismatch_tech_dep$full_code),
                           c("349.1",
                             "86.06",
                             "V45.85",
                             "V53.3",
                             "V53.91",
                             "V56", "V56.0", "V56.1", "V56.2", "V56.3", "V56.31", "V56.32", "V56.8",
                             "V65.46",
                             "Z49.01", "Z49.02", "Z49.31", "Z49.32")
             )
          )
)

# we expect there are some difference in the transplant flag
#
# ICD-9-PCS 37.52 -- documented as cvd (device) implimented as cvd and
# transplant.

#subset(get_pccc_codes(), grepl("^37\\.52", full_code))
#subset(get_icd_codes(with.descriptions = TRUE), grepl("^37\\.52", full_code))

# ICD-9-CM V42.0
# documented as renal (transplant)
# missing from the transplant set in the pccc_1.0.6/src/pccc.cpp

#subset(get_pccc_codes(), grepl("^V42\\.0", full_code))
#subset(get_icd_codes(with.descriptions = TRUE), grepl("^V42\\.0", full_code) & icdv == 9)

# ICD-10-CM Z94
# specifically Z94.1, Z94.2, Z94.4, Z94.81, Z94.82, Z94.83, Z94.84
# All documented as subcondition transplant but are missing from the transplant
# set in the pccc_1.0.6/srs/pccc.cpp
#
#subset(get_pccc_codes(), grepl("^Z94", full_code))
#subset(get_icd_codes(with.descriptions = TRUE), grepl("^Z94", full_code) & icdv == 10)

#
mismatch_transplant <- old_vs_mdcr[transplant != any_transplant]
mismatch_transplant[, .(full_code, transplant, any_transplant)]
stopifnot(nrow(mismatch_transplant) == 15L)

stopifnot(
          isTRUE(identical(sort(unique(mismatch_transplant$full_code)),
                           c("37.52",
                             "37.53",
                             "37.54",
                             "37.55",
                             "V42.0",
                             "Z94.1",
                             "Z94.2",
                             "Z94.4",
                             "Z94.81",
                             "Z94.82",
                             "Z94.83",
                             "Z94.84")
                          )
          )
)

# we expect there is no difference in the ccc_flag
stopifnot(
  old_vs_mdcr[ccc_flag != cmrb_flag][, .N == 0]
)

################################################################################
#                                 End of File                                  #
################################################################################
