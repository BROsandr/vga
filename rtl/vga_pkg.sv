package vga_pkg;
  localparam VGA_MAX_H = 1280; // maximum supported resolution in pixels
  localparam VGA_MAX_V = 1024;

  localparam VGA_MAX_H_WIDTH = $clog2( VGA_MAX_H * 2 );  // extra width for HF + HR + HB
  localparam VGA_MAX_V_WIDTH = $clog2( VGA_MAX_V * 2 );

  typedef enum {
    VGA_RES_800_600,
    VGA_RES_1280_1024,


    VGA_RES_NUM
  } resulution_t;  
endpackage