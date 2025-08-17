`timescale 1ps/1ps
// A * B + C 's ALU

module alu_3 #(
    parameter DW_A = 24,
    parameter INT_A = 0,
    parameter DW_B = 24,
    parameter INT_B = 0,
    parameter DW_C = 24,
    parameter INT_C = 0
)
(
    clk,
    n_rst,
    din_a,
    din_b,
    din_c,
    dout
);
    parameter SIGN = 1;
    parameter D_WIDTH = 24;

    // 3 = vt, 7 = soc, 2 = theta4
    parameter FLT_A = DW_A - INT_A - SIGN;
    parameter FLT_B = DW_B - INT_B - SIGN;
    parameter FLT_C = DW_C - INT_C - SIGN;

    parameter EXT = INT_C - (INT_A + INT_B);

    input clk, n_rst;
    input [DW_A-1:0] din_a;
    input [DW_B-1:0] din_b;
    input [DW_C-1:0] din_c;

    output [DW_A+DW_B-1-1+EXT+1:0] dout;


    //wire [DW_A+DW_B-1-1+EXT+1:0] abb_ab_c; //result
    wire [DW_A+DW_B-1-1:0] mul_ab; //result
    //wire [DW_A+FLT_B+FLT_C-1-1:0] res_alu;

mul #(
    .D_WIDTH1(DW_A),
    .D_WIDTH2(DW_B)
) u_multiple1
(
    .clk(clk),
    .n_rst(n_rst),
    .mul_a(din_a), // SIGN_INT_A__FLT_A
    .mul_b(din_b), // SIGN_INT_B_FLT_B => DW_C+1
    .mul_out(mul_ab) // SIGN_INT_B+INT_C+1_FLT_B+FLT_C
);

wire [DW_A+DW_B-1-1:0] mul_ab_zero;

assign mul_ab_zero = (mul_ab[DW_A+DW_B-1-2:0] == {DW_A+DW_B-1-1{1'b0}}) ? {DW_A+DW_B-1{1'b0}} : mul_ab;

add #(
    .SIGN_BIT(SIGN),
    .INT_BIT(INT_C),
    .FLT_BIT(FLT_A+FLT_B)
) u_adder_c
(
    .din_a({din_c,{FLT_A+FLT_B-FLT_C{1'b0}}}), 
    .din_b(mul_ab_zero), 
    .dout(dout) 
);

/*
add #(
    .SIGN_BIT(SIGN),
    .INT_BIT(INT_C),
    .FLT_BIT(FLT_A+FLT_B)
) u_adder_c
(
    .din_a({din_c,{FLT_A+FLT_B-FLT_C{1'b0}}}), 
    .din_b({mul_ab[DW_C-1],{INT_B{mul_ab[DW_C-1]}},mul_ab[DW_C-2:DW_C-2-(FLT_B-1)]}), 
    .dout(abb_ab_c) 
);
*/

//assign dout = mul_a_bc[DW_A+DW_B+1-1-1:DW_A+DW_B+1-1-1-D_WIDTH+1];
endmodule