module vga_axil_slave_fsm
  import vga_axil_pkg::axil_data_t, vga_axil_pkg::axil_addr_t, vga_axil_pkg::native_addr_t;
(
  vga_axil_if        axil_if,

  input  axil_data_t data_i,

  output native_addr_t addr_write_o,
  output native_addr_t addr_read_o,
  output axil_data_t   data_o,

  output logic       read_en_o,
  output logic       write_en_o
);
  import vga_axil_pkg::AXIL_ADDR_WIDTH, vga_axil_pkg::AXIL_WIDTH_OFFSET;
  function automatic native_addr_t axil2native_addr(axil_addr_t axil_addr);
    return axil_addr[AXIL_ADDR_WIDTH-1:AXIL_WIDTH_OFFSET];
  endfunction

// START fsm state_ff, state_next logic
  localparam int  NUM_OF_STATES = 5;
  localparam type state_e = enum bit [$clog2(NUM_OF_STATES)-1:0] {
    StIdle,
    StAddr,
    StData,
    StResp,
    StAddrData
  };
  state_e read_state_ff, read_state_next, write_state_ff, write_state_next;

  always_ff @(posedge axil_if.clk or negedge axil_if.arst_n) begin
    if (!axil_if.arst_n) begin
      read_state_ff  <= StIdle;
      write_state_ff <= StIdle;
    end else begin
      read_state_ff  <= read_state_next;
      write_state_ff <= write_state_next;
    end
  end

  // state_ff is indicating what has already been done.
  //   For example state == StAddr indicates that an address has been accepted.
  always_comb begin : read
    read_state_next = read_state_ff;
    unique case (read_state_ff)
      StIdle: if (axil_if.ar_handshake) read_state_next = StAddr;
      StAddr:                           read_state_next = StData;
      StData:                           read_state_next = StResp;
      StResp: if (axil_if.r_handshake)  read_state_next = StIdle;

      default:                          read_state_next = StIdle;
    endcase
  end

  always_comb begin : write
    write_state_next = write_state_ff;
    unique case (write_state_ff)
      StIdle    : if (axil_if.aw_handshake && axil_if.w_handshake) write_state_next = StAddrData;
      StAddrData:                                                  write_state_next = StResp;
      StResp    : if (axil_if.b_handshake)                         write_state_next = StIdle;

      default:                                                     write_state_next = StIdle;
    endcase
  end
// END fsm state_ff, state_next logic

// START read logic
// START axil_if.arready
  logic arready_ff;
  logic arready_next;

  assign arready_next = read_state_next == StIdle;

  always_ff @(posedge axil_if.clk or negedge axil_if.arst_n) begin
    if      (!axil_if.arst_n) arready_ff <= '0;
    else                      arready_ff <= arready_next;
  end
// END axil_if.arready

// START addr_read_ff
  native_addr_t addr_read_ff;
  native_addr_t addr_read_next;
  logic         addr_read_en;

  assign      addr_read_en   = read_state_next == StAddr;
  assign      addr_read_next = axil2native_addr(axil_if.araddr);

  always_ff @(posedge axil_if.clk or negedge axil_if.arst_n) begin
    if      (!axil_if.arst_n) addr_read_ff <= '0;
    else if (addr_read_en   ) addr_read_ff <= addr_read_next;
  end
// END addr_read_ff

// START read_en
  logic read_en_ff;
  logic read_en_next;

  assign read_en_next = read_state_next == StAddr;

  always_ff @(posedge axil_if.clk or negedge axil_if.arst_n) begin
    if      (!axil_if.arst_n) read_en_ff <= '0;
    else                      read_en_ff <= read_en_next;
  end
// END read_en

// START axil_if.rrvalid
  logic rvalid_ff;
  logic rvalid_next;

  assign rvalid_next = read_state_next == StResp;

  always_ff @(posedge axil_if.clk or negedge axil_if.arst_n) begin
    if      (!axil_if.arst_n) rvalid_ff <= '0;
    else                      rvalid_ff <= rvalid_next;
  end
// END axil_if.rvalid

// START axil_if.rdata
  axil_data_t rdata_ff;
  axil_data_t rdata_next;
  logic       rdata_en;

  assign rdata_en   = read_state_next == StData;
  assign rdata_next = data_i;

  always_ff @(posedge axil_if.clk or negedge axil_if.arst_n) begin
    if      (!axil_if.arst_n) rdata_ff <= '0;
    else if (rdata_en       ) rdata_ff <= rdata_next;
  end
// END axil_if.rdata
// END read logic

// START write logic
// START write_en
  logic write_en_ff;
  logic write_en_next;

  assign write_en_next = write_state_next == StAddrData;

  always_ff @(posedge axil_if.clk or negedge axil_if.arst_n) begin
    if      (!axil_if.arst_n) write_en_ff <= '0;
    else                      write_en_ff <= write_en_next;
  end
// END write_en

// START axil_if.bvalid
  logic bvalid_ff;
  logic bvalid_next;

  assign bvalid_next = write_state_next == StResp;

  always_ff @(posedge axil_if.clk or negedge axil_if.arst_n) begin
    if      (!axil_if.arst_n) bvalid_ff <= '0;
    else                      bvalid_ff <= bvalid_next;
  end
// END axil_if.bvalid

// START axil_if.awready
  logic awready_ff;
  logic awready_next;

  assign awready_next = read_state_next == StIdle;

  always_ff @(posedge axil_if.clk or negedge axil_if.arst_n) begin
    if      (!axil_if.arst_n) awready_ff <= '0;
    else                      awready_ff <= awready_next;
  end
// END axil_if.awready

// START data_out_ff
  axil_data_t data_out_ff;
  axil_data_t data_out_next;
  logic       data_out_en;

  assign      data_out_en   = write_state_next == StAddrData;
  assign      data_out_next = axil_if.wdata;

  always_ff @(posedge axil_if.clk or negedge axil_if.arst_n) begin
    if      (!axil_if.arst_n    ) data_out_ff <= '0;
    else if (data_out_en        ) data_out_ff <= data_out_next;
  end
// END data_ff

// START addr_write_ff
  native_addr_t addr_write_ff;
  native_addr_t addr_write_next;
  logic         addr_write_en;

  assign      addr_write_en   = write_state_next == StAddrData;
  assign      addr_write_next = axil2native_addr(axil_if.awaddr);

  always_ff @(posedge axil_if.clk or negedge axil_if.arst_n) begin
    if      (!axil_if.arst_n    ) addr_write_ff <= '0;
    else if (addr_write_en      ) addr_write_ff <= addr_write_next;
  end
// END addr_write_ff
// END write logic

// START out assignments
  assign addr_write_o = addr_write_ff;
  assign addr_read_o  = addr_read_ff;
  assign read_en_o    = read_en_ff;
  assign write_en_o   = write_en_ff;
  assign data_o       = data_out_ff;

  assign axil_if.arready = arready_ff;
  assign axil_if.awready = awready_ff;
  assign axil_if.wready  = awready_ff; // simultaneous with axil_if.awready
  assign axil_if.bvalid  = bvalid_ff;
  assign axil_if.rvalid  = rvalid_ff;
  assign axil_if.rdata   = rdata_ff;

  import vga_axil_pkg::axil_resp_t, vga_axil_pkg::OKAY;
  assign axil_if.rresp   = axil_resp_t'(OKAY);
  assign axil_if.bresp   = axil_resp_t'(OKAY);
// END out assignments

endmodule
