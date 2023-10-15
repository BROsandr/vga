module vga_axil_slave_fsm_sva
  import vga_axil_pkg::axil_data_t, vga_axil_pkg::native_addr_t;
(
  // ports
  vga_axil_if        axil_if,

  input axil_data_t data_i,

  input native_addr_t addr_write_o,
  input native_addr_t addr_read_o,
  input axil_data_t   data_o,

  input logic       read_en_sync_o,
  input logic       write_en_o
);

// START x-checks
  sva_x_check_write_en : assert property (
    @(posedge axil_if.clk) disable iff (!axil_if.arst_n)
    !$isunknown(write_en_o)
  ) else begin
    $error( "write_en_o is unknown" );
    $stop;
  end

  sva_x_check_read_en : assert property (
    @(posedge axil_if.clk) disable iff (!axil_if.arst_n)
    !$isunknown(read_en_sync_o)
  ) else begin
    $error( "read_en_sync_o is unknown" );
    $stop;
  end

  sva_x_check_addr_write_en : assert property (
    @(posedge axil_if.clk) disable iff (!axil_if.arst_n)
    write_en_o |-> !$isunknown(addr_write_o)
  ) else begin
    $error( "addr_write_o is unknown while write_en_o" );
    $stop;
  end

  sva_x_check_addr_read_en : assert property (
    @(posedge axil_if.clk) disable iff (!axil_if.arst_n)
    read_en_sync_o |-> !$isunknown(addr_read_o)
  ) else begin
    $error( "addr_read_o is unknown while read_en_sync_o" );
    $stop;
  end

  sva_x_check_data_read_en : assert property (
    @(posedge axil_if.clk) disable iff (!axil_if.arst_n)
    read_en_sync_o |-> ##1 !$isunknown(data_i)
  ) else begin
    $error( "data_i is unknown after read_en_o" );
    $stop;
  end

  sva_x_check_data_write_en : assert property (
    @(posedge axil_if.clk) disable iff (!axil_if.arst_n)
    write_en_o |-> !$isunknown(data_o)
  ) else begin
    $error( "data_o is unknown while write_en_o" );
    $stop;
  end
// END x-checks
endmodule
