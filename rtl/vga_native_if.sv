interface vga_native_if (
  vga_axil_if axil_if
);
  import vga_axil_pkg::native_addr_t, vga_axil_pkg::axil_addr_t, vga_axil_pkg::axil_data_t;

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

  `include "../dv/vga_native_if_sva.svh"
endinterface
