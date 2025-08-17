`timescale 1ps/1ps

module fnd_decoder (
    clk,
    n_rst,
    soc_int,
    fnd_out_10,
    fnd_out_1
);
    input clk, n_rst;
    input [7:0] soc_int;
    output reg [6:0] fnd_out_1;
    output reg [6:0] fnd_out_10;


always@(*)
		case(soc_int[7:4])
			4'h0 : fnd_out_10 = 7'b100_0000;
			4'h1 : fnd_out_10 = 7'b111_1001;
			4'h2 : fnd_out_10 = 7'b010_0100;
			4'h3 : fnd_out_10 = 7'b011_0000;
			4'h4 : fnd_out_10 = 7'b001_1001;
			4'h5 : fnd_out_10 = 7'b001_0010;
			4'h6 : fnd_out_10 = 7'b000_0011;
			4'h7 : fnd_out_10 = 7'b101_1000;
			4'h8 : fnd_out_10 = 7'b000_0000;
			4'h9 : fnd_out_10 = 7'b001_1000;
			4'ha : fnd_out_10 = 7'b000_1000;
			default : fnd_out_10 = 7'b100_0000; 
		endcase

always@(*)
		case(soc_int[3:0])
			4'h0 : fnd_out_1 = 7'b100_0000;
			4'h1 : fnd_out_1 = 7'b111_1001;
			4'h2 : fnd_out_1 = 7'b010_0100;
			4'h3 : fnd_out_1 = 7'b011_0000;
			4'h4 : fnd_out_1 = 7'b001_1001;
			4'h5 : fnd_out_1 = 7'b001_0010;
			4'h6 : fnd_out_1 = 7'b000_0011;
			4'h7 : fnd_out_1 = 7'b101_1000;
			4'h8 : fnd_out_1 = 7'b000_0000;
			4'h9 : fnd_out_1 = 7'b001_1000;
			default : fnd_out_1 = 7'b100_0000; 
		endcase
endmodule