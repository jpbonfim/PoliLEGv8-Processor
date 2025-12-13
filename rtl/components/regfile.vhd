library ieee;
use ieee.numeric_bit.all;
use work.regfile_pkg.all;

entity regfile is
    port (
        clock    : in bit;
        reset    : in bit;
        regWrite : in bit;
        rr1      : in bit_vector(4 downto 0);  -- Read Address 1
        rr2      : in bit_vector(4 downto 0);  -- Read Address 2
        wr       : in bit_vector(4 downto 0);  -- Write Address
        d        : in bit_vector(63 downto 0); -- Write Data
        q1       : out bit_vector(63 downto 0);-- Read Data 1
        q2       : out bit_vector(63 downto 0) -- Read Data 2
    );
end entity regfile;

architecture structural of regfile is

    -- Internal Signals
    signal write_enables : bit_vector(31 downto 0);
    signal reg_outputs   : reg_array_t; -- Connects Registers to Muxes

begin

    ----------------------------------------------------------------------------
    -- Write Decoder
    -- Selects which register receives the 'enable' signal
    ----------------------------------------------------------------------------
    u_decoder: entity work.decoder_5x32
        port map (
            addr    => wr,
            enable  => regWrite,
            decoded => write_enables
        );

    ----------------------------------------------------------------------------
    -- Instantiates 32 registers.
    -- Logic: Registers 0-30 are standard 'reg'. Register 31 is 'reg_xzr'.
    ----------------------------------------------------------------------------
    gen_regs: for i in 0 to 31 generate
        
        -- Case A: Standard Registers (X0 to X30)
        gen_std: if i < 31 generate
            u_reg: entity work.reg
                port map (
                    clock  => clock,
                    reset  => reset,
                    enable => write_enables(i),
                    d      => d,
                    q      => reg_outputs(i)
                );
        end generate gen_std;

        -- Case B: Zero Register (X31)
        -- Uses the specific 'reg_xzr' entity
        gen_xzr: if i = 31 generate
            u_xzr: entity work.reg_xzr
                port map (
                    clock  => clock,
                    reset  => reset,
                    enable => write_enables(i),
                    d      => d,
                    q      => reg_outputs(i)
                );
        end generate gen_xzr;

    end generate gen_regs;

    ----------------------------------------------------------------------------
    -- Read Multiplexers
    -- Select the data for output ports q1 and q2
    ----------------------------------------------------------------------------
    
    -- Mux for Read Port 1 (controlled by rr1)
    u_mux1: entity work.mux_regs
        port map (
            inputs => reg_outputs,
            sel    => rr1,
            dOut   => q1
        );

    -- Mux for Read Port 2 (controlled by rr2)
    u_mux2: entity work.mux_regs
        port map (
            inputs => reg_outputs,
            sel    => rr2,
            dOut   => q2
        );

end architecture structural;