`timescale 1ps/1ps

module K_alu #(
	parameter DW_1 = 48,
	parameter INT_1 = 0,
	parameter DW_2 = 48,
	parameter INT_2 = 0,
	parameter DW_B = 24,
	parameter INT_B = 0
)
(
	clk,
	n_rst,
	start,
	k1_up,
	k2_up,
	k_bottom,
	k_1,
	k_2,
	div_done
);
//-----------------------------------------------------
//--------------------SET_PARAMETER--------------------
	parameter SIGN = 1;
	parameter D_WIDTH = 24;

	parameter FLT_1 = DW_1 - INT_1 - SIGN; //24 - 0 - 1 = 23
	parameter FLT_2 = DW_2 - INT_2 - SIGN; //24 - 0 - 1 = 23
	parameter FLT_B = DW_B - INT_B - SIGN; //24 - 0 - 1 = 23
	
//-----------------------------------------------------
//----------------------SET_PORTS----------------------
	input				clk, n_rst, start;
	input [DW_1-1:0]	k1_up;		//1 0 23 ==> 24
	input [DW_2-1:0]	k2_up;		//1 0 23 ==> 24
	input [DW_B-1:0]	k_bottom;	//1 0 23 ==> 24
	
	output [D_WIDTH-1:0] k_1;		//1 3 20 ==> 24
	output [D_WIDTH-1:0] k_2;		//1 0 23 ==> 24
	output div_done;
	
//-----------------------------------------------------
//----------------------SET__PINS----------------------
	wire [47:0] t_k_bottom;		//1 0 23 ==> 24
	wire [47:0] t_k_1;			//1 0 23 ==> 24
	wire [47:0] t_k_2;			//1 0 23 ==> 24
//-----------------------------------------------------
//-----------------------MODULES-----------------------
//assign t_k_bottom = {24'b0,k_bottom[23],k_bottom[22:0]};
assign t_k_bottom = {k_bottom[23],{24{k_bottom[23]}},k_bottom[22:0]};
wire done_k1, done_k2;

div_d u_div_k_1(
    .clk(clk),
    .rst_n(n_rst),
    .M(t_k_bottom),
    .Q(k1_up),
    .start(start),
    .done(done_k1),
    .result_r(),
    .result_p(t_k_1)
);

div_d u_div_k_2(
    .clk(clk),
    .rst_n(n_rst),
    .M(t_k_bottom),
    .Q(k2_up),
    .start(start),
    .done(done_k2),
    .result_r(),
    .result_p(t_k_2)
);

/*
div u_div_k_1(
	.clk		(clk),
	.n_rst		(n_rst),
	.M			(t_k_bottom),
	.Q			(k1_up),
	.start		(start),
	.remain		(),
	.value		(t_k_1),
	.done		(done_k1)
);

div u_div_k_2(
	.clk		(clk),
	.n_rst		(n_rst),
	.M			(t_k_bottom),
	.Q			(k2_up),
	.start		(start),
	.remain		(),
	.value		(t_k_2),
	.done		(done_k2)
);
*/

wire [D_WIDTH-1:0] k_1_data;
assign k_1_data = {t_k_1[47],t_k_1[26:4]};
wire [D_WIDTH-1:0] k_2_data;
assign k_2_data = {t_k_2[47],t_k_2[23:1]};

assign k_1 = k_1_data;
//assign k_1 = (k1_up[47] ^ k_bottom[23]) ? {1'b1, ~t_k_1[23:1]} + 1'b1 : {1'b0, t_k_1[46:24]};
assign k_2 = k_2_data;
assign div_done = ((done_k1 == 1'b1) && (done_k2 == 1'b1)) ? 1'b1 : 1'b0;
endmodule
