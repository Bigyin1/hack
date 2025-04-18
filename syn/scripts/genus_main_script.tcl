##############################################################################
## Different trash for output in console
##############################################################################

source $env(SYN_FILES)/console_info_output_vars.tcl

##############################################################################
## Preset global variables and attributes
##############################################################################

source $env(SYN_SCRIPTS)/flow_vars.tcl

puts $g_start_setup
####################################################################
## Genus setup
####################################################################

set_db / .hdl_track_filename_row_col              true
set_db / .information_level                       11
set_db / .source_verbose                          true

#set_db / .input_pragma_keyword {synopsys}

#set_db / .hdl_error_on_logic_abstract             true
#set_db / .hdl_preserve_unused_flop                true
#set_db / .hdl_preserve_unused_registers           true
#set_db / .multibit_allow_unused_bits              true
#set_db / .optimize_constant_0_flops               false
#set_db / .optimize_constant_1_flops               false

set_db hdl_error_on_latch true

# for resolving problem with mbist lockup latch set false
# set_db hdl_error_on_latch                         false
set_db remove_assigns                             true

# be ready for DFT
set_db / .use_scan_seqs_for_non_dft               false 


# old commands
#set_db hdl_unconnected_input_port_value           0
#set_db hdl_undriven_output_port_value             0
#set_db hdl_undriven_signal_value                  0
# new command
set_db hdl_unconnected_value                      0

#set_db hdl_error_on_blackbox                      true        ; # (default: false )
set_db hdl_error_on_blackbox                      false        ;
## # set naming style for genus
## set_db bus_naming_style                           {%s[%d]}    ; # (default: %s[%d] )
## #set_db hdl_reg_naming_style                       {%s_reg%s}  ; # (default: %s_reg%s )
## #set_db hdl_parameter_naming_style                 {_%d}       ; # (default: _%s%d )
## #set_db hdl_record_naming_style                    {%s_%s}     ; # (default: %s[%s] )
## set_db hdl_bus_wire_naming_style                  {%s[%d]}    ; # (default: %s[%d] )
## #set_db hdl_array_naming_style                     {%s_%d}     ; # (default: %s[%d] )
## #set_db hdl_instance_array_naming_style            {%s_%d}     ; # (default: %s[%d] )
## #set_db hdl_generate_index_style                   {%s_%d}     ; # (default: %s[%d] )
## set_db hdl_generate_separator                     {_}         ; # (default: . )

# set naming style for genus
#set_db bus_naming_style %s[%d]              ; # (default: %s[%d] )
#set_db hdl_reg_naming_style %s_reg%s        ; # (default: %s_reg%s )
set_db hdl_parameter_naming_style _%d        ; # (default: _%s%d )
set_db hdl_record_naming_style  %s_%s        ; # (default: %s[%s] )
#set_db hdl_bus_wire_naming_style  %s[%d]    ; # (default: %s[%d] )
set_db hdl_array_naming_style %s_%d          ; # (default: %s[%d] )
set_db hdl_instance_array_naming_style %s_%d ; # (default: %s[%d] )
set_db hdl_generate_index_style %s_%d        ; # (default: %s[%d] )
set_db hdl_generate_separator _              ; # (default: . )

# set module prefix for blocks (for LVS uniq modules)
# set_db gen_module_prefix                         ${DESIGN}
# set_db lp_clock_gating_prefix                    ${DESIGN}

# use ChipWare components to instantiate the functionality in the design as opposed
# to the user defined modules (Verilog) or entities (VHDL) with identical names
#set_db hdl_use_cw_first                           true        ; # (default: false )

set_db write_vlog_empty_module_for_logic_abstract false

set_db auto_ungroup                               none
set_db lp_insert_clock_gating                     true
#set_db lp_insert_discrete_clock_gating_logic      true

#set_db / .innovus_executable                      $env(ENCOUNTER)

set_db / .qos_report_power                        true 

set_db timing_report_fields                       { timing_point arc               \
                                                    edge         cell              \
                                                    delay        arrival           \
                                                    transition   fanout            \
                                                    load         user_derate       \
                                                    total_derate instance_location \
                                                    wire_length  flags             }
         
set_db timing_report_time_unit                    ns

regexp \[0-9\]+(\.\[0-9\]+) [get_db / .program_version] exe_ver exe_sub_ver
puts "Executable Version: $exe_ver"

# set_db / .time_recovery_arcs                     true
# set_db / .timing_use_ecsm_pin_capacitance        true
# set_db / .lef_add_power_and_ground_pins          false

#set LEC directory and number of threads in for write_do_lec 
set_db verification_directory_naming_style        ${SYN_DIR}/out/fv/fv_dir
set_db wlec_compare_threads                       8
set_db wlec_parallel_threads                      8

