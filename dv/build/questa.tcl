# Clock and reset
add wave -noupdate -group {Clock and Reset} /tb_npu_top/DUT/clk_i
add wave -noupdate -group {Clock and Reset} /tb_npu_top/DUT/arstn_i
# APB Master
add wave -noupdate -group {APB Master} /tb_npu_top/DUT/p_addr_i
add wave -noupdate -group {APB Master} /tb_npu_top/DUT/p_sel_i
add wave -noupdate -group {APB Master} /tb_npu_top/DUT/p_enable_i
add wave -noupdate -group {APB Master} /tb_npu_top/DUT/p_write_i
add wave -noupdate -group {APB Master} /tb_npu_top/DUT/p_wdata_i
add wave -noupdate -group {APB Master} /tb_npu_top/DUT/p_ready_o
add wave -noupdate -group {APB Master} /tb_npu_top/DUT/p_rdata_o
add wave -noupdate -group {APB Master} /tb_npu_top/DUT/p_slverr_o
# AXI4 Store
add wave -noupdate -group {AXI4 Store} {/tb_npu_top/DUT/wa_valid_o[2]}
add wave -noupdate -group {AXI4 Store} {/tb_npu_top/DUT/wa_ready_i[2]}
add wave -noupdate -group {AXI4 Store} {/tb_npu_top/DUT/wa_addr_o[2]}
add wave -noupdate -group {AXI4 Store} {/tb_npu_top/DUT/wd_valid_o[2]}
add wave -noupdate -group {AXI4 Store} {/tb_npu_top/DUT/wd_ready_i[2]}
add wave -noupdate -group {AXI4 Store} {/tb_npu_top/DUT/wd_data_o[2]}
add wave -noupdate -group {AXI4 Store} {/tb_npu_top/DUT/wd_strb_o[2]}
add wave -noupdate -group {AXI4 Store} {/tb_npu_top/DUT/wr_valid_i[2]}
add wave -noupdate -group {AXI4 Store} {/tb_npu_top/DUT/wr_ready_o[2]}
add wave -noupdate -group {AXI4 Store} {/tb_npu_top/DUT/ra_valid_o[2]}
add wave -noupdate -group {AXI4 Store} {/tb_npu_top/DUT/ra_ready_i[2]}
add wave -noupdate -group {AXI4 Store} {/tb_npu_top/DUT/ra_addr_o[2]}
add wave -noupdate -group {AXI4 Store} {/tb_npu_top/DUT/rd_valid_i[2]}
add wave -noupdate -group {AXI4 Store} {/tb_npu_top/DUT/rd_ready_o[2]}
add wave -noupdate -group {AXI4 Store} {/tb_npu_top/DUT/rd_data_i[2]}
# AXI4 Load 1
add wave -noupdate -group {AXI4 Load 1} {/tb_npu_top/DUT/wa_valid_o[1]}
add wave -noupdate -group {AXI4 Load 1} {/tb_npu_top/DUT/wa_ready_i[1]}
add wave -noupdate -group {AXI4 Load 1} {/tb_npu_top/DUT/wa_addr_o[1]}
add wave -noupdate -group {AXI4 Load 1} {/tb_npu_top/DUT/wd_valid_o[1]}
add wave -noupdate -group {AXI4 Load 1} {/tb_npu_top/DUT/wd_ready_i[1]}
add wave -noupdate -group {AXI4 Load 1} {/tb_npu_top/DUT/wd_data_o[1]}
add wave -noupdate -group {AXI4 Load 1} {/tb_npu_top/DUT/wd_strb_o[1]}
add wave -noupdate -group {AXI4 Load 1} {/tb_npu_top/DUT/wr_valid_i[1]}
add wave -noupdate -group {AXI4 Load 1} {/tb_npu_top/DUT/wr_ready_o[1]}
add wave -noupdate -group {AXI4 Load 1} {/tb_npu_top/DUT/ra_valid_o[1]}
add wave -noupdate -group {AXI4 Load 1} {/tb_npu_top/DUT/ra_ready_i[1]}
add wave -noupdate -group {AXI4 Load 1} {/tb_npu_top/DUT/ra_addr_o[1]}
add wave -noupdate -group {AXI4 Load 1} {/tb_npu_top/DUT/rd_valid_i[1]}
add wave -noupdate -group {AXI4 Load 1} {/tb_npu_top/DUT/rd_ready_o[1]}
add wave -noupdate -group {AXI4 Load 1} {/tb_npu_top/DUT/rd_data_i[1]}
# AXI4 Load 0
add wave -noupdate -group {AXI4 Load 0} {/tb_npu_top/DUT/wa_valid_o[0]}
add wave -noupdate -group {AXI4 Load 0} {/tb_npu_top/DUT/wa_ready_i[0]}
add wave -noupdate -group {AXI4 Load 0} {/tb_npu_top/DUT/wa_addr_o[0]}
add wave -noupdate -group {AXI4 Load 0} {/tb_npu_top/DUT/wd_valid_o[0]}
add wave -noupdate -group {AXI4 Load 0} {/tb_npu_top/DUT/wd_ready_i[0]}
add wave -noupdate -group {AXI4 Load 0} {/tb_npu_top/DUT/wd_data_o[0]}
add wave -noupdate -group {AXI4 Load 0} {/tb_npu_top/DUT/wd_strb_o[0]}
add wave -noupdate -group {AXI4 Load 0} {/tb_npu_top/DUT/wr_valid_i[0]}
add wave -noupdate -group {AXI4 Load 0} {/tb_npu_top/DUT/wr_ready_o[0]}
add wave -noupdate -group {AXI4 Load 0} {/tb_npu_top/DUT/ra_valid_o[0]}
add wave -noupdate -group {AXI4 Load 0} {/tb_npu_top/DUT/ra_ready_i[0]}
add wave -noupdate -group {AXI4 Load 0} {/tb_npu_top/DUT/ra_addr_o[0]}
add wave -noupdate -group {AXI4 Load 0} {/tb_npu_top/DUT/rd_valid_i[0]}
add wave -noupdate -group {AXI4 Load 0} {/tb_npu_top/DUT/rd_ready_o[0]}
add wave -noupdate -group {AXI4 Load 0} {/tb_npu_top/DUT/rd_data_i[0]}
# Signal name width
configure wave -namecolwidth 350;
