sva_axil_unsupported_wstrb : assert property (
  @(posedge clk) disable iff ($sampled(~arst_n))
  wvalid |-> wstrb == '1
) else begin
  $error("wstrb != '1 while wvalid. Other wstrb values are unsupported.");
end

// START SEE. https://github.com/pulp-platform/axi/blob/master/src/axi_intf.sv
// Single-Channel Assertions: Signals including valid must not change between valid and handshake.
// AW
AXI4_ERRM_AWADDR_STABLE : assert property (
  @(posedge clk) 
  (awvalid && !awready |=> $stable(awaddr))
);
AXI4_ERRM_AWVALID_STABLE : assert property (
  @(posedge clk) 
  (awvalid && !awready |=> awvalid)
);
// W
AXI4_ERRM_WDATA_STABLE : assert property (
  @(posedge clk) 
  (wvalid && !wready |=> $stable(wdata))
);
AXI4_ERRM_WSTRB_STABLE : assert property (
  @(posedge clk) 
  (wvalid && !wready |=> $stable(wstrb))
);
AXI4_ERRM_WVALID_STABLE : assert property (
  @(posedge clk) 
  (wvalid && !wready |=> wvalid)
);
// B
AXI4_ERRS_BRESP_STABLE : assert property (
  @(posedge clk) 
  (bvalid && !bready |=> $stable(bresp))
);
AXI4_ERRS_BVALID_STABLE : assert property (
  @(posedge clk) (bvalid && !bready |=> bvalid)
);
// AR
AXI4_ERRM_ARADDR_STABLE : assert property (
  @(posedge clk)
  (arvalid && !arready |=> $stable(araddr))
);
AXI4_ERRM_ARVALID_STABLE : assert property (
  @(posedge clk)
  (arvalid && !arready |=> arvalid)
);
// R
AXI4_ERRS_RDATA_STABLE : assert property (
  @(posedge clk)
  (rvalid && !rready |=> $stable(rdata))
);
AXI4_ERRS_RRESP_STABLE : assert property (
  @(posedge clk)
  (rvalid && !rready |=> $stable(rresp))
);
AXI4_ERRS_RVALID_STABLE : assert property (
  @(posedge clk)
  (rvalid && !rready |=> rvalid)
);
// END SEE

initial begin : sva_internal_logic_checks
  AXI4LITE_AUX_DATA_WIDTH : assert($size(axil_data_t) inside {32, 64});
  AXI4_AUX_ADDR_WIDTH     : assert($size(axil_addr_t) inside {32, 64});
end

sva_axi_reset_valid : assert property (
  @(posedge clk)
  ~arst_n |-> {wvalid, awvalid, bvalid, arvalid, rvalid} == '0
) else begin
  $error("while ~arst_n not all valid == 0");
end

AXI4_ERRM_AWVALID_RESET : assert property (
  @(posedge clk)
  ~arst_n ##1 arst_n |-> {awvalid, wvalid, bvalid, arvalid, rvalid} == '0
) else begin
  $error("valid is not 0 for the first cycle after reset");
end

localparam int  NUM_OF_VALID_TYPES = 2;
localparam type valid_e = enum bit [$clog2(NUM_OF_VALID_TYPES)-1:0] {
  AddrValid,
  DataValid
};
typedef valid_e valid_sequence[$];
valid_sequence  write_sequence;
valid_sequence  read_sequence;
valid_sequence  expected_sequence = '{AddrValid, DataValid};

function automatic void print_sequence_elements(valid_sequence seq);
  foreach (seq[i]) $display("%p ", seq[i]);
endfunction

function automatic void print_sequences(valid_sequence expected_sequence,
                                        valid_sequence actual_sequence);
  $display("Expected sequence ==");
  print_sequence_elements(expected_sequence);
  $display("");
  $display("Actual sequence ==");
  print_sequence_elements(actual_sequence);
endfunction

function automatic void check_sequence(valid_sequence actual_sequence);
  if (expected_sequence.size != actual_sequence.size) begin
    $error("expected_sequence.size != actual_sequence.size \n%d != %d",
        expected_sequence.size, actual_sequence.size);
    print_sequences(expected_sequence, actual_sequence);
  end else begin
    foreach (expected_sequence[i]) begin
      if (expected_sequence[i] != actual_sequence[i]) begin
        $error("Sequence mismatch");
        print_sequences(expected_sequence, actual_sequence);
      end
    end
  end
endfunction

always_ff @(posedge clk) begin : check_write_sequence
  if ($rose(awvalid)) write_sequence.push_back(AddrValid);
  if ($rose(wvalid))  write_sequence.push_back(DataValid);
  if ($rose(bvalid)) begin
    check_sequence(write_sequence);
    write_sequence.delete();
  end
end

always_ff @(posedge clk) begin : check_read_sequence
  if ($rose(arvalid)) read_sequence.push_back(AddrValid);
  if ($rose(rvalid)) begin
    read_sequence.push_back(DataValid);
    check_sequence(read_sequence);
    read_sequence.delete();
  end
end

// X-checks
AXI4_ERRM_AWADDR_X : assert property (
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

AXI4_ERRM_VALID_X : assert property (
  @(posedge clk)
  !$isunknown({awvalid, wvalid, bvalid, arvalid, rvalid})
)  else begin
  $error("some valid is unknown");
end

AXI4_ERRM_READY_X : assert property (
  @(posedge clk)
  !$isunknown({awready, wready, bready, arready, rready})
)  else begin
  $error("some ready is unknown");
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
