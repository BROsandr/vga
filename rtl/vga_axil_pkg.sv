// The module contains various common declarations for axi4 lite designs.

package vga_axil_pkg;
  parameter int unsigned AXIL_ADDR_WIDTH = 32;
  parameter type axil_addr_t = logic [AXIL_ADDR_WIDTH-1:0];

  parameter int unsigned AXIL_DATA_WIDTH = 32;
  parameter type axil_data_t = logic [AXIL_DATA_WIDTH-1:0];

  parameter int unsigned AXIL_RESP_WIDTH = 2;
  parameter type axil_resp_t = logic [AXIL_RESP_WIDTH-1:0];

  parameter type axil_resp_e = enum axil_resp_t { // Only responses which supported by the current IP
    OKAY   = axil_resp_t'('b00),
    SLVERR = axil_resp_t'('b10)
  };

  parameter int unsigned AXIL_WIDTH_OFFSET = 2; // axil_slave is word addressed
  parameter int unsigned NATIVE_ADDR_WIDTH = AXIL_ADDR_WIDTH - AXIL_WIDTH_OFFSET;
  parameter type native_addr_t = logic [NATIVE_ADDR_WIDTH-1:0];

  function automatic native_addr_t axil2native_addr(axil_addr_t axil_addr);
    return axil_addr[AXIL_ADDR_WIDTH-1:AXIL_WIDTH_OFFSET];
  endfunction
endpackage
