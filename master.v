`timescale 1ns/1ps
module #(
  parameter DATA_WIDTH   = 32,
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
  input      [DATA_WIDTH-1:0]           u_wdata,
  input      [$clog2(SLAVE_COUNT)-1:0]  u_slave,

  output reg                            h_req,
  output reg                            h_lock,

  output reg [H_ADDR_WIDTH-1:0]         h_addr,
  output reg [DATA_WIDTH-1:0]           h_wdata
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


  reg [DATA_WIDTH-1:0]           h_rdata_r;
  reg [2:0]                      state;
  reg [2:0]                      state_next;
  reg [H_ADDR_WIDTH-1:0]         h_addr_r;             //These are obsolete?
  reg [$clog2(PROGRM_DEPTH)-1:0] program_counter;
  reg                            h_write;                
  reg                            transfer_state;  

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state   <= ST_IDLE;
    end else begin
      state   <= state_next;
    end
  end

  always @(*) begin
    if (!rst_n) begin
      state_next = ST_IDLE;
    end else begin
      case (state)
        ST_IDLE : begin
          if (u_req) begin
            state_next = ST_REQUEST;
          end else begin
            state_next = ST_IDLE;
          end
        end // End of ST_IDLE

        ST_REQUEST : begin
          if (h_grant) begin
            state_next = ST_TRANS_BEGIN;
          end else begin
            state_next = ST_REQUEST;
          end
        end // End of ST_REQUEST

        ST_TRANS_BEGIN : begin
          if (h_ready) begin
            state_next = ST_TRANS_END;
          end else begin
            state_next = ST_TRANS_BEGIN;
          end
        end // End of ST_TRANS_BEGIN

       ST_TRANS_END : begin
         if (h_ready) begin
          if (u_write) begin
            //state should go to the transfer begin if the h_lock is kept high or the h_ready was lowered by the slave for requesting aditional cycle
            if (u_lock == 1 || h_ready != 1) begin
              state   = ST_TRANS_BEGIN; 
            end else begin
              state   = ST_IDLE;
            end
          end else begin
            //slave is ready but the master hasn't got the data yet
            state_next = ST_TRANS_RD_HOLD;
          end
         end else if (h_resp == RESPONSE_SPLIT) begin
           //If split response came
           state_next  = ST_SPLIT;
         end else if (h_resp == RESPONSE_RETRY || h_resp == RESPONSE_ERROR) begin
           state_next  = ST_REQUEST;
         end else begin
           //If there is no issue, the data transfer still can be made
           state_next  = ST_TRANS_END;
         end
       end // End of ST_TRANS_END

       ST_TRANS_RD_HOLD : begin
        if (h_resp == RESPONSE_SPLIT) begin
          state_next   = ST_SPLIT;
        end else if (h_lock || h_rdata_valid == 0 || h_ready != 1) begin
          state_next   = ST_TRANS_RD_HOLD;
        end else begin
          state_next   = ST_IDLE;
        end
       end // End of the ST_TRANS_RD_HOLD

       ST_SPLIT: begin
        if (h_grant) begin
          state_next  = ST_TRANS_RD_HOLD;
        end else begin
          state_next   = ST_SPLIT;
        end
       end // End of the ST_SPLIT

      endcase
    end
  end
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      {h_req, h_lock, h_addr, h_wdata, h_rdata_r} <= {1'b0, 1'b0, 16'bx, 32'bx, 32'bz};

    end else begin   
      case (state)
        ST_IDLE: begin
          {h_req, h_lock, h_addr[15], h_addr[14:0], h_write} <= {1'b0, 1'b0, TRANSFER_IDLE, 15'bx, u_write};
        end // End of ST_IDLE
        
        ST_REQUEST: begin
          //if req is made then h_req signal can't set to 0 since state won't change from the st_req to st_idl.
          //u_lock should kept high until the transmission is ended
          //h_req signal will be interchanged to be activated when the h_grant is low and go low when the h_grant is given      
          if (h_grant) begin
            {h_req, h_lock, h_wdata, h_addr[11:0]} <= {u_req, u_lock, 32'bx, u_addr};
          end //else begin
          //   {h_req, h_lock, h_wdata, h_addr[11:0], h_req} <= {u_req, u_lock, 32'bx, u_addr, 1'b1};
          // end
        end // End of ST_REQUEST
  
        ST_TRANS_BEGIN: begin
          if (h_ready) begin                     
            //h_ready should be kept high as long as the slave wants to communicate (This is set by the slave)
            //Since the access has been granted. No need to keep requesting. So h_req is driven low.
            //Target slave is assigned to h_addr[14:13]
            {h_req, h_addr[15], h_addr[14:13], h_addr[12], h_write} <= {1'b0, transfer_state, u_slave, u_write};
            program_counter                                         <= h_addr[U_ADDR_WIDTH-1:0] + ADDR_INCREMENT; //Hasn't been used. Kept for future use.
          end
        end // End of the ST_TRANS_BEGIN
        
        ST_TRANS_END: begin
          if (u_write) begin
            h_wdata <= u_wdata;
          end
          {h_lock, h_addr[15], h_addr} <= {u_lock, TRANSFER_START};
        end // End of the ST_TRANS_END
        
        ST_TRANS_RD_HOLD: begin
          if (h_resp != RESPONSE_SPLIT) begin
            h_lock    <= u_lock;
            if (h_rdata_valid) begin
              h_rdata_r <= h_rdata ;
            end else begin
              h_rdata_r <= 32'bz;
            end
          end
        end // End of the ST_TRANS_RD_HOLD

      endcase
    end
  end
    
endmodule