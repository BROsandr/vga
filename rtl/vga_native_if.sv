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

// START write2native_channel
  native_addr_t addr_write;
  axil_data_t   data2native;
  logic         write_en;    // One clock width.
// END write2native_channel

  modport axil (
    input .clk_i   (clk),
    input .arst_ni (arst_n),

    // read2axil_channel
    input  .data_i         (data2axil),
    output .addr_read_o    (addr_read),
    output .read_en_sync_o (read_en_sync),

    // write2native_channel
    output .data_o       (data2native),
    output .addr_write_o (addr_write),
    output .write_en_o   (write_en)
  );

  modport native (
    input .clk_i   (clk),
    input .arst_ni (arst_n),

    // read2axil_channel
    input  .data_i         (data2axil),
    output .addr_read_o    (addr_read),
    output .read_en_sync_o (read_en_sync),

    // write2native_channel
    output .data_o       (data2native),
    output .addr_write_o (addr_write),
    output .write_en_o   (write_en)
  );

  `include "sva/vga_native_if_sva.svh"
endinterface
