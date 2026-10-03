# Contributing to medicalcoder

Thanks for your interest in improving `medicalcoder`. Bug reports,
documentation fixes, reproducible examples, and code contributions are
welcome. For substantial changes, open or comment on a GitHub issue
first so the scope and intended behavior can be discussed before
implementation.

## Development setup

Work from the package root. The package uses a `Makefile` to document
the development workflow; it requires GNU Make and an R installation.
The Makefile installs the development dependencies when needed and
builds a source package before checking it.

``` sh
make check
```

`make check` runs the routine package check. It includes the `data-raw`
make pipeline as a prerequisite, so generated package data are current
before the source tarball is built. Review changes to generated data
together with their source files and scripts under `data-raw/`.

Other useful targets are:

``` sh
make check-as-cran   # run R CMD check --as-cran
make check-extended  # include the slower extended tests
make site            # build the pkgdown site
```

Routine checks omit extended tests; run `make check-extended`
periodically and before changes that affect code mappings or regex
matching. The extended tests can take several minutes.

## Keep dependencies deliberate

`medicalcoder` aims to keep its dependency footprint small. This is part
of the design of the end-user API: dependencies affect installation,
availability, maintenance, and the environments where users can run the
package. The same care applies to development. Packages listed in
`Suggests` still add work for contributors and CI, even when they are
optional for end users.

Before adding a dependency, consider whether base R or a package already
used by `medicalcoder` can do the job clearly. A package should not be
added just because it is familiar or offers a convenient way to
implement one small task. When a new dependency seems warranted, explain
the benefit and consider its installation burden, maintenance, platform
support, and role (runtime, development, testing, or documentation).

The current development and documentation dependencies have these roles:

| DESCRIPTION entry | Why it is used |
|----|----|
| `data.table` (`Suggests`) | Optional fast path for `data.table` inputs, plus tests, vignettes, and data preparation scripts. The core API also works with base data frames without it. |
| `dplyr` (`Suggests`) | Optional tibble-aware data-frame operations in the package, and examples comparing or transforming results. |
| `tibble` (`Suggests`) | Tests and examples for tibble inputs and outputs; tibbles remain optional for package users. |
| `kableExtra` (`Suggests`) | Formats tables in the README and vignettes. |
| `knitr` (`Suggests`, `VignetteBuilder`) | Evaluates and renders README and vignette R Markdown content. |
| `R.utils` (`Suggests`) | Supports reading compressed input files in the benchmarking workflow alongside `data.table`; it is not needed by the end-user API. |
| `rmarkdown` (`Suggests`, `VignetteBuilder`) | Provides the HTML vignette rendering engine. |
| `tidyr` (`Suggests`) | Reshapes data in the PCCC transition vignette. |
| `pkgdown` (`Config/Needs/website`) | Builds the package website; it is not needed to install or use the package. |
| `comorbidity`, `multimorbidity`, `pccc` (`Config/Needs/website`) | Used by website articles that compare or demonstrate transitions from those packages. |
| `dplyr`, `tibble`, `tidyr` (`Config/Needs/website`) | Support code in website-only comparison and transition articles. |
| `DBI`, `RSQLite` (`Config/Needs/website`) | Run the MIMIC comparison SQL locally against an in-memory SQLite database. |

`Config/Needs/website` lists dependencies for building the website and
its articles. These packages are not dependencies of the installed
package. `Config/roxygen2/version` records the roxygen2 version used to
generate documentation; it is tool metadata rather than a package
dependency.

## Code, documentation, and data

- Follow the conventions of the surrounding code and keep changes
  focused.
- Add or update tests for behavior changes. The test groups and runner
  behavior are described in
  [`tests/README.md`](http://www.peteredewitt.com/medicalcoder/tests/README.md).
  Each test script runs in its own environment; use
  `skip_test("reason")` for a test that cannot run without an optional
  dependency. Do not call [`quit()`](https://rdrr.io/r/base/quit.html)
  from an individual test script.
- Update roxygen comments when exported behavior changes, then
  regenerate the help files as part of the package documentation
  workflow.
- If a change affects the README, edit `README.Rmd` and regenerate
  `README.md`.
- For generated ICD or comorbidity data, update the relevant `data-raw/`
  pipeline and retain source provenance and validation checks. Avoid
  hand edits to generated package data when the pipeline should produce
  the change.
- Add user-facing changes to `NEWS.md`.

## Before opening a pull request

Run the most relevant tests while developing, then run `make check`. Run
`make check-extended` when the change touches extended-test coverage.
Include the commands you ran and their results in the pull request
description. If a check could not be run, say why. Keep generated files
in sync with their source files and scripts, and avoid including local
build outputs or unrelated files.

## General references

- [CRAN Repository
  Policy](https://cran.r-project.org/web/packages/policies.html)
  describes requirements for packages distributed through CRAN.
