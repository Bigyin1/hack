//---------------------------------------------------------
// Library: NPU test library
//---------------------------------------------------------


//---------------------------------------------------------
// Class: npu_test_base
//---------------------------------------------------------

// NPU Base test

class npu_test_base extends uvm_test;

    `uvm_component_utils(npu_test_base)
    `uvm_component_new


    //---------------------------------------------------------
    // Fields
    //---------------------------------------------------------

    // Test configuration

    npu_test_cfg_base test_config;

    // Register model

    npu_reg_model reg_model;

    // Configuration for APB registers values

    npu_apb_reg_config reg_config;

    // Address map

    addr_map_t addr_map;

    // APB master configuration and agent
    
    apb_config_t apb_master_config;
    apb_agent_t  apb_master;

    // APB register adapter and predictor

    npu_reg2apb_adapter reg2apb_adapter;
    apb_reg_predictor_t apb_reg_predictor;

    // AXI4 slave configurations, delay databases and agents
    // We have 3 agents. 2 for read and 1 for write

    axi4_config_t      axi4_slave_configs [axi4_slave_type_t];
    axi4_slave_delay_t axi4_slave_delays  [axi4_slave_type_t];
    axi4_agent_t       axi4_slaves        [axi4_slave_type_t];

    // AXI4 memory adapters and predictors

    reg2axi4_adapter_t   reg2axi_adapters   [axi4_slave_type_t];
    axi4_reg_predictor_t axi_reg_predictors [axi4_slave_type_t];

    // Scoreboard
    
    npu_scoreboard scb;

    // Sequences

    uvm_reg_sequence seqs [$];


    //---------------------------------------------------------
    // Function: build_phase
    //---------------------------------------------------------
    
    // Create AXI4 environment, configure it

    virtual function void build_phase(uvm_phase phase);

        // Apply overrides
        apply_overrides();

        // Create master and slave agents
        create_agents();

        // Create scoreboard
        create_scoreboard();
        
        // Create configurations
        create_configs();

        // Create register model
        create_reg_model();

        // Set AXI4 common settings
        set_common();

        // Set AXI4 slave basic settings
        set_apb_master_basic();

        // Set AXI4 slave delays
        set_apb_master_delay();

        // Set AXI4 slave basic settings
        set_axi4_slave_basic();

        // Set AXI4 slave delays
        set_axi4_slave_delay();

        // Share AXI4 slave memories
        share_axi4_slave_mem();

    endfunction


    //---------------------------------------------------------
    // Function: apply_overrides
    //---------------------------------------------------------
    
    // Apply all needed components/objects overrides

    virtual function void apply_overrides();
    endfunction


    //---------------------------------------------------------
    // Function: create_agents
    //---------------------------------------------------------
    
    // Create agents

    virtual function void create_agents();

        // APB agent
        apb_master = apb_agent_t::type_id::create("apb_master", this);

        // Also create APB adapter and predictor
        reg2apb_adapter   = npu_reg2apb_adapter::type_id::create("reg2apb_adapter", this);
        apb_reg_predictor = apb_reg_predictor_t::type_id::create("apb_reg_predictor", this);

        // AX4 agents
        foreach(axi4_slave_types[i]) begin
             axi4_slaves[axi4_slave_types[i]] = axi4_agent_t::type_id::create(
                $sformatf("axi4_slave[%s]", axi4_slave_types[i].name().tolower()) ,this);
        end

        // Also create AXI4 adapters and predictors
        foreach(axi4_slave_types[i]) begin
            reg2axi_adapters[axi4_slave_types[i]] = reg2axi4_adapter_t::type_id::create(
                $sformatf("reg2axi_adapter[%s]", axi4_slave_types[i].name().tolower()), this);
            axi_reg_predictors[axi4_slave_types[i]] = axi4_reg_predictor_t::type_id::create(
                $sformatf("axi_reg_predictor[%s]", axi4_slave_types[i].name().tolower()), this);
        end

    endfunction


    //---------------------------------------------------------
    // Function: create_scoreboard
    //---------------------------------------------------------
    
    // Create scoreboard

    virtual function void create_scoreboard();

        scb = npu_scoreboard::type_id::create("scb", this);
    
    endfunction


    //---------------------------------------------------------
    // Function: create_configs
    //---------------------------------------------------------
    
    // Create agents configurations 
    // Also create test configuration

    virtual function void create_configs();

        // AXI4
        foreach(axi4_slave_types[i]) begin
             axi4_slave_configs[axi4_slave_types[i]] =
                axi4_config_t::type_id::create($sformatf("axi4_slave_configs[%0s]",
                    axi4_slave_types[i].name().tolower()) ,this);
        end

        // APB
        apb_master_config = apb_config_t::type_id::create("apb_master_config");

        // Create test config and pass it to the resource database
        test_config = npu_test_cfg_base::type_id::create("test_config");
        uvm_resource_db #( npu_test_cfg_base )::set(
            "*", "test_config", test_config, this);

        // Create APB registers config and pass it to the resource database
        reg_config = npu_apb_reg_config::type_id::create("reg_config");
        uvm_resource_db #( npu_apb_reg_config )::set(
            "*", "reg_config", reg_config, this);
    
    
    endfunction

    //---------------------------------------------------------
    // Function: create_reg_model
    //---------------------------------------------------------

    // Create and set register model

    virtual function void create_reg_model();

        // Create and build
        reg_model = npu_reg_model::type_id::create("reg_model");
        reg_model.build();

        // Pass register model to the resource database
        uvm_resource_db #(npu_reg_model)::set("*", "reg_model", reg_model);

    endfunction

    //---------------------------------------------------------
    // Function: set_common
    //---------------------------------------------------------
    
    // Configure setting common for masters and slaves

    virtual function void set_common();

        // Pass AXI4 configurations
        foreach(axi4_slaves[i]) axi4_slaves[i].cfg = axi4_slave_configs[i];

        // Pass APB configuration
        apb_master.cfg = apb_master_config;

        // Obtain AXI4 interfaces
        foreach(axi4_slave_configs[i]) begin
            string intf_name = $sformatf("AXI4_SLAVE_IF_%0d", i.name());
            if(!uvm_resource_db #( axi4_bfm_type )::read_by_name( get_full_name(),
                intf_name, axi4_slave_configs[i].m_bfm )) `uvm_fatal(get_name() , $sformatf(
                    "uvm_config_db #( axi4_bfm_type )::get cannot find resource %s", intf_name))
        end

        // Obtain APB interface
        begin
            string intf_name = "APB_MASTER_IF";
            if(!uvm_resource_db #( apb_bfm_type )::read_by_name( get_full_name(),
                intf_name, apb_master_config.m_bfm )) `uvm_fatal(get_name() , $sformatf(
                    "uvm_config_db #( apb_bfm_type )::get cannot find resource %s", intf_name))
        end

        // Create address map
        addr_map = addr_map_t::type_id::create("axi4_addr_map");

        // Set address mask (for AXI4 it is 4kB)
        addr_map.addr_mask = 'h0FFF;

        // Setup basic full range address space
        addr_map.add( '{
            kind  : MAP_NORMAL,
            name  : "axi4_addr_map",
            id    : -1,
            domain: MAP_NS,
            region: 0,
            addr  : 'b0,
            size  : 2**npu_dv_pkg::AXI4_ADDR_WIDTH,
            mem   : MEM_DEVICE
            // No 'prot', because no protection support
            // MAP_PROT_ATTR define is not passed to testbench
        });

    endfunction


    //---------------------------------------------------------
    // Function: set_apb_master_basic
    //---------------------------------------------------------
    
    // Configure APB master

    virtual function void set_apb_master_basic();

        // Set agent type
        apb_master_config.agent_cfg.agent_type = APB_MASTER;

        // Disable default scoreboarding
        apb_master_config.agent_cfg.en_sb = 1'b0;

        // Set address map
        apb_master_config.addr_map = addr_map;

    endfunction


    //---------------------------------------------------------
    // Function: set_apb_master_delay
    //---------------------------------------------------------
    
    // Configure APB master delays

    virtual function void set_apb_master_delay();
    endfunction


    //---------------------------------------------------------
    // Function: set_axi4_slave_basic
    //---------------------------------------------------------
    
    // Configure AXI4 slaves's scoreboarding, assertions

    virtual function void set_axi4_slave_basic();

        foreach(axi4_slave_configs[i]) begin

            // Configure AXI4-Lite slave
            axi4_slave_configs[i].agent_cfg.agent_type  = AXI4_SLAVE;
            axi4_slave_configs[i].agent_cfg.if_type     = AXI4_LITE;

            // No restriction on outstanding transactions amount
            axi4_slave_configs[i].m_max_outstanding_read_addrs  = 2**31-1;
            axi4_slave_configs[i].m_max_outstanding_write_addrs = 2**31-1;
            axi4_slave_configs[i].m_max_outstanding_wdata       = 2**31-1;

            // Enable default scoreboarding
            axi4_slave_configs[i].agent_cfg.en_sb = 1'b1;

            // Enable assertions
            axi4_slave_configs[i].m_bfm.config_enable_all_assertions = 1'b1;

            // Enable ready delays from delay db
            axi4_slave_configs[i].en_ready_control = 1;

            // Set slave ID
            axi4_slave_configs[i].slave_id = -1;

            // Set address map
            axi4_slave_configs[i].addr_map = addr_map;

            // Disable assertion on data width
            axi4_slave_configs[i].m_bfm.config_enable_assertion[AXI4_PARAM_READ_DATA_BUS_WIDTH ] = 1'b0;
            axi4_slave_configs[i].m_bfm.config_enable_assertion[AXI4_PARAM_WRITE_DATA_BUS_WIDTH] = 1'b0;

            // Disable assertions on protection
            axi4_slave_configs[i].m_bfm.config_enable_assertion[AXI4_ARPROT_UNKN] = 1'b0;
            axi4_slave_configs[i].m_bfm.config_enable_assertion[AXI4_AWPROT_UNKN] = 1'b0;

        end

    endfunction


    //---------------------------------------------------------
    // Function: set_axi4_slave_delay
    //---------------------------------------------------------
    
    // Share AXI4 slave memories

    virtual function void set_axi4_slave_delay();

        // Setup delays depending on AXI4 slave delay mode
        if( test_config.axi4_slave_always_ready )
            set_axi4_slave_delay_zero();
        else
            set_axi4_slave_delay_nonzero();

    endfunction


    //---------------------------------------------------------
    // Function: share_axi4_slave_mem
    //---------------------------------------------------------
    
    // Set shared memory for all AXI4 slaves

    virtual function void share_axi4_slave_mem();

        slave_normal_mem shared_mem;
        shared_mem = slave_normal_mem::type_id::create("shared_mem");

        foreach(axi4_slave_configs[i]) begin
            axi4_slave_configs[i].slv_mem = shared_mem;
        end

        // Pass shared mem to APB registers configuration
        reg_config.mem = shared_mem;

    endfunction


    //---------------------------------------------------------
    // Function: set_axi4_slave_delay_zero
    //---------------------------------------------------------
    
    // Set zero delays for AXI4 slave

    virtual function void set_axi4_slave_delay_zero();

        foreach(axi4_slave_types[i]) begin

            axi4_slave_delays[axi4_slave_types[i]] =
                axi4_slave_delay_t::type_id::create($sformatf("axi4_slave_delays[%s]",
                    axi4_slave_types[i].name.tolower()), this);

        end

        foreach(axi4_slave_delays[i]) begin

            // Set address map
            axi4_slave_delays[i].set_address_map(axi4_slave_configs[i].addr_map);

            // Set AXI4-Lite interface
            axi4_slave_delays[i].set_axi4lite_interface(1);

            // Set full random ready mode
            axi4_slave_delays[i].m_random_ready_mode = 1;
            axi4_slave_delays[i].m_valid2ready_mode  = 0;

            // Set ready always to 1
            axi4_slave_delays[i].m_aw_not_ready.min = 0;
            axi4_slave_delays[i].m_aw_not_ready.max = 0;
            axi4_slave_delays[i].m_ar_not_ready     = 0;
            axi4_slave_delays[i].m_ar_not_ready     = 0;
            axi4_slave_delays[i].m_w_not_ready      = 0;
            axi4_slave_delays[i].m_w_not_ready      = 0;

        end

        // Pass AXI4 slave delays to configs
        foreach(axi4_slave_configs[i])
            axi4_slave_configs[i].slave_delay = axi4_slave_delays[i];

    endfunction


    //---------------------------------------------------------
    // Function: set_axi4_slave_delay_nonzero
    //---------------------------------------------------------
    
    // Set custom delays for AXI4 slave

    virtual function void set_axi4_slave_delay_nonzero();

        axi4_slave_rd_delay_s min_rd_delays [] = new[3];
        axi4_slave_rd_delay_s max_rd_delays [] = new[3];
        axi4_slave_wr_delay_s min_wr_delays [] = new[3];
        axi4_slave_wr_delay_s max_wr_delays [] = new[3];

        foreach(axi4_slave_types[i]) begin
            axi4_slave_delays[axi4_slave_types[i]] =
                axi4_slave_delay_t::type_id::create($sformatf("axi4_slave_delays[%s]",
                    axi4_slave_types[i].name.tolower()), this);
        end

        foreach(axi4_slave_delays[i]) begin

            // Set address map
            axi4_slave_delays[i].set_address_map(axi4_slave_configs[i].addr_map);

            // Set AXI4-Lite interface
            axi4_slave_delays[i].set_axi4lite_interface(1);

            // Read database
            // Min
            min_rd_delays[i].arvalid2arready = 0;
            min_rd_delays[i].addr2data       = 0;
            min_rd_delays[i].data2data       = '{0};
            // Max
            max_rd_delays[i].arvalid2arready = $urandom_range(3, 6);
            max_rd_delays[i].addr2data       = $urandom_range(3, 6);
            max_rd_delays[i].data2data       = '{$urandom_range(3, 6)};
  
            // Set default delays for slave read database
            axi4_slave_delays[i].set_rd_def_delays(min_rd_delays[i], max_rd_delays[i]);

            // Write database
            // Min
            min_wr_delays[i].awvalid2awready = 0;
            min_wr_delays[i].wvalid2wready   = '{0};
            min_wr_delays[i].wlast2bvalid    = 0;
            // Max
            max_wr_delays[i].awvalid2awready = $urandom_range(3, 6);
            max_wr_delays[i].wvalid2wready   = '{$urandom_range(3, 6)};
            max_wr_delays[i].wlast2bvalid    = $urandom_range(3, 6);

            // Set default delays for slave write database
            axi4_slave_delays[i].set_wr_def_delays(min_wr_delays[i], max_wr_delays[i]);
        
        end

        foreach(axi4_slave_configs[i])
            axi4_slave_configs[i].slave_delay = axi4_slave_delays[i];

    endfunction


    //---------------------------------------------------------
    // Function: connect_phase
    //---------------------------------------------------------
    
    // Connect components

    virtual function void connect_phase(uvm_phase phase);

        // APB
        apb_master.ap["trans_ap"].connect(
            scb.apb_sub.analysis_export
        );

        // AXI4
        foreach(axi4_slaves[i]) begin
            axi4_slaves[i].ap["trans_ap"].connect(
                scb.axi4_subs[i].analysis_export);
        end

        // Setup sequencers for register model
        reg_model.apb_map.set_sequencer(apb_master.m_sequencer, reg2apb_adapter);
        foreach(reg_model.axi4_map[i]) begin
            reg_model.axi4_map[i].set_sequencer(
                axi4_slaves[i].m_sequencer, reg2axi_adapters[i]);
        end

        // Setup adapters for register model
        apb_reg_predictor.map = reg_model.apb_map;
        apb_reg_predictor.adapter = reg2apb_adapter;
        foreach(axi_reg_predictors[i]) begin
            axi_reg_predictors[i].map =
                reg_model.axi4_map[i];
            axi_reg_predictors[i].adapter =
                reg2axi_adapters[i];
        end

        // Connect predictors to monitors
        apb_master.ap["trans_ap"].connect(apb_reg_predictor.bus_item_export);
        foreach(axi4_slaves[i]) begin
            axi4_slaves[i].ap["trans_ap"].connect(
                axi_reg_predictors[i].bus_item_export);
        end

    endfunction


    //---------------------------------------------------------
    // Task: end_of_elaboration_phase
    //---------------------------------------------------------
    
    // Setup some logging settings and etc.

    virtual function void end_of_elaboration_phase(uvm_phase phase);
    endfunction


    //---------------------------------------------------------
    // Task: run_phase
    //---------------------------------------------------------
    
    // Main stimulus here

    virtual task main_phase(uvm_phase phase);

        phase.raise_objection(this);

        // Create sequences
        create_seqs();

        // Run sequences
        // This task will end if all sequences are
        // done or if any sequence is timeouted
        run_seqs();

        // Wait for test timeout or done
        fork
            test_timeout();
            test_is_done();
        join_any
        disable fork;

        phase.drop_objection(this);

    endtask


    //---------------------------------------------------------
    // Function: report_phase
    //---------------------------------------------------------
    
    virtual function void report_phase(uvm_phase phase);

        `uvm_info(get_name(), $sformatf(
            "\n\nTest simulation cycles: %0d\n\n",
                $time()/npu_dv_pkg::CLK_PERIOD), UVM_NONE);

    endfunction


    //---------------------------------------------------------
    // Function: create_seqs
    //---------------------------------------------------------

    // This function creates sequences to run
    // For base test its empty

    virtual function void create_seqs();
    endfunction


    //---------------------------------------------------------
    // Task: run_seqs
    //---------------------------------------------------------

    // This task runs sequences
    
    virtual task run_seqs();
        run_apb_seq_queue(seqs);
    endtask


    //---------------------------------------------------------
    // Task: run_apb_seq_queue
    //---------------------------------------------------------

    // This task runs APB sequence queue on sequencer

    virtual task run_apb_seq_queue(
        uvm_sequence seqs [$]
    );
        foreach(seqs[i]) begin
            `uvm_info(get_name(), $sformatf("Running APB sequence '%s'...",
                seqs[i].get_name()), UVM_MEDIUM);
            fork begin
                fork
                    seqs[i].start(apb_master.m_sequencer); 
                    seq_timeout();
                join_any
                disable fork;
            end join
        end
    endtask


    //---------------------------------------------------------
    // Task: test_is_done
    //---------------------------------------------------------
    
    virtual task test_is_done();

        // TODO: implement

    endtask


    //---------------------------------------------------------
    // Tasks: Timeouts
    //---------------------------------------------------------

    // Sequence timeout
    // We drop fatal if sequence is timeouted
    
    virtual task seq_timeout();
        apb_master_config.wait_for_reset();
        repeat(test_config.seq_timeout_clks)
            apb_master_config.wait_for_clock();
        `uvm_fatal(get_name(), "Sequence timeout on APB master!");
    endtask

    // Test timeout
    // We drop error if test is timeouted
    // In report phase we must print some
    // statistics for user analysis
    
    virtual task test_timeout();
        apb_master_config.wait_for_reset();
        repeat(test_config.test_timeout_clks)
            apb_master_config.wait_for_clock();
        `uvm_error(get_name(), "Test timeout!");
    endtask


    //---------------------------------------------------------
    // Function: rand_reg_config
    //---------------------------------------------------------
    
    // Function for randomizing register configuration

    virtual function void rand_reg_config();
        if(!reg_config.randomize()) begin
            `uvm_fatal(get_name(), "Can't randomize APB register configuration!");
        end
        `uvm_info(get_name(), reg_config.convert2string(), UVM_NONE);
    endfunction


    //---------------------------------------------------------
    // Function: axi4_slave_mem_init
    //---------------------------------------------------------
    
    virtual function void axi4_slave_mem_init();
        // Generate random tensors
        reg_config.gen_tensors();
        // Matrix 0
        axi4_slave_mem_init_matrix(ADDR_T0);
        // Matrix 1
        axi4_slave_mem_init_matrix(ADDR_T1);
    endfunction


    //---------------------------------------------------------
    // Function: axi4_slave_mem_init_matrix
    //---------------------------------------------------------
    
    virtual function void axi4_slave_mem_init_matrix(npu_apb_reg_t matrix);
        axi4_addr_t pos;
        // We can pick any memory because it is shared between slaves
        for(
            axi4_addr_t addr = calc_matrix_lower_bound(matrix, reg_config.apb_regs);
                        addr < calc_matrix_upper_bound(matrix, reg_config.apb_regs);
                        addr = addr + 1
        ) begin
            // Per byte
            axi4_slave_configs[LOAD_0].slv_mem.backdoor_write(addr, reg_config.tensors[matrix][pos]);
            pos = pos + 1;
        end
    endfunction


