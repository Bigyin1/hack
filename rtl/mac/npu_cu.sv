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

  module npu_cu

  import npu_pkg::O_LEN;
  import npu_pkg::I_LEN;
  import npu_pkg::T_LEN;
  import npu_pkg::AXI_A_W;
  import npu_pkg::AXI_D_W;
  import npu_pkg::AXI_S_W;

(
  input  logic clk_i,
  input  logic arstn_i,

  // control
  output logic clear_o,

  // LSU interface
  ADDRDATA_BUS_SV.Master lsu_master [2:0],

  // CSR interface
  CSR_BUS_SV.Master csr_master,

  // MAC
  output logic                    t0_v_o, // t0 data valid input
  output logic signed [I_LEN-1:0] t0_o,   // t0 data input
  output logic                    t1_v_o, // t1 convloution core valid input
  output logic signed [I_LEN-1:0] t1_o,   // t1 convloution core input

  input  logic                    t2_v_i, // t2 valid convolution result
  input  logic signed [O_LEN-1:0] t2_i    // t2 convolution result
);

  logic finish;

  ////////////////////////////////////////////////////////////

  // TENSOR adress registers:
  logic [AXI_A_W-1:0] addr_t0_ff;
  logic [AXI_A_W-1:0] addr_t1_ff;
  logic [AXI_A_W-1:0] addr_t2_ff;

  ////////////////////////////////////////////////////////////

  // LSU READ
  logic lsu_0_rd_hs;
  logic lsu_1_rd_hs;
//logic lsu_2_rd_hs;

  logic lsu_0_rd_hs_ff;
  logic lsu_1_rd_hs_ff;
//logic lsu_2_rd_hs_ff;

  logic lsu_0_r_ready;
  logic lsu_1_r_ready;
//logic lsu_2_r_ready;

  logic [255:0][I_LEN-1:0] lsu_0_r_data;
  logic [255:0][I_LEN-1:0] lsu_1_r_data;
//logic [255:0][I_LEN-1:0] lsu_2_r_data;

  ////////////////////////////////////////////////////////////

  // LSU WRITE
//logic lsu_0_wd_hs;
//logic lsu_1_wd_hs;
  logic lsu_2_wd_hs;

//logic lsu_0_w_ready;
//logic lsu_1_w_ready;
//logic lsu_2_w_ready;

//logic [255:0] lsu_0_w_strb;
//logic [255:0] lsu_1_w_strb;
  logic [255:0] lsu_2_w_strb;

