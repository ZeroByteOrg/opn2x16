VGM2ZSM		= ./vgm2zsm
CL65		= cl65
INCPATH		= ../zsound/inc
LIBPATH		= ../zsound/lib
PATHS		= $(addprefix -L ,$(LIBPATH)) $(addprefix --asm-include-dir ,$(INCPATH))
CL65FLAGS	= -g -Ln player.sym -t cx16 -C $(CFG) -u __EXEHDR__ $(PATHS)
VGMS	:= $(wildcard ./ost/*.vgm)
ZSMR38	:= $(patsubst ./ost/%.vgm,./zsm38/%.zsm,$(VGMS))
ZSMR39	:= $(patsubst ./ost/%.vgm,./zsm39/%.zsm,$(VGMS))
ZSMS	:= $(ZSMR38) $(ZSMR39) $(ZSM2R38) $(ZSM2R39)
ZIPFILE	:= citycon_zsm.zip

PLAYER38	:= zsm38.prg
PLAYER39	:= zsm39.prg

#SRCLIST	:= main.asm zsmplayer.asm pcm.asm
SRCLIST		:= main.asm
INCLIST		:= x16.inc zsm.inc
LIB38		:= zsound38.lib
LIB39		:= zsound39.lib

SRC		:= $(patsubst %.asm,src/%.asm,$(SRCLIST))
INC		:= $(patsubst %.inc,src/%.inc,$(INCLIST))
CFG		:= player.cfg

.PHONY: player
player: $(PLAYER38) $(PLAYER39)

zsm: $(ZSMS)

$(PLAYER38): $(SRC) $(INC) $(CFG)
	$(CL65) $(CL65FLAGS) --asm-define REV=38 -o $@ $(SRC) $(LIB38)

$(PLAYER39): $(SRC) $(INC) $(CFG)
	$(CL65) $(CL65FLAGS) -o $@ $(SRC) $(LIB39)

.PHONY: src/%.inc
src/%.inc:

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

$(ZIPFILE): $(ZSMS)
	zip $(ZIPFILE) $(ZSMS)

.PHONY: clean
clean:
	rm -f $(ZSMS)
	rm -f $(ZIPFILE)
	rm -f $(PLAYER38) $(PLAYER39)

.PHONY: zip
zip:	$(ZIPFILE)
