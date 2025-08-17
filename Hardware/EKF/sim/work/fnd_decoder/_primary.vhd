library verilog;
use verilog.vl_types.all;
entity fnd_decoder is
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        soc_int         : in     vl_logic_vector(7 downto 0);
        fnd_out_10      : out    vl_logic_vector(6 downto 0);
        fnd_out_1       : out    vl_logic_vector(6 downto 0)
    );
end fnd_decoder;
