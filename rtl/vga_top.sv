module vga_top(
  input clk_i, arstn_i,
  
  output VGA_HS_o, VGA_VS_o,
  input [10:0] addr_x_i,
  input [10:0] addr_y_i,

  input [1:0]  color_i,
  input        we_i,

  output [11:0] RGB_o,
  output [11:0] LED_o
);

  localparam HSYNC_BITS = 11,
             VSYNC_BITS = 11,
             HD         = 1280,
             VD         = 1024;

  vga #(
    .HSYNC_BITS( HSYNC_BITS ),
    .VSYNC_BITS( VSYNC_BITS ),
    .HD( HD ),
    .VD( VD )
  ) vga(
    .clk( clk_i ),
    .arstn( arstn_i ),
    .VGA_HS( VGA_HS_o ),
    .VGA_VS( VGA_VS_o ),
    .RGB( RGB_o ),
    .LED( LED_o )
  );

endmodule