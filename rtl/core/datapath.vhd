entity fluxoDados is
    port(
        clock        : in bit;
        reset        : in bit;
        extendMSB    : in bit_vector (4 downto 0);
        extendLSB    : in bit_vector (4 downto 0);
        reg2Loc      : in bit;
        regWrite     : in bit;
        aluSrc       : in bit;
        alu_control  : in bit_vector (3 downto 0);
        branch       : in bit;
        uncondBranch : in bit;
        memRead      : in bit;
        memWrite     : in bit;
        memToReg     : in bit;
        opcode       : out bit_vector (10 downto 0)
    );
end entity fluxoDados;

architecture structural of fluxoDados is

    -- Constants
    constant ROM_ADDRESS_SIZE : natural := 7;
    constant RAM_ADDRESS_SIZE : natural := 7;
    constant DATA_WORD_SIZE   : natural := 8;
    constant INITIAL_ROM_DATA : string  := "memInstrPolilegv8.dat";
    constant INITIAL_RAM_DATA : string  := "memDadosInicialPolilegv8.dat";

    -- Internal Signals

    -- Program Counter (PC) signals
    signal s_pc_out      : bit_vector(ROM_ADDRESS_SIZE-1 downto 0);
    signal s_pc_in       : bit_vector(ROM_ADDRESS_SIZE-1 downto 0);
    signal s_pc_64       : bit_vector(63 downto 0); -- 64-bit signal for PC math
    signal s_pc_plus_4   : bit_vector(63 downto 0);
    signal s_pc_next_64  : bit_vector(63 downto 0); -- Output of Branch Mux

    -- Instruction Memory signals
    signal s_instruction : bit_vector(31 downto 0);

    -- Register File signals
    signal s_read_reg_2  : bit_vector(4 downto 0); -- Output of Reg2Loc Mux
    signal s_write_data  : bit_vector(63 downto 0); -- Output of MemToReg Mux
    signal s_read_data_1 : bit_vector(63 downto 0);
    signal s_read_data_2 : bit_vector(63 downto 0);

    -- Sign Extend signals
    signal s_sign_ext_out : bit_vector(63 downto 0);

    -- ALU signals
    signal s_alu_src_b   : bit_vector(63 downto 0); -- Output of ALUSrc Mux
    signal s_alu_result  : bit_vector(63 downto 0);
    signal s_alu_zero    : bit;
    signal s_alu_ov      : bit; -- Not used but required for port map
    signal s_alu_co      : bit; -- Not used but required for port map

    -- Data Memory signals
    signal s_mem_read_data : bit_vector(63 downto 0);

    -- Branch Logic signals
    signal s_shifted_offset   : bit_vector(63 downto 0);
    signal s_branch_target    : bit_vector(63 downto 0);
    signal s_branch_decision  : bit;
    
    -- Constant for PC increment (4)
    signal s_const_4_64 : bit_vector(63 downto 0);

