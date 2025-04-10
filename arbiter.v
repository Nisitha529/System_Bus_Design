module arbiter (
  input            clk,
  input            rst,

  input            h_req_1,
  input            h_req_2,
  input            h_lock_1,
  input            h_lock_2,

  input      [1:0] h_split,
  input      [1:0] h_resp,
  input            h_ready,

  output reg       h_grant_1,
  output reg       h_grant_2,
  output reg [1:0] h_mas,
  output reg       h_lock,
  output reg [1:0] sel
);

  localparam IDLE      = 2'b00;
  localparam GRANT_1   = 2'b01;
  localparam GRANT_2   = 2'b10;
  localparam SPLIT     = 2'b11;

  localparam NO_DEVICE = 2'b00;
  localparam DEVICE_1  = 2'b01;
  localparam DEVICE_2  = 2'b10;

  reg [1:0] state;
  reg       g1;
  reg       g2;
  reg [1:0] grant_save;

  always @(posedge clk) begin
    if (rst) begin
      h_grant_1  <= 0;
      h_grant_2  <= 0;
      h_mas      <= 0;
      h_lock     <= 0;
      sel        <= 2'd0;
      grant_save <= 2'd0;
      state      <= IDLE;
    end else begin
      case (state)
        IDLE: begin
          h_grant_1 <= 0;
          h_grant_2 <= 0;
          h_mas     <= 0;
          h_lock    <= 0;
          sel       <= NO_DEVICE;

          // The considered priority order is follows.
          // 1. Split request
          // 2. Locked request
          // 3. Normal request

          if (h_split == DEVICE_1) begin           // Slave 1 requesting for master 1 via a split request
            state   <= GRANT_1; 
          end else if (h_split == DEVICE_2) begin  // Slave 1 requesting for master 2 via a split request
            state   <= GRANT_2;
          end else if (h_req_1 == 1 && h_req_2 == 0) begin //
            state   <= GRANT_1;
          end else if (h_req_1 == 0 && h_req_2 == 1) begin
            state   <= GRANT_2;
          end else if (h_req_1 == 1 && h_req_2 == 1) begin
            if (h_split == DEVICE_1 || h_lock_1) begin
              state <= GRANT_1;
            end else if (h_split == DEVICE_2 || h_lock_2) begin
              state <= GRANT_2;
            end else begin
              if (grant_save == DEVICE_1) begin
                state <= GRANT_2;
              end else if (grant_save == DEVICE_2) begin
                state <= GRANT_1;
              end else begin
                state <= count;
              end
            end
          end

        end   
      endcase
    end
  end
    
endmodule