###########################################
#         Local variables (opts)          #
###########################################
export SYN_DEFINES := SYNTHESIS

libs_LL_and_HS := true

GENUS_OPTS    +=  -common_ui
GENUS_OPTS    +=  -files $(SYN_DIR)/scripts/genus_main_script.tcl

CDNS_OPTS     +=  -stylus
CDNS_OPTS     +=  -cpus 8
# CDNS_OPTS     +=  -no_gui

export GEN_WORK    := $(SYN_DIR)/work_genus
export FLOW_OUT    := $(SYN_DIR)/out
export CFM_WORK    := $(SYN_DIR)/work_conformal

export FE_MMMC     := $(SYN_FILES)/genus_mmmc.tcl
export FE_NETLIST  := $(FLOW_OUT)/fe_final/$(DESIGN_NAME).v
export FE_DEF      := ${FLOW_OUT}/be_final/${DESIGN_NAME}_fp.def

export BE_MMMC     := $(SYN_FILES)/innovus_mmmc.tcl
export BE_OCV      := $(SYN_FILES)/innovus_ocv.tcl
export BE_NETLIST  := $(FLOW_OUT)/be_final/$(DESIGN_NAME).v
export BE_DEF      := ${FLOW_OUT}/be_final/${DESIGN_NAME}.def

# # DFT vars
# export SCAN	   := true

export date_suf=$(shell date +%d.%m.%y_%H:%M)

dirs:
	mkdir -p $(GEN_WORK)
	mkdir -p $(FLOW_OUT)
	mkdir -p $(CFM_WORK)

cdnshelp: dirs
	cd $(SYN_DIR) && \
		module purge && \
		module load cadence/IC/06.18.040 && \
		cdnshelp

build: dirs
	cd $(GEN_WORK) && \
		module purge && \
		module load cadence/GENUS/21.14 && \
		genus $(GENUS_OPTS)
	cd $(SYN_DIR)

genus: dirs
	cd $(GEN_WORK) && \
		module purge && \
		module load cadence/GENUS/21.14 && \
		genus -common_ui
	cd $(SYN_DIR)

lec: $(CFM_WORK)
	mkdir -p ./syn/out/lec_logs/ ; \
	touch ./syn/out/lec_logs/lec.log ;\
	cd $(CFM_WORK) && \
	 module purge && \
	 module load cadence/CONFRML/22.10.100 && \
	 lec -xl -TclMode -Dofile ./out/fe_lec/rtl2final.lec.do -LOGfile ./out/lec_logs/lec.log
	@${MAKE} syn_clean_lec

all:
	make syn_build
	make syn_lec
	
###

clean_genus:
	rm -rf $(GEN_WORK)/*
	rm -f  $(GEN_WORK)/.*

clean_lec:
	rm -rf $(CFM_WORK)/*
	rm -f  $(CFM_WORK)/.*
