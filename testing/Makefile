USER_SHELL := $(shell echo $$SHELL)
SHELL := $(if $(USER_SHELL),$(USER_SHELL),/bin/bash)
.SHELLFLAGS := -lc

CONTAINER ?= docker

V35 := 3.5.0 3.5.1 3.5.2 3.5.3
V36 := 3.6.0 3.6.1 3.6.2 3.6.3
V40 := 4.0.0 4.0.1 4.0.2 4.0.3 4.0.4 4.0.5
V41 := 4.1.0 4.1.1 4.1.2 4.1.3
V42 := 4.2.0 4.2.1 4.2.2 4.2.3
V43 := 4.3.0 4.3.1 4.3.2 4.3.3
V44 := 4.4.0 4.4.1 4.4.2
V45 := 4.5.0 4.5.1
LATEST := latest
VERSIONS := $(V35) $(V36) $(V40) $(V41) $(V42) $(V43) $(V44) $(V45) $(LATEST)

PKG_ROOT    := ..
PKG_VERSION := $(shell awk '/^Version:/{print $$2}' $(PKG_ROOT)/DESCRIPTION)
PKG_NAME    := $(shell awk '/^Package:/{print $$2}' $(PKG_ROOT)/DESCRIPTION)
TARBALL     := $(PKG_NAME)_$(PKG_VERSION).tar.gz

RVS := $(addprefix R-,$(VERSIONS))
CHECKS := $(addsuffix /$(PKG_NAME).Rcheck/00check.log,$(RVS))

.PHONY: all clean

all: $(CHECKS)

$(TARBALL): $(PKG_ROOT)/$(TARBALL)
	cp $< $@

R-%/$(PKG_NAME).Rcheck/00check.log: $(TARBALL)
	$(RM) -r R-$*
	mkdir -p R-$*
	$(CONTAINER) rm mdcr_$* || true;
	$(CONTAINER) info >/dev/null 2>&1 || { echo "$(CONTAINER) is unavailable or the daemon cannot be reached"; exit 1; }
	$(CONTAINER) pull r-base:$*
	$(CONTAINER) run \
		--name mdcr_$*\
		-v "$$(PWD)":/home/docker \
		-w /home/docker \
		-e _R_CHECK_FORCE_SUGGESTS_=false \
		r-base:$* \
		R CMD check --no-build-vignettes --ignore-vignettes --no-manual -o R-$* $(TARBALL)
	$(CONTAINER) rm mdcr_$*

clean:
	$(RM) -r $(RVS)
	for v in $(VERSIONS); do\
		$(CONTAINER) rm mdcr_$$v || true; \
	done
