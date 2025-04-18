//---------------------------------------------------------
// Class: npu_test_cfg_base
//---------------------------------------------------------

// NPU test configuration

class npu_test_cfg_base extends uvm_object;

    `uvm_object_utils(npu_test_cfg_base)


    //---------------------------------------------------------
    // Field: clp
    //---------------------------------------------------------
    
    // Commandline processor inst

    static uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();


    //---------------------------------------------------------
    // Fields: Sequences settings
    //---------------------------------------------------------

    // Amount of iterations

    int unsigned iter_am = 100;


    //---------------------------------------------------------
    // Field: seq_timeout_clks
    //---------------------------------------------------------
    
    int unsigned seq_timeout_clks = 5000;


    //---------------------------------------------------------
    // Field: test_timeout_clks
    //---------------------------------------------------------
    
    int unsigned test_timeout_clks = 100000;


    //---------------------------------------------------------
    // Field: axi4_slave_always_ready
    //---------------------------------------------------------
    
    // Is AXI4 slave always ready

    bit axi4_slave_always_ready = 0;


    //---------------------------------------------------------
    // Function: new
    //---------------------------------------------------------
    
    function new (string name = "");
        super.new( name );
        get_plusargs();
    endfunction


    //---------------------------------------------------------
    // Function: get_plusargs
    //---------------------------------------------------------
    
    virtual function void get_plusargs();
        string str;
        if(clp.get_arg_value("+test_timeout_clks=", str))
            test_timeout_clks = str.atoi();
        if(clp.get_arg_value("+seq_timeout_clks=", str))
            seq_timeout_clks = str.atoi();
        if(clp.get_arg_value("+iter_am=", str))
            iter_am = str.atoi();
    endfunction


endclass

