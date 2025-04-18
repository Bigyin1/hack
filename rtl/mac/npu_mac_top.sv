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

module npu_mac_top
  import npu_pkg::*;
(
  input  logic            clk_i,
  input  logic            arstn_i,

  // LSU interface
  ADDRDATA_BUS_SV.Master  lsu_master [2:0],

  // CSR interface
  CSR_BUS_SV.Master       csr_master
);

  logic             clear;

  logic             t0_valid;
  logic [I_LEN-1:0] t0_data;

  logic             t1_valid;
  logic [I_LEN-1:0] t1_data;

  logic             t2_valid;
  logic [O_LEN-1:0] t2_data;

  // CU
  npu_cu cu (
    .clk_i        ( clk_i              ),
    .arstn_i      ( arstn_i            ),

    .clear_o      ( clear              ),

    // LSU 0,1,2
    .lsu_master   ( lsu_master [2:0]   ),

    // CSR interface
    .csr_master   ( csr_master         ),

    // MAC
    .t0_v_o       ( t0_valid           ),
    .t0_o         ( t0_data            ),
    .t1_v_o       ( t1_valid           ),
    .t1_o         ( t1_data            ),

    .t2_v_i       ( t2_valid           ),
    .t2_i         ( t2_data            )
  );

  // MAC
  npu_mac mac (
    .clk_i   ( clk_i                   ),
    .arstn_i ( arstn_i                 ),

    .clear_i ( clear                   ),

    // for input data (t0,t1):
    .zp_t0_i ( csr_master.csr_zp_t0    ),
    .zp_t1_i ( csr_master.csr_zp_t1    ),

    .t0_v_i  ( t0_valid                ),
    .t0_i    ( t0_data                 ),
    .t1_v_i  ( t1_valid                ),
    .t1_i    ( t1_data                 ),

    // for output data (t2):
    .zp_t2_i ( csr_master.csr_zp_t2    ),

    .bi_t2_i ( csr_master.csr_bias_t2  ),

    .sc_t2_i ( csr_master.csr_scale_t2 ),
    .sc_sh_i ( csr_master.csr_shift_t2 ),

    .t2_v_o  ( t2_valid                ),
    .t2_o    ( t2_data                 )
  );

endmodule
