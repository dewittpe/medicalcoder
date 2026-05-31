
DT <- data.table::fread("icd-10-se.tsv")

# The file is in Swedish.  Translate column nmaes to English.
old2new <- c(
  "Kod"                                   = "Code",
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



