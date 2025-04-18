SHELL  := bash

#---------------------------------------------------------
# Makefile for AXI4 NPU DV
#---------------------------------------------------------

# User settings for matrixes
ADDR_T0_0 = 4
ADDR_T0_1 = 4
ADDR_T0_2 = 3
ADDR_T1_0 = 4
ADDR_T1_1 = 4
ADDR_T1_2 = 3

SIZES_SIM_OPTS = +ADDR_T0_0=$(ADDR_T0_0) +ADDR_T1_0=$(ADDR_T1_0) \
				 +ADDR_T0_1=$(ADDR_T0_1) +ADDR_T1_1=$(ADDR_T1_1) \
				 +ADDR_T0_2=$(ADDR_T0_2) +ADDR_T1_2=$(ADDR_T1_2)

# Iterations amount for tensor calculation
ITER_AM = 5

# Tensor calculation timeout in clock cycles
TIMEOUT = 500000

# Seed
SEED := $(shell echo $$RANDOM)

# Output directory
OUT = ./out

# Output directory with seed
OUT_SEED = ./out/seed-$(SEED)

# Netlist simulation switch
NETLIST = 0

# Run options
RUN_OPTS =

# GUI or console switch
ifeq ($(GUI),1)
	RUN_OPTS += -gui
	DEBUG = 1
else
	RUN_OPTS += -c
endif

# Verbosity
VERBOSITY = UVM_LOW

# Statistics
EN_STATS = 0

# Test
TEST = $(shell head -n 1 $(CURDIR)/testlist.lst)
ifeq ($(TEST),all)
	override TEST = $(shell cat $(CURDIR)/testlist.lst)
endif

# Transactions logging
ifeq ($(LOGGING),1)
	RUN_OPTS += +en_logging=1
endif

# Debugging
ifeq ($(DEBUG),1)
	RUN_OPTS += -voptargs="+acc" -do questa.tcl
else
	RUN_OPTS += -voptargs="-O5 +acc+npr+/tb_npu_top/DUT"
endif

# Lists
TB_LIST          = $(CURDIR)/../lst/files_tb.lst
UVM_LIST         = $(CURDIR)/../lst/files_uvm.lst
VIP_LIST         = $(CURDIR)/../lst/files_vip.lst
RTL_VERILOG_LIST = $(CURDIR)/../../lst/files_rtl_verilog.lst
RTL_MEM_LIST     = $(CURDIR)/../../lst/files_mem_verilog.lst
RTL_VHDL_LIST    = $(CURDIR)/../../lst/files_rtl_vhdl.lst
RTL_INCDIR_LIST  = $(CURDIR)/../../lst/incdir.lst
DV_INCDIR_LIST   = $(CURDIR)/../lst/incdir.lst

# TB Sources
TB_SRCS  = $(shell eval echo $$(cat $(UVM_LIST)))
TB_SRCS += $(shell eval echo $$(cat $(TB_LIST)))

# VIP sources
VIP_SRCS = $(shell eval echo $$(cat $(VIP_LIST)))

# RTL sources
ifeq ($(NETLIST),1)
# TODO: Support netlist simulation
$(error Netlist simulation is not supported for now.)
else
	RTL_VERILOG_SRCS  = $(addprefix $(CURDIR)/../../,$(shell eval echo $$(cat $(RTL_VERILOG_LIST))))
	RTL_VERILOG_SRCS += $(addprefix $(CURDIR)/../../,$(shell eval echo $$(cat $(RTL_MEM_LIST))))
	RTL_VHDL_SRCS    += $(addprefix $(CURDIR)/../../,$(shell eval echo $$(cat $(RTL_VHDL_LIST))))
endif

# DV directories to include
DV_INCDIRS = $(addprefix +incdir+,$(shell eval echo $$(cat $(DV_INCDIR_LIST))))

# RTL directories to inlcude
RTL_INCDIRS = $(addprefix +incdir+,$(shell eval echo $$(cat $(RTL_INCDIR_LIST))))

.PHONY: run prepare clean open_wave

# RTL run logs
rtl_run_logs = $(addsuffix /rtl_run.log,$(addprefix $(OUT_SEED)/,$(TEST)))

# First target to run
run: prepare $(rtl_run_logs)
	@echo "| Check run_history.log!"
	@echo "|"

# Do some preparations
prepare:
	@echo "|"

# Run simulation
$(rtl_run_logs): $(OUT)/vip_compile.log $(OUT)/rtl_compile.log \
	$(OUT)/tb_compile.log $(OUT)/SEED.$(SEED) | $(OUT)
	@mkdir -p $(dir $@)
	@printf "| %-100s" "Running ($@)"; echo -n " | "
	@vsim  $(RUN_OPTS) -do "run -all; wave zoom full; quit;" tb_npu_top \
		-sv_seed $(SEED) -mvchome $$QUESTA_MVC_HOME +UVM_TESTNAME=$(shell basename $(dir $@)) \
			+UVM_VERBOSITY=$(VERBOSITY) +en_stats=$(EN_STATS) -l $@ -wlf $(basename $@).wlf \
				-suppress 3829 +log_file_name=$(dir $@)/hack_2025_rtl_plus_stats.txt $(SIZES_SIM_OPTS) \
					+iter_am=$(ITER_AM) +seq_timeout_clks=$(TIMEOUT) > $@ 
	@rm -rf transcript
	@sh check_log.sh $@
	@printf "%-100s" "$(shell date) | Test: $(shell basename $(dir $@))" >> run_history.log
	@printf "%-20s" " | Seed: $(SEED)" >> run_history.log
	@echo -n " | " >> run_history.log
	@sh check_log.sh $@ >> run_history.log
	@cp $@ $(OUT)

# Clean output directory
clean:
	@rm -rf $(OUT) work

# TB compilation
$(OUT)/tb_compile.log: $(TB_SRCS) $(OUT)/NETLIST.$(NETLIST) | $(OUT)
	@printf "| %-100s" "Compiling TB ($@)"; echo -n " | "
	@vlog -64 -sv $(DV_INCDIRS) $(TB_SRCS) -timescale "1 ns / 1 ps" > $@
	@echo "Done"
	@touch $@

# RTL compilation
$(OUT)/rtl_compile.log: $(RTL_VERILOG_SRCS) $(RTL_VHDL_SRCS) $(OUT)/NETLIST.$(NETLIST) | $(OUT)
	@printf "| %-100s" "Compiling RTL ($@)"; echo -n " | "
	@vlog -64 -sv $(RTL_INCDIRS) $(RTL_VERILOG_SRCS) +nospecify -timescale "1 ns / 1 ps" > $@
ifneq ($(RTL_VHDL_SRCS),)
	@vcom -64 $(RTL_INCDIRS) $(RTL_VHDL_SRCS) >> $@
endif
	@echo "Done"
	@touch $@

# VIP compilation
$(OUT)/vip_compile.log: $(VIP_SRCS) | $(OUT)
	@printf "| %-100s" "Compiling VIP ($@)"; echo -n " | "
	@vlog -64 -sv $(DV_INCDIRS) $(VIP_SRCS) -timescale "1 ns / 1 ps" > $@
	@echo "Done"
	@touch $@

$(OUT):
	@mkdir -p $@

$(OUT)/NETLIST.$(NETLIST):
	@rm -f $(OUT)/NETLIST.*
	@touch $@

$(OUT)/SEED.$(SEED):
	@rm -f $(OUT)/SEED.*
	@touch $@
