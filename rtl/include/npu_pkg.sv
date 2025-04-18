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

package npu_pkg;

  parameter I_LEN   = 8;         // 8-bit  data input
  parameter O_LEN   = 8;         // 8-bit  data output
  parameter Z_LEN   = 16;        // 16-bit data after zeropoint
  parameter M_LEN   = 32;        // 32-bit data after multiply

  parameter AXI_A_W = 32;        // AXI ADDRESS width
  parameter AXI_D_W = 256;       // AXI DATA    width
  parameter AXI_S_W = AXI_D_W/8; // STRB        width

  // for CSR:
  parameter T_LEN   = 11;        // 11-bit for tensor size:
                                 //              COL   ROW   DEPTH
                                 // data matrix [512]x[512]x[  32];
                                 // conv core   [ 16]x[ 16]x[  32];
                                 // result      [512]x[512]x[1024];

  parameter APB_A_W = 32;        // APB ADDRESS width
  parameter APB_D_W = 32;        // APB DATA    width

  parameter CSRR_OP = 1'b0;      // APB READ
  parameter CSRW_OP = 1'b1;      // APB WRITE

endpackage
