package vga_axil_pkg;
  parameter int unsigned AXIL_ADDR_WIDTH = 32;
  parameter type axil_addr_t = logic [AXIL_ADDR_WIDTH-1:0];

  parameter int unsigned AXIL_DATA_WIDTH = 32;
  parameter type axil_data_t = logic [AXIL_DATA_WIDTH-1:0];

  parameter int unsigned AXIL_RESP_WIDTH = 2;
  parameter type axil_resp_t = logic [AXIL_RESP_WIDTH-1:0];

  localparam type axil_addr_data_t = struct {
    axil_addr_t addr;
    axil_data_t data;
  };
endpackage
