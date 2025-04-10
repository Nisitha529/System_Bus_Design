/* 
 file name : master_module.v

 Description:
	A 4k block RAM which acts as a slave
	
 Maintainers : Sanjula Thiranjaya <sthiranjaya@gmail.com>
					Sachini Wickramasinghe <sswickramasinghe@gmail.com>
					Kavish Ranawella <kavishranawella@gmail.com>
					
 Revision : v1.0 
*/

module master_module #(parameter SLAVE_LEN=2, parameter ADDR_LEN=12, parameter DATA_LEN=8, parameter BURST_LEN=12)(
	input clk, 
	input reset,
	output busy,
	output [6:0]display1_pin,
	output [6:0]display2_pin,
	
	input read,
	input write,
	input [DATA_LEN-1:0]data_load,
	input [ADDR_LEN:0]address_load,
	input [SLAVE_LEN-1:0]slave_select_load,
	input [ADDR_LEN:0]burst_num_load,
	
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
	
	
wire [1:0]instruction;
wire [SLAVE_LEN-1:0]slave_select;
wire [ADDR_LEN-1:0]address;
wire [DATA_LEN-1:0]data_out;
wire [BURST_LEN-1:0]burst_num;
wire [DATA_LEN-1:0]data_in;
wire rx_done;
wire tx_done;
wire new_rx;
	

master_port #(.SLAVE_LEN(SLAVE_LEN), .ADDR_LEN(ADDR_LEN), .DATA_LEN(DATA_LEN), .BURST_LEN(BURST_LEN)) MASTER_PORT(
	.clk(clk), 
	.reset(reset),
	
	.instruction(instruction),
	.slave_select(slave_select),
	.address(address),
	.data_out(data_out),
	.burst_num(burst_num),
	.data_in(data_in),
	.rx_done(rx_done),
	.tx_done(tx_done),
	.new_rx(new_rx),
	
	.arbitor_busy(arbitor_busy),
	.bus_busy(bus_busy),
	.approval_grant(approval_grant),
	.approval_request(approval_request),
	.tx_slave_select(tx_slave_select),
	.trans_done(trans_done),
	
	
	.rx_data(rx_data),
	.tx_address(tx_address),
	.tx_data(tx_data),
	.tx_burst_num(tx_burst_num),
	
	.slave_valid(slave_valid),
	.slave_ready(slave_ready),
	.master_valid(master_valid),
	.master_ready(master_ready),
	.write_en(write_en),
	.read_en(read_en));
	
button_event1 #(.SLAVE_LEN(SLAVE_LEN), .ADDR_LEN(ADDR_LEN), .DATA_LEN(DATA_LEN), .BURST_LEN(BURST_LEN)) BUTTON_EVENT1(
	.clk(clk), 
	.reset(reset),
	.busy(busy),
	.display1_pin(display1_pin),
	.display2_pin(display2_pin),
	
	.read(read),
	.write(write),
	.data_load(data_load),
	.address_load(address_load),
	.slave_select_load(slave_select_load),
	.burst_num_load(burst_num_load),
	
	.data_in(data_in),
	.rx_done(rx_done),
	.tx_done(tx_done),
	.trans_done(trans_done),
	.new_rx(new_rx),
	.instruction(instruction),
	.slave_select(slave_select),
	.address(address),
	.data_out(data_out),	
	.burst_num(burst_num));
	
	
endmodule 