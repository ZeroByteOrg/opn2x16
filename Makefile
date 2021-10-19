# Makefile adapted from general-purpose Makefile by Job Vranish
# "Even simpler Makefile"
# https://spin.atomicobject.com/2016/08/26/makefile-c-projects/

LIBRARY ?= zwidgets.lib
EXEC ?= TEST.PRG
SRC_DIRS ?= ./src
VGM2ZSM		= ./vgm2zsm

CC		= /usr/local/bin/cl65
CFLAGS	= -t cx16 -O -g $(INC_FLAGS)
#CFLAGS	= -t cx16 -O -g -Ln %.sym -c
LD		= /usr/local/bin/cl65
LDFLAGS	= -t cx16 -O
AR		= /usr/local/bin/ar65

#SRCS := $(shell find $(SRC_DIRS) -name \*.c -or -name \*.asm)
SRCS := $(shell find $(SRC_DIRS) -name \*.c)
OBJS := $(addsuffix .o,$(basename $(SRCS)))
DEPS := $(OBJS:.o=.d)
VGMS := $(shell find ost -name \*.vgm)
ZSMR38 := $(addsuffix .ZSM38,zsm38/$(basename $(VGMS)))
ZSMR39 := $(addsuffix .ZSM39,zsm39/$(basename $(VGMS)))
ZSMS := $(ZSMR38) $(ZSMR39)

INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

#CPPFLAGS ?= $(INC_FLAGS) -MMD -MP

$(EXEC): main.c $(LIBRARY) $(SRC_DIRS)/zwidgets.h main.c
	$(LD) $(LDFLAGS) -g -Ln $@.sym -m $@.map -o $@ main.c $(LIBRARY) src/mouse/wait.o

$(LIBRARY): $(OBJS)
	$(AR) a $(LIBRARY) $(OBJS)
	

.PHONY: zsm
zsm: $(ZSMS)

%.ZSM38: %.vgm
	$(VGM2ZSM) $< $@

%.ZSM39: 
	$(VGM2ZSM) $< $@

.PHONY: clean
clean:
	$(RM) $(EXEC) $(LIBRARY) $(OBJS) $(DEPS) *.map *.sym
	
.PHONY: lib
lib: $(LIBRARY)

.PHONY: test
test: $(EXEC)

.PHONY: %.h

.PHONY: main.c

#zwidgets.h: src/zwidgets.h
#	cp $< $@
	
-include $(DEPS)


