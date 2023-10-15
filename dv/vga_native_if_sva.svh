// START x-checks
  sva_x_check_write_en : assert property (
    @(posedge axil_if.clk) disable iff (!axil_if.arst_n)
    !$isunknown(write_en)
  ) else begin
    $error( "write_en is unknown" );
    $stop;
  end

  sva_x_check_read_en : assert property (
    @(posedge axil_if.clk) disable iff (!axil_if.arst_n)
    !$isunknown(read_en_sync)
  ) else begin
    $error( "read_en_sync is unknown" );
    $stop;
  end

  sva_x_check_addr_write_en : assert property (
    @(posedge axil_if.clk) disable iff (!axil_if.arst_n)
    write_en |-> !$isunknown(addr_write)
  ) else begin
    $error( "addr_write is unknown while write_en_o" );
    $stop;
  end

  sva_x_check_addr_read_en : assert property (
    @(posedge axil_if.clk) disable iff (!axil_if.arst_n)
    read_en_sync |-> !$isunknown(addr_read)
  ) else begin
    $error( "addr_read is unknown while read_en_sync" );
    $stop;
  end

  sva_x_check_data_read_en : assert property (
    @(posedge axil_if.clk) disable iff (!axil_if.arst_n)
    read_en_sync |-> ##1 !$isunknown(data2axil)
  ) else begin
    $error( "data2native is unknown after read_en" );
    $stop;
  end

  sva_x_check_data_write_en : assert property (
    @(posedge axil_if.clk) disable iff (!axil_if.arst_n)
    write_en |-> !$isunknown(data2native)
  ) else begin
    $error( "data is unknown while write_en" );
    $stop;
  end
// END x-checks
