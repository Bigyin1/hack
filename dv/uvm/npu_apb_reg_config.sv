//---------------------------------------------------------
// Class: npu_apb_reg_config
//---------------------------------------------------------

// Configuration for NPU settings passed via APB

class npu_apb_reg_config extends uvm_object;

    `uvm_object_utils(npu_apb_reg_config)


    //---------------------------------------------------------
    // Field: apb_regs
    //---------------------------------------------------------

    rand npu_apb_data_t apb_regs [npu_apb_reg_t];


    //---------------------------------------------------------
    // Field: mem
    //---------------------------------------------------------

    // AXI4 memory in system
    // Must be set explicitly

    slave_normal_mem mem;


    //---------------------------------------------------------
    // Fields: Tensors
    //---------------------------------------------------------

    rand byte tensors [npu_apb_reg_t][];


    //---------------------------------------------------------
    // Function: new
    //---------------------------------------------------------

    function new(string name = "");
        super.new(name);
        foreach(npu_apb_rw_regs[i]) begin
            apb_regs[npu_apb_rw_regs[i]] = 0;
        end
        foreach(npu_apb_ro_regs[i]) begin
            apb_regs[npu_apb_ro_regs[i]] = 0;
        end
        foreach(npu_apb_ro_regs[i]) begin
            apb_regs[npu_apb_wo_regs[i]] = 0;
        end
        tensors[ADDR_T0] = {};
        tensors[ADDR_T1] = {};
    endfunction


    //---------------------------------------------------------
    // Function: gen_tensors
    //---------------------------------------------------------

    // Genetate tensors depending on APB config

    virtual function void gen_tensors();
        tensors[ADDR_T0] = new[apb_regs[ADDR_T0_0] * apb_regs[ADDR_T0_1] * apb_regs[ADDR_T0_2]];
        tensors[ADDR_T1] = new[apb_regs[ADDR_T1_0] * apb_regs[ADDR_T1_1] * apb_regs[ADDR_T1_2]];
        foreach(tensors[ADDR_T0][i]) begin
            tensors[ADDR_T0][i] = $urandom(); // blazingly fast, but 32 bit
        end
        foreach(tensors[ADDR_T1][i]) begin
            tensors[ADDR_T1][i] = $urandom(); // blazingly fast, but 32 bit
        end
    endfunction


    //---------------------------------------------------------
    // Constraint:
    //---------------------------------------------------------

    // Matrix arrays are not interleave:

    constraint interleave_c {
        // T0: [a:b], T1: [c:d], T2: [e:f]
        // (b < c || d < a) and
        (`CALC_MATRIX_UPPER_BOUND(ADDR_T0, apb_regs) < `CALC_MATRIX_LOWER_BOUND(ADDR_T1, apb_regs)) ||
        (`CALC_MATRIX_UPPER_BOUND(ADDR_T1, apb_regs) < `CALC_MATRIX_LOWER_BOUND(ADDR_T0, apb_regs));
        // (b < e || f < a) and
        (`CALC_MATRIX_UPPER_BOUND(ADDR_T0, apb_regs) < `CALC_MATRIX_LOWER_BOUND(ADDR_T2, apb_regs)) ||
        (`CALC_MATRIX_UPPER_BOUND(ADDR_T2, apb_regs) < `CALC_MATRIX_LOWER_BOUND(ADDR_T0, apb_regs));
        // (d < e || f < c)
        (`CALC_MATRIX_UPPER_BOUND(ADDR_T1, apb_regs) < `CALC_MATRIX_LOWER_BOUND(ADDR_T2, apb_regs)) ||
        (`CALC_MATRIX_UPPER_BOUND(ADDR_T2, apb_regs) < `CALC_MATRIX_LOWER_BOUND(ADDR_T1, apb_regs));
    }


    //---------------------------------------------------------
    // Constraints: Valid configuration
    //---------------------------------------------------------

    // Status always 0
    constraint status_c {
        apb_regs[STATUS] == 0;
    }

    // Control 0 or 1
    constraint control_c {
        apb_regs[CONTROL] inside {0, 1};
    }

    // Matrix base addresses are byte-aligned
    constraint addr_c {
        apb_regs[ADDR_T0][1:0] == 2'b00;
        apb_regs[ADDR_T1][1:0] == 2'b00;
        apb_regs[ADDR_T2][1:0] == 2'b00;
    }

    // Rows
    constraint rows_c {
        apb_regs[ADDR_T0_0] inside {[8:512]};
        apb_regs[ADDR_T1_0] inside {[3: 16]};
    }

    // Columns
    constraint cols_c {
        apb_regs[ADDR_T0_1] inside {[8:512]};
        apb_regs[ADDR_T1_1] inside {[3: 16]};
    }

    // Depth
    constraint depth_c {
        apb_regs[ADDR_T0_2] inside {[4:32]};
        apb_regs[ADDR_T1_2] inside {[3:16]};
    }

    // Kernel sizes
    constraint kernel_sizes_c {
        apb_regs[ADDR_T2_0] == apb_regs[ADDR_T0_0] -
                               apb_regs[ADDR_T1_0] + 1;
        apb_regs[ADDR_T2_1] == apb_regs[ADDR_T0_1] -
                               apb_regs[ADDR_T1_1] + 1;
        apb_regs[ADDR_T2_2] == apb_regs[ADDR_T0_2] *
                               apb_regs[ADDR_T1_2];
    }

    // Kernel is square matrix
    constraint kernel_square_c {
        apb_regs[ADDR_T1_0] == apb_regs[ADDR_T1_1];
    }

    // Kernel is smaller than base
    constraint kernel_base_c {
        apb_regs[ADDR_T1_0] <= apb_regs[ADDR_T0_0];
        apb_regs[ADDR_T1_1] <= apb_regs[ADDR_T0_1];
    }

    // Zero point
    constraint zero_point_c {
        apb_regs[ZP_T0] inside {[0:255]};
        apb_regs[ZP_T1] inside {[0:255]};
        apb_regs[ZP_T2] inside {[0:255]};
    }

    // Scale
    constraint scale_c {
        apb_regs[SCALE_T2] inside {[1073741824:2147483647]};
    }

    // Shift
    constraint shift_c {
        apb_regs[SHIFT_T2] inside {[0:31]};
    }


    //---------------------------------------------------------
    // Function: convert2string
    //---------------------------------------------------------

    virtual function string convert2string();
        string str;
        str = {str, "\n\nAPB registers configuration:"};
        str = {str, "\n+------------------+------------+---------------+"};
        str = {str, "\n| Name             | Value Dec  | Value Hex     |"};
        str = {str, "\n+------------------+------------+---------------+"};
        foreach(apb_regs[i]) begin
            str = {str, $sformatf("\n| %-16s | %10d |    %10h |",
                i, apb_regs[i], apb_regs[i])};
        end
        str = {str, "\n+------------------+------------+---------------+\n"};
        str = {str, "\nMatrix address ranges:"};
        str = {str, "\n+------------------+------------+------------+------------+------------+"};
        str = {str, "\n| Name             | Start Dec  | End Dec    | Start Hex  | End Hex    |"};
        str = {str, "\n+------------------+------------+------------+------------+------------+"};
        str = {str, $sformatf("\n| %-16s | %10d | %10d | %10h | %10h |",
            "Tensor 0", calc_matrix_lower_bound(ADDR_T0, apb_regs),
                         calc_matrix_upper_bound(ADDR_T0, apb_regs),
                         calc_matrix_lower_bound(ADDR_T0, apb_regs),
                         calc_matrix_upper_bound(ADDR_T0, apb_regs))};
        str = {str, $sformatf("\n| %-16s | %10d | %10d | %10h | %10h |",
            "Tensor 1", calc_matrix_lower_bound(ADDR_T1, apb_regs),
                         calc_matrix_upper_bound(ADDR_T1, apb_regs),
                         calc_matrix_lower_bound(ADDR_T1, apb_regs),
                         calc_matrix_upper_bound(ADDR_T1, apb_regs))};
        str = {str, $sformatf("\n| %-16s | %10d | %10d | %10h | %10h |",
            "Tensor 2", calc_matrix_lower_bound(ADDR_T2, apb_regs),
                         calc_matrix_upper_bound(ADDR_T2, apb_regs),
                         calc_matrix_lower_bound(ADDR_T2, apb_regs),
                         calc_matrix_upper_bound(ADDR_T2, apb_regs))};
        str = {str, "\n+------------------+------------+------------+------------+------------+\n"};
        str = {str, "\nMatrix sizes:"};
        str = {str, "\n+------------------+--------+--------+----------+"};
        str = {str, "\n| Matrix           | Rows   | Cols   | Depth    |"};
        str = {str, "\n+------------------+--------+--------+----------+"};
        str = {str, $sformatf("\n| %-16s |  %5d |  %5d |    %5d |",
            "Tensor 0", apb_regs[ADDR_T0_0], apb_regs[ADDR_T0_1], apb_regs[ADDR_T0_2])};
        str = {str, $sformatf("\n| %-16s |  %5d |  %5d |    %5d |",
            "Tensor 1", apb_regs[ADDR_T1_0], apb_regs[ADDR_T1_1], apb_regs[ADDR_T1_2])};
        str = {str, $sformatf("\n| %-16s |  %5d |  %5d |    %5d |",
            "Tensor 2", apb_regs[ADDR_T2_0], apb_regs[ADDR_T2_1], apb_regs[ADDR_T2_2])};
        str = {str, "\n+------------------+--------+--------+----------+\n"};
        return str;
    endfunction


endclass


//---------------------------------------------------------
// Class: npu_apb_reg_config_no_start
//---------------------------------------------------------

// Configuration for NPU settings passed via APB
// CONTROL register is value of 0

class npu_apb_reg_config_no_start extends npu_apb_reg_config;

    `uvm_object_utils(npu_apb_reg_config_no_start)

    constraint control_c {
        apb_regs[CONTROL] == 0;
    }

