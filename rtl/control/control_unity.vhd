entity unidadeControle is
    port(
        opcode       : in bit_vector (10 downto 0);
        extendMSB    : out bit_vector (4 downto 0);
        extendLSB    : out bit_vector (4 downto 0);
        reg2Loc      : out bit;
        regWrite     : out bit;
        aluSrc       : out bit;
        alu_control  : out bit_vector (3 downto 0);
        branch       : out bit;
        uncondBranch : out bit;
        memRead      : out bit;
        memWrite     : out bit;
        memToReg     : out bit
    );
end entity unidadeControle;

architecture structural of unidadeControle is
begin

    process(opcode)
    begin
        -- Initialize default values to avoid bugs
        extendMSB    <= (others => '0');
        extendLSB    <= (others => '0');
        reg2Loc      <= '0';
        regWrite     <= '0';
        aluSrc       <= '0';
        alu_control  <= "0000";
        branch       <= '0';
        uncondBranch <= '0';
        memRead      <= '0';
        memWrite     <= '0';
        memToReg     <= '0';

        
        -- Control signals according to the opcode
        -- Dont care bits were defined to zero to maintain a deterministic approach

        -- ADD (R-Format)
        -- Opcode: 10001011000
        if opcode = "10001011000" then
            reg2Loc      <= '0';
            aluSrc       <= '0';
            memToReg     <= '0';
            regWrite     <= '1';
            memRead      <= '0';
            memWrite     <= '0';
            branch       <= '0';
            uncondBranch <= '0';
            alu_control  <= "0010"; -- Add
            -- ExtendMSB/LSB are Don't Care (X)
            extendMSB    <= "00000";
            extendLSB    <= "00000";

        -- SUB (R-Format)
        -- Opcode: 11001011000
        elsif opcode = "11001011000" then
            reg2Loc      <= '0';
            aluSrc       <= '0';
            memToReg     <= '0';
            regWrite     <= '1';
            memRead      <= '0';
            memWrite     <= '0';
            branch       <= '0';
            uncondBranch <= '0';
            alu_control  <= "0110"; -- Subtract
            -- ExtendMSB/LSB are Don't Care (X)
            extendMSB    <= "00000";
            extendLSB    <= "00000";

        -- AND (R-Format)
        -- Opcode: 10001010000
        elsif opcode = "10001010000" then
            reg2Loc      <= '0';
            aluSrc       <= '0';
            memToReg     <= '0';
            regWrite     <= '1';
            memRead      <= '0';
            memWrite     <= '0';
            branch       <= '0';
            uncondBranch <= '0';
            alu_control  <= "0000"; -- AND
            -- ExtendMSB/LSB are Don't Care (X)
            extendMSB    <= "00000";
            extendLSB    <= "00000";

        -- ORR (R-Format)
        -- Opcode: 10101010000
        elsif opcode = "10101010000" then
            reg2Loc      <= '0';
            aluSrc       <= '0';
            memToReg     <= '0';
            regWrite     <= '1';
            memRead      <= '0';
            memWrite     <= '0';
            branch       <= '0';
            uncondBranch <= '0';
            alu_control  <= "0001"; -- OR
            -- ExtendMSB/LSB are Don't Care (X)
            extendMSB    <= "00000";
            extendLSB    <= "00000";

        -- LDUR (D-Format)
        -- Opcode: 11111000010
        elsif opcode = "11111000010" then
            reg2Loc      <= '0'; -- Don't Care (X)
            aluSrc       <= '1';
            memToReg     <= '1';
            regWrite     <= '1';
            memRead      <= '1';
            memWrite     <= '0';
            branch       <= '0';
            uncondBranch <= '0';
            alu_control  <= "0010";  -- Add (Address calc)
            extendMSB    <= "10100"; -- 20
            extendLSB    <= "01100"; -- 12

        -- STUR (D-Format)
        -- Opcode: 11111000000
        elsif opcode = "11111000000" then
            reg2Loc      <= '1';
            aluSrc       <= '1';
            memToReg     <= '0'; -- Don't Care (x)
            regWrite     <= '0';
            memRead      <= '0';
            memWrite     <= '1';
            branch       <= '0';
            uncondBranch <= '0';
            alu_control  <= "0010";  -- Add (Address calc)
            extendMSB    <= "10100"; -- 20
            extendLSB    <= "01100"; -- 12

        -- CBZ (CB-Format)
        -- Opcode: 10110100XXX (Bits 2-0 are don't care for opcode check)
        -- Matches 10110100...
        elsif opcode(10 downto 3) = "10110100" then
            reg2Loc      <= '1';
            aluSrc       <= '0';
            memToReg     <= '0'; -- Don't Care (x)
            regWrite     <= '0';
            memRead      <= '0';
            memWrite     <= '0';
            branch       <= '1';
            uncondBranch <= '0';
            alu_control  <= "0011";  -- Pass B (XX11)
            extendMSB    <= "10111"; -- 23
            extendLSB    <= "00101"; -- 5

        -- B (B-Format)
        -- Opcode: 000101XXXXX (Bits 4-0 are don't care for opcode check)
        -- Matches 000101...
        elsif opcode(10 downto 5) = "000101" then
            reg2Loc      <= '0'; -- Don't Care
            aluSrc       <= '0'; -- Don't Care
            memToReg     <= '0'; -- Don't Care
            regWrite     <= '0';
            memRead      <= '0';
            memWrite     <= '0';
            branch       <= '0';
            uncondBranch <= '1';
            alu_control  <= "0000";  -- Don't Care (XXXX)
            extendMSB    <= "11001"; -- 25
            extendLSB    <= "00000"; -- 0

        else
            -- Default case for unknown opcodes (Safety)
            -- All signals already set to 0 at start of process
            null;
        end if;

    end process;

end architecture structural;