interface vga_timing_io
  import vga_pkg::*;
();
  logic [VGA_MAX_H_WIDTH-1:0] hd;
  logic [VGA_MAX_H_WIDTH-1:0] hf;
  logic [VGA_MAX_H_WIDTH-1:0] hr;
  logic [VGA_MAX_H_WIDTH-1:0] hb;
                                
  logic [VGA_MAX_V_WIDTH-1:0] vd;
  logic [VGA_MAX_V_WIDTH-1:0] vf;
  logic [VGA_MAX_V_WIDTH-1:0] vr;
  logic [VGA_MAX_V_WIDTH-1:0] vb;
endinterface