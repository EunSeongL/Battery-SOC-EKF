library verilog;
use verilog.vl_types.all;
entity soc_decoder is
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        soc_int         : in     vl_logic_vector(6 downto 0);
        soc_int_fnd     : out    vl_logic_vector(7 downto 0)
    );
end soc_decoder;