endclass


//---------------------------------------------------------
// Class: npu_apb_reg_config_start
//---------------------------------------------------------

// Configuration for NPU settings passed via APB
// CONTROL register is value of 1

class npu_apb_reg_config_start extends npu_apb_reg_config;

    `uvm_object_utils(npu_apb_reg_config_start)

    constraint control_c {
        apb_regs[CONTROL] == 1;
    }

endclass


//---------------------------------------------------------
// Class: npu_apb_reg_config_fixed
//---------------------------------------------------------

// Config with fixed matrixes
// Depth is 3
// Tensor 0 is 4x4
// Tensor 1 is 4x4 or 3x3

class npu_apb_reg_config_fixed extends npu_apb_reg_config_start;

    `uvm_object_utils(npu_apb_reg_config_fixed)

    // Rows
    constraint rows_c {
        apb_regs[ADDR_T0_0] == 4;
        apb_regs[ADDR_T1_0] inside {3, 4};
    }

    // Columns
    constraint cols_c {
        apb_regs[ADDR_T0_1] == 4;
        apb_regs[ADDR_T1_1] inside {3, 4};
    }

    // Depth
    constraint depth_c {
        apb_regs[ADDR_T0_2] == 2;
        apb_regs[ADDR_T1_2] == 3;
    }

