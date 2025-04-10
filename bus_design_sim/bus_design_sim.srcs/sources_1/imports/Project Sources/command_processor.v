/* 
 file name : command_processor.v

 Description:
	A 4k block RAM which acts as a slave
	
 Maintainers : Sanjula Thiranjaya <sthiranjaya@gmail.com>
					Sachini Wickramasinghe <sswickramasinghe@gmail.com>
					Kavish Ranawella <kavishranawella@gmail.com>
					
 Revision : v1.0 
*/

module command_processor #(parameter SLAVE_LEN=2, parameter ADDR_LEN=12, parameter DATA_LEN=8, parameter BURST_LEN=12)(
	input clk, 
	input reset,
	input button1,
	input button2,
	input button3,
	input [ADDR_LEN-1:0]switch_array,
	input mode_switch,
	input rw_switch1,
	input rw_switch2,
	output [6:0]display1_pin,
	output [6:0]display2_pin,
	output [6:0]display3_pin,
	output [6:0]display4_pin,
	output [3:0]display_val4, //for the LCD display

	output read1,
	output write1,
	output reg [DATA_LEN-1:0]data1 = 0,
	output reg [ADDR_LEN:0]address1 = 0,
	output reg [SLAVE_LEN-1:0]slave1 = 1,
	output reg [BURST_LEN:0]burst_num1 = 0,
	output read2,
	output write2,
	output reg [DATA_LEN-1:0]data2 = 0,
	output reg [ADDR_LEN:0]address2 = 0,
	output reg [SLAVE_LEN-1:0]slave2 = 1,
	output reg [BURST_LEN:0]burst_num2 = 0);
	
reg [2:0]config_state = 0;
reg [1:0]master = 1;
reg [DATA_LEN-1:0]data = 0;
reg [ADDR_LEN:0]address = 0;
reg [SLAVE_LEN-1:0]slave = 1;
reg [BURST_LEN:0]burst_num = 1;

reg button1_old = 0;
reg button2_old = 0;
reg button3_old = 0;
wire button1_edge;
wire button2_edge;
wire button3_edge;
assign button1_edge = (button1_old == 0 && button1 == 1) ? 1 : 0;
assign button2_edge = (button2_old == 0 && button2 == 1) ? 1 : 0;
assign button3_edge = (button3_old == 0 && button3 == 1) ? 1 : 0;

always @(posedge clk)
begin
	button1_old <= button1;
	button2_old <= button2;
	button3_old <= button3;
end

parameter SLAVE_NUM = 3;
parameter BURST_MAX = 12'hFFF;


parameter IDLE_CONFIG=0, SELECT_MASTER=1, SELECT_SLAVE=2, SELECT_ADDRESS=3, SELECT_DATA=4,
				SELECT_BURST=5, FINISH=6;
				
wire [3:0]display_val1;
wire [3:0]display_val2;
wire [3:0]display_val3;
//wire [3:0]display_val4;

