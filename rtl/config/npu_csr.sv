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

module npu_csr
  import npu_pkg::*;
(
  input            clk_i,
  input            arstn_i,

  // MAC interface
  CSR_BUS_SV.Slave slave_csr,

  // APB interface
  APB_BUS_SV.Slave slave_apb
);

  ////////////////////////////////////////////////////////////
  //                Control-status registers                //
  ////////////////////////////////////////////////////////////

  // status registers:
  logic csr_status;                      //  1-bit "1" - calc active / "0" - waiting

  // tensor address registers:
  logic [APB_A_W-1:0] csr_addr_t0;       // 32-bit TENSOR 0: ADDR
  logic [APB_A_W-1:0] csr_addr_t1;       // 32-bit TENSOR 1: ADDR
  logic [APB_A_W-1:0] csr_addr_t2;       // 32-bit TENSOR 2: ADDR

  // tensor size registers:
  logic [T_LEN-2:0] csr_addr_t0_0;       // 10-bit TENSOR 0: ROW
  logic [T_LEN-2:0] csr_addr_t0_1;       // 10-bit TENSOR 0: COL
  logic [T_LEN-6:0] csr_addr_t0_2;       //  6-bit TENSOR 0: DEPTH
  logic [T_LEN-7:0] csr_addr_t1_0;       //  5-bit TENSOR 1: ROW
  logic [T_LEN-7:0] csr_addr_t1_1;       //  5-bit TENSOR 1: COL
  logic [T_LEN-6:0] csr_addr_t1_2;       //  6-bit TENSOR 1: DEPTH
  logic [T_LEN-2:0] csr_addr_t2_0;       // 10-bit TENSOR 2: ROW
  logic [T_LEN-2:0] csr_addr_t2_1;       // 10-bit TENSOR 2: COL
  logic [T_LEN-1:0] csr_addr_t2_2;       // 11-bit TENSOR 2: DEPTH

  // tensor param registers:
  logic signed [I_LEN-1:0] csr_zp_t0;    //  8-bit TENSOR 0: ZERO_POINT
  logic signed [I_LEN-1:0] csr_zp_t1;    //  8-bit TENSOR 1: ZERO_POINT
  logic signed [I_LEN-1:0] csr_zp_t2;    //  8-bit TENSOR 2: ZERO_POINT

  logic signed [M_LEN-1:0] csr_bias_t2;  // 32-bit TENSOR 2: BIAS
  logic signed [M_LEN-1:0] csr_scale_t2; // 32-bit TENSOR 2: SCALE
  logic        [T_LEN-7:0] csr_shift_t2; //  5-bit TENSOR 2: SHIFT

  ////////////////////////////////////////////////////////////

  // status:
  logic CSR_STATUS;                      //  1-bit "1" - calc active / "0" - waiting
  logic CSR_CONTROL;                     //  1-bit write to MAC activation

  // tensor address:
  logic [APB_A_W-1:0] CSR_ADDR_T0;       // 32-bit TENSOR 0: ADDR
  logic [APB_A_W-1:0] CSR_ADDR_T1;       // 32-bit TENSOR 1: ADDR
  logic [APB_A_W-1:0] CSR_ADDR_T2;       // 32-bit TENSOR 2: ADDR

  // tensor size:
  logic [T_LEN-2:0] CSR_ADDR_T0_0;       // 10-bit TENSOR 0: ROW
  logic [T_LEN-2:0] CSR_ADDR_T0_1;       // 10-bit TENSOR 0: COL
  logic [T_LEN-6:0] CSR_ADDR_T0_2;       //  6-bit TENSOR 0: DEPTH
  logic [T_LEN-7:0] CSR_ADDR_T1_0;       //  5-bit TENSOR 1: ROW
  logic [T_LEN-7:0] CSR_ADDR_T1_1;       //  5-bit TENSOR 1: COL
  logic [T_LEN-6:0] CSR_ADDR_T1_2;       //  6-bit TENSOR 1: DEPTH
  logic [T_LEN-2:0] CSR_ADDR_T2_0;       // 10-bit TENSOR 2: ROW
  logic [T_LEN-2:0] CSR_ADDR_T2_1;       // 10-bit TENSOR 2: COL
  logic [T_LEN-1:0] CSR_ADDR_T2_2;       // 11-bit TENSOR 2: DEPTH

  // tensor param:
  logic signed [I_LEN-1:0] CSR_ZP_T0;    //  8-bit TENSOR 0: ZERO_POINT
  logic signed [I_LEN-1:0] CSR_ZP_T1;    //  8-bit TENSOR 1: ZERO_POINT
  logic signed [I_LEN-1:0] CSR_ZP_T2;    //  8-bit TENSOR 2: ZERO_POINT

  logic signed [M_LEN-1:0] CSR_BIAS_T2;  // 32-bit TENSOR 2: BIAS
  logic signed [M_LEN-1:0] CSR_SCALE_T2; // 32-bit TENSOR 2: SCALE
  logic        [T_LEN-7:0] CSR_SHIFT_T2; //  5-bit TENSOR 2: SHIFT

  ////////////////////////////////////////////////////////////

  always_ff @( posedge clk_i ) begin
    if ( ~arstn_i ) begin
      // status registers:
      csr_status    <= 1'b0;

      // tensor address registers:
      csr_addr_t0   <= { APB_A_W {1'b0} };
      csr_addr_t1   <= { APB_A_W {1'b0} };
      csr_addr_t2   <= { APB_A_W {1'b0} };

      // tensor size registers:
      csr_addr_t0_0 <= { T_LEN-1 {1'b0} };
      csr_addr_t0_1 <= { T_LEN-1 {1'b0} };
      csr_addr_t0_2 <= { T_LEN-5 {1'b0} };
      csr_addr_t1_0 <= { T_LEN-6 {1'b0} };
      csr_addr_t1_1 <= { T_LEN-6 {1'b0} };
      csr_addr_t1_2 <= { T_LEN-5 {1'b0} };
      csr_addr_t2_0 <= { T_LEN-1 {1'b0} };
      csr_addr_t2_1 <= { T_LEN-1 {1'b0} };
      csr_addr_t2_2 <= { T_LEN   {1'b0} };

      // tensor param registers:
      csr_zp_t0     <= { I_LEN   {1'b0} };
      csr_zp_t1     <= { I_LEN   {1'b0} };
      csr_zp_t2     <= { I_LEN   {1'b0} };

      csr_bias_t2   <= { M_LEN   {1'b0} };
      csr_scale_t2  <= { M_LEN   {1'b0} };
      csr_shift_t2  <= { T_LEN-6 {1'b0} };
    end
    else begin
      // status registers:
      csr_status    <= CSR_STATUS;

      // tensor address registers:
      csr_addr_t0   <= CSR_ADDR_T0;
      csr_addr_t1   <= CSR_ADDR_T1;
      csr_addr_t2   <= CSR_ADDR_T2;

      // tensor size registers:
      csr_addr_t0_0 <= CSR_ADDR_T0_0;
      csr_addr_t0_1 <= CSR_ADDR_T0_1;
      csr_addr_t0_2 <= CSR_ADDR_T0_2;
      csr_addr_t1_0 <= CSR_ADDR_T1_0;
      csr_addr_t1_1 <= CSR_ADDR_T1_1;
      csr_addr_t1_2 <= CSR_ADDR_T1_2;
      csr_addr_t2_0 <= CSR_ADDR_T2_0;
      csr_addr_t2_1 <= CSR_ADDR_T2_1;
      csr_addr_t2_2 <= CSR_ADDR_T2_2;

      // tensor param registers:
      csr_zp_t0     <= CSR_ZP_T0;
      csr_zp_t1     <= CSR_ZP_T1;
      csr_zp_t2     <= CSR_ZP_T2;

      csr_bias_t2   <= CSR_BIAS_T2;
      csr_scale_t2  <= CSR_SCALE_T2;
      csr_shift_t2  <= CSR_SHIFT_T2;
    end
  end

  ////////////////////////////////////////////////////////////
  //                       Operations                       //
  ////////////////////////////////////////////////////////////

  logic apb_r_op; // APB READ  operation
  logic apb_w_op; // APB WRITE operation

  logic apb_wdata_i_null; // APB wdata == '0

  logic apb_ill_access_ingnore; // IGNORING write to illegal CSR address if write data == '0

  assign apb_wdata_i_null = ~|slave_apb.p_wdata;

  assign apb_ill_access_ingnore = ( slave_apb.p_write == CSRW_OP ) && apb_wdata_i_null;

  always_comb begin
    apb_r_op = 1'b0;
    apb_w_op = 1'b0;
    if ( slave_apb.p_sel ) begin
      case ( slave_apb.p_write )
        CSRR_OP: apb_r_op = 1'b1;
        CSRW_OP: apb_w_op = 1'b1;
      endcase
    end
  end

  ////////////////////////////////////////////////////////////
  //                    APB WRITE CONTROL                   //
  ////////////////////////////////////////////////////////////

 logic apb_illegal_write;

  always_comb begin

    apb_illegal_write = 1'b0;

    if ( apb_w_op ) begin
      case ( slave_apb.p_addr ) inside

        // status registers:
        32'h04, // CSR_CONTROL:   (WO)

        // tensor address registers:
        32'h08, // CSR_ADDR_T0:   (RW)
        32'h0C, // CSR_ADDR_T1:   (RW)
        32'h10, // CSR_ADDR_T2:   (RW)

        // tensor size registers:
        32'h14, // CSR_ADDR_T0_0: (RW)
        32'h18, // CSR_ADDR_T0_1: (RW)
        32'h1C, // CSR_ADDR_T0_2: (RW)
        32'h20, // CSR_ADDR_T1_0: (RW)
        32'h24, // CSR_ADDR_T1_1: (RW)
        32'h28, // CSR_ADDR_T1_2: (RW)
        32'h2C, // CSR_ADDR_T2_0: (RW)
        32'h30, // CSR_ADDR_T2_1: (RW)
        32'h34, // CSR_ADDR_T2_2: (RW)

        // tensor param registers:
        32'h38, // CSR_ZP_T0:     (RW)
        32'h3C, // CSR_ZP_T1:     (RW)
        32'h40, // CSR_ZP_T2:     (RW)

        32'h44, // CSR_BIAS_T2:   (RW)
        32'h48, // CSR_SCALE_T2:  (RW)
        32'h4C: // CSR_SHIFT_T2:  (RW)

          apb_illegal_write = 1'b0;
        default:
          apb_illegal_write = 1'b1;
      endcase
    end
  end

  ////////////////////////////////////////////////////////////
  //                    APB READ CONTROL                    //
  ////////////////////////////////////////////////////////////

  logic apb_illegal_sel;

  logic [APB_D_W-1:0] apb_data_sel;

  always_comb begin

    apb_illegal_sel  = 1'b0;
    apb_data_sel = { APB_D_W{1'b0} };

    if ( apb_r_op ) begin
      case ( slave_apb.p_addr ) inside

        // status registers (zero-extended output):
        32'h00: apb_data_sel = { {(APB_D_W-1)       {1'b0}}, csr_status    };                 // CSR_STATUS:    (RO)

        // tensor address registers (zero-extended output):
        32'h08: apb_data_sel = { {(APB_D_W-APB_A_W) {1'b0}}, csr_addr_t0   };                 // CSR_ADDR_T0:   (RW)
        32'h0C: apb_data_sel = { {(APB_D_W-APB_A_W) {1'b0}}, csr_addr_t1   };                 // CSR_ADDR_T1:   (RW)
        32'h10: apb_data_sel = { {(APB_D_W-APB_A_W) {1'b0}}, csr_addr_t2   };                 // CSR_ADDR_T2:   (RW)

        // tensor size registers (zero-extended output):
        32'h14: apb_data_sel = { {(APB_D_W-T_LEN+1) {1'b0}}, csr_addr_t0_0 };                 // CSR_ADDR_T0_0: (RW)
        32'h18: apb_data_sel = { {(APB_D_W-T_LEN+1) {1'b0}}, csr_addr_t0_1 };                 // CSR_ADDR_T0_1: (RW)
        32'h1C: apb_data_sel = { {(APB_D_W-T_LEN+5) {1'b0}}, csr_addr_t0_2 };                 // CSR_ADDR_T0_2: (RW)
        32'h20: apb_data_sel = { {(APB_D_W-T_LEN+6) {1'b0}}, csr_addr_t1_0 };                 // CSR_ADDR_T1_0: (RW)
        32'h24: apb_data_sel = { {(APB_D_W-T_LEN+6) {1'b0}}, csr_addr_t1_1 };                 // CSR_ADDR_T1_1: (RW)
        32'h28: apb_data_sel = { {(APB_D_W-T_LEN+5) {1'b0}}, csr_addr_t1_2 };                 // CSR_ADDR_T1_2: (RW)
        32'h2C: apb_data_sel = { {(APB_D_W-T_LEN+1) {1'b0}}, csr_addr_t2_0 };                 // CSR_ADDR_T2_0: (RW)
        32'h30: apb_data_sel = { {(APB_D_W-T_LEN+1) {1'b0}}, csr_addr_t2_1 };                 // CSR_ADDR_T2_1: (RW)
        32'h34: apb_data_sel = { {(APB_D_W-T_LEN  ) {1'b0}}, csr_addr_t2_2 };                 // CSR_ADDR_T2_2: (RW)

        // tensor param registers (sign-extended output):
        32'h38: apb_data_sel = { {(APB_D_W-I_LEN  ) {csr_zp_t0[I_LEN-1]}}, csr_zp_t0 };       // CSR_ZP_T0:     (RW)
        32'h3C: apb_data_sel = { {(APB_D_W-I_LEN  ) {csr_zp_t1[I_LEN-1]}}, csr_zp_t1 };       // CSR_ZP_T1:     (RW)
        32'h40: apb_data_sel = { {(APB_D_W-I_LEN  ) {csr_zp_t2[I_LEN-1]}}, csr_zp_t2 };       // CSR_ZP_T2:     (RW)

        32'h44: apb_data_sel = { {(APB_D_W-M_LEN  ) {csr_bias_t2[M_LEN-1]}}, csr_bias_t2 };   // CSR_BIAS_T2:   (RW)
        32'h48: apb_data_sel = { {(APB_D_W-M_LEN  ) {csr_scale_t2[M_LEN-1]}}, csr_scale_t2 }; // CSR_SCALE_T2:  (RW)
        32'h4C: apb_data_sel = { {(APB_D_W-T_LEN+7) {1'b0}}, csr_shift_t2  };                 // CSR_SHIFT_T2:  (RW)

        default: begin
          apb_data_sel = { APB_D_W{1'b0} };
          apb_illegal_sel  = 1'b1;
        end
      endcase
    end
  end

  ////////////////////////////////////////////////////////////
  //                         CONTROL                        //
  ////////////////////////////////////////////////////////////

  logic apb_r_op_ff;    // APB READ  operation register
  logic apb_w_op_ff;    // APB WRITE operation register

  logic csr_ill_acc_ff; // CSR ILLEGAL ACCESS  register

  always_ff @( posedge clk_i ) begin
    if ( ~arstn_i ) begin

      apb_r_op_ff    <= '0;
      apb_w_op_ff    <= '0;

      csr_ill_acc_ff <= '0;
    end
    else if ( !slave_apb.p_enable ) begin

      apb_r_op_ff    <= apb_r_op;
      apb_w_op_ff    <= apb_w_op;

      csr_ill_acc_ff <= slave_apb.p_sel && ( ~apb_ill_access_ingnore || apb_illegal_sel ) && ( apb_illegal_sel || apb_illegal_write );
    end
  end

  logic [APB_D_W-1:0] apb_data_sel_ff;

  always_ff @(posedge clk_i) begin
    if( ~arstn_i ) begin
      apb_data_sel_ff <= 'd0;
    end
    else begin
      if ( !slave_apb.p_enable ) begin
        apb_data_sel_ff <= apb_data_sel;
      end
    end
  end

  // APB Slave interface connect:
  assign slave_apb.p_ready  = ( apb_r_op_ff || apb_w_op_ff );
  assign slave_apb.p_rdata  = apb_data_sel_ff;
  assign slave_apb.p_slverr = csr_ill_acc_ff;

  ////////////////////////////////////////////////////////////
  //                          WRITE                         //
  ////////////////////////////////////////////////////////////

  always_comb begin

    CSR_STATUS    = slave_csr.csr_status; // "1" - calc active / "0" - waiting
    CSR_CONTROL   = '0;                   // write to MAC activation

    // tensor address:
    CSR_ADDR_T0   = csr_addr_t0;   // TENSOR 0: ADDR
    CSR_ADDR_T1   = csr_addr_t1;   // TENSOR 1: ADDR
    CSR_ADDR_T2   = csr_addr_t2;   // TENSOR 2: ADDR

    // tensor size:
    CSR_ADDR_T0_0 = csr_addr_t0_0; // TENSOR 0: ROW
    CSR_ADDR_T0_1 = csr_addr_t0_1; // TENSOR 0: COL
    CSR_ADDR_T0_2 = csr_addr_t0_2; // TENSOR 0: DEPTH
    CSR_ADDR_T1_0 = csr_addr_t1_0; // TENSOR 1: ROW
    CSR_ADDR_T1_1 = csr_addr_t1_1; // TENSOR 1: COL
    CSR_ADDR_T1_2 = csr_addr_t1_2; // TENSOR 1: DEPTH

    CSR_ADDR_T2_0 = csr_addr_t2_0; // TENSOR 2: ROW
    CSR_ADDR_T2_1 = csr_addr_t2_1; // TENSOR 2: COL
    CSR_ADDR_T2_2 = csr_addr_t2_2; // TENSOR 2: DEPTH

    // tensor param:
    CSR_ZP_T0     = csr_zp_t0;     // TENSOR 0: ZERO_POINT
    CSR_ZP_T1     = csr_zp_t1;     // TENSOR 1: ZERO_POINT
    CSR_ZP_T2     = csr_zp_t2;     // TENSOR 2: ZERO_POINT

    CSR_BIAS_T2   = csr_bias_t2;   // TENSOR 2: BIAS
    CSR_SCALE_T2  = csr_scale_t2;  // TENSOR 2: SCALE
    CSR_SHIFT_T2  = csr_shift_t2;  // TENSOR 2: SHIFT

    // checking write access rights:
    if ( apb_w_op ) begin
      case ( slave_apb.p_addr ) inside

        // status registers:
        32'h04: CSR_CONTROL   = slave_apb.p_wdata[0];           //  1-bit write to MAC activation

        // tensor address registers:
        32'h08: CSR_ADDR_T0   = slave_apb.p_wdata[APB_A_W-1:0]; // 32-bit TENSOR 0: ADDR
        32'h0C: CSR_ADDR_T1   = slave_apb.p_wdata[APB_A_W-1:0]; // 32-bit TENSOR 1: ADDR
        32'h10: CSR_ADDR_T2   = slave_apb.p_wdata[APB_A_W-1:0]; // 32-bit TENSOR 2: ADDR

        // tensor size registers:
        32'h14: CSR_ADDR_T0_0 = slave_apb.p_wdata[T_LEN-2:0];   // 10-bit TENSOR 0: ROW
        32'h18: CSR_ADDR_T0_1 = slave_apb.p_wdata[T_LEN-2:0];   // 10-bit TENSOR 0: COL
        32'h1C: CSR_ADDR_T0_2 = slave_apb.p_wdata[T_LEN-6:0];   //  6-bit TENSOR 0: DEPTH
        32'h20: CSR_ADDR_T1_0 = slave_apb.p_wdata[T_LEN-7:0];   //  5-bit TENSOR 1: ROW
        32'h24: CSR_ADDR_T1_1 = slave_apb.p_wdata[T_LEN-7:0];   //  5-bit TENSOR 1: COL
        32'h28: CSR_ADDR_T1_2 = slave_apb.p_wdata[T_LEN-6:0];   //  6-bit TENSOR 1: DEPTH
        32'h2C: CSR_ADDR_T2_0 = slave_apb.p_wdata[T_LEN-2:0];   // 10-bit TENSOR 2: ROW
        32'h30: CSR_ADDR_T2_1 = slave_apb.p_wdata[T_LEN-2:0];   // 10-bit TENSOR 2: COL
        32'h34: CSR_ADDR_T2_2 = slave_apb.p_wdata[T_LEN-1:0];   // 11-bit TENSOR 2: DEPTH

        // tensor param registers:
        32'h38: CSR_ZP_T0     = slave_apb.p_wdata[I_LEN-1:0];   //  8-bit TENSOR 0: ZERO_POINT
        32'h3C: CSR_ZP_T1     = slave_apb.p_wdata[I_LEN-1:0];   //  8-bit TENSOR 1: ZERO_POINT
        32'h40: CSR_ZP_T2     = slave_apb.p_wdata[I_LEN-1:0];   //  8-bit TENSOR 2: ZERO_POINT

        32'h44: CSR_BIAS_T2   = slave_apb.p_wdata[M_LEN-1:0];   // 32-bit TENSOR 2: BIAS
        32'h48: CSR_SCALE_T2  = slave_apb.p_wdata[M_LEN-1:0];   // 32-bit TENSOR 2: SCALE
        32'h4C: CSR_SHIFT_T2  = slave_apb.p_wdata[T_LEN-7:0];   //  5-bit TENSOR 2: SHIFT

        default: begin
        end
      endcase
    end
  end

  ////////////////////////////////////////////////////////////
  //                        MAC READ                        //
  ////////////////////////////////////////////////////////////

  // Status channel:
  assign slave_csr.csr_control  = CSR_CONTROL;

  // Read address channel:
  assign slave_csr.csr_addr_t0  = csr_addr_t0;
  assign slave_csr.csr_addr_t1  = csr_addr_t1;
  assign slave_csr.csr_addr_t2  = csr_addr_t2;

  // Write response channel:
  assign slave_csr.csr_addr_t0_0 = csr_addr_t0_0;
  assign slave_csr.csr_addr_t0_1 = csr_addr_t0_1;
  assign slave_csr.csr_addr_t0_2 = csr_addr_t0_2;
  assign slave_csr.csr_addr_t1_0 = csr_addr_t1_0;
  assign slave_csr.csr_addr_t1_1 = csr_addr_t1_1;
  assign slave_csr.csr_addr_t1_2 = csr_addr_t1_2;
  assign slave_csr.csr_addr_t2_0 = csr_addr_t2_0;
  assign slave_csr.csr_addr_t2_1 = csr_addr_t2_1;
  assign slave_csr.csr_addr_t2_2 = csr_addr_t2_2;

  // Read param channel:
  assign slave_csr.csr_zp_t0    = csr_zp_t0;
  assign slave_csr.csr_zp_t1    = csr_zp_t1;
  assign slave_csr.csr_zp_t2    = csr_zp_t2;

  assign slave_csr.csr_bias_t2  = csr_bias_t2;
  assign slave_csr.csr_scale_t2 = csr_scale_t2;
  assign slave_csr.csr_shift_t2 = csr_shift_t2;

  ////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////

endmodule
