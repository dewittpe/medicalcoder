source('utilities.R')
library(medicalcoder)

# use three codes:
codes <-
  c(
    "H49.811", # metabolic (other)
    "J84.111", # respiratory (chronic respiratory disease)
    "Z96.41"   # metabolic (device and technology use)
  )
subset(get_pccc_codes(), full_code %in% codes)


# build six permutations of these codes.  The codes will be considered poa on
# encounters 2, 4, and 6.  There will be seven encounters for each permutation.
permutations <-
  data.frame(
    permutation = rep(1:6, each = 7),
    encounter_id = rep(1:7, times = 6),
    code =
      codes[c(NA, 1, NA, 2, NA, 3, NA,
        NA, 1, NA, 3, NA, 2, NA,
        NA, 2, NA, 1, NA, 3, NA,
        NA, 2, NA, 3, NA, 1, NA,
        NA, 3, NA, 1, NA, 2, NA,
        NA, 3, NA, 2, NA, 1, NA)]
  )


permutations <- split(permutations, f = permutations[["permutation"]])
permutations <-
  lapply(
    permutations,
    function(x) {
      x[["plabel"]] <- with(x, paste(na.omit(code), collapse = ", "))
      x[["plabel"]] <- with(x, paste0("Permutation ", permutation, ": ", plabel))
      x
    }
  )
permutations <- do.call(rbind, permutations)

# flag cumulative conditions
args <-
  list(
       data = permutations,
       id.vars = c("permutation", "plabel", "encounter_id"),
       icd.codes = "code",
       method = "pccc_v3.1",
       flag.method = "cumulative",
       poa = 1,
       icdv.var = NULL,
       icdv = NULL,
       dx.var = NULL,
       dx = NULL,
       poa.var = NULL,
       age.var = NULL,
       primarydx.var = NULL,
       primarydx = NULL,
       full.codes = TRUE,
       compact.codes = FALSE,
       subconditions = FALSE
  )
#list2env(args, .GlobalEnv)

rtn <- do.call(comorbidities, args)

################################################################################
# verify that the permutations are as expected
stopifnot(rtn[rtn$permutation == 1, "plabel"] == "Permutation 1: H49.811, J84.111, Z96.41")
stopifnot(rtn[rtn$permutation == 2, "plabel"] == "Permutation 2: H49.811, Z96.41, J84.111")
stopifnot(rtn[rtn$permutation == 3, "plabel"] == "Permutation 3: J84.111, H49.811, Z96.41")
stopifnot(rtn[rtn$permutation == 4, "plabel"] == "Permutation 4: J84.111, Z96.41, H49.811")
stopifnot(rtn[rtn$permutation == 5, "plabel"] == "Permutation 5: Z96.41, H49.811, J84.111")
stopifnot(rtn[rtn$permutation == 6, "plabel"] == "Permutation 6: Z96.41, J84.111, H49.811")

# Permutation 1
#   The sequnce of conditions:
#     2. metabolic (other) (H49.811)
#     4. respiratory       (J84.111)
#     6. metabolic (tech)  (Z96.41)
expected_metabolic_dxpr_or_tech_1  = c(0L, 1L, 1L, 1L, 1L, 1L, 1L)
expected_metabolic_dxpr_only_1     = c(0L, 1L, 1L, 1L, 1L, 0L, 0L)
expected_metabolic_tech_only_1     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_metabolic_dxpr_and_tech_1 = c(0L, 0L, 0L, 0L, 0L, 1L, 1L)

expected_respiratory_dxpr_or_tech_1  = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)
expected_respiratory_dxpr_only_1     = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)
expected_respiratory_tech_only_1     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_respiratory_dxpr_and_tech_1 = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)

# Permutation 2
#   The sequnce of conditions:
#     2. metabolic (other) (H49.811)
#     4. metabolic (tech)  (Z96.41)
#     6. respiratory       (J84.111)
expected_metabolic_dxpr_or_tech_2  = c(0L, 1L, 1L, 1L, 1L, 1L, 1L)
expected_metabolic_dxpr_only_2     = c(0L, 1L, 1L, 0L, 0L, 0L, 0L)
expected_metabolic_tech_only_2     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_metabolic_dxpr_and_tech_2 = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)

