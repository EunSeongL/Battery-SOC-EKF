library verilog;
use verilog.vl_types.all;
entity alu_2 is
    generic(
        DW_A            : integer := 24;
        INT_A           : integer := 0;
        DW_B            : integer := 24;
        INT_B           : integer := 0;
        DW_C            : integer := 24;
        INT_C           : integer := 0
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        din_a           : in     vl_logic_vector;
        din_b           : in     vl_logic_vector;
        din_c           : in     vl_logic_vector;
        dout            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DW_A : constant is 1;
    attribute mti_svvh_generic_type of INT_A : constant is 1;
    attribute mti_svvh_generic_type of DW_B : constant is 1;
    attribute mti_svvh_generic_type of INT_B : constant is 1;
    attribute mti_svvh_generic_type of DW_C : constant is 1;
    attribute mti_svvh_generic_type of INT_C : constant is 1;
end alu_2;
