`timescale 1ps/1ps
`define FPGA
//------------------------
//----------EKF-----------
//------------------------
module ekf_charge (
    clk,
    n_rst,
    //i_b,
    //v_t,
    start,
    stop_sig,
    ekf_vrc,
    ekf_soc,
    ekf_done
);
    // ex {N{1'b0}}
// CASE 1
// SIGN + INT_CASE1 + FR_CASE1 = 24
// Ri, Rd, Cd, Cb, Q_1, Q_4, R
// P_1, P_2, P_3, P_4
// theta4 = ocv-soc
// a_4, x_rc
//-------------------------------------------
// CASE 2
// SIGN + INT_CASE2 + FR_CASE2 = 24
// theta5 = ocv-soc
//-------------------------------------------
// CASE 3
// SIGN + INT_CASE3 + FR_CASE3 = 24
//-------------------------------------------
parameter SIGN = 1;
parameter INT_CASE1 = 0;
parameter FR_CASE1 = 23;
parameter INT_CASE2 = 2;
parameter FR_CASE2 = 21;
parameter INT_CASE3 = 7;
parameter FR_CASE3 = 16;
//D_WIDTH
parameter D_WIDTH = 24;
//-------------------------------------------
// State machine
parameter STATE_CNT = 4;
parameter IDLE      = 4'h0;
// LATENCY_1 => x_soc_p, x_rc_p, P1_p, P2_p, P3_p, P4_p, x_vt_hat
parameter LATENCY_1 = 4'h1; 
// LATENCY_2 => K_up_1, K_up_2, K_bottom
parameter LATENCY_2 = 4'h2;
// LATENCY_3 => K_1, K_2
parameter LATENCY_3 = 4'h3;
// LATENCY_4 => x_soc, x_rc, kh1, kh2, kh3, kh4, P_1, P_2, P_3, P_4
parameter LATENCY_4 = 4'h4;
parameter LATENCY_5 = 4'h5;
// DONE => k = k +1
parameter DONE      = 4'h6;
parameter SOC_DONE  = 4'h7;
parameter STOP      = 4'h8;
//-------------------------------------------
// Static parameter
parameter RI = 24'b0__0000_0110_0110_0110_0110_011; //0.025 => 0.02499
parameter RD = 24'b0__0000_1000_1011_0100_0011_100; //0.034 => 0.03399
// CD =  0.00005590894
// 소수부 0 13개 기억
//parameter CD = 24'b0__0111_0101_0011_1111_1110_001
parameter CD = 24'b0__0111_0101_0011_1111_1110_001;
// CB = 0.00005676
// 소수부 0 13개 기억
//parameter CB = 24'b0__0111_0111_0000_1000_1100_101
parameter CB = 24'b0__0111_0111_0000_1000_1100_101;
// Q_1, Q_4, R //0.0001
// 소수부 0 13개 기억
// Q_2, Q_3 = 0
//parameter Q_1 = 24'b0__1101_0001_1011_0111_0001_011
parameter Q_1 = 24'b0__0000_0000_0000_0_1101_0001_10; //0.0001
parameter Q_4 = 24'b0__0000_0000_0000_0_1101_0001_10;
parameter R = 24'b0__0000_0000_0000_0_1101_0001_10;
// dt = 1000
parameter b_1_1000 = 24'b1__1111_0001_0111_1100_1100_111;
parameter b_2_1000 = 24'b0__0000_1110_0100_1111_0100_011;
// -0.10100100000100010000010
//    24'b1__0101_1011_1110_1110_1111_110
parameter a_4_1000 = 24'b1__0101_1011_1110_1110_1111_110; //-0.6408843994140625
//0.011010010001100110110000111
parameter a_4_1000_2 = 24'b0__0110_1001_0001_1001_1011_000; //0.41054826473046074

