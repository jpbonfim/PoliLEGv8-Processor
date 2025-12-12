library ieee;
use ieee.numeric_bit.all;

entity memoriaDados_tb is
end entity memoriaDados_tb;

architecture test of memoriaDados_tb is

    -- ========================================================================
    --  CONFIGURATION
    -- ========================================================================
    constant ADDR_WIDTH : natural := 4;
    constant DATA_WIDTH : natural := 8;
    constant RAM_FILE   : string  := "./firmware/memDados_conteudo_inicial.dat";
    constant CLK_PERIOD : time    := 10 ns;

    -- Helper Constants
    constant VAL_ZERO : bit_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    constant VAL_FULL : bit_vector(DATA_WIDTH-1 downto 0) := (others => '1');

    -- Signals
    signal clk_s    : bit := '0';
    signal wr_s     : bit := '0';
    signal addr_s   : bit_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal data_i_s : bit_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_o_s : bit_vector(DATA_WIDTH-1 downto 0);
    
    signal sim_running : boolean := true;

begin
    DUT: entity work.memoriaDados
    generic map (
        addressSize => ADDR_WIDTH,
        dataSize    => DATA_WIDTH,
        datFileName => RAM_FILE
    )
    port map (
        clock  => clk_s,
        wr     => wr_s,
        addr   => addr_s,
        data_i => data_i_s,
        data_o => data_o_s
    );

    clk_proc: process
    begin
        while sim_running loop
            clk_s <= '0';
            wait for CLK_PERIOD/2;
            clk_s <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    test_proc: process
        -- Helper function for reporting
        function to_str(bv : bit_vector) return string is
        begin
            return integer'image(to_integer(unsigned(bv)));
        end function;

    begin
        report "=========================================";
        report "Starting RAM Verification";
        report "=========================================";

        -- Initial Read Test (From File)
        -- Address 1 should have 00000000 (0) from the file
        report "Test 1: Reading Initial Value from File...";
        addr_s <= bit_vector(to_unsigned(1, ADDR_WIDTH));
        wr_s   <= '0'; 
        wait for CLK_PERIOD; -- Wait for prop

        assert data_o_s = VAL_ZERO
            report "[FAIL] Initial Read: Expected 0, got " & to_str(data_o_s)
            severity error;
        
        report "[PASS] Initial Read verified.";

        -- Write Test
        -- Write 55 (00110111) to Address 1
        report "Test 2: Writing New Value (55) to Address 1...";
        wr_s     <= '1';
        data_i_s <= bit_vector(to_unsigned(55, DATA_WIDTH));
        wait for CLK_PERIOD; -- Clock edge happens here

        -- Disable write
        wr_s <= '0';
        
        -- Check if output updated (Asynchronous Read)
        assert data_o_s = bit_vector(to_unsigned(55, DATA_WIDTH))
            report "[FAIL] Write Verification: Expected 55, got " & to_str(data_o_s)
            severity error;
            
        report "[PASS] Write verified.";

        -- Write Protection Test (wr = 0)
        -- Try to write 99 to Address 1 with wr=0. Value should remain 55.
        report "Test 3: Testing Write Protection (wr=0)...";
        data_i_s <= bit_vector(to_unsigned(99, DATA_WIDTH));
        wr_s     <= '0';
        wait for CLK_PERIOD;

        assert data_o_s = bit_vector(to_unsigned(55, DATA_WIDTH))
            report "[FAIL] Protection: RAM updated when wr=0! Got " & to_str(data_o_s)
            severity error;

        report "[PASS] Write Protection verified.";

        -- End Simulation
        report "=========================================";
        report "RAM Test Completed.";
        report "=========================================";
        sim_running <= false;
        wait;
    end process;

end architecture test;