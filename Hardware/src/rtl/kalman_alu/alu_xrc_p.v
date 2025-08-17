`timescale 1ps/1ps

// A*(B+C) 's ALU



module alu_xrc_p #(

    parameter DW_A = 24,

    parameter INT_A = 0,

    parameter DW_B = 24,

    parameter INT_B = 0,

    parameter DW_C = 24,

    parameter INT_C = 0,

    parameter DW_D = 5,

    parameter INT_D = 4,



    parameter DW_E = 24,

    parameter INT_E = 0

    

)

(

    clk,

    n_rst,
    bef_x_rc,
    //din_a,
    i_b,
    //din_b,
    a_4,
    //din_c,
    b_2,
    //dout
    x_rc_p

);

    parameter SIGN = 1;

    parameter D_WIDTH = 24;



    // 3 = vt, 7 = soc, 2 = theta4

    parameter FLT_A = DW_A - INT_A - SIGN;

    parameter FLT_B = DW_B - INT_B - SIGN;

    parameter FLT_C = DW_C - INT_C - SIGN;
    
    parameter FLT_D = DW_D - INT_D - SIGN;


    input clk, n_rst;

   // input [DW_A-1:0] din_a;
    input [DW_A-1:0] a_4;
   // input [DW_B-1:0] din_b;
    input [DW_B-1:0] bef_x_rc;
   // input [DW_E-1:0] din_c;
    input [DW_C-1:0] b_2;
   
    input [DW_D-1:0] i_b;
 

    output [D_WIDTH-1:0] x_rc_p;


    // 1 5 46  ==> 52bit
    wire [DW_A+DW_B-1+4:0]add_x_rc_p;
   
   // wire [DW_A+DW_B+1-1-1:0] mul_a_bc; //result

    wire [DW_A+DW_B-1-1:0] mul_x_rc_a4; //result
    //wire [DW_A+FLT_B+FLT_E-1-1:0] res_alu;
    
    wire [DW_C+DW_D-1-1:0] mul_b2_ib;  //b_2 * i_b

mul #(

    .D_WIDTH1(DW_A),

    .D_WIDTH2(DW_B)

) u_multiple1

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(bef_x_rc), // SIGN_INT_A__FLT_A

    .mul_b(a_4), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_x_rc_a4) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);

mul #(

    .D_WIDTH1(DW_C),

    .D_WIDTH2(DW_D)

) u_multiple2

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(b_2), // SIGN_INT_A__FLT_A

    .mul_b(i_b), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_b2_ib) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);

//DW_C = DW_A+DW_B -1

add #(

    .SIGN_BIT(SIGN),

    .INT_BIT(4),

    .FLT_BIT(FLT_A + FLT_B)

) u_adder_x_rc_p

(

    .din_a({mul_b2_ib,{23{1'b0}}}), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B

    .din_b({mul_x_rc_a4[DW_A+DW_B-1-1],{INT_D{mul_x_rc_a4[DW_A+DW_B-1-1]}},mul_x_rc_a4[DW_A+DW_B-1-2:DW_A+DW_B-1-2-(FLT_A+FLT_B-1)]}), //din_c 맞춰주는 설정

    .dout(add_x_rc_p) // SIGN_INT_B+1_FLT_B => DW_B+1

);



//assign x_rc_p = mul_a_bc[DW_A+DW_B+1-1-1:DW_A+DW_B+1-1-1-D_WIDTH+1];
assign x_rc_p = {add_x_rc_p[51],add_x_rc_p[45:23]};

// 1, 0, 23 




endmodule

// 1 0 23 1 3 21 b 기준 b에 무조건 정수있는애들이 들어와야됌 둘 다 1 0 23이면  ok

//(b+c) * a

/*
mul #(

    .D_WIDTH1(DW_A),

    .D_WIDTH2(DW_B+1)

) u_multiple1

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(din_a), // SIGN_INT_A__FLT_A

    .mul_b(add_bc), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_a_bc) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);
*/
