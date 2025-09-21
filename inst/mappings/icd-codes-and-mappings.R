################################################################################
library(medicalcoder)
require(data.table)

################################################################################
# Helper functions
get_all_duplicates <- function(x, by = seq_along(x), ...) {
  duplicated(x, by = by, fromLast = FALSE, ...) | duplicated(x, by = by, fromLast = TRUE, ...)
}

compare_symbols_html <- function(x, y) {
  fcase(is.na(x) & is.na(y), "——",
        !is.na(x) & is.na(y), "✔—",
        is.na(x) & !is.na(y), "—✔",
        x == y, "✅",
        x != y, "❌")
}

################################################################################
# build an icd_codes data.table for use in the articles.  this will require one
# description per code
icd_codes <- get_icd_codes(with.description = TRUE)
setDT(icd_codes)

# retain the most recent description
icd_codes[, max_desc_end := max(desc_end), by = .(icdv, dx, full_code, code)]
icd_codes <- icd_codes[max_desc_end == desc_end]
icd_codes[, max_desc_end := NULL]

# retain cms if that is available along with another coding system
icd_codes[, srcs := length(unique(src)), by = .(icdv, dx, full_code, code)]
icd_codes[, cms := as.integer(any(src == "cms")), by = .(icdv, dx, full_code, code)]

icd_codes <-
  icd_codes[
    srcs == 1 |                              # just one source
    (srcs == 2 & cms == 1 & src == "cms") |  # more than one source - take CMS
    (srcs > 1 & cms == 0 & src == "cdc")     # more than one source, CMS not available, take CDC
  ]
icd_codes[, srcs := NULL]
icd_codes[, cms := NULL]

stopifnot(icd_codes[, .N, by = .(icdv, dx, full_code, code)][, all(N == 1)])
#icd_codes[, .N, by = .(icdv, dx, full_code, code)][N > 1]

icd_codes[, icdsystem := fcase(icdv ==  9 & dx == 0, "ICD-9-PCS",
                               icdv ==  9 & dx == 1, "ICD-9-CM",
                               icdv == 10 & dx == 0, "ICD-10-PCS",
                               icdv == 10 & dx == 1, "ICD-10-CM")]

stopifnot("No duplicated full codes" =
  icd_codes[get_all_duplicates(icd_codes, by = c("icdv", "dx", "full_code")), .N == 0L]
)
# icd_codes[get_all_duplicates(icd_codes, by = c("icdv", "dx", "full_code"))]

################################################################################
# pccc codes
#
# Add column with the conditions (subcondition) [flags] for use in reporting
pccc_codes <- get_pccc_codes()
setDT(pccc_codes)

# build the mapping row-wise
pccc_codes[,
           map := paste0(condition, " (", paste(sort(unique(subcondition)), collapse = ", "), ")"),
           by = .(icdv, dx, full_code, condition)]

pccc_codes <-
  melt(
    pccc_codes,
    id.vars = c("icdv", "dx", "full_code", "code", "map"),
    measure.vars = patterns("pccc"),
    variable.name = "method",
    variable.factor = FALSE
  )

pccc_codes <- pccc_codes[value == 1]
pccc_codes[, value := NULL]

pccc_codes[, map := paste(sort(unique(map)), collapse = "; ")
           , by = .(icdv, dx, full_code, method)]

pccc_codes <- unique(pccc_codes)

setnames(pccc_codes, old = "map", new = "condition")

################################################################################
# charlson codes
charlson_codes <- get_charlson_codes()
setDT(charlson_codes)

charlson_codes <-
  melt(
    charlson_codes,
    id.vars = c("icdv", "dx", "full_code", "code", "condition"),
    measure.vars = patterns("charlson"),
    variable.name = "method",
    variable.factor = FALSE
  )

charlson_codes <- charlson_codes[value == 1]
charlson_codes[, value := NULL]

charlson_codes[, condition := paste(sort(unique(condition)), collapse = "; ")
               , by = .(icdv, dx, full_code, method)]

charlson_codes <- unique(charlson_codes)

################################################################################
# elixhauser codes
elixhauser_codes <- get_elixhauser_codes()
setDT(elixhauser_codes)

elixhauser_codes <-
  melt(
    elixhauser_codes,
    id.vars = c("icdv", "dx", "full_code", "code", "condition"),
    measure.vars = patterns("elixhauser"),
    variable.name = "method",
    variable.factor = FALSE
  )

