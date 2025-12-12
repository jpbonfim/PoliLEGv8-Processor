library ieee;
use ieee.numeric_bit.all;

entity sign_extend is
    generic (
        dataISize       : natural := 32;
        dataOSize       : natural := 64;
        dataMaxPosition : natural := 5  -- It should always be log2(dataISize)
    );
    port(
        inData      : in bit_vector(dataISize-1 downto 0);
        inDataStart : in bit_vector(dataMaxPosition-1 downto 0);
        inDataEnd   : in bit_vector(dataMaxPosition-1 downto 0);
        outData     : out bit_vector(dataOSize-1 downto 0)
    );
end entity sign_extend;

architecture behavioral of sign_extend is
begin
    process(inData, inDataStart, inDataEnd)
        variable idx_start : integer;
        variable idx_end   : integer;
        variable width     : integer; -- Width of the extracted segment
        variable sign_bit  : bit;
    begin
        idx_start := to_integer(unsigned(inDataStart));
        idx_end   := to_integer(unsigned(inDataEnd));

        -- Determine the sign bit (MSB of the selection)
        -- It does not perform a safety check because it trusts that dataMaxPosition was instantiated correctly (log2(dataISize))
        sign_bit := inData(idx_start);

        -- Calculate width of the valid data segment
        if idx_start >= idx_end then
            width := idx_start - idx_end + 1;
        else
            width := 0; -- Invalid range
        end if;

        -- Loop to generate output bits
        for k in 0 to dataOSize-1 loop
            if k < width then
                -- Copy data bits
                -- outData(0) gets inData(idx_end)
                -- outData(1) gets inData(idx_end + 1), etc.
                outData(k) <= inData(idx_end + k);
            else
                -- Phase 2: Sign Extension
                -- All upper bits receive the sign bit
                outData(k) <= sign_bit;
            end if;
        end loop;
    end process;

end architecture behavioral;