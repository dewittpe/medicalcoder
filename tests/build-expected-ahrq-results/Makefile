include ../../Makevars

YEARS := 2022 2023 2024 2025 2026
INPUTDATA := $(foreach y,$(YEARS),$(y)/sas_testdata_$(y).csv)

NUMDX := 12
POAFLAG :=1
POAPREFIX :=DXPOA

# SASODAPATH - these scripts are going to be evaluated in SAS Studio via SAS
# OnDemand for Academics (https://welcome.oda.sas.com/). Expect the path to look
# like /home/uXXXXXXXX where the uXXXXXXXX is your user id.
SASODAPATH ?=

SAS := 2022/CMR_Format_Program_v2022-1.sas 2022/CMR_Index_Program_v2022-1.sas 2022/CMR_Mapping_Program_v2022-1.sas
SAS += 2023/CMR_Format_Program_v2023-1.sas 2023/CMR_Index_Program_v2023-1.sas 2023/CMR_Mapping_Program_v2023-1.sas
SAS += 2024/CMR_Format_Program_v2024-1.sas 2024/CMR_Index_Program_v2024-1.sas 2024/CMR_Mapping_Program_v2024-1.sas
SAS += 2025/CMR_Format_Program_v2025-1.sas 2025/CMR_Index_Program_v2025-1.sas 2025/CMR_Mapping_Program_v2025-1.sas
SAS += 2026/CMR_Format_Program_v2026-1.sas 2026/CMR_Index_Program_v2026-1.sas 2026/CMR_Mapping_Program_v2026-1.sas

.PHONY: all clean purge

all: $(SAS) $(INPUTDATA)

define build_one
$(1)/sas_testdata_$(1).csv: sas_testdata.csv
	@mkdir -p $$(@D)
	$(R) -e "library(data.table)" \
		-e "sas_testdata <- fread(file = 'sas_testdata.csv')" \
		-e "set(sas_testdata, j = 'YEAR', value = $(1))" \
		-e "set(sas_testdata, j = 'DQTR', value = 4L)" \
		-e "setcolorder(sas_testdata, c('PATID', 'YEAR', 'DQTR'))"\
		-e "fwrite(x = sas_testdata, file = '$$@')"
endef

$(foreach y,$(YEARS),$(eval $(call build_one,$(y))))

sas_testdata.csv: prepare-test-data.R
	$(RSCRIPT) $<

