library verilog;
use verilog.vl_types.all;
entity data_width is
    port(
        sign            : in     vl_logic;
        int_bit         : in     vl_logic_vector(3 downto 0);
        flt_bit         : in     vl_logic_vector(4 downto 0);
        d_width         : out    vl_logic_vector(4 downto 0)
    );
end data_width;
