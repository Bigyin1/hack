//---------------------------------------------------------
// Library: npu_apb_reg_seq_lib
//---------------------------------------------------------

// NPU APB register access sequence library


//---------------------------------------------------------
// Class: npu_apb_reg_seq_base
//---------------------------------------------------------

// Base NPU APB register access sequence

class npu_apb_reg_seq_base extends uvm_reg_sequence;

    `uvm_object_utils(npu_apb_reg_seq_base)
    `uvm_object_new


    //---------------------------------------------------------
    // Field: status
    //---------------------------------------------------------

    // Read/write status
    
    uvm_status_e status;
    

    //---------------------------------------------------------
    // Field: reg_model
    //---------------------------------------------------------

    // Register model

    npu_reg_model reg_model;


    //---------------------------------------------------------
    // Field: apb_config
    //---------------------------------------------------------
    
    // Configuration for APB registers values

    npu_apb_reg_config reg_config;


    //---------------------------------------------------------
    // Field: apb_regs
    //---------------------------------------------------------

    // APB registers to work with
    
    npu_apb_reg_t apb_regs [];


    //---------------------------------------------------------
    // Task: body
    //---------------------------------------------------------

    virtual task body();
        get_reg_model();
        get_reg_config();
    endtask

    
    //---------------------------------------------------------
    // Task: execure_write
    //---------------------------------------------------------
    
    virtual task execure_write();
        npu_apb_data_t data;
        foreach(apb_regs[i]) begin
            randomize_data_for_reg(data, apb_regs[i]);
            reg_model.apb_regs[apb_regs[i]].write(
                status, data, UVM_FRONTDOOR, reg_model.apb_map, this
            );
            if(status != UVM_IS_OK) begin
                `uvm_fatal(get_name(), $sformatf(
                    "Write access to '%s' register failed!",
                        apb_regs[i].name()));
            end
            else begin
                `uvm_info(get_name(), $sformatf(
                    "Write access to '%s' register done!",
                        apb_regs[i].name()), UVM_NONE);
            end
        end
    endtask


    //---------------------------------------------------------
    // Task: execure_read
    //---------------------------------------------------------
    
    virtual task execure_read();
        foreach(apb_regs[i]) begin
            reg_model.apb_regs[apb_regs[i]].mirror(
                status, UVM_CHECK, UVM_FRONTDOOR, reg_model.apb_map, this
            );
            if(status != UVM_IS_OK) begin
                `uvm_fatal(get_name(), $sformatf(
                    "Read access to '%s' register failed!",
                        apb_regs[i].name()));
            end
            else begin
                `uvm_info(get_name(), $sformatf(
                    "Read access to '%s' register done!",
                        apb_regs[i].name()), UVM_NONE);
            end
        end
    endtask

    //---------------------------------------------------------
    // Function: get_reg_model
    //---------------------------------------------------------
    
    // Function for getting register model

    virtual function void get_reg_model();
        if (!uvm_resource_db#(npu_reg_model)::read_by_name("*", "reg_model", reg_model))
          `uvm_fatal(get_name(), "Can't find register model in resource database!");
    endfunction


    //---------------------------------------------------------
    // Function: get_reg_config
    //---------------------------------------------------------
    
    // Function for getting register config

    virtual function void get_reg_config();
        if (!uvm_resource_db#(npu_apb_reg_config)::read_by_name("*", "reg_config", reg_config))
            `uvm_fatal(get_name(), "Can't find register config in resource database!");
    endfunction


    //---------------------------------------------------------
    // Function: randomize_data_for_reg
    //---------------------------------------------------------

    // Function for randomization data for APB register

    virtual function void randomize_data_for_reg(
        inout npu_apb_data_t data,
        input npu_apb_reg_t  register = STATUS
    );
        
        // Equal to value in APB registers configuration
        data = reg_config.apb_regs[register];

    endfunction


    //---------------------------------------------------------
    // Function: setup_registers_to_work
    //---------------------------------------------------------
    
    virtual function void setup_registers_to_work(
        npu_apb_reg_t apb_regs []
    );
        this.apb_regs = apb_regs;
    endfunction


endclass


//---------------------------------------------------------
// Class: npu_apb_reg_seq_all_write
//---------------------------------------------------------

// Execute random writes to all APB registers and check status
// No MAC start is ussued

class npu_apb_reg_seq_all_write extends npu_apb_reg_seq_base;

    `uvm_object_utils(npu_apb_reg_seq_all_write)
    `uvm_object_new
    
    //---------------------------------------------------------
    // Task: body
    //---------------------------------------------------------
    
    virtual task body();
        super.body();
        setup_registers_to_work({npu_apb_rw_regs, npu_apb_wo_regs});
        execure_write();
    endtask


endclass


//---------------------------------------------------------
// Class: npu_apb_reg_seq_all_read
//---------------------------------------------------------

// Execute reads to all APB registers and check status
// We expecting register predictor to handle value checks

class npu_apb_reg_seq_all_read extends npu_apb_reg_seq_base;

    `uvm_object_utils(npu_apb_reg_seq_all_read)
    `uvm_object_new


    //---------------------------------------------------------
    // Task: body
    //---------------------------------------------------------
    
    virtual task body();
        super.body();
        setup_registers_to_work({npu_apb_rw_regs, npu_apb_ro_regs});
        execure_read();
    endtask


endclass


//---------------------------------------------------------
// Class: npu_reg_seq_config
//---------------------------------------------------------

class npu_reg_seq_config extends npu_apb_reg_seq_base;

    `uvm_object_utils(npu_reg_seq_config)
    `uvm_object_new

    //---------------------------------------------------------
    // Task: body
    //---------------------------------------------------------
    
    virtual task body();

        super.body();

        // Write all settings
        `uvm_info(get_name(), "APB configuration...", UVM_NONE);
        setup_registers_to_work({npu_apb_rw_regs});
        execure_write();
        `uvm_info(get_name(), "APB configuration done!", UVM_NONE);

    endtask

endclass


//---------------------------------------------------------
// Class: npu_reg_seq_start
//---------------------------------------------------------

class npu_reg_seq_start extends npu_apb_reg_seq_base;

    `uvm_object_utils(npu_reg_seq_start)
    `uvm_object_new


    //---------------------------------------------------------
    // Task: body
    //---------------------------------------------------------
    
    virtual task body();

        super.body();

        // Launch NPU
        `uvm_info(get_name(), "Launching NPU via CONTROL...", UVM_NONE);
        setup_registers_to_work({npu_apb_wo_regs});
        execure_write();
        `uvm_info(get_name(), "Launching NPU via CONTROL done!", UVM_NONE);

    endtask

endclass


//---------------------------------------------------------
// Class: npu_reg_seq_wait_status
//---------------------------------------------------------

class npu_reg_seq_wait_status extends npu_apb_reg_seq_base;

    `uvm_object_utils(npu_reg_seq_wait_status)
    `uvm_object_new


    //---------------------------------------------------------
    // Task: body
    //---------------------------------------------------------
    
    virtual task body();

        super.body();

        // Wait for IDLE
        `uvm_info(get_name(), "Waiting for NPU calculation...", UVM_NONE);
        forever begin
            npu_apb_data_t data;
            // Read status
            reg_model.apb_regs[STATUS].read(
                status, data, UVM_FRONTDOOR, reg_model.apb_map, this
            );
            if(status != UVM_IS_OK) begin
                `uvm_fatal(get_name(), "Read access to 'STATUS' register failed!");
            end
            // Wait for IDLE
            else begin
                if(data == 'b0) break;
            end
        end
        `uvm_info(get_name(), "Waiting for NPU calculation done!", UVM_NONE);

    endtask

endclass

