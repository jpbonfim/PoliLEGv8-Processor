library ieee;
use ieee.numeric_bit.all;

entity regfile_tb is
end entity regfile_tb;

architecture test of regfile_tb is

    -- Simulation Constants
    constant T_CLK   : time := 10 ns; -- Clock Period
    constant T_DELAY : time := 2 ns;  -- Small delay for checking after edge

    -- DUT Signals
    signal s_clock    : bit := '0';
    signal s_reset    : bit := '0';
    signal s_regWrite : bit := '0';
    signal s_rr1      : bit_vector(4 downto 0) := (others => '0');
    signal s_rr2      : bit_vector(4 downto 0) := (others => '0');
    signal s_wr       : bit_vector(4 downto 0) := (others => '0');
    signal s_d        : bit_vector(63 downto 0) := (others => '0');
    signal s_q1       : bit_vector(63 downto 0);
    signal s_q2       : bit_vector(63 downto 0);

begin

    dut: entity work.regfile
        port map (
            clock    => s_clock,
            reset    => s_reset,
            regWrite => s_regWrite,
            rr1      => s_rr1,
            rr2      => s_rr2,
            wr       => s_wr,
            d        => s_d,
            q1       => s_q1,
            q2       => s_q2
        );

    -- Clock Generation Process
    clk_proc: process
    begin
        s_clock <= '0';
        wait for T_CLK / 2;
        s_clock <= '1';
        wait for T_CLK / 2;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin
        report "==============================================================";
        report "             START OF SIMULATION: REGISTER FILE               ";
        report "==============================================================";

        -- 1. Reset Sequence
        report "Test 1: Global Reset";
        s_reset <= '1';
        wait for T_CLK;
        s_reset <= '0';
        wait for T_CLK;
        
        -- Check if output is zero (assuming X0 is selected by default)
        assert s_q1 = (63 downto 0 => '0') 
            report "FAILURE [Reset]: Register output not zero after reset." severity error;

        -- 2. Basic Write and Read Verification (Register X1)
        report "Test 2: Write 0xAAAA... to X1 and Read Back";
        s_regWrite <= '1';                  -- Enable Write
        s_wr       <= "00001";              -- Address X1
        s_d        <= (others => '1');      -- Data: All 1s initially
        s_d(1)     <= '0';                  -- Make it distinctive
        wait until s_clock = '1'; wait for T_DELAY; -- Wait for write edge
        
        s_regWrite <= '0';                  -- Disable Write
        s_rr1      <= "00001";              -- Read X1 on Port 1
        wait for T_DELAY; -- Wait for async read
        
        assert s_q1 = s_d 
            report "FAILURE [Write X1]: Data mismatch on Port 1." severity error;

        -- 3. Write Disable Verification
        report "Test 3: Try to Write to X1 with RegWrite='0' (Should Fail)";
        s_regWrite <= '0';                  -- Disable Write
        s_wr       <= "00001";              -- Address X1
        s_d        <= (others => '0');      -- New Data (All 0s)
        wait until s_clock = '1'; wait for T_DELAY;
        
        -- The value in X1 should REMAIN the old value (from Test 2)
        -- It should NOT have updated to the new 'All 0s' value.
        assert s_q1 /= (63 downto 0 => '0') 
            report "FAILURE [Write Disable]: Data was written even with RegWrite=0." severity error;

        -- 4. Dual Port Read Verification
        report "Test 4: Read different registers on Port 1 (X1) and Port 2 (X2)";
        -- First, write something to X2
        s_regWrite <= '1';
        s_wr       <= "00010";              -- Address X2
        s_d        <= (0 => '1', others => '0'); -- Data: 1
        wait until s_clock = '1'; wait for T_DELAY;
        s_regWrite <= '0';

        -- Now Read X1 on Port 1 and X2 on Port 2
        s_rr1 <= "00001"; -- X1 (contains large value from Test 2)
        s_rr2 <= "00010"; -- X2 (contains 1)
        wait for T_DELAY;

        assert s_q2(0) = '1' and s_q2(63) = '0'
            report "FAILURE [Dual Read]: Port 2 data incorrect." severity error;
        assert s_q1(0) = '1' and s_q1(63) = '1'
            report "FAILURE [Dual Read]: Port 1 data incorrect." severity error;

        -- 5. XZR (Register 31) Behavior Verification
        report "Test 5: XZR (X31) Hardwired Zero Test";
        
        -- Attempt to write all 1s to X31
        s_regWrite <= '1';
        s_wr       <= "11111";              -- Address 31 (XZR)
        s_d        <= (others => '1');      -- Data: All 1s
        wait until s_clock = '1'; wait for T_DELAY;
        s_regWrite <= '0';

        -- Read X31 on Port 1
        s_rr1 <= "11111"; 
        wait for T_DELAY;

        -- It MUST be zero
        assert s_q1 = (63 downto 0 => '0') 
            report "FAILURE [XZR]: Register 31 is not zero after write attempt." severity error;


        -- 6. Global reset should erase all values
        report "Test 6: Global Reset After Writings";
        s_reset <= '1';
        wait for T_CLK;
        s_reset <= '0';
        wait for T_CLK;

        -- Now Read X1 on Port 1 and X2 on Port 2
        s_rr1 <= "00001"; -- X1 (written in test 2)
        s_rr2 <= "00010"; -- X2 (written in test 4)
        wait for T_DELAY;

        assert s_q2 = (63 downto 0 => '0') 
            report "FAILURE [Dual Read]: Port 2 data incorrect." severity error;
        assert s_q1 = (63 downto 0 => '0') 
            report "FAILURE [Dual Read]: Port 1 data incorrect." severity error;
        
        report "==============================================================";
        report " END OF SIMULATION: Register File Verified.";
        report "==============================================================";
        wait;
    end process;

end architecture test;