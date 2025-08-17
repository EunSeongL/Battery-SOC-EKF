library verilog;
use verilog.vl_types.all;
entity K_bottom is
    generic(
        DW_A            : integer := 24;
        INT_A           : integer := 0;
        DW_B            : integer := 24;
        INT_B           : integer := 0;
        DW_C            : integer := 24;
        INT_C           : integer := 0;
        DW_D            : integer := 24;
        INT_D           : integer := 0;
        DW_E            : integer := 24;
        INT_E           : integer := 0;
        INT_F           : integer := 0;
        DW_F            : integer := 24
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        h_1             : in     vl_logic_vector;
        p1_p            : in     vl_logic_vector;
        p2_p            : in     vl_logic_vector;
        p3_p            : in     vl_logic_vector;
        p4_p            : in     vl_logic_vector;
        r               : in     vl_logic_vector;
        k_bottom        : out    vl_logic_vector(23 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DW_A : constant is 1;
    attribute mti_svvh_generic_type of INT_A : constant is 1;
    attribute mti_svvh_generic_type of DW_B : constant is 1;
    attribute mti_svvh_generic_type of INT_B : constant is 1;
    attribute mti_svvh_generic_type of DW_C : constant is 1;
    attribute mti_svvh_generic_type of INT_C : constant is 1;
    attribute mti_svvh_generic_type of DW_D : constant is 1;
    attribute mti_svvh_generic_type of INT_D : constant is 1;
    attribute mti_svvh_generic_type of DW_E : constant is 1;
    attribute mti_svvh_generic_type of INT_E : constant is 1;
    attribute mti_svvh_generic_type of INT_F : constant is 1;
    attribute mti_svvh_generic_type of DW_F : constant is 1;
end K_bottom;
