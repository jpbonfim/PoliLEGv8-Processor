library ieee;
use ieee.numeric_bit.all;

entity decoder_5x32 is
    port (
        addr    : in bit_vector(4 downto 0);
        enable  : in bit; -- Global write enable for regfile
        decoded : out bit_vector(31 downto 0)
    );
end entity decoder_5x32;

architecture behavioral of decoder_5x32 is
begin
    process (addr, enable)
        variable idx : integer;
    begin
        -- Default: all outputs zero
        decoded <= (others => '0');
        
        -- If write is enabled, set the specific bit
        if enable = '1' then
            idx := to_integer(unsigned(addr));
            decoded(idx) <= '1';
        end if;
    end process;
end architecture behavioral;