//logic [255:0][O_LEN-1:0] lsu_0_w_data;
//logic [255:0][O_LEN-1:0] lsu_1_w_data;
  logic [255:0][O_LEN-1:0] lsu_2_w_data;

  ////////////////////////////////////////////////////////////

  // ADDR shifting
  logic [AXI_A_W-1:0] addr_t0;

  logic [AXI_A_W-1:0] first_el;
  logic [AXI_A_W-1:0] last_el;

  logic [AXI_A_W-1:0] first_el_ff;
  logic [AXI_A_W-1:0] last_el_ff;

  ////////////////////////////////////////////////////////////

  // TENSOR read / write data
  logic [I_LEN-1:0] t0_r_data;
  logic [I_LEN-1:0] t1_r_data;
  logic [O_LEN-1:0] t2_w_data;

  // TENSOR read / write valid
  logic [I_LEN-1:0] t0_r_valid;
  logic [I_LEN-1:0] t1_r_valid;
  logic [O_LEN-1:0] t2_w_valid;

  ////////////////////////////////////////////////////////////

  logic iter_stall;

  logic iter_i_stall;
  logic iter_j_stall;
  logic iter_k_stall;

  logic iter_i_stall_ff;
  logic iter_j_stall_ff;
  logic iter_k_stall_ff;

  logic iter_i_en;
  logic iter_j_en;
  logic iter_k_en;
  logic iter_n_en;
  logic iter_m_en;

  logic [T_LEN-7:0] iter_i; // i ∈ [0:(T1_ROW - 1)]
  logic [T_LEN-2:0] iter_j; // j ∈ [0:(T2_COL - 1)]
  logic [T_LEN-2:0] iter_k; // k ∈ [0:(T2_ROW - 1)]
  logic [T_LEN-6:0] iter_n; // n ∈ [0:(T1_DP  - 1)]
  logic [T_LEN-6:0] iter_m; // m ∈ [0:(T0_DP  - 1)]

  ////////////////////////////////////////////////////////////
  //                NPU Finite State Machine                //
  ////////////////////////////////////////////////////////////

  enum logic [1:0] {NPU_IDLE, NPU_CALC} npu_state, npu_next_state;

  logic npu_idle;
  logic npu_calc;

  assign npu_idle = ( ( npu_state      == NPU_IDLE ) ||
                      ( npu_next_state == NPU_IDLE ) );

  assign npu_calc = ( ( npu_state      == NPU_CALC ) ||
                      ( npu_next_state == NPU_CALC ) ) && ~lsu_2_wd_hs;

  assign csr_master.csr_status = npu_state[0];

  // FSM current state:
  always_ff @( posedge clk_i ) begin
    if ( ~arstn_i ) begin
      npu_state <= NPU_IDLE;
    end
    else begin
      npu_state <= npu_next_state;
    end
  end

  always_comb begin
    npu_next_state = npu_state;

    case ( npu_state )

      NPU_IDLE: if ( csr_master.csr_control ) npu_next_state = NPU_CALC; // write to CONTROL CSR in NPU_IDLE state start the calc

      NPU_CALC: if ( finish && lsu_2_wd_hs ) npu_next_state = NPU_IDLE;

    endcase
  end

  ////////////////////////////////////////////////////////////
  //                          LSU 0                         //
  ////////////////////////////////////////////////////////////

  // LSU_WRITE_0:
  assign lsu_master[0].w_valid  = '0; // output
  assign lsu_master[0].w_addr   = '0; // output
  assign lsu_master[0].w_data   = '0; // output
  assign lsu_master[0].w_strb   = '0; // output