# block_global_variables
# INFO: gf_step_block_global_variables not defined
puts $g_finish_setup
####################################################################
## Read libs
####################################################################
puts $g_start_read_libs

read_libs /tools/SAED_14/std/liberty/saed14rvt_tt0p8v25c.lib $env(FILES_MEM_LIB)

puts $g_finish_read_libs
set clk_freq $env(CLK)

puts $g_start_read_dont_use
source ${SYN_FILES}/dont_use.tcl
puts $g_finish_read_dont_use

####################################################################
## Load RTL
####################################################################
puts $g_start_read_rtl
set inc_lst_gen $env(inc_lst)
set RTL [join $env(syn_list)]
set_db init_hdl_search_path [join $env(incdir_list)]

read_hdl ${RTL} ${inc_lst_gen} -define ${HDL_DEFINES} -sv 
if {$env(FILES_VHDL) != ""} {
  read_hdl $env(FILES_VHDL) -vhdl
}
puts $g_finish_read_rtl
####################################################################
## Elaborate
####################################################################
puts $g_start_elaborate

elaborate ${DESIGN_NAME}
#write_db -all_root_attributes ${GEN_WORK}/elab/${DESIGN_NAME}.db
report_messages -info
report_messages -warning
report_messages -error

puts $g_finish_elaborate
####################################################################
## Read SDC
####################################################################
puts $g_start_read_sdc

read_sdc ${SDC_DIR}/${DESIGN_NAME}.sdc

# Cost groups
define_cost_group -name in2reg  -design ${DESIGN_NAME}
define_cost_group -name reg2out -design ${DESIGN_NAME}
define_cost_group -name reg2reg -design ${DESIGN_NAME}
define_cost_group -name in2out  -design ${DESIGN_NAME}

path_group -from [all::all_seqs] -to [all::all_seqs] -group reg2reg -name reg2reg
path_group -from [all::all_seqs] -to [all_outputs]   -group reg2out -name reg2out
path_group -from [all_inputs]    -to [all::all_seqs] -group in2reg  -name in2reg
path_group -from [all_inputs]    -to [all_outputs]   -group in2out  -name in2out

puts $g_finish_read_sdc
####################################################################
## Init design
####################################################################
puts $g_start_initialization

init_design -top ${DESIGN_NAME}

if {$env(INIT_PAUSE) == 1} {
  suspend
}

check_timing_intent -verbose > ${GEN_WORK}/elab_init/${DESIGN_NAME}_intent_init.rpt
write_db -all_root_attributes ${GEN_WORK}/elab_init/${DESIGN_NAME}.db
write_snapshot -outdir ${GEN_WORK} -tag elab_init/snapshot/

report_messages -info
report_messages -warning
report_messages -error

puts $g_finish_initialization
####################################################################
## Preserve insts
####################################################################
puts $g_start_read_dont_touch

set_interactive_constraint_modes [get_db constraint_modes .name]
set_interactive_constraint_modes ""

puts $g_finish_read_dont_touch
####################################################################
## Synthesizing to generic 
####################################################################
puts $g_start_syn_gen

set GEN_EFF     high
set MAP_EFF     high
set OPT_EFF     low

set_db / .syn_generic_effort ${GEN_EFF}

syn_generic ${DESIGN_NAME}

## Generate a summary for the current stage of synthesis
report_dp ${DESIGN_NAME} > ${GEN_WORK}/syn_gen/${DESIGN_NAME}_dp.rpt
write_snapshot -outdir     ${GEN_WORK} -tag syn_gen/snapshot/
write_hdl >                ${GEN_WORK}/syn_gen/${DESIGN_NAME}_gen.v
report_summary -directory  ${GEN_WORK}/syn_gen

report_messages -info    > ${GEN_WORK}/syn_gen/report_info.rpt
report_messages -warning > ${GEN_WORK}/syn_gen/report_warning.rpt
report_messages -error   > ${GEN_WORK}/syn_gen/report_error.rpt
puts "${m_write} gen reports ${m_done}"

puts $g_runtime_syn_gen
time_info GENERIC

puts $g_finish_syn_gen
####################################################################
## Synthesizing to mapped
####################################################################
puts $g_start_syn_map

set_db / .syn_map_effort ${MAP_EFF}

# syn_map
syn_map ${DESIGN_NAME}

## Generate a summary for the current stage of synthesis 
report_dp ${DESIGN_NAME} > ${GEN_WORK}/syn_map/${DESIGN_NAME}_dp.rpt
write_snapshot -outdir     ${GEN_WORK} -tag syn_map/snapshot/
write_hdl >                ${GEN_WORK}/syn_map/${DESIGN_NAME}_map.v
report_summary -directory  ${GEN_WORK}/syn_map
report_clock_gating

