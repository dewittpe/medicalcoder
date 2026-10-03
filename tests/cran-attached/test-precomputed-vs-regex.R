################################################################################
# CRAN-safe smoke tests for the user-facing regex mapping path.

smoke_data <-
  data.frame(
    id = c("p1", "p2"),
    code = c("I50.9", "C78.4"),
    icdv = c(10L, 10L),
    dx = c(1L, 1L),
    stringsAsFactors = FALSE
  )

smoke_args <-
  list(
    data = smoke_data,
    id.vars = "id",
    icd.codes = "code",
    icdv.var = "icdv",
    dx.var = "dx",
    poa = 1L,
    primarydx = 0L,
    method = "charlson_quan2011"
  )

smoke_precomputed <-
  do.call(
    comorbidities,
    c(smoke_args, list(mapping = "precomputed"))
  )

smoke_regex <-
  do.call(
    comorbidities,
    c(smoke_args, list(mapping = "regex"))
  )

stopifnot(
  identical(smoke_regex, smoke_precomputed),
  smoke_regex[["chf"]][smoke_regex[["id"]] == "p1"] == 1L,
  smoke_regex[["mst"]][smoke_regex[["id"]] == "p2"] == 1L
)

unsupported_pccc <-
  tryCatchError(
    comorbidities(
      data = smoke_data,
      id.vars = "id",
      icd.codes = "code",
      icdv.var = "icdv",
      dx.var = "dx",
      poa = 1L,
      method = "pccc_v3.1",
      mapping = "regex"
    )
  )

unsupported_elixhauser <-
  tryCatchError(
    comorbidities(
      data = smoke_data,
      id.vars = "id",
      icd.codes = "code",
      icdv.var = "icdv",
      dx.var = "dx",
      poa = 1L,
      primarydx = 0L,
      method = "elixhauser_ahrq2025",
      mapping = "regex"
    )
  )

unsupported_beyrer <-
  tryCatchError(
    comorbidities(
      data = smoke_data,
      id.vars = "id",
      icd.codes = "code",
      icdv.var = "icdv",
      dx.var = "dx",
      poa = 1L,
      primarydx = 0L,
      method = "charlson_beyrer2021",
      mapping = "regex"
    )
  )

stopifnot(
  inherits(unsupported_pccc, "error"),
  unsupported_pccc[["message"]] == 'mapping = "regex" for PCCC methods has not yet been implemented',
  inherits(unsupported_elixhauser, "error"),
  unsupported_elixhauser[["message"]] == 'mapping = "regex" for Elixhauser methods has not yet been implemented',
  inherits(unsupported_beyrer, "error"),
  unsupported_beyrer[["message"]] == "method = 'charlson_beyrer2021' does not have a regex variant.  Exact ICD codes only to be consistent with the publication."
)
