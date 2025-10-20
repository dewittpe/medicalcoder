include ../../../Makevars

# =============================================================================
# verify version of pandoc which is needed
# =============================================================================
# Compare versions using sort -V (GNU) or fallback awk (BSD/macOS)
PANDOC_VERSION := $(shell $(PANDOC) --version 2>/dev/null | head -n1 | awk '{print $$2}')

ifeq ($(PANDOC_VERSION),)
  $(error Pandoc not found; please install version $(PANDOC_MIN_VERSION) or newer)
endif

# Check if $(PANDOC_VERSION) < $(PANDOC_MIN_VERSION)
# sort -V works on GNU sort; on macOS you may need coreutils "gsort"
ifeq ($(shell printf '%s\n%s\n' $(PANDOC_MIN_VERSION) $(PANDOC_VERSION) | sort -V | head -n1),$(PANDOC_VERSION))
  ifneq ($(PANDOC_VERSION),$(PANDOC_MIN_VERSION))
    $(error Pandoc version $(PANDOC_VERSION) is too old; need >= $(PANDOC_MIN_VERSION))
  endif
endif

# =============================================================================
# =============================================================================
# The files lised in CMS_SOURCES are downloaded via download.sh
CMS_SOURCES := cms/cms_v32.zip cms/cms_v31.zip cms/cms_v30.zip cms/cms_v29.zip cms/cms_v28.zip cms/cms_v27.zip cms/cms_v26.zip cms/cms_v25.zip cms/cms_v24.zip cms/cms_v23.zip

# CDC Sources are RTF file and will be processed to plain text files.  The rtf
# files are aquired from runnig the download script
ICD9CMPATH := ./ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD9-CM

DTAB97_CHAPTERS := chap01.rtf chap02.rtf chap03.rtf chap04.rtf chap05.rtf chap06.rtf chap07.rtf chap08.rtf chap09.rtf chap10.rtf chap11.rtf chap12.rtf chap13.rtf chap14.rtf chap15.rtf chap16.rtf chap17.rtf vcodes.rtf ecodes.rtf
DTAB97_SOURCES := $(addprefix $(ICD9CMPATH)/1996/DISEASES/TABULAR/, $(DTAB97_CHAPTERS))
PTAB97_CHAPTERS := 01chap05.rtf 06chap10.rtf 11chap16.rtf
PTAB97_SOURCES := $(addprefix $(ICD9CMPATH)/1996/PROCED/TABULAR/, $(PTAB97_CHAPTERS))

#DTAB_ZIPS := $(ICD9CMPATH)/1997/dtab98.zip $(ICD9CMPATH)/1998/dtab99.zip $(ICD9CMPATH)/2000/dtab01.zip $(ICD9CMPATH)/2001/DTAB02.ZIP $(ICD9CMPATH)/2002/dtab03.zip $(ICD9CMPATH)/2003/Dtab04.zip $(ICD9CMPATH)/2004/DTAB05.zip $(ICD9CMPATH)/2005/Dtab06.zip $(ICD9CMPATH)/2006/Dtab07.zip $(ICD9CMPATH)/2007/Dtab08.zip $(ICD9CMPATH)/2008/Dtab09.zip $(ICD9CMPATH)/2009/Dtab10.zip $(ICD9CMPATH)/2010/DTAB11.zip $(ICD9CMPATH)/2011/Dtab12.zip

CDC_SOURCES := cdc/dtab97.txt cdc/dtab98.txt cdc/dtab99.txt cdc/dtab01.txt cdc/dtab02.txt cdc/dtab03.txt cdc/dtab04.txt cdc/dtab05.txt cdc/dtab06.txt cdc/dtab07.txt cdc/dtab08.txt cdc/dtab09.txt cdc/dtab10.txt cdc/dtab11.txt cdc/dtab12.txt cdc/ptab97.txt cdc/ptab98.txt cdc/ptab99.txt cdc/ptab01.txt cdc/ptab02.txt cdc/ptab03.txt cdc/ptab04.txt cdc/ptab05.txt cdc/ptab06.txt cdc/ptab07.txt cdc/ptab08.txt cdc/ptab09.txt cdc/ptab10.txt cdc/ptab11.txt cdc/ptab12.txt


################################################################################
# Funciton definitions
#
# clean_format_file
#
# remove some markdown formatting from text files
#
# * remove backslashes:
# * remove double asterisks.  the bolding was not consistent from year to year.
#   Yes, that means I'm losing some information, but the primary purpose for this
#   work is to be able to get the ICD codes out
# * remove any leading white space
# * replace two or more spaces with one space
# * replace tab with a space
# * Use nvim (neovim) to format all the paragraphs
#   nvim --headless +"set tw=20000" +"normal! ggVGgq" +wq $1
# * replaced use of nvim with awk for portability
define clean_format_file
	# Clean formatting in $1
	sed -E $(SED_INPLACE) \
		-e 's/\\//g' \
		-e 's/\*\*//g' \
		-e 's/^[[:space:]]+//' \
		-e 's/[[:space:]]{2,}/ /g' \
		-e 's/\t/ /g' \
		-e 's/\^//g' \
		$1
	awk 'BEGIN{RS=""; ORS="\n\n"} {gsub(/[ \t]+/," "); gsub(/\n+/," "); print}' "$1" > "$1.tmp" && mv "$1.tmp" "$1"; \
	$(RM) $1.bak
