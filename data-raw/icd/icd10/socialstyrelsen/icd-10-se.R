
DT <- data.table::fread("icd-10-se.tsv")

# The file is in Swedish.  Translate column nmaes to English.
old2new <- c(
  "Kod"                                   = "full_code",
  "Giltig från"                           = "Valid from",
  "Överordnad kod"                        = "Superordinate code",
  "Titel"                                 = "Title",
  "Latin"                                 = "Latin",
  "Beskrivning"                           = "Description",
  "Exempel"                               = "Example",
  "Innefattar"                            = "Includes",
  "Utesluter"                             = "Excludes",
  "Anmärkning"                            = "Note",
  "Kodningsinformation"                   = "Coding information",
  "Innehåll"                              = "Contents",
  "Manifestation(*)/Etiologi(†)"          = "Manifestation(*)/Etiology(†)",
  "Koppling Manifestation(*)/Etiologi(†)" = "Link Manifestation(*)/Etiology(†)",
  "Ej huvuddiagnos"                       = "Not a main diagnosis",
  "Kodnivå - kodspecifikation"            = "Code level - code specification")
data.table::setnames(x = DT, old = names(old2new), new = old2new)


# DT[, .N, keyby = .(`Code level - code specification`)]
#
#                                                             Avsnittskod, kodintervall   Section code, code range
#                         Femställig kod för att ange frakturtyp (sex tecken med punkt)   Five-digit code to indicate fracture type (six characters with a period)
#                Femställig kod för att ange plats och aktivitet (sex tecken med punkt)   Five-digit code to indicate location and activity (six characters with a period)
#                             Femställig kod för att ange sårtyp (sex tecken med punkt)   Five-digit code to indicate wound type (six characters with period)
#  Femställig kod för att ange typ av respiratorisk insufficiens (sex tecken med punkt)   Five-digit code to indicate type of respiratory insufficiency (six characters with period)
#                                                                            Kapitelkod   Chapter code
#                                                               Kategorikod, treställig   Category code, three digits
#                                              Kategorikod, yttre orsakskod, treställig   Category code, external cause code, three-digit
#                          Nationell fördjupningskod, femställig (sex tecken med punkt)   National immersion code, five digits (six characters with a period)
#                                     Subkategorikod, fyrställig (fem tecken med punkt)   Subcategory code, four-digit (five characters with a period)
#                    Subkategorikod, yttre orsakskod, fyrställig (fem tecken med punkt)   Subcategory code, external cause code, four-digit (five characters with a period)
data.table::set(DT, j = "Code level - code specification", value = NULL)

# DT[, .N, keyby = .(`Not a main diagnosis`)]
# Key: <Not a main diagnosis>
#                                          Not a main diagnosis     N
#                                                        <char> <int>
# 1:                                                            57813
# 2: Denna kategori ska inte användas för att ange huvuddiagnos   317    This category should not be used to indicate a principal diagnosis
# 3:  Koder i denna kategori ska inte användas som huvuddiagnos    89    Codes in this category should not be used as a principal diagnosis
# 4:   Koder i detta avsnitt ska inte användas som huvuddiagnos    41    Codes in this section should not be used as a principal diagnosis
# 5:                         Ska inte användas som huvuddiagnos 24229    Not to be used as a principal diagnosis
data.table::set(DT, j = "Not a main diagnosis", value = NULL)

#DT[, .N, keyby = .(`Link Manifestation(*)/Etiology(†)`)]
#DT[, .N, keyby = .(`Manifestation(*)/Etiology(†)`)]
data.table::set(DT, j = "Link Manifestation(*)/Etiology(†)", value = NULL)
data.table::set(DT, j = "Manifestation(*)/Etiology(†)", value = NULL)

data.table::set(DT, j = "Contents", value = NULL)
data.table::set(DT, j = "Coding information", value = NULL)
data.table::set(DT, j = "Note", value = NULL)
data.table::set(DT, j = "Excludes", value = NULL)
data.table::set(DT, j = "Includes", value = NULL)
data.table::set(DT, j = "Example", value = NULL)
data.table::set(DT, j = "Latin", value = NULL)
data.table::set(DT, j = "Description", value = NULL)
data.table::set(DT, j = "Superordinate code", value = NULL)

DT <- DT[grepl("^\\D", full_code)][!grepl("^\\D\\d\\d-\\D\\d\\d", full_code)]
DT <- DT[!(duplicated(full_code) & is.na(`Valid from`) & Title == "")]
# There are about 3400 unique ICD-10-SE codes
# merge(
#   x =
#     DT[grepl("^\\D", full_code)][!grepl("^\\D\\d\\d-\\D\\d\\d", full_code)]
#   ,
#   y =
#     subset(medicalcoder::get_icd_codes(), icdv == 10 & dx == 1)
#   ,
#   all.x = TRUE,
#   by = "full_code",
# ) |>
# subset(is.na(known_start))

# To get the data into a format that will work with the rest of the work flow we
# will copy the data by year
DT[, year := data.table::year(`Valid from`)]
stopifnot(all(!is.na(DT[["year"]])))
data.table::set(x = DT, j = "Valid from", value = NULL)

sets <- list()
for (yr in 1997:2026) {
  i <- length(sets) + 1L
  sets[[i]] <- subset(DT, year <= yr)
  data.table::set(sets[[i]], j = "year", value = yr)
}

sets <- data.table::rbindlist(sets)

data.table::setDF(sets)
saveRDS(object = sets, file = "icd-10-se.rds")

