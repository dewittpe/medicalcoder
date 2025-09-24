library(medicalcoder)
library(data.table)

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
  data.table(permutation = rep(1:6, each = 7),
             encounter_id = rep(1:7, times = 6),
             code =
               codes[c(NA, 1, NA, 2, NA, 3, NA,
                       NA, 1, NA, 3, NA, 2, NA,
                       NA, 2, NA, 1, NA, 3, NA,
                       NA, 2, NA, 3, NA, 1, NA,
                       NA, 3, NA, 1, NA, 2, NA,
                       NA, 3, NA, 2, NA, 1, NA)])

permutations[, plabel := paste(na.omit(code), collapse = ", "), by = .(permutation)]
permutations[, plabel := paste0("Permutation ", permutation, ": ", plabel)]

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
stopifnot(rtn[permutation == 1, plabel == "Permutation 1: H49.811, J84.111, Z96.41"])
stopifnot(rtn[permutation == 2, plabel == "Permutation 2: H49.811, Z96.41, J84.111"])
stopifnot(rtn[permutation == 3, plabel == "Permutation 3: J84.111, H49.811, Z96.41"])
stopifnot(rtn[permutation == 4, plabel == "Permutation 4: J84.111, Z96.41, H49.811"])
stopifnot(rtn[permutation == 5, plabel == "Permutation 5: Z96.41, H49.811, J84.111"])
stopifnot(rtn[permutation == 6, plabel == "Permutation 6: Z96.41, J84.111, H49.811"])

# Permutation 1
#   The sequnce of conditions:
#     2. metabolic (other) (H49.811)
#     4. respiratory       (J84.111)
#     6. metabolic (tech)  (Z96.41)

expected_metabolic_dxpr_or_tech1  = c(0L, 1L, 1L, 1L, 1L, 1L, 1L)
expected_metabolic_dxpr_only1     = c(0L, 1L, 1L, 1L, 1L, 0L, 0L)
expected_metabolic_tech_only1     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_metabolic_dxpr_and_tech1 = c(0L, 0L, 0L, 0L, 0L, 1L, 1L)

expected_respiratory_dxpr_or_tech1  = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)
expected_respiratory_dxpr_only1     = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)
expected_respiratory_tech_only1     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_respiratory_dxpr_and_tech1 = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)

# Permutation 2
#   The sequnce of conditions:
#     2. metabolic (other) (H49.811)
#     4. metabolic (tech)  (Z96.41)
#     6. respiratory       (J84.111)
expected_metabolic_dxpr_or_tech2  = c(0L, 1L, 1L, 1L, 1L, 1L, 1L)
expected_metabolic_dxpr_only2     = c(0L, 1L, 1L, 0L, 0L, 0L, 0L)
expected_metabolic_tech_only2     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_metabolic_dxpr_and_tech2 = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)

expected_respiratory_dxpr_or_tech2  = c(0L, 0L, 0L, 0L, 0L, 1L, 1L)
expected_respiratory_dxpr_only2     = c(0L, 0L, 0L, 0L, 0L, 1L, 1L)
expected_respiratory_tech_only2     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_respiratory_dxpr_and_tech2 = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)

# Permutation 3
#   The sequnce of conditions:
#     2. respiratory       (J84.111)
#     4. metabolic (other) (H49.811)
#     6. metabolic (tech)  (Z96.41)
expected_metabolic_dxpr_or_tech3  = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)
expected_metabolic_dxpr_only3     = c(0L, 0L, 0L, 1L, 1L, 0L, 0L)
expected_metabolic_tech_only3     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_metabolic_dxpr_and_tech3 = c(0L, 0L, 0L, 0L, 0L, 1L, 1L)

expected_respiratory_dxpr_or_tech3  = c(0L, 1L, 1L, 1L, 1L, 1L, 1L)
expected_respiratory_dxpr_only3     = c(0L, 1L, 1L, 1L, 1L, 1L, 1L)
expected_respiratory_tech_only3     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_respiratory_dxpr_and_tech3 = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)

