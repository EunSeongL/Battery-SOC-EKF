library verilog;
use verilog.vl_types.all;
entity top_div is
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        Q               : in     vl_logic_vector(23 downto 0);
        M               : in     vl_logic_vector(23 downto 0);
        start           : in     vl_logic;
        value           : out    vl_logic_vector(23 downto 0);
        remain          : out    vl_logic_vector(23 downto 0);
        done            : out    vl_logic
    );
end top_div;
