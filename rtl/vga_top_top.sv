`timescale 1ns / 1ps

module vga_top_top
  import vga_pkg::*;
(
  input clk_i, arstn_i,
  input [2:0] sw,
  
  output VGA_HS_o, VGA_VS_o,
  output [11:0] RGB_o
);

  logic [10:0] addr_x_ff, addr_y_ff;
  logic [10:0] left_x_ff, left_y_ff;
  logic        next_row;

  logic [VGA_MAX_H_WIDTH-1:0] res_x;
  logic [VGA_MAX_V_WIDTH-1:0] res_y;

  logic [15:0]counter_ff;

  logic       counter_tick;
  
  logic [1:0]       color;
  
  // assign       color = sw;
  
  logic        we_ff;
  
  assign we_ff = 1;
  
  logic req;
  
  edge_detect #(
    .WIDTH( 1 ),
    .REGISTER_OUTPUTS( 1'b1 )
  ) in_ed (
    .clk( clk_i ),
    .anrst( 1'b1 ),
    .in( sw[2] ),
    .rising(  ),
    .falling(  ),
    .both( req )
  );

  logic clk40mhz;
  
  vga_resolution_e resolution;
  assign resolution = ( sw[2] ) ? ( VGA_RES_800_600 ) : ( VGA_RES_1280_1024 );

  assign res_x = ( resolution == VGA_RES_800_600 ) ? ( 800 ) : ( 1280 );
  assign res_y = ( resolution == VGA_RES_800_600 ) ? ( 600 ) : ( 1024 );

  
  
  vga_clk_gen clk_gen(
    .clk_100m_i( clk_i ),
    .arstn_i( arstn_i ),
    .resolution_i( resolution ),
    .req_i( req ),
  
    .clk_o( clk40mhz ),
    .valid_o()
  );
  

  vga_top vga_top(
    .clk_i( clk40mhz ), .arstn_i( arstn_i ),
    
    .VGA_HS_o( VGA_HS_o ), .VGA_VS_o( VGA_VS_o ),
    .color_i( color ),
    .addr_x_i( addr_x_ff ),
    .addr_y_i( addr_y_ff ),
    .we_i( we_ff ),
    .RGB_o( RGB_o ),
    .sw_i( sw[2] )
  );

  always_ff @( posedge clk40mhz or negedge arstn_i )
    if( ~arstn_i )
      addr_x_ff <= '0;
    else if( addr_x_ff < res_x )
      addr_x_ff <= addr_x_ff + 1'b1;
    else 
      addr_x_ff <= '0;

  always_ff @( posedge clk40mhz or negedge arstn_i )
    if( ~arstn_i )
      addr_y_ff <= '0;
    else if( addr_x_ff == res_x ) begin
      if( addr_y_ff <= res_y )
        addr_y_ff <= addr_y_ff + 1'b1;
      else
        addr_y_ff <= '0;
    end

  assign color = ( addr_y_ff inside {[left_y_ff:left_y_ff+100]} && addr_x_ff inside {[left_x_ff:left_x_ff+100]} ) ? ( 2'b1 ) : ( 2'b0 );

  always_ff @( posedge clk40mhz or negedge arstn_i )
    if( ~arstn_i )
      counter_ff <= '0;
    else 
      counter_ff <= counter_ff + 1;

  assign counter_tick = counter_ff == '0;
    
  always_ff @( posedge clk40mhz or negedge arstn_i )
    if( ~arstn_i ) left_y_ff <= '0;
    else if( counter_tick ) begin
      if( left_y_ff < res_y ) left_y_ff <= left_y_ff + 1'd1;
      else left_y_ff <= '0;
    end

  assign next_row = left_y_ff == res_y;

  always_ff @( posedge clk40mhz or negedge arstn_i )
    if( ~arstn_i ) left_x_ff <= '0;
    else if( next_row && counter_tick ) begin
      if( left_x_ff < res_x ) left_x_ff <= left_x_ff + 4;
      else left_x_ff <= '0;
    end

endmodule