#Intermediate netlist for LEC verification
write_do_lec                  \
    -golden    rtl            \
    -revised   fv_map         \
    -no_exit                  \
    -tmp_dir   ${FLOW_OUT}/fe_lec_tmp/ \
    >          ${FLOW_OUT}/fe_lec/rtl2intermediate.lec.do
#    -log_file ${FLOW_OUT}/fe_lec/rtl2intermediate.lec.log \    
#    -pre_exit ${SYN_FILES}/lec_pre_exit_file.do \

puts "${m_write}_do_lec (map) ${m_done}"

report_messages -info    > ${GEN_WORK}/syn_map/report_info.rpt
report_messages -warning > ${GEN_WORK}/syn_map/report_warning.rpt
report_messages -error   > ${GEN_WORK}/syn_map/report_error.rpt
puts "${m_write} map reports ${m_done}"

puts $g_runtime_syn_map
time_info MAPPED

puts $g_finish_syn_map
###################################################################
# Optimization
####################################################################
puts $g_start_syn_opt

set_db / .syn_opt_effort ${OPT_EFF}

syn_opt ${DESIGN_NAME} -incr
#syn_opt -spatial

# remove_cdn_loop_breaker -instances [vfind / -inst cdn_loop_breaker*]

# Generate a summary for the current stage of synthesis
report_dp ${DESIGN_NAME} > ${GEN_WORK}/syn_opt/datapath_opt.rpt
write_snapshot -outdir     ${GEN_WORK} -tag syn_opt/snapshot/
write_hdl >                ${GEN_WORK}/syn_map/${DESIGN_NAME}_opt.v
report_summary -directory  ${GEN_WORK}/syn_opt
#report_clock_gating

report_messages -info    > ${GEN_WORK}/syn_opt/report_info.rpt
report_messages -warning > ${GEN_WORK}/syn_opt/report_warning.rpt
report_messages -error   > ${GEN_WORK}/syn_opt/report_error.rpt
puts "${m_write} opt reports ${m_done}"

puts $g_runtime_syn_opt
time_info OPT
puts $g_finish_syn_opt
####################################################################
## Writing out data
####################################################################
## Generate a summary for the current stage of synthesis
write_snapshot -outdir    ${GEN_WORK} -tag final/snapshot/
write_hdl >               ${FLOW_OUT}/fe_final/${DESIGN_NAME}.v
check_timing_intent -verbose > ${GEN_WORK}/final/${DESIGN_NAME}_intent_final.rpt
report_summary -directory ${GEN_WORK}/final/
report_summary -directory ${FLOW_OUT}/fe_final/
report_summary -directory ${FLOW_OUT}/reports/

report_clock_gating          > ${GEN_WORK}/final/clockgating.rpt
report_power  -levels    0   > ${GEN_WORK}/final/power.rpt
report_gates  -power         > ${GEN_WORK}/final/gates_power.rpt
report_timing -max_paths 100 > ${GEN_WORK}/final/timing_100.rpt

####################################################################
## Write_db
####################################################################
write_db -all_root_attributes -to_file ${GEN_WORK}/final/${DESIGN_NAME}_${date_suf}.db
####################################################################
 
foreach gp "in2reg reg2out reg2reg in2out" {
  report_timing -max_paths 1000 -max_slack 0.0 -group $gp > ${FLOW_OUT}/reports/${DESIGN_NAME}_${gp}_failed_timing_1000.rpt
}
report_timing -max_paths 1000 > ${FLOW_OUT}/reports/${DESIGN_NAME}_all_timing_1000.rpt

report_area -detail -depth 2 > ${FLOW_OUT}/reports/area.rpt

puts "${m_write} final reports ${m_done}"

####################################################################
## Write_do_lec
####################################################################

write_do_lec                                    \
    -golden_design  fv_map                      \
    -revised_design ${FLOW_OUT}/fe_final/${DESIGN_NAME}.v \
    -no_exit                                    \
    -tmp_dir        ${FLOW_OUT}/fe_lec_tmp/              \
    >               ${FLOW_OUT}/fe_lec/intermediate2final.lec.do
#    -log_file  ${FLOW_OUT}/fe_lec/intermediate2final.lec.log \
#    -pre_exit  ${SYN_FILES}/lec_pre_exit_file.do \

puts "${m_write}_do_lec (syn) ${m_done}"


# Uncomment if the RTL is to be compared with the final netlist
write_do_lec                                    \
    -golden_design  rtl                         \
    -revised_design ${FLOW_OUT}/fe_final/${DESIGN_NAME}.v \
    -no_exit                                    \
    -tmp_dir        ${FLOW_OUT}/fe_lec_tmp/              \
    >               ${FLOW_OUT}/fe_lec/rtl2final.lec.do
#    -pre_exit ${SYN_FILES}/lec_pre_exit_file.do \
#    -log_file ${FLOW_OUT}/lec_logs/rtl2final.lec.log \

puts "${m_write}_do_lec (final) ${m_done}"

exit
