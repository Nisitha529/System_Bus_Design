/* 
 file name : LCD_in.v

 Description:
	A 4k block RAM which acts as a slave
	
 Maintainers : Sanjula Thiranjaya <sthiranjaya@gmail.com>
					Sachini Wickramasinghe <sswickramasinghe@gmail.com>
					Kavish Ranawella <kavishranawella@gmail.com>
					
 Revision : v1.0 
*/
module LCD_in(
	input clock,
	input rst,
	input m1_start,
   input m2_start,
   input [12:0] address1,
   input [7:0] data1,
   input [12:0] address2,
   input [7:0] data2,
	input [3:0]config_state,
	input mode_switch,
   output LCD_ON,	// LCD Power ON/OFF
   output LCD_BLON,	// LCD Back Light ON/OFF
   output LCD_RW,	// LCD Read/Write Select, 0 = Write, 1 = Read
   output LCD_EN,	// LCD Enable
   output LCD_RS,	// LCD Command/Data Select, 0 = Command, 1 = Data
   inout [7:0] LCD_DATA	// LCD Data bus 8 bits
);

wire [3:0] LCD_state; 
reg config_done;
reg [15:0] Data_Line1;
reg [15:0] Data_Line2;

wire [7:0] Line11;
wire [7:0] Line12;
wire [7:0] Line13;
wire [7:0] Line14;
wire [7:0] Line15;
wire [7:0] Line16;
wire [7:0] Line17;
wire [7:0] Line18;
wire [7:0] Line19;
wire [7:0] Line110;
wire [7:0] Line111;
wire [7:0] Line112;
wire [7:0] Line113;
wire [7:0] Line114;
wire [7:0] Line115;
wire [7:0] Line116;

wire [7:0] Line21;
wire [7:0] Line22;
wire [7:0] Line23;
wire [7:0] Line24;
wire [7:0] Line25;
wire [7:0] Line26;
wire [7:0] Line27;
wire [7:0] Line28;
wire [7:0] Line29;
wire [7:0] Line210;
wire [7:0] Line211;
wire [7:0] Line212;
wire [7:0] Line213;
wire [7:0] Line214;
wire [7:0] Line215;
wire [7:0] Line216;



lcdlab3 LCD(
	.clock(clock),
	.rst(rst),
	.Line11(Line11),
	.Line12(Line12),
	.Line13(Line13),
	.Line14(Line14),
   .Line15(Line15),
	.Line16(Line16),
	.Line17(Line17),
	.Line18(Line18),
	.Line19(Line19),
	.Line110(Line110),
	.Line111(Line111),
	.Line112(Line112),
	.Line113(Line113),
	.Line114(Line114),
	.Line115(Line115),
	.Line116(Line116),
	
	.Line21(Line21),
	.Line22(Line22),
	.Line23(Line23),
	.Line24(Line24),
    .Line25(Line25),
	.Line26(Line26),
	.Line27(Line27),
	.Line28(Line28),
	.Line29(Line29),
	.Line210(Line210),
	.Line211(Line211),
	.Line212(Line212),
	.Line213(Line213),
	.Line214(Line214),
	.Line215(Line215),
	.Line216(Line216),	
   .LCD_ON(LCD_ON),	
   .LCD_BLON(LCD_BLON),	
   .LCD_RW(LCD_RW),	
   .LCD_EN(LCD_EN),	
   .LCD_RS(LCD_RS),	
   .LCD_DATA(LCD_DATA));

//always @ (posedge clock or posedge rst)
//begin
//	if (rst)	config_done <= 1'b0;
//end	
	
