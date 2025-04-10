module Bus_Arbiter(

input sys_clk, //Both m1 and m2 clocks are equal
input sys_rst,
input m1_request, //marks the master_request_available of the transmission
input m2_request,
input m1_slave_sel,
input m2_slave_sel,
input trans_done,
input s1_slave_split_en,
input s2_slave_split_en,
input s3_slave_split_en,

output reg m1_grant,
output reg m2_grant,
output reg arbiter_busy,
output reg bus_busy,

output reg[1:0] bus_grant, //to mux
output reg[1:0] slave_sel //to mux
);

parameter[2:0] IDEAL_STATE = 3'd0;
parameter[2:0] MASTER1_REQUESTING_STATE = 3'd1;
parameter[2:0] MASTER2_REQUESTING_STATE  = 3'd2;
parameter[2:0] BUS_BUSY_STATE = 3'd3;
parameter[2:0] SPLIT_AVAILABLE_STATE = 3'd4;
parameter[2:0] SPLIT_M1_GRANT_STATE = 3'd5;
parameter[2:0] SPLIT_M2_GRANT_STATE = 3'd6;
parameter[2:0] SPLIT_BUSY_STATE = 3'd7;

wire slave_split_available = s1_slave_split_en || s2_slave_split_en || s3_slave_split_en ; // No two slaves will issue a split at once
reg split_enabled;

reg [2:0] arbiter_state = 0; //added later
reg [1:0] master1_slave;
reg [1:0] master2_slave;
reg [1:0] clk_count;
reg slave_sel_done;

reg previous_m1_grant;
reg previous_m2_grant;
reg [1:0]previous_grant;
reg [1:0]previous_slave_sel;

reg [1:0] slave_addr_state = 0;
wire master_request_available = m1_request || m2_request;


