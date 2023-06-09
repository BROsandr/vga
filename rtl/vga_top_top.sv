`timescale 1ns / 1ps

module vga_top_top(
  input clk_i, arstn_i,
  input [1:0] sw,
  
  output VGA_HS_o, VGA_VS_o,
  output [11:0] RGB_o,
  output [11:0] LED_o
);

  logic [10:0] addr_x, addr_y_ff;
  
  assign addr_x = 11'd1000;
  
  logic [1:0]       color;
  
  assign       color = sw;
  
  logic        we_ff;
  
  assign we_ff = 1;

  vga_top vga_top(
    .clk_i( clk_i ), .arstn_i( arstn_i ),
    
    .VGA_HS_o( VGA_HS_o ), .VGA_VS_o( VGA_VS_o ),
    .color_i( color ),
    .addr_x_i( addr_x ),
    .addr_y_i( addr_y_ff ),
    .we_i( we_ff ),
    .RGB_o( RGB_o ),
    .LED_o( LED_o )
  );
    
  always_ff @( posedge clk_i or negedge arstn_i )
    if( ~arstn_i ) addr_y_ff <= '0;
    else if( addr_y_ff < 11'd1024 ) addr_y_ff <= addr_y_ff + 1'd1;
    else addr_y_ff <= '0;

endmodule
