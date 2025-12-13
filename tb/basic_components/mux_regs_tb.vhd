library ieee;
use ieee.numeric_bit.all;
use work.regfile_pkg.all;

entity mux_regs_tb is
end entity mux_regs_tb;

architecture test of mux_regs_tb is

    -- Simulation Constants
    constant T_DELAY    : time := 10 ns;
    constant DATA_WIDTH : natural := 64; -- Matches the poliLEGv8 64-bit width

    -- Signals for connection
    signal s_inputs : reg_array_t := (others => (others => '0'));
    signal s_sel    : bit_vector(4 downto 0) := (others => '0');
    signal s_dOut   : bit_vector(DATA_WIDTH-1 downto 0);

begin

    dut: entity work.mux_regs
        generic map (
            dataSize => DATA_WIDTH
        )
        port map (
            inputs => s_inputs,
            sel    => s_sel,
            dOut   => s_dOut
        );

    stim_proc: process
    begin
        report "==============================================================";
        report "         START OF SIMULATION: 32-to-1 MULTIPLEXER             ";
        report "==============================================================";

        -- Setup: Fill the input array with distinct values to verify selection.
        -- We use the index 'i' to create a unique pattern for each input.
        -- Example: Input 0 = 0...00, Input 1 = 0...01, Input 5 = 0...05, etc.
        for i in 0 to 31 loop
            s_inputs(i) <= bit_vector(to_unsigned(i, DATA_WIDTH));
        end loop;

        wait for T_DELAY;
        -- Loop through all 32 possible selection values
        for i in 0 to 31 loop
            -- Apply the selector
            s_sel <= bit_vector(to_unsigned(i, 5));
            
            wait for T_DELAY;

            -- Check if Output matches Input[i]
            assert s_dOut = s_inputs(i)
                report "FAILURE at Index " & integer'image(i) & 
                       ". Expected: " & integer'image(i) & 
                       " but got a different value."
                severity error;
        end loop;

        -- Test Case: Verify with a specific large value
        report "Test Case: Large Value at Index 15";
        s_inputs(15) <= (others => '1'); -- All 1s (FFFF...)
        s_sel        <= "01111";         -- Select index 15
        wait for T_DELAY;
        
        assert s_dOut = (s_dOut'range => '1')
            report "FAILURE: Did not pass large value correctly."
            severity error;

        report "==============================================================";
        report " END OF SIMULATION: Mux tests completed.";
        report "==============================================================";
        wait;
    end process;

end architecture test;