/////////////////////////////////////////////////
parameter 
IDEAL = 0, 
ADR_STATE1 = 1, 
ADR_STATE2 = 2; 
/////////////////////////////////////////////////
always @(posedge sys_clk or posedge sys_rst) 
begin
    if (sys_rst == 1'b1)
    begin
        master1_slave <= 2'b0;
        master2_slave <= 2'b0;
		  slave_sel_done <= 1'b0;
		  slave_addr_state <= IDEAL;
        
    end
	else
    begin
		case (slave_addr_state)
			IDEAL:begin
				if (master_request_available == 1 & arbiter_busy == 0 & bus_busy == 0)
				begin
					slave_addr_state <= ADR_STATE1;
                master1_slave[0] <= m1_slave_sel;
                master2_slave[0] <= m2_slave_sel;
               slave_sel_done <= 1'b0;
				end
				else
					slave_addr_state <= IDEAL;
               slave_sel_done <= 1'b0;
            end    
	   ADR_STATE1:begin
		slave_addr_state <= ADR_STATE2;
                master1_slave[1] <= m1_slave_sel;
                master2_slave[1] <= m2_slave_sel;
            end
            ADR_STATE2: begin
		slave_addr_state <= IDEAL;
                slave_sel_done = 1'b1;
            end
            default: begin
                slave_addr_state <= IDEAL;
            end  
        endcase
    end
end   
///////////////////////////////////////////////

////state machine to grant permission to the masters based on priority
always @(posedge sys_clk or posedge sys_rst)
begin
if (sys_rst == 1'b1)
    begin
        arbiter_state <= IDEAL_STATE ;
        m1_grant = 0;
        m2_grant = 0; 
        bus_grant = 2'b0;
        slave_sel = 2'b0;
	    arbiter_busy = 0;
		bus_busy = 0;
        split_enabled = 0;
    end
else 
    begin
    case (arbiter_state)
    IDEAL_STATE :begin      
            if (m1_request == 1'b1) //priority
            begin
                arbiter_state <= MASTER1_REQUESTING_STATE ;	
				arbiter_busy = 1;
            end
            else if (m2_request == 1'b1 ) 
            begin
                arbiter_state <= MASTER2_REQUESTING_STATE ;
                arbiter_busy = 1;
            end
            else
            begin
                arbiter_state <= IDEAL_STATE ;
				arbiter_busy = 0;
				bus_busy = 0;
                split_enabled = 0;

            end
        end
    MASTER1_REQUESTING_STATE :begin
            if (slave_sel_done == 1'b1)        
            begin
                arbiter_state <= BUS_BUSY_STATE;
                bus_grant = 2'd1;
				m1_grant = 1;
				m2_grant = 0;
                slave_sel[0] = master1_slave[0];
                slave_sel[1] = master1_slave[1];
         	    arbiter_busy = 0;
				bus_busy = 1;
            end
            else
            begin
                arbiter_state <= MASTER1_REQUESTING_STATE ;
            end
        end
    MASTER2_REQUESTING_STATE :begin
            if (slave_sel_done == 1'b1)            
            begin
                arbiter_state <= BUS_BUSY_STATE;
                bus_grant = 2'd2;
                m2_grant = 1;
				m1_grant = 0;
                slave_sel[0] = master2_slave[0];
                slave_sel[1] = master2_slave[1];
         	    arbiter_busy = 0;
				bus_busy = 1;
            end
            else
            begin
                arbiter_state <= MASTER2_REQUESTING_STATE ;
            end
        end
		  
    BUS_BUSY_STATE :begin
            if (trans_done == 1'b1)            
            begin
                arbiter_state <= IDEAL_STATE;
				bus_busy = 0;
				m1_grant = 0;
                m2_grant = 0;
            end
			else if (slave_split_available == 1'b1)
			begin
                arbiter_state <= SPLIT_AVAILABLE_STATE;
                previous_m1_grant <= m1_grant;
                previous_m2_grant <= m2_grant;
				previous_grant <= bus_grant;
				previous_slave_sel <= slave_sel;
                split_enabled <= 1;
				bus_busy = 0;
                arbiter_busy = 0;
			end
			else
            begin
                arbiter_state <= BUS_BUSY_STATE ;
				bus_busy = 1;
            end
        end
    SPLIT_AVAILABLE_STATE :begin      
            if (m1_request == 1'b1 )
            begin
                arbiter_state <= SPLIT_M1_GRANT_STATE ;
                m1_grant = 0;
                m2_grant = 0; 
                bus_grant = 2'b0;
                slave_sel = 2'b0; 	
				arbiter_busy = 1;
            end
            else if (m2_request == 1'b1 ) 
            begin
                arbiter_state <= SPLIT_M2_GRANT_STATE ;
                m1_grant = 0;
                m2_grant = 0; 
                bus_grant = 2'b0;
                slave_sel = 2'b0; 
                arbiter_busy = 1;
            end
			else if (slave_split_available == 1'b0)
			begin
                arbiter_state <= BUS_BUSY_STATE;
                m1_grant <= previous_m1_grant;
                m2_grant <= previous_m2_grant;
				bus_grant <= previous_grant;
				slave_sel <= previous_slave_sel;
				bus_busy = 1;
                split_enabled <= 0;
			end
            else
            begin
                arbiter_state <= SPLIT_AVAILABLE_STATE ;
                m1_grant = 0;
                m2_grant = 0; 
                bus_grant = 2'b0;
                slave_sel = 2'b0;                
				arbiter_busy = 0;
				bus_busy = 0;
            end
        end
    SPLIT_M1_GRANT_STATE :begin
            if (slave_sel_done == 1'b1)        
            begin
                if (master1_slave != previous_slave_sel)
                begin
                    arbiter_state <= SPLIT_BUSY_STATE;
                    bus_grant = 2'd1;
					m1_grant = 1;
					m2_grant = 0;
                    slave_sel[0] = master1_slave[0];
                    slave_sel[1] = master1_slave[1];
         	        arbiter_busy = 0;
					bus_busy = 1;
                end
                else
                begin 
                    arbiter_state<=SPLIT_AVAILABLE_STATE;
                    arbiter_busy = 0;
                end
            end
            else
            begin
                arbiter_state <= SPLIT_M1_GRANT_STATE ;
                bus_busy = 0;
            end
        end 
    SPLIT_M2_GRANT_STATE :begin
            if (slave_sel_done == 1'b1)            
            begin
                if (master2_slave != previous_slave_sel)                
                begin
                    arbiter_state <= SPLIT_BUSY_STATE;
                    bus_grant = 2'd2;
                    m2_grant = 1;
				    m1_grant = 0;
                    slave_sel[0] = master2_slave[0];
                    slave_sel[1] = master2_slave[1];
         	        arbiter_busy = 0;
				    bus_busy = 1;
                end 
                else
                begin 
                    arbiter_state<=SPLIT_AVAILABLE_STATE;
                    arbiter_busy = 0;
                end
            end
            else
            begin
                arbiter_state <= SPLIT_M2_GRANT_STATE ;
                bus_busy = 0;
            end
        end  
    SPLIT_BUSY_STATE :begin
            if (trans_done == 1'b1)
			begin
                arbiter_state <= BUS_BUSY_STATE;
                m1_grant = previous_m1_grant;
                m2_grant = previous_m2_grant;
				bus_grant <= previous_grant;
				slave_sel <= previous_slave_sel;
				bus_busy = 1;
                split_enabled <= 0; 
			end
			else
            begin
                arbiter_state <= SPLIT_BUSY_STATE ;
				bus_busy = 1;
            end
        end      

        default : begin
            arbiter_state <= IDEAL_STATE ;
            m1_grant = 0;
            m2_grant = 0; 
            bus_grant = 2'b0;
            slave_sel = 2'b0;
			arbiter_busy = 0;
			bus_busy = 0;
        end
    endcase
    end
end


endmodule
