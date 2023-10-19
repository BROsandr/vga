// This is axi4 lite interface with sva.
// For simplicity the interface places restrictions on users.

interface vga_axil_if
  import vga_axil_pkg::axil_resp_e, vga_axil_pkg::axil_resp_t;
#(
  parameter type axil_addr_t = vga_axil_pkg::axil_addr_t,
  parameter type axil_data_t = vga_axil_pkg::axil_data_t
) (
  input logic clk,
  input logic arst_n
);
  typedef logic [$size(axil_data_t) / $bits(byte) - 1 : 0] axil_strb_t;

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

  // START handshakes
  logic  aw_handshake;
  assign aw_handshake = awvalid && awready;

  logic  w_handshake;
  assign w_handshake = wvalid && wready;

  logic  b_handshake;
  assign b_handshake = bvalid && bready;

  logic  ar_handshake;
  assign ar_handshake = arvalid && arready;

  logic  r_handshake;
  assign r_handshake = rvalid && rready;
  // END handshakes

  task automatic read(input axil_addr_t addr, output axil_resp_e resp, output axil_data_t data);
    @(posedge clk);
    axil_if.araddr  <= addr;
    axil_if.arvalid <= 1'b1;
    axil_if.rready  <= 1'b1;
    do begin
      @(posedge clk);
    end while (!axil_if.arready);

    axil_if.arvalid <= 1'b0;

    do begin
      @(posedge clk);
    end while (!axil_if.rvalid);

    resp = axil_resp_e'(axil_if.rresp);
    data = axil_if.rdata;

    reset_master_r_chan();
  endtask

  task automatic write(input axil_addr_t addr, input axil_data_t data, output axil_resp_e resp);
    @(posedge clk);
    axil_if.awaddr  <= addr;
    axil_if.awvalid <= 1'b1;
    axil_if.wvalid  <= 1'b1;
    axil_if.wdata   <= data;
    axil_if.bready  <= 1'b1;
    axil_if.wstrb   <= '1;
    do begin
      @(posedge clk);
    end while (!axil_if.awready);

    axil_if.awvalid  <= 1'b0;

    while (!axil_if.wready) begin
      @(posedge clk);
    end

    axil_if.wvalid  <= 1'b0;

    do begin
      @(posedge clk);
    end while (!axil_if.bvalid);

    resp = axil_resp_e'(axil_if.bresp);

    reset_master_w_chan();
  endtask

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

  `include "sva/vga_axil_if_sva.svh"
endinterface
