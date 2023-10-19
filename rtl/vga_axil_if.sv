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
  logic       ar_handshake;
  assign      ar_handshake = arvalid && arready;

  // R-channel
  axil_data_t rdata;
  axil_resp_t rresp;
  logic       rvalid;
  logic       rready;
  logic       r_handshake;
  assign      r_handshake = rvalid && rready;

  // AW-channel
  axil_addr_t awaddr;
  logic       awvalid;
  logic       awready;
  logic       aw_handshake;
  assign      aw_handshake = awvalid && awready;

  // W-channel
  axil_data_t wdata;
  axil_strb_t wstrb;
  logic       wvalid;
  logic       wready;
  logic       w_handshake;
  assign      w_handshake = wvalid && wready;

  // B-channel
  axil_resp_t bresp;
  logic       bvalid;
  logic       bready;
  logic       b_handshake;
  assign      b_handshake = bvalid && bready;

  modport slave (
    input  .clk_i   (clk),
    input  .arst_ni (arst_n),

    // AR-channel
    input  .araddr_i       (araddr),
    input  .arvalid_i      (arvalid),
    input  .ar_handshake_i (ar_handshake),
    output .arready_o      (arready),

    // R-channel
    input  .rready_i      (rready),
    input  .r_handshake_i (r_handshake),
    output .rdata_o       (rdata),
    output .rresp_o       (rresp),
    output .rvalid_o      (rvalid),

    // AW-channel
    input  .awaddr_i       (awaddr),
    input  .awvalid_i      (awvalid),
    input  .aw_handshake_i (aw_handshake),
    output .awready_o      (awready),

    // W-channel
    input  .wdata_i       (wdata),
    input  .wstrb_i       (wstrb),
    input  .wvalid_i      (wvalid),
    input  .w_handshake_i (w_handshake),
    output .wready_o      (wready),

    // B-channel
    input  .bready_i      (bready),
    input  .b_handshake_i (b_handshake),
    output .bresp_o       (bresp),
    output .bvalid_o      (bvalid)
  );

  modport master (
    input  .clk_i   (clk),
    input  .arst_ni (arst_n),

    // AR-channel
    input  .arready_i      (arready),
    input  .ar_handshake_i (ar_handshake),
    output .araddr_o       (araddr),
    output .arvalid_o      (arvalid),

    // R-channel
    input  .rdata_i       (rdata),
    input  .rresp_i       (rresp),
    input  .rvalid_i      (rvalid),
    input  .r_handshake_i (r_handshake),
    output .rready_o      (rready),

    // AW-channel
    input  .aw_handshake_i (aw_handshake),
    input  .awready_i      (awready),
    output .awaddr_o       (awaddr),
    output .awvalid_o      (awvalid),

    // W-channel
    input  .w_handshake_i (w_handshake),
    input  .wready_i      (wready),
    output .wdata_o       (wdata),
    output .wstrb_o       (wstrb),
    output .wvalid_o      (wvalid),

    // B-channel
    input  .b_handshake_i (b_handshake),
    input  .bresp_i       (bresp),
    input  .bvalid_i      (bvalid),
    output .bready_o      (bready)
  );

  `include "sva/vga_axil_if_sva.svh"
endinterface
