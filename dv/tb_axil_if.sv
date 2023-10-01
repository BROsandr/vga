module tb_axil_if ();

  vga_clk_if    clk_if();
  vga_arst_n_if arst_n_if(clk_if.clk);
  vga_axil_if   axil_if(clk_if.clk, arst_n_if.arst_n);

  import vga_axil_pkg::*;
  axil_data_t expected_data = axil_data_t'(4);
  axil_addr_t addr          = axil_addr_t'(3);

  task automatic handle_write2slave();
    @(posedge clk_if.clk);
    axil_if.awready <= 1'b1;
    axil_if.wready  <= 1'b1;
    axil_if.bvalid  <= 1'b0;
    axil_if.bresp   <= SLVERR;

    if (axil_if.awvalid && axil_if.wvalid) begin
      if (axil_if.awaddr != addr) begin
        vga_scoreboard_error scoreboard_error = new(vga_scoreboard_error::ScbErrorAddrMismatch);
        $fatal(1, scoreboard_error.print_log(.expected($sformatf("0x%x", addr)),
                                              .actual  ($sformatf("0x%x", axil_if.awaddr))));
      end

      if (axil_if.wdata != expected_data) begin
        vga_scoreboard_error scoreboard_error = new(vga_scoreboard_error::ScbErrorAddrMismatch);
        $fatal(1, scoreboard_error.print_log(.expected($sformatf("0x%x", expected_data)),
                                             .actual  ($sformatf("0x%x", axil_if.wdata))));
      end

      axil_if.bvalid <= 1'b1;
      axil_if.bresp  <= OKAY;

      $display("OK. Slave. Write");
    end
  endtask

  task automatic handle_read2slave();
    @(posedge clk_if.clk);
    axil_if.arready <= 1'b1;
    axil_if.rvalid  <= 1'b0;
    axil_if.rresp   <= SLVERR;

    if (axil_if.arvalid && axil_if.rready) begin
      if (axil_if.araddr != addr) begin
        vga_scoreboard_error scoreboard_error = new(vga_scoreboard_error::ScbErrorAddrMismatch);
        $fatal(1, scoreboard_error.print_log(.expected($sformatf("0x%x", addr)),
                                             .actual  ($sformatf("0x%x", axil_if.araddr))));
      end

      axil_if.rvalid <= 1'b1;
      axil_if.rresp  <= OKAY;

      $display("OK. Slave. Read");
    end
  endtask

  initial begin : slave
    fork begin
      forever begin
        wait(axil_if.arst_n);
        fork
          forever begin
            handle_write2slave();
          end

          forever begin
            handle_read2slave();
          end

          begin
            wait(!axil_if.arst_n);
            axil_if.reset_slave();
          end
        join_any
        disable fork;
      end
    end join
  end

  initial begin : master
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