endclass


//---------------------------------------------------------
// Class: npu_apb_reg_config_small
//---------------------------------------------------------

// Config with small matrixes

class npu_apb_reg_config_small extends npu_apb_reg_config_start;

    `uvm_object_utils(npu_apb_reg_config_small)

    // Rows
    constraint rows_c {
        apb_regs[ADDR_T0_0] inside {[8:16]};
        apb_regs[ADDR_T1_0] inside {[3: 8]};
    }

    // Columns
    constraint cols_c {
        apb_regs[ADDR_T0_1] inside {[8:16]};
        apb_regs[ADDR_T1_1] inside {[3: 8]};
    }

    // Depth
    constraint depth_c {
        apb_regs[ADDR_T0_2] inside {[4:8]};
        apb_regs[ADDR_T1_2] inside {[3:4]};
    }

endclass


//---------------------------------------------------------
// Class: npu_apb_reg_config_playground
//---------------------------------------------------------

// Config with user defined matrixes sizes

class npu_apb_reg_config_playground extends npu_apb_reg_config_start;

    `uvm_object_utils(npu_apb_reg_config_playground)

    function void post_randomize();
        // Get matrix sizes from commandline
        void'($value$plusargs("ADDR_T0_0=%0d", apb_regs[ADDR_T0_0]));
        void'($value$plusargs("ADDR_T0_1=%0d", apb_regs[ADDR_T0_1]));
        void'($value$plusargs("ADDR_T0_2=%0d", apb_regs[ADDR_T0_2]));
        void'($value$plusargs("ADDR_T1_0=%0d", apb_regs[ADDR_T1_0]));
        void'($value$plusargs("ADDR_T1_1=%0d", apb_regs[ADDR_T1_1]));
        void'($value$plusargs("ADDR_T1_2=%0d", apb_regs[ADDR_T1_2]));
        // Calculate result size
        apb_regs[ADDR_T2_0] = apb_regs[ADDR_T0_0] -
                              apb_regs[ADDR_T1_0] + 1;
        apb_regs[ADDR_T2_1] = apb_regs[ADDR_T0_1] -
                              apb_regs[ADDR_T1_1] + 1;
        apb_regs[ADDR_T2_2] = apb_regs[ADDR_T0_2] *
                              apb_regs[ADDR_T1_2];
    endfunction
    
endclass
