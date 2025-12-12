library ieee;
use ieee.numeric_bit.all;

entity sign_extend_tb is
end entity sign_extend_tb;

architecture test of sign_extend_tb is    
    -- Configuration matching the entity defaults
    constant I_SIZE    : natural := 32;
    constant O_SIZE    : natural := 64;
    constant POS_WIDTH : natural := 5;

    -- Signals
    signal inData_s  : bit_vector(I_SIZE-1 downto 0);
    signal inStart_s : bit_vector(POS_WIDTH-1 downto 0);
    signal inEnd_s   : bit_vector(POS_WIDTH-1 downto 0);
    signal outData_s : bit_vector(O_SIZE-1 downto 0);

    -- Helper to convert int to bit_vector for positions
    function to_pos(n : natural) return bit_vector is
    begin
        return bit_vector(to_unsigned(n, POS_WIDTH));
    end function;

begin
    DUT: entity work.sign_extend
    generic map (
        dataISize       => I_SIZE,
        dataOSize       => O_SIZE,
        dataMaxPosition => POS_WIDTH
    )
    port map (
        inData      => inData_s,
        inDataStart => inStart_s,
        inDataEnd   => inEnd_s,
        outData     => outData_s
    );

    test_proc: process
        -- Helper for reporting
        function to_str(bv : bit_vector) return string is
        begin
            return integer'image(to_integer(unsigned(bv)));
        end function;
    begin
        report "=========================================";
        report "Starting Sign Extender Verification";
        report "=========================================";

        -- =========================================================
        -- Case 1: The Example from the Document
        -- inData = ...00010001
        -- Start=4, End=1
        -- Extracted: bits 4 down to 1 are "1000" (Decimal 8, but bit 4 is '1', so it's negative in 4 bits context: -8)
        -- Sign bit is bit 4 ('1').
        -- Expected Output: 111...1111000 (Sign extended)
        -- =========================================================
        inData_s  <= (4 => '1', 0 => '1', others => '0'); -- ...010001
        inStart_s <= to_pos(4);
        inEnd_s   <= to_pos(1);
        wait for 10 ns;

        -- Verification:
        -- Lower part is "1000".
        -- Upper part (bits 4 to 63) should be '1'.
        
        assert outData_s(3 downto 0) = "1000"
            report "Case 1 Fail: Data extraction incorrect." severity error;
            
        assert outData_s(O_SIZE-1 downto 4) = (O_SIZE-1 downto 4 => '1')
            report "Case 1 Fail: Sign extension incorrect." severity error;

        report "[PASS] Document Example (Start=4, End=1) verified.";

        -- =========================================================
        -- Case 2: Positive Number Extension
        -- Extract bits 2 to 0. Value "011" (3). Sign bit at pos 2 is '0'.
        -- Expected: 00...00011
        -- =========================================================
        inData_s  <= (1 => '1', 0 => '1', others => '0'); -- ...000011
        inStart_s <= to_pos(2);
        inEnd_s   <= to_pos(0);
        wait for 10 ns;

        assert outData_s(2 downto 0) = "011" 
            report "Case 2 Fail: Extraction." severity error;
        assert outData_s(O_SIZE-1 downto 3) = (O_SIZE-1 downto 3 => '0') 
            report "Case 2 Fail: Extension should be 0s." severity error;

        report "[PASS] Positive Number Extension verified.";

        -- =========================================================
        -- Case 3: Single Bit Negative
        -- Extract bit 5 only. Bit 5 is '1'.
        -- Expected: 111...111
        -- =========================================================
        inData_s  <= (5 => '1', others => '0');
        inStart_s <= to_pos(5);
        inEnd_s   <= to_pos(5);
        wait for 10 ns;

        assert outData_s = (O_SIZE-1 downto 0 => '1') 
            report "Case 3 Fail: All bits should be 1." severity error;

        report "[PASS] Single Bit Negative Extension verified.";

        report "=========================================";
        report "Sign Extender Test Completed.";
        report "=========================================";
        wait;
    end process;

end architecture test;