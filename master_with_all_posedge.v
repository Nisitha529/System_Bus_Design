`timescale 1ns/1ps
module #(
  parameter DATA_WDITH   = 32,
  parameter H_ADDR_WIDTH = 16,
  parameter U_ADDR_WIDTH = 12,
  parameter RESP_COUNT   = 4,
  parameter SLAVE_COUNT  = 4,
  parameter PROGRM_DEPTH = 4096
) master (
  input                                 clk,
  input                                 rst_n,

  input                                 h_grant,
  input                                 h_ready,      //Ready signal from the slaves
  input      [$clog2(RESP_COUNT)-1:0]   h_resp,       //  
  input      [DATA_WIdTH-1:0]           h_rdata,
  input                                 h_rdata_valid,//this was intrduced additionally in  TRANS_RD_HOLD state

  input                                 u_req,
  input                                 u_lock,
  input                                 u_write,     //Whether read or write
  input      [U_ADDR_WIDTH-1:0]         u_addr,
  input      [DATA_WDITH-1:0]           u_wdata,
  input      [$clog2(SLAVE_COUNT)-1:0]  u_slave,

  output reg                            h_req,
  output reg                            h_lock,

  output reg [H_ADDR_WIDTH-1:0]         h_addr,
  output reg [DATA_WDITH-1:0]           h_wdata
);

  // Transfer type definitions
  localparam TRANSFER_IDLE    = 1'd0;
  localparam TRANSFER_START   = 1'd1;

  // Response type definitions
  localparam RESPONSE_OKAY    = 2'd0;
  localparam RESPONSE_ERROR   = 2'd1;
  localparam RESPONSE_RETRY   = 2'd2;
  localparam RESPONSE_SPLIT   = 2'd3;

  // State of Master_FSM
  localparam ST_IDLE          = 3'd0;
  localparam ST_REQUEST       = 3'd1;
  localparam ST_TRANS_BEGIN   = 3'd2;
  localparam ST_TRANS_END     = 3'd3;
  localparam ST_TRANS_RD_HOLD = 3'd4;
  localparam ST_SPLIT         = 3'd5;
  
  localparam ADDR_INCREMENT   = 12'd4;

  reg [H_ADDR_WIDTH-1:0]         h_addr_r;
  reg [DATA_WDITH-1:0]           h_rdata_r;
  reg [$clog2(PROGRM_DEPTH)-1:0] program_counter;
  reg                            transfer_state;
  reg [2:0]                      state;
  reg                            h_write;
  
  always @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
      h_req     <= 1'b0;
      h_lock    <= 1'b0;
      h_addr    <= 16'bx;
      h_wdata   <= 32'bx;
      state     <= ST_IDLE;
      h_rdata_r <= 32'bx;

    end else begin   
      case (state)
        ST_IDLE: begin
          h_req          <= 1'b0;
          h_lock         <= 1'b0;
          transfer_state <= TRANSFER_IDLE;
          h_addr_r       <= 16'bx;
          h_addr_r[15]   <= transfer_state;
          h_addr         <= h_addr_r;
          h_write        <= u_write;
          state          <= (u_req == 1)? ST_REQUEST : ST_IDLE;
        end
        
        ST_REQUEST: begin
          h_wdata          <= 32'bx;           //if req is made then h_req signal can't set to 0 since state won't change from the st_req to st_idl.
          h_req            <= u_req;
          h_lock           <= u_lock;          //u_lock should kept high until the transmission is ended
          if (h_grant) begin
            h_addr_r[11:0] <= u_addr;
            h_req          <= 1'b1;
            h_lock         <= u_lock;
            state          <= ST_TRANS_BEGIN;
          end else begin
            state          <= ST_REQUEST;
          end
        end
  
        ST_TRANS_BEGIN: begin
          if (h_ready) begin                     //h_ready should be kept high as long as the slave wants to communicate (This is set by the slave)
            h_req            <= 1'b0;            //Since the access has been granted. No need to keep requesting
            transfer_state   <= TRANSFER_IDLE;
            h_addr_r[15]     <= transfer_state;
            h_addr_r[14:13]  <= u_slave;         //Target slave
            h_write          <= u_write;
            h_addr_r[12]     <= h_write;
            h_addr           <= h_addr_r;
            program_counter  <= h_addr[U_ADDR_WIDTH-1:0] + ADDR_INCREMENT;
            state            <= ST_TRANS_END;
          end
        end
        
        ST_TRANS_END: begin
          h_lock         <= u_lock;
          transfer_state <= TRANSFER_START;  
          h_addr_r[15]   <= transfer_state;
          h_addr         <= h_addr_r;
          if (h_ready) begin
            if (u_write) begin
              h_wdata    <= u_wdata;
              state      <= (h_lock == 1 || h_ready != 1) ? ST_TRANS_BEGIN : ST_IDLE; //state should go to the transfer begin if the h_lock is kept high or the h_ready was lowered by the slave for requesting aditional cycle
            end else begin     // slave is ready but the master hasn't got the data yet
              state      <= ST_TRANS_RD_HOLD;
            end
          end else if (h_resp == RESPONSE_SPLIT) begin //If split response came
            state        <= ST_SPLIT;
          end else begin
            state        <= ST_TRANS_END;  //If there is no issue, the data transfer still can be made
          end
        end
        
        ST_TRANS_RD_HOLD: begin
          if (h_resp == RESPONSE_SPLIT) begin
            state     <= ST_SPLIT;
          end else begin
            h_lock    <= u_lock;
            h_rdata_r <= (h_rdata_valid) ? h_rdata : 32'bz;
            state     <= (h_lock || h_rdata_valid == 0 || h_ready != 1) ? ST_TRANS_RD_HOLD : ST_IDLE;
          end
        end
        ST_SPLIT: begin
          if (h_grant) begin
            state     <= ST_TRANS_RD_HOLD;
          end
        end
      endcase

    end
  end
    
endmodule