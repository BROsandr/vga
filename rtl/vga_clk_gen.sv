module vga_clk_gen
  import vga_pkg::*;
(
  input  logic clk_100m_i,
  input  logic arstn_i,
  input  vga_resolution_e resolution_i,
  input  logic        req_i,

  output logic clk_o,
  output logic valid_o
);
  typedef struct {
    logic [7:0]                 freq_int;
    logic [9:0]                 freq_frac;
  } divide_s;
  divide_s divide_ff[VGA_RES_NUM];

  enum { 
    IDLE_S,
    SET_CONFIG_S,
    WAIT_LOCKED_S,
    APPLY_CONFIG_S,
    VALID_S
  } state_ff, state_next;

  logic state_en;

  localparam MULT = 10;
  localparam CLK_FREQ = 100;
  localparam STAGE_FREQ = MULT * CLK_FREQ;

  localparam CONFIG_ADDR = 11'h208;
  localparam APPLY_ADDR  = 11'h25C;

  logic                       valid_ff;
  logic                       valid_next;
    
  logic [10:0] s_axi_awaddr;
  logic        s_axi_awvalid;
  logic        s_axi_awready;
  logic [31:0] s_axi_wdata;
  logic [3:0]  s_axi_wstrb;
  logic        s_axi_wvalid;
  logic        s_axi_wready;
  logic [1:0]  s_axi_bresp;
  logic        s_axi_bvalid;
  logic        s_axi_bready;
  logic [10:0] s_axi_araddr;
  logic        s_axi_arvalid;
  logic        s_axi_arready;
  logic [31:0] s_axi_rdata;
  logic [1:0]  s_axi_rresp;
  logic        s_axi_rvalid;
  logic        s_axi_rready;
  logic        locked;

  initial begin
    divide_s divide_local_ff;

    divide_local_ff.freq_int = 8'd25;
    divide_local_ff.freq_frac = 10'd0;

    divide_ff[VGA_RES_800_600] = divide_local_ff;
  end

  initial begin
    divide_s divide_local_ff;

    divide_local_ff.freq_int = 8'd108;
    divide_local_ff.freq_frac = 10'd0;

    divide_ff[VGA_RES_1280_1024] = divide_local_ff;
  end

  always_ff @( posedge clk_100m_i or negedge arstn_i )
    if     ( ~arstn_i ) state_ff <= IDLE_S;
    else                state_ff <= state_next;

  always_comb begin
    state_next = state_ff;
    case( state_ff)
      IDLE_S: begin
        if( req_i ) state_next = SET_CONFIG_S;
      end

      SET_CONFIG_S: begin
        if( s_axi_bvalid ) state_next = WAIT_LOCKED_S;
      end

      WAIT_LOCKED_S: begin
        if( locked ) state_next = APPLY_CONFIG_S;
      end

      APPLY_CONFIG_S: begin
        if( s_axi_bvalid ) state_next = VALID_S;
      end

      VALID_S: begin
        state_next = IDLE_S;
      end

      default: begin
        state_next = IDLE_S;
      end
    endcase
  end

  always_comb begin
    s_axi_awaddr  = '0      ;
    s_axi_awvalid = '0       ;
    s_axi_wdata   = '0     ;
    s_axi_wstrb   = '1     ;
    s_axi_wvalid  = '0      ;
    s_axi_bready  = '0      ;
    s_axi_araddr  = '0      ;
    s_axi_arvalid = '0       ;
    s_axi_rvalid  = '0      ;

    case( state_ff)
      SET_CONFIG_S: begin
        s_axi_awaddr = CONFIG_ADDR;
        s_axi_awvalid = 1'b1;

        s_axi_wdata = 32'({ divide_ff[resolution_i].freq_frac, divide_ff[resolution_i].freq_int });
        s_axi_wvalid = 1'b1;

        s_axi_bready = 1'b1;
      end

      APPLY_CONFIG_S: begin
        s_axi_awaddr = APPLY_ADDR;
        s_axi_awvalid = 1'b1;

        s_axi_wdata = 32'h3;
        s_axi_wvalid = 1'b1;

        s_axi_bready = 1'b1;
      end

      VALID_S: begin
        valid_o = 1'b1;
      end
    endcase
  end

  clk_wiz_1 clk_wiz_1(
    .s_axi_aclk      (clk_100m_i),        // input s_axi_aclk                        
    .s_axi_aresetn   (arstn_i),     // input s_axi_aresetn,                                                          
    .s_axi_awaddr    (s_axi_awaddr),      // input [10 : 0] s_axi_awaddr,                              
    .s_axi_awvalid   (s_axi_awvalid),     // input s_axi_awvalid,                                                          
    .s_axi_awready   (s_axi_awready),     // output s_axi_awready,                                                         
    .s_axi_wdata     (s_axi_wdata),       // input [31 : 0] s_axi_wdata,                             
    .s_axi_wstrb     (s_axi_wstrb),       // input [3 : 0] s_axi_wstrb,                         
    .s_axi_wvalid    (s_axi_wvalid),      // input s_axi_wvalid,                                                         
    .s_axi_wready    (s_axi_wready),      // output s_axi_wready,                                                        
    .s_axi_bresp     (s_axi_bresp),       // output [1 : 0] s_axi_bresp,                                               
    .s_axi_bvalid    (s_axi_bvalid),      // output s_axi_bvalid,                                                        
    .s_axi_bready    (s_axi_bready),      // input s_axi_bready,                                                         
    .s_axi_araddr    (s_axi_araddr),      // input [10 : 0] s_axi_araddr,                              
    .s_axi_arvalid   (s_axi_arvalid),     // input s_axi_arvalid,                                                          
    .s_axi_arready   (s_axi_arready),     // output s_axi_arready,                                                         
    .s_axi_rdata     (s_axi_rdata),       // output [31 : 0] s_axi_rdata,                            
    .s_axi_rresp     (s_axi_rresp),       // output [1 : 0] s_axi_rresp,                                               
    .s_axi_rvalid    (s_axi_rvalid),      // output s_axi_rvalid,                                                        
    .s_axi_rready    (s_axi_rready),      // input s_axi_rready,                                                         
    // Clock out ports
    .clk_out1(clk_o),     // output clk_out1
    // Status and control signals
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk_100m_i)
  );      // input clk_in1
// INST_TAG_END ------ End INSTANTIATION Template ---------
endmodule