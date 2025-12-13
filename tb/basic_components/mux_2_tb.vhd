library ieee;
use ieee.numeric_bit.all;

entity mux_n_tb is
end entity mux_n_tb;

architecture test of mux_n_tb is
    -- Constants
    constant TEST_WIDTH : natural := 8;
    constant TIME_DELAY : time := 10 ns;
    
    -- Signals to connect to the DUT (Device Under Test)
    signal in0_s  : bit_vector(TEST_WIDTH-1 downto 0);
    signal in1_s  : bit_vector(TEST_WIDTH-1 downto 0);
    signal sel_s  : bit;
    signal dOut_s : bit_vector(TEST_WIDTH-1 downto 0);

begin

    DUT: entity work.mux_n
    generic map (
        dataSize => TEST_WIDTH -- Overriding generic to 8 bits for testing
    )
    port map (
        in0  => in0_s,
        in1  => in1_s,
        sel  => sel_s,
        dOut => dOut_s
    );

    test_process: process
        -- Helper function to convert integer to bit_vector
        function to_bv(val : integer) return bit_vector is
        begin
            return bit_vector(to_unsigned(val, TEST_WIDTH));
        end function;

    begin
        report "=========================================";
        report "Starting Simulation: Multiplexer (Size " & integer'image(TEST_WIDTH) & ")";
        report "=========================================";

        -- Initialize inputs
        in0_s <= to_bv(10); -- Binary: 00001010
        in1_s <= to_bv(20); -- Binary: 00010100
        sel_s <= '0';
        wait for TIME_DELAY;

        -- Case 1: Select in0 (sel = '0')
        assert dOut_s = in0_s
            report "Error: sel=0 should select in0." severity error;
        
        report "Test 1 Passed: Selected in0 (Value: " & integer'image(to_integer(unsigned(dOut_s))) & ")";

        -- Case 2: Select in1 (sel = '1')
        sel_s <= '1';
        wait for TIME_DELAY;

        assert dOut_s = in1_s
            report "Error: sel=1 should select in1." severity error;

        report "Test 2 Passed: Selected in1 (Value: " & integer'image(to_integer(unsigned(dOut_s))) & ")";

        -- Case 3: Change Data while sel is stable
        -- sel is still '1', so changing in1 should update output immediately
        in1_s <= to_bv(255);
        wait for TIME_DELAY;

        assert dOut_s = to_bv(255)
            report "Error: Output did not update when input changed." severity error;

        report "Test 3 Passed: Dynamic update verified.";

        -- End Simulation
        report "=========================================";
        report "Simulation Completed Successfully.";
        report "=========================================";
        wait;
    end process;

end architecture test;