entity tb_two_left_shifts is
end entity tb_two_left_shifts;

architecture test of tb_two_left_shifts is
    constant dataSize_TB : natural := 64;
    
    subtype word_t is bit_vector(dataSize_TB-1 downto 0);
    
    constant ZEROS : word_t := (others => '0');
    constant ONES  : word_t := (others => '1');
    
    signal input_s  : word_t;
    signal output_s : word_t;

begin
    DUT: entity work.two_left_shifts
    generic map (
        dataSize => dataSize_TB
    )
    port map (
        input  => input_s,
        output => output_s
    );

    stimulus_process: process
    begin
        report "Starting Testbench for two_left_shifts...";

        -- =========================================================
        -- Case 1: Test with all Zeros
        -- =========================================================
        input_s <= ZEROS;
        wait for 10 ns;
        
        assert output_s = ZEROS
            report "Error in Case 1: Output should be all zeros."
            severity error;

        -- =========================================================
        -- Case 2: Test with all Ones
        -- =========================================================
        input_s <= ONES;
        wait for 10 ns;
        
        assert output_s(1 downto 0) = "00" 
            report "Error in Case 2: The 2 LSBs must be '00'."
            severity error;
            
        assert output_s(dataSize_TB-1 downto 2) = ONES(dataSize_TB-3 downto 0)
            report "Error in Case 2: The upper bits should be ones."
            severity error;

        -- =========================================================
        -- Case 3: Shifting '1' (Decimal 1 becomes Decimal 4)
        -- =========================================================
        input_s <= (0 => '1', others => '0'); -- ...0001
        wait for 10 ns;
        
        assert output_s(2) = '1' and output_s(1 downto 0) = "00"
            report "Error in Case 3: Value 1 did not shift to 4."
            severity error;

        -- =========================================================
        -- Case 4: Testing Boundary (MSB Drop)
        -- =========================================================
        input_s <= (dataSize_TB-1 => '1', others => '0');
        wait for 10 ns;
        assert output_s = ZEROS
            report "Error in Case 4: MSB was not correctly discarded."
            severity error;

        -- =========================================================
        -- End of Tests
        -- =========================================================
        report "Testbench completed successfully.";
        wait;
    end process;

end architecture test;