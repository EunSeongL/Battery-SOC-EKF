`timescale 1ps/1ps

module soc_decoder (
    clk,
    n_rst,
    soc_int,
    soc_int_fnd
);
    input clk;
    input n_rst;
    input [6:0] soc_int;

    output [7:0] soc_int_fnd;

reg [3:0] soc_fnd_10, soc_fnd_1;

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        soc_fnd_10 <= 4'h0;
        soc_fnd_1 <= 4'h0;
    end
    else begin
        if (soc_int == 7'h64) begin // soc 100
            soc_fnd_10 <= 4'ha;
            soc_fnd_1 <= 4'h0;
        end
        else if ((soc_int <= 7'h63) && (soc_int >= 7'h5a)) begin // soc 99~90
            soc_fnd_10 <= 4'h9;
            soc_fnd_1 <= soc_int - 7'h5a;
        end
        else if ((soc_int <= 7'h59) && (soc_int >= 7'h50)) begin // soc 89~80
            soc_fnd_10 <= 4'h8;
            soc_fnd_1 <= soc_int - 7'h50;
        end
        else if ((soc_int <= 7'h4f) && (soc_int >= 7'h46)) begin // soc 79~70
            soc_fnd_10 <= 4'h7;
            soc_fnd_1 <= soc_int - 7'h46;
        end
        else if ((soc_int <= 7'h45) && (soc_int >= 7'h3c)) begin // soc 69~60
            soc_fnd_10 <= 4'h6;
            soc_fnd_1 <= soc_int - 7'h3c;
        end
        else if ((soc_int <= 7'h3b) && (soc_int >= 7'h32)) begin // soc 59~50
            soc_fnd_10 <= 4'h5;
            soc_fnd_1 <= soc_int - 7'h32;
        end
        else if ((soc_int <= 7'h31) && (soc_int >= 7'h28)) begin // soc 49~40
            soc_fnd_10 <= 4'h4;
            soc_fnd_1 <= soc_int - 7'h28;
        end
        else if ((soc_int <= 7'h27) && (soc_int >= 7'h1e)) begin // soc 39~30
            soc_fnd_10 <= 4'h3;
            soc_fnd_1 <= soc_int - 7'h1e;
        end
        else if ((soc_int <= 7'h1d) && (soc_int >= 7'h14)) begin // soc 29~20
            soc_fnd_10 <= 4'h2;
            soc_fnd_1 <= soc_int - 7'h14;
        end
        else if ((soc_int <= 7'h13) && (soc_int >= 7'h0a)) begin // soc 19~10
            soc_fnd_10 <= 4'h1;
            soc_fnd_1 <= soc_int - 7'h0a;
        end
        else if ((soc_int <= 7'h09) && (soc_int >= 7'h00)) begin // soc 10~00
            soc_fnd_10 <= 4'h0;
            soc_fnd_1 <= soc_int - 7'h00;
        end
        else begin
            soc_fnd_10 <= 4'h0;
            soc_fnd_1 <= 4'h0;
        end
    end
end


assign soc_int_fnd = {soc_fnd_10,soc_fnd_1};

endmodule