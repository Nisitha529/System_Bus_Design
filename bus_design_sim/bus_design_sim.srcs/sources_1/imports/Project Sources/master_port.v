/* 
 file name : master_port.v

 Description:
	This file contains the master port 
	It encapsulated the input and output ports.
	Sets the control signals of the bus
	
 Maintainers : Sanjula Thiranjaya <sthiranjaya@gmail.com>
					Sachini Wickramasinghe <sswickramasinghe@gmail.com>
					Kavish Ranawella <kavishranawella@gmail.com>
					
 Revision : v1.0 
*/

module master_port #(parameter SLAVE_LEN=2, parameter ADDR_LEN=12, parameter DATA_LEN=8, parameter BURST_LEN=12)(

	input clk, 
	input reset,
	
	input [1:0]instruction,
	input [SLAVE_LEN-1:0]slave_select,
	input [ADDR_LEN-1:0]address,
	input [DATA_LEN-1:0]data_out,
	input [BURST_LEN-1:0]burst_num,
	output [DATA_LEN-1:0]data_in,
	output rx_done,
	output tx_done,
	output new_rx,
	
	input arbitor_busy,
	input bus_busy,
	input approval_grant,
	output approval_request,
	output tx_slave_select,
	output trans_done,
	
	input rx_data,
	output tx_address,
	output tx_data,
	output tx_burst_num,
	
	input slave_valid,
	input slave_ready,
	output master_valid,
	output master_ready,
	output write_en,
	output read_en);
	
	
wire master_ready_IN;
wire master_ready_OUT;

assign master_ready = master_ready_IN && master_ready_OUT;

//wire read_en_IN;
//wire read_en_OUT;

//assign read_en = read_en_IN || read_en_OUT;

assign trans_done = (instruction==2'b10) ? tx_done : ((instruction==2'b11) ? rx_done : tx_done);

master_in_port #(.DATA_LEN(DATA_LEN), .BURST_LEN(BURST_LEN)) MASTER_IN_PORT(
	.clk(clk), 
	.reset(reset),
	
	.tx_done(tx_done),
	.instruction(instruction),
	.burst_num(burst_num),
	.data(data_in),
	.rx_done(rx_done),
	.new_rx(new_rx),
	
	.rx_data(rx_data),
	.slave_valid(slave_valid),
	.master_ready(master_ready_IN));
	//.read_en(read_en_IN));

master_out_port #(.SLAVE_LEN(SLAVE_LEN), .ADDR_LEN(ADDR_LEN), .DATA_LEN(DATA_LEN), .BURST_LEN(BURST_LEN)) MASTER_OUT_PORT(
	.clk(clk), 
	.reset(reset),
	
	.slave_select(slave_select),
	.instruction(instruction), 
	.address(address),
	.data(data_out),
	.burst_num(burst_num),
	.rx_done(rx_done),
	.tx_done(tx_done),
	
	.slave_ready(slave_ready),
	.arbitor_busy(arbitor_busy),
	.bus_busy(bus_busy),	
	.approval_grant(approval_grant),
	.master_ready(master_ready_OUT),
	.approval_request(approval_request),
	.tx_slave_select(tx_slave_select),
	.master_valid(master_valid),
	.write_en(write_en),
	.read_en(read_en),	
	.tx_address(tx_address),
	.tx_data(tx_data),
	.tx_burst_num(tx_burst_num));
	
	
endmodule