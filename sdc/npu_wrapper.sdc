# ================== CLOCK FREQ ==================
set PERIOD_CLK [expr (1000.0/$clk_freq)]

# ================== CLOCK DEFINITIONS ================== 
create_clock  -period $PERIOD_CLK  -name clk [get_ports clk_i]

# = I/O Delay
# ================== PORT GROUPS  ==================
set INPUTPORTS_CLK  [remove_from_collection [all_inputs]  [get_ports {clk_i}]]
set OUTPUTPORTS_CLK [all_outputs]

# ================== IO DELAYS ==================
set INPUT_DELAY_CLK       [expr 0.66 * $PERIOD_CLK]
set OUTPUT_DELAY_CLK      [expr 0.66 * $PERIOD_CLK]


# = AXI4 Slave
set_input_delay  -add_delay -max $INPUT_DELAY_CLK       -clock clk [get_ports "wa_ready_i"]
set_input_delay  -add_delay -min 0                      -clock clk [get_ports "wa_ready_i"]

set_output_delay -add_delay -max $OUTPUT_DELAY_CLK      -clock clk [get_ports "wa_valid_o"]
set_output_delay -add_delay -min 0                      -clock clk [get_ports "wa_valid_o"]

set_output_delay -add_delay -max $OUTPUT_DELAY_CLK      -clock clk [get_ports "wa_addr_o_*"]
set_output_delay -add_delay -min 0                      -clock clk [get_ports "wa_addr_o_*"]


set_output_delay -add_delay -max $OUTPUT_DELAY_CLK      -clock clk [get_ports "wd_valid_o"]
set_output_delay -add_delay -min 0                      -clock clk [get_ports "wd_valid_o"]

set_output_delay -add_delay -max $OUTPUT_DELAY_CLK      -clock clk [get_ports "wd_data_o_*"]
set_output_delay -add_delay -min 0                      -clock clk [get_ports "wd_data_o_*"]

set_output_delay -add_delay -max $OUTPUT_DELAY_CLK      -clock clk [get_ports "wd_strb_o_*"]
set_output_delay -add_delay -min 0                      -clock clk [get_ports "wd_strb_o_*"]

set_input_delay  -add_delay -max $INPUT_DELAY_CLK       -clock clk [get_ports "wd_ready_i"]
set_input_delay  -add_delay -min 0                      -clock clk [get_ports "wd_ready_i"]

set_input_delay  -add_delay -max $INPUT_DELAY_CLK       -clock clk [get_ports "wr_valid_i"]
set_input_delay  -add_delay -min 0                      -clock clk [get_ports "wr_valid_i"]

set_output_delay -add_delay -max $OUTPUT_DELAY_CLK      -clock clk [get_ports "wr_ready_o"]
set_output_delay -add_delay -min 0                      -clock clk [get_ports "wr_ready_o"]

set_output_delay -add_delay -max $OUTPUT_DELAY_CLK      -clock clk [get_ports "ra_valid_o"]
set_output_delay -add_delay -min 0                      -clock clk [get_ports "ra_valid_o"]

set_output_delay -add_delay -max $OUTPUT_DELAY_CLK      -clock clk [get_ports "ra_addr_o_*"]
set_output_delay -add_delay -min 0                      -clock clk [get_ports "ra_addr_o_*"]

set_input_delay  -add_delay -max $INPUT_DELAY_CLK       -clock clk [get_ports "ra_ready_i"]
set_input_delay  -add_delay -min 0                      -clock clk [get_ports "ra_ready_i"]


set_input_delay  -add_delay -max $INPUT_DELAY_CLK       -clock clk [get_ports "rd_data_i_*"]
set_input_delay  -add_delay -min 0                      -clock clk [get_ports "rd_data_i_*"]

set_input_delay  -add_delay -max $INPUT_DELAY_CLK       -clock clk [get_ports "rd_valid_i"]
set_input_delay  -add_delay -min 0                      -clock clk [get_ports "rd_valid_i"]

set_output_delay -add_delay -max $OUTPUT_DELAY_CLK      -clock clk [get_ports "rd_ready_o"]
set_output_delay -add_delay -min 0                      -clock clk [get_ports "rd_ready_o"]

set_input_delay  -add_delay -max $INPUT_DELAY_CLK       -clock clk [get_ports "p_addr_i"]
set_input_delay  -add_delay -min 0                      -clock clk [get_ports "p_addr_i"]

set_input_delay  -add_delay -max $INPUT_DELAY_CLK       -clock clk [get_ports "p_sel_i"]
set_input_delay  -add_delay -min 0                      -clock clk [get_ports "p_sel_i"]

set_input_delay  -add_delay -max $INPUT_DELAY_CLK       -clock clk [get_ports "p_enable_i"]
set_input_delay  -add_delay -min 0                      -clock clk [get_ports "p_enable_i"]

set_input_delay  -add_delay -max $INPUT_DELAY_CLK       -clock clk [get_ports "p_write_i"]
set_input_delay  -add_delay -min 0                      -clock clk [get_ports "p_write_i"]

set_input_delay  -add_delay -max $INPUT_DELAY_CLK       -clock clk [get_ports "p_wdata_i"]
set_input_delay  -add_delay -min 0                      -clock clk [get_ports "p_wdata_i"]

set_output_delay -add_delay -max $OUTPUT_DELAY_CLK      -clock clk [get_ports "p_ready_o"]
set_output_delay -add_delay -min 0                      -clock clk [get_ports "p_ready_o"]

set_output_delay -add_delay -max $OUTPUT_DELAY_CLK      -clock clk [get_ports "p_rdata_o"]
set_output_delay -add_delay -min 0                      -clock clk [get_ports "p_rdata_o"]

set_output_delay -add_delay -max $OUTPUT_DELAY_CLK      -clock clk [get_ports "p_slverr_o"]
set_output_delay -add_delay -min 0                      -clock clk [get_ports "p_slverr_o"]