# Permutation 4
#   The sequnce of conditions:
#     2. respiratory       (J84.111)
#     4. metabolic (tech)  (Z96.41)
#     6. metabolic (other) (H49.811)
expected_metabolic_dxpr_or_tech4  = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)
expected_metabolic_dxpr_only4     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_metabolic_tech_only4     = c(0L, 0L, 0L, 1L, 1L, 0L, 0L)
expected_metabolic_dxpr_and_tech4 = c(0L, 0L, 0L, 0L, 0L, 1L, 1L)

expected_respiratory_dxpr_or_tech4  = c(0L, 1L, 1L, 1L, 1L, 1L, 1L)
expected_respiratory_dxpr_only4     = c(0L, 1L, 1L, 1L, 1L, 1L, 1L)
expected_respiratory_tech_only4     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_respiratory_dxpr_and_tech4 = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)

# Permutation 5
#   The sequnce of conditions:
#     2. metabolic (tech)  (Z96.41)
#     4. metabolic (other) (H49.811)
#     6. respiratory       (J84.111)
expected_metabolic_dxpr_or_tech5  = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)
expected_metabolic_dxpr_only5     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_metabolic_tech_only5     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_metabolic_dxpr_and_tech5 = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)

expected_respiratory_dxpr_or_tech5  = c(0L, 0L, 0L, 0L, 0L, 1L, 1L)
expected_respiratory_dxpr_only5     = c(0L, 0L, 0L, 0L, 0L, 1L, 1L)
expected_respiratory_tech_only5     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_respiratory_dxpr_and_tech5 = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)

# Permutation 6
#   The sequnce of conditions:
#     2. metabolic (tech)  (Z96.41)
#     4. respiratory       (J84.111)
#     6. metabolic (other) (H49.811)
expected_metabolic_dxpr_or_tech6  = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)
expected_metabolic_dxpr_only6     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_metabolic_tech_only6     = c(0L, 0L, 0L, 1L, 1L, 0L, 0L)
expected_metabolic_dxpr_and_tech6 = c(0L, 0L, 0L, 0L, 0L, 1L, 1L)

expected_respiratory_dxpr_or_tech6  = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)
expected_respiratory_dxpr_only6     = c(0L, 0L, 0L, 1L, 1L, 1L, 1L)
expected_respiratory_tech_only6     = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)
expected_respiratory_dxpr_and_tech6 = c(0L, 0L, 0L, 0L, 0L, 0L, 0L)

