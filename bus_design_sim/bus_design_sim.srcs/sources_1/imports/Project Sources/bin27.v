module decoder(
  input  [3:0] io_bin,
  output [6:0] io_seven
);
  wire  _T = 4'h0 == io_bin; // @[Conditional.scala 37:30]
  wire  _T_1 = 4'h1 == io_bin; // @[Conditional.scala 37:30]
  wire  _T_2 = 4'h2 == io_bin; // @[Conditional.scala 37:30]
  wire  _T_3 = 4'h3 == io_bin; // @[Conditional.scala 37:30]
  wire  _T_4 = 4'h4 == io_bin; // @[Conditional.scala 37:30]
  wire  _T_5 = 4'h5 == io_bin; // @[Conditional.scala 37:30]
  wire  _T_6 = 4'h6 == io_bin; // @[Conditional.scala 37:30]
  wire  _T_7 = 4'h7 == io_bin; // @[Conditional.scala 37:30]
  wire  _T_8 = 4'h8 == io_bin; // @[Conditional.scala 37:30]
  wire  _T_9 = 4'h9 == io_bin; // @[Conditional.scala 37:30]
  wire  _T_10 = 4'ha == io_bin; // @[Conditional.scala 37:30]
  wire  _T_11 = 4'hb == io_bin; // @[Conditional.scala 37:30]
  wire  _T_12 = 4'hc == io_bin; // @[Conditional.scala 37:30]
  wire  _T_13 = 4'hd == io_bin; // @[Conditional.scala 37:30]
  wire  _T_14 = 4'he == io_bin; // @[Conditional.scala 37:30]
  wire  _T_15 = 4'hf == io_bin; // @[Conditional.scala 37:30]
  wire [7:0] _GEN_0 = _T_15 ? 8'h8e : 8'h0; // @[Conditional.scala 39:67 decoder.scala 29:21]
  wire [7:0] _GEN_1 = _T_14 ? 8'h86 : _GEN_0; // @[Conditional.scala 39:67 decoder.scala 28:21]
  wire [7:0] _GEN_2 = _T_13 ? 8'ha1 : _GEN_1; // @[Conditional.scala 39:67 decoder.scala 27:21]
  wire [7:0] _GEN_3 = _T_12 ? 8'hc6 : _GEN_2; // @[Conditional.scala 39:67 decoder.scala 26:21]
  wire [7:0] _GEN_4 = _T_11 ? 8'h83 : _GEN_3; // @[Conditional.scala 39:67 decoder.scala 25:21]
  wire [7:0] _GEN_5 = _T_10 ? 8'h88 : _GEN_4; // @[Conditional.scala 39:67 decoder.scala 24:21]
  wire [7:0] _GEN_6 = _T_9 ? 8'h90 : _GEN_5; // @[Conditional.scala 39:67 decoder.scala 23:20]
  wire [7:0] _GEN_7 = _T_8 ? 8'h80 : _GEN_6; // @[Conditional.scala 39:67 decoder.scala 22:20]
  wire [7:0] _GEN_8 = _T_7 ? 8'hf8 : _GEN_7; // @[Conditional.scala 39:67 decoder.scala 21:20]
  wire [7:0] _GEN_9 = _T_6 ? 8'h82 : _GEN_8; // @[Conditional.scala 39:67 decoder.scala 20:20]
  wire [7:0] _GEN_10 = _T_5 ? 8'h92 : _GEN_9; // @[Conditional.scala 39:67 decoder.scala 19:20]
  wire [7:0] _GEN_11 = _T_4 ? 8'h99 : _GEN_10; // @[Conditional.scala 39:67 decoder.scala 18:20]
  wire [7:0] _GEN_12 = _T_3 ? 8'hb0 : _GEN_11; // @[Conditional.scala 39:67 decoder.scala 17:20]
  wire [7:0] _GEN_13 = _T_2 ? 8'ha4 : _GEN_12; // @[Conditional.scala 39:67 decoder.scala 16:20]
  wire [7:0] _GEN_14 = _T_1 ? 8'hf9 : _GEN_13; // @[Conditional.scala 39:67 decoder.scala 15:20]
  wire [7:0] _GEN_15 = _T ? 8'hc0 : _GEN_14; // @[Conditional.scala 40:58 decoder.scala 14:20]
  assign io_seven = _GEN_15[6:0]; // @[decoder.scala 32:12]
endmodule
module bin27(
  input        clock,
  input        reset,
  input  [3:0] io_bin,
  output [6:0] io_seven
);
  wire [3:0] display_io_bin; // @[Hello.scala 9:23]
  wire [6:0] display_io_seven; // @[Hello.scala 9:23]
  decoder display ( // @[Hello.scala 9:23]
    .io_bin(display_io_bin),
    .io_seven(display_io_seven)
  );
  assign io_seven = display_io_seven; // @[Hello.scala 11:6]
  assign display_io_bin = io_bin; // @[Hello.scala 11:6]
endmodule