elixhauser_codes <- elixhauser_codes[value == 1]
elixhauser_codes[, value := NULL]

elixhauser_codes[, condition := paste(sort(unique(condition)), collapse = "; ")
                  , by = .(icdv, dx, full_code, method)]

elixhauser_codes <- unique(elixhauser_codes)

################################################################################
# All ICD codes and Mappings
mappings <-
  rbindlist(list(pccc_codes, charlson_codes, elixhauser_codes),
            use.names = TRUE)
mappings <-
  dcast(data = mappings,
        formula = icdv + dx + full_code + code ~ method,
        value.var = "condition")

mappings <-
  merge(x = icd_codes,
        y = mappings,
        all = TRUE,
        by = c("icdv", "dx", "full_code", "code"))

stopifnot("verify icdsystem and full_code are unique" =
  mappings[get_all_duplicates(mappings, by = c("icdsystem", "full_code"))][, .N == 0L]
)

################################################################################
# Add the Partial Equivalence Relations (PERs) for PCCC
PERS <- data.table::CJ(v2.0 = c(NA, LETTERS[1:5]),
                       v2.1 = c(NA, LETTERS[1:5]),
                       v3.0 = c(NA, LETTERS[1:5]),
                       v3.1 = c(NA, LETTERS[1:5]))
PERS[, v2.0_eq_v2.1 := (v2.0 == v2.1)]
PERS[, v2.0_eq_v3.0 := (v2.0 == v3.0)]
PERS[, v2.0_eq_v3.1 := (v2.0 == v3.1)]
PERS[, v2.1_eq_v3.0 := (v2.1 == v3.0)]
PERS[, v2.1_eq_v3.1 := (v2.1 == v3.1)]
PERS[, v3.0_eq_v3.1 := (v3.0 == v3.1)]
PERS[, v2.0_vs_v2.1 := compare_symbols_html(v2.0, v2.1)]
PERS[, v2.0_vs_v3.0 := compare_symbols_html(v2.0, v3.0)]
PERS[, v2.0_vs_v3.1 := compare_symbols_html(v2.0, v3.1)]
PERS[, v2.1_vs_v3.0 := compare_symbols_html(v2.1, v3.0)]
PERS[, v2.1_vs_v3.1 := compare_symbols_html(v2.1, v3.1)]
PERS[, v3.0_vs_v3.1 := compare_symbols_html(v3.0, v3.1)]

PERS <- PERS[, .N, keyby = .(v2.0_eq_v2.1, v2.0_eq_v3.0, v2.0_eq_v3.1, v2.1_eq_v3.0, v2.1_eq_v3.1, v3.0_eq_v3.1,
                             v2.0_vs_v2.1, v2.0_vs_v3.0, v2.0_vs_v3.1, v2.1_vs_v3.0, v2.1_vs_v3.1, v3.0_vs_v3.1)]

