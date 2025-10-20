include ../../Makevars

YEARS := 2022 2023 2024 2025
INPUTDATA := $(foreach y,$(YEARS),$(y)/mdcr_for_sas_$(y).csv)

POAFLAG :=0

# SASODAPATH - these scripts are going to be evaluated in SAS Studio via SAS
# OnDemand for Academics (https://welcome.oda.sas.com/). Expect the path to look
# like /home/uXXXXXXXX where the uXXXXXXXX is your user id.
SASODAPATH ?=

SAS := 2022/CMR_Format_Program_v2022-1.sas 2022/CMR_Index_Program_v2022-1.sas 2022/CMR_Mapping_Program_v2022-1.sas
SAS += 2023/CMR_Format_Program_v2023-1.sas 2023/CMR_Index_Program_v2023-1.sas 2023/CMR_Mapping_Program_v2023-1.sas
SAS += 2024/CMR_Format_Program_v2024-1.sas 2024/CMR_Index_Program_v2024-1.sas 2024/CMR_Mapping_Program_v2024-1.sas
SAS += 2025/CMR_Format_Program_v2025-1.sas 2025/CMR_Index_Program_v2025-1.sas 2025/CMR_Mapping_Program_v2025-1.sas

.PHONY: all clean purge

all: $(SAS) $(INPUTDATA)

define build_one
$(1)/mdcr_for_sas_$(1).csv: prepare-mdcr-cmr.R
	@mkdir -p $$(@D)
	$(RSCRIPT) $$< $(1)
endef

$(foreach y,$(YEARS),$(eval $(call build_one,$(y))))

2022/CMR_%_Program_v2022-1.sas: ../../data-raw/elixhauser/ahrq/CMR_v2022-1.zip
	unzip -o $< $(@F) -d $(@D)
	sed "s|\(LIBNAME LIBRARY '\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2022\2|" $@ > $@.tmp1
	sed "s|\(LIBNAME[[:space:]]\{1,\}IN1[[:space:]]\{1,\}'\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2022\2|" $@.tmp1 > $@.tmp2
	sed "s|\(LIBNAME[[:space:]]\{1,\}OUT1[[:space:]]\{1,\}'\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2022\2|" $@.tmp2 > $@.tmp1
	if [ "$*" = "Mapping" ]; then \
		sed "s|\(POAPREFIX=\).*\(;\)|\1 \2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(NUMDX[[:space:]]*=\).*\(;\)|\141\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(POA[[:space:]]*=\).*\(;\)|\1$(POAFLAG)\2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1mdcr_for_sas_2022\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1mdcr_sas_result_2022\2|" $@.tmp1 > $@; \
		head -n 79 $@ > $@.tmp1; \
		echo "proc import datafile='$(SASODAPATH)/AHRQ2022/mdcr_for_sas_2022.csv'" >> $@.tmp1; \
		echo "  out=in1.mdcr_for_sas_2022" >> $@.tmp1; \
		echo "  dbms=csv replace;" >> $@.tmp1; \
		echo "  guessingrows=MAX;" >> $@.tmp1; \
		echo "run;" >> $@.tmp1; \
		tail -n +80 $@ > $@.tmp2; \
		echo "proc export data=out1.mdcr_sas_result_2022" >> $@.tmp2; \
		echo "  outfile='$(SASODAPATH)/AHRQ2022/mdcr_sas_result_2022.csv'" >> $@.tmp2; \
		echo "  dbms=csv replace;" >> $@.tmp2; \
		echo "run;" >> $@.tmp2; \
		cat $@.tmp1 $@.tmp2 > $@; \
		elif [ "$*" = "Index" ]; then \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1mdcr_sas_result_2022\2|" $@.tmp1 > $@.tmp2 \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1mdcr_sas_result_index_2022\2|" $@.tmp2 > $@; \
		echo "proc export data=out1.&OUT" >> $@; \
  	echo "outfile='$(SASODAPATH)/AHRQ2022/mdcr_sas_result_index_2022.csv'" >> $@; \
		echo "dbms=csv replace;" >> $@; \
		echo "run;" >> $@; \
		elif [ "$*" = "Format" ]; then \
		mv $@.tmp1 $@; \
		fi
	$(RM) $@.tmp1 $@.tmp2

