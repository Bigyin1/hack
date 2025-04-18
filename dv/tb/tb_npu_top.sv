//---------------------------------------------------------
// Module: tb_npu_top
//---------------------------------------------------------

// Main NPU testbench module

module tb_npu_top;


    //---------------------------------------------------------
    // Imports
    //---------------------------------------------------------

    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import npu_dv_pkg::*;


    //---------------------------------------------------------
    // Signals: Clock and reset
    //---------------------------------------------------------

    logic ACLK;
    logic ARESETn;


    //---------------------------------------------------------
    // Field: reset_duration
    //---------------------------------------------------------
    
    int reset_duration = 10;


    //---------------------------------------------------------
    // Routine: Clock and reset generation
    //---------------------------------------------------------

    initial begin
        ACLK <= 0;
        forever begin
            #(CLK_PERIOD/2) ACLK = ~ACLK;
        end
    end

    initial begin
        ARESETn <= 0;
        repeat(reset_duration) @(posedge ACLK);
        @(negedge ACLK);
        ARESETn <= 1;
    end


    //---------------------------------------------------------
    // Instances: AXI4
    //---------------------------------------------------------

    axi4_slave #(
        .ADDR_WIDTH      ( npu_dv_pkg::AXI4_ADDR_WIDTH      ),
        .RDATA_WIDTH     ( npu_dv_pkg::AXI4_DATA_WIDTH      ),
        .WDATA_WIDTH     ( npu_dv_pkg::AXI4_DATA_WIDTH      ),
        .ID_WIDTH        ( npu_dv_pkg::AXI4_ID_WIDTH        ),
        .USER_WIDTH      ( npu_dv_pkg::AXI4_USER_WIDTH      ),
        .REGION_MAP_SIZE ( npu_dv_pkg::AXI4_REGION_MAP_SIZE ),
        .IF_NAME         ( "AXI4_SLAVE_IF_LOAD_0"           ) 
    ) axi4_sl_0          ( .ACLK (ACLK), .ARESETn (ARESETn) );

    axi4_slave #(
        .ADDR_WIDTH      ( npu_dv_pkg::AXI4_ADDR_WIDTH      ),
        .RDATA_WIDTH     ( npu_dv_pkg::AXI4_DATA_WIDTH      ),
        .WDATA_WIDTH     ( npu_dv_pkg::AXI4_DATA_WIDTH      ),
        .ID_WIDTH        ( npu_dv_pkg::AXI4_ID_WIDTH        ),
        .USER_WIDTH      ( npu_dv_pkg::AXI4_USER_WIDTH      ),
        .REGION_MAP_SIZE ( npu_dv_pkg::AXI4_REGION_MAP_SIZE ),
        .IF_NAME         ( "AXI4_SLAVE_IF_LOAD_1"           ) 
    ) axi4_sl_1          ( .ACLK (ACLK), .ARESETn (ARESETn) );

    axi4_slave #(
        .ADDR_WIDTH      ( npu_dv_pkg::AXI4_ADDR_WIDTH      ),
        .RDATA_WIDTH     ( npu_dv_pkg::AXI4_DATA_WIDTH      ),
        .WDATA_WIDTH     ( npu_dv_pkg::AXI4_DATA_WIDTH      ),
        .ID_WIDTH        ( npu_dv_pkg::AXI4_ID_WIDTH        ),
        .USER_WIDTH      ( npu_dv_pkg::AXI4_USER_WIDTH      ),
        .REGION_MAP_SIZE ( npu_dv_pkg::AXI4_REGION_MAP_SIZE ),
        .IF_NAME         ( "AXI4_SLAVE_IF_STORE_0"          ) 
    ) axi4_ss_0          ( .ACLK (ACLK), .ARESETn (ARESETn) );


    //---------------------------------------------------------
    // Instance: APB master
    //---------------------------------------------------------
    
    apb_master #(
        .SLAVE_COUNT ( npu_dv_pkg::APB_SLAVE_COUNT    ),
        .ADDR_WIDTH  ( npu_dv_pkg::APB_ADDRESS_WIDTH  ),
        .WDATA_WIDTH ( npu_dv_pkg::APB_WDATA_WIDTH    ),
        .RDATA_WIDTH ( npu_dv_pkg::APB_RDATA_WIDTH    ),
        .IF_NAME     ( "APB_MASTER_IF"                )
    ) apb_master     (.PCLK (ACLK), .PRESETn (ARESETn));


    //---------------------------------------------------------
    // Instance: DUT
    //---------------------------------------------------------
    
    // NPU instance for DV

    npu_wrapper DUT (
        .clk_i      ( ACLK                                                                              ), 
        .arstn_i    ( ARESETn                                                                           ),
        .wa_valid_o ( {axi4_ss_0.axi4_if.AWVALID, axi4_sl_1.axi4_if.AWVALID, axi4_sl_0.axi4_if.AWVALID} ),
        .wa_ready_i ( {axi4_ss_0.axi4_if.AWREADY, axi4_sl_1.axi4_if.AWREADY, axi4_sl_0.axi4_if.AWREADY} ),
        .wa_addr_o  ( {axi4_ss_0.axi4_if.AWADDR,  axi4_sl_1.axi4_if.AWADDR,  axi4_sl_0.axi4_if.AWADDR } ),
        .wd_valid_o ( {axi4_ss_0.axi4_if.WVALID,  axi4_sl_1.axi4_if.WVALID,  axi4_sl_0.axi4_if.WVALID } ),
        .wd_ready_i ( {axi4_ss_0.axi4_if.WREADY,  axi4_sl_1.axi4_if.WREADY,  axi4_sl_0.axi4_if.WREADY } ),
        .wd_data_o  ( {axi4_ss_0.axi4_if.WDATA,   axi4_sl_1.axi4_if.WDATA,   axi4_sl_0.axi4_if.WDATA  } ),
        .wd_strb_o  ( {axi4_ss_0.axi4_if.WSTRB,   axi4_sl_1.axi4_if.WSTRB,   axi4_sl_0.axi4_if.WSTRB  } ),
        .wr_valid_i ( {axi4_ss_0.axi4_if.BVALID,  axi4_sl_1.axi4_if.BVALID,  axi4_sl_0.axi4_if.BVALID } ),
        .wr_ready_o ( {axi4_ss_0.axi4_if.BREADY,  axi4_sl_1.axi4_if.BREADY,  axi4_sl_0.axi4_if.BREADY } ),
        .ra_valid_o ( {axi4_ss_0.axi4_if.ARVALID, axi4_sl_1.axi4_if.ARVALID, axi4_sl_0.axi4_if.ARVALID} ),
        .ra_ready_i ( {axi4_ss_0.axi4_if.ARREADY, axi4_sl_1.axi4_if.ARREADY, axi4_sl_0.axi4_if.ARREADY} ),
        .ra_addr_o  ( {axi4_ss_0.axi4_if.ARADDR,  axi4_sl_1.axi4_if.ARADDR,  axi4_sl_0.axi4_if.ARADDR } ),
        .rd_valid_i ( {axi4_ss_0.axi4_if.RVALID,  axi4_sl_1.axi4_if.RVALID,  axi4_sl_0.axi4_if.RVALID } ),
        .rd_ready_o ( {axi4_ss_0.axi4_if.RREADY,  axi4_sl_1.axi4_if.RREADY,  axi4_sl_0.axi4_if.RREADY } ),
        .rd_data_i  ( {axi4_ss_0.axi4_if.RDATA,   axi4_sl_1.axi4_if.RDATA,   axi4_sl_0.axi4_if.RDATA  } ),
        .p_addr_i   ( apb_master.apb_if.PADDR                                                           ),
        .p_sel_i    ( apb_master.apb_if.PSEL                                                            ),
        .p_enable_i ( apb_master.apb_if.PENABLE                                                         ),
        .p_write_i  ( apb_master.apb_if.PWRITE                                                          ),
        .p_wdata_i  ( apb_master.apb_if.PWDATA                                                          ),
        .p_ready_o  ( apb_master.apb_if.PREADY                                                          ),
        .p_rdata_o  ( apb_master.apb_if.PRDATA                                                          ),
        .p_slverr_o ( apb_master.apb_if.PSLVERR                                                         )
    );


    //---------------------------------------------------------
    // Routine: Run test
    //---------------------------------------------------------

    initial begin

        // Pass clock period to the resource database
        uvm_resource_db#(int)::set("*", "clk_period", int'(CLK_PERIOD));

        // Run test
        run_test();

        // Guard from running simulation
        // after test done
        forever $stop();

    end


endmodule
