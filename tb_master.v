`timescale 1ns/1ps
module tb_master ();
  localparam DATA_WIDTH    = 32;
  localparam H_ADDR_WIDTH  = 16;
  localparam U_ADDR_WIDTH  = 12;
  localparam RESP_COUNT    = 4;
  localparam SLAVE_COUNT   = 4;
  localparam PROGRM_DEPTH  = 4096;
  localparam CLK_CYCLE     = 10;

  reg                            clk;
  reg                            rst_n;

  reg                            h_grant;
  reg                            h_ready;
  reg [$clog2(RESP_COUNT)-1:0]   h_resp;
  reg [DATA_WIDTH-1:0]           h_rdata;
  reg                            h_rdata_valid;

  reg                            u_req;
  reg                            u_lock;
  reg                            u_write;
  reg [U_ADDR_WIDTH-1:0]         u_addr;
  reg [DATA_WIDTH-1:0]           u_wdata;
  reg [$clog2(SLAVE_COUNT)-1:0]  u_slave;

  reg                            h_req;
  reg                            h_lock;

  reg [H_ADDR_WIDTH-1:0]         h_addr;
  reg [DATA_WIDTH-1:0]           h_wdata;

  tb_master #
  (
    .DATA_WIDTH                  (DATA_WIDTH),
    .H_ADDR_WIDTH                (H_ADDR_WIDTH),
    .U_ADDR_WIDTH                (U_ADDR_WIDTH),
    .RESP_COUNT                  (RESP_COUNT),
    .SLAVE_COUNT                 (SLAVE_COUNT),
    .PROGRM_DEPTH                (PROGRM_DEPTH)
  )(
    .clk                         (clk),
    .rst_n                       (rst_n),

    .h_grant                     (h_grant),
    .h_ready                     (h_ready),
    .h_resp                      (h_resp),
    .h_rdata                     (h_rdata),
    .h_rdata_valid               (h_rdata_valid),

    .u_req                       (u_req),
    .u_lock                      (u_lock),
    .u_write                     (u_write),
    .u_addr                      (u_addr),
    .u_wdata                     (u_wdata),
    .u_slave                     (u_slave),

    .h_req                       (h_req),
    .h_lock                      (h_lock),

    .h_addr                      (h_addr),
    .h_wdata                     (h_wdata)
  );

  always begin
    #(CLK_CYCLE/2);
    clk = ~ clk;
  end

  initial begin
    clk           = 0;
    rst_n         = 1;
    
    h_grant       = 0;
    h_ready       = 1'bz;
    h_resp        = 2'd0;
    h_rdata       = 32'bx;
    h_rdata_valid = 0;

    u_req         = 0;
    u_lock        = 0;
    u_write       = 0;
    u_addr        = 16'bx;
    u_wdata       = 32'bx;
    u_slave       = 2'd0;
    #(CLK_CYCLE*8);

    rst_n         = 0;
    #(CLK_CYCLE*7);

    rst_n         = 1;
    #(CLK_CYCLE*5);

    // Normal Writing procedure

    u_req         = 1;
    u_lock        = 0;
    u_write       = 1;
    u_addr        = 16'd3;
    u_wdata       = $random;
    u_slave       = 2'd1;
    #(CLK_CYCLE*3);

    h_grant       = 1;
    h_resp        = 2'd0;
    #(CLK_CYCLE*2);

    h_ready       = 1;
    #(CLK_CYCLE*3);

    u_req         = 0;
    u_lock        = 0;
    u_write       = 0;

    h_grant       = 0;
    h_ready       = 0;
    #(CLK_CYCLE*5);

    // Normal Reading procedure
    
    u_req         = 1;
    u_lock        = 0;
    u_write       = 0;
    u_addr        = 16'd3;
    u_slave       = 2'd1;
    #(CLK_CYCLE*3);
 
    h_grant       = 1;
    h_resp        = 2'd0;
    #(CLK_CYCLE*2);

    h_ready       = 1;
    #(CLK_CYCLE*3);

    

  end

endmodule