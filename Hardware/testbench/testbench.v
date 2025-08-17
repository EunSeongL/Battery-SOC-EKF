`timescale 1ps/1ps

module testbench (); 

//reg [23:0] v_t;
//reg [4:0] i_b;
reg clk, n_rst;
reg start;
reg mode;
reg stop_top;
//wire [23:0] ekf_soc, ekf_vrc;
wire [23:0] ekf_vrc;
wire [23:0] ekf_soc;      
wire ekf_done;
wire [6:0] fnd_out_1, fnd_out_10;



top u_top(
    .clk(clk),
    .n_rst(n_rst),
    .start(start),
    .mode(mode),
    .stop_top(stop_top),
    .ekf_vrc(ekf_vrc),
    .ekf_soc(ekf_soc),
    .ekf_done(ekf_done),
    // FPGA
    .fnd_out_1(fnd_out_1),
    .fnd_out_10(fnd_out_10)
);



always #5 clk = ~clk;
    initial begin
        clk = 1'b0;
        n_rst = 1'b0;
        #7 n_rst = 1'b1;
    end

initial begin
        start = 1'b0;
        mode = 1'b0;
        stop_top = 1'b0;
        //i_b = 5'h00;
        //v_t = 24'h0;

        #20;
        start = 1'b1;
        //i_b = 5'h0a;                              //10
        //v_t = 24'b0_100_0010_0000_0000_0000_0000; //4.125
        #10;
        start = 1'b0;
        #798701; //1580000
        stop_top = 1'b1;
        #10;
        stop_top = 1'b0;
        #1000000;
        start = 1'b1;
        #10;
        start = 1'b0;
        #919195;
        stop_top = 1'b1;
        #10;
        stop_top = 1'b0;
        #1100000;
        start = 1'b1;
        #10;
        start = 1'b0;
        #4000000;

        mode = 1'b1;
        #10;
        start = 1'b1;
        //i_b = 5'h0a;                              //10
        //v_t = 24'b0_100_0010_0000_0000_0000_0000; //4.125
        #10;
        start = 1'b0;
        #10000

        $stop;
    end


endmodule

