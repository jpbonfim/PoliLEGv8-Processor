--   OP  | OPERATION
--  0000 | and
--  0001 | or
--  0010 | sum
--  0110 | subtraction
--  0111 | Pass B
--  1100 | nor

library ieee;
use ieee.numeric_bit.all;

entity ula is
    port (
        A        : in bit_vector(63 downto 0);  -- Input A
        B        : in bit_vector(63 downto 0);  -- Input B
        S        : in bit_vector(3 downto 0);   -- Selection/Control
        F        : out bit_vector(63 downto 0); -- Output Result
        Z        : out bit;                     -- Zero Flag
        Ov       : out bit;                     -- Overflow Flag
        Co       : out bit                      -- Carry Out Flag
    );
end entity ula;

architecture structural of ula is
    -- Component Declaration for the 1-bit ALU
    component ula1bit is
        port (
            a         : in bit;
            b         : in bit;
            cin       : in bit;
            ainvert   : in bit;
            binvert   : in bit;
            operation : in bit_vector(1 downto 0);
            result    : out bit;
            cout      : out bit;
            overflow  : out bit
        );
    end component;

    -- Internal signals
    signal carry       : bit_vector(64 downto 0); -- Carry chain (0 to 64)
    signal result_vec  : bit_vector(63 downto 0); -- Internal result storage
    signal ov_signals  : bit_vector(63 downto 0); -- Overflow signals from each 1-bit ALU
    signal ainvert     : bit;
    signal binvert     : bit;
    signal op_sel      : bit_vector(1 downto 0);

begin
    -- Control Signal Decoding
    -- S(3) = Ainvert
    -- S(2) = Binvert
    -- S(1 downto 0) = Operation
    ainvert <= S(3);
    binvert <= S(2);
    op_sel  <= S(1 downto 0);

    -- Carry-in logic to handle subtraction (0110 -> binver + sum):
    -- Carry-in must be 1 whenever B is inverted
    carry(0) <= binvert; 

    -- Generate Loop: Instantiating 64 1-bit ALUs
    gen_alu: for i in 0 to 63 generate
        alu_inst: ula1bit
        port map (
            a         => A(i),
            b         => B(i),
            cin       => carry(i),      -- Carry in from previous stage
            ainvert   => ainvert,
            binvert   => binvert,
            operation => op_sel,
            result    => result_vec(i),
            cout      => carry(i+1),    -- Carry out to next stage
            overflow  => ov_signals(i)  -- Overflow output from this stage
        );
    end generate gen_alu;

    -- Output Assignment
    F <= result_vec;

    -- Carry Out Flag
    -- The global Carry Out is the Carry Out of the last bit (bit 63)
    Co <= carry(64);

    -- Overflow Flag (Ov)
    -- Overflow is only defined by the behavior of the MSB (Most Significant Bit).
    -- The 'ula1bit' calculates (Cin XOR Cout) which is the correct Overflow logic 
    -- for signed arithmetic at the MSB position.
    -- Therefore, we take the overflow signal from the last ALU instance (index 63).
    Ov <= ov_signals(63);

    -- Zero Flag (Z)
    -- Z is 1 if all bits of the result are 0.
    process (result_vec)
        variable temp_or : bit;
    begin
        temp_or := '0';
        for k in 0 to 63 loop
            temp_or := temp_or or result_vec(k);
        end loop;
        Z <= not temp_or; 
    end process;

end architecture structural;