begin
    ----------------------------------------------------------------------------
    -- Signal Assignments and Logic
    ----------------------------------------------------------------------------

    -- Output Opcode assignment 
    opcode <= s_instruction(31 downto 21);

    -- PC Expansion to 64 bits for arithmetic 
    -- The PC register is small (ROM_ADDRESS_SIZE), but adders are 64-bit.
    s_pc_64(ROM_ADDRESS_SIZE-1 downto 0) <= s_pc_out;
    s_pc_64(63 downto ROM_ADDRESS_SIZE)  <= (others => '0');

    -- Constant 4 generation for PC + 4
    s_const_4_64 <= (2 => '1', others => '0');

    -- Branch Control Logic 
    -- (Branch AND Zero) OR Unconditional Branch
    s_branch_decision <= (branch and s_alu_zero) or uncondBranch;

    -- Update PC Input from the 64-bit result of the Branch Mux, only uses the ROM_ADDRESS_SIZE least significant bits
    s_pc_in <= s_pc_next_64(ROM_ADDRESS_SIZE-1 downto 0);

    ----------------------------------------------------------------------------
    -- Component Instantiations
    ----------------------------------------------------------------------------

    -- 1. Program Counter (PC) 
    PC_REG: entity work.reg
        generic map (
            dataSize => ROM_ADDRESS_SIZE
        )
        port map (
            clock  => clock,
            reset  => reset,
            enable => '1', -- PC always enabled in this single-cycle design
            d      => s_pc_in,
            q      => s_pc_out
        );

    -- 2. PC Adder (PC + 4) 
    ADDER_PC_PLUS_4: entity work.adder_n
        generic map (
            dataSize => 64
        )
        port map (
            in0  => s_pc_64,
            in1  => s_const_4_64,
            sum  => s_pc_plus_4,
            cout => open -- Carry out ignored
        );

    -- 3. Instruction Memory 
    -- Uses a wrapper to iterface the rom 'rom_wrapper_8x4'.
    INSTRUCTION_MEMORY: entity work.rom_wrapper_8x4
        generic map (
            addressSize => ROM_ADDRESS_SIZE,
            dataSize    => DATA_WORD_SIZE,
            datFileName => INITIAL_ROM_DATA
        )
        port map (
            addr => s_pc_out,
            data => s_instruction
        );

    -- 4. Mux for Read Register 2 (Reg2Loc) 
    -- Selects between Rm (20-16) and Rt/Rd (4-0) based on control signal.
    -- Inputs are 5 bits, so we use a 5-bit mux (generic dataSize = 5).
    MUX_REG2LOC: entity work.mux_n
        generic map (
            dataSize => 5
        )
        port map (
            in0  => s_instruction(20 downto 16), -- [20-16] Rm
            in1  => s_instruction(4 downto 0),   -- [4-0] Rt/Rd
            sel  => reg2Loc,
            dOut => s_read_reg_2
        );

    -- 5. Register File 
    REGISTER_FILE: entity work.regfile
        port map (
            clock    => clock,
            reset    => reset,
            regWrite => regWrite,
            rr1      => s_instruction(9 downto 5), -- Rn
            rr2      => s_read_reg_2,              -- Output of Reg2Loc Mux
            wr       => s_instruction(4 downto 0), -- Rd
            d        => s_write_data,              -- Data to write (from MemToReg Mux)
            q1       => s_read_data_1,
            q2       => s_read_data_2
        );

    -- 6. Sign Extend 
    -- Uses 'sign_extend' from Part 1.
    -- Expands instruction fields to 64 bits based on control signals.
    SIGN_EXTENSION: entity work.sign_extend
        generic map (
            dataISize       => 32,
            dataOSize       => 64,
            dataMaxPosition => 5
        )
        port map (
            inData      => s_instruction,
            inDataStart => extendMSB,
            inDataEnd   => extendLSB,
            outData     => s_sign_ext_out
        );

    -- 7. Mux for ALU Source B (ALUSrc) 
    -- Selects between Read Data 2 (RegFile) and Sign Extended Immediate.
    MUX_ALU_SRC: entity work.mux_n
        generic map (
            dataSize => 64
        )
        port map (
            in0  => s_read_data_2,
            in1  => s_sign_ext_out,
            sel  => aluSrc,
            dOut => s_alu_src_b
        );

    -- 8. Arithmetic Logic Unit (ULA) 
    ALU: entity work.ula
        port map (
            A      => s_read_data_1,
            B      => s_alu_src_b,
            S      => alu_control,
            F      => s_alu_result,
            Z      => s_alu_zero,
            Ov     => s_alu_ov, -- Connected but unused
            Co     => s_alu_co  -- Connected but unused
        );

    -- 9. Data Memory 
    -- Uses a wrapper to iterface the ram 'ram_wrapper_8x8'.
    -- Address comes from ALU Result
    DATA_MEMORY: entity work.ram_wrapper_8x8
        generic map (
            addressSize => RAM_ADDRESS_SIZE,
            dataSize    => DATA_WORD_SIZE,
            datFileName => INITIAL_RAM_DATA
        )
        port map (
            clock  => clock,
            wr     => memWrite,
            addr   => s_alu_result(RAM_ADDRESS_SIZE-1 downto 0),
            data_i => s_read_data_2,
            data_o => s_mem_read_data
        );

    -- 10. Mux for Write Back (MemToReg) 
    -- Selects between ALU Result and Memory Output for writing back to registers.
    MUX_MEM_TO_REG: entity work.mux_n
        generic map (
            dataSize => 64
        )
        port map (
            in0  => s_alu_result,
            in1  => s_mem_read_data,
            sel  => memToReg,
            dOut => s_write_data
        );

    -- 11. Shift Left 2 
    -- Shifts the sign-extended offset for branch calculation.
    SHIFT_LEFT: entity work.two_left_shifts
        generic map (
            dataSize => 64
        )
        port map (
            input  => s_sign_ext_out,
            output => s_shifted_offset
        );

    -- 12. Branch Adder 
    -- Calculates Branch Target Address (PC + Shifted Offset).
    ADDER_BRANCH: entity work.adder_n
        generic map (
            dataSize => 64
        )
        port map (
            in0  => s_pc_64,
            in1  => s_shifted_offset,
            sum  => s_branch_target,
            cout => open -- Carry out ignored
        );

    -- 13. Mux for PC Source (Branch) 
    -- Selects between PC+4 and Branch Target Address based on branch logic.
    MUX_BRANCH: entity work.mux_n
        generic map (
            dataSize => 64
        )
        port map (
            in0  => s_pc_plus_4,
            in1  => s_branch_target,
            sel  => s_branch_decision, -- Controlled by (Branch & Zero) OR UncondBranch
            dOut => s_pc_next_64
        );

end architecture structural;