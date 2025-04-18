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

`ifndef APB_BUS_SV
`define APB_BUS_SV

import npu_pkg::APB_A_W;
import npu_pkg::APB_D_W;

interface APB_BUS_SV #();

  ////////////////////////////////////////////////////////////
  //                       APB bridge                       //
  ////////////////////////////////////////////////////////////

  logic [APB_A_W-1:0] p_addr;   // address
  logic               p_sel;    // 1-slave
  logic               p_enable; // second and subsequent cycles of an APB transfer
  logic               p_write;  // 1-WRITE / 0-READ
  logic [APB_D_W-1:0] p_wdata;

  ////////////////////////////////////////////////////////////
  //                     Slave interface                    //
  ////////////////////////////////////////////////////////////

  logic               p_ready;
  logic [APB_D_W-1:0] p_rdata;
  logic               p_slverr;

  ////////////////////////////////////////////////////////////
  //                      Master Side                       //
  ////////////////////////////////////////////////////////////

  modport Master
  (

    // APB bridge
    output p_addr, output p_sel, output p_enable, output p_write, output p_wdata,

    // Slave interface
    input p_ready, input p_rdata, input p_slverr

  );

  ////////////////////////////////////////////////////////////
  //                       Slave Side                       //
  ////////////////////////////////////////////////////////////

  modport Slave
  (

    // APB bridge
    input p_addr, input p_sel, input p_enable, input p_write, input p_wdata,

    // Slave interface
    output p_ready, output p_rdata, output p_slverr

  );

 endinterface

 `endif