endclass


//---------------------------------------------------------
// Class: npu_apb_random_access_test
//---------------------------------------------------------

// Random reads and writes via APB.
// No MAC start

class npu_apb_random_access_test extends npu_test_base;

    `uvm_component_utils(npu_apb_random_access_test)
    `uvm_component_new


    //---------------------------------------------------------
    // Function: create_configs
    //---------------------------------------------------------

    virtual function void create_configs();
        npu_apb_reg_config::type_id::set_type_override(
            npu_apb_reg_config_no_start::get_type());
        super.create_configs();
    endfunction

    
    //---------------------------------------------------------
    // Function: run_seqs
    //---------------------------------------------------------

    virtual task run_seqs();
        npu_apb_reg_seq_base seq;
        // Iterate
        repeat(test_config.iter_am) begin
            // Randomize APB register config
            rand_reg_config();
            // Do basic APB write 
            seq = npu_apb_reg_seq_all_write::type_id::create("apb_wr_seq");
            seqs = {seq}; run_apb_seq_queue(seqs);
            // Do basic APB read
            seq = npu_apb_reg_seq_all_read::type_id::create("apb_rd_seq");
            seqs = {seq}; run_apb_seq_queue(seqs);
        end
    endtask


endclass


//---------------------------------------------------------
// Class: npu_apb_fixed_work_mode_test
//---------------------------------------------------------

