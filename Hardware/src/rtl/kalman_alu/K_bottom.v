`timescale 1ps/1ps

// A*(B+C) 's ALU



module K_bottom #(

    parameter DW_A = 24,

    parameter INT_A = 0,

    parameter DW_B = 24,

    parameter INT_B = 0,

    parameter DW_C = 24,

    parameter INT_C = 0,

    parameter DW_D = 24,

    parameter INT_D = 0,

    parameter DW_E = 24,

    parameter INT_E = 0,

    parameter INT_F = 0,
    
    parameter DW_F = 24
)
(
    clk,
    n_rst,
    h_1,
    p1_p,
    p2_p,
    p3_p,
    p4_p,
    r,
    k_bottom
);

    parameter SIGN = 1;

    parameter D_WIDTH = 24;



    // 3 = vt, 7 = soc, 2 = theta4
    //h_1
    parameter FLT_A = DW_A - INT_A - SIGN;
    //p1_p
    parameter FLT_B = DW_B - INT_B - SIGN;
    //p2_p
    parameter FLT_C = DW_C - INT_C - SIGN;
    //p3_p
    parameter FLT_D = DW_D - INT_D - SIGN;
    //p4_p
    parameter FLT_E = DW_E - INT_E - SIGN;
  
    parameter FLT_F = DW_F - INT_F - SIGN;

    input clk, n_rst;

    input [DW_A-1:0] h_1;
   // input [DW_B-1:0] din_b;
    input [DW_B-1:0] p1_p;
   // input [DW_E-1:0] din_c;
    input [DW_C-1:0] p2_p;
   
    input [DW_D-1:0] p3_p;
    
    input [DW_E-1:0] p4_p;

    input [DW_F-1:0] r;

    output [D_WIDTH-1:0] k_bottom;


    // 1 0 46  ==> 52bit
    wire [DW_A+DW_B-2:0]mul_h1_p1_p;
    // 1 1 69 
    wire [DW_A+DW_D-1:0] add_mul_p3_p; //result
    
    wire [70:0] mul_add_p3_p_h_1;  //(h_1*p1_p-p3_p) * h_1

mul #(

    .D_WIDTH1(DW_A),

    .D_WIDTH2(DW_B)

) u_multiple1

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(h_1), // SIGN_INT_A__FLT_A

    .mul_b(p1_p), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_h1_p1_p) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);

//h_1*p1_p - p3_p

add #(

    .SIGN_BIT(SIGN),

    .INT_BIT(0),

    .FLT_BIT(46)

) u_adder_h1_p1_p_p3_p

(

    .din_a(mul_h1_p1_p), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B

    .din_b(~{p3_p,{23{1'b0}}}+1'b1), //din_c 맞춰주는 설정

    .dout(add_mul_p3_p) // SIGN_INT_B+1_FLT_B => DW_B+1

);


mul #(

    .D_WIDTH1(48),

    .D_WIDTH2(DW_B)

) u_multiple2

(

    .clk(clk),

    .n_rst(n_rst),

    .mul_a(add_mul_p3_p), // SIGN_INT_A__FLT_A

    .mul_b(h_1), // SIGN_INT_B+1_FLT_B => DW_E+1

    .mul_out(mul_add_p3_p_h_1) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1

);

//--------------------------------------------------------------------------------------

    //1 0 46
    wire [DW_A+DW_C-2:0]mul_h1_p2_p;
    
    //1 1 46
    wire [DW_A+DW_E-1:0] add_mul_p4_p; //result
    
mul #(
    .D_WIDTH1(DW_A),
    .D_WIDTH2(DW_C)
) u_multiple3
(
    .clk(clk),
    .n_rst(n_rst),
    .mul_a(h_1), // SIGN_INT_A__FLT_A
    .mul_b(p2_p), // SIGN_INT_B+1_FLT_B => DW_E+1
    .mul_out(mul_h1_p2_p) // SIGN_INT_B+INT_E+1_FLT_B+FLT_E-1
);


add #(

    .SIGN_BIT(SIGN),

    .INT_BIT(0),

    .FLT_BIT(46)

) u_adder_h1_p2_p_p4_p

(

    .din_a(mul_h1_p2_p), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B

    .din_b(~{p4_p,{23{1'b0}}}+1'b1), //din_c 맞춰주는 설정

    .dout(add_mul_p4_p) // SIGN_INT_B+1_FLT_B => DW_B+1

);

//-------------------------------------------------------
 
wire[71:0]alu_kb_1;

add #(

    .SIGN_BIT(SIGN),

    .INT_BIT(1),

    .FLT_BIT(69)

) u_adder_alu_kb_1

(

    .din_a(mul_add_p3_p_h_1), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B

    .din_b(~{add_mul_p4_p,{23{1'b0}}}+1'b1), //din_c 맞춰주는 설정

    .dout(alu_kb_1) // SIGN_INT_B+1_FLT_B => DW_B+1

);

//last alu k_b
//-----------------------------------------------------------------------------------
 
wire [72:0]k_bot;
add #(

    .SIGN_BIT(SIGN),

    .INT_BIT(2),

    .FLT_BIT(69)

) u_adder_alu_kb_last

(

    .din_a(alu_kb_1), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B

    .din_b({r[23],{2{r[23]}},r[22:0],{46{1'b0}}}), //din_c 맞춰주는 설정

    .dout(k_bot) // SIGN_INT_B+1_FLT_B => DW_B+1

);


assign k_bottom = {k_bot[72],k_bot[68:46]};

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