// dt = 100
parameter b_1_100 = 24'b1__1111_1110_1000_1100_0111_110;
parameter b_2_100 = 24'b0__0000_0001_0110_1110_0101_001;
parameter a_4_100 = 24'b0__1101_0101_1111_1110_0100_110;
parameter a_4_100_2 = 24'b0__1011_0010_1111_0111_0010_001;
//0.1011001011110111001000110010010111001101011010011011
//-------------------------------------------
// theta4 => 1 0 23 
// theta5 => 1 2 21
parameter theta4_1 = 24'b0__0000_0110_1100_1000_1011_010; // x_soc < 20 , 0.0265
parameter theta4_2 = 24'b0__0000_0010_0011_1010_0010_100; // x_soc < 95 , 0.0087
parameter theta4_3 = 24'b0__0000_0011_1111_0111_1100_111; // else , 0.0155
parameter theta5_1 = 24'b0_10_1110_1001_0010_0011_1010_0; // x_soc < 20 , 2.9107
parameter theta5_2 = 24'b0_11_0100_0100_0011_0010_1100_1; // x_soc < 95 , 3.2664
parameter theta5_3 = 24'b0_10_1001_1110_1001_1110_0001_1; // else , 2.6196
//-------------------------------------------
parameter dt_cd_ri_1000 = 24'b0__0001_0100_1010_1110_1010_011; // dt*cd + ri
parameter dt_cd_ri_100 = 24'b0__0000_0111_1101_0100_0000_011;
// Ports
input clk, n_rst;
input start;
input stop_sig;
//input [4:0] i_b; // SIGN + INT => 1 + 4
//input [D_WIDTH-1:0] v_t; 

