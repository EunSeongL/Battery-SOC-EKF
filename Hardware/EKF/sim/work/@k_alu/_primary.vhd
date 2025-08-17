library verilog;
use verilog.vl_types.all;
entity K_alu is
    generic(
        DW_1            : integer := 48;
        INT_1           : integer := 0;
        DW_2            : integer := 48;
        INT_2           : integer := 0;
        DW_B            : integer := 24;
        INT_B           : integer := 0
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        start           : in     vl_logic;
        k1_up           : in     vl_logic_vector;
        k2_up           : in     vl_logic_vector;
        k_bottom        : in     vl_logic_vector;
        k_1             : out    vl_logic_vector(23 downto 0);
        k_2             : out    vl_logic_vector(23 downto 0);
        div_done        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DW_1 : constant is 1;
    attribute mti_svvh_generic_type of INT_1 : constant is 1;
    attribute mti_svvh_generic_type of DW_2 : constant is 1;
    attribute mti_svvh_generic_type of INT_2 : constant is 1;
    attribute mti_svvh_generic_type of DW_B : constant is 1;
    attribute mti_svvh_generic_type of INT_B : constant is 1;
end K_alu;
