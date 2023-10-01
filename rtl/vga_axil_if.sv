interface vga_axil_if
  import vga_axil_pkg::*;
(
  input logic clk,
  input logic arst_n
);
  // AR-channel
  axil_addr_t araddr;
  logic       arvalid;
  logic       arready;

  // R-channel
  axil_data_t rdata;
  axil_resp_t rresp;

  task automatic read(output axil_data_t read_data);
    read_data = axil_data_t'(4);
  endtask

  task automatic write(axil_addr_data_t addr_data);
  endtask
endinterface