output [D_WIDTH-1:0] ekf_vrc;
output [D_WIDTH-1:0] ekf_soc;
//output [22:16] ekf_soc;
output ekf_done;
//-------------------------------------------
wire [D_WIDTH-1:0] first_soc;
wire [D_WIDTH-1:0] first_vrc;
//assign first_soc = {1'b0,7'h64,{16{1'b0}}}; //100
assign first_soc = 24'b0_000_0001_0000_0000_0000_0000;
assign first_vrc = {D_WIDTH{1'b0}}; //0

parameter first_p1 = 24'b0__0000_0000_0000_0_1101_0001_10; //0.0001
parameter first_p2 = {D_WIDTH{1'b0}}; //0
parameter first_p3 = {D_WIDTH{1'b0}}; //0
parameter first_p4 = 24'b0__0000_0000_0000_0_1101_0001_10; //0.0001


reg [STATE_CNT-1:0] state, n_state;
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        state <= IDLE;
    end
    else begin
        state <= n_state;
    end
end

reg [4:0] cnt_1, cnt_2;
reg [7:0] cnt_4;
reg [5:0] cnt_3;
reg [11:0] k;
wire div_done;
reg [11:0] cnt_d;
wire x_soc_32;

wire [4:0] i_b;
wire [4:0] i_b_charge;
wire [D_WIDTH-1:0] v_t;
wire la1_done;
reg la2_done;
reg la3_done;
reg la4_done;

reg clk_en;

reg stop_sig_ff;

/*
`ifdef FPGA
ib_mem ib_rom(
	.address(k+12'h1),
	.clock(clk),
	.q(i_b)
    );

vt_mem vt_rom(
	.address(k+12'h1),
	.clock(clk),
	.q(v_t)
    );
reg [27:0]fpga_cnt;

always @ (posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        fpga_cnt <= 28'd0;
        clk_en <= 1'b0;
    end
    else begin
        if (state == SOC_DONE) begin
            fpga_cnt <= fpga_cnt + 1'b1;
            if (fpga_cnt == 28'd250000) begin
                clk_en <= 1'b1;
                fpga_cnt <= 28'd0;
            end
            else begin
                clk_en <= 1'b0;
            end
        end

        else begin
            fpga_cnt <= 28'd0;
        end
    end
end
`else    
*/
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        clk_en <= 1'b0;
    end

    else begin
        clk_en <= 1'b1;
    end
end

//wire [11:0] read_addr;
//assign read_addr = 12'd2455-k;

rom_charge #(
    .D_WIDTH(5),
    .A_WIDTH(12),
    .SELECT(0)
    ) rom_i_b (
	.clk(clk),
    .n_rst(n_rst),
	.raddr(k+12'h1), //12'd2456
    //.raddr(read_addr), //12'd2456
	.data_out(i_b)
);

//assign i_b = (~i_b_charge) + 1'b1;

rom_charge #(
    .D_WIDTH(24),
    .A_WIDTH(12),
    .SELECT(1)
    ) rom_v_t (
	.clk(clk),
    .n_rst(n_rst),
	.raddr(k+12'h1), //12'd2456
    //.raddr(read_addr), //12'd2456
	.data_out(v_t)
);

//`endif


always @(*)
    case(state)
        IDLE : n_state = (start == 1'b1) ? LATENCY_1 : state;
        LATENCY_1 : n_state = (la1_done == 1'b1) ? LATENCY_2 : state;
        LATENCY_2 : n_state = (la2_done == 1'b1) ? LATENCY_3 : state;
        LATENCY_3 : n_state = (la3_done == 1'b1) ? LATENCY_4 : state; // divider
        LATENCY_4 : n_state = (la4_done == 1'b1) ? SOC_DONE : state;
        LATENCY_5 : n_state = SOC_DONE;
        SOC_DONE : n_state = (clk_en == 1'b1) && ((x_soc_32 == 1'b1) || ((x_soc_32 == 1'b0) && (cnt_d == 12'h3f2)))? DONE : state;
        DONE : n_state = (stop_sig_ff == 1'b1) ? STOP : (k < 12'd2456) ? LATENCY_1 : (k == 12'd2456) ? IDLE : state; //0 ~ 2454
        STOP : n_state = (start == 1'b1) ? DONE : state;
        default : n_state = IDLE;
    endcase

    // LATENCY 1
    reg [D_WIDTH-1:0] x_soc_p_reg;
    reg [D_WIDTH-1:0] x_rc_p_reg;
    reg [D_WIDTH-1:0] p1_p_reg;
    reg [D_WIDTH-1:0] p2_p_reg;
    reg [D_WIDTH-1:0] p3_p_reg;
    reg [D_WIDTH-1:0] p4_p_reg;
    reg [D_WIDTH-1:0] x_vt_hat_reg;
    // LATENCY 2
    reg [47:0] k1_up_reg;
    reg [47:0] k2_up_reg;
    reg [D_WIDTH-1:0] k_bottom_reg;
    // LATENCY 3
    reg [D_WIDTH-1:0] k_1_reg;
    reg [D_WIDTH-1:0] k_2_reg;
    // LATENCY 4
    reg [D_WIDTH-1:0] x_soc_reg;
    reg [D_WIDTH-1:0] x_rc_reg;


    reg [D_WIDTH-1:0] p1_reg;
    reg [D_WIDTH-1:0] p2_reg;
    reg [D_WIDTH-1:0] p3_reg;
    reg [D_WIDTH-1:0] p4_reg;

    wire [D_WIDTH-1:0] p1_wire;
    wire [D_WIDTH-1:0] p2_wire;
    wire [D_WIDTH-1:0] p3_wire;
    wire [D_WIDTH-1:0] p4_wire;

    wire [D_WIDTH-1:0] x_rc_p_wire;
    wire [D_WIDTH-1:0] k_bottom_wire;

    //wire [D_WIDTH-1:0] k_1_wire;
    //wire [D_WIDTH-1:0] k_2_wire;

    wire [D_WIDTH-1:0] k_1_wire;
    wire [D_WIDTH-1:0] k_2_wire;

    wire [D_WIDTH-1:0] x_vt_hat_wire;

//////////////////////////////////////////////////////////////////////////////////////////
//(x_soc_reg[22:16] > 7'd70)
/*
wire [D_WIDTH-1:0] a_4;
assign a_4 = (x_soc_reg[D_WIDTH-2:D_WIDTH-3] == 2'b00) ? a_4_100 : a_4_1000;       // soc 32% 이하
wire [D_WIDTH-1:0] a_4_2;
assign a_4_2 = (x_soc_reg[D_WIDTH-2:D_WIDTH-3] == 2'b00) ? a_4_100_2 : a_4_1000_2; // soc 32% 이하
wire [D_WIDTH-1:0] b_1;
assign b_1 = (x_soc_reg[D_WIDTH-2:D_WIDTH-3] == 2'b00) ? b_1_100 : b_1_1000;       // soc 32% 이하
wire [D_WIDTH-1:0] b_2;
assign b_2 = (x_soc_reg[D_WIDTH-2:D_WIDTH-3] == 2'b00) ? b_2_100 : b_2_1000;       // soc 32% 이하
wire [D_WIDTH-1:0] dt_cd_ri;
assign dt_cd_ri = (x_soc_reg[D_WIDTH-2:D_WIDTH-3] == 2'b00) ? dt_cd_ri_100 : dt_cd_ri_1000;       // soc 32% 이하
*/
wire [D_WIDTH-1:0] a_4;
assign a_4 = (x_soc_reg[22:16] > 7'd70) ? a_4_100 : a_4_1000;       // soc 70% 이상
wire [D_WIDTH-1:0] a_4_2;
assign a_4_2 = (x_soc_reg[22:16] > 7'd70) ? a_4_100_2 : a_4_1000_2; // soc 70% 이상
wire [D_WIDTH-1:0] b_1;
assign b_1 = (x_soc_reg[22:16] > 7'd70) ? b_1_100 : b_1_1000;       // soc 70% 이상
wire [D_WIDTH-1:0] b_2;
assign b_2 = (x_soc_reg[22:16] > 7'd70) ? b_2_100 : b_2_1000;       // soc 70% 이상
wire [D_WIDTH-1:0] dt_cd_ri;
assign dt_cd_ri = (x_soc_reg[22:16] > 7'd70) ? dt_cd_ri_100 : dt_cd_ri_1000;       // soc 70% 이상

wire [D_WIDTH-1:0] theta4;
assign theta4 = (x_soc_reg[22:16] < 7'h14) ? theta4_1 : ((x_soc_reg[22:16] >= 7'h14) && (x_soc_reg[22:16] <= 7'h5f)) ? theta4_2 : theta4_3;
wire [D_WIDTH-1:0] theta5;
assign theta5 = (x_soc_reg[22:16] < 7'h14) ? theta5_1 : ((x_soc_reg[22:16] >= 7'h14) && (x_soc_reg[22:16] <= 7'h5f)) ? theta5_2 : theta5_3;

wire [D_WIDTH-1:0] h_1;
assign h_1 = theta4;
//////////////////////////////////////////////////////////////////////////////////////////

    // extension
    wire [D_WIDTH:0] p1_p_wire_ext;             // 24 + 24 => 25
    wire [D_WIDTH+D_WIDTH-1-1:0] p2_p_wire_ext; // 24 * 24 => 47
    wire [D_WIDTH+D_WIDTH-1-1:0] p3_p_wire_ext; // 24 * 24 => 47
    wire [47:0] p4_p_wire_ext;                  // 
    wire [31:0] x_soc_p_wire_ext;
    wire [47:0] k1_up_wire_ext;
    wire [47:0] k2_up_wire_ext;
    wire [47:0] x_soc_ext_1;
    wire [48:0] x_soc_ext_2; // 1 8 16
    wire [47:0] x_rc_ext_1;
    wire [48:0] x_rc_ext_2;

/////////////////////////////////////////////////////////////////////////////////////////
    wire [D_WIDTH-1:0] p1_p_wire;
    assign p1_p_wire = {p1_p_wire_ext[D_WIDTH],p1_p_wire_ext[D_WIDTH-2:0]};
    wire [D_WIDTH-1:0] p2_p_wire;
    assign p2_p_wire = p2_p_wire_ext[46:23];
    wire [D_WIDTH-1:0] p3_p_wire;
    assign p3_p_wire = p3_p_wire_ext[46:23];
    wire [D_WIDTH-1:0] p4_p_wire;
    assign p4_p_wire = {p4_p_wire_ext[47],p4_p_wire_ext[45:23]};

    wire [D_WIDTH-1:0] x_soc_p_wire;
    assign x_soc_p_wire = {x_soc_p_wire_ext[31],x_soc_p_wire_ext[29:7]};


    wire [47:0] k1_up_wire;

    assign k1_up_wire = {k1_up_wire_ext[47],k1_up_wire_ext[45:0],1'b0};
    wire [47:0] k2_up_wire;

    assign k2_up_wire = {k2_up_wire_ext[47],k2_up_wire_ext[45:0],1'b0};

    wire [D_WIDTH-1:0] x_soc_wire;
    assign x_soc_wire = {x_soc_ext_2[48],x_soc_ext_2[46:24]};
    wire [D_WIDTH-1:0] x_rc_wire;
    assign x_rc_wire = {x_rc_ext_2[48],x_rc_ext_2[42:20]};

    assign x_soc_32 = (x_soc_reg[22:16] > 7'd70) ? 1'b1 : 1'b0;
//////////////////////////////////////////////////////////////////////////////////////////
//STOP signal 
reg stop_d;
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        stop_d <= 1'b0;
    end
    else begin
        stop_d <= (stop_sig == 1'b1) ? 1'b1 : 1'b0;
    end
end


always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        stop_sig_ff <= 1'b0;
    end
    else begin
        if ((stop_sig == 1'b1) && (stop_d == 1'b0)) begin
            stop_sig_ff <= 1'b1;
        end
        else if (state == STOP) begin
            stop_sig_ff <= 1'b0;
        end
        else begin
            stop_sig_ff <= stop_sig_ff;
        end
    end
end

//////////////////////////////////////////////////////////////////////////////////////////

//                              DONE . k = k+1
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        k <= 12'h000;
    end
    else begin
        if (state == DONE) begin
            if (k < 2457) begin
                k <= k + 12'h001;
            end
            else begin
                k <= 12'd0;
            end
        end
        else if (state == IDLE) begin
            k <= 12'h000;
        end
        else begin
            k <= k;
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        cnt_d <= 12'h00;
    end
    else begin
        if (state == SOC_DONE) begin
            if ((cnt_d < 12'h3f3) && (clk_en == 1'b1)) //12'da
                cnt_d <= cnt_d + 12'h01;
            else
                cnt_d <= cnt_d;
        end
        else begin
            cnt_d <= 12'h00;
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        cnt_1 <= 5'h0;
    end
    else begin
        if (state == LATENCY_1) begin
            if (cnt_1 < 5'h0b)
                cnt_1 <= cnt_1 + 5'h1;
            else
                cnt_1 <= 5'h0;
        end
        else begin
            cnt_1 <= 5'h0;
        end
    end
end
assign la1_done = (cnt_1 == 5'h0a) ? 1'b1 : 1'b0;
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        cnt_2 <= 5'h0;
        la2_done <= 1'b0;
    end
    else begin
        if (state == LATENCY_2) begin
            cnt_2 <= cnt_2 + 5'h1;
            if (cnt_2 == 5'h0a) 
                la2_done <= 1'b1;
            else
                la2_done <= 1'b0;
        end
        else begin
            cnt_2 <= 5'h0;
            la2_done <= 1'b0;
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        cnt_3 <= 6'h00;
        la3_done <= 1'b0;
    end
    else begin
        if (state == LATENCY_3) begin
            cnt_3 <= cnt_3 + 6'h01;
            if (cnt_3 == 6'd50)
                la3_done <= 1'b1;
            else
                la3_done <= 1'b0;
        end
        else begin
            cnt_3 <= 6'h00;
            la3_done <= 1'b0;
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        cnt_4 <= 8'h0;
        la4_done <= 1'b0;
    end
    else begin
        if (state == LATENCY_4) begin
            cnt_4 <= cnt_4 + 5'h1;
            if (cnt_4 == 8'h1f)
                la4_done <= 1'b1;
            else
                la4_done <= 1'b0;
        end
        else begin
            cnt_4 <= 5'h0;
            la4_done <= 1'b0;
        end
    end
end

//////////////////////////////////////////////////////////////////////////////////////////
//                               LATENCY 1
//////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        p1_p_reg <= {D_WIDTH{1'b0}};
        p2_p_reg <= {D_WIDTH{1'b0}};
        p3_p_reg <= {D_WIDTH{1'b0}};
        p4_p_reg <= {D_WIDTH{1'b0}};
    end
    else begin
        if (state == LATENCY_1) begin
            p1_p_reg <= p1_p_wire;
            p2_p_reg <= p2_p_wire;
            p3_p_reg <= p3_p_wire;
            p4_p_reg <= p4_p_wire;
        end
        else begin
            p1_p_reg <= p1_p_reg;
            p2_p_reg <= p2_p_reg;
            p3_p_reg <= p3_p_reg;
            p4_p_reg <= p4_p_reg;
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        x_soc_p_reg <= {D_WIDTH{1'b0}};
    end
    else begin
        if (state == LATENCY_1) begin
            x_soc_p_reg <= x_soc_p_wire;
        end
        else begin
            x_soc_p_reg <= x_soc_p_reg;
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        x_rc_p_reg <= {D_WIDTH{1'b0}};
    end
    else begin
        if (state == LATENCY_1) begin
            x_rc_p_reg <= x_rc_p_wire;
        end
        else begin
            x_rc_p_reg <= x_rc_p_reg;
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        x_vt_hat_reg <= {D_WIDTH{1'b0}};
    end
    else begin
        if (state == LATENCY_1) begin
            x_vt_hat_reg <= x_vt_hat_wire;
        end
        else begin
            x_vt_hat_reg <= x_vt_hat_reg;
        end
    end
end

//////////////////////////////////////////////////////////////////////////////////////////
//                               LATENCY 2
//////////////////////////////////////////////////////////////////////////////////////////

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        k1_up_reg <= {D_WIDTH{1'b0}};
    end
    else begin
        if (state == LATENCY_2) begin
            k1_up_reg <= k1_up_wire;
        end
        else begin
            k1_up_reg <= k1_up_reg;
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        k2_up_reg <= {D_WIDTH{1'b0}};
    end
    else begin
        if (state == LATENCY_2) begin
            k2_up_reg <= k2_up_wire;
        end
        else begin
            k2_up_reg <= k2_up_reg;
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        k_bottom_reg <= {D_WIDTH{1'b0}};
    end
    else begin
        if (state == LATENCY_2) begin
            k_bottom_reg <= k_bottom_wire;
        end
        else begin
            k_bottom_reg <= k_bottom_reg;
        end
    end
end

//////////////////////////////////////////////////////////////////////////////////////////
//                               LATENCY 3
//////////////////////////////////////////////////////////////////////////////////////////

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        k_1_reg <= {D_WIDTH{1'b0}};
    end
    else begin
        if (state == LATENCY_3) begin
            //k_1_reg <= ((div_done == 1'b1) && (cnt_3 == 6'h31)) ? k_1_wire : k_1_reg;
            k_1_reg <= (div_done == 1'b1) ? k_1_wire : k_1_reg;
        end
        else begin
            k_1_reg <= k_1_reg;
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        k_2_reg <= {D_WIDTH{1'b0}};
    end
    else begin
        if (state == LATENCY_3) begin
            //k_2_reg <= ((div_done == 1'b1) && (cnt_3 == 6'h31)) ? k_2_wire : k_2_reg;
            k_2_reg <= (div_done == 1'b1) ? k_2_wire : k_2_reg;
        end
        else begin
            k_2_reg <= k_2_reg;
        end
    end
end

//////////////////////////////////////////////////////////////////////////////////////////
//                               LATENCY 4
//////////////////////////////////////////////////////////////////////////////////////////

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        x_soc_reg <= {D_WIDTH{1'b0}};
    end
    else begin
        if (k == 12'h0) begin //2455
            x_soc_reg <= first_soc;
        end
        else if (state == LATENCY_4) begin
            x_soc_reg <= x_soc_wire; 
        end
        else begin
            x_soc_reg <= x_soc_reg;
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        x_rc_reg <= {D_WIDTH{1'b0}};
    end
    else begin
        if (k == 12'h0) begin //2455
            x_rc_reg <= first_vrc;
        end
        else if (state == LATENCY_4) begin
            x_rc_reg <= x_rc_wire;
        end
        else begin
            x_rc_reg <= x_rc_reg;
        end
    end
end

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        p1_reg <= {D_WIDTH{1'b0}};
        p2_reg <= {D_WIDTH{1'b0}};
        p3_reg <= {D_WIDTH{1'b0}};
        p4_reg <= {D_WIDTH{1'b0}};
    end
    else begin
        if (k == 12'h0) begin //2455
            p1_reg <= first_p1;
            p2_reg <= first_p2;
            p3_reg <= first_p3;
            p4_reg <= first_p4;
        end
        else if (state == LATENCY_4) begin
            p1_reg <= p1_wire;
            p2_reg <= p2_wire;
            p3_reg <= p3_wire;
            p4_reg <= p4_wire;
        end
        else begin
            p1_reg <= p1_reg;
            p2_reg <= p2_reg;
            p3_reg <= p3_reg;
            p4_reg <= p4_reg;
        end
    end
end



//------------------------------
//----------LATENCY 1-----------
//------------------------------

alu_2 #(
        .DW_A(24),
        .INT_A(0),
        .DW_B(5),
        .INT_B(4),
        .DW_C(24),
        .INT_C(7)
    ) u_alu_2_x_soc_p (
        .clk(clk),
        .n_rst(n_rst),
        .din_a(b_1),
        .din_b(i_b),
        .din_c(x_soc_reg),
        .dout(x_soc_p_wire_ext)
    );

alu_xrc_p #(
    . DW_A(24),
    . INT_A(0),
    . DW_B(24),
    . INT_B(0),
    . DW_C(24),
    . INT_C(0),
    . DW_D(5),
    . INT_D(4),
    . DW_E(24),
    . INT_E(0)
) u_alu_xrc_p (
    .clk(clk),
    .n_rst(n_rst),
    .bef_x_rc(x_rc_reg),
    .i_b(i_b),
    .a_4(a_4),
    .b_2(b_2),
    .x_rc_p(x_rc_p_wire)
);

alu_3 #(
        .DW_A(24),
        .INT_A(0),
        .DW_B(24),
        .INT_B(0),
        .DW_C(24),
        .INT_C(0)
    ) u_alu_2_p4_p (
        .clk(clk),
        .n_rst(n_rst),
        .din_a(a_4_2),
        .din_b(p4_reg),
        .din_c(Q_4),
        .dout(p4_p_wire_ext)
);

add #(
    .SIGN_BIT(SIGN),
    .INT_BIT(INT_CASE1), // 0
    .FLT_BIT(FR_CASE1)   // 23
) u_adder_p1_p (
    .din_a(p1_reg),
    .din_b(Q_1),
    .dout(p1_p_wire_ext) // SIGN_INT_B+1_FLT_B => DW_B+1
);

mul #(
    .D_WIDTH1(D_WIDTH),
    .D_WIDTH2(D_WIDTH)
) u_multiple_p2_p
(
    .clk(clk),
    .n_rst(n_rst),
    .mul_a(p2_reg),
    .mul_b(a_4), 
    .mul_out(p2_p_wire_ext) // SIGN_INT_B+INT_C+1_FLT_B+FLT_C-1
);

mul #(
    .D_WIDTH1(D_WIDTH),
    .D_WIDTH2(D_WIDTH)
) u_multiple_p3_p
(
    .clk(clk),
    .n_rst(n_rst),
    .mul_a(p3_reg),
    .mul_b(a_4), 
    .mul_out(p3_p_wire_ext) // SIGN_INT_B+INT_C+1_FLT_B+FLT_C-1
);

alu_x_vt_hat #(
    . DW_A (24),
    . INT_A(0),
    . DW_B(24),
    . INT_B(7),
    . DW_C(24),
    . INT_C(2),
    . DW_D(24),
    . INT_D(0),
    . DW_E(24),
    . INT_E(0),
    . DW_F(24),
    . INT_F(0),
    . DW_G(5),
    . INT_G(4)    
) u_alu_x_vt_hat (
    .clk(clk),
    .n_rst(n_rst),
    .theta4(theta4),
    .i_b(i_b),
    .x_soc(x_soc_reg),
    .theta5(theta5),
    .a_4(a_4),
    .x_rc(x_rc_reg),
    .dt_cd_ri(dt_cd_ri),
    .x_vt_hat(x_vt_hat_wire)
);

//------------------------------
//----------LATENCY 2-----------
//------------------------------

alu_3 #(
        .DW_A(24),
        .INT_A(0),
        .DW_B(24),
        .INT_B(0),
        .DW_C(24),
        .INT_C(0)
    ) u_alu_2_k1_up (
        .clk(clk),
        .n_rst(n_rst),
        .din_a(p1_p_reg),
        .din_b(h_1),
        .din_c(~p2_p_reg + 1'b1),
        .dout(k1_up_wire_ext)
    );

alu_3 #(
        .DW_A(24),
        .INT_A(0),
        .DW_B(24),
        .INT_B(0),
        .DW_C(24),
        .INT_C(0)
    ) u_alu_2_k2_up (
        .clk(clk),
        .n_rst(n_rst),
        .din_a(p3_p_reg),
        .din_b(h_1),
        .din_c(~p4_p_reg + 1'b1),
        .dout(k2_up_wire_ext)
    );


K_bottom #(
    .DW_A(24),
    .INT_A(0),
    .DW_B(24),
    .INT_B(0),
    .DW_C(24),
    .INT_C(0),
    .DW_D(24),
    .INT_D(0),
    .DW_E(24),
    .INT_E(0),
    .INT_F(0),
    .DW_F(24)
) u_k_bottom (
    .clk(clk),
    .n_rst(n_rst),
    .h_1(h_1),
    .p1_p(p1_p_reg),
    .p2_p(p2_p_reg),
    .p3_p(p3_p_reg),
    .p4_p(p4_p_reg),
    .r(R),
    .k_bottom(k_bottom_wire)
);

//------------------------------
//----------LATENCY 3-----------
//------------------------------
wire div_start;
assign div_start = ((state == LATENCY_3) && (cnt_3 == 6'h00)) ? 1'b1 : 1'b0;


K_alu #(
	.DW_1(48),
	.INT_1(0),
	.DW_2(48),
	.INT_2(0),
	.DW_B(24),
	.INT_B(0)
) u_K_alu (
	.clk(clk),
	.n_rst(n_rst),
	.start(div_start),
	.k1_up(k1_up_reg),
	.k2_up(k2_up_reg),
	.k_bottom(k_bottom_reg),
	.k_1(k_1_wire),
	.k_2(k_2_wire),
    .div_done(div_done)
);


//------------------------------
//----------LATENCY 4-----------
//------------------------------
//x_soc
// 1 4 20
wire [24:0] sub_hat;

add #(
    .SIGN_BIT(SIGN),
    .INT_BIT(3),
    .FLT_BIT(20)
) u_adder_sub_hat
(
    .din_a(v_t), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B
    .din_b(~(x_vt_hat_reg) + 1'b1), //din_c 맞춰주는 설정
    .dout(sub_hat) // 1 4 20
);

mul #(
    .D_WIDTH1(D_WIDTH),
    .D_WIDTH2(25)
) u_multiple_k_1_sub_hat
(
    .clk(clk),
    .n_rst(n_rst),
    .mul_a(k_1_reg),     // 1 3 20
    .mul_b(sub_hat),     // 1  4 20
    .mul_out(x_soc_ext_1) // SIGN_INT_B+INT_C+1_FLT_B+FLT_C-1    //1 7 40
);


add #(
    .SIGN_BIT(SIGN),
    .INT_BIT(7),
    .FLT_BIT(40)
) u_adder_x_soc
(
    .din_a(x_soc_ext_1), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B
    .din_b({x_soc_p_reg,{24{1'b0}}}), //din_c 맞춰주는 설정
    .dout(x_soc_ext_2) // 1 8 16
);


mul #(
    .D_WIDTH1(D_WIDTH),
    .D_WIDTH2(25)
) u_multiple_k_2_sub_hat
(
    .clk(clk),
    .n_rst(n_rst),
    .mul_a(k_2_reg),     // 1 0 23
    .mul_b(sub_hat),     // 1  4 20
    .mul_out(x_rc_ext_1) // SIGN_INT_B+INT_C+1_FLT_B+FLT_C-1    1 4 43
);

add #(
    .SIGN_BIT(SIGN),
    .INT_BIT(4),
    .FLT_BIT(43)
) u_adder_x_rc
(
    .din_a(x_rc_ext_1), //din_b 기준으로 설정 정수bit이 0이 아닌친구 SIGN_INT_B_FLT_B
    .din_b({x_rc_p_reg[D_WIDTH-1],{4{x_rc_p_reg[D_WIDTH-1]}},x_rc_p_reg[D_WIDTH-2:0],{20{1'b0}}}), //din_c 맞춰주는 설정
    .dout(x_rc_ext_2) // SIGN_INT_B+1_FLT_B => DW_B+1 1 5 43
);

// p1, p2, p3, p4
alu_p_1to4 #(
    .DW_A(24),
    //p1_p
    .INT_A(0),
    .DW_B(24),
    //k_1
    .INT_B(3),
    .DW_C(24),
    //h_1
    .INT_C(0),
    .DW_D(24),
    //p3_p
    .INT_D(0),
    //p2_p
    .DW_E(24),
    .INT_E(0),
    //p4_p
    .DW_F(24),
    .INT_F(0),
    //k_2
    .DW_G(24),
    .INT_G(0)
) u_alu_p_1to4 (
    .clk(clk),
    .n_rst(n_rst),
    .p1_p(p1_p_reg),
    .p3_p(p3_p_reg),
    .p2_p(p2_p_reg),
    .p4_p(p4_p_reg),
    .k_1(k_1_reg),
    .k_2(k_2_reg),
    .h_1(h_1),
    .p_1(p1_wire),
    .p_2(p2_wire),
    .p_3(p3_wire),
    .p_4(p4_wire)
);

//------------------------------
//-------------DONE-------------
//------------OUTPUT------------
//------------------------------
reg [D_WIDTH-1:0] ekf_soc_d;
reg [D_WIDTH-1:0] ekf_vrc_d;
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        ekf_soc_d <= {D_WIDTH{1'b0}};
        ekf_vrc_d <= {D_WIDTH{1'b0}};
    end
    else begin
        if (state == SOC_DONE) begin
            ekf_soc_d <= x_soc_reg;
            ekf_vrc_d <= x_rc_reg;
        end
        else begin
            ekf_soc_d <= ekf_soc_d;
            ekf_vrc_d <= ekf_vrc_d;
        end
    end
end

wire [6:0] soc_99;
assign soc_99 = ekf_soc_d[22:16];

assign ekf_soc = ekf_soc_d;
assign ekf_vrc = ekf_vrc_d;
assign ekf_done = (state == DONE) ? 1'b1 : 1'b0;


endmodule   