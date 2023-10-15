// This is a simple interface for addressed read/write connecting a slave to the axil converter.

interface vga_native_if #(
  parameter type native_addr_t = vga_axil_pkg::native_addr_t,
  parameter type axil_data_t   = vga_axil_pkg::axil_data_t
) (
  vga_axil_if axil_if
);
// START clk, reset
  logic  clk;
  assign clk = axil_if.clk;

  logic  arst_n;
  assign arst_n = axil_if.arst_n;
// END clk, reset

// START read2axil_channel
  axil_data_t   data2axil;
  native_addr_t addr_read;
  logic         read_en_sync; // Synchronous read. One clock width
// END read2axil_channel

// START write2axil_channel
  native_addr_t addr_write;
  axil_data_t   data2native;
  logic         write_en;    // One clock width.
// END write2axil_channel

  `include "sva/vga_native_if_sva.svh"
endinterface
