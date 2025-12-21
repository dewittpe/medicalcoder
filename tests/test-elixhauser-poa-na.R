library(medicalcoder)

# POA-NA should still flag POA-exempt Elixhauser conditions (post-2022).
method <- "elixhauser_ahrq_icd10"

codes <- get_elixhauser_codes()
codes <- codes[!is.na(codes[[method]]), , drop = FALSE]
codes[["patid"]] <- seq_len(nrow(codes))
codes[["poa"]] <- NA_integer_

rtn <- comorbidities(
  data = codes,
  icd.codes = "code",
  id.vars = "patid",
  icdv.var = "icdv",
  dx.var = "dx",
  poa.var = "poa",
  primarydx = 0L,
  flag.method = "current",
  method = method
)

rtn <-
  merge(
    x = codes[, c("patid", "poaexempt", "condition")],
    y = rtn,
    by = "patid"
  )

# verify
# ICD codes which are POA exempt should all flag to 1
poaexempt_codes <- subset(rtn, poaexempt == 1L)
for (cn in unique(rtn[["condition"]])) {
  x <- subset(poaexempt_codes, condition == cn)
  stopifnot(all(x[[cn]] == 1L))
}

# now for the conditions
rtn <- subset(rtn, poaexempt == 0L)


poa_tbl <- get_elixhauser_poa()

poa_required_conds <- 
  poa_tbl[["condition"]][poa_tbl[[method]] == 1L & poa_tbl$poa_required == 1L]

poa_not_required_conds <- 
  poa_tbl[["condition"]][poa_tbl[[method]] == 1L & poa_tbl$poa_required == 0L]

for (cn in poa_required_conds) {
  stopifnot(all(rtn[[cn]] == 0L))
}

for (cn in poa_not_required_conds) {
  x <- subset(rtn, condition == cn)
  stopifnot(all(x[[cn]] == 1L))
}
