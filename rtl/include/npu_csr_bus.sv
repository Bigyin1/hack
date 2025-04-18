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

`ifndef CSR_BUS_SV
`define CSR_BUS_SV

  import npu_pkg::APB_A_W;
  import npu_pkg::I_LEN;
  import npu_pkg::M_LEN;
  import npu_pkg::T_LEN;

interface CSR_BUS_SV #();

  ////////////////////////////////////////////////////////////
  //                     Status channel                     //
  ////////////////////////////////////////////////////////////

  logic              csr_status;         //  1-bit "1" - calc active / "0" - waiting
  logic              csr_control;        //  1-bit write to MAC activation

  ////////////////////////////////////////////////////////////
  //                  Read address channel                  //
  ////////////////////////////////////////////////////////////

  logic [APB_A_W-1:0] csr_addr_t0;       // 32-bit TENSOR 0: ADDR
  logic [APB_A_W-1:0] csr_addr_t1;       // 32-bit TENSOR 1: ADDR
  logic [APB_A_W-1:0] csr_addr_t2;       // 32-bit TENSOR 2: ADDR

  ////////////////////////////////////////////////////////////
  //                    Read size channel                   //
  ////////////////////////////////////////////////////////////

  logic [T_LEN-2:0] csr_addr_t0_0;       // 10-bit TENSOR 0: ROW
  logic [T_LEN-2:0] csr_addr_t0_1;       // 10-bit TENSOR 0: COL
  logic [T_LEN-6:0] csr_addr_t0_2;       //  6-bit TENSOR 0: DEPTH
  logic [T_LEN-7:0] csr_addr_t1_0;       //  5-bit TENSOR 1: ROW
  logic [T_LEN-7:0] csr_addr_t1_1;       //  5-bit TENSOR 1: COL
  logic [T_LEN-6:0] csr_addr_t1_2;       //  6-bit TENSOR 1: DEPTH
  logic [T_LEN-2:0] csr_addr_t2_0;       // 10-bit TENSOR 2: ROW
  logic [T_LEN-2:0] csr_addr_t2_1;       // 10-bit TENSOR 2: COL
  logic [T_LEN-1:0] csr_addr_t2_2;       // 11-bit TENSOR 2: DEPTH

  ////////////////////////////////////////////////////////////
  //                   Read param channel                   //
  ////////////////////////////////////////////////////////////

  // tensor param registers:
  logic signed [I_LEN-1:0] csr_zp_t0;    //  8-bit TENSOR 0: ZERO_POINT
  logic signed [I_LEN-1:0] csr_zp_t1;    //  8-bit TENSOR 1: ZERO_POINT
  logic signed [I_LEN-1:0] csr_zp_t2;    //  8-bit TENSOR 2: ZERO_POINT

  logic signed [M_LEN-1:0] csr_bias_t2;  // 32-bit TENSOR 2: BIAS
  logic signed [M_LEN-1:0] csr_scale_t2; // 32-bit TENSOR 2: SCALE
  logic        [T_LEN-7:0] csr_shift_t2; //  5-bit TENSOR 2: SHIFT

  ////////////////////////////////////////////////////////////
  //                      Master Side                       //
  ////////////////////////////////////////////////////////////

  modport Master
  (

    // Status channel:
    output csr_status,
    input  csr_control,

    // Read address channel:
    input  csr_addr_t0,
    input  csr_addr_t1,
    input  csr_addr_t2,

    // Write response channel:
    input  csr_addr_t0_0,
    input  csr_addr_t0_1,
    input  csr_addr_t0_2,
    input  csr_addr_t1_0,
    input  csr_addr_t1_1,
    input  csr_addr_t1_2,
    input  csr_addr_t2_0,
    input  csr_addr_t2_1,
    input  csr_addr_t2_2,

    // Read param channel:
    input  csr_zp_t0,
    input  csr_zp_t1,
    input  csr_zp_t2,

    input  csr_bias_t2,
    input  csr_scale_t2,
    input  csr_shift_t2

  );

  ////////////////////////////////////////////////////////////
  //                       Slave Side                       //
  ////////////////////////////////////////////////////////////

  modport Slave
  (

    // Status channel:
    input  csr_status,
    output csr_control,

    // Read address channel:
    output csr_addr_t0,
    output csr_addr_t1,
    output csr_addr_t2,

    // Write response channel:
    output csr_addr_t0_0,
    output csr_addr_t0_1,
    output csr_addr_t0_2,
    output csr_addr_t1_0,
    output csr_addr_t1_1,
    output csr_addr_t1_2,
    output csr_addr_t2_0,
    output csr_addr_t2_1,
    output csr_addr_t2_2,

    // Read param channel:
    output csr_zp_t0,
    output csr_zp_t1,
    output csr_zp_t2,

    output csr_bias_t2,
    output csr_scale_t2,
    output csr_shift_t2

  );

endinterface

`endif
