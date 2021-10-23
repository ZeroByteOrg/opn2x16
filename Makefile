VGM2ZSM		= ./vgm2zsm
VGM2ZSM2	= ./vgm2zsm2
CL65		= cl65
CL65FLAGS	= -g -Ln player.sym -t cx16 -C $(CFG) -u __EXEHDR__
VGMS	:= $(wildcard ./ost/*.vgm)
ZSMR38	:= $(patsubst ./ost/%.vgm,./zsm38/%.zsm,$(VGMS))
ZSMR39	:= $(patsubst ./ost/%.vgm,./zsm39/%.zsm,$(VGMS))
ZSM2R38	:= $(patsubst ./ost/%.vgm,./zsm38/%.zsm2,$(VGMS))
ZSM2R39	:= $(patsubst ./ost/%.vgm,./zsm39/%.zsm2,$(VGMS))
ZSMS	:= $(ZSMR38) $(ZSMR39) $(ZSM2R38) $(ZSM2R39)
ZIPFILE	:= citycon_zsm.zip

PLAYER38	:= zsm238.prg
PLAYER39	:= zsm239.prg

SRCLIST	:= main.asm zsmplayer.asm pcm.asm
#SRCLIST	:= zsmplayer.asm
INCLIST	:= x16.inc zsm.inc

SRC		:= $(patsubst %.asm,src/%.asm,$(SRCLIST))
INC		:= $(patsubst %.inc,src/%.inc,$(INCLIST))
CFG		:= player.cfg

.PHONY: player
player: $(PLAYER38) $(PLAYER39)

zsm: $(ZSMS)

$(PLAYER38): $(SRC) $(INC) $(CFG)
	$(CL65) $(CL65FLAGS) --asm-define REV=38 -o $@ $(SRC)

$(PLAYER39): $(SRC) $(INC) $(CFG)
	$(CL65) $(CL65FLAGS) -o $@ $(SRC)

.PHONY: %.inc
%.inc:

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
	rm -f $(PLAYER38) $(PLAYER39)

.PHONY: zip
zip:	$(ZIPFILE)