always @ (config_state)
begin
	if (~rst) config_done <= 1'b0;
	else if (mode_switch == 0 & config_state == 4'd6) config_done <= 1'b1;
	else if (mode_switch == 1) config_done <= 1'b0; 
end	
 
	
assign LCD_state =  (mode_switch == 0 & config_state == 4'd0 & config_done == 1'b0)? 4'd0: //Start Config //Press Any Key	
					(mode_switch == 0 & config_state == 4'd1)? 4'd1: //Select Master	 	
                    (mode_switch == 0 & config_state == 4'd2)? 4'd2: //Select Slave	
					(mode_switch == 0 & config_state == 4'd3)? 4'd3: //Input Address SW[0:11]	
					(mode_switch == 0 & config_state == 4'd4)? 4'd4: //Input Data    SW[0:7]	
					(mode_switch == 0 & config_state == 4'd5)? 4'd5: //Input Number of Bursts	
					(mode_switch == 0 & config_state == 4'd6)? 4'd6: //Save Configuration
					(mode_switch == 0 & config_state == 4'd0 & config_done == 1'b1)? 4'd8: //Config Done //Start New Config?
					(mode_switch == 1 )? 4'd7: 4'd0; 	

always @ (posedge m1_start or posedge m2_start)
begin
	if (m1_start == 1) 
	begin
		Data_Line1 <= address1;
		Data_Line2 <= data1;
	end
	else if (m2_start == 1) 
	begin
		Data_Line1 <= address2;
		Data_Line2 <= data2;
	end	
end						
		
//////////////////////////////Line 1//////////////////////////////////////////						 
assign Line11    = (LCD_state == 4'd0)? 8'h53: //S	
						 (LCD_state == 4'd1)? 8'h53://S	 	
                   (LCD_state == 4'd2)? 8'h53://S	
						 (LCD_state == 4'd3)? 8'h49://I	
						 (LCD_state == 4'd4)? 8'h49://I	
						 (LCD_state == 4'd5)? 8'h49://I	
						 (LCD_state == 4'd6)? 8'h53://S	
						 (LCD_state == 4'd8)? 8'h43://C	
						 (LCD_state == 4'd7)? 8'h41:8'h30 ; //A 
						 
assign Line12    = (LCD_state == 4'd0)? 8'h74://t	
						 (LCD_state == 4'd1)? 8'h65://e	 	
                   (LCD_state == 4'd2)? 8'h65:	//e
						 (LCD_state == 4'd3)? 8'h6E://n	
						 (LCD_state == 4'd4)? 8'h6E://n	
						 (LCD_state == 4'd5)? 8'h6E://n	
						 (LCD_state == 4'd6)? 8'h61://a
						 (LCD_state == 4'd8)? 8'h6F://o	
						 (LCD_state == 4'd7)? 8'h2D:8'h30 ; //- 
						 
assign Line13    = (LCD_state == 4'd0)? 8'h61://a	
						 (LCD_state == 4'd1)? 8'h6C://l	 	
                   (LCD_state == 4'd2)? 8'h6C://l	
						 (LCD_state == 4'd3)? 8'h70://p	
						 (LCD_state == 4'd4)? 8'h70://p	
						 (LCD_state == 4'd5)? 8'h70://p	
						 (LCD_state == 4'd6)? 8'h76://v
						 (LCD_state == 4'd8)? 8'h6E://n	
						 (LCD_state == 4'd7 & Data_Line1[13] == 1'b1 )? 8'h31 : 8'h30 ; 
						 
assign Line14    = (LCD_state == 4'd0)? 8'h72://r	
						 (LCD_state == 4'd1)? 8'h65://e	 	
                   (LCD_state == 4'd2)? 8'h65://e	
						 (LCD_state == 4'd3)? 8'h75://u	
						 (LCD_state == 4'd4)? 8'h75://u	
						 (LCD_state == 4'd5)? 8'h75://u	
						 (LCD_state == 4'd6)? 8'h65://e
						 (LCD_state == 4'd8)? 8'h66://f	
						 (LCD_state == 4'd7 & Data_Line1[12] == 1'b1 )? 8'h31 : 8'h30 ;
						 
assign Line15    = (LCD_state == 4'd0)? 8'h74://t	
						 (LCD_state == 4'd1)? 8'h63://c	 	
                   (LCD_state == 4'd2)? 8'h63://c	
						 (LCD_state == 4'd3)? 8'h74://t	
						 (LCD_state == 4'd4)? 8'h74://t	
						 (LCD_state == 4'd5)? 8'h74://t	
						 (LCD_state == 4'd6)? 8'h20://sp	
						 (LCD_state == 4'd8)? 8'h69://i
						 (LCD_state == 4'd7 & Data_Line1[11] == 1'b1 )? 8'h31 : 8'h30 ; 
						 
assign Line16    = (LCD_state == 4'd0)? 8'h20://sp	
						 (LCD_state == 4'd1)? 8'h74://t	 	
                   (LCD_state == 4'd2)? 8'h74://t	
						 (LCD_state == 4'd3)? 8'h20://sp	
						 (LCD_state == 4'd4)? 8'h20://sp	
						 (LCD_state == 4'd5)? 8'h20://sp	
						 (LCD_state == 4'd6)? 8'h43://C	
						 (LCD_state == 4'd8)? 8'h67://g
						 (LCD_state == 4'd7 & Data_Line1[10] == 1'b1 )? 8'h31 : 8'h30 ;
						 
assign Line17    = (LCD_state == 4'd0)? 8'h43://C	
						 (LCD_state == 4'd1)? 8'h20: //sp	 	
                   (LCD_state == 4'd2)? 8'h20: //sp	
						 (LCD_state == 4'd3)? 8'h41://A	
						 (LCD_state == 4'd4)? 8'h44://D	
						 (LCD_state == 4'd5)? 8'h4E://N	
						 (LCD_state == 4'd6)? 8'h6F://o	
						 (LCD_state == 4'd8)? 8'h20://Sp
						 (LCD_state == 4'd7 & Data_Line1[9] ==  1'b1 )? 8'h31 : 8'h30 ;
        
assign Line18    = (LCD_state == 4'd0)? 8'h6F://o	
						 (LCD_state == 4'd1)? 8'h4D: //M	 	
                   (LCD_state == 4'd2)? 8'h73://s	
						 (LCD_state == 4'd3)? 8'h64://d	
						 (LCD_state == 4'd4)? 8'h61://a
						 (LCD_state == 4'd5)? 8'h75://u	
						 (LCD_state == 4'd6)? 8'h6E://n	
						 (LCD_state == 4'd8)? 8'h64://d
						 (LCD_state == 4'd7 & Data_Line1[8] ==  1'b1 )? 8'h31 : 8'h30 ;    

assign Line19    = (LCD_state == 4'd0)? 8'h6E://n	
						 (LCD_state == 4'd1)? 8'h61: //a	 	
                   (LCD_state == 4'd2)? 8'h6C:	//l
						 (LCD_state == 4'd3)? 8'h64://d	
						 (LCD_state == 4'd4)? 8'h74://t	
						 (LCD_state == 4'd5)? 8'h6D://m	
						 (LCD_state == 4'd6)? 8'h66://f	
						 (LCD_state == 4'd8)? 8'h6F://o
						 (LCD_state == 4'd7 & Data_Line1[7] ==  1'b1 )? 8'h31 : 8'h30 ;        

assign Line110    =(LCD_state == 4'd0)? 8'h66://f	
						 (LCD_state == 4'd1)? 8'h73://s	 	
                   (LCD_state == 4'd2)? 8'h61://a	
						 (LCD_state == 4'd3)? 8'h72://r	
						 (LCD_state == 4'd4)? 8'h61://a	
						 (LCD_state == 4'd5)? 8'h62://b	
						 (LCD_state == 4'd6)? 8'h69://i	
						 (LCD_state == 4'd8)? 8'h6E://n
						 (LCD_state == 4'd7 & Data_Line1[6] ==  1'b1 )? 8'h31 : 8'h30 ;        

assign Line111    =(LCD_state == 4'd0)? 8'h69://i	
						 (LCD_state == 4'd1)? 8'h74: //t	 	
                   (LCD_state == 4'd2)? 8'h76://v	
						 (LCD_state == 4'd3)? 8'h65://e	
						 (LCD_state == 4'd4)? 8'h20://sp	
						 (LCD_state == 4'd5)? 8'h65://e	
						 (LCD_state == 4'd6)? 8'h67://g	
						 (LCD_state == 4'd8)? 8'h65://e
						 (LCD_state == 4'd7 & Data_Line1[5] ==  1'b1 )? 8'h31 : 8'h30 ;        

assign Line112    =(LCD_state == 4'd0)? 8'h67://g	
						 (LCD_state == 4'd1)? 8'h65://e 	
                   (LCD_state == 4'd2)? 8'h65://e	
						 (LCD_state == 4'd3)? 8'h73://s	
						 (LCD_state == 4'd4)? 8'h20://sp	
						 (LCD_state == 4'd5)? 8'h72://r	
						 (LCD_state == 4'd6)? 8'h20://sp
						 (LCD_state == 4'd8)? 8'h20://sp	
						 (LCD_state == 4'd7 & Data_Line1[4] ==  1'b1 )? 8'h31 : 8'h30 ;        

assign Line113    =(LCD_state == 4'd0)? 8'h20://sp	
						 (LCD_state == 4'd1)? 8'h72://r	 	
                   (LCD_state == 4'd2)? 8'h20://sp	
						 (LCD_state == 4'd3)? 8'h73://s	
						 (LCD_state == 4'd4)? 8'h20://sp	
						 (LCD_state == 4'd5)? 8'h20://sp
						 (LCD_state == 4'd6)? 8'h20://sp
						 (LCD_state == 4'd8)? 8'h20://sp	
						 (LCD_state == 4'd7 & Data_Line1[3] ==  1'b1 )? 8'h31 : 8'h30 ;        

assign Line114    =(LCD_state == 4'd0)? 8'h20://sp	
						 (LCD_state == 4'd1)? 8'h20://sp	 	
                   (LCD_state == 4'd2)? 8'h20://sp	
						 (LCD_state == 4'd3)? 8'h20://sp	
						 (LCD_state == 4'd4)? 8'h20://sp	
						 (LCD_state == 4'd5)? 8'h6F://o
						 (LCD_state == 4'd6)? 8'h20://sp
						 (LCD_state == 4'd8)? 8'h20://sp	
						 (LCD_state == 4'd7 & Data_Line1[2] ==  1'b1 )? 8'h31 : 8'h30 ;        

assign Line115    =(LCD_state == 4'd0)? 8'h20:	
						 (LCD_state == 4'd1)? 8'h20://sp	 	
                   (LCD_state == 4'd2)? 8'h20://sp	
						 (LCD_state == 4'd3)? 8'h20://sp	
						 (LCD_state == 4'd4)? 8'h20://sp	
						 (LCD_state == 4'd5)? 8'h66://f
						 (LCD_state == 4'd6)? 8'h20://sp
						 (LCD_state == 4'd8)? 8'h20://sp	
						 (LCD_state == 4'd7 & Data_Line1[1] ==  1'b1 )? 8'h31 : 8'h30 ;       

assign Line116    =(LCD_state == 4'd0)? 8'h20:	
						 (LCD_state == 4'd1)? 8'h20://sp	 	
                   (LCD_state == 4'd2)? 8'h20://sp	
						 (LCD_state == 4'd3)? 8'h20://sp	
						 (LCD_state == 4'd4)? 8'h20://sp	
						 (LCD_state == 4'd5)? 8'h20://sp	
						 (LCD_state == 4'd6)? 8'h20://sp
						 (LCD_state == 4'd8)? 8'h20://sp	
						 (LCD_state == 4'd7 & Data_Line1[0] ==  1'b1 )? 8'h31 : 8'h30 ; 

////////////////////////////////Line 2////////////////////////////////////////
assign Line21    = (LCD_state == 4'd0)? 8'h50: //P		
						 (LCD_state == 4'd1)? 8'h20://sp	 	
                   (LCD_state == 4'd2)? 8'h20://sp
						 (LCD_state == 4'd3)? 8'h53://S	
						 (LCD_state == 4'd4)? 8'h53://S	
						 (LCD_state == 4'd5)? 8'h42://B	
						 (LCD_state == 4'd6)? 8'h20://sp
						 (LCD_state == 4'd8)? 8'h53://S	
						 (LCD_state == 4'd7)? 8'h44:8'h30 ; //D 
						 
assign Line22    = (LCD_state == 4'd0)? 8'h72://r
						 (LCD_state == 4'd1)? 8'h20://sp	 	
                   (LCD_state == 4'd2)? 8'h20://sp	
						 (LCD_state == 4'd3)? 8'h57://W	
						 (LCD_state == 4'd4)? 8'h57://W	
						 (LCD_state == 4'd5)? 8'h75://u	
						 (LCD_state == 4'd6)? 8'h20://sp
						 (LCD_state == 4'd8)? 8'h74://t	
						 (LCD_state == 4'd7)? 8'h2D:8'h30 ; //- 
						 
assign Line23    = (LCD_state == 4'd0)? 8'h65://e	
						 (LCD_state == 4'd1)? 8'h20://sp	 	
                   (LCD_state == 4'd2)? 8'h20://sp	
						 (LCD_state == 4'd3)? 8'h5B://[	
						 (LCD_state == 4'd4)? 8'h5B://[	
						 (LCD_state == 4'd5)? 8'h72://r	
						 (LCD_state == 4'd6)? 8'h20://sp
						 (LCD_state == 4'd8)? 8'h61://a	
						 (LCD_state == 4'd7 & Data_Line2[13] == 1'b1 )? 8'h31 : 8'h30 ; 
						 
assign Line24    = (LCD_state == 4'd0)? 8'h73://s	
						 (LCD_state == 4'd1)? 8'h20://sp	 	
                   (LCD_state == 4'd2)? 8'h20://sp	
						 (LCD_state == 4'd3)? 8'h30://0
						 (LCD_state == 4'd4)? 8'h30://0	
						 (LCD_state == 4'd5)? 8'h73://s	
						 (LCD_state == 4'd6)? 8'h20://sp
						 (LCD_state == 4'd8)? 8'h72://r	
						 (LCD_state == 4'd7 & Data_Line2[12] == 1'b1 )? 8'h31 : 8'h30 ;
						 
assign Line25    = (LCD_state == 4'd0)? 8'h73://s
						 (LCD_state == 4'd1)? 8'h20://sp	 	
                   (LCD_state == 4'd2)? 8'h20://sp	
						 (LCD_state == 4'd3)? 8'h3A://:	
						 (LCD_state == 4'd4)? 8'h3A://:	
						 (LCD_state == 4'd5)? 8'h74://t	
						 (LCD_state == 4'd6)? 8'h20://sp
						 (LCD_state == 4'd8)? 8'h74://t	
						 (LCD_state == 4'd7 & Data_Line2[11] == 1'b1 )? 8'h31 : 8'h30 ; 
						 
assign Line26    = (LCD_state == 4'd0)? 8'h20:	
						 (LCD_state == 4'd1)? 8'h20:	 	
                   (LCD_state == 4'd2)? 8'h20:	
						 (LCD_state == 4'd3)? 8'h31://1	
						 (LCD_state == 4'd4)? 8'h37://7	
						 (LCD_state == 4'd5)? 8'h73://s	
						 (LCD_state == 4'd6)? 8'h20://sp
						 (LCD_state == 4'd8)? 8'h20://sp	
						 (LCD_state == 4'd7 & Data_Line2[10] == 1'b1 )? 8'h31 : 8'h30 ;
						 
assign Line27    = (LCD_state == 4'd0)? 8'h41://A	
						 (LCD_state == 4'd1)? 8'h20:	 	
                   (LCD_state == 4'd2)? 8'h20:	
						 (LCD_state == 4'd3)? 8'h31://1	
						 (LCD_state == 4'd4)? 8'h5D://]	
						 (LCD_state == 4'd5)? 8'h20://sp	
						 (LCD_state == 4'd6)? 8'h20://sp
						 (LCD_state == 4'd8)? 8'h4E://N	
						 (LCD_state == 4'd7 & Data_Line2[9] ==  1'b1 )? 8'h31 : 8'h30 ;
        
assign Line28    = (LCD_state == 4'd0)? 8'h6E://n		
						 (LCD_state == 4'd1)? 8'h20:	 	
                   (LCD_state == 4'd2)? 8'h20:	
						 (LCD_state == 4'd3)? 8'h5D://]
						 (LCD_state == 4'd4)? 8'h20://sp	
						 (LCD_state == 4'd5)? 8'h20://sp	
						 (LCD_state == 4'd6)? 8'h20://sp
						 (LCD_state == 4'd8)? 8'h65://e	
						 (LCD_state == 4'd7 & Data_Line2[8] ==  1'b1 )? 8'h31 : 8'h30 ;    

assign Line29    = (LCD_state == 4'd0)? 8'h79://y	
						 (LCD_state == 4'd1)? 8'h20:	 	
                   (LCD_state == 4'd2)? 8'h20:	
						 (LCD_state == 4'd3)? 8'h20://sp
						 (LCD_state == 4'd4)? 8'h20://sp	
						 (LCD_state == 4'd5)? 8'h20:	
						 (LCD_state == 4'd6)? 8'h20:
						 (LCD_state == 4'd8)? 8'h77://w	
						 (LCD_state == 4'd7 & Data_Line2[7] ==  1'b1 )? 8'h31 : 8'h30 ;        

assign Line210    =(LCD_state == 4'd0)? 8'h20:	
						 (LCD_state == 4'd1)? 8'h20:	 	
                   (LCD_state == 4'd2)? 8'h20:	
						 (LCD_state == 4'd3)? 8'h20:	
						 (LCD_state == 4'd4)? 8'h20:	
						 (LCD_state == 4'd5)? 8'h20:	
						 (LCD_state == 4'd6)? 8'h20:
						 (LCD_state == 4'd8)? 8'h20://sp	
						 (LCD_state == 4'd7 & Data_Line2[6] ==  1'b1 )? 8'h31 : 8'h30 ;        

assign Line211    =(LCD_state == 4'd0)? 8'h4B://K	
						 (LCD_state == 4'd1)? 8'h20:	 	
                   (LCD_state == 4'd2)? 8'h20:	
						 (LCD_state == 4'd3)? 8'h20:	
						 (LCD_state == 4'd4)? 8'h20:	
						 (LCD_state == 4'd5)? 8'h20:	
						 (LCD_state == 4'd6)? 8'h20:
						 (LCD_state == 4'd8)? 8'h43://C	
						 (LCD_state == 4'd7 & Data_Line2[5] ==  1'b1 )? 8'h31 : 8'h30 ;        

assign Line212    =(LCD_state == 4'd0)? 8'h65://e	
						 (LCD_state == 4'd1)? 8'h20:	 	
                   (LCD_state == 4'd2)? 8'h20:	
						 (LCD_state == 4'd3)? 8'h20:	
						 (LCD_state == 4'd4)? 8'h20:	
						 (LCD_state == 4'd5)? 8'h20:	
						 (LCD_state == 4'd6)? 8'h20:
						 (LCD_state == 4'd8)? 8'h6F://o	
						 (LCD_state == 4'd7 & Data_Line2[4] ==  1'b1 )? 8'h31 : 8'h30 ;        

assign Line213    =(LCD_state == 4'd0)? 8'h79://y
						 (LCD_state == 4'd1)? 8'h20:	 	
                   (LCD_state == 4'd2)? 8'h20:	
						 (LCD_state == 4'd3)? 8'h20:	
						 (LCD_state == 4'd4)? 8'h20:	
						 (LCD_state == 4'd5)? 8'h20:	
						 (LCD_state == 4'd6)? 8'h20:
						 (LCD_state == 4'd8)? 8'h6E://n	
						 (LCD_state == 4'd7 & Data_Line2[3] ==  1'b1 )? 8'h31 : 8'h30 ;        

assign Line214    =(LCD_state == 4'd0)? 8'h20:	
						 (LCD_state == 4'd1)? 8'h20:	 	
                   (LCD_state == 4'd2)? 8'h20:	
						 (LCD_state == 4'd3)? 8'h20:	
						 (LCD_state == 4'd4)? 8'h20:	
						 (LCD_state == 4'd5)? 8'h20:	
						 (LCD_state == 4'd6)? 8'h20:
						 (LCD_state == 4'd8)? 8'h66://f	
						 (LCD_state == 4'd7 & Data_Line2[2] ==  1'b1 )? 8'h31 : 8'h30 ;        

assign Line215    =(LCD_state == 4'd0)? 8'h20:	
						 (LCD_state == 4'd1)? 8'h20:	 	
                   (LCD_state == 4'd2)? 8'h20:	
						 (LCD_state == 4'd3)? 8'h20:	
						 (LCD_state == 4'd4)? 8'h20:	
						 (LCD_state == 4'd5)? 8'h20:	
						 (LCD_state == 4'd6)? 8'h20:
						 (LCD_state == 4'd8)? 8'h69://i	
						 (LCD_state == 4'd7 & Data_Line2[1] ==  1'b1 )? 8'h31 : 8'h30 ;       

assign Line216    =(LCD_state == 4'd0)? 8'h20:	
						 (LCD_state == 4'd1)? 8'h20:	 	
                   (LCD_state == 4'd2)? 8'h20:	
						 (LCD_state == 4'd3)? 8'h20:	
						 (LCD_state == 4'd4)? 8'h20:	
						 (LCD_state == 4'd5)? 8'h20:	
						 (LCD_state == 4'd6)? 8'h20:
						 (LCD_state == 4'd8)? 8'h67://g	
						 (LCD_state == 4'd7 & Data_Line2[0] ==  1'b1 )? 8'h31 : 8'h30 ; 
	
        	

////old testings
//reg [1:0] Data_Type1 = 2'd0; //00-address, 01-data, 10-Master, 11-Selected Slave  
//reg [1:0] Data_Type2 = 2'd1;			
//			
//assign Line11    = (Data_Type1 == 2'd0 )? 8'h41 : 
//						 (Data_Type1 == 2'd1 )? 8'h44 : 
//						 (Data_Type1 == 2'd2 )? 8'h4D : 
//						 (Data_Type1 == 2'd3 )? 8'h53 : 8'h30 ; 
//			
//assign Line21    = (Data_Type2 == 2'd0 )? 8'h41 : 
//						 (Data_Type2 == 2'd1 )? 8'h44 : 
//						 (Data_Type2 == 2'd2 )? 8'h4D : 
//						 (Data_Type2 == 2'd3 )? 8'h53 : 8'h30 ; 					
	
endmodule 