## Lab1 TODO: create Makefile for functest here

SRC_DIR := src
NAMES ?= $(basename $(notdir $(wildcard $(SRC_DIR)/*.c)))
SRCS := $(addprefix $(SRC_DIR)/, $(NAMES))
BASE_PORT := $(abspath ../base-port)
# SIM_PATH = ## This is for running the simulator, you can ignore for Lab 1

.PHONY: all
all: $(NAMES)

%: src/%.c
	@printf "NAMES:=%s\nSRCS:=%s\nBASE_PORT:=%s\ninclude %s/Makefile\n" "$@" "$(basename $<)" "$(BASE_PORT)" "$(BASE_PORT)" > $@.mk
	@make -s -f $@.mk
	@rm -rf $@.mk

clean:
	@rm -rf build