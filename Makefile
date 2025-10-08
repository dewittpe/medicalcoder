include Makevars
# =============================================================================
# Config
# =============================================================================

PKG_ROOT    := $(CURDIR)
PKG_VERSION := $(shell awk '/^Version:/{print $$2}' $(PKG_ROOT)/DESCRIPTION)
PKG_NAME    := $(shell awk '/^Package:/{print $$2}' $(PKG_ROOT)/DESCRIPTION)

# Sources
RFILES     := $(wildcard $(PKG_ROOT)/R/*.R)
MANROXYGEN := $(wildcard $(PKG_ROOT)/man-roxygen/*.R)
TESTS      := $(wildcard $(PKG_ROOT)/tests/*.R)
EXAMPLES   := $(wildcard $(PKG_ROOT)/examples/*.R)
VIGNETTES  := $(wildcard $(PKG_ROOT)/vignettes/*.Rmd)
DATA       := $(PKG_ROOT)/data/mdcr.rda $(PKG_ROOT)/data/mdcr_longitudinal.rda $(PKG_ROOT)/R/sysdata.rda

TARBALL   := $(PKG_NAME)_$(PKG_VERSION).tar.gz

# =============================================================================
# Phony targets
# =============================================================================

.PHONY: all check check-as-cran install uninstall clean data-raw site covr

# =============================================================================
# Default
# =============================================================================

all:
	$(MAKE) data-raw    # ensure the internal data is up to date
	$(MAKE) $(TARBALL)  #

# =============================================================================
# Build the package
# =============================================================================

$(TARBALL): .install_dev_deps.Rout .document.Rout $(VIGNETTES) $(TESTS) $(DATA)
	$(R) CMD build --resave-data --md5 "$(PKG_ROOT)"

# Run data-raw with parallelism you can override
data-raw:
	$(MAKE) -C data-raw

# =============================================================================
# Dev deps & documentation stamps
# =============================================================================

# Install dev dependencies once; store console output in the stamp
.install_dev_deps.Rout: $(PKG_ROOT)/DESCRIPTION
	$(RSCRIPT) --quiet -e $(REPOS) \
	  -e "if (!requireNamespace('devtools', quietly=TRUE)) \
	       install.packages('devtools', repos='$(CRAN)')" \
	  -e "options(warn=2)" \
	  -e "devtools::install_dev_deps(pkg='$(PKG_ROOT)')" \
	  > $@ 2>&1

.document.Rout: $(RFILES) $(MANROXYGEN) $(EXAMPLES) $(PKG_ROOT)/DESCRIPTION $(PKG_ROOT)/README.md .install_dev_deps.Rout
	$(RSCRIPT) --quiet -e "options(warn=2)" \
	  -e "devtools::document('$(PKG_ROOT)')" \
	  > $@ 2>&1

# README depends on dev deps because it uses devtools::load_all()
$(PKG_ROOT)/README.md: $(PKG_ROOT)/README.Rmd .install_dev_deps.Rout benchmarking/outtable.rds
	$(RSCRIPT) -e "devtools::load_all('$(PKG_ROOT)')" \
	  -e "knitr::knit('$(PKG_ROOT)/README.Rmd', output='README.md')"

$(PKG_ROOT)/R/sysdata.rda:
	$(MAKE) -C data-raw ../R/sysdata.rda

# =============================================================================
# Check / Install
# =============================================================================

check: $(TARBALL) .install_dev_deps.Rout
	$(R) CMD check $(TARBALL)

check-as-cran: $(TARBALL) .install_dev_deps.Rout
	$(R) CMD check --as-cran $(TARBALL)

install: data-raw $(TARBALL)
	$(R) CMD INSTALL $(TARBALL)

uninstall:
	$(R) --quiet -e "try(remove.packages('$(PKG_NAME)'), silent=TRUE)"

# =============================================================================
# Coverage
# =============================================================================
COVR_TYPES_tests      := tests
COVR_TYPES_vignettes  := vignettes
COVR_TYPES_examples   := examples

covr-report-%.html: $(TARBALL) .install_dev_deps.Rout
	$(R) --quiet \
	  -e "x <- covr::package_coverage(type=c('$(COVR_TYPES_$*)'), function_exclusions = c(\".onLoad\"))" \
	  -e "covr::report(x, file='$@')"

covr: covr-report-tests.html covr-report-vignettes.html covr-report-examples.html

# =============================================================================
# Package down site
# =============================================================================

site: $(TARBALL) .install_dev_deps.Rout
	$(R) --quiet -e "pkgdown::build_site()"

# =============================================================================
# Clean
# =============================================================================

clean:
	$(RM) $(TARBALL)
	$(MAKE) -C data-raw clean
	$(RM) -r $(PKG_NAME).Rcheck
	$(RM) .*.Rout *.Rout
	$(RM) -r lib/*
	$(RM) -r doc/*
	$(RM) vignettes/*.html
	$(RM) *.html