stopifnot(
    rtn[permutation == 1, metabolic_dxpr_or_tech  == expected_metabolic_dxpr_or_tech1 ]
  , rtn[permutation == 1, metabolic_dxpr_only     == expected_metabolic_dxpr_only1    ]
  , rtn[permutation == 1, metabolic_tech_only     == expected_metabolic_tech_only1    ]
  , rtn[permutation == 1, metabolic_dxpr_and_tech == expected_metabolic_dxpr_and_tech1]

  , rtn[permutation == 1, respiratory_dxpr_or_tech  == expected_respiratory_dxpr_or_tech1 ]
  , rtn[permutation == 1, respiratory_dxpr_only     == expected_respiratory_dxpr_only1    ]
  , rtn[permutation == 1, respiratory_tech_only     == expected_respiratory_tech_only1    ]
  , rtn[permutation == 1, respiratory_dxpr_and_tech == expected_respiratory_dxpr_and_tech1]

  , rtn[permutation == 2, metabolic_dxpr_or_tech  == expected_metabolic_dxpr_or_tech2 ]
  , rtn[permutation == 2, metabolic_dxpr_only     == expected_metabolic_dxpr_only2    ]
  , rtn[permutation == 2, metabolic_tech_only     == expected_metabolic_tech_only2    ]
  , rtn[permutation == 2, metabolic_dxpr_and_tech == expected_metabolic_dxpr_and_tech2]

  , rtn[permutation == 2, respiratory_dxpr_or_tech  == expected_respiratory_dxpr_or_tech2 ]
  , rtn[permutation == 2, respiratory_dxpr_only     == expected_respiratory_dxpr_only2    ]
  , rtn[permutation == 2, respiratory_tech_only     == expected_respiratory_tech_only2    ]
  , rtn[permutation == 2, respiratory_dxpr_and_tech == expected_respiratory_dxpr_and_tech2]

  , rtn[permutation == 3, metabolic_dxpr_or_tech  == expected_metabolic_dxpr_or_tech3 ]
  , rtn[permutation == 3, metabolic_dxpr_only     == expected_metabolic_dxpr_only3    ]
  , rtn[permutation == 3, metabolic_tech_only     == expected_metabolic_tech_only3    ]
  , rtn[permutation == 3, metabolic_dxpr_and_tech == expected_metabolic_dxpr_and_tech3]

  , rtn[permutation == 3, respiratory_dxpr_or_tech  == expected_respiratory_dxpr_or_tech3 ]
  , rtn[permutation == 3, respiratory_dxpr_only     == expected_respiratory_dxpr_only3    ]
  , rtn[permutation == 3, respiratory_tech_only     == expected_respiratory_tech_only3    ]
  , rtn[permutation == 3, respiratory_dxpr_and_tech == expected_respiratory_dxpr_and_tech3]

  , rtn[permutation == 4, metabolic_dxpr_or_tech  == expected_metabolic_dxpr_or_tech4 ]
  , rtn[permutation == 4, metabolic_dxpr_only     == expected_metabolic_dxpr_only4    ]
  , rtn[permutation == 4, metabolic_tech_only     == expected_metabolic_tech_only4    ]
  , rtn[permutation == 4, metabolic_dxpr_and_tech == expected_metabolic_dxpr_and_tech4]

  , rtn[permutation == 4, respiratory_dxpr_or_tech  == expected_respiratory_dxpr_or_tech4 ]
  , rtn[permutation == 4, respiratory_dxpr_only     == expected_respiratory_dxpr_only4    ]
  , rtn[permutation == 4, respiratory_tech_only     == expected_respiratory_tech_only4    ]
  , rtn[permutation == 4, respiratory_dxpr_and_tech == expected_respiratory_dxpr_and_tech4]

  , rtn[permutation == 5, metabolic_dxpr_or_tech  == expected_metabolic_dxpr_or_tech5 ]
  , rtn[permutation == 5, metabolic_dxpr_only     == expected_metabolic_dxpr_only5    ]
  , rtn[permutation == 5, metabolic_tech_only     == expected_metabolic_tech_only5    ]
  , rtn[permutation == 5, metabolic_dxpr_and_tech == expected_metabolic_dxpr_and_tech5]

  , rtn[permutation == 5, respiratory_dxpr_or_tech  == expected_respiratory_dxpr_or_tech5 ]
  , rtn[permutation == 5, respiratory_dxpr_only     == expected_respiratory_dxpr_only5    ]
  , rtn[permutation == 5, respiratory_tech_only     == expected_respiratory_tech_only5    ]
  , rtn[permutation == 5, respiratory_dxpr_and_tech == expected_respiratory_dxpr_and_tech5]

  , rtn[permutation == 6, metabolic_dxpr_or_tech  == expected_metabolic_dxpr_or_tech6 ]
  , rtn[permutation == 6, metabolic_dxpr_only     == expected_metabolic_dxpr_only6    ]
  , rtn[permutation == 6, metabolic_tech_only     == expected_metabolic_tech_only6    ]
  , rtn[permutation == 6, metabolic_dxpr_and_tech == expected_metabolic_dxpr_and_tech6]

  , rtn[permutation == 6, respiratory_dxpr_or_tech  == expected_respiratory_dxpr_or_tech6 ]
  , rtn[permutation == 6, respiratory_dxpr_only     == expected_respiratory_dxpr_only6    ]
  , rtn[permutation == 6, respiratory_tech_only     == expected_respiratory_tech_only6    ]
  , rtn[permutation == 6, respiratory_dxpr_and_tech == expected_respiratory_dxpr_and_tech6]
)

################################################################################
#                                 End of File                                  #
################################################################################
