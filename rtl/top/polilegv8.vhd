entity polilegv8 is
    port (
        clock : in bit;
        reset : in bit
    );
end entity polilegv8;

architecture structural of polilegv8 is
    -- Internal Signals for connecting Control Unit and Data Path
    
    -- Opcode (Data Path -> Control Unit)
    signal s_opcode       : bit_vector(10 downto 0);

    -- Control Signals (Control Unit -> Data Path)
    signal s_extendMSB    : bit_vector(4 downto 0);
    signal s_extendLSB    : bit_vector(4 downto 0);
    signal s_reg2Loc      : bit;
    signal s_regWrite     : bit;
    signal s_aluSrc       : bit;
    signal s_alu_control  : bit_vector(3 downto 0);
    signal s_branch       : bit;
    signal s_uncondBranch : bit;
    signal s_memRead      : bit;
    signal s_memWrite     : bit;
    signal s_memToReg     : bit;

begin
    ----------------------------------------------------------------------------
    -- Control Unit
    -- Receives the Opcode from the Data Path and generates all control signals.
    ----------------------------------------------------------------------------

    CONTROL_UNIT: entity work.unidadeControle
        port map (
            -- Input
            opcode       => s_opcode,

            -- Outputs (Control Signals)
            extendMSB    => s_extendMSB,
            extendLSB    => s_extendLSB,
            reg2Loc      => s_reg2Loc,
            regWrite     => s_regWrite,
            aluSrc       => s_aluSrc,
            alu_control  => s_alu_control,
            branch       => s_branch,
            uncondBranch => s_uncondBranch,
            memRead      => s_memRead,
            memWrite     => s_memWrite,
            memToReg     => s_memToReg
        );

    ----------------------------------------------------------------------------
    -- Data Path
    -- Executes instructions based on Clock, Reset, and Control Signals.
    -- Outputs the current Opcode to the Control Unit.
    ----------------------------------------------------------------------------
    
    DATA_PATH: entity work.fluxoDados
        port map (
            -- System Inputs
            clock        => clock,
            reset        => reset,

            -- Control Inputs (from Control Unit)
            extendMSB    => s_extendMSB,
            extendLSB    => s_extendLSB,
            reg2Loc      => s_reg2Loc,
            regWrite     => s_regWrite,
            aluSrc       => s_aluSrc,
            alu_control  => s_alu_control,
            branch       => s_branch,
            uncondBranch => s_uncondBranch,
            memRead      => s_memRead,
            memWrite     => s_memWrite,
            memToReg     => s_memToReg,

            -- Output (to Control Unit)
            opcode       => s_opcode
        );

end architecture structural;