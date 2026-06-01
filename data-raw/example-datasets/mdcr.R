################################################################################
# file: mdcr.R
#
# purpose: Build an example claims-like dataset (mdcr) for package examples by
#          reshaping wide dx/pr columns to long format and anonymizing patid.
#
# inputs:  mdcr.csv (columns include: patid, icdv, dx, pr)
#
# output:  ../../data/mdcr.rda (data.frame with columns: patid, icdv, dx, code)
#
# deps:    data.table (fread, melt); base R
#
# notes:   set.seed(42) ensures deterministic anonymized patid mapping.
#          Run from the directory containing mdcr.csv (e.g., data-raw/…).
#
# idempotent: yes (deterministic given mdcr.csv and the fixed seed)
#
################################################################################

set.seed(42)

mdcr <- data.table::fread("mdcr.csv")
mdcr <- data.table::melt(
    data = mdcr
  , id.vars = c("patid", "icdv")
  , measure.vars = c("dx", "pr")
  , variable.name = "dxpr"
  , value.name = "code"
  , variable.factor = FALSE
)
mdcr <- mdcr[code != ""]
mdcr[, dx := as.integer(dxpr == "dx")]
mdcr[, dxpr := NULL]

# generate random and unique patid
ids <- data.table::data.table(patid = unique(mdcr$patid))
ids[, patid2 := sample(10000:99999, size = .N)]

mdcr <- merge(mdcr, ids, by = "patid")
mdcr[, patid := patid2]
mdcr[, patid2 := NULL]

data.table::setDF(mdcr)
save(mdcr, file = "../../data/mdcr.rda", ascii = FALSE, version = 3, compress = "xz", compression_level = 9)

################################################################################
#                                 End of File                                  #
################################################################################
