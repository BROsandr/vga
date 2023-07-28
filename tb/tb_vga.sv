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
logic [11:0] RGB;

logic clk, arstn;
logic [2:0] sw;

  // Inouts

  wire [15:0]                       ddr2_dq;
  wire [1:0]                        ddr2_dqs_n;
  wire [1:0]                        ddr2_dqs_p;

    // Outputs

  wire [12:0]                      ddr2_addr;
  wire [2:0]                       ddr2_ba;
  wire                             ddr2_ras_n;
  wire                             ddr2_cas_n;
  wire                             ddr2_we_n;
  wire [0:0]                       ddr2_ck_p;
  wire [0:0]                       ddr2_ck_n;
  wire [0:0]                       ddr2_cke;
  wire [1:0]                       ddr2_dm;
  wire [0:0]                       ddr2_odt;

  ddr2_model ddr2_model (
    .ck( ddr2_ck_p ),
    .ck_n( ddr2_ck_n ),
    .cke( ddr2_cke ),
    .cs_n( 1'b0 ),
    .ras_n( ddr2_ras_n ),
    .cas_n( ddr2_cas_n ),
    .we_n( ddr2_we_n ),
    .dm_rdqs( ddr2_dm ),
    .ba( ddr2_ba ),
    .addr( ddr2_addr ),
    .dq( ddr2_dq ),
    .dqs( ddr2_dqs_p ),
    .dqs_n( ddr2_dqs_n ),
    .rdqs_n(  ),
    .odt( ddr2_odt )
  );

  vga_top_top vga_top_top(
    .clk_i( clk ), .arstn_i( arstn ),
    .sw( sw ),

    .VGA_HS_o( VGA_HS ), .VGA_VS_o( VGA_VS ),
    .RGB_o( RGB ),
    // Inouts

    .ddr2_dq,
    .ddr2_dqs_n,
    .ddr2_dqs_p,
    //( // ) Outputs
    .ddr2_addr,
    .ddr2_ba,
    .ddr2_ras_n,
    .ddr2_cas_n,
    .ddr2_we_n,
    .ddr2_ck_p,
    .ddr2_ck_n,
    .ddr2_cke,
    .ddr2_dm,
    .ddr2_odt
  );
		
    initial begin
        clk <= 0;
        forever begin
          #5 clk <= ~clk;
        end
    end
    
    initial begin
      arstn <= 0;
      #100ns;
      arstn <= 1;
      #10s
      $finish;
    
    end
    
    initial begin
        sw <= '0;
        @( posedge arstn );
        @( posedge clk );
        sw <= 3'b101;
        #1ms;
        @( posedge clk );
        sw <= 3'b001;
    end
endmodule