PERS <- PERS[, .SD, .SDcols = patterns("_vs_")]
PERS[, per := 1:.N]
PERS[1, per_desc := "[v2.0, v2.1, v3.0, v3.1]"]
PERS[2, per_desc := "[v2.0, v2.1, v3.0]; \\{v3.1\\}"]
PERS[3, per_desc := "[v2.0, v2.1, v3.1]; \\{v3.0\\}"]
PERS[4, per_desc := "[v2.0, v3.0, v3.1]; \\{v2.1\\}"]
PERS[5, per_desc := "[v2.1, v3.0, v3.1]; \\{v2.0\\}"]
PERS[6, per_desc := "[v2.0, v2.1]; \\{v3.0\\}; \\{v3.1\\}"]
PERS[7, per_desc := "[v2.0, v2.1]; \\{v3.0, v3.1\\}"]
PERS[8, per_desc := "[v2.0], \\{v2.1\\}; [v3.0]; \\{v3.1\\}"]
PERS[9, per_desc := "[v2.0, v3.0]; \\{v2.1, v3.1\\}"]
PERS[10, per_desc := "[v2.0, v3.1]; \\{v2.1\\}; \\{v3.0\\}"]
PERS[11, per_desc := "[v2.0]; \\{v2.1\\}; \\{v3.0\\}; \\{v3.1\\}"]
PERS[12, per_desc := "[v2.0]; \\{v2.1\\}; \\{v3.0, v3.1\\}"]
PERS[13, per_desc := "[v2.0]; \\{v2.1, v3.1\\}, \\{v3.0\\}"]
PERS[14, per_desc := "[v2.0, v3.1]; \\{v2.1, v3.0\\}"]
PERS[15, per_desc := "[v2.0]; \\{v2.1, v3.0\\}, \\{v3.1\\}"]
PERS[16, per_desc := "[v2.0]; \\{v2.1, v3.0, v3.1\\}"]
PERS[17, per_desc := "\\{v2.0\\}; [v2.1, v3.0], \\{v3.1\\}"]
PERS[18, per_desc := "\\{v2.0, v3.1\\}; [v2.1, v3.0]"]
PERS[19, per_desc := "\\{v2.0\\}; [v2.1, v3.1]; \\{v3.0\\}"]
PERS[20, per_desc := "\\{v2.0\\}; [v2.1], \\{v3.0\\}, \\{v3.1\\}"]
PERS[21, per_desc := "\\{v2.0\\}; [v2.1], \\{v3.0, v3.1\\}"]
PERS[22, per_desc := "\\{v2.0, v3.1\\}; [v2.1], \\{v3.0\\}"]
PERS[23, per_desc := "\\{v2.0, v3.0\\}; [v2.1, v3.1]"]
PERS[24, per_desc := "\\{v2.0, v3.0\\}; [v2.1]; \\{v3.1\\}"]
PERS[25, per_desc := "\\{v2.0, v3.0, v3.1\\}; [v2.1]"]
PERS[26, per_desc := "\\{v2.0\\}; \\{v2.1\\}; [v3.0, v3.1]"]
PERS[27, per_desc := "\\{v2.0\\}; \\{v2.1\\}; [v3.0], \\{v3.1\\}"]
PERS[28, per_desc := "\\{v2.0\\}; \\{v2.1, v3.1\\}; [v3.0]"]
PERS[29, per_desc := "\\{v2.0, v3.1\\}; \\{v2.1\\} [v3.0]"]
PERS[30, per_desc := "\\{v2.0\\}; \\{v2.1\\}; \\{v3.0\\}, [v3.1]"]
PERS[31, per_desc := "\\{v2.0\\}; \\{v2.1, v3.0\\}; [v3.1]"]
PERS[32, per_desc := "\\{v2.0\\}; \\{v2.1\\}; \\{v3.0\\}; \\{v3.1\\}"]
PERS[33, per_desc := "\\{v2.0\\}; \\{v2.1\\}; \\{v3.0, v3.1\\}"]
PERS[34, per_desc := "\\{v2.0\\}; \\{v2.1, v3.1\\}; \\{v3.0\\}"]
PERS[35, per_desc := "\\{v2.0\\}; \\{v2.1, v3.0\\}; \\{v3.1\\}"]
PERS[36, per_desc := "\\{v2.0\\}; \\{v2.1, v3.0, v3.1\\}"]
PERS[37, per_desc := "\\{v2.0, v3.1\\}; \\{v2.1\\}; \\{v3.0\\}"]
PERS[38, per_desc := "\\{v2.0, v3.1\\}, \\{v2.1, v3.0\\}"]
PERS[39, per_desc := "\\{v2.0, v3.0\\}, \\{v2.1\\}; [v3.1]"]
PERS[40, per_desc := "\\{v2.0, v3.0\\}; \\{v2.1\\}; \\{v3.1\\}"]
PERS[41, per_desc := "\\{v2.0, v3.0\\}; \\{v2.1, v3.1\\}"]
PERS[42, per_desc := "\\{v2.0, v3.0, v3.1\\}; \\{v2.1\\}"]
PERS[43, per_desc := "\\{v2.0, v2.1\\}, [v3.0, v3.1]"]
PERS[44, per_desc := "\\{v2.0, v2.1\\}; [v3.0]; \\{v3.1\\}"]
PERS[45, per_desc := "\\{v2.0, v2.1, v3.1\\}; [v3.0]"]
PERS[46, per_desc := "\\{v2.0, v2.1\\}; \\{v3.0\\}, [v3.1]"]
PERS[47, per_desc := "\\{v2.0, v2.1\\}; \\{v3.0\\}; \\{v3.1\\}"]
PERS[48, per_desc := "\\{v2.0, v2.1\\}; \\{v3.0, v3.1\\}"]
PERS[49, per_desc := "\\{v2.0, v2.1, v3.1\\}; \\{v3.0\\}"]
PERS[50, per_desc := "\\{v2.0, v2.1, v3.0\\}; [v3.1]"]
PERS[51, per_desc := "\\{v2.0, v2.1, v3.0\\}; \\{v3.1\\}"]
PERS[52, per_desc := "\\{v2.0, v2.1, v3.0, v3.1\\}"]

