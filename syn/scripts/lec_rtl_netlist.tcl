add_search_path -design   $env(incdir_list)

read_library -liberty     $env(lec_libs)

read_design -gold -sv09   $env(syn_list)

read_design -REV -NETLIST $env(SYN_DIR)/out/syn_opt/netlist_opt.v

vpxmode
set system mode lec


// auto compare (you may set off it) //

add compared points -all
compare -NONEQ_Print

///////////////////////////////////////