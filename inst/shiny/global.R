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

data.table::setkey(comorbiditycodes, icdv, dx, chapter, subchapter, category, subcategory, subclassification, subsubclassification)

pccc_conditions <- unique(medicalcoder::get_pccc_conditions()[, c("condition", "condition_label")])
pccc_conditions <- stats::setNames(pccc_conditions$condition, pccc_conditions$condition_label)

