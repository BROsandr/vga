interface vga_axil_if
  import vga_axil_pkg::axil_resp_e, vga_axil_pkg::axil_resp_t;
#(
  parameter type axil_addr_t = vga_axil_pkg::axil_addr_t,
  parameter type axil_data_t = vga_axil_pkg::axil_data_t
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

    resp = axil_if.rresp;
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

    resp = axil_if.bresp;

    reset_master_w_chan();
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

  sva_axil_unsupported_wstrb : assert property (
    @(posedge clk) disable iff ($sampled(~arst_n))
    wvalid |-> wstrb == '1
  ) else begin
    $error("wstrb != '1 while wvalid. Other wstrb values are unsupported.");
  end

  // START SEE. https://github.com/pulp-platform/axi/blob/master/src/axi_intf.sv
  // Single-Channel Assertions: Signals including valid must not change between valid and handshake.
  // AW
  assert property (@(posedge clk) (awvalid && !awready |=> $stable(awaddr)));
  assert property (@(posedge clk) (awvalid && !awready |=> awvalid));
  // W
  assert property (@(posedge clk) (wvalid && !wready |=> $stable(wdata)));
  assert property (@(posedge clk) (wvalid && !wready |=> $stable(wstrb)));
  assert property (@(posedge clk) (wvalid && !wready |=> wvalid));
  // B
  assert property (@(posedge clk) (bvalid && !bready |=> $stable(bresp)));
  assert property (@(posedge clk) (bvalid && !bready |=> bvalid));
  // AR
  assert property (@(posedge clk) (arvalid && !arready |=> $stable(araddr)));
  assert property (@(posedge clk) (arvalid && !arready |=> arvalid));
  // R
  assert property (@(posedge clk) (rvalid && !rready |=> $stable(rdata)));
  assert property (@(posedge clk) (rvalid && !rready |=> $stable(rresp)));
  assert property (@(posedge clk) (rvalid && !rready |=> rvalid));
  // END SEE

  sva_axi_reset_valid : assert property (
    @(posedge clk)
    ~arst_n |-> {wvalid, awvalid, bvalid, arvalid, rvalid} == '0
  ) else begin
    $error("while ~arst_n not all valid == 0");
  end

  // X-checks
  sva_x_awvalid : assert property (
    @(posedge clk)
    awvalid |-> !$isunknown(awaddr)
  )  else begin
    $error("awvalid == x");
  end

  sva_x_wvalid : assert property (
    @(posedge clk)
    wvalid |-> !$isunknown({wdata, wstrb})
  )  else begin
    $error("wdata or wstrb == x");
  end

  sva_x_bvalid : assert property (
    @(posedge clk)
    bvalid |-> !$isunknown(bresp)
  )  else begin
    $error("bresp == x");
  end

  sva_x_arvalid : assert property (
    @(posedge clk)
    arvalid |-> !$isunknown(araddr)
  )  else begin
    $error("araddr == x");
  end

  sva_x_rvalid : assert property (
    @(posedge clk)
    rvalid |-> !$isunknown({rresp, rdata})
  )  else begin
    $error("rresp or rdata == x");
  end

  sva_x_valid : assert property (
    @(posedge clk)
    !$isunknown({awvalid, wvalid, bvalid, arvalid, rvalid})
  )  else begin
    $error("some valid is unknonw");
  end

  sva_x_reset : assert property (
    @(posedge clk)
    !$isunknown(arst_n)
  )  else begin
    $error("reset is unknown");
  end

  // unsupported pipeline mode check

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

  sva_aw_handshake : assert property (
    @(posedge clk)
    aw_handshake |-> ##1 !aw_handshake
  )  else begin
    $error("aw_handshake during 2 clk");
  end

  sva_w_handshake : assert property (
    @(posedge clk)
    w_handshake |-> ##1 !w_handshake
  )  else begin
    $error("w_handshake during 2 clk");
  end

  sva_b_handshake : assert property (
    @(posedge clk)
    b_handshake |-> ##1 !b_handshake
  )  else begin
    $error("b_handshake during 2 clk");
  end

  sva_ar_handshake : assert property (
    @(posedge clk)
    ar_handshake |-> ##1 !ar_handshake
  )  else begin
    $error("ar_handshake during 2 clk");
  end

  sva_r_handshake : assert property (
    @(posedge clk)
    r_handshake |-> ##1 !r_handshake
  )  else begin
    $error("r_handshake during 2 clk");
  end
endinterface
