module lcdlab3(
	input clock,
	input rst,
	input [7:0] Line11,
   input [7:0] Line12,
   input [7:0] Line13,
   input [7:0] Line14,
   input [7:0] Line15,
   input [7:0] Line16,
   input [7:0] Line17,
   input [7:0] Line18,
   input [7:0] Line19,
   input [7:0] Line110,
   input [7:0] Line111,
   input [7:0] Line112,
   input [7:0] Line113,
   input [7:0] Line114,
   input [7:0] Line115,
   input [7:0] Line116,

	input [7:0] Line21,
   input [7:0] Line22,
   input [7:0] Line23,
   input [7:0] Line24,
   input [7:0] Line25,
   input [7:0] Line26,
   input [7:0] Line27,
   input [7:0] Line28,
   input [7:0] Line29,
   input [7:0] Line210,
   input [7:0] Line211,
   input [7:0] Line212,
   input [7:0] Line213,
   input [7:0] Line214,
   input [7:0] Line215,
   input [7:0] Line216,
//	LCD Module 16X2
  output LCD_ON,	// LCD Power ON/OFF
  output LCD_BLON,	// LCD Back Light ON/OFF
  output LCD_RW,	// LCD Read/Write Select, 0 = Write, 1 = Read
  output LCD_EN,	// LCD Enable
  output LCD_RS,	// LCD Command/Data Select, 0 = Command, 1 = Data
  inout [7:0] LCD_DATA	// LCD Data bus 8 bits
);

reg [17:0] SW;
wire [6:0]	HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7;
wire [8:0] LEDG;
wire [17:0] LEDR;
wire [35:0] GPIO_0,GPIO_1;

//	All inout port turn to tri-state
assign	GPIO_0		=	36'hzzzzzzzzz;
assign	GPIO_1		=	36'hzzzzzzzzz;

wire [6:0] myclock;
wire RST;
wire CLOCK_50;
assign CLOCK_50 = clock; 
assign RST = rst;

// reset delay gives some time for peripherals to initialize
wire DLY_RST;
Reset_Delay r0(	.iCLK(CLOCK_50),.oRESET(DLY_RST) );

// Send switches to red leds 
assign LEDR = SW;

// turn LCD ON
assign	LCD_ON		=	1'b1;
assign	LCD_BLON	=	1'b1;

wire [3:0] hex1, hex0;
assign hex1 = SW[7:4];
assign hex0 = SW[3:0];


LCD_Display u1(
// Host Side
   .iCLK_50MHZ(CLOCK_50),
   .iRST_N(DLY_RST),
   .hex0(hex0),
   .hex1(hex1),
// LCD Side
   .DATA_BUS(LCD_DATA),
   .LCD_RW(LCD_RW),
   .LCD_E(LCD_EN),
   .LCD_RS(LCD_RS),

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
	.Line216(Line216)
);


// blank unused 7-segment digits
assign HEX0 = 7'b111_1111;
assign HEX1 = 7'b111_1111;
assign HEX2 = 7'b111_1111;
assign HEX3 = 7'b111_1111;
assign HEX4 = 7'b111_1111;
assign HEX5 = 7'b111_1111;
assign HEX6 = 7'b111_1111;
assign HEX7 = 7'b111_1111;

endmodule