2022/CMR_%_Program_v2022-1.sas: ../../data-raw/elixhauser/ahrq/CMR_v2022-1.zip
	unzip -o $< $(@F) -d $(@D)
	sed "s|\(LIBNAME LIBRARY '\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2022\2|" $@ > $@.tmp1
	sed "s|\(LIBNAME[[:space:]]\{1,\}IN1[[:space:]]\{1,\}'\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2022\2|" $@.tmp1 > $@.tmp2
	sed "s|\(LIBNAME[[:space:]]\{1,\}OUT1[[:space:]]\{1,\}'\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2022\2|" $@.tmp2 > $@.tmp1
	if [ "$*" = "Mapping" ]; then \
		sed "s|\(POAPREFIX=\).*\(;\)|\1$(POAPREFIX)\2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(NUMDX[[:space:]]*=\).*\(;\)|\1$(NUMDX)\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(\sPOA[[:space:]]*=\).*\(;\)|\1$(POAFLAG)\2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1sas_testdata_2022\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1sas_result_2022\2|" $@.tmp1 > $@; \
		head -n 79 $@ > $@.tmp1; \
		echo "proc import datafile='$(SASODAPATH)/AHRQ2022/sas_testdata_2022.csv'" >> $@.tmp1; \
		echo "  out=in1.sas_testdata_2022" >> $@.tmp1; \
		echo "  dbms=csv replace;" >> $@.tmp1; \
		echo "  guessingrows=MAX;" >> $@.tmp1; \
		echo "run;" >> $@.tmp1; \
		tail -n +80 $@ > $@.tmp2; \
		echo "proc export data=out1.sas_result_2022" >> $@.tmp2; \
		echo "  outfile='$(SASODAPATH)/AHRQ2022/sas_result_2022.csv'" >> $@.tmp2; \
		echo "  dbms=csv replace;" >> $@.tmp2; \
		echo "run;" >> $@.tmp2; \
		cat $@.tmp1 $@.tmp2 > $@; \
		elif [ "$*" = "Index" ]; then \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1sas_result_2022\2|" $@.tmp1 > $@.tmp2 \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1sas_result_index_2022\2|" $@.tmp2 > $@; \
		echo "proc export data=out1.&OUT" >> $@; \
  	echo "outfile='$(SASODAPATH)/AHRQ2022/sas_result_index_2022.csv'" >> $@; \
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
		sed "s|\(POAPREFIX=\).*\(;\)|\1$(POAPREFIX)\2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(NUMDX[[:space:]]*=\).*\(;\)|\1$(NUMDX)\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(\sPOA[[:space:]]*=\).*\(;\)|\1$(POAFLAG)\2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1sas_testdata_2023\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1sas_result_2023\2|" $@.tmp1 > $@; \
		head -n 79 $@ > $@.tmp1; \
		echo "proc import datafile='$(SASODAPATH)/AHRQ2023/sas_testdata_2023.csv'" >> $@.tmp1; \
		echo "  out=in1.sas_testdata_2023" >> $@.tmp1; \
		echo "  dbms=csv replace;" >> $@.tmp1; \
		echo "  guessingrows=MAX;" >> $@.tmp1; \
		echo "run;" >> $@.tmp1; \
		tail -n +80 $@ > $@.tmp2; \
		echo "proc export data=out1.sas_result_2023" >> $@.tmp2; \
		echo "  outfile='$(SASODAPATH)/AHRQ2023/sas_result_2023.csv'" >> $@.tmp2; \
		echo "  dbms=csv replace;" >> $@.tmp2; \
		echo "run;" >> $@.tmp2; \
		cat $@.tmp1 $@.tmp2 > $@; \
		elif [ "$*" = "Index" ]; then \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1sas_result_2023\2|" $@.tmp1 > $@.tmp2 \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1sas_result_index_2023\2|" $@.tmp2 > $@; \
		echo "proc export data=out1.&OUT" >> $@; \
  	echo "outfile='$(SASODAPATH)/AHRQ2023/sas_result_index_2023.csv'" >> $@; \
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
		sed "s|\(POAPREFIX=\).*\(;\)|\1$(POAPREFIX)\2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(NUMDX[[:space:]]*=\).*\(;\)|\1$(NUMDX)\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(\sPOA[[:space:]]*=\).*\(;\)|\1$(POAFLAG)\2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1sas_testdata_2024\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1sas_result_2024\2|" $@.tmp1 > $@; \
		head -n 79 $@ > $@.tmp1; \
		echo "proc import datafile='$(SASODAPATH)/AHRQ2024/sas_testdata_2024.csv'" >> $@.tmp1; \
		echo "  out=in1.sas_testdata_2024" >> $@.tmp1; \
		echo "  dbms=csv replace;" >> $@.tmp1; \
		echo "  guessingrows=MAX;" >> $@.tmp1; \
		echo "run;" >> $@.tmp1; \
		tail -n +80 $@ > $@.tmp2; \
		echo "proc export data=out1.sas_result_2024" >> $@.tmp2; \
		echo "  outfile='$(SASODAPATH)/AHRQ2024/sas_result_2024.csv'" >> $@.tmp2; \
		echo "  dbms=csv replace;" >> $@.tmp2; \
		echo "run;" >> $@.tmp2; \
		cat $@.tmp1 $@.tmp2 > $@; \
		elif [ "$*" = "Index" ]; then \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1sas_result_2024\2|" $@.tmp1 > $@.tmp2 \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1sas_result_index_2024\2|" $@.tmp2 > $@; \
		echo "proc export data=out1.&OUT" >> $@; \
  	echo "outfile='$(SASODAPATH)/AHRQ2024/sas_result_index_2024.csv'" >> $@; \
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
		sed "s|\(POAPREFIX=\).*\(;\)|\1$(POAPREFIX)\2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(NUMDX[[:space:]]*=\).*\(;\)|\1$(NUMDX)\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(\sPOA[[:space:]]*=\).*\(;\)|\1$(POAFLAG)\2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1sas_testdata_2025\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1sas_result_2025\2|" $@.tmp1 > $@; \
		head -n 79 $@ > $@.tmp1; \
		echo "proc import datafile='$(SASODAPATH)/AHRQ2025/sas_testdata_2025.csv'" >> $@.tmp1; \
		echo "  out=in1.sas_testdata_2025" >> $@.tmp1; \
		echo "  dbms=csv replace;" >> $@.tmp1; \
		echo "  guessingrows=MAX;" >> $@.tmp1; \
		echo "run;" >> $@.tmp1; \
		tail -n +80 $@ > $@.tmp2; \
		echo "proc export data=out1.sas_result_2025" >> $@.tmp2; \
		echo "  outfile='$(SASODAPATH)/AHRQ2025/sas_result_2025.csv'" >> $@.tmp2; \
		echo "  dbms=csv replace;" >> $@.tmp2; \
		echo "run;" >> $@.tmp2; \
		cat $@.tmp1 $@.tmp2 > $@; \
		elif [ "$*" = "Index" ]; then \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1sas_result_2025\2|" $@.tmp1 > $@.tmp2 \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1sas_result_index_2025\2|" $@.tmp2 > $@; \
		echo "proc export data=out1.&OUT" >> $@; \
  	echo "outfile='$(SASODAPATH)/AHRQ2025/sas_result_index_2025.csv'" >> $@; \
		echo "dbms=csv replace;" >> $@; \
		echo "run;" >> $@; \
		elif [ "$*" = "Format" ]; then \
		mv $@.tmp1 $@; \
		fi
	$(RM) $@.tmp1 $@.tmp2

