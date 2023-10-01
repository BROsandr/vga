module tb_axil_if ();

  vga_clk_if    clk_if();
  vga_arst_n_if arst_n_if(clk_if.clk);
  vga_axil_if   axil_if(clk_if.clk, arst_n_if.arst_n);

  initial begin
    import vga_axil_pkg::*;

    axil_data_t expected_data = axil_data_t'(4);
    axil_addr_t addr          = axil_addr_t'(3);
    axil_data_t response_data;

    // randomize expected_packet
    addr          = $random;
    expected_data = $random;

    // read-write to dut
    axil_if.write(.addr(addr), .data(expected_data));
    axil_if.read(response_data);

    // scoreboarding(check result)
    if (expected_data == response_data) begin
      $display("OK");
    end else begin
      vga_scoreboard_error scoreboard_error = new(vga_scoreboard_error::ScbErrorDataMismatch);
      $fatal(1, scoreboard_error.print_log(.expected($sformatf("0x%x", expected_data)),
                                           .actual  ($sformatf("0x%x", response_data       ))));
    end
  end
endmodule