endef

# fix_rtf_escape
#
# Problem:
#   input RTF contains this line:
#
#      \par Littr\'e9's gland
#
#   Here’s what’s going on:
#
#   \'e9 is an RTF escape sequence for é, so Littr\'e9 should become Littré.
#
#   But the apostrophe in 's that follows immediately is being interpreted as
#   part of the escape sequence, which confuses the parser.
#
#   Pandoc expects valid RTF escape sequences like \'hh, where hh are
#   hexadecimal digits. In your case, it sees 's (which is invalid), hence the
#   error: unexpected 's'.
#
define fix_rtf_escape
	sed -E $(SED_INPLACE) 's/\\'\''(..)'\''s/\\'\''\1 ’s/g' $1
	$(RM) $1.bak
endef


################################################################################
.INTERMEDIATE: cdc.rds cms.rds

.PHONY: all clean

all: icd9_cm_pcs.rds

cms.rds: cms.R $(CMS_SOURCES)
	$(RSCRIPT) $<

cdc.rds: cdc.R $(CDC_SOURCES)
	$(RSCRIPT) $<

icd9_cm_pcs.rds: icd9_cm_pcs.R cms.rds cdc.rds
	$(RSCRIPT) $<

cdc/dtab97.txt: $(DTAB97_SOURCES)
	@mkdir -p cdc
	$(RM) $@
	# covert from rtf to markdown, save as .txt
	for file in $(DTAB97_SOURCES); do\
		outfile=$$(basename $$file);\
		echo the outfile: $$outfile;\
		$(PANDOC) $$file --to=markdown --output=$$outfile;\
		cat $$outfile >> $@;\
		$(RM) $$outfile;\
	done
	# remove the footnotes
	awk '\
		/^\[\^[0-9]{1,}\]:/ { skip=1; next } \
		skip && NF == 0 { skip=0; next } \
		skip { next } \
		{ print } \
		' $@ > tmp
	mv tmp $@
	sed -E $(SED_INPLACE) 's/\[\^[0-9]+\]//g' $@
	$(RM) $@.bak
	$(call clean_format_file,$@)

cdc/ptab97.txt: $(PTAB97_SOURCES)
	@mkdir -p cdc
	$(RM) $@
	# covert from rtf to markdown, save as .txt
	for file in $(PTAB97_SOURCES); do\
		outfile=$$(basename $$file);\
		echo the outfile: $$outfile;\
		$(PANDOC) $$file --to=markdown --output=$$outfile;\
		cat $$outfile >> $@;\
		$(RM) $$outfile;\
	done
	# remove the footnotes
	awk '\
		/^\[\^[0-9]{1,}\]:/ { skip=1; next } \
		skip && NF == 0 { skip=0; next } \
		skip { next } \
		{ print } \
		' $@ > tmp
	mv tmp $@
	sed -E $(SED_INPLACE) 's/\[\^[0-9]+\]//g' $@
	$(RM) $@.bak
	$(call clean_format_file,$@)

cdc/dtab98.txt: $(ICD9CMPATH)/1997/dtab98.zip
	unzip -jo $<
	$(call fix_rtf_escape,dtab98.rtf)
	$(PANDOC) dtab98.rtf --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) dtab98.rtf

cdc/dtab99.txt: $(ICD9CMPATH)/1998/dtab99.zip
	unzip -jo $<
	$(call fix_rtf_escape,dtab99.rtf)
	$(PANDOC) dtab99.rtf --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) dtab99.rtf

cdc/dtab01.txt: $(ICD9CMPATH)/2000/dtab01.zip
	unzip -jo $<
	$(call fix_rtf_escape,DTAB01.RTF)
	$(PANDOC) DTAB01.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) DTAB01.RTF

cdc/dtab02.txt: $(ICD9CMPATH)/2001/DTAB02.ZIP
	unzip -jo $<
	$(call fix_rtf_escape,Dtab02.RTF)
	$(PANDOC) Dtab02.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Dtab02.RTF

cdc/dtab03.txt: $(ICD9CMPATH)/2002/dtab03.zip
	unzip -jo $<
	$(call fix_rtf_escape,Dtab03.RTF)
	$(PANDOC) Dtab03.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Dtab03.RTF

cdc/dtab04.txt: $(ICD9CMPATH)/2003/Dtab04.zip
	unzip -jo $<
	$(call fix_rtf_escape,Dtab04.rtf)
	$(PANDOC) Dtab04.rtf --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Dtab04.rtf

