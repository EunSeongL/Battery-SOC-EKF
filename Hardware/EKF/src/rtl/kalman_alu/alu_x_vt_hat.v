`timescale 1ps/1ps

// A*(B+C) 's ALU

module alu_x_vt_hat #(

    parameter DW_A = 24,
    //theta4
    parameter INT_A = 0,

    parameter DW_B = 24,
    //x_soc
    parameter INT_B = 7,

    parameter DW_C = 24,
    //theta5
    parameter INT_C = 2,

    parameter DW_D = 24,
    //a_4 = 1-dt/rd*cd
    parameter INT_D = 0,

    parameter DW_E = 24,
    //x_rc
    parameter INT_E = 0,

    parameter DW_F = 24,
    //dt_cd_ri
    parameter INT_F = 0,
   
    parameter DW_G = 5,
    //i_b
    parameter INT_G = 4    

)

(

    clk,

    n_rst,
    theta4,
    //din_a,
    i_b,
    //din_b,
    x_soc,
    //din_c,
    theta5,
    //dout
    a_4,
    x_rc,
    dt_cd_ri,
    x_vt_hat
);

    parameter SIGN = 1;

    parameter D_WIDTH = 24;



    // 3 = vt, 7 = soc, 2 = theta4

    parameter FLT_A = DW_A - INT_A - SIGN;

    parameter FLT_B = DW_B - INT_B - SIGN;

    parameter FLT_C = DW_C - INT_C - SIGN;
    
    parameter FLT_D = DW_D - INT_D - SIGN;

    parameter FLT_E = DW_E - INT_E - SIGN;

    parameter FLT_F = DW_F - INT_F - SIGN;

    parameter FLT_G = DW_G - INT_G - SIGN;


    input clk, n_rst;

   // input [DW_A-1:0] din_a;
    input [DW_A-1:0] theta4;
   // input [DW_B-1:0] din_b;
    input [DW_B-1:0] x_soc;
   // input [DW_E-1:0] din_c;
    input [DW_C-1:0] theta5;
    
    input [DW_D-1:0] a_4;

    input [DW_E-1:0] x_rc;
 
    input [DW_F-1:0] dt_cd_ri;

    input [DW_G-1:0] i_b;

    output [D_WIDTH-1:0] x_vt_hat;


    // 1 7 39  ==> 47bit
    wire [DW_A + DW_B-2:0]mul_theta4_x_soc;
   
    // 1 8 39 ==> 48bit
    wire [DW_A+DW_C-1:0] add_theta5; //result
    
    // 1 0 46 ==> 47bit 
    wire [DW_D+DW_E-1-1:0] mul_a4_x_rc;  //a_4 * x_rc
    
    // 1 4 23 ==> 28bit
    wire [27:0] mul_b2_ri_ib;

    // 1 5 46 ==> 52bit (a_4 *x_rc) + (b_2+ri)*ib
    wire [51:0] add_xrc_ib;  
   
    // 1 9 46 ==> 56bit
    wire [55:0] r_x_vt_hat; 

mul #(

    .D_WIDTH1(DW_A),

    .D_WIDTH2(DW_B)

) u_multiple1

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(theta4), // SIGN_INT_A__FLT_A

    .mul_b(x_soc), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_theta4_x_soc) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);



add #(

    .SIGN_BIT(SIGN),

    .INT_BIT(7),

    .FLT_BIT(FLT_A + FLT_B)

) u_adder_add_theta

(

    .din_a(mul_theta4_x_soc), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B

    .din_b({theta5[DW_C-1],{5{theta5[DW_C-1]}},theta5[DW_C-2:0],{18{1'b0}}}), //din_c 맞춰주는 설정

    .dout(add_theta5) // SIGN_INT_B+1_FLT_B => DW_B+1

);



mul #(

    .D_WIDTH1(DW_D),

    .D_WIDTH2(DW_E)

) u_multiple2
(
    .clk(clk),

    .n_rst(n_rst),

    .mul_a(a_4), // SIGN_INT_A__FLT_A

    .mul_b(x_rc), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_a4_x_rc) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);


mul #(

    .D_WIDTH1(DW_F),

    .D_WIDTH2(DW_G)

) u_multiple3

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(dt_cd_ri), // SIGN_INT_A__FLT_A

    .mul_b(i_b), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_b2_ri_ib) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);




wire [51:0]sub_add_xrc_ib;
// a_4 * x_rc + dt_cd_ri * ib
add #(

    .SIGN_BIT(SIGN),

    .INT_BIT(4),

    .FLT_BIT(46)

) u_adder_2
(
    .din_a({mul_b2_ri_ib,{23{1'b0}}}), //din_b 기준으로 설정 정수bit이 0이 아닌친구 sign_int_b_flt_b

    .din_b({mul_a4_x_rc[DW_D+DW_E-1-1],{4{mul_a4_x_rc[DW_D+DW_E-1-1]}},mul_a4_x_rc[DW_D+DW_E-1-2:0]}), //din_c 맞춰주는 설정

    .dout(sub_add_xrc_ib) // sign_int_b+1_flt_b => dw_b+1

);


assign add_xrc_ib = ~(sub_add_xrc_ib) +1'b1;
// add_result x_vt_hat add_theta5 -  r_x_vt_hat
add #(

    .SIGN_BIT(SIGN),

    .INT_BIT(8),

    .FLT_BIT(46)

) u_adder_x_vt_hat
(

    .din_a({add_theta5,{7{1'b0}}}), //din_b 기준으로 설정 정수bit이 0이 아닌친구 sign_int_b_flt_b

    .din_b({add_xrc_ib[51],{3{add_xrc_ib[51]}},{add_xrc_ib[50:0]}}), //din_c 맞춰주는 설정

    .dout(r_x_vt_hat) // sign_int_b+1_flt_b => dw_b+1

);





//assign x_rc_p = mul_a_bc[DW_A+DW_B+1-1-1:DW_A+DW_B+1-1-1-D_WIDTH+1];
assign x_vt_hat = {r_x_vt_hat[55],r_x_vt_hat[48:26]};

// 1, 0, 23 




endmodule
