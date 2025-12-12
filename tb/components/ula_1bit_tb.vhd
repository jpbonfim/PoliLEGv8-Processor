library ieee;
use ieee.numeric_bit.ALL;

entity ula1bit_tb is 
end entity ula1bit_tb;

architecture behavioral of ula1bit_tb is 

    -- ========================================================================
    --  DEFINITIONS
    -- ========================================================================
    
    -- Operation Codes
    constant OP_AND  : bit_vector(1 downto 0) := "00";
    constant OP_OR   : bit_vector(1 downto 0) := "01";
    constant OP_ADD  : bit_vector(1 downto 0) := "10";
    constant OP_PASS : bit_vector(1 downto 0) := "11";

    -- Test Vector Record
    type pattern_type is record
        -- Inputs
        a, b, cin       : bit;
        ainv, binv      : bit;
        op              : bit_vector(1 downto 0);
        -- Expected Outputs
        exp_res         : bit;
        exp_cout        : bit;
        exp_ovf         : bit; -- Expected Overflow (Cin XOR Cout)
        desc            : string(1 to 20); -- Short description
    end record;

    type pattern_array is array (natural range <>) of pattern_type;

    -- ========================================================================
    --  TEST VECTORS
    -- ========================================================================
    constant PATTERNS : pattern_array := (
        -- a | b | cin | ainv | binv | OP | res | cout | ovf |
        -- [AND Tests]
        -- a=0, b=0 -> 0
        ('0', '0', '0', '0', '0', OP_AND, '0', '0', '0', "AND: 0 & 0          "),
        -- a=1, b=1 -> 1
        ('1', '1', '0', '0', '0', OP_AND, '1', '1', '1', "AND: 1 & 1          "), -- Cout depends on Adder logic (1+1) even in AND mode
        -- a=1, b=0, invB=1 -> 1 & (not 0) = 1 & 1 -> 1
        ('1', '0', '0', '0', '1', OP_AND, '1', '1', '1', "AND: 1 & !0 (1)     "),

        -- [OR Tests]
        -- a=0, b=0 -> 0
        ('0', '0', '0', '0', '0', OP_OR,  '0', '0', '0', "OR:  0 | 0          "),
        -- a=0, b=1 -> 1
        ('0', '1', '0', '0', '0', OP_OR,  '1', '0', '0', "OR:  0 | 1          "),
        -- a=0, b=0, invA=1, invB=1 -> (!0)|(!0) = 1|1 -> 1
        ('0', '0', '0', '1', '1', OP_OR,  '1', '1', '1', "OR: !0 | !0         "),

        -- [ADD Tests]
        -- 0 + 0 + 0 = 0
        ('0', '0', '0', '0', '0', OP_ADD, '0', '0', '0', "ADD: 0+0            "),
        -- 1 + 0 + 0 = 1
        ('1', '0', '0', '0', '0', OP_ADD, '1', '0', '0', "ADD: 1+0            "),
        -- 1 + 1 + 0 = 0 (Cout 1) -> Overflow: Cin(0) XOR Cout(1) = 1
        ('1', '1', '0', '0', '0', OP_ADD, '0', '1', '1', "ADD: 1+1 (Ovflow)   "),
        -- 1 + 1 + 1 = 1 (Cout 1) -> Overflow: Cin(1) XOR Cout(1) = 0
        ('1', '1', '1', '0', '0', OP_ADD, '1', '1', '0', "ADD: 1+1+1          "),
        -- 1 + 0 + 1 = 0 (Cout 1) -> Overflow: Cin(1) XOR Cout(1) = 0
        ('1', '0', '1', '0', '0', OP_ADD, '0', '1', '0', "ADD: 1+0+1          "),

        -- [SUBTRACTION SIMULATION Tests] (A - B = A + !B + 1)
        -- 1 - 1 = 0. Inputs: a=1, b=1, binv=1, cin=1
        -- Logic: 1 + (!1) + 1 = 1 + 0 + 1 = 0 (Cout 1). Ovf: 1 XOR 1 = 0.
        ('1', '1', '1', '0', '1', OP_ADD, '0', '1', '0', "SUB: 1 - 1          "),
        
        -- 0 - 1 = -1 (11...1). Inputs: a=0, b=1, binv=1, cin=1
        -- Logic: 0 + (!1) + 1 = 0 + 0 + 1 = 1 (Cout 0). Ovf: 1 XOR 0 = 1.
        ('0', '1', '1', '0', '1', OP_ADD, '1', '0', '1', "SUB: 0 - 1          "),

        -- [PASS B Tests]
        -- Pass B=1 -> 1
        ('0', '1', '0', '0', '0', OP_PASS, '1', '0', '0', "PASS B: 1           "),
        -- Pass B=1, invB=1
        ('0', '1', '0', '0', '1', OP_PASS, '1', '0', '0', "PASS B: 1  (binv)   ")
    );

    -- ========================================================================
    --  SIGNALS
    -- ========================================================================
    signal a_s, b_s, cin_s       : bit;
    signal ainv_s, binv_s        : bit;
    signal op_s                  : bit_vector(1 downto 0);
    signal res_s, cout_s, ovf_s  : bit;

begin

    DUT: entity work.ula1bit
    port map (
        a         => a_s,
        b         => b_s,
        cin       => cin_s,
        ainvert   => ainv_s,
        binvert   => binv_s,
        operation => op_s,
        result    => res_s,
        cout      => cout_s,
        overflow  => ovf_s
    );

    process
        function to_str(b: bit) return string is
        begin
            return integer'image(bit'pos(b));
        end function;
    begin
        report "==========================================================";
        report "               Starting 1-Bit ALU Testbench               ";
        report "==========================================================";

        for i in PATTERNS'range loop
            a_s    <= PATTERNS(i).a;
            b_s    <= PATTERNS(i).b;
            cin_s  <= PATTERNS(i).cin;
            ainv_s <= PATTERNS(i).ainv;
            binv_s <= PATTERNS(i).binv;
            op_s   <= PATTERNS(i).op;

            wait for 5 ns;

            -- Check Result
            assert res_s = PATTERNS(i).exp_res
                report "[FAIL] Test " & integer'image(i) & " (" & PATTERNS(i).desc & ")" &
                       " Result: Got " & to_str(res_s) & 
                       ", Exp " & to_str(PATTERNS(i).exp_res)
                severity error;

            -- Check Carry Out
            -- Note: Cout is relevant primarily in ADD mode, but the hardware generates it 
            -- based on the adder logic (A_processed + B_processed + Cin) regardless of Op selection.
            assert cout_s = PATTERNS(i).exp_cout
                report "[FAIL] Test " & integer'image(i) & " (" & PATTERNS(i).desc & ")" &
                       " Cout: Got " & to_str(cout_s) & 
                       ", Exp " & to_str(PATTERNS(i).exp_cout)
                severity error;

            -- Check Overflow
            assert ovf_s = PATTERNS(i).exp_ovf
                report "[FAIL] Test " & integer'image(i) & " (" & PATTERNS(i).desc & ")" &
                       " Overflow: Got " & to_str(ovf_s) & 
                       ", Exp " & to_str(PATTERNS(i).exp_ovf)
                severity error;

        end loop;

        report "==========================================================";
        report "          ALU 1-Bit Test Completed Successfully           ";
        report "==========================================================";
        wait;
    end process;

end architecture behavioral;