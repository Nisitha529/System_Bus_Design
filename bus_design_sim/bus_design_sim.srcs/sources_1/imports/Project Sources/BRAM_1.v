
module BRAM_1 (clk, en, we, rst, addr, di, dout);
input clk;
input en;
input we;
input rst;
input [11:0] addr;
input [7:0] di;
output [7:0] dout;


reg [7:0] ram [4095:0];
reg [7:0] dout;

always @(posedge clk)
begin
if (en) //optional enable
begin
if (we) //write enable
ram[addr] <= di;
if (rst) //optional reset
dout <= 0;
else
dout <= ram[addr];
end
end

endmodule