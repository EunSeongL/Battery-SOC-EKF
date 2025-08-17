library verilog;
use verilog.vl_types.all;
entity div is
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        Q               : in     vl_logic_vector(47 downto 0);
        M               : in     vl_logic_vector(47 downto 0);
        start           : in     vl_logic;
        remain          : out    vl_logic_vector(47 downto 0);
        value           : out    vl_logic_vector(47 downto 0);
        done            : out    vl_logic
    );
end div;
