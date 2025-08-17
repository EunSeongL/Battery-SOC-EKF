library verilog;
use verilog.vl_types.all;
entity rom_charge is
    generic(
        D_WIDTH         : vl_notype;
        A_WIDTH         : vl_notype;
        \SELECT\        : vl_notype
    );
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        raddr           : in     vl_logic_vector;
        data_out        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of D_WIDTH : constant is 5;
    attribute mti_svvh_generic_type of A_WIDTH : constant is 5;
    attribute mti_svvh_generic_type of \SELECT\ : constant is 5;
end rom_charge;
