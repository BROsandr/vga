module vga_apb_wrapper
#(
  parameter APB_ADDR_WIDTH = 12,  // APB slaves are 4KB by default
  parameter APB_DATA_WIDTH = 32
)
(
  input  logic                      clk_i,
  input  logic                      rstn_i,
  input  logic [APB_ADDR_WIDTH-1:0] apb_paddr_i,
  input  logic [APB_DATA_WIDTH-1:0] apb_pwdata_i,
  input  logic                      apb_pwrite_i,
  input  logic                      apb_psel_i,
  input  logic                      apb_penable_i,
  output logic [APB_DATA_WIDTH-1:0] apb_prdata_o,
  output logic                      apb_pready_o,
  output logic                      apb_pslverr_o,

  output logic                      vga_hs_o,
  output logic                      vga_vs_o,
  output logic [11:0]               rgb_o
);

  // Local declarations

  localparam ADDR_X     = 12'h0;
  localparam ADDR_Y     = 12'h4;
  localparam ADDR_COLOR = 12'h8;
  localparam ADDR_WE    = 12'hc;

  logic                      apb_write;
  logic                      apb_read;

  logic                      apb_sel_addr_x;
  logic                      apb_sel_addr_y;
  logic                      apb_sel_color;
  logic                      apb_sel_we;

  logic                      ctrl_we_ff;
  logic                      ctrl_we_en;
  logic                      ctrl_we_next;

  logic    [10:0]            addr_x_ff;
  logic                      addr_x_en;
  logic    [10:0]            addr_x_next;

  logic    [10:0]            addr_y_ff;
  logic                      addr_y_en;
  logic    [10:0]            addr_y_next;

  logic                      color_ff;
  logic                      color_en;
  logic                      color_next;

  logic                      apb_ready_ff;
  logic                      apb_ready_next;
  logic                      apb_ready_en;


  //////////////////////////
  // APB decoding         //
  //////////////////////////

  assign apb_write             = apb_psel_i & apb_pwrite_i;

  assign apb_sel_addr_x        = (apb_paddr_i == ADDR_X);
  assign apb_sel_addr_y        = (apb_paddr_i == ADDR_Y);
  assign apb_sel_color         = (apb_paddr_i == ADDR_COLOR);
  assign apb_sel_we            = (apb_paddr_i == ADDR_WE);

  //////////////////////////
  // Control register     //
  //////////////////////////


  // WE bit

  assign ctrl_we_en = (apb_write & apb_sel_we)
                     | ctrl_we_ff;

  assign ctrl_we_next = (apb_write & apb_sel_we) ? apb_pwdata_i[0]
                       :                             '0;

  always_ff @(posedge clk_i or negedge rstn_i)
  if (~rstn_i)
    ctrl_we_ff <= '0;
  else if (ctrl_we_en)
    ctrl_we_ff <= ctrl_we_next;

  //////////////////////////
  // ADDR registers    //
  //////////////////////////

  assign addr_x_en = apb_write & apb_sel_addr_x;

  assign addr_x_next = apb_pwdata_i[10:0];

  always_ff @(posedge clk_i or negedge rstn_i)
  if (~rstn_i)
    addr_x_ff <= '0;
  else if (addr_x_en)
    addr_x_ff <= addr_x_next;

  assign addr_y_en = apb_write & apb_sel_addr_y;

  assign addr_y_next = apb_pwdata_i[10:0];

  always_ff @(posedge clk_i or negedge rstn_i)
  if (~rstn_i)
    addr_y_ff <= '0;
  else if (addr_y_en)
    addr_y_ff <= addr_y_next;

  //////////////////////////
  // COLOR registers    //
  //////////////////////////

  assign color_en = apb_write & apb_sel_color;

  assign color_next = apb_pwdata_i[0];

  always_ff @(posedge clk_i or negedge rstn_i)
  if (~rstn_i)
    color_ff <= '0;
  else if (color_en)
    color_ff <= color_next;
    
  //////////////////////////
  // APB ready            //
  //////////////////////////

  assign apb_ready_next = ( apb_psel_i & apb_penable_i ) & ~apb_ready_ff;

  assign apb_ready_en = (apb_psel_i & apb_penable_i)
                      | apb_ready_ff;

  always_ff @(posedge clk_i or negedge rstn_i)
  if (~rstn_i)
    apb_ready_ff <= '0;
  else if (apb_ready_en)
    apb_ready_ff <= apb_ready_next;

  assign apb_pready_o  = apb_ready_ff;


  //////////////////////////
  // APB error            //
  //////////////////////////

  assign apb_pslverr_o = 1'b0;


  //////////////////////////
  // Vga instantiation //
  //////////////////////////

  // Instantiation
  vga_mem_wrapper vga_mem_wrapper(
    .clk_i( clk_i ), 
    .arstn_i( rstn_i ),
    
    .VGA_HS_o( vga_hs_o ), 
    .VGA_VS_o( vga_vs_o ),
    .color_i ( color_ff ),
    .addr_x_i( addr_x_ff ),
    .addr_y_i( addr_y_ff ),
    .we_i    ( ctrl_we_ff ) ,
    .RGB_o   ( rgb_o ),
    .LED_o   (  )
  );

endmodule
