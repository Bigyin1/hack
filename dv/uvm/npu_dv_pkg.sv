//---------------------------------------------------------
// Package: npu_dv_pkg
//---------------------------------------------------------

// NPU DV package

package npu_dv_pkg;


    //---------------------------------------------------------
    // Imports
    //---------------------------------------------------------

    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import mvc_pkg::*;
    import npu_pkg::*;

    import mgc_axi4_v1_0_pkg::*;
    import mgc_axi4lite_seq_pkg::*;
    import mgc_apb3_v1_0_pkg::*;
    import addr_map_pkg::*;
    import slave_mem_models_pkg::*;
    import QUESTA_MVC::*;


    //---------------------------------------------------------
    // Include: Utility
    //---------------------------------------------------------

    `include "npu_utils.sv"


    //---------------------------------------------------------
    // Parameters: Common
    //---------------------------------------------------------

    parameter CLK_PERIOD = 10;


    //---------------------------------------------------------
    // Parameters: AXI4
    //---------------------------------------------------------

    parameter AXI4_ADDR_WIDTH      = npu_pkg::AXI_A_W;
    parameter AXI4_DATA_WIDTH      = npu_pkg::AXI_D_W;
    parameter AXI4_ID_WIDTH        = 1;
    parameter AXI4_USER_WIDTH      = 1;
    parameter AXI4_REGION_MAP_SIZE = 1;


    //---------------------------------------------------------
    // Parameters: APB
    //---------------------------------------------------------

    parameter APB_SLAVE_COUNT   = 1;
    parameter APB_ADDRESS_WIDTH = npu_pkg::APB_A_W;
    parameter APB_WDATA_WIDTH   = npu_pkg::APB_D_W;
    parameter APB_RDATA_WIDTH   = npu_pkg::APB_D_W;


    //---------------------------------------------------------
    // Parameters: VIP
    //---------------------------------------------------------

    parameter AXI4_RAL_MEM_DATA_WIDTH = 32;


    //---------------------------------------------------------
    // Typedef: npu_apb_data_t
    //---------------------------------------------------------

    typedef bit [npu_pkg::APB_D_W-1:0] npu_apb_data_t;


    //---------------------------------------------------------
    // Typedef: apb_addr_t
    //---------------------------------------------------------

    typedef bit [npu_pkg::APB_A_W-1:0] apb_addr_t;


    //---------------------------------------------------------
    // Typedef: axi4_addr_t
    //---------------------------------------------------------

    typedef bit [AXI4_ADDR_WIDTH-1:0] axi4_addr_t;


    //---------------------------------------------------------
    // Typedef: axi4_bfm_type
    //---------------------------------------------------------

    // AXI4 interface with DUT parameters

    typedef virtual mgc_axi4 #(`AXI4_PARAMS_INST) axi4_bfm_type;


    //---------------------------------------------------------
    // Typedef: apb_bfm_type
    //---------------------------------------------------------

    // APB interface with DUT parameters

    typedef virtual mgc_apb3 #(`APB_INTF_PARAMS_INST) apb_bfm_type;


    //---------------------------------------------------------
    // Typedef: axi4_config_t
    //---------------------------------------------------------

    // AXI4 configuration

    typedef axi4_vip_config #(`AXI4_PARAMS_INST) axi4_config_t;


    //---------------------------------------------------------
    // Typedef: axis_config_t
    //---------------------------------------------------------

    // APB configuration

    typedef apb3_vip_config #(`APB_PARAMS_INST) apb_config_t;


    //---------------------------------------------------------
    // Typedef: axi4_agent_t
    //---------------------------------------------------------

    // AXI4 agent

    typedef axi4_agent #(`AXI4_PARAMS_INST) axi4_agent_t;


    //---------------------------------------------------------
    // Typedef: apb_agent_t
    //---------------------------------------------------------

    // APB agent

    typedef apb_agent #(`APB_PARAMS_INST) apb_agent_t;


    //---------------------------------------------------------
    // Typedef: axi4_slave_delay_t
    //---------------------------------------------------------

    // AXI4 slave delay settings

    typedef axi4_slave_delay_db axi4_slave_delay_t;


    //---------------------------------------------------------
    // Typedef: apb_rw_trans_t
    //---------------------------------------------------------

    // APB transaction

    typedef apb3_host_apb3_transaction #(`APB_INTF_PARAMS_INST) apb_rw_trans_t;


    //---------------------------------------------------------
    // Typedef: axi4_rw_trans_t
    //---------------------------------------------------------

    // AXI4 transaction

    typedef axi4_master_rw_transaction #(`AXI4_PARAMS_INST) axi4_rw_trans_t;


    //---------------------------------------------------------
    // Typedefs: APB register predictor, adapter and etc
    //---------------------------------------------------------

    typedef apb3_host_apb3_transaction #(`APB_INTF_PARAMS_INST)
        apb3_host_apb3_transaction_t;

    typedef reg2apb_adapter #(
        .T(apb3_host_apb3_transaction_t),
        `APB_PARAMS_INST
    ) reg2apb_adapter_t;

    typedef apb_reg_predictor #(
        .T(apb3_host_apb3_transaction_t),
        `APB_PARAMS_INST
    ) apb_reg_predictor_t;


    //---------------------------------------------------------
    // Typedef: AXI4 register predictor, adapter and etc
    //---------------------------------------------------------

    typedef reg2axi4_adapter   #(
        .T(axi4_rw_trans_t),
        `AXI4_PARAMS_INST
    ) reg2axi4_adapter_t;

    typedef axi4_reg_predictor #(
        .T(axi4_rw_trans_t),
        `AXI4_PARAMS_INST
    ) axi4_reg_predictor_t;


    //---------------------------------------------------------
    // Typedef: axi4_slave_type_t
    //---------------------------------------------------------

    // AXI4 slave type

    typedef enum {
        LOAD_0,
        LOAD_1,
        STORE_0
    } axi4_slave_type_t;


    //---------------------------------------------------------
    // Field: axis_slave_types
    //---------------------------------------------------------

    // All AXI4 slave types

    axi4_slave_type_t axi4_slave_types [] = '{LOAD_0, LOAD_1, STORE_0};


    //---------------------------------------------------------
    // Typedef: npu_apb_reg_t
    //---------------------------------------------------------

    typedef enum apb_addr_t {
        STATUS    = 'h0,
        CONTROL   = 'h4,
        ADDR_T0   = 'h8,
        ADDR_T1   = 'hC,
        ADDR_T2   = 'h10,
        ADDR_T0_0 = 'h14,
        ADDR_T0_1 = 'h18,
        ADDR_T0_2 = 'h1C,
        ADDR_T1_0 = 'h20,
        ADDR_T1_1 = 'h24,
        ADDR_T1_2 = 'h28,
        ADDR_T2_0 = 'h2C,
        ADDR_T2_1 = 'h30,
        ADDR_T2_2 = 'h34,
        ZP_T0     = 'h38,
        ZP_T1     = 'h3C,
        ZP_T2     = 'h40,
        BIAS_T2   = 'h44,
        SCALE_T2  = 'h48,
        SHIFT_T2  = 'h4C
    } npu_apb_reg_t;


    //---------------------------------------------------------
    // Field: npu_apb_ro_regs
    //---------------------------------------------------------

    npu_apb_reg_t npu_apb_ro_regs [] = {
        STATUS
    };


    //---------------------------------------------------------
    // Field: npu_apb_wo_regs
    //---------------------------------------------------------

    npu_apb_reg_t npu_apb_wo_regs [] = {
        CONTROL
    };


    //---------------------------------------------------------
    // Field: npu_apb_rw_regs
    //---------------------------------------------------------

    npu_apb_reg_t npu_apb_rw_regs [] = {
        ADDR_T0,   ADDR_T1,   ADDR_T2,   ADDR_T0_0, ADDR_T0_1, ADDR_T0_2,
        ADDR_T1_0, ADDR_T1_1, ADDR_T1_2, ADDR_T2_0, ADDR_T2_1, ADDR_T2_2,
        ZP_T0,     ZP_T1,     ZP_T2,     BIAS_T2,   SCALE_T2,  SHIFT_T2
    };


    //---------------------------------------------------------
    // Typedef: addr_map_t
    //---------------------------------------------------------

    // Address map

    typedef addr_map_pkg::address_map addr_map_t;


    //---------------------------------------------------------
    // Typedefs: bytearr_t, intarr_t
    //---------------------------------------------------------

    typedef byte bytearr_t [];
    typedef int  intarr_t  [];


    //---------------------------------------------------------
    // Functions: Conversion
    //---------------------------------------------------------

    function automatic intarr_t bytearr2intarr(bytearr_t barr);
        intarr_t iarr = new[barr.size()];
        foreach(barr[i]) iarr[i] = int'(barr[i]);
        return iarr;
    endfunction

    function automatic bytearr_t intarr2bytearr(intarr_t iarr);
        bytearr_t barr = new[iarr.size()];
        foreach(iarr[i]) barr[i] = byte'(iarr[i]);
        return barr;
    endfunction


    //---------------------------------------------------------
    // Include: NPU memory library
    //---------------------------------------------------------

    `include "npu_mem_lib.sv"


    //---------------------------------------------------------
    // Functions: Calculating matrixes address range
    //---------------------------------------------------------

    `define CALC_MATRIX_LOWER_BOUND(MATRIX,REGS) \
        REGS[MATRIX]

    `define CALC_MATRIX_UPPER_BOUND(MATRIX,REGS) \
        REGS[MATRIX]+REGS[MATRIX``_0]*REGS[MATRIX``_1]*REGS[MATRIX``_2]

    function automatic apb_addr_t calc_matrix_lower_bound(
        npu_apb_reg_t matrix, npu_apb_data_t apb_regs [npu_apb_reg_t]
    );
        case(matrix)
            ADDR_T0: return `CALC_MATRIX_LOWER_BOUND(ADDR_T0, apb_regs);
            ADDR_T1: return `CALC_MATRIX_LOWER_BOUND(ADDR_T1, apb_regs);
            ADDR_T2: return `CALC_MATRIX_LOWER_BOUND(ADDR_T2, apb_regs);
            default: begin
                `uvm_fatal("%m", $sformatf("Invalid matrix '%s'", matrix.name()));
            end
        endcase
    endfunction

    function automatic apb_addr_t calc_matrix_upper_bound(
        npu_apb_reg_t matrix, npu_apb_data_t apb_regs [npu_apb_reg_t]
    );
        case(matrix)
            ADDR_T0: return `CALC_MATRIX_UPPER_BOUND(ADDR_T0, apb_regs);
            ADDR_T1: return `CALC_MATRIX_UPPER_BOUND(ADDR_T1, apb_regs);
            ADDR_T2: return `CALC_MATRIX_UPPER_BOUND(ADDR_T2, apb_regs);
            default: begin
                `uvm_fatal("%m", $sformatf("Invalid matrix '%s'", matrix.name()));
            end
        endcase
    endfunction

    typedef apb_addr_t matrix_addr_range_t [2];

    function automatic matrix_addr_range_t calc_matrix_addr_range(
        npu_apb_reg_t matrix, npu_apb_data_t apb_regs [npu_apb_reg_t]
    );
        case(matrix)
            ADDR_T0: return '{calc_matrix_lower_bound(ADDR_T0, apb_regs), calc_matrix_upper_bound(ADDR_T0, apb_regs)};
            ADDR_T1: return '{calc_matrix_lower_bound(ADDR_T1, apb_regs), calc_matrix_upper_bound(ADDR_T1, apb_regs)};
            ADDR_T2: return '{calc_matrix_lower_bound(ADDR_T2, apb_regs), calc_matrix_upper_bound(ADDR_T2, apb_regs)};
            default: begin
                `uvm_fatal("%m", $sformatf("Invalid matrix '%s'", matrix.name()));
            end
        endcase
    endfunction


    //---------------------------------------------------------
    // Include: Objects and components
    //---------------------------------------------------------

    `include "npu_apb_reg_config.sv"
    `include "npu_apb_reg_seq_lib.sv"
    `include "npu_test_cfg.sv"
    `include "npu_model.sv"
    `include "npu_scoreboard.sv"
    `include "npu_reg2apb_adapter.sv"
    `include "npu_test_lib.sv"


endpackage
