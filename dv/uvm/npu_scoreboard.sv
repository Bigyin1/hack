typedef class npu_scoreboard;

//---------------------------------------------------------
// Classes: NPU subscribers
//---------------------------------------------------------

// APB

class npu_subscriber_apb
    extends uvm_subscriber#(mvc_sequence_item_base);

    `uvm_component_utils(npu_subscriber_apb)


    //---------------------------------------------------------
    // Field: m_scb
    //---------------------------------------------------------

    // Handle for parent scoreboard

    protected npu_scoreboard m_scb;


    //---------------------------------------------------------
    // Function: new
    //---------------------------------------------------------

    function new(string name, uvm_component parent);
        super.new(name, parent);
        $cast(m_scb, parent);
    endfunction


    //---------------------------------------------------------
    // Function: write
    //---------------------------------------------------------

    // Print AXI4 transaction and execute scoreboard logging

    virtual function void write(mvc_sequence_item_base t);
        apb_rw_trans_t t_;
        $cast(t_, t.clone());
        `uvm_info(get_name(), $sformatf("Got APB transaction:\n %s",
            t_.convert2string()), UVM_HIGH);
        m_scb.log_apb(t_);
    endfunction


endclass

// AXI4

class npu_subscriber_axi4
    extends uvm_subscriber#(mvc_sequence_item_base);

    `uvm_component_utils(npu_subscriber_axi4)


    //---------------------------------------------------------
    // Field: m_scb
    //---------------------------------------------------------

    // Handle for parent scoreboard

    protected npu_scoreboard m_scb;


    //---------------------------------------------------------
    // Field: slave_type
    //---------------------------------------------------------

    // See npu_dv_pkg.sv

    axi4_slave_type_t slave_type;


    //---------------------------------------------------------
    // Function: new
    //---------------------------------------------------------

    function new(string name, uvm_component parent);
        super.new(name, parent);
        $cast(m_scb, parent);
    endfunction


    //---------------------------------------------------------
    // Function: write
    //---------------------------------------------------------

    // Print AXI4 transaction and execute scoreboard logging

    virtual function void write(mvc_sequence_item_base t);
        axi4_rw_trans_t t_;
        $cast(t_, t.clone());
        `uvm_info(get_name(), $sformatf("Got AXI4 %s transaction:\n %s",
            slave_type.name().tolower(), t_.convert2string()), UVM_HIGH);
        m_scb.log_axi4(t_, slave_type);
    endfunction


endclass


//---------------------------------------------------------
// Class: npu_scoreboard
//---------------------------------------------------------

// NPU scoreboard
// Receives AXI4 write transactions from NPU and checks
// MAC calculation result with reference model

