# R Versions to test against
#
# CRAN only requires testing against oldrelease, current, and dev.
#
# R 3.5.x:
#    Pain to build in 2025; expecting curl 7; curl 8 exists and ./configure fails
#
# R 3.6.x:
#    Pain to build in 2025; expecting curl 7; curl 8 exists and ./configure fails
#
# R 4.0.x: ./configure fails:
#   checking if libcurl is version 7 and >= 7.28.0... 
#   configure: error: libcurl >= 7.28.0 library and headers are required with support for https
#  
# R 4.1.x:
#   checking if libcurl is version 7 and >= 7.28.0... no
#   configure: error: libcurl >= 7.28.0 library and headers are required with support for https
#
#
# libcurl 8 released March 2023 and will for for R 4.3.0+

VERSIONS :=
#VERSIONS += 3.5.0 3.5.1 3.5.2 3.5.3
#VERSIONS += 3.6.0 3.6.1 3.6.2 3.6.3
#VERSIONS += 4.0.0 4.0.1 4.0.2 4.0.3
#VERSIONS += 4.1.0 4.1.1 4.1.2 4.1.3
#VERSIONS += 4.2.0 4.2.1 4.2.2 4.2.3
VERSIONS += 4.3.0 4.3.1 4.3.2 4.3.3
VERSIONS += 4.4.0 4.4.1 4.4.2
VERSIONS += 4.5.0 4.5.1

TARBALLS := $(addprefix R-,$(addsuffix .tar.gz,$(VERSIONS)))
CONFIGURE_FILES := $(addsuffix /configure,$(addprefix R-,$(VERSIONS)))

.PHONY: all clean purge

all: $(CONFIGURE_FILES)

R-%.tar.gz: download_R_source.sh
	./$< $*

R-%/configure: R-%.tar.gz
	tar -xvf $<

clean:
	$(RM) $(TARBALLS)

purge: clean
	for v in $(VERSIONS); do\
		$(RM) -r R-$$v;\
	done
