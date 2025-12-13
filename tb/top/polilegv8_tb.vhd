entity polilegv8_tb is
end entity polilegv8_tb;

architecture test of polilegv8_tb is

    -- Top Level Component Declaration (Processor)
    component polilegv8 is
        port (
            clock : in bit;
            reset : in bit
        );
    end component;

    -- Stimulus Signals
    signal s_clock : bit := '0';
    signal s_reset : bit := '1';

    -- Clock Period Definition (Adjustable)
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Processor Instantiation (DUT - Device Under Test)
    DUT: component polilegv8
        port map (
            clock => s_clock,
            reset => s_reset
        );

    -- Clock Generation Process
    p_clock_gen: process
    begin
        s_clock <= '0';
        wait for CLK_PERIOD / 2;
        s_clock <= '1';
        wait for CLK_PERIOD / 2;
    end process p_clock_gen;

    -- Stimulus Process (Reset and Timing Control)
    p_stimulus: process
    begin
        -- 1. Initial System Reset
        -- Keep reset high for 2 cycles to ensure registers and PC are cleared
        report "Starting Simulation: Reset Active";
        s_reset <= '1';
        wait for CLK_PERIOD * 2;
        
        -- 2. Release Reset
        report "Releasing Reset: Processor Running";
        s_reset <= '0';

        -- 3. Wait for program execution
        -- The provided program (memInstrPolilegv8.dat) has approximately 
        -- 15 to 20 instructions before entering the final infinite loop.
        -- 60 cycles * 10ns = 600ns should be sufficient.
        wait for 600 ns;

        -- 4. End of Simulation
        report "End of stimulus time. Check waveforms.";
        
        -- Stop simulation (assert failure is used to stop simulation in some tools)
        assert false report "Simulation Completed Successfully" severity failure;
        wait;
    end process p_stimulus;

    ----------------------------------------------------------------------------
    -- VERIFICATION GUIDE (Manual via Waveform)
    ----------------------------------------------------------------------------
    -- To validate functionality, add the DUT's internal signals to your 
    -- waveform viewer (GTKWave/ModelSim).
    --
    -- Critical Signals to Monitor:
    -- 1. DUT.U_DATA_PATH.PC_REG.q (PC Value)
    -- 2. DUT.U_DATA_PATH.REGISTER_FILE (Register Content)
    -- 3. DUT.U_DATA_PATH.DATA_MEMORY (RAM Content)
    --
    -- EXPECTED RESULTS (Based on Document Part 3):
    --
    -- A) Initial Loads (LDUR):
    --    - X0  must be 8 (0x...08)
    --    - X1  must be 5 (0x...05)
    --    - X12 must be 0xFEDCBA9876543210
    --    - X13 must be 0x0123456789ABCDEF
    --
    -- B) Arithmetic/Logic Operations:
    --    - X4  (ADD X0, X1)   -> Must be 13 (0x...0D)
    --    - X25 (SUB X0, X1)   -> Must be 3  (0x...03)
    --    - X16 (SUB X1, X0)   -> Must be -3 (0xFF...FD)
    --    - X30 (ORR X12, X13) -> Must be -1 (0xFF...FF / all 1s)
    --    - X8  (AND X12, X13) -> Must be 0  (0x00...00 / all 0s)
    --
    -- C) Zero Register Test (XZR/X31):
    --    - The instruction 'ORR XZR, X0, X1' attempts to write 13 into XZR.
    --    - Verify if XZR remains 0.
    --
    -- D) Branch Logic (CBZ):
    --    - The code executes 'CBZ XZR, #3'. Since XZR is 0, it must branch
    --      over the error instructions (STUR to wrong addresses) and jump 
    --      to the correct write section.
    --
    -- E) Memory Writes (STUR) - End of program:
    --    - Address [32-39] (Base 32): Must contain X4  (13)
    --    - Address [40-47] (Base 40): Must contain X25 (3)
    --    - Address [48-55] (Base 48): Must contain X16 (-3)
    --    - Address [56-63] (Base 56): Must contain X30 (-1)
    --    - Address [64-71] (Base 64): Must contain X8  (0)
    ----------------------------------------------------------------------------

end architecture test;