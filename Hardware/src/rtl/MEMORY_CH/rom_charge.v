`timescale 1ps/1ps

module rom_charge #(
    parameter D_WIDTH,
    parameter A_WIDTH,
    parameter SELECT
    )(
	clk,
    n_rst,
	raddr,
	data_out
);



input	                   clk, n_rst;

input	    [A_WIDTH-1:0]  raddr;

output reg	    [D_WIDTH-1:0]  data_out;


reg [D_WIDTH-1:0]           rom_ib [0 : 2**A_WIDTH-1];
reg [D_WIDTH-1:0]           rom_vt [0 : 2**A_WIDTH-1];
reg [D_WIDTH-1:0]           rom [0 : 2**A_WIDTH-1];


initial begin
    case (SELECT)
        0: $readmemb("../src/rtl/MEMORY_CH/ib.txt", rom_ib);
        1: $readmemb("../src/rtl/MEMORY_CH/vt.txt", rom_vt);
        default: $readmemb("../src/rtl/MEMORY_CH/soc.txt", rom);
    endcase
end

always @(posedge clk or negedge n_rst) begin
    if (SELECT == 0) begin
            data_out <= rom_ib[raddr];
    end
    else if (SELECT == 1) begin
            data_out <= rom_vt[raddr];
    end
    else begin
            data_out <= rom[raddr];
    end
end


endmodule