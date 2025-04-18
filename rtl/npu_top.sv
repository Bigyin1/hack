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

module npu_top
(
  input  logic clk_i,
  input  logic arstn_i,

  APB_BUS_SV.Slave csr_apb_slave, // CSR master side

  AXI4LITE_BUS_SV.Master lsu_axi_master [2:0] // LSU-0,1,2 master side
);

  // ADDRDATA interface
  ADDRDATA_BUS_SV lsu_ad_slave [2:0] ();

  // CSR interface
  CSR_BUS_SV csr_slave ();

  // LSU-0,1,2
  npu_lsu lsu [2:0]   (
    .clk_i            ( clk_i                ),
    .arstn_i          ( arstn_i              ),

    .slave            ( lsu_ad_slave   [2:0] ),

    .master           ( lsu_axi_master [2:0] )
  );

  // MAC
  npu_mac_top mac_top (
    .clk_i            ( clk_i                ),
    .arstn_i          ( arstn_i              ),

    .lsu_master       ( lsu_ad_slave [2:0]   ),

    .csr_master       ( csr_slave            )
  );

  // CSR
  npu_csr csr         (
    .clk_i            ( clk_i                ),
    .arstn_i          ( arstn_i              ),

    .slave_csr        ( csr_slave            ),

    .slave_apb        ( csr_apb_slave        )
  );

endmodule
