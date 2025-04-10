/* 
 file name : Bus_mux.v

 Description:
	The multiplexer to maintain communication between master and slave
	
 Maintainers : Sanjula Thiranjaya <sthiranjaya@gmail.com>
					Sachini Wickramasinghe <sswickramasinghe@gmail.com>
					Kavish Ranawella <kavishranawella@gmail.com>
					
 Revision : v1.0 
*/

module Bus_mux(

input [1:0] bus_grant, 
input [1:0] slave_sel,

input m1_clk, 
input m1_rst,
input m1_master_valid,
input m1_master_ready,
input m1_tx_address,
input m1_tx_data,
output m1_rx_data,
input m1_write_en,
input m1_read_en,
output m1_slave_valid,
output m1_slave_ready,
input m1_tx_burst_num,

input m2_clk, 
input m2_rst,
input m2_master_valid,
input m2_master_ready,
input m2_tx_address,
input m2_tx_data,
output m2_rx_data,
input m2_write_en,
input m2_read_en,
output m2_slave_valid,
output m2_slave_ready,
input m2_tx_burst_num,

output s1_clk, 
output s1_rst,
output s1_master_valid,
output s1_master_ready,
output s1_rx_address,
output s1_rx_data,
input s1_tx_data,
output s1_write_en,
output s1_read_en,
input s1_slave_valid,
input s1_slave_ready,
output s1_rx_burst_num,

output s2_clk, 
output s2_rst,
output s2_master_valid,
output s2_master_ready,
output s2_rx_address,
output s2_rx_data,
input s2_tx_data,
output s2_write_en,
output s2_read_en,
input s2_slave_valid,
input s2_slave_ready,
output s2_rx_burst_num,

output s3_clk, 
output s3_rst,
output s3_master_valid,
output s3_master_ready,
output s3_rx_address,
output s3_rx_data,
input s3_tx_data,
output s3_write_en,
output s3_read_en,
input s3_slave_valid,
input s3_slave_ready,
output s3_rx_burst_num

);


////////////////// M1 //////////////////////////
assign m1_rx_data     = ((bus_grant == 2'd1) & (slave_sel == 2'd1)) ? s1_tx_data:
                        ((bus_grant == 2'd1) & (slave_sel == 2'd2)) ? s2_tx_data:
                        ((bus_grant == 2'd1) & (slave_sel == 2'd3)) ? s3_tx_data: 1'b0;

assign m1_slave_ready = ((bus_grant == 2'd1) & (slave_sel == 2'd1)) ? s1_slave_ready:
                        ((bus_grant == 2'd1) & (slave_sel == 2'd2)) ? s2_slave_ready: 
                        ((bus_grant == 2'd1) & (slave_sel == 2'd3)) ? s3_slave_ready: 1'b0;
								
assign m1_slave_valid = ((bus_grant == 2'd1) & (slave_sel == 2'd1)) ? s1_slave_valid:
                        ((bus_grant == 2'd1) & (slave_sel == 2'd2)) ? s2_slave_valid: 
                        ((bus_grant == 2'd1) & (slave_sel == 2'd3)) ? s3_slave_valid: 1'b0;
								

////////////////// M2 /////////////////////////
assign m2_rx_data     = ((bus_grant == 2'd2) & (slave_sel == 2'd1)) ? s1_tx_data:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd2)) ? s2_tx_data: 
                        ((bus_grant == 2'd2) & (slave_sel == 2'd3)) ? s3_tx_data: 1'b0;

assign m2_slave_ready = ((bus_grant == 2'd2) & (slave_sel == 2'd1)) ? s1_slave_ready:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd2)) ? s2_slave_ready:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd3)) ? s3_slave_ready: 1'b0;
								
assign m2_slave_valid = ((bus_grant == 2'd2) & (slave_sel == 2'd1)) ? s1_slave_valid:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd2)) ? s2_slave_valid:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd3)) ? s3_slave_valid: 1'b0;


////////////////// S1 /////////////////////////
assign s1_clk         = ((bus_grant == 2'd1) & (slave_sel == 2'd1)) ? m1_clk:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd1)) ? m2_clk: 1'b0; 

assign s1_rst         = ((bus_grant == 2'd1) & (slave_sel == 2'd1)) ? m1_rst: 
                        ((bus_grant == 2'd2) & (slave_sel == 2'd1)) ? m2_rst: 1'b0;

assign s1_master_valid= ((bus_grant == 2'd1) & (slave_sel == 2'd1)) ? m1_master_valid:
						((bus_grant == 2'd2) & (slave_sel == 2'd1)) ? m2_master_valid: 1'b0;

assign s1_master_ready= ((bus_grant == 2'd1) & (slave_sel == 2'd1)) ? m1_master_ready:
						((bus_grant == 2'd2) & (slave_sel == 2'd1)) ? m2_master_ready: 1'b0;
								
