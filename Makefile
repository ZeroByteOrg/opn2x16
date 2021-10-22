VGM2ZSM		= ./vgm2zsm
VGM2ZSM2	= ./vgm2zsm2
VGMS	:= $(wildcard ./ost/*.vgm)
ZSMR38	:= $(patsubst ./ost/%.vgm,./zsm38/%.zsm,$(VGMS))
ZSMR39	:= $(patsubst ./ost/%.vgm,./zsm39/%.zsm,$(VGMS))
ZSM2R38	:= $(patsubst ./ost/%.vgm,./zsm38/%.zsm2,$(VGMS))
ZSM2R39	:= $(patsubst ./ost/%.vgm,./zsm39/%.zsm2,$(VGMS))
ZSMS	:= $(ZSMR38) $(ZSMR39) $(ZSM2R38) $(ZSM2R39)
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

./zsm38/%.zsm2: ./ost/%.vgm $(VGM2ZSM)
	$(VGM2ZSM2) -4 $< $@

./zsm39/%.zsm2: ./ost/%.vgm $(VGM2ZSM)
	$(VGM2ZSM2) $< $@

$(ZIPFILE): zsms
	zip $(ZIPFILE) $(ZSMS)

.PHONY: clean
clean:
	rm -f $(ZSMS)
	rm -f $(ZIPFILE)

.PHONY: zip
zip:	$(ZIPFILE)
