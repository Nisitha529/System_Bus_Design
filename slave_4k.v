`timescale 1ns/1ps

module#(
  parameter DATA_WIDTH   = 32,
  parameter H_ADDR_WIDTH = 16,
  parameter MEMORY_DEPTH = 4096,  // Since 4k slave
  parameter RESP_COUNT   = 4
)slave_4k(
  input                                clk,
  input                                rst_n,

  input      [H_ADDR_WIDTH-1:0]        h_addr,
  input      [DATA_WIDTH-1:0]          h_wdata,
  input                                sel,
  input                                h_lock,

  output reg [DATA_WIDTH-1:0]          h_rdata,
  output reg [$clog2(RESP_COUNT)-1:0]  h_resp,
  output reg                           h_ready
);

  localparam MSB_ADDR       = $clog2(MEMORY_DEPTH) - 1; // MSB for 4k address
  
  // Transfer type definitions
  localparam TRANSFER_IDLE  = 1'b0;
  localparam TRANSFER_START = 1'b1;

  // Response type definitions
  localparam RESPONSE_OKAY  = 2'd0;
  localparam RESPONSE_ERROR = 2'd1;
  localparam RESPONSE_RETRY = 2'd2;

  // State of Slave_FSM
  localparam ST_IDLE        = 2'd0;
  localparam ST_ACTIVE      = 2'd1;
  localparam ST_WRITE       = 2'd2;
  localparam ST_READ        = 2'd3;

  reg [1:0]                      state;
  reg [1:0]                      state_next;
  reg [$clog2(MEMORY_DEPTH)-1:0] s_addr;
  reg                            h_write;
  reg                            transfer_state;

  reg [DATA_WDITH-1:0] s_reg [MEMORY_DEPTH-1:0];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state   <= ST_IDLE;
    end else begin
      state   <= state_next;
    end
  end

  always @(*) begin
    if (!rst_n) begin
      state_next   = ST_IDLE;
    end else begin
      case (state)
        ST_IDLE : begin
          if (sel) begin
            state_next = ST_ACTIVE;
          end else begin
            state_next = ST_IDLE;
          end
        end // End of ST_IDLE

        ST_ACTIVE : begin
          if (h_addr[H_ADDR_WIDTH-1]) begin
            if (h_addr[H_ADDR_WIDTH-4]) begin
              state_next = ST_WRITE;
            end else begin
              state_next = ST_READ;
            end
          end else begin
            if (sel) begin
              state_next = ST_ACTIVE;
            end else begin
              state_next = ST_IDLE;
            end
          end
        end // End of ST_ACTIVE

        ST_WRITE : begin
          if (h_addr[H_ADDR_WIDTH-1]) begin
            if (h_wdata == s_reg[s_addr]) begin
              state_next = ST_ACTIVE;
            end else if (h_wdata != s_reg[s_addr] && h_lock == 1) begin
              state_next = ST_WRITE;
            end else begin
              state_next = ST_ACTIVE;
            end
          end else begin
            state_next   = ST_ACTIVE;
          end
        end // End of ST_WRITE

        ST_READ : begin
          if (h_addr[H_ADDR_WIDTH-1]) begin
            if (h_rdata == s_reg[s_addr]) begin
              state_next = ST_ACTIVE;
            end else if (h_rdata != s_reg[s_addr] && h_lock == 1) begin
              state_next = ST_READ;
            end else begin
              state_next = ST_ACTIVE;
            end
          end else begin
            state_next   = ST_ACTIVE;
          end
        end // End of ST_READ

      endcase
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      h_rdata        <= 32'b0;
      h_resp         <= RESPONSE_OKAY;
      h_ready        <= 1'b0;
      s_addr         <= 12'b0;
      h_write        <= 1'b0;
      transfer_state <= 1'b0;
    end else begin
      case (state)
        ST_IDLE: begin
          h_resp  <= RESPONSE_OKAY;
          h_ready <= 1'b0;
        end

        ST_ACTIVE: begin
          h_resp         <= RESPONSE_OKAY;
          h_ready        <= 1'b1;
          s_addr         <= h_addr[MSB_ADDR:0];
          h_write        <= h_addr[H_ADDR_WIDTH-4];
          transfer_state <= h_addr[H_ADDR_WIDTH-1];
          if (h_addr[H_ADDR_WIDTH-1]) begin
            h_ready      <= 1'b1;
            h_resp       <= RESPONSE_OKAY;
          end else begin
            h_resp       <= RESPONSE_ERROR;
          end
        end

        ST_WRITE: begin
          s_addr          <= h_addr[MSB_ADDR:0];
          h_write         <= h_addr[H_ADDR_WIDTH-4];
          transfer_state  <= h_addr[H_ADDR_WIDTH-1];
          if (h_addr[H_ADDR_WIDTH-1] == TRANSFER_START) begin
            s_reg[s_addr] <= h_wdata;
            if (h_wdata == s_reg[s_addr]) begin
              h_resp      <= RESPONSE_OKAY;
              h_ready     <= 1'b1;
            end else if (h_wdata !== s_reg[s_addr] && h_lock == 1) begin
              h_resp      <= RESPONSE_RETRY;
              h_ready     <= 1'b0;
            end else begin
              h_resp      <= RESPONSE_ERROR;
              h_ready     <= 1'b0;
            end
          end else begin
            h_resp        <= RESPONSE_RETRY;
          end
        end

        ST_READ: begin
          s_addr          <= h_addr[MSB_ADDR:0];
          h_write         <= h_addr[H_ADDR_WIDTH-4];
          transfer_state  <= h_addr[H_ADDR_WIDTH-1];

          if (transfer_state == TRANSFER_START) begin
            h_rdata       <= s_reg[s_addr];
            if (h_rdata == s_reg[s_addr]) begin
              h_resp      <= RESPONSE_OKAY;
              h_ready     <= 1'b1;
            end else if (h_rdata != s_reg[s_addr] && h_lock == 1) begin
              h_resp      <= RESPONSE_RETRY;
              h_ready     <= 1'b0;
            end else begin
              h_resp      <= RESPONSE_ERROR;
              h_ready     <= 1'b0;
            end
          end else begin
            h_resp        <= RESPONSE_RETRY;
          end

        end

      endcase
    end
  end

endmodule