assign s1_rx_address  = ((bus_grant == 2'd1) & (slave_sel == 2'd1)) ? m1_tx_address:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd1)) ? m2_tx_address: 1'b0;

assign s1_rx_data     = ((bus_grant == 2'd1) & (slave_sel == 2'd1)) ? m1_tx_data:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd1)) ? m2_tx_data: 1'b0;

assign s1_write_en    = ((bus_grant == 2'd1) & (slave_sel == 2'd1)) ? m1_write_en: 
                        ((bus_grant == 2'd2) & (slave_sel == 2'd1)) ? m2_write_en: 1'b0;

assign s1_read_en     = ((bus_grant == 2'd1) & (slave_sel == 2'd1)) ? m1_read_en:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd1)) ? m2_read_en: 1'b0;

assign s1_rx_burst_num = ((bus_grant == 2'd1) & (slave_sel == 2'd1)) ? m1_tx_burst_num:
                         ((bus_grant == 2'd2) & (slave_sel == 2'd1)) ? m2_tx_burst_num: 1'b0;


////////////////// S2 /////////////////////////
assign s2_clk         = ((bus_grant == 2'd1) & (slave_sel == 2'd2)) ? m1_clk:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd2)) ? m2_clk: 1'b0; 

assign s2_rst         = ((bus_grant == 2'd1) & (slave_sel == 2'd2)) ? m1_rst: 
                        ((bus_grant == 2'd2) & (slave_sel == 2'd2)) ? m2_rst: 1'b0;

assign s2_master_valid= ((bus_grant == 2'd1) & (slave_sel == 2'd2)) ? m1_master_valid:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd2)) ? m2_master_valid: 1'b0;

assign s2_master_ready= ((bus_grant == 2'd1) & (slave_sel == 2'd2)) ? m1_master_ready:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd2)) ? m2_master_ready: 1'b0;								
								
assign s2_rx_address  = ((bus_grant == 2'd1) & (slave_sel == 2'd2)) ? m1_tx_address:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd2)) ? m2_tx_address: 1'b0;

assign s2_rx_data     = ((bus_grant == 2'd1) & (slave_sel == 2'd2)) ? m1_tx_data:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd2)) ? m2_tx_data: 1'b0;

assign s2_write_en    = ((bus_grant == 2'd1) & (slave_sel == 2'd2)) ? m1_write_en: 
                        ((bus_grant == 2'd2) & (slave_sel == 2'd2)) ? m2_write_en: 1'b0;

assign s2_read_en     = ((bus_grant == 2'd1) & (slave_sel == 2'd2)) ? m1_read_en:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd2)) ? m2_read_en: 1'b0;

assign s2_rx_burst_num = ((bus_grant == 2'd1) & (slave_sel == 2'd2)) ? m1_tx_burst_num:
                         ((bus_grant == 2'd2) & (slave_sel == 2'd2)) ? m2_tx_burst_num: 1'b0;

////////////////// S3 /////////////////////////
assign s3_clk         = ((bus_grant == 2'd1) & (slave_sel == 2'd3)) ? m1_clk:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd3)) ? m2_clk: 1'b0; 

assign s3_rst         = ((bus_grant == 2'd1) & (slave_sel == 2'd3)) ? m1_rst: 
                        ((bus_grant == 2'd2) & (slave_sel == 2'd3)) ? m2_rst: 1'b0;

assign s3_master_valid= ((bus_grant == 2'd1) & (slave_sel == 2'd3)) ? m1_master_valid:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd3)) ? m2_master_valid: 1'b0;

assign s3_master_ready= ((bus_grant == 2'd1) & (slave_sel == 2'd3)) ? m1_master_ready:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd3)) ? m2_master_ready: 1'b0;								
								
assign s3_rx_address  = ((bus_grant == 2'd1) & (slave_sel == 2'd3)) ? m1_tx_address:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd3)) ? m2_tx_address: 1'b0;

assign s3_rx_data     = ((bus_grant == 2'd1) & (slave_sel == 2'd3)) ? m1_tx_data:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd3)) ? m2_tx_data: 1'b0;

assign s3_write_en    = ((bus_grant == 2'd1) & (slave_sel == 2'd3)) ? m1_write_en: 
                        ((bus_grant == 2'd2) & (slave_sel == 2'd3)) ? m2_write_en: 1'b0;

assign s3_read_en     = ((bus_grant == 2'd1) & (slave_sel == 2'd3)) ? m1_read_en:
                        ((bus_grant == 2'd2) & (slave_sel == 2'd3)) ? m2_read_en: 1'b0;

assign s3_rx_burst_num = ((bus_grant == 2'd1) & (slave_sel == 2'd3)) ? m1_tx_burst_num:
                         ((bus_grant == 2'd2) & (slave_sel == 2'd3)) ? m2_tx_burst_num: 1'b0;

endmodule