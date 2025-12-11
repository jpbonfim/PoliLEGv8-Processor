library ieee;
use ieee.numeric_bit.all;

entity reg_tb is 
    -- Override the generic for testing purposes
    generic (dataSize : natural := 8); 
end entity reg_tb;

architecture behavioral of reg_tb is

    -- Signals to connect to the DUT
    signal clk_in    : bit := '0';
    signal rst_in    : bit := '0';
    signal enable_in : bit := '0';
    signal d_in      : bit_vector(dataSize-1 downto 0) := (others => '0');
    signal q_out     : bit_vector(dataSize-1 downto 0);

    -- Simulation Control
    signal sim_running : boolean := true;
    constant CLK_PERIOD : time := 10 ns;

    -- Helper Constants
    constant ZEROS : bit_vector(dataSize-1 downto 0) := (others => '0');
    constant ONES  : bit_vector(dataSize-1 downto 0) := (others => '1');

begin

    DUT: entity work.reg
    generic map (
        dataSize => dataSize
    )
    port map (
        clock  => clk_in,
        reset  => rst_in,
        enable => enable_in,
        d      => d_in,
        q      => q_out
    );

    -- Clock Generator
    clk_process: process
    begin
        while sim_running loop
            clk_in <= '0';
            wait for CLK_PERIOD / 2;
            clk_in <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulus Process
    stimulus_proc: process
        -- Helper function to convert bit_vector to string for reporting
        function to_string(bv : bit_vector) return string is
        begin
            return integer'image(to_integer(unsigned(bv)));
        end function;

    begin
        report "=========================================";
        report "Starting Simulation: Register (Size " & integer'image(dataSize) & ")";
        report "=========================================";

        -- 1. Initialization
        rst_in <= '1';
        enable_in <= '0';
        d_in <= ONES; -- Apply ones to see if reset forces zero
        wait for CLK_PERIOD;

        -- 2. RESET TEST (Asynchronous)
        -- The output must be 0 immediately, regardless of clock or enable
        assert q_out = ZEROS
            report "Error: Reset failed. Output is " & to_string(q_out) & ", expected 0."
            severity error;
        
        report "Test 1: Reset verified.";
        
        -- Release reset
        rst_in <= '0';
        wait for CLK_PERIOD;

        -- 3. WRITE ENABLE TEST
        -- Enable = 1, Data should flow from D to Q on clock edge
        report "Test 2: Testing Write Operation (Enable = 1)...";
        enable_in <= '1';

        -- Case A: Write 5 (Binary 00...0101)
        d_in <= bit_vector(to_unsigned(5, dataSize));
        wait for CLK_PERIOD; -- Wait for clock edge
        
        assert q_out = bit_vector(to_unsigned(5, dataSize))
            report "Error: Write failed. Expected 5, got " & to_string(q_out)
            severity error;

        -- Case B: Write 42 (Binary ...101010)
        d_in <= bit_vector(to_unsigned(42, dataSize));
        wait for CLK_PERIOD;

        assert q_out = bit_vector(to_unsigned(42, dataSize))
            report "Error: Write failed. Expected 42, got " & to_string(q_out)
            severity error;
            
        report "Test 2: Write Operation verified.";

        -- 4. HOLD TEST (Enable = 0)
        -- Enable = 0, Q should remain 42 even if D changes to 100
        report "Test 3: Testing Hold Operation (Enable = 0)...";
        enable_in <= '0';
        d_in <= bit_vector(to_unsigned(100, dataSize)); -- Change input
        wait for CLK_PERIOD;

        assert q_out = bit_vector(to_unsigned(42, dataSize)) -- Should still be 42
            report "Error: Hold failed. Register updated when disabled! Got " & to_string(q_out)
            severity error;

        report "Test 3: Hold Operation verified.";

        -- 5. End of Simulation
        report "=========================================";
        report "Simulation Completed Successfully.";
        report "=========================================";
        sim_running <= false;
        wait;
    end process;

end architecture behavioral;