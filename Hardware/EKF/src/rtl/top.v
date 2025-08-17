`timescale 1ps/1ps

module top (
    clk,
    n_rst,
    start,
    mode,   //mode = 1 charge
    stop_top,
    ekf_vrc,
    ekf_soc,
    ekf_done,
    // FPGA
    fnd_out_1,
    fnd_out_10
    //led_1,
);
    
input clk;
input n_rst;
input start;
input mode;
input stop_top;
output [23:0] ekf_vrc;
output [23:0] ekf_soc;
output ekf_done;
//    FPGA
output [6:0] fnd_out_1, fnd_out_10;

wire start_ch, start_dis;
assign start_ch = ((mode == 1'b1) && (start == 1'b1)) ? 1'b1 : 1'b0;
assign start_dis = ((mode == 1'b0) && (start == 1'b1)) ? 1'b1 : 1'b0;

wire stop_ch, stop_dis;
assign stop_ch = ((mode == 1'b1) && (stop_top == 1'b1)) ? 1'b1 : 1'b0;
assign stop_dis = ((mode == 1'b0) && (stop_top == 1'b1)) ? 1'b1 : 1'b0;

/*
reg g_clk;

always @ (posedge clk or negedge n_rst) begin
    if(!n_rst) begin
        g_clk <= 1'b0;
    end
    else begin
        g_clk <= ~g_clk;
    end
end
*/
//charge mode
wire [23:0] ekf_soc_data_ch;
wire [23:0] ekf_vrc_ch;
wire ekf_done_ch;
ekf_charge u_ekf_charge (
    .clk(clk),
    .n_rst(n_rst),
    .start(start_ch),
    .stop_sig(stop_ch),
    .ekf_vrc(ekf_vrc_ch),
    .ekf_soc(ekf_soc_data_ch),
    .ekf_done(ekf_done_ch)
);

//discharge mode
wire [23:0] ekf_soc_data_dis;
wire [23:0] ekf_vrc_dis;
wire ekf_done_dis;
ekf_discharge u_ekf_discharge (
    .clk(clk),
    .n_rst(n_rst),
    .start(start_dis),
    .stop_sig(stop_dis),
    .ekf_vrc(ekf_vrc_dis),
    .ekf_soc(ekf_soc_data_dis),
    .ekf_done(ekf_done_dis)
);



wire [6:0]  soc_int;
wire [7:0]  soc_int_fnd;
assign soc_int = (mode == 1'b1) ? ekf_soc_data_ch[22:16] : ekf_soc_data_dis[22:16];

soc_decoder u_soc_decoder (
    .clk(clk),
    .n_rst(n_rst),
    .soc_int(soc_int),
    .soc_int_fnd(soc_int_fnd)
);


fnd_decoder u_fnd_decoder (
    .clk(clk),
    .n_rst(n_rst),
    .soc_int(soc_int_fnd),
    .fnd_out_1(fnd_out_1),
    .fnd_out_10(fnd_out_10)
);


assign ekf_soc = (mode == 1'b1) ? ekf_soc_data_ch : ekf_soc_data_dis;
assign ekf_vrc = (mode == 1'b1) ? ekf_vrc_ch : ekf_vrc_dis;
assign ekf_done = (mode == 1'b1) ? ekf_done_ch : ekf_done_dis;
endmodule

/* 

module ekf (
    clk,
    n_rst,
    //i_b,
    //v_t,
    start,
    ekf_vrc,
    ekf_soc,
    ekf_done
);


*/