`timescale 1ps/1ps

// A*(B+C) 's ALU



module alu_p_1to4 #(

    parameter DW_A = 24,
    //p1_p
    parameter INT_A = 0,

    parameter DW_B = 24,
    //k_1
    parameter INT_B = 3,

    parameter DW_C = 24,
    //h_1
    parameter INT_C = 0,

    parameter DW_D = 24,
    //p3_p
    parameter INT_D = 0,

    //p2_p
    parameter DW_E = 24,

    parameter INT_E = 0,
    //p4_p
    parameter DW_F = 24,
    
    parameter INT_F = 0,
    //k_2
    parameter DW_G = 24,

    parameter INT_G = 0



)

(

    clk,

    n_rst,
    p1_p,
    p3_p,
    p2_p,
    p4_p,
    k_1,
    k_2,
    h_1,
    p_1,
    p_2,
    p_3,
    p_4

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
    input [DW_A-1:0] p1_p;
   // input [DW_B-1:0] din_b;
    input [DW_B-1:0] k_1;
   // input [DW_E-1:0] din_c;
    input [DW_C-1:0] h_1;
   
    input [DW_D-1:0] p3_p;
 
    input [DW_E-1:0] p2_p;

    input [DW_F-1:0] p4_p;

    input [DW_G-1:0] k_2;


    output [D_WIDTH-1:0] p_1;
    output [D_WIDTH-1:0] p_2;
    output [D_WIDTH-1:0] p_3;
    output [D_WIDTH-1:0] p_4;


//------------------------------------alu p_1----------------------------------------------------------    
    // 1 3 43  ==> 47bit
    wire [DW_C+DW_B-2:0]mul_kh1;
    // 1 3 66 ==> 70bit
    wire [DW_C+DW_B+DW_A-3:0] mul_p1_p_kh1; //result
    // 1 3 43 ==> 47bit
    wire [DW_D+DW_B-1-1:0] mul_kh2_p3_p;  //b_2 * i_b

mul #(

    .D_WIDTH1(DW_B),

    .D_WIDTH2(DW_C)

) u_multiple1

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(k_1), // SIGN_INT_A__FLT_A

    .mul_b(h_1), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_kh1) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);

//k_1*h_1*p1_p
mul #(

    .D_WIDTH1(47),

    .D_WIDTH2(DW_A)

) u_multiple2

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(mul_kh1), // SIGN_INT_A__FLT_A

    .mul_b(p1_p), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_p1_p_kh1) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);

//DW_C = DW_A+DW_B -1


mul #(

    .D_WIDTH1(DW_B),

    .D_WIDTH2(DW_A)

) u_multiple3

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(~(k_1)+1'b1), // SIGN_INT_A__FLT_A

    .mul_b(p3_p), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_kh2_p3_p) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);


//K_1*h_1 * p1_p + (-K_1*P3_P)

wire [70:0]add_kh1_kh2_p;
add #(

    .SIGN_BIT(SIGN),

    .INT_BIT(3),

    .FLT_BIT(66)

) u_adder_kh1_p1_p_p3_p

(

    .din_a(mul_p1_p_kh1), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B

    .din_b({mul_kh2_p3_p[DW_B+DW_D-2],mul_kh2_p3_p[45:0],{23{1'b0}}}), //din_c 맞춰주는 설정

    .dout(add_kh1_kh2_p) // SIGN_INT_B+1_FLT_B => DW_B+1

);

wire [71:0]r_p_1;

add #(

    .SIGN_BIT(SIGN),

    .INT_BIT(4),

    .FLT_BIT(66)

) u_adder_p1_p

(

    .din_a(~(add_kh1_kh2_p)+1'b1), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B

    .din_b({p1_p[DW_A-1],{4{p1_p[DW_A-1]}},p1_p[22:0],{43{1'b0}}}), //din_c 맞춰주는 설정

    .dout(r_p_1) // SIGN_INT_B+1_FLT_B => DW_B+1

);
// p_1 (1, 0, 23)
assign p_1 = {r_p_1[71],r_p_1[65:43]};

//---------------------------------------------------------------------------------------------------------------------------------------



//-----------------------------alu_P_2---------------------------------------------------------------------------------------------------


    // 1 3 66 ==> 70bit
    wire [DW_C+DW_B+DW_A-3:0] mul_kh1_p2_p; //result
    // 1 3 43 ==> 47bit
    wire [DW_D+DW_B-1-1:0] mul_kh2_p4_p;  //kh2*p4_p


//k_1*h_1*p2_p
mul #(

    .D_WIDTH1(47),

    .D_WIDTH2(DW_A)

) u_multiple5

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(mul_kh1), // SIGN_INT_A__FLT_A

    .mul_b(p2_p), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_kh1_p2_p) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);

//DW_C = DW_A+DW_B -1


mul #(

    .D_WIDTH1(DW_B),

    .D_WIDTH2(DW_A)

) u_multiple6

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(~(k_1)+1'b1), // SIGN_INT_A__FLT_A

    .mul_b(p4_p), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_kh2_p4_p) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);


//K_1*h_1 * p1_p + (-K_1*P3_P)

wire [70:0]add_p2_p_kh1_kh2_p;
add #(

    .SIGN_BIT(SIGN),

    .INT_BIT(3),

    .FLT_BIT(66)

) u_adder_kh1_p2_p_p4_p_p2

(

    .din_a(mul_kh1_p2_p), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B

    .din_b({mul_kh2_p4_p[DW_B+DW_D-2],mul_kh2_p4_p[45:0],{23{1'b0}}}), //din_c 맞춰주는 설정

    .dout(add_p2_p_kh1_kh2_p) // SIGN_INT_B+1_FLT_B => DW_B+1

);

wire [71:0]r_p_2;

add #(

    .SIGN_BIT(SIGN),

    .INT_BIT(4),

    .FLT_BIT(66)

) u_adder_p22222

(

    .din_a(~(add_p2_p_kh1_kh2_p)+1'b1), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B

    .din_b({p2_p[DW_E-1],{4{p2_p[DW_E-1]}},p2_p[22:0],{43{1'b0}}}), //din_c 맞춰주는 설정

    .dout(r_p_2) // SIGN_INT_B+1_FLT_B => DW_B+1

);
// p_1 (1, 0, 23)
assign p_2 = {r_p_2[71],r_p_2[65:43]};

//-----------------------------------------------------------------------------------------------------------------------------------------


//------------------------alu_P_3----------------------------------------------------------------------------


    // 1 0 46  ==> 47bit
    wire [DW_C+DW_G-2:0]mul_kh3;
    // 1 0 69 ==> 70bit
    wire [DW_C+DW_G+DW_A-3:0] mul_p1_p_kh3; //p1_p*kh3
    // 1 0 46 ==> 47bit
    wire [DW_D+DW_G-1-1:0] mul_kh4_p3_p;  //b_2 * i_b

mul #(

    .D_WIDTH1(DW_G),

    .D_WIDTH2(DW_C)

) u_multiple7

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(k_2), // SIGN_INT_A__FLT_A

    .mul_b(h_1), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_kh3) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);

//k_2*h_1*p1_p
mul #(

    .D_WIDTH1(47),

    .D_WIDTH2(DW_A)

) u_multiple8

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(mul_kh3), // SIGN_INT_A__FLT_A

    .mul_b(p1_p), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_p1_p_kh3) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);


//kh4 = -K_2
//
mul #(

    .D_WIDTH1(DW_G),

    .D_WIDTH2(DW_A)

) u_multiple9

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(~(k_2)+1'b1), // SIGN_INT_A__FLT_A

    .mul_b(p3_p), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_kh4_p3_p) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);


//K_2*h_1 * p1_p + (-K_2*P3_P)

wire [70:0]add_kh3_kh4_p;
add #(

    .SIGN_BIT(SIGN),

    .INT_BIT(0),

    .FLT_BIT(69)

) u_adder_kh3_p1_p_p3_p

(

    .din_a(mul_p1_p_kh3), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B

    .din_b({mul_kh4_p3_p[DW_G+DW_D-2],mul_kh4_p3_p[45:0],{23{1'b0}}}), //din_c 맞춰주는 설정

    .dout(add_kh3_kh4_p) // SIGN_INT_B+1_FLT_B => DW_B+1

);

wire [71:0]r_p_3;

add #(

    .SIGN_BIT(SIGN),

    .INT_BIT(1),

    .FLT_BIT(69)

) u_adder_p3_p3

(

    .din_a(~(add_kh3_kh4_p)+1'b1), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B

    .din_b({p3_p[DW_D-1],{1{p3_p[DW_D-1]}},p3_p[22:0],{46{1'b0}}}), //din_c 맞춰주는 설정

    .dout(r_p_3) // SIGN_INT_B+1_FLT_B => DW_B+1

);
// p_3 (1, 0, 23)
assign p_3 = {r_p_3[71],r_p_3[68:46]};

//---------------------------------------------------------------------------------------------------------------------------




//-------------------------------------ALU_P_4------------------------------------------------------------------------------

  
    // 1 0 69 ==> 70bit
    wire [DW_C+DW_G+DW_E-3:0] mul_p2_p_kh3; //p2_p*kh3
    // 1 0 46 ==> 47bit
    wire [DW_F+DW_G-1-1:0] mul_kh4_p4_p;  //kh4*p4_p


//k_2*h_1*p2_p =kh3 * p2_p
mul #(

    .D_WIDTH1(47),

    .D_WIDTH2(DW_E)

) u_multiple11

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(mul_kh3), // SIGN_INT_A__FLT_A

    .mul_b(p2_p), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_p2_p_kh3) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);


//kh4 = -K_2
//
mul #(

    .D_WIDTH1(DW_G),

    .D_WIDTH2(DW_C)

) u_multiple12

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(~(k_2)+1'b1), // SIGN_INT_A__FLT_A

    .mul_b(p4_p), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_kh4_p4_p) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);


//K_2*h_1 * p2_p + (-K_2*P4_P)

wire [70:0]add_p4_kh3_kh4_p;
add #(

    .SIGN_BIT(SIGN),

    .INT_BIT(0),

    .FLT_BIT(69)

) u_adder_kh4_p1_p_p3_p

(

    .din_a(mul_p2_p_kh3), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B

    .din_b({mul_kh4_p4_p[DW_G+DW_F-2],mul_kh4_p4_p[45:0],{23{1'b0}}}), //din_c 맞춰주는 설정

    .dout(add_p4_kh3_kh4_p) // SIGN_INT_B+1_FLT_B => DW_B+1

);

wire [71:0]r_p_4;

add #(

    .SIGN_BIT(SIGN),

    .INT_BIT(1),

    .FLT_BIT(69)

) u_adder_p4_p_p

(

    .din_a(~(add_p4_kh3_kh4_p)+1'b1), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B

    .din_b({p4_p[DW_F-1],{1{p4_p[DW_F-1]}},p4_p[22:0],{46{1'b0}}}), //din_c 맞춰주는 설정

    .dout(r_p_4) // SIGN_INT_B+1_FLT_B => DW_B+1

);
// p_3 (1, 0, 23)
assign p_4 = {r_p_4[71],r_p_4[68:46]};


//------------------------------------------------------------------------------------------------

endmodule