2023/CMR_%_Program_v2023-1.sas: ../../data-raw/elixhauser/ahrq/CMR_v2023-1.zip
	unzip -o $< $(@F) -d $(@D)
	sed "s|\(LIBNAME LIBRARY '\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2023\2|" $@ > $@.tmp1
	sed "s|\(LIBNAME[[:space:]]\{1,\}IN1[[:space:]]\{1,\}'\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2023\2|" $@.tmp1 > $@.tmp2
	sed "s|\(LIBNAME[[:space:]]\{1,\}OUT1[[:space:]]\{1,\}'\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2023\2|" $@.tmp2 > $@.tmp1
	if [ "$*" = "Mapping" ]; then \
		sed "s|\(POAPREFIX=\).*\(;\)|\1 \2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(NUMDX[[:space:]]*=\).*\(;\)|\141\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(POA[[:space:]]*=\).*\(;\)|\1$(POAFLAG)\2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1mdcr_for_sas_2023\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1mdcr_sas_result_2023\2|" $@.tmp1 > $@; \
		head -n 79 $@ > $@.tmp1; \
		echo "proc import datafile='$(SASODAPATH)/AHRQ2023/mdcr_for_sas_2023.csv'" >> $@.tmp1; \
		echo "  out=in1.mdcr_for_sas_2023" >> $@.tmp1; \
		echo "  dbms=csv replace;" >> $@.tmp1; \
		echo "  guessingrows=MAX;" >> $@.tmp1; \
		echo "run;" >> $@.tmp1; \
		tail -n +80 $@ > $@.tmp2; \
		echo "proc export data=out1.mdcr_sas_result_2023" >> $@.tmp2; \
		echo "  outfile='$(SASODAPATH)/AHRQ2023/mdcr_sas_result_2023.csv'" >> $@.tmp2; \
		echo "  dbms=csv replace;" >> $@.tmp2; \
		echo "run;" >> $@.tmp2; \
		cat $@.tmp1 $@.tmp2 > $@; \
		elif [ "$*" = "Index" ]; then \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1mdcr_sas_result_2023\2|" $@.tmp1 > $@.tmp2 \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1mdcr_sas_result_index_2023\2|" $@.tmp2 > $@; \
		echo "proc export data=out1.&OUT" >> $@; \
  	echo "outfile='$(SASODAPATH)/AHRQ2023/mdcr_sas_result_index_2023.csv'" >> $@; \
		echo "dbms=csv replace;" >> $@; \
		echo "run;" >> $@; \
		elif [ "$*" = "Format" ]; then \
		mv $@.tmp1 $@; \
		fi
	$(RM) $@.tmp1 $@.tmp2

