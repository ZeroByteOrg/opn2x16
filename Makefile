VGM2ZSM	= ./vgm2zsm
VGMS	:= $(wildcard ./ost/*.vgm)
ZSMR38	:= $(patsubst ./ost/%.vgm,./zsm38/%.zsm,$(VGMS))
ZSMR39	:= $(patsubst ./ost/%.vgm,./zsm39/%.zsm,$(VGMS))
ZSMS	:= $(ZSMR38) $(ZSMR39)
ZIPFILE	:= citycon_zsm.zip

zsms: $(ZSMS)

.PHONY: $(ZSM2VGM)
$(VGM2ZSM):

.PHONY: %.zsm
%.zsm: ost/%.vgm
	make ./zsm38/$@
	make ./zsm39/$@

./zsm38/%.zsm: ./ost/%.vgm $(VGM2ZSM)
	$(VGM2ZSM) -4 $< $@

./zsm39/%.zsm: ./ost/%.vgm $(VGM2ZSM)
	$(VGM2ZSM) $< $@

$(ZIPFILE): zsms
	zip $(ZIPFILE) $(ZSMS)

.PHONY: clean
clean:
	rm -f $(ZSMS)
	rm -f $(ZIPFILE)

.PHONY: zip
zip:	$(ZIPFILE)
