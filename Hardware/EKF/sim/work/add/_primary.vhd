library verilog;
use verilog.vl_types.all;
entity add is
    generic(
        SIGN_BIT        : vl_notype;
        INT_BIT         : vl_notype;
        FLT_BIT         : vl_notype
    );
    port(
        din_a           : in     vl_logic_vector;
        din_b           : in     vl_logic_vector;
        dout            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SIGN_BIT : constant is 5;
    attribute mti_svvh_generic_type of INT_BIT : constant is 5;
    attribute mti_svvh_generic_type of FLT_BIT : constant is 5;
end add;
