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

 module npu_lsu (
  input  logic clk_i,
  input  logic arstn_i,

  ADDRDATA_BUS_SV.Slave  slave,

  AXI4LITE_BUS_SV.Master master
);

  logic hs_master_ra_ff;
  logic hs_master_rd_ff;

  ////////////////////////////////////////////////////////////

  logic hs_master_wa_ff;
  logic hs_master_wd_ff;
  logic hs_master_wr_ff;

  ////////////////////////////////////////////////////////////
  //                  Finite State Machine                  //
  ////////////////////////////////////////////////////////////

  enum logic [1:0] {IDLE, READ, WRITE} lsu_state, lsu_next_state;

  // FSM current state:
  always_ff @( posedge clk_i ) begin
    if ( ~arstn_i ) begin
      lsu_state <= IDLE;
    end
    else begin
      lsu_state <= lsu_next_state;
    end
  end

  always_comb begin
    lsu_next_state = lsu_state;

    case ( lsu_state )
      IDLE: begin
        if ( slave.r_valid )
          lsu_next_state = READ;
        else if ( slave.w_valid )
          lsu_next_state = WRITE;
      end

      READ: begin
        if ( slave.r_valid )
          lsu_next_state = READ;
        else if ( hs_master_rd_ff )
          lsu_next_state = IDLE;
      end

      WRITE: begin
        if ( slave.w_valid )
          lsu_next_state = WRITE;
        else if ( hs_master_wr_ff )
          lsu_next_state = IDLE;
      end

    endcase
  end

  ////////////////////////////////////////////////////////////
  //                       Read data                        //
  ////////////////////////////////////////////////////////////

  // Read channel:
  assign slave.r_ready = master.rd_valid && ( hs_master_ra_ff || ( slave.r_valid && master.ra_ready ) );
  assign slave.r_data  = master.rd_data;

  always_comb begin
    // Read address channel:
    master.ra_valid = '0;
    master.ra_addr  = '0;

    // Read data channel:
    master.rd_ready = '0;

    if ( lsu_state == READ ) begin
      // Read address channel:
      master.ra_valid = slave.r_valid && ~hs_master_ra_ff;
      master.ra_addr  = slave.r_addr;

      // Read data channel:
      master.rd_ready = slave.rd_ready;
    end
  end

  always_ff @( posedge clk_i or negedge arstn_i ) begin
    if ( ~arstn_i ) begin
      hs_master_ra_ff <= '0;
    end
    else if ( lsu_state == READ ) begin
      if ( ~hs_master_ra_ff ) begin
        hs_master_ra_ff <= slave.r_valid && master.ra_ready;
      end
      else if ( slave.rd_ready && master.rd_valid ) begin
        hs_master_ra_ff <= '0;
      end
      else if ( hs_master_ra_ff ) begin
        hs_master_ra_ff <= hs_master_ra_ff;
      end
    end
    else if ( lsu_next_state == READ ) begin
      hs_master_ra_ff <= slave.r_valid && master.ra_ready;
    end
  end

  always_ff @( posedge clk_i or negedge arstn_i ) begin
    if ( ~arstn_i ) begin
      hs_master_rd_ff <= '0;
    end
    else if ( lsu_state == READ ) begin
      hs_master_rd_ff <= slave.rd_ready && master.rd_valid;
    end
    else if ( lsu_next_state == READ ) begin
      hs_master_rd_ff <= slave.rd_ready && master.rd_valid;
    end
  end

  ////////////////////////////////////////////////////////////
  //                       Write data                       //
  ////////////////////////////////////////////////////////////

  // Write channel:
//assign slave.w_ready = master.wa_ready;
//assign slave.w_resp  = hs_master_wd_ff && hs_master_wa_ff;
  assign slave.w_ready = master.wr_ready && master.wr_valid;

  always_comb begin
    // Write address channel:
    master.wa_valid = '0;
    master.wa_addr  = '0;

    // Write data channel:
    master.wd_valid = '0;
    master.wd_data  = '0;
    master.wd_strb  = '0;

    // Write response channel:
    master.wr_ready = '0;
    if ( lsu_state == WRITE ) begin
      // Write address channel:
      master.wa_valid = slave.w_valid && ~hs_master_wa_ff;
      master.wa_addr  = slave.w_addr;

      // Write data channel:
      master.wd_valid = slave.w_valid && ~hs_master_wd_ff;;
      master.wd_data  = slave.w_data;
      master.wd_strb  = slave.w_strb;

      // Write response channel:
      master.wr_ready = hs_master_wd_ff && hs_master_wa_ff;
    end
  end

  always_ff @( posedge clk_i or negedge arstn_i ) begin
    if ( ~arstn_i ) begin
      hs_master_wa_ff <= '0;
    end
    else if ( lsu_state == WRITE ) begin
      if ( ~hs_master_wa_ff ) begin
        hs_master_wa_ff <= slave.w_valid && master.wa_ready;
      end
      else if ( master.wr_ready && master.wr_valid ) begin
        hs_master_wa_ff <= '0;
      end
      else if ( hs_master_wa_ff ) begin
        hs_master_wa_ff <= hs_master_wa_ff;
      end
    end
    else if ( lsu_next_state == WRITE ) begin
      hs_master_wa_ff <= slave.w_valid && master.wa_ready;
    end
  end

  always_ff @( posedge clk_i or negedge arstn_i ) begin
    if ( ~arstn_i ) begin
      hs_master_wd_ff <= '0;
    end
    else if ( lsu_state == WRITE ) begin
      if ( ~hs_master_wd_ff ) begin
        hs_master_wd_ff <= slave.w_valid && master.wd_ready;
      end
      else if ( master.wr_ready && master.wr_valid ) begin
        hs_master_wd_ff <= '0;
      end
      else if ( hs_master_wd_ff ) begin
        hs_master_wd_ff <= hs_master_wd_ff;
      end
    end
    else if ( lsu_next_state == WRITE ) begin
      hs_master_wd_ff <= slave.w_valid && master.wd_ready;
    end
  end


  always_ff @( posedge clk_i or negedge arstn_i ) begin
    if ( ~arstn_i ) begin
      hs_master_wr_ff <= '0;
    end
    else if ( lsu_state == WRITE ) begin
      hs_master_wr_ff <= master.wr_ready && master.wr_valid;
    end
    else if ( lsu_next_state == WRITE ) begin
      hs_master_wr_ff <= master.wr_ready && master.wr_valid;
    end
  end

endmodule
