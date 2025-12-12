library ieee;
use ieee.numeric_bit.all;

entity memoriaInstrucoes_tb is
end entity memoriaInstrucoes_tb;

architecture test of memoriaInstrucoes_tb is
    
    -- ========================================================================
    --  TEST CONFIGURATION
    -- ========================================================================
    constant ADDR_WIDTH : natural := 8;  -- Address Bus Size
    constant DATA_WIDTH : natural := 8;  -- Word Size
    constant ROM_FILE   : string  := "./firmware/memInstr_conteudo.dat"; 

    -- Define a record type for test cases: (Address, Expected Value)
    type test_entry is record
        addr_idx : natural; -- The address to access
        exp_val  : natural; -- The expected decimal value at that address
    end record;

    -- Define the list of cases to verify
    -- Ensure your .dat file matches these expectations!
    type test_array is array (natural range <>) of test_entry;
    constant TEST_CASES : test_array := (
        (addr_idx => 1, exp_val => 64),
        (addr_idx => 3, exp_val => 225),
        (addr_idx => 49, exp_val => 0),
        (addr_idx => 255, exp_val => 0)
    );

    -- ========================================================================
    -- Signals
    -- ========================================================================
    signal addr_s : bit_vector(ADDR_WIDTH-1 downto 0);
    signal data_s : bit_vector(DATA_WIDTH-1 downto 0);

begin

    DUT: entity work.memoriaInstrucoes
    generic map (
        addressSize => ADDR_WIDTH,
        dataSize    => DATA_WIDTH,
        datFileName => ROM_FILE
    )
    port map (
        addr => addr_s,
        data => data_s
    );

    verify_proc: process
        variable current_addr : natural;
        variable expected_val : natural;
        variable actual_val   : natural;
    begin
        report "==============================================================";
        report "Starting ROM Verification";
        report "File: " & ROM_FILE;
        report "==============================================================";

        -- Iterate through the configuration array
        for i in TEST_CASES'range loop
            
            -- Setup
            current_addr := TEST_CASES(i).addr_idx;
            expected_val := TEST_CASES(i).exp_val;
            
            -- Apply Stimulus
            addr_s <= bit_vector(to_unsigned(current_addr, ADDR_WIDTH));
            
            -- Wait for Read Access Time
            wait for 10 ns; 
            
            -- Sample and Check
            actual_val := to_integer(unsigned(data_s));

            if actual_val = expected_val then
                report "[PASS] Address " & integer'image(current_addr) & 
                       ": Read " & integer'image(actual_val) & " correctly.";
            else
                report "[FAIL] Address " & integer'image(current_addr) & 
                       ": Expected " & integer'image(expected_val) & 
                       ", but got " & integer'image(actual_val) 
                       severity error;
            end if;

        end loop;

        report "==============================================================";
        report "ROM Test Completed.";
        report "==============================================================";
        wait;
    end process;

end architecture test;