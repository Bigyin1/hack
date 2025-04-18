MAKEFILE            := $(realpath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR        := $(realpath $(dir $(MAKEFILE)))
MAKEFLAGS           := -rR

export ROOT_DIR     := $(MAKEFILE_DIR)
export GIT_HOME     := $(MAKEFILE_DIR)

#################### Settings, LOCALVARs ####################
export CLK          := $(shell cat $(GIT_HOME)/freq.mk)
export INIT_PAUSE   ?= 0
export DESIGN_NAME  := npu_wrapper


SIM_DIR             := $(GIT_HOME)/sim
export SDC_DIR      := $(GIT_HOME)/sdc
export SYN_DIR      := $(GIT_HOME)/syn
export METR_DIR     := $(GIT_HOME)/metrics
export SYN_FILES    := $(SYN_DIR)/files
export SYN_SCRIPTS  := $(SYN_DIR)/scripts

export INCDIR_LIST_PATH := $(foreach path, $(shell cat $(GIT_HOME)/lst/incdir.lst), $(GIT_HOME)/$(path))
export incdir_list      := $(INCDIR_LIST_PATH)

export INC_PATH := $(foreach path, $(shell cat $(GIT_HOME)/lst/files_rtl_svh.lst), $(GIT_HOME)/$(path))
export inc_lst := $(INC_PATH)

export FILES_RTL  := $(foreach path, $(shell cat $(GIT_HOME)/lst/files_rtl_verilog.lst), $(GIT_HOME)/$(path))
export FILES_VHDL := $(foreach path, $(shell cat $(GIT_HOME)/lst/files_rtl_vhdl.lst), $(GIT_HOME)/$(path))

export FILES_MEM_LIB := $(foreach path, $(shell cat $(GIT_HOME)/lst/files_mem_lib.lst), $(path))
export FILES_MEM_RTL := $(foreach path, $(shell cat $(GIT_HOME)/lst/files_mem_verilog.lst), $(path))

export syn_list  := $(FILES_RTL)

.PHONY: metrics

syn_%:
	$(MAKE) -f ./syn/Makefile $*

metrics:
	@python3 $(METR_DIR)/script/metr_collection.py