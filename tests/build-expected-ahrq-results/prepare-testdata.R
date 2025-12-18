################################################################################
# file: prepare-test-data.R
#
# Build a data set where all known ICD-10 diagnostic codes will be tested for
# comorbidities with POA = Y and POA = N in the AHRQ SAS code and the
# medicalcoder::comorbidities()
#
# Two important sets are generated.
#
# 1. All ICD-10 diagnostic codes - one code per patient
# 2. A randomly selected ICD-10 code for each pairwise set of comorbidities.
#    Elixhauser coding has severity and POA conditions where the presence of one
#    level may mask another.  Since all individual codes will be tested by the
#    first set, this set will test all the condition masking.
#
# These two sets are combined into one data set for the testing

################################################################################
library(data.table)
library(medicalcoder)
set.seed(42)

icdcodes <- as.data.table(get_icd_codes())
elxcodes <- as.data.table(get_elixhauser_codes())
icdcodes <- icdcodes[icdv == 10L & dx == 1L & !is.na(assignable_start), unique(code)]
x1 <-
  data.table::CJ(
    code = icdcodes,
    poa = c(0L, 1L)
  )
x1[, PATID := paste0("i", formatC(seq_len(.N), flag = "0", width = 5L, format = "d"))]

elxcodes <- elxcodes[icdv == 10L & dx == 1L]
elxcodes <- elxcodes[!is.na(elixhauser_ahrq_icd10)]

x <-
  data.table::CJ(
    cnd1 = c("notacnd", elxcodes[dx == 1 & icdv == 10, unique(condition)]),
    cnd2 = c("notacnd", elxcodes[dx == 1 & icdv == 10, unique(condition)]),
    poa1 = c(0L, 1L),
    poa2 = c(0L, 1L)
  )
x[, cnd1f := factor(cnd1)]
x[, cnd2f := factor(cnd2, levels = levels(cnd1f))]
x[, cnd1f := as.integer(cnd1f)]
x[, cnd2f := as.integer(cnd2f)]
x <- x[cnd1f <= cnd2f]
x[, PATID := paste0("p", formatC(1:.N, format = "d", flag = 0, width = 4L))]
x <- melt(
  x,
  id.vars = c("PATID", "poa1", "poa2"),
  measure.vars = c("cnd1", "cnd2"),
  value.name = "condition"
)
setkey(x, PATID)

x[, poa := fifelse(variable == "cnd1", poa1, poa2)]
x[, poa1 := NULL]
x[, poa2 := NULL]
x[, variable := NULL]

for (cnd in unique(x[["condition"]])) {
  idx <- which(x[["condition"]] == cnd)
  n <- length(idx)
  codes <- elxcodes[condition == cnd, code]
  rtn <-
    if (length(codes) > 0L) {
      sample(codes, size = n, replace = TRUE)
    } else {
      rep("icdcode", n)
    }
  data.table::set(x, i = idx, j = "code", value = rtn)
}

x[, condition := NULL]

testdata <- rbindlist(list(x1, x), use.names = TRUE, fill = TRUE)

# test that the data flows through
tic <- Sys.time()
  rtn <-
    comorbidities(
      data = testdata,
      id.vars = "PATID",
      icd.codes = "code",
      dx = 1L,
      icdv = 10L,
      poa.var = "poa",
      primarydx = 0L,
      method = "elixhauser_ahrq_icd10")
toc <- Sys.time()
difftime(toc, tic)

sas_testdata <- copy(testdata)
sas_testdata[, dummy := 1 + 1:.N, by = .(PATID)]
setnames(sas_testdata, old = "code", new = "I10_DX")
setnames(sas_testdata, old = "poa",  new = "DXPOA")
sas_testdata[PATID == "p0001"]
sas_testdata <-
  dcast(sas_testdata,
    PATID ~ dummy,
    value.var = list("I10_DX", "DXPOA"),
    sep = ""
  )
sas_testdata[, I10_DX1 := "acode"]
sas_testdata[, DXPOA1 := "Y"]
sas_testdata[, DXPOA2 := fifelse(DXPOA2 == 1, "Y", "N")]
sas_testdata[, DXPOA3 := fifelse(DXPOA3 == 1, "Y", "N")]

setcolorder(sas_testdata, c("PATID", "I10_DX1", "I10_DX2", "I10_DX3", "DXPOA1", "DXPOA2", "DXPOA3"))

fwrite(x = sas_testdata, file = "sas_testdata.csv")
fwrite(x = testdata, file = "testdata.csv")

################################################################################
#                                 End of File                                  #
################################################################################
