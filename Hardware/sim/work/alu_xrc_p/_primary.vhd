library verilog;
use verilog.vl_types.all;
entity alu_xrc_p is
    generic(
        DW_A            : integer := 24;
        INT_A           : integer := 0;
        DW_B            : integer := 24;
        INT_B           : integer := 0;
        DW_C            : integer := 24;
        INT_C           : integer := 0;
        DW_D            : integer := 5;
        INT_D           : integer := 4;
        DW_E            : integer := 24;
        INT_E           : integer := 0
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        bef_x_rc        : in     vl_logic_vector;
        i_b             : in     vl_logic_vector;
        a_4             : in     vl_logic_vector;
        b_2             : in     vl_logic_vector;
        x_rc_p          : out    vl_logic_vector(23 downto 0)
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
end alu_xrc_p;
