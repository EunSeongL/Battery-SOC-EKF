library verilog;
use verilog.vl_types.all;
entity mul is
    generic(
        D_WIDTH1        : vl_notype;
        D_WIDTH2        : vl_notype
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        mul_a           : in     vl_logic_vector;
        mul_b           : in     vl_logic_vector;
        mul_out         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of D_WIDTH1 : constant is 5;
    attribute mti_svvh_generic_type of D_WIDTH2 : constant is 5;
end mul;
