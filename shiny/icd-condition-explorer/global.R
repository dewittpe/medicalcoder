suppressPackageStartupMessages(
  {
    library(medicalcoder)
    library(data.table)
    library(shiny)
    library(shinydashboard)
    library(shinyBS)
    library(DT)
  }
)

icdcodes <- data.table::as.data.table(medicalcoder::get_icd_codes(with.descriptions = TRUE, with.hierarchy = TRUE))

# use a factor for chapter to key the ordering
chapters <- icdcodes[, unique(.SD), .SDcols = c("icdv", "dx", "chapter")]
icdcodes[, chapter := factor(chapter, levels = chapters$chapter)]

icdcodestable <- data.table::copy(icdcodes)
icdcodestable[, icdv := factor(icdv, levels = c(9, 10))]
icdcodestable[, dx := factor(dx, levels = c(0, 1))]
icdcodestable[, src := factor(src)]

comorbiditycodes <-
  data.table::rbindlist(
    list(
      data.table::as.data.table(medicalcoder::get_pccc_codes()),
      data.table::as.data.table(medicalcoder::get_charlson_codes()),
      data.table::as.data.table(medicalcoder::get_elixhauser_codes())
    ),
  use.names = TRUE,
  fill = TRUE
)

# format such that the conditions are listed in the columns for each family of
# comorbidities
comorbiditycodes <-
  data.table::melt(
    data = comorbiditycodes,
    id.vars = c("icdv", "dx", "full_code", "condition"),
    measure.vars = grep("^(pccc|charlson|elixhauser)_", names(comorbiditycodes)),
    na.rm = FALSE
  )
comorbiditycodes <- comorbiditycodes[value == 1]

comorbiditycodes <-
  data.table::dcast(
    data = comorbiditycodes,
    formula = icdv + dx + full_code ~ variable,
    fun.aggregate = function(x) { paste(sort(unique(x)), collapse = "; ") },
    value.var = "condition"
  )

comorbiditycodes <-
  merge(
    x = icdcodes[, unique(.SD), .SDcols = c("icdv", "dx", "full_code", "chapter", "subchapter", "category", "subcategory", "subclassification", "subsubclassification")],
    y = comorbiditycodes,
    all = TRUE,
    by = c("icdv", "dx", "full_code")
  )

# NA values in character vectors will be set to "--not applicable--"
for (j in c("chapter", "subchapter", "category", "subcategory", "subclassification", "subsubclassification")) {
  if (is.character(comorbiditycodes[[j]])) {
    i <- which(is.na(comorbiditycodes[[j]]))
    data.table::set(comorbiditycodes, i = i, j = j, value = "--not applicable--")
  }
  if (is.character(icdcodes[[j]])) {
    i <- which(is.na(icdcodes[[j]]))
    data.table::set(icdcodes, i = i, j = j, value = "--not applicable--")
  }
}

data.table::setkey(comorbiditycodes, icdv, dx, chapter, subchapter, category, subcategory, subclassification, subsubclassification)

pccc_conditions <- unique(medicalcoder::get_pccc_conditions()[, c("condition", "condition_label")])
pccc_conditions <- stats::setNames(pccc_conditions$condition, pccc_conditions$condition_label)

charlson_conditions <- unique(medicalcoder::get_charlson_index_scores()[, c("condition", "condition_description")])
charlson_conditions <- stats::setNames(charlson_conditions$condition, charlson_conditions$condition_description)

elixhauser_conditions <- unique(medicalcoder::get_elixhauser_index_scores()[, c("condition"), drop = FALSE])
elixhauser_conditions <- stats::setNames(elixhauser_conditions$condition, elixhauser_conditions$condition)
