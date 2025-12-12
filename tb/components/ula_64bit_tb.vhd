library ieee;
use ieee.numeric_bit.all;

entity tb_ula is
end entity tb_ula;

architecture test of tb_ula is
    -- Signals to connect to the DUT
    -- Initialized to avoid undefined values at the start of simulation
    signal s_A        : bit_vector(63 downto 0) := (others => '0');
    signal s_B        : bit_vector(63 downto 0) := (others => '0');
    signal s_S        : bit_vector(3 downto 0)  := (others => '0');
    
    -- Output signals
    signal s_F        : bit_vector(63 downto 0);
    signal s_Z        : bit;
    signal s_Ov       : bit;
    signal s_Co       : bit;

    -- Simulation constants
    constant T_DELAY : time := 10 ns;

begin

    dut: entity work.ula
        port map (
            A  => s_A,
            B  => s_B,
            S  => s_S,
            F  => s_F,
            Z  => s_Z,
            Ov => s_Ov,
            Co => s_Co
        );

    stim_proc: process
    begin
        report "==============================================================";
        report "               START OF SIMULATION: 64-BIT ALU                ";
        report "==============================================================";

        ------------------------------------------------------------------------
        -- CASE 1: AND Operation (S = 0000)
        -- Bit mask test
        ------------------------------------------------------------------------
        s_S <= "0000";
        s_A <= (others => '1');           -- All bits set to 1
        s_B <= (0 => '1', others => '0'); -- Only bit 0 set to 1
        wait for T_DELAY;
        
        assert s_F(0) = '1' and s_F(63 downto 1) = (63 downto 1 => '0')
            report "FAILURE [AND]: Incorrect bit mask result." severity error;

        ------------------------------------------------------------------------
        -- CASE 2: OR Operation (S = 0001)
        -- Bit combination test
        ------------------------------------------------------------------------
        s_S <= "0001";
        s_A <= (63 => '1', others => '0'); -- MSB '1'
        s_B <= (0  => '1', others => '0'); -- LSB '1'
        wait for T_DELAY;

        assert s_F(63) = '1' and s_F(0) = '1' and s_F(62 downto 1) = (62 downto 1 => '0')
            report "FAILURE [OR]: Incorrect bit combination." severity error;

        ------------------------------------------------------------------------
        -- CASE 3: ADD Operation (S = 0010)
        -- Simple addition without overflow
        ------------------------------------------------------------------------
        s_S <= "0010";
        s_A <= (1 => '1', 0 => '1', others => '0'); -- 3
        s_B <= (1 => '1', others => '0');           -- 2
        wait for T_DELAY;
        
        -- Expected: 3 + 2 = 5 (binary ...101)
        assert s_F(2 downto 0) = "101" and s_F(63 downto 3) = (63 downto 3 => '0')
            report "FAILURE [ADD]: Simple addition (3+2) incorrect." severity error;

        ------------------------------------------------------------------------
        -- CASE 4: SUB Operation (S = 0110) and ZERO Flag (Z)
        -- Subtraction of equal numbers must result in Zero
        ------------------------------------------------------------------------
        s_S <= "0110";
        s_A <= (10 => '1', others => '0'); -- Arbitrary value
        s_B <= (10 => '1', others => '0'); -- Same value
        wait for T_DELAY;

        assert s_F = (s_F'range => '0') 
            report "FAILURE [SUB]: Result is not zero." severity error;
        assert s_Z = '1' 
            report "FAILURE [FLAG Z]: Zero flag not set." severity error;

        ------------------------------------------------------------------------
        -- CASE 5: PASS B Operation (S = 0111)
        -- Must pass input B entirely to output
        ------------------------------------------------------------------------
        s_S <= "0111";
        s_A <= (others => '1');             -- 'A' should be ignored (noise)
        s_B <= (15 downto 0 => '1', others => '0'); -- Pattern in B
        wait for T_DELAY;

        assert s_F = s_B 
            report "FAILURE [PASS B]: Output F differs from B." severity error;

        ------------------------------------------------------------------------
        -- CASE 6: NOR Operation (S = 1100)
        -- NOR(0,0) must be -1 (all bits 1)
        ------------------------------------------------------------------------
        s_S <= "1100";
        s_A <= (others => '0');
        s_B <= (others => '0');
        wait for T_DELAY;

        assert s_F = (s_F'range => '1') 
            report "FAILURE [NOR]: NOR of zeros must be all 1s." severity error;

        ------------------------------------------------------------------------
        -- CASE 7: OVERFLOW Flag (Ov)
        -- Simulates signed complement-of-two error (Max Positive + 1)
        ------------------------------------------------------------------------
        s_S <= "0010"; -- ADD
        -- Largest positive number in 64 bits: 0111...111
        s_A <= (63 => '0', others => '1'); 
        s_B <= (0 => '1', others => '0');  -- +1
        wait for T_DELAY;

        -- Result becomes negative (1000...0), which is an Overflow
        assert s_Ov = '1' and s_F(63) = '1' and s_F(62 downto 0) = (62 downto 0 => '0')
            report "FAILURE [FLAG Ov]: Overflow not detected." severity error;

        ------------------------------------------------------------------------
        -- CASE 8: CARRY OUT Flag (Co)
        -- Simulates magnitude rollover (Max Unsigned + 1)
        ------------------------------------------------------------------------
        s_S <= "0010"; -- ADD
        s_A <= (others => '1'); -- All 1s (-1 signed or Max unsigned)
        s_B <= (0 => '1', others => '0'); -- +1
        wait for T_DELAY;

        -- Result should be 0 with Carry Out
        assert s_Co = '1' 
            report "FAILURE [FLAG Co]: Carry Out not generated." severity error;
        assert s_Z = '1' 
            report "FAILURE [ADD]: Rollover sum did not result in zero." severity error;

        report "==============================================================";
        report " END OF SIMULATION: All tests completed.";
        report "==============================================================";
        wait;
    end process;

end architecture test;