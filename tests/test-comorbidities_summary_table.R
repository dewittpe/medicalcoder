library(medicalcoder)

warning("Test needs to be updated for refactor of pccc")
if (FALSE) {
################################################################################
# Verify the summary table output for pccc_v3.0 is as expected

rtn <- comorbidities(data = mdcr, id.vars = "patid", icd.codes = "code", poa = 1, flag.method = 'current', method = "pccc_v3.0")
rtn <- comorbidities_summary_table(rtn)
expected_rtn  <-
  structure(list(condition = c("Neuromuscular", "Cardiovascular disease",
  "Respiratory", "Renal", "Gastrointestinal", "Hematologic or Immunologic",
  "Metabolic", "Congenital or genetic", "Malignancy", "Neonatal",
  "Transplant", "Technology dependence", "Any CCC", "Tech dependece"
  ), pccc_v3_non_tech = c("5,535 (14.5)", "4,797 (12.5)", "2,507 (6.6)",
  "2,353 (6.1)", "1,900 (5.0)", "2,876 (7.5)", "3,402 (8.9)", "3,186 (8.3)",
  "3,881 (10.1)", "1,526 (4.0)", "1,653 (4.3)", NA, "20,949 (54.8)",
  NA), pccc_v3_tech_only = c("348 (0.9)", "301 (0.8)", "823 (2.2)",
  "529 (1.4)", "3,868 (10.1)", "0 (0.0)", "40 (0.1)", "0 (0.0)",
  "0 (0.0)", "0 (0.0)", "0 (0.0)", "7,101 (18.6)", NA, "7,101 (18.6)"
  ), pccc_v3_non_tech_and_tech = c("1,289 (3.4)", "609 (1.6)",
  "1,482 (3.9)", "886 (2.3)", "4,259 (11.1)", "0 (0.0)", "51 (0.1)",
  "0 (0.0)", "0 (0.0)", "0 (0.0)", "0 (0.0)", "7,101 (18.6)", NA,
  NA), pccc_v3_non_tech_or_tech = c("5,883 (15.4)", "5,098 (13.3)",
  "3,330 (8.7)", "2,882 (7.5)", "5,768 (15.1)", "2,876 (7.5)",
  "3,442 (9.0)", "3,186 (8.3)", "3,881 (10.1)", "1,526 (4.0)",
  "1,653 (4.3)", NA, "20,949 (54.8)", NA)), row.names = c(NA, -14L
  ), class = "data.frame")

stopifnot(
  "pccc 3.0 summary table is as expected" = isTRUE(identical(rtn, expected_rtn))
)

################################################################################
# Version 2.0

rtn <- comorbidities(data = mdcr, id.vars = "patid", icd.codes = "code", poa = 1, flag.method = 'current', method = "pccc_v2.0")
rtn <- comorbidities_summary_table(rtn)

expected_rtn  <-
  read.delim(header = TRUE, sep = "\t", text =
"condition\tpccc_v2.0
Neuromuscular\t5,842 (15.3)
Cardiovascular disease\t5,034 (13.2)
Respiratory\t3,317 (8.7)
Renal\t2,967 (7.8)
Gastrointestinal\t6,891 (18.0)
Hematologic or Immunologic\t2,806 (7.3)
Metabolic\t3,307 (8.6)
Congenital or genetic\t3,399 (8.9)
Malignancy\t4,024 (10.5)
Neonatal\t1,572 (4.1)
Transplant\t1,227 (3.2)
Technology dependence\t8,797 (23.0)
Any CCC\t22,686 (59.3)
")

stopifnot(
  "pccc 2.0 summary table is as expected" = isTRUE(identical(rtn, expected_rtn))
)

################################################################################
# Version 2.1

rtn <- comorbidities(data = mdcr, id.vars = "patid", icd.codes = "code", poa = 1, flag.method = 'current', method = "pccc_v2.1")
rtn <- comorbidities_summary_table(rtn)

expected_rtn  <-
  read.delim(header = TRUE, sep = "\t", text =
"condition\tpccc_v2.1
Neuromuscular\t5,988 (15.6)
Cardiovascular disease\t5,034 (13.2)
Respiratory\t3,321 (8.7)
Renal\t2,967 (7.8)
Gastrointestinal\t6,891 (18.0)
Hematologic or Immunologic\t2,806 (7.3)
Metabolic\t3,333 (8.7)
Congenital or genetic\t3,399 (8.9)
Malignancy\t4,057 (10.6)
Neonatal\t1,572 (4.1)
Transplant\t1,476 (3.9)
Technology dependence\t8,850 (23.1)
Any CCC\t22,733 (59.4)
")

stopifnot(
  "pccc 2.1 summary table is as expected" = isTRUE(identical(rtn, expected_rtn))
)

}

################################################################################
#                                 End of File                                  #
################################################################################
