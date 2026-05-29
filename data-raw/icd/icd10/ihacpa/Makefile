include ../../../../Makevars

all: eleven.txt twelfth01.txt twelfth02.txt thirteenth01.txt thirteenth02.txt

eleven.txt: edition11.pdf
	pdftotext -f 2 -l 1272 -layout $< $@.temp
	sed -E $(SED_INPLACE) 's/\x0c//g' $@.temp
	sed -E $(SED_INPLACE) '/^\xC2\xA9/d' $@.temp
	sed -E $(SED_INPLACE) '/^ICD-10-AM Chronicle/d' $@.temp
	sed -E $(SED_INPLACE) '/^[[:blank:]]+Historical/d' $@.temp
	sed -E $(SED_INPLACE) '/^[[:blank:]]+ICD-10-AM/d' $@.temp
	sed -E $(SED_INPLACE) '/^Chapter/d' $@.temp
	sed -E $(SED_INPLACE) '/^Back to top/d' $@.temp
	sed -E $(SED_INPLACE) '/^[[:alnum:]][0-9][0-9](-|\xE2\x80\x93)[[:alnum:]]/d' $@.temp
	sed -E $(SED_INPLACE) 's/\xE2\x80\xA0//g' $@.temp
	sed -E $(SED_INPLACE) 's/\*//g' $@.temp
	sed -E $(SED_INPLACE) '/^$$/d' $@.temp
	sed -E $(SED_INPLACE) -e ':a' -e 'N' -e '$$!ba' -e 's/\n {6,}/ /g' $@.temp
	$(RM) $@.temp.bak
	@mv $@.temp $@
	$(RM) $@.temp

twelfth01.txt: edition12part1.pdf
	pdftotext -f 4 -l 366 -layout $< $@.temp
	sed -E $(SED_INPLACE) '/^IHACPA ICD-10-AM/d' $@.temp
	sed -E $(SED_INPLACE) '/^$$/d' $@.temp
	sed -E $(SED_INPLACE) '/^Appendix/d' $@.temp
	sed -E $(SED_INPLACE) 's/\x0c//g' $@.temp
	sed -E $(SED_INPLACE) -e ':a' -e 'N' -e '$$!ba' -e 's/\n {6,}/ /g' $@.temp
	sed -E $(SED_INPLACE) '/^Historical/d' $@.temp
	sed -E $(SED_INPLACE) '/^ICD-10-AM/d' $@.temp
	sed -E $(SED_INPLACE) '/^Chapter/d' $@.temp
	sed -E $(SED_INPLACE) 's/\xE2\x80\xA0//g' $@.temp
	sed -E $(SED_INPLACE) 's/\*//g' $@.temp
	sed -E $(SED_INPLACE) '/^[[:alnum:]][0-9][0-9](-|\xE2\x80\x93)[[:alnum:]]/d' $@.temp
	$(RM) $@.temp.bak
	@mv $@.temp $@
	$(RM) $@.temp

twelfth02.txt: edition12part2.pdf
	pdftotext -f 4 -l 366 -layout $< $@.temp
	sed -E $(SED_INPLACE) '/^IHACPA ICD-10-AM/d' $@.temp
	sed -E $(SED_INPLACE) '/^$$/d' $@.temp
	sed -E $(SED_INPLACE) '/^Appendix/d' $@.temp
	sed -E $(SED_INPLACE) 's/\x0c//g' $@.temp
	sed -E $(SED_INPLACE) 's/\xE2\x80\xA0//g' $@.temp
	sed -E $(SED_INPLACE) 's/\*//g' $@.temp
	sed -E $(SED_INPLACE) -e ':a' -e 'N' -e '$$!ba' -e 's/\n {6,}/ /g' $@.temp
	sed -E $(SED_INPLACE) '/^Historical/d' $@.temp
	sed -E $(SED_INPLACE) '/^ICD-10-AM/d' $@.temp
	sed -E $(SED_INPLACE) '/^Chapter/d' $@.temp
	sed -E $(SED_INPLACE) '/^[[:alnum:]][0-9][0-9](-|\xE2\x80\x93)[[:alnum:]]/d' $@.temp
	$(RM) $@.temp.bak
	@mv $@.temp $@
	$(RM) $@.temp

thirteenth01.txt: edition13part1.pdf
	pdftotext -f 5 -l 368 -layout $< $@.temp
	sed -E $(SED_INPLACE) '/^$$/d' $@.temp
	sed -E $(SED_INPLACE) '/^IHACPA ICD-10-AM/d' $@.temp
	sed -E $(SED_INPLACE) '/^Historical/d' $@.temp
	sed -E $(SED_INPLACE) '/^[[:alnum:]][0-9][0-9](-|\xE2\x80\x93)[[:alnum:]]/d' $@.temp
	sed -E $(SED_INPLACE) '/^Chapter/d' $@.temp
	sed -E $(SED_INPLACE) 's/\x0c//g' $@.temp
	sed -E $(SED_INPLACE) 's/\xE2\x80\xA0//g' $@.temp
	sed -E $(SED_INPLACE) 's/\*//g' $@.temp
	sed -E $(SED_INPLACE) '/^[[:blank:]]*OFFICIAL/d' $@.temp
	sed -E $(SED_INPLACE) -e ':a' -e 'N' -e '$$!ba' -e 's/\n {6,}/ /g' $@.temp
	$(RM) $@.temp.bak
	@mv $@.temp $@
	$(RM) $@.temp

thirteenth02.txt: edition13part2.pdf
	pdftotext -f 4 -l 841 -layout $< $@.temp
	sed -E $(SED_INPLACE) '/^$$/d' $@.temp
	sed -E $(SED_INPLACE) '/^IHACPA ICD-10-AM/d' $@.temp
	sed -E $(SED_INPLACE) 's/\x0c//g' $@.temp
	sed -E $(SED_INPLACE) '/^Historical/d' $@.temp
	sed -E $(SED_INPLACE) '/^[[:alnum:]][0-9][0-9](-|\xE2\x80\x93)[[:alnum:]]/d' $@.temp
	sed -E $(SED_INPLACE) '/^Chapter/d' $@.temp
	sed -E $(SED_INPLACE) 's/\xE2\x80\xA0//g' $@.temp
	sed -E $(SED_INPLACE) 's/\*//g' $@.temp
	sed -E $(SED_INPLACE) -e ':a' -e 'N' -e '$$!ba' -e 's/\n {6,}/ /g' $@.temp
	$(RM) $@.temp.bak
	@mv $@.temp $@
	$(RM) $@.temp

clean:
	$(RM) *.txt
