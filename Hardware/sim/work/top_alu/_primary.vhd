library verilog;
use verilog.vl_types.all;
entity top_alu is
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        k1_up           : in     vl_logic_vector(23 downto 0);
        k2_up           : in     vl_logic_vector(23 downto 0);
        k_bottom        : in     vl_logic_vector(23 downto 0);
        k_1             : out    vl_logic_vector(23 downto 0);
        k_2             : out    vl_logic_vector(23 downto 0);
        div_done        : out    vl_logic
    );
end top_alu;
