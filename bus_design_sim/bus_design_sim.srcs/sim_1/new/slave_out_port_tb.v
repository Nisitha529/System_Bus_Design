`timescale 1ns/10ps

module slave_out_port_tb;

	reg clk;
	reg reset;
	reg master_ready;
	reg [11:0]datain;
	reg slave_valid;
	wire slave_ready;
	wire slave_tx_done;
	wire tx_data;

	
	slave_out_port UUT(
	.clk(clk),
	.reset(reset),
	.master_ready(master_ready),
	.datain(datain),
	.slave_valid(slave_valid),
	.slave_ready(slave_ready),
	.slave_tx_done(slave_tx_done),
	.tx_data(tx_data));


	initial begin
		clk = 0;
		reset = 0;
		master_ready = 0;
		datain = 8'b11001100;
		slave_valid = 1;
		
		#15
		master_ready = 1;
		#10 
		master_ready = 0;

		#300
		#15
		master_ready = 1;
		#10 
		master_ready = 0;
	end


	always
		#5 clk = !clk;

endmodule 