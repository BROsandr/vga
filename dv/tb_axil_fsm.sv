`include "./common/vga_scoreboard_error.svh"

module tb_axil_fsm ();

  vga_clk_if         clk_if    ();
  vga_arst_n_if      arst_n_if (clk_if.clk);
  vga_axil_if        axil_if   (clk_if.clk, arst_n_if.arst_n);

  import vga_axil_pkg::*;
  axil_data_t expected_data[native_addr_t];
  axil_data_t actual_data  [native_addr_t];

  axil_data_t   data2axil;
  native_addr_t addr_write;
  native_addr_t addr_read;
  axil_data_t   data2native;
  logic         read_en_sync;
  logic         write_en;

  vga_axil_slave_fsm axil_slave_fsm (
    .axil_if,
    .data_i         (data2axil),
    .addr_write_o   (addr_write),
    .addr_read_o    (addr_read),
    .data_o         (data2native),
    .read_en_sync_o (read_en_sync),
    .write_en_o     (write_en)
  );

  bind vga_axil_slave_fsm vga_axil_slave_fsm_sva vga_axil_slave_fsm_sva (.*);

  task automatic handle_write2slave();
    @(posedge clk_if.clk);

    if (write_en) begin
      actual_data[addr_write] = data2native;

      $display($sformatf("OK. Time == %f. Slave. Write. Addr == 0x%x, Data == 0x%x",
          $time, addr_write, data2native));
    end
  endtask

  task automatic handle_read2slave();
    @(posedge clk_if.clk);

    if (read_en_sync) begin
      data2axil <= actual_data[addr_read];

      $display($sformatf("OK. Time == %f. Slave. Read. Addr == 0x%x, Data == 0x%x",
          $time, addr_read, data2axil));
    end
  endtask

  initial begin : slave
    axil_if.reset_slave();
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

  function automatic void check_resp(axil_resp_e expected, axil_resp_e actual);
    if (expected != actual) begin
      vga_scoreboard_error scoreboard_error = new(vga_scoreboard_error::ScbErrorRespMismatch);
      $fatal(1, scoreboard_error.print_log(.expected($sformatf("0x%x", expected)),
                                           .actual  ($sformatf("0x%x", actual  ))));
    end
  endfunction

  task automatic reset();
    arst_n_if.arst_n <= 1'b0;
    axil_if.reset_master();
    #100ns;
    arst_n_if.arst_n <= 1'b1;
  endtask

  function automatic check_addr_data(axil_addr_t addr, axil_data_t actual_data);
    if (!expected_data.exists(addr)) begin
      vga_scoreboard_error scoreboard_error = new(vga_scoreboard_error::ScbErrorUnexpectedAddr);
      $fatal(1, scoreboard_error.print_log(.expected($sformatf("0x%x", addr))));
    end
    if (expected_data[addr] == actual_data) begin
      $display($sformatf("OK. Time == %f", $time));
    end else begin
      vga_scoreboard_error scoreboard_error = new(vga_scoreboard_error::ScbErrorDataMismatch);
      $fatal(1, scoreboard_error.print_log(.expected($sformatf("0x%x", expected_data[addr])),
                                           .actual  ($sformatf("0x%x", actual_data       ))));
    end
  endfunction

  // task automatic random_test(int iteration = 10);
  //   axil_data_t response_data;
  //   axil_resp_e response;

  //   repeat (iteration) begin
  //     // randomize expected_packet
  //     expected_axil_addr = $random;
  //     expected_data      = $random;

  //     // read-write to dut
  //     axil_if.write(.addr(expected_axil_addr), .data(expected_data), .resp(response));
  //     check_resp(.expected(OKAY), .actual(response));

  //     axil_if.read(.addr(expected_axil_addr), .resp(response), .data(response_data));
  //     check_resp(.expected(OKAY), .actual(response));

  //     // store packet into the expected map
  //     expected_data[expected_axil_addr] = expected_data;

  //     // scoreboarding(check result)
  //     check_addr_data(.addr(addr
  //   end
  // endtask

  task automatic continuous_test(int iteration = 10);
    int unsigned word_counter = 0;

    $display("continuous_test started");

    repeat (iteration) begin
      axil_data_t data;
      axil_addr_t addr;
      axil_resp_e response;

      addr          = axil_addr_t'(word_counter);
      data          = axil_addr_t'(word_counter);
      word_counter += AXIL_ADDR_WIDTH / $size(byte);

      axil_if.write(.addr(addr), .data(data), .resp(response));
      check_resp(.expected(OKAY), .actual(response));

      // store packet into the expected map
      expected_data[addr] = data;
    end

    word_counter = 0;

    repeat (iteration) begin
      axil_data_t data;
      axil_addr_t addr;
      axil_resp_e response;

      addr          = axil_addr_t'(word_counter);
      word_counter += AXIL_ADDR_WIDTH / $size(byte);

      axil_if.read(.addr(addr), .resp(response), .data(data));
      check_resp(.expected(OKAY), .actual(response));

      // scoreboarding(check result)
      check_addr_data(.addr(addr), .actual_data(data));
    end

    $display("continuous_test ended");
  endtask

  initial begin : master
    // Set up environment
    clk_if.start_clk();
    reset();
    continuous_test();

    $finish();
  end
endmodule
