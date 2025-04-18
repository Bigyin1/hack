//---------------------------------------------------------
// Library: npu_mem_lib
//---------------------------------------------------------

// NPU RAL model


//---------------------------------------------------------
// Class: npu_reg_field
//---------------------------------------------------------

// NPU regsiter field

class npu_reg_field extends uvm_reg_field;

    `uvm_object_utils(npu_reg_field)
    `uvm_object_new

    virtual function void do_predict(
        uvm_reg_item      rw,
        uvm_predict_e     kind = UVM_PREDICT_DIRECT,
        uvm_reg_byte_en_t be = -1
    );

        npu_apb_reg_t se_iregs [] = {ZP_T0, ZP_T1, ZP_T2};
        npu_apb_reg_t se_mregs [] = {BIAS_T2, SCALE_T2};

        // Signextend for signed settings
        string name = this.get_name();
        foreach(se_iregs[i]) begin
            if(name == se_iregs[i].name()) begin
                rw.value[0][APB_D_W:I_LEN] = {(APB_D_W-I_LEN){rw.value[0][I_LEN-1]}};
            end
        end
        foreach(se_mregs[i]) begin
            if(name == se_mregs[i].name()) begin
                rw.value[0][APB_D_W:M_LEN] = {(APB_D_W-I_LEN){rw.value[0][M_LEN-1]}};
            end
        end

        super.do_predict(rw, kind, be);

    endfunction

endclass


//---------------------------------------------------------
// Class: npu_reg
//---------------------------------------------------------
    
// NPU register

class npu_reg extends uvm_reg;

    `uvm_object_utils(npu_reg)

    npu_reg_field COMMON;

    function new(string name = "");
        super.new(name, npu_pkg::APB_D_W, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        COMMON = npu_reg_field::type_id::create(get_name());
    endfunction
        
endclass


//---------------------------------------------------------
// Class: npu_ro_reg
//---------------------------------------------------------
    
// NPU read only register
    
class npu_ro_reg extends npu_reg;

    `uvm_object_utils(npu_ro_reg)
    `uvm_object_new

    virtual function void build();
        super.build();
        COMMON.configure(
            this, npu_pkg::APB_D_W, 0, "RO", 0, 0, 1, 0, 1);
    endfunction
        
endclass


//---------------------------------------------------------
// Class: npu_ro_reg
//---------------------------------------------------------
    
// NPU write only register
    
class npu_wo_reg extends npu_reg;

    `uvm_object_utils(npu_wo_reg)
    `uvm_object_new

    virtual function void build();
        super.build();
        COMMON.configure(
            this, npu_pkg::APB_D_W, 0, "WO", 0, 0, 1, 0, 1);
    endfunction
        
endclass


//---------------------------------------------------------
// Class: npu_rw_reg
//---------------------------------------------------------
    
// NPU read/write register
    
class npu_rw_reg extends npu_reg;

    `uvm_object_utils(npu_rw_reg)
    `uvm_object_new

    virtual function void build();
        super.build();
        COMMON.configure(
            this, npu_pkg::APB_D_W, 0, "RW", 0, 0, 1, 0, 1);
    endfunction
        
endclass


//---------------------------------------------------------
// Class: npu_rw_mem
//---------------------------------------------------------
    
// NPU memory

class npu_rw_mem extends uvm_mem;

    `uvm_object_utils(npu_rw_mem)

    function new(string name = "");
        super.new(name, npu_dv_pkg::AXI4_ADDR_WIDTH / npu_dv_pkg::AXI4_RAL_MEM_DATA_WIDTH,
            npu_dv_pkg::AXI4_RAL_MEM_DATA_WIDTH, "RW", UVM_NO_COVERAGE);
    endfunction

endclass


//---------------------------------------------------------
// Class: npu_reg_model
//---------------------------------------------------------
    
// NPU register model with APB registers and AXI4-Lite memory

class npu_reg_model extends uvm_reg_block;

    `uvm_object_utils(npu_reg_model)
    `uvm_object_new


    //---------------------------------------------------------
    // Field: apb_regs
    //---------------------------------------------------------

    // All APB registers associative array

    npu_reg apb_regs [npu_apb_reg_t];


    //---------------------------------------------------------
    // Field: axi4_men
    //---------------------------------------------------------
        
    // AXI4 memory

    npu_rw_mem axi4_mem;


    //---------------------------------------------------------
    // Fields: Address maps
    //---------------------------------------------------------
        
    uvm_reg_map apb_map;
    uvm_reg_map axi4_map [axi4_slave_type_t];


    //---------------------------------------------------------
    // Function: build
    //---------------------------------------------------------
        
    virtual function void build();

        // Create RO registers
        foreach (npu_apb_ro_regs[i]) begin
            apb_regs[npu_apb_ro_regs[i]] =
                npu_ro_reg::type_id::create(
                    npu_apb_ro_regs[i].name());
            apb_regs[npu_apb_ro_regs[i]].build();
            apb_regs[npu_apb_ro_regs[i]].configure(this, null, "");
        end

        // Create WO
        foreach (npu_apb_wo_regs[i]) begin
            apb_regs[npu_apb_wo_regs[i]] =
                npu_rw_reg::type_id::create(
                    npu_apb_wo_regs[i].name());
            apb_regs[npu_apb_wo_regs[i]].build();
            apb_regs[npu_apb_wo_regs[i]].configure(this, null, "");
        end

        // Create RW registers
        foreach (npu_apb_rw_regs[i]) begin
            apb_regs[npu_apb_rw_regs[i]] =
                npu_rw_reg::type_id::create(
                    npu_apb_rw_regs[i].name());
            apb_regs[npu_apb_rw_regs[i]].build();
            apb_regs[npu_apb_rw_regs[i]].configure(this, null, "");
        end

        // Create memory
        axi4_mem = npu_rw_mem::type_id::create("axi4_mem");
        axi4_mem.configure(this, "");

        // Create APB address map and add registers
        apb_map = create_map("apb_address_map", 'h0,
            npu_pkg::APB_D_W/8, UVM_LITTLE_ENDIAN);
        foreach(npu_apb_ro_regs[i]) begin
            apb_map.add_reg(apb_regs[npu_apb_ro_regs[i]],
                npu_apb_ro_regs[i], "RO");
        end
        foreach(npu_apb_wo_regs[i]) begin
            apb_map.add_reg(apb_regs[npu_apb_wo_regs[i]],
                npu_apb_wo_regs[i], "WO");
        end
        foreach(npu_apb_rw_regs[i]) begin
            apb_map.add_reg(apb_regs[npu_apb_rw_regs[i]],
                npu_apb_rw_regs[i], "RW");
        end

        // Create AXI4 address map and add shared memory
        foreach(axi4_slave_types[i]) begin
            axi4_map[axi4_slave_types[i]] = create_map($sformatf(
                    "axi4_address_map[%s]", axi4_slave_types[i]), 'h0,
                        npu_dv_pkg::AXI4_RAL_MEM_DATA_WIDTH, UVM_LITTLE_ENDIAN);
            axi4_map[axi4_slave_types[i]].add_mem(axi4_mem, '0, "RW");
        end

        // Lock model
        lock_model();

    endfunction

endclass