//assign lsu_0_wd_hs = lsu_master[0].w_ready; // input

  // LSU_READ_0:
  assign lsu_master[0].r_valid  = npu_calc && ~iter_stall;
  assign lsu_master[0].r_addr   = { addr_t0_ff[AXI_A_W-1:5], 5'b0 }; // alignment across memory lines
  assign lsu_master[0].rd_ready = lsu_0_rd_hs;

  assign lsu_0_r_ready = lsu_master[0].r_ready;
  assign lsu_0_r_data  = lsu_master[0].r_data;

  ////////////////////////////////////////////////////////////
  //                          LSU 1                         //
  ////////////////////////////////////////////////////////////

  // LSU_WRITE_1:
  assign lsu_master[1].w_valid  = '0; // output
  assign lsu_master[1].w_addr   = '0; // output
  assign lsu_master[1].w_data   = '0; // output
  assign lsu_master[1].w_strb   = '0; // output

//assign lsu_1_wd_hs = lsu_master[1].w_ready; // input

  // LSU_READ_1:
  assign lsu_master[1].r_valid  = npu_calc && ~iter_stall;
  assign lsu_master[1].r_addr   = { addr_t1_ff[AXI_A_W-1:5], 5'b0 }; // alignment across memory lines
  assign lsu_master[1].rd_ready = lsu_1_rd_hs;

  assign lsu_1_r_ready = lsu_master[1].r_ready;
  assign lsu_1_r_data  = lsu_master[1].r_data;

  ////////////////////////////////////////////////////////////
  //                          LSU 2                         //
  ////////////////////////////////////////////////////////////

  // LSU_WRITE_2:
  assign lsu_master[2].w_valid  = ( iter_j_en || iter_k_en ) && t2_w_valid; // output
  assign lsu_master[2].w_addr   = { addr_t2_ff[AXI_A_W-1:5], 5'b0 }; // alignment across memory lines
  assign lsu_master[2].w_data   = lsu_2_w_data; // output
  assign lsu_master[2].w_strb   = lsu_2_w_strb; // output

//assign lsu_2_w_ready = lsu_master[2].w_ready; // input
//assign lsu_2_wd_hs   = lsu_master[2].w_resp;  // input
  assign lsu_2_wd_hs   = lsu_master[2].w_ready; // input

  // LSU_READ_2:
  assign lsu_master[2].r_valid  = '0;
  assign lsu_master[2].r_addr   = '0;

//assign lsu_2_r_ready = lsu_master[2].r_ready;
//assign lsu_2_r_data  = lsu_master[2].r_data;

  ////////////////////////////////////////////////////////////
  //                       HANDSHAKEs                       //
  ////////////////////////////////////////////////////////////

  assign lsu_0_rd_hs = lsu_0_r_ready && lsu_1_r_ready;
  assign lsu_1_rd_hs = lsu_0_r_ready && lsu_1_r_ready;

  ////////////////////////////////////////////////////////////
  //                          ITERs                         //
  ////////////////////////////////////////////////////////////

  always_ff @( posedge clk_i ) begin
    if( ~arstn_i ) begin
      iter_i <= '0;
    end
    else begin
      if ( npu_state == NPU_IDLE ) begin
        iter_i <= '0;
      end
      else if ( ( iter_j_en || iter_k_en || iter_n_en || iter_m_en ) && lsu_2_wd_hs ) begin
        iter_i <= '0;
      end
      else if ( lsu_0_rd_hs && lsu_1_rd_hs && ( ~iter_j_en && ~iter_k_en ) ) begin
        if ( iter_i_en && ~iter_i_stall_ff ) begin
          iter_i <= iter_i + 'd1;
        end
      end
    end
  end

  always_ff @( posedge clk_i ) begin
    if( ~arstn_i ) begin
      iter_j <= '0;
    end
    else begin
      if ( npu_state == NPU_IDLE ) begin
        iter_j <= '0;
      end
      else if ( ( iter_k_en || iter_n_en || iter_m_en ) && lsu_2_wd_hs ) begin
        iter_j <= '0;
      end
      else if ( lsu_2_wd_hs ) begin
        if ( iter_j == csr_master.csr_addr_t2_1 ) begin
          iter_j <= '0;
        end
        else if ( iter_j_en ) begin
          iter_j <= iter_j + 'd1;
        end
      end
    end
  end

  always_ff @( posedge clk_i ) begin
    if( ~arstn_i ) begin
      iter_k <= '0;
    end
    else begin
      if ( npu_state == NPU_IDLE ) begin
        iter_k <= '0;
      end
      else if ( ( iter_n_en || iter_m_en ) && lsu_2_wd_hs ) begin
        iter_k <= '0;
      end
      else if ( lsu_2_wd_hs ) begin
        if ( iter_k == csr_master.csr_addr_t2_0 ) begin
          iter_k <= '0;
        end
        else if ( iter_k_en ) begin
          iter_k <= iter_k + 'd1;
        end
      end
    end
  end

  always_ff @( posedge clk_i ) begin
    if( ~arstn_i ) begin
      iter_n <= '0;
    end
    else begin
      if ( npu_state == NPU_IDLE ) begin
        iter_n <= '0;
      end
      else if ( iter_m_en && lsu_2_wd_hs ) begin
        iter_n <= '0;
      end
      else if ( lsu_2_wd_hs ) begin
        if ( iter_n_en ) begin
          iter_n <= iter_n + 'd1;
        end
      end
    end
  end

    always_ff @( posedge clk_i ) begin
    if( ~arstn_i ) begin
      iter_m <= '0;
    end
    else begin
      if ( npu_state == NPU_IDLE ) begin
        iter_m <= '0;
      end
      else if ( lsu_2_wd_hs ) begin
        if ( iter_m == csr_master.csr_addr_t0_2 ) begin
          iter_m <= '0;
        end
        else if ( iter_m_en ) begin
          iter_m <= iter_m + 'd1;
        end
      end
    end
  end

  ////////////////////////////////////////////////////////////
  //                 TENSOR 0 ADDRESS SHIFT                 //
  ////////////////////////////////////////////////////////////

  assign iter_stall   = iter_i_stall_ff || iter_j_stall_ff || iter_k_stall_ff || (iter_i_en && iter_j_en );
  assign iter_i_stall = ( iter_i_en && lsu_0_rd_hs && lsu_1_rd_hs && ~iter_j_en );
  assign iter_j_stall = ( iter_j_en && lsu_2_wd_hs );
  assign iter_k_stall = ( iter_k_en && lsu_2_wd_hs );

  always_ff @( posedge clk_i ) begin
    if( ~arstn_i ) begin
      iter_i_stall_ff <= '0;
      iter_j_stall_ff <= '0;
      iter_k_stall_ff <= '0;
    end
    else begin
      iter_i_stall_ff <= iter_i_stall;
      iter_j_stall_ff <= iter_j_stall;
      iter_k_stall_ff <= iter_k_stall;
    end
  end

  assign finish = ( addr_t0_ff == last_el_ff               ) &&
                  ( iter_i == csr_master.csr_addr_t1_0     ) &&
                  ( iter_j == csr_master.csr_addr_t2_1 - 1 ) &&
                  ( iter_k == csr_master.csr_addr_t2_0 - 1 ) &&
                  ( iter_n == csr_master.csr_addr_t1_2 - 1 ) &&
                  ( iter_m == csr_master.csr_addr_t0_2 - 1 );

  assign first_el = ( csr_master.csr_addr_t0 + iter_j ) + ( csr_master.csr_addr_t0_0 * csr_master.csr_addr_t0_1 * iter_m ) + ( csr_master.csr_addr_t0_1 * ( iter_i + iter_k ) );
  assign last_el  = ( csr_master.csr_addr_t0 + iter_j ) + ( csr_master.csr_addr_t0_0 * csr_master.csr_addr_t0_1 * iter_m ) + ( csr_master.csr_addr_t0_1 * ( iter_i + iter_k ) ) + ( ( csr_master.csr_addr_t1_1 - 1 ) );

  always_comb begin
    case ( npu_state )

      NPU_CALC: begin
        iter_i_en = (   addr_t0_ff == last_el_ff );                                                 // i ∈ [0:(T1_ROW - 1)]
        iter_j_en = ( ( addr_t0_ff == last_el_ff ) && ( iter_i == csr_master.csr_addr_t1_0     ) ); // j ∈ [0:(T2_COL - 1)]
        iter_k_en = ( ( addr_t0_ff == last_el_ff ) && ( iter_i == csr_master.csr_addr_t1_0     )
                                                   && ( iter_j == csr_master.csr_addr_t2_1 - 1 ) ); // k ∈ [0:(T2_ROW - 1)]
        iter_n_en = ( ( addr_t0_ff == last_el_ff ) && ( iter_i == csr_master.csr_addr_t1_0     )
                                                   && ( iter_j == csr_master.csr_addr_t2_1 - 1 )
                                                   && ( iter_k == csr_master.csr_addr_t2_0 - 1 ) ); // n ∈ [0:(T1_DP  - 1)]
        iter_m_en = ( ( addr_t0_ff == last_el_ff ) && ( iter_i == csr_master.csr_addr_t1_0     )
                                                   && ( iter_j == csr_master.csr_addr_t2_1 - 1 )
                                                   && ( iter_k == csr_master.csr_addr_t2_0 - 1 )
                                                   && ( iter_n == csr_master.csr_addr_t1_2 - 1 ) ); // m ∈ [0:(T0_DP  - 1)]
      end

      default: begin // NPU_IDLE
        iter_i_en = 1'b0;
        iter_j_en = 1'b0;
        iter_k_en = 1'b0;
        iter_n_en = 1'b0;
        iter_m_en = 1'b0;
      end

    endcase
  end

  always_ff @( posedge clk_i ) begin
    if( ~arstn_i ) begin
      first_el_ff <= '0;
      last_el_ff  <= '0;
    end
    else begin
      if ( ~iter_j_en ) begin
        first_el_ff <= first_el;
        last_el_ff  <= last_el;
      end
    end
  end

  always_ff @( posedge clk_i ) begin
    if( ~arstn_i ) begin
      addr_t0_ff <= '0;
    end
    else begin
      if ( npu_state == NPU_IDLE ) begin
        addr_t0_ff <= csr_master.csr_addr_t0;
      end
      else if ( ( iter_i_stall_ff && ~iter_j_en ) || ( iter_j_stall_ff && ~iter_k_en ) || iter_k_stall_ff ) begin
        addr_t0_ff <= first_el;
      end
      else if ( npu_state == NPU_CALC ) begin
        if ( lsu_0_rd_hs && lsu_1_rd_hs && ( ~iter_j_en && ~iter_k_en && ~iter_n_en && ~iter_m_en ) ) begin
          if ( addr_t0_ff < last_el_ff ) begin
            addr_t0_ff <= addr_t0_ff + 1'b1;
          end
        end
      end
    end
  end

  ////////////////////////////////////////////////////////////
  //                 TENSOR 1 ADDRESS SHIFT                 //
  ////////////////////////////////////////////////////////////

  always_ff @( posedge clk_i ) begin
    if( ~arstn_i ) begin
      addr_t1_ff <= '0;
    end
    else begin
      if ( npu_state == NPU_IDLE ) begin
        addr_t1_ff <= csr_master.csr_addr_t1;
      end
      else if ( iter_j_stall_ff || iter_k_stall_ff ) begin
        addr_t1_ff <= csr_master.csr_addr_t1 + ( csr_master.csr_addr_t1_0 * csr_master.csr_addr_t1_1 * iter_n );
      end
      else if ( npu_state == NPU_CALC ) begin
        if ( lsu_0_rd_hs && lsu_1_rd_hs && ( ~iter_j_en && ~iter_k_en && ~iter_n_en && ~iter_m_en ) ) begin
          if ( ~iter_j_en && ~iter_k_en && ~iter_n_en && ~iter_m_en ) begin
            addr_t1_ff <= addr_t1_ff + 1'b1;
          end
        end
      end
    end
  end

  ////////////////////////////////////////////////////////////
  //                 TENSOR 2 ADDRESS SHIFT                 //
  ////////////////////////////////////////////////////////////

  always_ff @( posedge clk_i ) begin
    if( ~arstn_i ) begin
      addr_t2_ff <= '0;
    end
    else begin
      if ( npu_state == NPU_IDLE ) begin
        addr_t2_ff <= csr_master.csr_addr_t2;
      end
      else if ( npu_state == NPU_CALC ) begin
        if ( lsu_2_wd_hs ) begin
          if ( iter_j_en || iter_k_en || iter_n_en || iter_m_en ) begin
            addr_t2_ff <= addr_t2_ff + 1'b1;
          end
        end
      end
    end
  end

  ////////////////////////////////////////////////////////////
  //                     INPUT DATA MUX                     //
  ////////////////////////////////////////////////////////////

  always_comb begin
    t0_r_data = '0;
    t1_r_data = '0;

    for (int i = 0; i < AXI_S_W; i = i + 1) begin
      if ( addr_t0_ff[4:0] == i ) t0_r_data = lsu_0_r_data[i];
      if ( addr_t1_ff[4:0] == i ) t1_r_data = lsu_1_r_data[i];
    end
  end

  ////////////////////////////////////////////////////////////
  //                    OUTPUT DATA MUX                     //
  ////////////////////////////////////////////////////////////

  always_comb begin
    lsu_2_w_data = '0;
    lsu_2_w_strb = '0;

    for (int i = 0; i < AXI_S_W; i = i + 1) begin
      if ( addr_t2_ff[4:0] == i ) lsu_2_w_data[i] = t2_w_data;
      if ( addr_t2_ff[4:0] == i ) lsu_2_w_strb[i] = '1;
    end
  end

  ////////////////////////////////////////////////////////////
  //                       MAC CONTROL                      //
  ////////////////////////////////////////////////////////////

  assign clear_o = lsu_2_wd_hs;

  assign t0_r_valid = lsu_0_rd_hs && lsu_1_rd_hs && ( ~iter_j_en && ~iter_k_en );
  assign t1_r_valid = lsu_0_rd_hs && lsu_1_rd_hs && ( ~iter_j_en && ~iter_k_en );

  assign t0_v_o = t0_r_valid;
  assign t0_o   = t0_r_data;
  assign t1_v_o = t1_r_valid;
  assign t1_o   = t1_r_data;

  assign t2_w_valid = t2_v_i;
  assign t2_w_data  = t2_i;

endmodule
