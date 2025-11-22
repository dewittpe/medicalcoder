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
V45 := 4.5.0 4.5.1 4.5.2
LATEST := #latest
VERSIONS := $(V35) $(V36) $(V40) $(V41) $(V42) $(V43) $(V44) $(V45) $(LATEST)
WITHOUTSUGGESTS := $(addsuffix -without-suggests,$(VERSIONS))
# Limit with-suggests to R versions whose base OS is still supported (roughly Debian >= bullseye/R 4.1+).
WITHSUGGESTS := $(addsuffix -with-suggests,$(V41) $(V42) $(V43) $(V44) $(V45) $(LATEST))

# CRAN snapshots: use the date the *next* R release occurred. Empty means "current".
SNAP_4.4.2 :=
SNAP_4.4.1 := 2024-10-31
SNAP_4.4.0 := 2024-06-14
SNAP_4.3.3 := 2024-04-24
SNAP_4.3.2 := 2024-02-29
SNAP_4.3.1 := 2023-10-31
SNAP_4.3.0 := 2023-06-16
SNAP_4.2.3 := 2023-04-21
SNAP_4.2.2 := 2023-03-15
SNAP_4.2.1 := 2022-10-31
SNAP_4.2.0 := 2022-06-23
SNAP_4.1.3 := 2022-04-22
SNAP_4.1.2 := 2022-03-10
SNAP_4.1.1 := 2021-11-01
SNAP_4.1.0 := 2021-08-10
SNAP_4.0.5 := 2021-05-18
SNAP_4.0.4 := 2021-03-31
SNAP_4.0.3 := 2021-02-15
SNAP_4.0.2 := 2020-10-10
SNAP_4.0.1 := 2020-06-22
SNAP_4.0.0 := 2020-06-06
SNAP_3.6.3 := 2020-04-24
SNAP_3.6.2 := 2020-02-29
SNAP_3.6.1 := 2019-12-12
SNAP_3.6.0 := 2019-07-05
SNAP_3.5.3 := 2019-04-26
SNAP_3.5.2 := 2019-03-11
SNAP_3.5.1 := 2018-12-20
SNAP_3.5.0 := 2018-07-02
# 4.5.x snapshots default to "current" until next releases occur.

snapshot_arg = $(if $(SNAP_$1),--build-arg SNAPSHOT=$(SNAP_$1),)

PKG_ROOT    := ..
PKG_VERSION := $(shell awk '/^Version:/{print $$2}' $(PKG_ROOT)/DESCRIPTION)
PKG_NAME    := $(shell awk '/^Package:/{print $$2}' $(PKG_ROOT)/DESCRIPTION)
TARBALL     := $(PKG_NAME)_$(PKG_VERSION).tar.gz

RVS := $(addprefix R-,$(WITHOUTSUGGESTS)) $(addprefix R-,$(WITHSUGGESTS))
CHECKS := $(addsuffix /$(PKG_NAME).Rcheck/00check.log,$(RVS))

.PRECIOUS: $(CHECKS)

.PHONY: all clean

all: README.md

$(TARBALL): $(PKG_ROOT)/$(TARBALL)
	cp $< $@

README.md: README.Rmd $(CHECKS)
	$(R) -q -e "knitr::knit('$<', output = '$@')"

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
	$(DOCKER) build --build-arg R_TAG=$* $(call snapshot_arg,$*) -t mdcr-$*-with-suggests -f $< .
	@touch $@

.images:
	mkdir -p .images

clean:
	$(RM) -r .images
	$(RM) -r $(RVS)
