interface vga_axil_if
  import vga_axil_pkg;
#(
  parameter type axil_addr_t = vga_axil_pkg::axil_addr_t,
  parameter type axil_data_t = vga_axil_pkg::axil_data_t,
  parameter type axil_resp_t = vga_axil_pkg::axil_resp_t
) (
  input logic clk,
  input logic arst_n
);
  localparam type axil_strb_t = logic [$size(axil_data_t) / $size(byte) - 1 : 0];

  // AR-channel
  axil_addr_t araddr;
  logic       arvalid;
  logic       arready;

  // R-channel
  axil_data_t rdata;
  axil_resp_t rresp;
  logic       rvalid;
  logic       rready;

  // AW-channel
  axil_addr_t awaddr;
  logic       awvalid;
  logic       awready;

  // W-channel
  axil_data_t wdata;
  axil_strb_t wstrb;

  // B-channel
  axil_resp_t bresp;
  logic       bvalid;
  logic       bready;

  task automatic read(output axil_data_t read_data);
    read_data = axil_data_t'(4);
  endtask

  task automatic write(axil_addr_t addr, axil_data_t data);
  endtask
endinterface
