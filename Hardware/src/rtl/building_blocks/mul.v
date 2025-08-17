`timescale 1ps/1ps
module mul #(
    parameter D_WIDTH1,
    parameter D_WIDTH2
)
(
    clk,
    n_rst,
    mul_a,
    mul_b,
    mul_out
);
// ex {N{1'b0}}
    input clk;
    input n_rst;
    input [D_WIDTH1-1:0] mul_a;
    input [D_WIDTH2-1:0] mul_b;
    output [D_WIDTH1+D_WIDTH2-1-1:0] mul_out;

    wire [D_WIDTH1+D_WIDTH2-1-1:0] mul_zero;

    wire a_sign, b_sign;
    assign a_sign = mul_a[D_WIDTH1-1]; // SIGN BIT
    assign b_sign = mul_b[D_WIDTH2-1]; // SIGN BIT

    wire [D_WIDTH1-2:0] a_abs;         // INT BIT A + FLT BIT A
    wire [D_WIDTH2-2:0] b_abs;         // INT BIT B + FLT BIT B
    assign a_abs = (a_sign == 1'b1) ? ~mul_a[D_WIDTH1-2:0] + {{D_WIDTH1-2{1'b0}},1'b1} : mul_a[D_WIDTH1-2:0];
    assign b_abs = (b_sign == 1'b1) ? ~mul_b[D_WIDTH2-2:0] + {{D_WIDTH2-2{1'b0}},1'b1} : mul_b[D_WIDTH2-2:0];

    reg [D_WIDTH1+D_WIDTH2-2-1:0] mul_abs;                    // INT_A+FLT_A * INT_B+FLT_B => D_WIDTH1 + D_WIDTH2 - 2(SIGN)

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            mul_abs <= {D_WIDTH1+D_WIDTH2-2{1'b0}};
        end
        else begin
            mul_abs <= a_abs * b_abs; //
        end
    end

    reg a_sign_d, b_sign_d;
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            a_sign_d <= 1'b0;
            b_sign_d <= 1'b0;
        end
        else begin
            a_sign_d <= a_sign;
            b_sign_d <= b_sign;
        end
    end

    wire [D_WIDTH1+D_WIDTH2-2-1:0] mul_abs_2s;
    assign mul_abs_2s = ~mul_abs + {{D_WIDTH1+D_WIDTH2-2-1{1'b0}},1'b1};

    assign mul_zero = (a_sign_d == b_sign_d) ? {1'b0,mul_abs} : {1'b1,mul_abs_2s};

    assign mul_out = (mul_zero[D_WIDTH1+D_WIDTH2-1-2:0] == {D_WIDTH1+D_WIDTH2-1-1{1'b0}}) ? {D_WIDTH1+D_WIDTH2-1{1'b0}} : mul_zero;


endmodule