assign display_val1 = (mode_switch == 0)?(
							(config_state==1)?{2'b00,master}:
							(config_state==2)?{2'b00,slave}:
							(config_state==3)?switch_array[3:0]:
							(config_state==4)?switch_array[3:0]:
							(config_state==5)?switch_array[3:0]:0):0;
							
assign display_val2 = (mode_switch == 0)?(
							(config_state==3)?switch_array[7:4]:
							(config_state==4)?switch_array[7:4]:
							(config_state==5)?switch_array[7:4]:0):0;
							
assign display_val3 = (mode_switch == 0)?(
							(config_state==3)?switch_array[11:8]:
							(config_state==5)?switch_array[11:8]:0):0;
							
assign display_val4 = (mode_switch == 0)?{1'b0,config_state}:0;
				
				
assign read1 = (mode_switch==1 && rw_switch1==1) ? button1 : 0;
assign write1 = (mode_switch==1 && rw_switch1==0) ? button1 : 0;

assign read2 = (mode_switch==1 && rw_switch2==1) ? button2 : 0;
assign write2 = (mode_switch==1 && rw_switch2==0) ? button2 : 0;

bin27 DISPLAY1 (.clock(clk), .reset(reset), .io_bin(display_val1), .io_seven(display1_pin));
bin27 DISPLAY2 (.clock(clk), .reset(reset), .io_bin(display_val2), .io_seven(display2_pin));
bin27 DISPLAY3 (.clock(clk), .reset(reset), .io_bin(display_val3), .io_seven(display3_pin));
bin27 DISPLAY4 (.clock(clk), .reset(reset), .io_bin(display_val4), .io_seven(display4_pin));

always @ (posedge reset or posedge clk)//button1 or posedge button2 or posedge button3 or posedge mode_switch) 
begin
	if (reset)
	begin
		config_state <= IDLE_CONFIG;
		master <= 1;
		slave <= 1;
		address <= 0;
		data <= 0;
		burst_num <= 1;
		slave1 <= 1;
		address1 <= 0;
		data1 <= 0;
		burst_num1 <= 1;
		slave2 <= 1;
		address2 <= 0;
		data2 <= 0;
		burst_num2 <= 1;
	end	
	
	else
	begin
		if (mode_switch==1)
		begin
			config_state <= IDLE_CONFIG;
			master <= 1;
			slave <= 1;
			address <= 0;
			data <= 0;
			burst_num <= 1;
		end
		else
		begin
		
			case(config_state)	
			
			IDLE_CONFIG:
			begin
				if (button1_edge==1 || button2_edge==1 || button3_edge==1)
				begin
					config_state <= SELECT_MASTER;
				end
				else
				begin
					config_state <= IDLE_CONFIG;
				end
				master <= 1;
				slave <= 1;
				address <= 0;
				data <= 0;
				burst_num <= 1;
				slave1 <= slave1;
				address1 <= address1;
				data1 <= data1;
				burst_num1 <= burst_num1;
				slave2 <= slave2;
				address2 <= address2;
				data2 <= data2;
				burst_num2 <= burst_num2;
			end
			
			SELECT_MASTER:
			begin
				if (button3_edge==1)
				begin
					config_state <= SELECT_SLAVE;
					master<=master;
				end
				else
				begin
					config_state <= SELECT_MASTER;
					if (button1_edge==1)
					begin
						if (master==1)
							master <= 2;
						else
							master <= 1;
					end
					else if (button2_edge==1)
					begin
						if (master==1)
							master <= 2;
						else
							master <= 1;
					end
					else
					begin
						master<=master;
					end
				end
				slave <= slave;
				address <= address;
				data <= data;
				burst_num <= burst_num;
				slave1 <= slave1;
				address1 <= address1;
				data1 <= data1;
				burst_num1 <= burst_num1;
				slave2 <= slave2;
				address2 <= address2;
				data2 <= data2;
				burst_num2 <= burst_num2;
			end
			
			SELECT_SLAVE:
			begin
				if (button3_edge==1)
				begin
					config_state <= SELECT_ADDRESS;
					slave<=slave;
				end
				else
				begin
					config_state <= SELECT_SLAVE;
					if (button1_edge==1)
					begin
						if (slave>=SLAVE_NUM)
							slave <= 0;
						else
							slave <= slave+1;
					end
					else if (button2_edge==1)
					begin
						if (slave==1)
							slave <= SLAVE_NUM;
						else
							slave <= slave-1;
					end
					else
					begin
						slave<=slave;
					end
				end
				master <= master;
				address <= address;
				data <= data;
				burst_num <= burst_num;
				slave1 <= slave1;
				address1 <= address1;
				data1 <= data1;
				burst_num1 <= burst_num1;
				slave2 <= slave2;
				address2 <= address2;
				data2 <= data2;
				burst_num2 <= burst_num2;
			end
			
			SELECT_ADDRESS:
			begin
				if (button1_edge==1 || button2_edge==1 || button3_edge==1)
				begin
					config_state <= SELECT_DATA;
					address <= switch_array;
				end
				else
				begin
					config_state <= SELECT_ADDRESS;
					address <= address;
				end
				master <= master;
				slave <= slave;
				data <= data;
				burst_num <= burst_num;
				slave1 <= slave1;
				address1 <= address1;
				data1 <= data1;
				burst_num1 <= burst_num1;
				slave2 <= slave2;
				address2 <= address2;
				data2 <= data2;
				burst_num2 <= burst_num2;
			end
			
			SELECT_DATA:
			begin
				if (button1_edge==1 || button2_edge==1 || button3_edge==1)
				begin
					config_state <= SELECT_BURST;
					data <= switch_array[7:0];
				end
				else
				begin
					config_state <= SELECT_DATA;
					data <= data;
				end
				master <= master;
				slave <= slave;
				address <= address;
				burst_num <= burst_num;
				slave1 <= slave1;
				address1 <= address1;
				data1 <= data1;
				burst_num1 <= burst_num1;
				slave2 <= slave2;
				address2 <= address2;
				data2 <= data2;
				burst_num2 <= burst_num2;
			end
				
			SELECT_BURST:
			begin
				if (button1_edge==1 || button2_edge==1 || button3_edge==1)
				begin
					config_state <= FINISH;
					if (switch_array >= BURST_MAX)
						burst_num <= BURST_MAX;
					else
						burst_num <= switch_array;
				end
				else
				begin
					config_state <= SELECT_BURST;
					burst_num <= burst_num;
				end
				master <= master;
				slave <= slave;
				address <= address;
				data <= data;
				slave1 <= slave1;
				address1 <= address1;
				data1 <= data1;
				burst_num1 <= burst_num1;
				slave2 <= slave2;
				address2 <= address2;
				data2 <= data2;
				burst_num2 <= burst_num2;
			end
		
			FINISH:
			begin
				if (button1_edge==1 || button2_edge==1 || button3_edge==1)
				begin
					config_state <= IDLE_CONFIG;
					if (master==1)
					begin
						slave1 <= slave;
						address1 <= address;
						data1 <= data;
						burst_num1 <= burst_num;
						slave2 <= slave2;
						address2 <= address2;
						data2 <= data2;
						burst_num2 <= burst_num2;
					end
					else
					begin
						slave1 <= slave1;
						address1 <= address1;
						data1 <= data1;
						burst_num1 <= burst_num1;
						slave2 <= slave;
						address2 <= address;
						data2 <= data;
						burst_num2 <= burst_num;
					end
					master <= 1;
					slave <= 1;
					address <= 0;
					data <= 0;
					burst_num <= 1;
				end
				else
				begin
					config_state <= FINISH;
					master <= master;
					slave <= slave;
					address <= address;
					data <= data;
					burst_num <= burst_num;
					slave1 <= slave1;
					address1 <= address1;
					data1 <= data1;
					burst_num1 <= burst_num1;
					slave2 <= slave2;
					address2 <= address2;
					data2 <= data2;
					burst_num2 <= burst_num2;
				end
			end
		
			default:
			begin
				config_state <= IDLE_CONFIG;
				master <= 1;
				slave <= 1;
				address <= 0;
				data <= 0;
				burst_num <= 1;
				slave1 <= 1;
				address1 <= 0;
				data1 <= 0;
				burst_num1 <= 1;
				slave2 <= 1;
				address2 <= 0;
				data2 <= 0;
				burst_num2 <= 1;
			end
			endcase
		end
		
	end
end


endmodule