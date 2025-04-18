//---------------------------------------------------------
// Utility: AXI4 APM utilities
//---------------------------------------------------------

// UVM object new

`define uvm_object_new \
    function new (string name = ""); \
        super.new( name ); \
    endfunction

// UVM component new

`define uvm_component_new \
    function new(string name , uvm_component parent); \
        super.new(name, parent); \
    endfunction

// AXI4 parameters instance

`define AXI4_PARAMS_INST \
    .AXI4_ADDRESS_WIDTH   ( npu_dv_pkg::AXI4_ADDR_WIDTH      ), \
    .AXI4_RDATA_WIDTH     ( npu_dv_pkg::AXI4_DATA_WIDTH      ), \
    .AXI4_WDATA_WIDTH     ( npu_dv_pkg::AXI4_DATA_WIDTH      ), \
    .AXI4_ID_WIDTH        ( npu_dv_pkg::AXI4_ID_WIDTH        ), \
    .AXI4_USER_WIDTH      ( npu_dv_pkg::AXI4_USER_WIDTH      ), \
    .AXI4_REGION_MAP_SIZE ( npu_dv_pkg::AXI4_REGION_MAP_SIZE )

// APB parameters instance

`define APB_PARAMS_INST \
    .SLAVE_COUNT   ( npu_dv_pkg::APB_SLAVE_COUNT   ), \
    .ADDRESS_WIDTH ( npu_dv_pkg::APB_ADDRESS_WIDTH ), \
    .WDATA_WIDTH   ( npu_dv_pkg::APB_WDATA_WIDTH   ), \
    .RDATA_WIDTH   ( npu_dv_pkg::APB_RDATA_WIDTH   )

// APB interface parameters instance

`define APB_INTF_PARAMS_INST \
    .APB3_SLAVE_COUNT      ( npu_dv_pkg::APB_SLAVE_COUNT   ), \
    .APB3_PADDR_BIT_WIDTH  ( npu_dv_pkg::APB_ADDRESS_WIDTH ), \
    .APB3_PWDATA_BIT_WIDTH ( npu_dv_pkg::APB_WDATA_WIDTH   ), \
    .APB3_PRDATA_BIT_WIDTH ( npu_dv_pkg::APB_RDATA_WIDTH   )

// Function for getting current date and time as string

function automatic string get_date();    
    int fd; string date;
    void'($system("date > localtime"));
    fd = $fopen("localtime", "r");
    void'($fgets(date, fd));
    $fclose(fd);
    void'($system("rm localtime"));
    return date;
endfunction