// Simple work mode test
// Config -> start via CONTROL -> wait for STATUS -> repeat
// Matrixes are fixed
// Depth is 3
// Tensor 0 is 4x4
// Tensor 1 is 4x4 or 3x3

class npu_apb_fixed_work_mode_test extends npu_test_base;

    `uvm_component_utils(npu_apb_fixed_work_mode_test)
    `uvm_component_new


    //---------------------------------------------------------
    // Function: create_configs
    //---------------------------------------------------------

    virtual function void create_configs();
        npu_apb_reg_config::type_id::set_type_override(
            npu_apb_reg_config_fixed::get_type());
        super.create_configs();
    endfunction


    //---------------------------------------------------------
    // Function: run_seqs
    //---------------------------------------------------------

    virtual task run_seqs();
        npu_apb_reg_seq_base seq;
        // Iterate
        repeat(test_config.iter_am) begin
            // Randomize APB register config
            rand_reg_config();
            // Configure NPU
            seq = npu_reg_seq_config::type_id::create("seq_config");
            seqs = {seq}; run_apb_seq_queue(seqs);
            // If we good at initializing NPU - setup slaves memories
            // NPU will take matrixes from them
            axi4_slave_mem_init();
            // Start NPU
            seq = npu_reg_seq_start::type_id::create("seq_start");
            seqs = {seq}; run_apb_seq_queue(seqs);
            // Wait for NPU IDLE state
            seq = npu_reg_seq_wait_status::type_id::create("weq_wait_status");
            seqs = {seq}; run_apb_seq_queue(seqs);
        end
    endtask


