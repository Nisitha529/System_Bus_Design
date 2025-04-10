`timescale 1ns/10ps

module Bus_Arbiter_tb;

reg clk;
reg reset;
reg m1_req = 0;
reg m2_req = 0;
reg m1_slave = 0;
reg m2_slave = 0;
reg trans_done = 0;
reg s1_slave_split_en = 0;

wire m1_grant;
wire m2_grant;
wire arbiter_busy;
wire bus_busy;
wire [1:0] bus_grant; 
wire [1:0] slave_sel; 

Bus_Arbiter1 UUT(
.sys_clk(clk), 
.sys_rst(reset),
.m1_request (m1_req), 
.m2_request(m2_req),
.m1_slave_sel(m1_slave),
.m2_slave_sel(m2_slave),
.trans_done(trans_done),
.s1_slave_split_en(s1_slave_split_en),
.s2_slave_split_en(0),
.s3_slave_split_en(0),
.m1_grant(m1_grant),
.m2_grant(m2_grant),
.arbiter_busy(arbiter_busy),
.bus_busy(bus_busy),
.bus_grant(bus_grant), 
.slave_sel(slave_sel));

	initial begin
		clk = 0;
		reset = 0;
        #2 reset = 1;
        #3 reset = 0;

    #10
    m2_req =1;
    m2_slave = 1;
    #10 m2_req = 0;
    #10 m2_slave = 0;
    #20 
    trans_done = 1;
    #10;
    trans_done = 0;
    #50
    
    
    #10
    m1_req =1;
    m2_req =1;
    m1_slave = 0;
    m2_slave = 1;
    #10
    m1_req = 0;
    m2_req = 0;
    m1_slave = 1;
    #10 m2_slave = 0;
    m1_slave = 0;
    
    #20 
    trans_done = 1;
    #10;
    trans_done = 0;
    #50
    
    
	#10 m1_req = 1;
	m1_slave = 1;
	#10 m1_slave = 0;
	m1_req = 0; 

	#20 s1_slave_split_en = 1;
	#10 m2_req = 1;
	m2_slave = 1;
	#10 m2_slave = 0;
	m2_req = 0;
	#50 s1_slave_split_en = 0;	

   #20 trans_done = 1;
	#10 trans_done = 0;
	
#100

	#10 m1_req = 1;
	m1_slave = 1;
	#10 m1_slave = 0;
	m1_req = 0; 

	#20 s1_slave_split_en = 1;
	#10 m2_req = 1;
	m2_slave = 1;
	#20 m2_slave = 0;
	m2_req = 0;
	#50 s1_slave_split_en = 0;	

   #20 trans_done = 1;
	#10 trans_done = 0;
//	#20 trans_done = 1;
	//#10 trans_done = 0;
	
//	#10 m2_req = 1;
//	m2_slave = 1;
//	#10 m2_slave = 1;
//        #10 m2_req = 0;
//
//	#10 m1_req = 1;
//	m1_slave = 1;
//	#10 m1_slave = 0;
//        #10 m1_req = 0;  
//
//	#50 m1_req = 1;
//	m1_slave = 1;
//	#10 m1_slave = 0;
//        #10 m1_req = 0;
//
//	#50 m2_req = 1;
//	m1_req = 1;
//	m2_slave = 1;
//	#10 m2_slave = 1;
//        #10 m2_req = 0; 
//	m1_req = 0; 



	end

always
	#5 clk = !clk;

//always @(posedge clk)
	//begin
//	if (m1_req == 1)
//       m1_slave = 1; 
//	end


endmodule 