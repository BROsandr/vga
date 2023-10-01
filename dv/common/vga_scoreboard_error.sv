class vga_scoreboard_error;
  parameter int unsigned SCB_NUM_OF_ERRORS = 2;
  parameter type scoreboard_error_e = enum bit [SCB_NUM_OF_ERRORS-1:0] {
    ScbErrorAddrMismatch,
    ScbErrorDataMismatch
  };
  scoreboard_error_e error = 'x;

  function new(scoreboard_error_e error);
    this.error = error;
  endfunction

  function string print_log(string expected, string actual);
    unique case (error)
      ScbErrorAddrMismatch: begin
        return $sformatf("ERROR. Address mismatch. Expected address == %s, actual address == %s",
            expected, actual);
      end
      ScbErrorDataMismatch: begin
        return $sformatf("ERROR. Data mismatch. Expected data == %s, actual data == %s",
            expected, actual);
      end
    endcase
  endfunction
endclass