endclass


//---------------------------------------------------------
// Class: npu_full_tensor_test
//---------------------------------------------------------

// NPU full tensor test with all range sizes randomly picked

class npu_full_tensor_test extends npu_apb_fixed_work_mode_test;

    `uvm_component_utils(npu_full_tensor_test)
    `uvm_component_new


    //---------------------------------------------------------
    // Function: create_configs
    //---------------------------------------------------------

    virtual function void create_configs();
        npu_apb_reg_config_fixed::type_id::set_type_override(
            npu_apb_reg_config_start::get_type());
        super.create_configs();
    endfunction


endclass


//---------------------------------------------------------
// Class: npu_small_tensor_test
//---------------------------------------------------------

// NPU small tensor test with relatively small sizes

class npu_small_tensor_test extends npu_apb_fixed_work_mode_test;

    `uvm_component_utils(npu_small_tensor_test)
    `uvm_component_new


    //---------------------------------------------------------
    // Function: create_configs
    //---------------------------------------------------------

    virtual function void create_configs();
        npu_apb_reg_config_fixed::type_id::set_type_override(
            npu_apb_reg_config_small::get_type());
        super.create_configs();
    endfunction


endclass


//---------------------------------------------------------
// Class: npu_playground_tensor_test
//---------------------------------------------------------

// NPU small tensor test with relatively small sizes

class npu_playground_tensor_test extends npu_apb_fixed_work_mode_test;

    `uvm_component_utils(npu_playground_tensor_test)
    `uvm_component_new


    //---------------------------------------------------------
    // Function: create_configs
    //---------------------------------------------------------

    virtual function void create_configs();
        npu_apb_reg_config_fixed::type_id::set_type_override(
            npu_apb_reg_config_playground::get_type());
        super.create_configs();
        test_config.iter_am = 1;
    endfunction


endclass