################################################################################
# which mappings are the same and which are different between the PCCC variants?
pccc_deltas <- mappings[, .(icdv, dx, full_code, code,
                            known_start, known_end,
                            assignable_start, assignable_end,
                            desc,
                            pccc_v3.1, pccc_v3.0, pccc_v2.1, pccc_v2.0)]

# Build the pairwise comparisons between the PCCC variants
pccc_deltas[, v2.0_eq_v2.1 := (pccc_v2.0 == pccc_v2.1)]
pccc_deltas[, v2.0_eq_v3.0 := (pccc_v2.0 == pccc_v3.0)]
pccc_deltas[, v2.0_eq_v3.1 := (pccc_v2.0 == pccc_v3.1)]
pccc_deltas[, v2.1_eq_v3.0 := (pccc_v2.1 == pccc_v3.0)]
pccc_deltas[, v2.1_eq_v3.1 := (pccc_v2.1 == pccc_v3.1)]
pccc_deltas[, v3.0_eq_v3.1 := (pccc_v3.0 == pccc_v3.1)]

pccc_deltas[, v2.0_vs_v2.1 := compare_symbols_html(pccc_v2.0, pccc_v2.1)]
pccc_deltas[, v2.0_vs_v3.0 := compare_symbols_html(pccc_v2.0, pccc_v3.0)]
pccc_deltas[, v2.0_vs_v3.1 := compare_symbols_html(pccc_v2.0, pccc_v3.1)]
pccc_deltas[, v2.1_vs_v3.0 := compare_symbols_html(pccc_v2.1, pccc_v3.0)]
pccc_deltas[, v2.1_vs_v3.1 := compare_symbols_html(pccc_v2.1, pccc_v3.1)]
pccc_deltas[, v3.0_vs_v3.1 := compare_symbols_html(pccc_v3.0, pccc_v3.1)]

pccc_deltas <-
  merge(pccc_deltas, PERS, all.x = TRUE, by = grep("_vs_", names(PERS), value = TRUE))

setcolorder(pccc_deltas,
            c("icdv", "dx", "full_code", "code",
              "known_start", "known_end",
              "assignable_start", "assignable_end",
              "desc",
              "pccc_v3.1", "pccc_v3.0", "pccc_v2.1", "pccc_v2.0",
              "per", "per_desc",
              "v2.0_vs_v2.1", "v2.0_vs_v3.0", "v2.0_vs_v3.1", "v2.1_vs_v3.0", "v2.1_vs_v3.1", "v3.0_vs_v3.1",
              "v2.0_eq_v2.1", "v2.0_eq_v3.0", "v2.0_eq_v3.1", "v2.1_eq_v3.0", "v2.1_eq_v3.1", "v3.0_eq_v3.1"))

pccc_pers <-
  pccc_deltas[, .(N = .N),
       keyby = .(per, per_desc,
                 v2.0_vs_v2.1, v2.0_vs_v3.0, v2.0_vs_v3.1, v2.1_vs_v3.0, v2.1_vs_v3.1, v3.0_vs_v3.1,
                 v2.0_eq_v2.1, v2.0_eq_v3.0, v2.0_eq_v3.1, v2.1_eq_v3.0, v2.1_eq_v3.1, v3.0_eq_v3.1)
       ]
pccc_pers <- merge(pccc_pers, PERS, all = TRUE, by = intersect(names(pccc_pers), names(PERS)))
pccc_pers[, N := nafill(N, fill = 0, type = "const")]

data.table::setcolorder(pccc_pers, c("per", "per_desc", "N"))
data.table::setorder(pccc_pers, -N, per)
stopifnot(nrow(pccc_pers) == 52L)

################################################################################
#                                 End of File                                  #
################################################################################