class npu_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(npu_scoreboard)
    `uvm_component_new


    //---------------------------------------------------------
    // Field: npu
    //---------------------------------------------------------

    // NPU model

    npu_model npu;


    // Configuration for APB registers values

    npu_apb_reg_config reg_config;


    //---------------------------------------------------------
    // Fields: Subscribers
    //---------------------------------------------------------

    // AXI4
    // See npu_dv_pkg.sv about ~axi4_rw_trans_t~

    npu_subscriber_axi4 axi4_subs [axi4_slave_type_t];

    // APB
    // See npu_dv_pkg.sv about ~apb_rw_trans_t~

    npu_subscriber_apb apb_sub;


    //---------------------------------------------------------
    // Fields: Transaction counters
    //---------------------------------------------------------

    int unsigned apb_control_wr_cnt;
    int unsigned apb_status_rd_cnt;


    //---------------------------------------------------------
    // Field: check_cnt
    //---------------------------------------------------------

    // Checks count

    int unsigned check_cnt;


    //---------------------------------------------------------
    // Function: build_phase
    //---------------------------------------------------------

    virtual function void build_phase(uvm_phase phase);
        // Get APB registers configuration
        if (!uvm_resource_db#(npu_apb_reg_config)::read_by_name("*", "reg_config", reg_config))
            `uvm_fatal(get_name(), "Can't find register config in resource database!");
        // Create subscribers
        foreach(axi4_slave_types[i]) begin
            axi4_subs[axi4_slave_types[i]] = new($sformatf(
                "axi4_subs[%s]", axi4_slave_types[i].name().tolower()), this);
            axi4_subs[axi4_slave_types[i]].slave_type = axi4_slave_types[i];
        end
        apb_sub = npu_subscriber_apb::type_id::create("apb_sub", this);
        // Create NPU model
        npu = npu_model::type_id::create("npu");
    endfunction


    //---------------------------------------------------------
    // Task: reset_phase
    //---------------------------------------------------------

    virtual task reset_phase(uvm_phase phase);
        reset_counters();
    endtask


    //---------------------------------------------------------
    // Function: reset_counters
    //---------------------------------------------------------

    virtual function void reset_counters();
        apb_status_rd_cnt  = 0;
        apb_control_wr_cnt = 0;
    endfunction


    //---------------------------------------------------------
    // Function: log_axi4
    //---------------------------------------------------------

    // Function for logging AXI4 transactions

    virtual function void log_axi4(axi4_rw_trans_t t, axi4_slave_type_t slave_type);
        case(slave_type)
            LOAD_0, LOAD_1: check_axi4_load(t);
            STORE_0       : check_axi4_store(t);
        endcase
    endfunction


    //---------------------------------------------------------
    // Function: check_axi4_load
    //---------------------------------------------------------

    // Function for logging AXI4 load transactions

    virtual function void check_axi4_load(axi4_rw_trans_t t);
    endfunction


    //---------------------------------------------------------
    // Function: check_axi4_store
    //---------------------------------------------------------

    // Function for logging AXI4 store transactions

    virtual function void check_axi4_store(axi4_rw_trans_t t);
    endfunction


    //---------------------------------------------------------
    // Function: log_apb
    //---------------------------------------------------------

    // Function for logging APB transactions and calling
    // result comparison with model if appropriate sequence
    // of transactions was executed: CONTROL was written with 1
    // and status was read with 0 after that

    virtual function void log_apb(apb_rw_trans_t t);

        // Update statistics
        case(t.read_or_write)
            APB3_TRANS_READ : begin
                if(
                    (npu_apb_reg_t' (t.addr   ) == STATUS) &&
                    (npu_apb_data_t'(t.rd_data) ==    'b0)
                ) begin
                    apb_status_rd_cnt += 1;
                    // If we got equal amount of reads from STATUS and
                    // writes to CONTROL, we check result
                    if(apb_status_rd_cnt == apb_control_wr_cnt) check();
                end
            end
            APB3_TRANS_WRITE: begin
                if(
                    (npu_apb_reg_t' (t.addr   ) ==               CONTROL) &&
                    (npu_apb_data_t'(t.wr_data) == npu_apb_data_t'(1'b1))
                )
                apb_control_wr_cnt += 1;
            end
        endcase

    endfunction


    //---------------------------------------------------------
    // Function: check
    //---------------------------------------------------------

    virtual function void check();

        // Expected (modeled) result
        bytearr_t expt_result;
        intarr_t  iexpt_result;

        // Real result
        byte real_result [$];

        // Result address range
        // Will be calculated lower
        matrix_addr_range_t tensor_2_ar;

        begin

            // Calculate result depending on current configuration
            npu.model(
                // Input tensors
                .matrix_1(bytearr2intarr(reg_config.tensors[ADDR_T0])),
                .matrix_2(bytearr2intarr(reg_config.tensors[ADDR_T1])),
                // Settings
                .zp_1    (signed'(8'(reg_config.apb_regs[ZP_T0   ]))),
                .zp_2    (signed'(8'(reg_config.apb_regs[ZP_T1   ]))),
                .zp_3    (signed'(8'(reg_config.apb_regs[ZP_T2   ]))),
                .bias    (signed'(   reg_config.apb_regs[BIAS_T2 ]) ),
                .scale   (signed'(   reg_config.apb_regs[SCALE_T2]) ),
                .shift   (reg_config.apb_regs[SHIFT_T2]),
                // Sizes
                .size_1  ('{reg_config.apb_regs[ADDR_T0_0],
                            reg_config.apb_regs[ADDR_T0_1],
                            reg_config.apb_regs[ADDR_T0_2]}),
                .size_2  ('{reg_config.apb_regs[ADDR_T1_0],
                            reg_config.apb_regs[ADDR_T1_1],
                            reg_config.apb_regs[ADDR_T1_2]}),
                .size_3  ('{reg_config.apb_regs[ADDR_T2_0],
                            reg_config.apb_regs[ADDR_T2_1],
                            reg_config.apb_regs[ADDR_T2_2]}),
                // Result
                .matrix_3(iexpt_result)
            );
            expt_result = intarr2bytearr(iexpt_result);

            // Calculate result tensor range in memory
            tensor_2_ar = calc_matrix_addr_range(ADDR_T2, reg_config.apb_regs);

            // Get actual result from NPU from memory
            begin
                axi4_addr_t addr = tensor_2_ar[0];
                while(addr < tensor_2_ar[1]) begin
                    real_result.push_back(reg_config.mem.backdoor_read(addr));
                    addr += 1;
                end
            end

            begin
                bit status; string msg;
                status = compare(real_result, expt_result, tensor_2_ar, msg);
                if(status) begin
                    `uvm_error(get_name(), {"\n\nTensor comparison mismatch!\n", msg});
                end
                else begin
                    `uvm_info(get_name(), "Tensor comparison passed!", UVM_NONE);
                end
            end
            
        end

    endfunction


    //---------------------------------------------------------
    // Function: compare
    //---------------------------------------------------------

    virtual function bit compare(
               bytearr_t           real_result,
               bytearr_t           expt_result,
               matrix_addr_range_t ar,
        output string              msg
    );
        bit status; axi4_addr_t addr = ar[0];
        msg = {msg, "Byte by byte comparison:\n"};
        msg = {msg, "+----------------+-----------------+-----------------+---------------+\n"  };
        msg = {msg, "+ Address        | Real            | Expected        | Mismatch      |\n"  };
        msg = {msg, "+----------------+-----------------+-----------------+---------------+\n"  };
        foreach (real_result[i]) begin
            msg = {msg, $sformatf("|       %-8h |              %-2h |              %-2h |             %-1b |\n",
                addr, real_result[i], expt_result[i], real_result[i] !== expt_result[i])};
            msg = {msg, "+----------------+-----------------+-----------------+---------------+\n"  };
            status |= real_result[i] !== expt_result[i];
            addr += 1;
        end
        return status;
    endfunction


endclass
