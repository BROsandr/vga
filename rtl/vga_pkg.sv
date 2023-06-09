package vga_pkg;
  localparam VGA_MAX_H = 1280;
  localparam VGA_MAX_V = 1280;

  localparam VGA_MAX_H_WIDTH = $clog2( VGA_MAX_H );
  localparam VGA_MAX_V_WIDTH = $clog2( VGA_MAX_V );
  
endpackage