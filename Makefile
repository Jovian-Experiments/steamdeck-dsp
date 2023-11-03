CC = gcc

CFLAGS= -O0 -g -Wall -Werror
LDFLAGS=-lrt -lm -shared

#ROOT = $(CURDIR)
INC_DIR = include
INC = -I$(INC_DIR)

TARGET= 

SRC_DIR=src
OBJ_DIR=obj

OUT_DIR=bin

FAUST_FILES =\
	src/faust/valve_binaural.dsp src/faust/valve_deck_speakers.dsp src/faust/valve_deck_microphone.dsp

FAUST_COMPILER?=g++

all: clean
	@echo "Making directories..."
	@mkdir -m 777 -p $(OBJ_DIR)
	@mkdir -m 777 -p $(OUT_DIR)
	@mkdir -m 777 $(OUT_DIR)/lv2
	@mkdir -m 777 $(OUT_DIR)/svg
	@mkdir -m 777 -p $(OBJ_DIR)/$(SRC_DIR)
	@mkdir -m 777 temp_includes
	@echo "copying in temp include paths..."
	@cp --no-preserve=mode -r /usr/include/boost temp_includes/boost
	@cp --no-preserve=mode -r /usr/include/lv2 temp_includes/lv2
	@echo "Building Faust plugins..."
	( CXX=$(FAUST_COMPILER) CXXFLAGS+=" -Itemp_includes " faust2lv2 src/faust/valve_deck_speakers.dsp)
	( CXX=$(FAUST_COMPILER) CXXFLAGS+=" -Itemp_includes " faust2lv2 src/faust/valve_binaural.dsp)
	( CXX=$(FAUST_COMPILER) CXXFLAGS+=" -Itemp_includes " faust2lv2 src/faust/valve_deck_microphone.dsp)
	@echo "Generating Faust plugin documentation..."
	faust2svg src/faust/valve_deck_speakers.dsp
	faust2svg src/faust/valve_binaural.dsp
	faust2svg src/faust/valve_deck_microphone.dsp
	@mkdir -p bin/svg
	@mv src/faust/valve_deck_speakers-svg bin/svg/valve_deck_speakers
	@mv src/faust/valve_binaural-svg bin/svg/valve_deck_binaural
	@mv src/faust/valve_deck_microphone-svg bin/svg/valve_deck_microphone
	@mkdir -p bin/lv2/$(FAUST_COMPILER)
	@mv src/faust/valve_deck_speakers.lv2 bin/lv2/$(FAUST_COMPILER)/valve_deck_speakers.lv2
	@mv src/faust/valve_binaural.lv2 bin/lv2/$(FAUST_COMPPILER)/valve_binaural.lv2
	@mv src/faust/valve_deck_microphone.lv2 bin/lv2/$(FAUST_COMPILER)/valve_deck_microphone.lv2

.PHONY: clean

clean:
	rm -rf $(OUT_DIR) $(OBJ_DIR) $(OUT_DIR)/$(OUT_FILE_NAME) Makefile.bak
	if [ -d temp_includes ]; then rm -r temp_includes; fi;

rebuild: clean build

install:
	@echo "Installing LV2 plugins to plugin path."
	@./install_plugins.sh
	@./setup_pipewire.sh
	@./setup_wireplumber.sh
	@./setup_ucm2.sh
	@./setup_sof_fw.sh