2024/CMR_%_Program_v2024-1.sas: ../../data-raw/elixhauser/ahrq/CMR_v2024-1.zip
	unzip -o $< $(@F) -d $(@D)
	sed "s|\(LIBNAME LIBRARY '\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2024\2|" $@ > $@.tmp1
	sed "s|\(LIBNAME[[:space:]]\{1,\}IN1[[:space:]]\{1,\}'\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2024\2|" $@.tmp1 > $@.tmp2
	sed "s|\(LIBNAME[[:space:]]\{1,\}OUT1[[:space:]]\{1,\}'\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2024\2|" $@.tmp2 > $@.tmp1
	if [ "$*" = "Mapping" ]; then \
		sed "s|\(POAPREFIX=\).*\(;\)|\1 \2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(NUMDX[[:space:]]*=\).*\(;\)|\141\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(POA[[:space:]]*=\).*\(;\)|\1$(POAFLAG)\2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1mdcr_for_sas_2024\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1mdcr_sas_result_2024\2|" $@.tmp1 > $@; \
		head -n 79 $@ > $@.tmp1; \
		echo "proc import datafile='$(SASODAPATH)/AHRQ2024/mdcr_for_sas_2024.csv'" >> $@.tmp1; \
		echo "  out=in1.mdcr_for_sas_2024" >> $@.tmp1; \
		echo "  dbms=csv replace;" >> $@.tmp1; \
		echo "  guessingrows=MAX;" >> $@.tmp1; \
		echo "run;" >> $@.tmp1; \
		tail -n +80 $@ > $@.tmp2; \
		echo "proc export data=out1.mdcr_sas_result_2024" >> $@.tmp2; \
		echo "  outfile='$(SASODAPATH)/AHRQ2024/mdcr_sas_result_2024.csv'" >> $@.tmp2; \
		echo "  dbms=csv replace;" >> $@.tmp2; \
		echo "run;" >> $@.tmp2; \
		cat $@.tmp1 $@.tmp2 > $@; \
		elif [ "$*" = "Index" ]; then \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1mdcr_sas_result_2024\2|" $@.tmp1 > $@.tmp2 \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1mdcr_sas_result_index_2024\2|" $@.tmp2 > $@; \
		echo "proc export data=out1.&OUT" >> $@; \
  	echo "outfile='$(SASODAPATH)/AHRQ2024/mdcr_sas_result_index_2024.csv'" >> $@; \
		echo "dbms=csv replace;" >> $@; \
		echo "run;" >> $@; \
		elif [ "$*" = "Format" ]; then \
		mv $@.tmp1 $@; \
		fi
	$(RM) $@.tmp1 $@.tmp2

2025/CMR_%_Program_v2025-1.sas: ../../data-raw/elixhauser/ahrq/CMR_v2025.1.zip
	unzip -jo $< CMR_v2025.1/$(@F) -d $(@D)
	sed "s|\(LIBNAME LIBRARY '\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2025\2|" $@ > $@.tmp1
	sed "s|\(LIBNAME[[:space:]]\{1,\}IN1[[:space:]]\{1,\}'\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2025\2|" $@.tmp1 > $@.tmp2
	sed "s|\(LIBNAME[[:space:]]\{1,\}OUT1[[:space:]]\{1,\}'\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2025\2|" $@.tmp2 > $@.tmp1
	if [ "$*" = "Mapping" ]; then \
		sed "s|\(POAPREFIX=\).*\(;\)|\1 \2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(NUMDX[[:space:]]*=\).*\(;\)|\141\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(POA[[:space:]]*=\).*\(;\)|\1$(POAFLAG)\2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1mdcr_for_sas_2025\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1mdcr_sas_result_2025\2|" $@.tmp1 > $@; \
		head -n 79 $@ > $@.tmp1; \
		echo "proc import datafile='$(SASODAPATH)/AHRQ2025/mdcr_for_sas_2025.csv'" >> $@.tmp1; \
		echo "  out=in1.mdcr_for_sas_2025" >> $@.tmp1; \
		echo "  dbms=csv replace;" >> $@.tmp1; \
		echo "  guessingrows=MAX;" >> $@.tmp1; \
		echo "run;" >> $@.tmp1; \
		tail -n +80 $@ > $@.tmp2; \
		echo "proc export data=out1.mdcr_sas_result_2025" >> $@.tmp2; \
		echo "  outfile='$(SASODAPATH)/AHRQ2025/mdcr_sas_result_2025.csv'" >> $@.tmp2; \
		echo "  dbms=csv replace;" >> $@.tmp2; \
		echo "run;" >> $@.tmp2; \
		cat $@.tmp1 $@.tmp2 > $@; \
		elif [ "$*" = "Index" ]; then \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1mdcr_sas_result_2025\2|" $@.tmp1 > $@.tmp2 \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1mdcr_sas_result_index_2025\2|" $@.tmp2 > $@; \
		echo "proc export data=out1.&OUT" >> $@; \
  	echo "outfile='$(SASODAPATH)/AHRQ2025/mdcr_sas_result_index_2025.csv'" >> $@; \
		echo "dbms=csv replace;" >> $@; \
		echo "run;" >> $@; \
		elif [ "$*" = "Format" ]; then \
		mv $@.tmp1 $@; \
		fi
	$(RM) $@.tmp1 $@.tmp2

clean:

purge: clean
	$(RM) -rf $(YEARS)


