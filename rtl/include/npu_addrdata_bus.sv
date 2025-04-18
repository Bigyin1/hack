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

`ifndef ADDRDATA_BUS_SV
`define ADDRDATA_BUS_SV

  import npu_pkg::AXI_A_W;
  import npu_pkg::AXI_D_W;
  import npu_pkg::AXI_S_W;

interface ADDRDATA_BUS_SV #();

  ////////////////////////////////////////////////////////////
  //                      Write channel                     //
  ////////////////////////////////////////////////////////////

  logic               w_valid;
  logic               w_ready;
  logic [AXI_A_W-1:0] w_addr;
  logic [AXI_D_W-1:0] w_data;
  logic [AXI_S_W-1:0] w_strb;
//logic               w_resp;

  ////////////////////////////////////////////////////////////
  //                      Read channel                      //
  ////////////////////////////////////////////////////////////

  logic               r_valid;
  logic               r_ready;
  logic              rd_ready;
  logic [AXI_A_W-1:0] r_addr;
  logic [AXI_D_W-1:0] r_data;

  ////////////////////////////////////////////////////////////
  //                      Master Side                       //
  ////////////////////////////////////////////////////////////

  modport Master
  (

    // Write channel:
    output w_valid, output w_addr, output w_data, output w_strb,
    input  w_ready, /*input  w_resp,*/

    // Read  channel:
    output r_valid, output r_addr, output rd_ready,
    input  r_ready, input  r_data

  );

  ////////////////////////////////////////////////////////////
  //                       Slave Side                       //
  ////////////////////////////////////////////////////////////

  modport Slave
  (

    // Write channel:
    input  w_valid, input  w_addr, input w_data, input w_strb,
    output w_ready, /*output w_resp,*/

    // Read  channel:
    input  r_valid, input  r_addr, input rd_ready,
    output r_ready, output r_data

  );

 endinterface

 `endif