expected_respiratory_dxpr_or_tech_2  = c(0L, 0L, 0L, 0L, 0L, 1L, 1L)
expected_respiratory_dxpr_only_2     = c(0L, 0L, 0L, 0L, 0L, 1L, 1L)
expected_respiratory_tech_only_2     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_respiratory_dxpr_and_tech_2 = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)

# Permutation 3
#   The sequnce of conditions:
#     2. respiratory       (J84.111)
#     4. metabolic (other) (H49.811)
#     6. metabolic (tech)  (Z96.41)
expected_metabolic_dxpr_or_tech_3  = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)
expected_metabolic_dxpr_only_3     = c(0L, 0L, 0L, 1L, 1L, 0L, 0L)
expected_metabolic_tech_only_3     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_metabolic_dxpr_and_tech_3 = c(0L, 0L, 0L, 0L, 0L, 1L, 1L)

expected_respiratory_dxpr_or_tech_3  = c(0L, 1L, 1L, 1L, 1L, 1L, 1L)
expected_respiratory_dxpr_only_3     = c(0L, 1L, 1L, 1L, 1L, 1L, 1L)
expected_respiratory_tech_only_3     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_respiratory_dxpr_and_tech_3 = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)

# Permutation 4
#   The sequnce of conditions:
#     2. respiratory       (J84.111)
#     4. metabolic (tech)  (Z96.41)
#     6. metabolic (other) (H49.811)
expected_metabolic_dxpr_or_tech_4  = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)
expected_metabolic_dxpr_only_4     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_metabolic_tech_only_4     = c(0L, 0L, 0L, 1L, 1L, 0L, 0L)
expected_metabolic_dxpr_and_tech_4 = c(0L, 0L, 0L, 0L, 0L, 1L, 1L)

expected_respiratory_dxpr_or_tech_4  = c(0L, 1L, 1L, 1L, 1L, 1L, 1L)
expected_respiratory_dxpr_only_4     = c(0L, 1L, 1L, 1L, 1L, 1L, 1L)
expected_respiratory_tech_only_4     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_respiratory_dxpr_and_tech_4 = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)

# Permutation 5
#   The sequnce of conditions:
#     2. metabolic (tech)  (Z96.41)
#     4. metabolic (other) (H49.811)
#     6. respiratory       (J84.111)
expected_metabolic_dxpr_or_tech_5  = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)
expected_metabolic_dxpr_only_5     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_metabolic_tech_only_5     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_metabolic_dxpr_and_tech_5 = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)

expected_respiratory_dxpr_or_tech_5  = c(0L, 0L, 0L, 0L, 0L, 1L, 1L)
expected_respiratory_dxpr_only_5     = c(0L, 0L, 0L, 0L, 0L, 1L, 1L)
expected_respiratory_tech_only_5     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_respiratory_dxpr_and_tech_5 = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)

# Permutation 6
#   The sequnce of conditions:
#     2. metabolic (tech)  (Z96.41)
#     4. respiratory       (J84.111)
#     6. metabolic (other) (H49.811)
expected_metabolic_dxpr_or_tech_6  = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)
expected_metabolic_dxpr_only_6     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_metabolic_tech_only_6     = c(0L, 0L, 0L, 1L, 1L, 0L, 0L)
expected_metabolic_dxpr_and_tech_6 = c(0L, 0L, 0L, 0L, 0L, 1L, 1L)

expected_respiratory_dxpr_or_tech_6  = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)
expected_respiratory_dxpr_only_6     = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)
expected_respiratory_tech_only_6     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_respiratory_dxpr_and_tech_6 = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)

for (cnd in c("metabolic", "respiratory")) {
  for (col in c("dxpr_or_tech", "dxpr_only", "tech_only", "dxpr_and_tech")) {
    for (prm in 1:6) {
      check <-
        rtn[rtn[["permutation"]] == prm, paste(cnd, col, sep = "_")] ==
        get(paste("expected", cnd, col, prm, sep = "_"))
      if (!all(check)) {
        stop(sprintf("test for %s failed", paste("expected", cnd, col, prm, sep = "_")))
      }
    }
  }
}

################################################################################
#                                 End of File                                  #
################################################################################
