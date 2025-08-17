library verilog;
use verilog.vl_types.all;
entity div_d is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        M               : in     vl_logic_vector(47 downto 0);
        Q               : in     vl_logic_vector(47 downto 0);
        start           : in     vl_logic;
        done            : out    vl_logic;
        result_r        : out    vl_logic_vector(47 downto 0);
        result_p        : out    vl_logic_vector(47 downto 0)
    );
end div_d;
