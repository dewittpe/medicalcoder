################################################################################
# file: charlson_regex_for_package.R
#
# objective:
#
#   define regular expressions for mapping between ICD and Charlson
#   Comorbidities.
#
# IMPORTANT DESIGN CONSTRAINT:
#
#   The input files have regex patterns.  There are a lot of them.  The point is
#   to have patterns which are easy to audit against references.  To simplify
#   the computational work, we define more complex regex here for use in the
#   package.
#
# requirements:
#
# inputs:
#    ./regex_for_package.txt
#
# outpus:
#
#   ./charlson_regex.rds
#
################################################################################
regex_patterns <- data.table::fread("regex_for_package.txt", header=TRUE)

regex_patterns[,dummy:=1L]

regex_wide <-
  data.table::dcast(
  data=regex_patterns,
  formula=condition+icdv+dx+pattern~method,
  value.var="dummy",
  fill=0L
)


regex_wide[, quan2011 := quan2005]
for (j in names(regex_wide)) {
  if (!(j %in% c("icdv", "dx", "condition", "pattern"))) {
    data.table::setnames(regex_wide, old = j, new = paste0("charlson_", j))
  }
}

data.table::setDF(regex_wide)
saveRDS(regex_wide, "./charlson_regex.rds")

################################################################################
#                                 End of file                                  #
################################################################################