2026/CMR_%_Program_v2026-1.sas: ../../data-raw/elixhauser/ahrq/CMR-v2026-1.zip
	unzip -jo $< $(@F) -d $(@D)
	sed "s|\(LIBNAME LIBRARY '\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2026\2|" $@ > $@.tmp1
	sed "s|\(LIBNAME[[:space:]]\{1,\}IN1[[:space:]]\{1,\}'\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2026\2|" $@.tmp1 > $@.tmp2
	sed "s|\(LIBNAME[[:space:]]\{1,\}OUT1[[:space:]]\{1,\}'\)[^']*\('.*\)|\1$(SASODAPATH)/AHRQ2026\2|" $@.tmp2 > $@.tmp1
	if [ "$*" = "Mapping" ]; then \
		sed "s|\(POAPREFIX=\).*\(;\)|\1$(POAPREFIX)\2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(NUMDX[[:space:]]*=\).*\(;\)|\1$(NUMDX)\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(\sPOA[[:space:]]*=\).*\(;\)|\1$(POAFLAG)\2|" $@.tmp1 > $@.tmp2; \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1sas_testdata_2026\2|" $@.tmp2 > $@.tmp1; \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1sas_result_2026\2|" $@.tmp1 > $@; \
		head -n 79 $@ > $@.tmp1; \
		echo "proc import datafile='$(SASODAPATH)/AHRQ2026/sas_testdata_2026.csv'" >> $@.tmp1; \
		echo "  out=in1.sas_testdata_2026" >> $@.tmp1; \
		echo "  dbms=csv replace;" >> $@.tmp1; \
		echo "  guessingrows=MAX;" >> $@.tmp1; \
		echo "run;" >> $@.tmp1; \
		tail -n +80 $@ > $@.tmp2; \
		echo "proc export data=out1.sas_result_2026" >> $@.tmp2; \
		echo "  outfile='$(SASODAPATH)/AHRQ2026/sas_result_2026.csv'" >> $@.tmp2; \
		echo "  dbms=csv replace;" >> $@.tmp2; \
		echo "run;" >> $@.tmp2; \
		cat $@.tmp1 $@.tmp2 > $@; \
		elif [ "$*" = "Index" ]; then \
		sed "s|\(CORE[[:space:]]*=\).*\(;\)|\1sas_result_2026\2|" $@.tmp1 > $@.tmp2 \
		sed "s|\(OUT[[:space:]]*=\).*\(;\)|\1sas_result_index_2026\2|" $@.tmp2 > $@; \
		echo "proc export data=out1.&OUT" >> $@; \
  	echo "outfile='$(SASODAPATH)/AHRQ2026/sas_result_index_2026.csv'" >> $@; \
		echo "dbms=csv replace;" >> $@; \
		echo "run;" >> $@; \
		elif [ "$*" = "Format" ]; then \
		mv $@.tmp1 $@; \
		fi
	$(RM) $@.tmp1 $@.tmp2

clean:

purge: clean
	$(RM) -r $(YEARS)

