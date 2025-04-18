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

`ifndef AXI4LITE_BUS_SV
`define AXI4LITE_BUS_SV

import npu_pkg::AXI_A_W;
import npu_pkg::AXI_D_W;
import npu_pkg::AXI_S_W;

interface AXI4LITE_BUS_SV #();

  ////////////////////////////////////////////////////////////
  //                 Write address channel                  //
  ////////////////////////////////////////////////////////////

  logic               wa_valid;
  logic               wa_ready;
  logic [AXI_A_W-1:0] wa_addr;

  ////////////////////////////////////////////////////////////
  //                   Write data channel                   //
  ////////////////////////////////////////////////////////////

  logic               wd_valid;
  logic               wd_ready;
  logic [AXI_D_W-1:0] wd_data;
  logic [AXI_S_W-1:0] wd_strb; // byte enable

  ////////////////////////////////////////////////////////////
  //                 Write response channel                 //
  ////////////////////////////////////////////////////////////

  logic               wr_valid;
  logic               wr_ready;
//logic               wr_resp;

  ////////////////////////////////////////////////////////////
  //                  Read address channel                  //
  ////////////////////////////////////////////////////////////

  logic               ra_valid;
  logic               ra_ready;
  logic [AXI_A_W-1:0] ra_addr;

  ////////////////////////////////////////////////////////////
  //                   Read data channel                    //
  ////////////////////////////////////////////////////////////

  logic               rd_valid;
  logic               rd_ready;
  logic [AXI_D_W-1:0] rd_data;
//logic               rd_resp;

  ////////////////////////////////////////////////////////////
  //                      Master Side                       //
  ////////////////////////////////////////////////////////////

  modport Master
  (

    // Write address channel:
    output wa_valid, output wa_addr,
    input  wa_ready,

    // Write data channel:
    output wd_valid, output wd_data, output wd_strb,
    input  wd_ready,

    // Write response channel:
    input  wr_valid, /*input  wr_resp,*/
    output wr_ready,

    // Read address channel:
    output ra_valid, output ra_addr,
    input  ra_ready,

    // Read data channel:
    input  rd_valid, input  rd_data,/* input  rd_resp,*/
    output rd_ready

  );

  ////////////////////////////////////////////////////////////
  //                       Slave Side                       //
  ////////////////////////////////////////////////////////////

  modport Slave
  (

    // Write address channel:
    input  wa_valid, input  wa_addr,
    output wa_ready,

    // Write data channel:
    input  wd_valid, input  wd_data, input  wd_strb,
    output wd_ready,

    // Write response channel:
    output wr_valid, /*output wr_resp,*/
    input  wr_ready,

    // Read address channel:
    input  ra_valid, input  ra_addr,
    output ra_ready,

    // Read data channel:
    output rd_valid, output rd_data,/* output rd_resp,*/
    input  rd_ready

  );

endinterface

`endif
