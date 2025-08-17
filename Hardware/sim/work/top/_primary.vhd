library verilog;
use verilog.vl_types.all;
entity top is
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        start           : in     vl_logic;
        mode            : in     vl_logic;
        stop_top        : in     vl_logic;
        ekf_vrc         : out    vl_logic_vector(23 downto 0);
        ekf_soc         : out    vl_logic_vector(23 downto 0);
        ekf_done        : out    vl_logic;
        fnd_out_1       : out    vl_logic_vector(6 downto 0);
        fnd_out_10      : out    vl_logic_vector(6 downto 0)
    );
end top;
