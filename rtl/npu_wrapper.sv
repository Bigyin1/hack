/*******************************************************
 * Copyright (C) 2025 National Research University of Electronic Technology (MIET),
 * Institute of Microdevices and Control Systems.
 * All Rights Reserved.
 *
 * This file is part of rtl_npu.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 *******************************************************/

  module npu_wrapper
  import npu_pkg::*;
(
  input  logic clk_i,
  input  logic arstn_i,

  ////////////////
  //  AXI4lite  //
  ////////////////

  // Write address channel
  output logic [2:0]               wa_valid_o,
  input  logic [2:0]               wa_ready_i,
  output logic [2:0] [AXI_A_W-1:0] wa_addr_o,

  // Write data channel
  output logic [2:0]               wd_valid_o,
  input  logic [2:0]               wd_ready_i,
  output logic [2:0] [AXI_D_W-1:0] wd_data_o,
  output logic [2:0] [AXI_S_W-1:0] wd_strb_o,

  // Write response channel
  input  logic [2:0]               wr_valid_i,
  output logic [2:0]               wr_ready_o,

  // Read address channel
  output logic [2:0]               ra_valid_o,
  input  logic [2:0]               ra_ready_i,
  output logic [2:0] [AXI_A_W-1:0] ra_addr_o,

  // Read data channel
  input  logic [2:0]               rd_valid_i,
  output logic [2:0]               rd_ready_o,
  input  logic [2:0] [AXI_D_W-1:0] rd_data_i,

  ////////////////
  // APB slave  //
  ////////////////

  // APB bridge
  input  logic [APB_A_W-1:0] p_addr_i,
  input  logic               p_sel_i,
  input  logic               p_enable_i,
  input  logic               p_write_i,
  input  logic [APB_D_W-1:0] p_wdata_i,

  // Slave interface
  output logic               p_ready_o,
  output logic [APB_D_W-1:0] p_rdata_o,
  output logic               p_slverr_o
);

  // ADDRDATA interface
  APB_BUS_SV csr_apb_slave ();

  // CSR interface
  AXI4LITE_BUS_SV lsu_axi_master [2:0] ();

  ////////////////
  //  AXI4lite  //
  ////////////////

  genvar i;

  generate
    for ( i=0; i<3; i=i+1 ) begin
      assign lsu_axi_master[i].wa_ready = wa_ready_i [i];

      assign lsu_axi_master[i].wd_ready = wd_ready_i [i];

      assign lsu_axi_master[i].wr_valid = wr_valid_i [i];

      assign lsu_axi_master[i].ra_ready = ra_ready_i [i];

      assign lsu_axi_master[i].rd_valid = rd_valid_i [i];
      assign lsu_axi_master[i].rd_data  = rd_data_i  [i];

      ///////////////////////////////////////////////////

      assign wa_valid_o [i] = lsu_axi_master[i].wa_valid;
      assign wa_addr_o  [i] = lsu_axi_master[i].wa_addr;

      assign wd_valid_o [i] = lsu_axi_master[i].wd_valid;
      assign wd_data_o  [i] = lsu_axi_master[i].wd_data;
      assign wd_strb_o  [i] = lsu_axi_master[i].wd_strb;

      assign wr_ready_o [i] = lsu_axi_master[i].wr_ready;

      assign ra_valid_o [i] = lsu_axi_master[i].ra_valid;
      assign ra_addr_o  [i] = lsu_axi_master[i].ra_addr;

      assign rd_ready_o [i] = lsu_axi_master[i].rd_ready;
    end
  endgenerate

  ////////////////
  //  APB slave //
  ////////////////

  assign csr_apb_slave.p_addr   = p_addr_i;
  assign csr_apb_slave.p_sel    = p_sel_i;
  assign csr_apb_slave.p_enable = p_enable_i;
  assign csr_apb_slave.p_write  = p_write_i;
  assign csr_apb_slave.p_wdata  = p_wdata_i;

  //////////////////////////////////////////

  assign p_ready_o  = csr_apb_slave.p_ready;
  assign p_rdata_o  = csr_apb_slave.p_rdata;
  assign p_slverr_o = csr_apb_slave.p_slverr;

  ////////////////
  //     NPU    //
  ////////////////

  npu_top npu       (
    .clk_i          ( clk_i                ),
    .arstn_i        ( arstn_i              ),

    .csr_apb_slave  ( csr_apb_slave        ),

    .lsu_axi_master ( lsu_axi_master [2:0] )
  );

endmodule
