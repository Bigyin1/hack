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

module npu_mac
  import npu_pkg::*;
(
  input  logic                    clk_i,
  input  logic                    arstn_i,

  input  logic                    clear_i,

  // for input data (t0,t1):
  input  logic signed [I_LEN-1:0] zp_t0_i, // t0 zeropoint input
  input  logic signed [I_LEN-1:0] zp_t1_i, // t1 zeropoint input

  input  logic                    t0_v_i,  // t0 data valid input
  input  logic signed [I_LEN-1:0] t0_i,    // t0 data input
  input  logic                    t1_v_i,  // t1 convloution core valid input
  input  logic signed [I_LEN-1:0] t1_i,    // t1 convloution core input

  // for output data (t2):
  input  logic signed [I_LEN-1:0] zp_t2_i, // t2 zeropoint input

  input  logic signed [M_LEN-1:0] bi_t2_i, // t2 bias input

  input  logic signed [M_LEN-1:0] sc_t2_i, // t2 scale input
  input  logic        [T_LEN-7:0] sc_sh_i, // t2 shift

  output logic                    t2_v_o,  // t2 valid convolution result
  output logic signed [O_LEN-1:0] t2_o     // t2 convolution result
);

  ////////////////////////////////////////////////////////////
  //                  data input zero point                 //
  ////////////////////////////////////////////////////////////

  logic signed [Z_LEN-1:0] t0_zp;   // t0 data after zeropoint
  logic                    t0_v_zp; // t0 data after zeropoint valid

  // zero point for t0 data input:
  npu_zp_i t0_i_zp (
    .zp_i    ( zp_t0_i ),

    .data_i  ( t0_i    ),
    .data_o  ( t0_zp   ),

    .valid_i ( t0_v_i  ),
    .valid_o ( t0_v_zp )
  );

  ////////////////////////////////////////////////////////////
  //            convloution core input zero point           //
  ////////////////////////////////////////////////////////////

  logic signed [Z_LEN-1:0] t1_zp;   // t1 convloution core after zeropoint
  logic                    t1_v_zp; // t1 convloution core after zeropoint valid

  // zero point for t1 convloution core input:
  npu_zp_i t1_i_zp (
    .zp_i    ( zp_t1_i ),

    .data_i  ( t1_i    ),
    .data_o  ( t1_zp   ),

    .valid_i ( t1_v_i  ),
    .valid_o ( t1_v_zp )
  );

  ////////////////////////////////////////////////////////////
  //                     multiplication                     //
  ////////////////////////////////////////////////////////////

  logic signed [M_LEN-1:0] mult;   // multiply result
  logic                    mult_v; // multiply result valid

  assign mult   = $signed(t0_zp) * $signed(t1_zp);
  assign mult_v = t0_v_zp && t1_v_zp;

  ////////////////////////////////////////////////////////////
  //                           sum                          //
  ////////////////////////////////////////////////////////////

  logic signed [M_LEN-1:0] sum;      // partial sum
  logic                    sum_v;    // partial sum valid

  logic signed [M_LEN-1:0] sum_ff;   // partial sum register
  logic                    sum_v_ff; // partial sum register valid

  logic signed [M_LEN-1:0] sum_ovf;  // partial sum with overflow
  logic                    ovf_p_l;  // positive overflow
  logic                    ovf_n_l;  // negative overflow

  assign sum_ovf = $signed(sum_ff) + $signed(mult);

  // adder overflow control:
  assign ovf_p_l = ~sum_ff[M_LEN-1] & ~mult[M_LEN-1] &  sum_ovf[M_LEN-1];
  assign ovf_n_l =  sum_ff[M_LEN-1] &  mult[M_LEN-1] & ~sum_ovf[M_LEN-1];

  // checking for adder overflow:
  assign sum = ovf_p_l ? $signed({1'b0,{(M_LEN-1){1'b1}}}) : // if adder is positive overflowed, the entire result[M_LEN-1:0] is filled with largest positive number
               ovf_n_l ? $signed({1'b1,{(M_LEN-1){1'b0}}}) : // if adder is negative overflowed, the entire result[M_LEN-1:0] is filled with largest negative number
                         $signed(sum_ovf);

  assign sum_v = mult_v;

  always_ff @( posedge clk_i ) begin
    if ( ~arstn_i || clear_i ) begin
      sum_v_ff <= '0;
    end
    else begin
      if ( sum_v )
      sum_v_ff <= sum_v;
    end
  end

  always_ff @( posedge clk_i ) begin
    if ( ~arstn_i || clear_i ) begin
      sum_ff <= '0;
    end
    else begin
      if ( sum_v ) begin
        sum_ff <= sum;
      end
    end
  end

  ////////////////////////////////////////////////////////////
  //                          bias                          //
  ////////////////////////////////////////////////////////////

  logic signed [M_LEN-1:0] t2_bi;   // t2 data after bias
  logic                    t2_v_bi; //

  // bias for t2 data output:
  npu_bi_o t2_o_bi (
    .bias_i  ( bi_t2_i ),

    .data_i  ( sum_ff  ),
    .data_o  ( t2_bi   ),

    .valid_i ( sum_v_ff),
    .valid_o ( t2_v_bi )
  );

  ////////////////////////////////////////////////////////////
  //                          scale                         //
  ////////////////////////////////////////////////////////////

  logic signed [M_LEN-1:0] t2_sc;   // t2 data after scale
  logic                    t2_v_sc; //

  // scale for t2 data output:
  npu_sc_o t2_o_sc (
    .shift_i ( sc_sh_i ),
    .scale_i ( sc_t2_i ),

    .data_i  ( t2_bi   ),
    .data_o  ( t2_sc   ),

    .valid_i ( t2_v_bi ),
    .valid_o ( t2_v_sc )
  );

  ////////////////////////////////////////////////////////////
  //                       activation                       //
  ////////////////////////////////////////////////////////////

  logic signed [M_LEN-1:0] t2_act;   // t2 data after scale
  logic                    t2_v_act; //

  // scale for t2 data output:
  npu_relu relu (
    .data_i  ( t2_sc    ),
    .data_o  ( t2_act   ),

    .valid_i ( t2_v_sc  ),
    .valid_o ( t2_v_act )
  );

  ////////////////////////////////////////////////////////////
  //                   output zero point                    //
  ////////////////////////////////////////////////////////////

  logic signed [O_LEN-1:0] t2_zp;   // t2 data after scale
  logic                    t2_v_zp; //

  // zeropoint for t2 data output:
  npu_zp_o t2_o_zp (
    .zp_i    ( zp_t2_i  ),

    .data_i  ( t2_act   ),
    .data_o  ( t2_zp    ),

    .valid_i ( t2_v_act ),
    .valid_o ( t2_v_zp  )
  );

  assign t2_o   = t2_zp;
  assign t2_v_o = t2_v_zp;

endmodule
