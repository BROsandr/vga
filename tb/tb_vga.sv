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


module tb_vga(

    );

logic VGA_HS, VGA_VS;
logic [11:0] RGB, LED;

logic clk, arstn;
logic [1:0] sw;
    
  vga_top_top vga_top_top(
    .clk_i( clk ), .arstn_i( arstn ),
    .sw( sw ),

    .VGA_HS_o( VGA_HS ), .VGA_VS_o( VGA_VS ),
    .RGB_o( RGB ),
    .LED_o( LED )
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
endmodule
