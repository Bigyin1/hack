//---------------------------------------------------------
// Class: npu_reg2apb_adapter
//---------------------------------------------------------

// Custom RAL to APB bus adapter for NPU

class npu_reg2apb_adapter extends reg2apb_adapter_t;

    `uvm_object_utils(npu_reg2apb_adapter)
    `uvm_object_new


    //---------------------------------------------------------
    // Function: bus2reg
    //---------------------------------------------------------

    // Add UVM_NOT_OK status of SLVERR
    
    virtual function void bus2reg(
            uvm_sequence_item bus_item,
        ref uvm_reg_bus_op    rw
    );
        T apb;
        super.bus2reg(bus_item, rw);
        $cast(apb, bus_item);
        if(apb.slave_err) rw.status = UVM_NOT_OK;
    endfunction


endclass
