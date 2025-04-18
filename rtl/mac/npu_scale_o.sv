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

module npu_sc_o
  import npu_pkg::M_LEN;
  import npu_pkg::T_LEN;
(
  input  logic        [T_LEN-7:0] shift_i,
  input  logic signed [M_LEN-1:0] scale_i,

  input  logic signed [M_LEN-1:0] data_i,
  output logic signed [M_LEN-1:0] data_o,

  input  logic                    valid_i,
  output logic                    valid_o
);

  logic signed [M_LEN*2-1:0] p_m_f;

  assign valid_o = valid_i;

  assign p_m_f = ( $signed(data_i) * $signed(scale_i) ) >>> 'd31 >>> shift_i;

  assign data_o = p_m_f[M_LEN-1:0];

endmodule