cdc/dtab05.txt: $(ICD9CMPATH)/2004/DTAB05.zip
	unzip -jo $<
	$(call fix_rtf_escape,DTAB05.RTF)
	$(PANDOC) DTAB05.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) DTAB05.RTF

cdc/dtab06.txt: $(ICD9CMPATH)/2005/Dtab06.zip
	unzip -jo $<
	$(call fix_rtf_escape,Dtab06.rtf)
	$(PANDOC) Dtab06.rtf --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Dtab06.rtf

cdc/dtab07.txt: $(ICD9CMPATH)/2006/Dtab07.zip
	unzip -jo $<
	$(call fix_rtf_escape,Dtab07.RTF)
	$(PANDOC) Dtab07.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Dtab07.RTF

cdc/dtab08.txt: $(ICD9CMPATH)/2007/Dtab08.zip
	unzip -jo $<
	$(call fix_rtf_escape,Dtab08.RTF)
	$(PANDOC) Dtab08.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Dtab08.RTF

cdc/dtab09.txt: $(ICD9CMPATH)/2008/Dtab09.zip
	unzip -jo $<
	$(call fix_rtf_escape,Dtab09.RTF)
	$(PANDOC) Dtab09.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Dtab09.RTF

cdc/dtab10.txt: $(ICD9CMPATH)/2009/Dtab10.zip
	unzip -jo $<
	$(call fix_rtf_escape,Dtab10.RTF)
	$(PANDOC) Dtab10.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Dtab10.RTF

cdc/dtab11.txt: $(ICD9CMPATH)/2010/DTAB11.ZIP
	unzip -jo $<
	$(call fix_rtf_escape,DTAB11.RTF)
	$(PANDOC) DTAB11.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) DTAB11.RTF

cdc/dtab12.txt: $(ICD9CMPATH)/2011/Dtab12.zip
	unzip -jo $<
	$(call fix_rtf_escape,Dtab12.rtf)
	$(PANDOC) Dtab12.rtf --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Dtab12.rtf

cdc/ptab98.txt: $(ICD9CMPATH)/1997/ptab98.zip
	unzip -jo $<
	$(call fix_rtf_escape,ptab98.rtf)
	$(PANDOC) ptab98.rtf --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) ptab98.rtf

cdc/ptab99.txt: $(ICD9CMPATH)/1998/ptab99.zip
	unzip -jo $<
	$(PANDOC) ptab99.rtf --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) ptab99.rtf

cdc/ptab01.txt: $(ICD9CMPATH)/2000/ptab01.zip
	unzip -jo $<
	$(PANDOC) PTAB01.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) PTAB01.RTF

cdc/ptab02.txt: $(ICD9CMPATH)/2001/PTAB02.ZIP
	unzip -jo $<
	$(PANDOC) Ptab02.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Ptab02.RTF

cdc/ptab03.txt: $(ICD9CMPATH)/2002/ptab03.zip
	unzip -jo $<
	$(PANDOC) Ptab03.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Ptab03.RTF

cdc/ptab04.txt: $(ICD9CMPATH)/2003/Ptab04.zip
	unzip -jo $<
	$(PANDOC) Ptab04.rtf --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Ptab04.rtf

cdc/ptab05.txt: $(ICD9CMPATH)/2004/Ptab05.zip
	unzip -jo $<
	$(PANDOC) Ptab05.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Ptab05.RTF

cdc/ptab06.txt: $(ICD9CMPATH)/2005/Ptab06.zip
	unzip -jo $<
	$(PANDOC) Ptab06.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Ptab06.RTF

cdc/ptab07.txt: $(ICD9CMPATH)/2006/Ptab07.zip
	unzip -jo $<
	$(PANDOC) Ptab07.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Ptab07.RTF

cdc/ptab08.txt: $(ICD9CMPATH)/2007/Ptab08.zip
	unzip -jo $<
	$(PANDOC) Ptab08.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Ptab08.RTF

cdc/ptab09.txt: $(ICD9CMPATH)/2008/Ptab09.zip
	unzip -jo $<
	$(PANDOC) Ptab09.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Ptab09.RTF

cdc/ptab10.txt: $(ICD9CMPATH)/2009/Ptab10.zip
	unzip -jo $<
	$(PANDOC) Ptab10.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Ptab10.RTF

cdc/ptab11.txt: $(ICD9CMPATH)/2010/PTAB11.ZIP
	unzip -jo $<
	$(PANDOC) PTAB11.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) PTAB11.RTF

cdc/ptab12.txt: $(ICD9CMPATH)/2011/Ptab12.zip
	unzip -jo $<
	$(PANDOC) Ptab12.RTF --to=markdown --output=$@
	$(call clean_format_file,$@)
	$(RM) Ptab12.RTF

$(CMS_SOURCES) &: .download_stamp
	@test -e $@

$(ICD9CMPATH)/%: .download_stamp
	@test -e $@

.download_stamp : download.sh
	./download.sh
	@touch $@

clean:
	$(RM) *.rds

