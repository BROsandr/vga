`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2023 11:55:15
// Design Name: 
// Module Name: tb_vga
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_clk_gen
  import vga_pkg::*;
(

    );

logic VGA_HS, VGA_VS;
logic [11:0] RGB, LED;

logic clk, arstn;
vga_resolution_e resolution;
logic req;
logic clk_out;
logic valid;
    
vga_clk_gen vga_clk_gen(
  .clk_100m_i( clk ),
  .arstn_i( arstn ),
  .resolution_i( resolution ),
  .req_i( req ),

  .clk_o( clk_out ),
  .valid_o( valid )
);
		
    initial begin
        clk <= 0;
        forever begin
          #5 clk <= ~clk;
        end
    end
    
    assign sw = 2'b11;
    
    initial begin
      arstn <= 0;
      #100ns;
      arstn <= 1;
      #10s
      $finish;
    end
    
    initial begin
      req <= 1'b1;
      resolution <= VGA_RES_1280_1024;
      @( posedge valid );
      req <= 1'b0;
      @( posedge clk );
      
      req <= 1'b1;
      resolution <= VGA_RES_800_600;
      @( posedge valid );
      req <= 1'b0;
    end
endmodule
