`timescale 1ns/1ps

interface vga_clk_if;
  /**
  * All functions:
  * @fn void start_clk()
  * @fn void stop_clk()
  * @fn void set_clk_period(real period)
  * @fn void set_clk_init(bit init)
  * @fn void set_clk(real period, bit init)
  **/

  //-------------------------------------------------
  // Parameters
  //-------------------------------------------------

  // Clock period
  real clk_period = 20;

  // Clock initial value
  bit clk_init = 0;

  // Clock generation event
  bit clk_gen;

  logic clk;

  //-------------------------------------------------
  // API
  //-------------------------------------------------

  // Set all clock parameters
  function automatic void set_clk(real period, bit init);
    set_clk_period(period);
    set_clk_init(init);
  endfunction

  // Set clock period
  function automatic void set_clk_period(real period);
    clk_period = period;
  endfunction

  // Set clock initial value
  function automatic void set_clk_init(bit init);
    clk_init = init;
  endfunction

  // Start clock generation
  function automatic void start_clk();
    clk_gen = 1'b1;
  endfunction

  // Stop clock generation
  function automatic void stop_clk();
    clk_gen = 1'b0;
  endfunction

  //-------------------------------------------------
  // Clock generation
  //-------------------------------------------------

  initial begin
    // Wait for clock generation permission
    wait(clk_gen);
    // Generate clock
    clk <= clk_init;
    fork
      forever begin
        wait(clk_gen);
        #(clk_period/2) clk <= ~clk;
      end
    join_none
  end

endinterface
