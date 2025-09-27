include ../Makevars

USER_SHELL := $(shell echo $$SHELL)
SHELL := $(if $(USER_SHELL),$(USER_SHELL),/bin/bash)
.SHELLFLAGS := -lc

DOCKER ?= docker

V35 := 3.5.0 3.5.1 3.5.2 3.5.3
V36 := 3.6.0 3.6.1 3.6.2 3.6.3
V40 := 4.0.0 4.0.1 4.0.2 4.0.3 4.0.4 4.0.5
V41 := 4.1.0 4.1.1 4.1.2 4.1.3
V42 := 4.2.0 4.2.1 4.2.2 4.2.3
V43 := 4.3.0 4.3.1 4.3.2 4.3.3
V44 := 4.4.0 4.4.1 4.4.2
V45 := 4.5.0 4.5.1
LATEST := #latest
VERSIONS := $(V35) $(V36) $(V40) $(V41) $(V42) $(V43) $(V44) $(V45) $(LATEST)
WITHOUTSUGGESTS := $(addsuffix -without-suggests,$(VERSIONS))
WITHSUGGESTS := $(addsuffix -with-suggests,$(V44)) $(addsuffix -with-suggests,$(V45)) $(addsuffix -with-suggests,$(LATEST))

PKG_ROOT    := ..
PKG_VERSION := $(shell awk '/^Version:/{print $$2}' $(PKG_ROOT)/DESCRIPTION)
PKG_NAME    := $(shell awk '/^Package:/{print $$2}' $(PKG_ROOT)/DESCRIPTION)
TARBALL     := $(PKG_NAME)_$(PKG_VERSION).tar.gz

RVS := $(addprefix R-,$(WITHOUTSUGGESTS)) $(addprefix R-,$(WITHSUGGESTS))
CHECKS := $(addsuffix /$(PKG_NAME).Rcheck/00check.log,$(RVS))

.PHONY: all clean

all: README.md

$(TARBALL): $(PKG_ROOT)/$(TARBALL)
	cp $< $@

README.md: README.Rmd $(CHECKS)
	$(R) -q -e "knitr::knit('%<', output = '$@')"

R-%-without-suggests/$(PKG_NAME).Rcheck/00check.log: .images/R-%-without-suggests.stamp $(TARBALL)
	$(RM) -r R-$*-without-suggests
	mkdir -p R-$*-without-suggests
	$(DOCKER) run \
		-v "$$(PWD)":/work \
		--rm 	mdcr-$*-without-suggests \
		R CMD check --no-build-vignettes --ignore-vignettes --no-manual -o R-$*-without-suggests $(TARBALL) > R-$*-without-suggests/docker.log 2>&1

R-%-with-suggests/$(PKG_NAME).Rcheck/00check.log: .images/R-%-with-suggests.stamp $(TARBALL)
	$(RM) -r R-$*-with-suggests
	mkdir -p R-$*-with-suggests
	$(DOCKER) run \
		-v "$$(PWD)":/work \
		--rm 	mdcr-$*-with-suggests \
		R CMD check -o R-$*-with-suggests $(TARBALL) > R-$*-with-suggests/docker.log 2>&1

.images/R-%-without-suggests.stamp: docker/without-suggests/Dockerfile $(TARBALL) | .images
	$(DOCKER) info >/dev/null 2>&1 || { echo "$(DOCKER) is unavailable or the daemon cannot be reached"; exit 1; }
	$(DOCKER) build --build-arg R_TAG=$* -t mdcr-$*-without-suggests -f $< .
	@touch $@

.images/R-%-with-suggests.stamp: docker/with-suggests/Dockerfile $(TARBALL) | .images
	$(DOCKER) info >/dev/null 2>&1 || { echo "$(DOCKER) is unavailable or the daemon cannot be reached"; exit 1; }
	$(DOCKER) build --build-arg R_TAG=$* -t mdcr-$*-with-suggests -f $< .
	@touch $@

.images:
	mkdir -p .images

clean:
	$(RM) -r .images
	$(RM) -r $(RVS)
