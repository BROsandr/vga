interface vga_axil_if #(
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
  logic       wvalid;
  logic       wready;

  // B-channel
  axil_resp_t bresp;
  logic       bvalid;
  logic       bready;

  task automatic read(output axil_data_t read_data);
    read_data = axil_data_t'(4);
  endtask

  task automatic write(axil_addr_t addr, axil_data_t data);
  endtask

  function automatic void reset_slave_w_chan(); // Only reset the axil specific(not clk, not reset)
    // AW-channel
    awready <= '0;

    // W-channle
    wready <= '0;

    // B-channel
    bresp  <= '0;
    bvalid <= '0;
  endfunction

  function automatic void reset_slave_r_chan(); // Only reset the axil specific(not clk, not reset)
    // AR-channel
    arready <= '0;

    // R-channel
    rdata  <= '0;
    rresp  <= '0;
    rvalid <= '0;
  endfunction

  function automatic void reset_slave(); // Only reset the axil specific(not clk, not reset)
    reset_slave_w_chan();
    reset_slave_r_chan();
  endfunction

  function automatic void reset_master_w_chan(); // Only reset the axil specific(not clk, not reset)
    // AW-channel
    awaddr  <= '0;
    awvalid <= '0;

    // W-channel
    wdata  <= '0;
    wstrb  <= '0;
    wvalid <= '0;

    // B-channel
    bready <= '0;
  endfunction

  function automatic void reset_master_r_chan(); // Only reset the axil specific(not clk, not reset)
    // AR-channel
    araddr  <= '0;
    arvalid <= '0;

    // R-channel
    rready <= '0;
  endfunction

  function automatic void reset_master(); // Only reset the axil specific(not clk, not reset)
    reset_master_w_chan();
    reset_master_r_chan();
  endfunction
endinterface
