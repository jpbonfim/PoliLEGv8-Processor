-- Testbench for Component 5: Binary Adder (adder_n)
-- Group T2G06 (Updated)

library ieee;
use ieee.numeric_bit.ALL;

entity adder_n_tb is 
end entity adder_n_tb;

architecture behavioral of adder_n_tb is 

    -- Configuration
    constant DATA_WIDTH : natural := 4; -- Using 4 bits for easy verification

    -- Test Vector Structures
    type pattern_type is record
        -- Inputs
        in0 : bit_vector(DATA_WIDTH-1 downto 0);
        in1 : bit_vector(DATA_WIDTH-1 downto 0);
        -- Expected Outputs
        exp_sum  : bit_vector(DATA_WIDTH-1 downto 0);
        exp_cout : bit;
    end record;
    
    type pattern_array is array (natural range <>) of pattern_type;

    -- Test Vectors Definition
    -- Format: (in0, in1, expected_sum, expected_cout)
    constant PATTERNS : pattern_array := (
        ("0000", "0000", "0000", '0'), -- 0 + 0 = 0
        ("0001", "0001", "0010", '0'), -- 1 + 1 = 2
        ("1111", "1111", "1110", '1'), -- 15 + 15 = 30 (14 + Carry)
        ("1110", "1010", "1000", '1'), -- 14 + 10 = 24 (8 + Carry)
        ("1110", "1011", "1001", '1'), -- 14 + 11 = 25 (9 + Carry)
        ("1010", "1001", "0011", '1'), -- 10 + 9 = 19 (3 + Carry)
        ("1100", "0010", "1110", '0'),  -- 12 + 2 = 14
        ("1010", "0101", "1111", '0'), -- 10 + 5 = 15
        ("0101", "1010", "1111", '0'), -- 5 + 10 = 15
        ("1000", "1000", "0000", '1'), -- 8 + 8 = 16 (0 + Carry)
        ("0000", "1111", "1111", '0'), -- 0 + 15 = 15
        ("1111", "0000", "1111", '0'), -- 15 + 0 = 15
        ("0111", "0001", "1000", '0'), -- 0111 (7) + 0001 (1) = 1000 (8) -> The carry from bit 0 must go to bit 3
        ("1101", "0101", "0010", '1')  -- 13 (1101) + 5 (0101) = 18 (2 + Carry)
    );

    signal s_in0   : bit_vector(DATA_WIDTH-1 downto 0);
    signal s_in1   : bit_vector(DATA_WIDTH-1 downto 0);
    signal s_sum   : bit_vector(DATA_WIDTH-1 downto 0);
    signal s_cOut  : bit;

begin
  
    DUT: entity work.adder_n
    generic map (
        dataSize => DATA_WIDTH
    )
    port map (
        in0  => s_in0,
        in1  => s_in1,
        sum  => s_sum,
        cout => s_cOut
    );
  
    stimulus_proc: process
        -- Helper function to simplify reporting (converts vector to decimal string)
        function to_string(bv : bit_vector) return string is
        begin
            return integer'image(to_integer(unsigned(bv)));
        end function;

    begin
        report "=========================================";
        report "Starting Simulation: Binary Adder";
        report "=========================================";

        for i in PATTERNS'range loop
            s_in0 <= PATTERNS(i).in0;
            s_in1 <= PATTERNS(i).in1;
            
            -- Wait for combinational logic propagation
            wait for 1 ns;

            -- Check Results
            -- Check Sum
            assert s_sum = PATTERNS(i).exp_sum
                report "[FAIL] Test " & integer'image(i) & ": Sum mismatch. " &
                       "Expected " & to_string(PATTERNS(i).exp_sum) & 
                       ", Got " & to_string(s_sum)
                severity error;

            -- Check Carry Out
            assert s_cOut = PATTERNS(i).exp_cout
                report "[FAIL] Test " & integer'image(i) & ": Carry mismatch. " &
                       "Expected " & bit'image(PATTERNS(i).exp_cout) & 
                       ", Got " & bit'image(s_cOut)
                severity error;
            
            -- Pass Confirmation
            if (s_sum = PATTERNS(i).exp_sum) and (s_cOut = PATTERNS(i).exp_cout) then
                report "[PASS] Test " & integer'image(i) & ": " &
                       to_string(s_in0) & " + " & to_string(s_in1) & 
                       " = " & to_string(s_sum) & 
                       " (Cout=" & bit'image(s_cOut) & ")";
            end if;

        end loop;

        report "=========================================";
        report "Simulation Completed Successfully.";
        report "=========================================";
        wait;
   end process;

end architecture behavioral;