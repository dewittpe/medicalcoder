include ../../../../Makevars

all: twelfth01.txt

twelfth01.txt: edition12part1.pdf
	pdftotext -f 4 -l 366 -layout $< $@.temp
	sed -E $(SED_INPLACE) '/^IHACPA ICD-10-AM — Chronicle Part 1: A00–T98, Z00–Z99 — First Edition to Twelfth Edition/d' $@.temp
	sed -E $(SED_INPLACE) '/^$$/d' $@.temp
	sed -E $(SED_INPLACE) '/^Appendix/d' $@.temp
	sed -E $(SED_INPLACE) 's/\x0c//g' $@.temp
	sed -E $(SED_INPLACE) -e ':a' -e 'N' -e '$$!ba' -e 's/\n {6,}/ /g' $@.temp
	$(RM) $@.temp.bak
	@mv $@.temp $@
	$(RM) $@.temp

clean:
	$(RM) *.txt
