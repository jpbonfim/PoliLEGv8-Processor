library std;
use std.env.all;

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
        -- Around 20 instructions before entering the final infinite loop.
        -- 60 cycles should be sufficient.
        wait for 60 * CLK_PERIOD;

        -- 4. End of Simulation
        report "End of stimulus time. Check waveforms.";
        report "Simulation Completed Successfully" severity note;
        
        -- Stop simulation properly
        std.env.stop; -- "stop" to endpoint for debugging or "finish" to end simulation
        wait;
    end process p_stimulus;

end architecture test;

    ----------------------------------------------------------------------------
    --                  VERIFICATION GUIDE (Manual via Waveform)
    ----------------------------------------------------------------------------
    -- Running the testbench above, the processor executes the code present in 
    -- the instruction memory (ROM, content: "./firmware/memInstrPolilegv8.dat") 
    -- with the initial data from the data memory (RAM, content: "./firmware/memDadosInicialPolilegv8.dat"). 
    
    ----------------------------------------------------------------------------    
    -- The code in the instruction memory in Assembly format is:
    -- LDUR X0,  [XZR, #0]      // Loads X0 = 0x0000000000000008
    -- LDUR X1,  [XZR, #8]      // Loads X1 = 0x0000000000000005
    -- LDUR X12, [XZR, #16]     // Loads X12 = 0xFEDCBA9876543210
    -- LDUR X13, [XZR, #24]     // Loads X13 = 0x0123456789ABCDEF
    -- ADD X4,  X0, X1          // X4 = X0 + X1 = 0x000000000000000D (13)
    -- SUB X25, X0, X1          // X25 = X0 - X1 = 0x0000000000000003 (3)
    -- SUB X16, X1, X0          // X16 = X1 - X0 = 0xFFFFFFFFFFFFFFFD (-3)
    -- ORR X30, X12, X13        // X30 = X12 OR X13 = 0xFFFFFFFFFFFFFFFF (all bits set)
    -- AND X8,  X12, X13        // X8  = X12 AND X13 = 0x0000000000000000 (all bits cleared)
    -- ORR XZR, X0, X1          // Attempts to write XZR = X0 OR X1 (0xE),
    --                          // but XZR is hardwired to zero and cannot be modified
    -- CBZ XZR, #3              // Since XZR is still zero, branch forward by 3 instructions
    -- STUR XZR, [X9, #32]      // Would incorrectly store XZR if it had been overwritten
    --                          // (not executed due to the branch)
    -- B #0                     // Infinite loop (not executed)
    -- STUR X4,  [XZR, #32]     // Stores X4 at memory addresses [32–39]
    -- STUR X25, [XZR, #40]     // Stores X25 at memory addresses [40–47]
    -- STUR X16, [XZR, #48]     // Stores X16 at memory addresses [48–55]
    -- STUR X30, [XZR, #56]     // Stores X30 at memory addresses [56–63]
    -- STUR X8,  [XZR, #64]     // Stores X8  at memory addresses [64–71]
    -- B #0                     // Infinite loop
    ----------------------------------------------------------------------------    

    -- To validate functionality, add the DUT's internal signals to your 
    -- waveform viewer (GTKWave/ModelSim).
    --
    -- Critical Signals to Monitor:
    -- 1. DUT.DATA_PATH.PC_REG.q (PC Value)
    -- 2. DUT.DATA_PATH.REGISTER_FILE (Register Content)
    -- 3. DUT.DATA_PATH.DATA_MEMORY (RAM Content)
    --
    -- EXPECTED RESULTS:
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
