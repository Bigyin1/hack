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

module npu_relu
  import npu_pkg::M_LEN;
(
  input  logic signed [M_LEN-1:0] data_i,
  output logic signed [M_LEN-1:0] data_o,

  input  logic                    valid_i,
  output logic                    valid_o
);

  assign valid_o = valid_i;

  assign data_o = ( $signed(data_i) > 0 ) ? data_i : '0;

endmodule
