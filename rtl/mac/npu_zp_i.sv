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

module npu_zp_i
  import npu_pkg::I_LEN;
  import npu_pkg::Z_LEN;
(
  input  logic signed [I_LEN-1:0] zp_i,

  input  logic signed [I_LEN-1:0] data_i,
  output logic signed [Z_LEN-1:0] data_o,

  input  logic                    valid_i,
  output logic                    valid_o
);

  assign valid_o = valid_i;

  assign data_o = $signed(data_i) + $signed(zp_i);

endmodule
