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
library(data.table)

mdcr <- fread("mdcr.csv")
mdcr <- melt(mdcr
             , id.vars = c("patid", "icdv")
             , measure.vars = c("dx", "pr")
             , variable.name = "dxpr"
             , value.name = "code"
             , variable.factor = FALSE)
mdcr <- mdcr[code != ""]
mdcr[, dx := as.integer(dxpr == "dx")]
mdcr[, dxpr := NULL]

# generate random and unique patid
ids <- data.table(patid = unique(mdcr$patid))
ids[, patid2 := sample(10000:99999, size = .N)]

mdcr <- merge(mdcr, ids, by = "patid")
mdcr[, patid := patid2]
mdcr[, patid2 := NULL]

setDF(mdcr)
save(mdcr, file = "../../data/mdcr.rda")

################################################################################
#                                 End of File                                  #
################################################################################
