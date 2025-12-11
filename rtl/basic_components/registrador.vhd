library ieee;
use ieee.numeric_bit.all;

entity registrador is 
    generic (dataSize : natural := 6);
    port(
        clock  : in bit;
        reset  : in bit;
        enable : in bit;
        d      : in bit_vector(dataSize-1 downto 0);
        q      : out bit_vector(datasize-1 downto 0)
        );
end entity registrador;

architecture behavioral of registrador is
  signal interno : bit_vector(dataSize-1 downto 0);
begin
  process(clock, reset)
  begin
    if reset = '1' then
      interno <= (others => '0');
    elsif rising_edge(clock) then
      if enable = '1' then
        interno <= d; 
      end if;
    end if;
  end process;
  q <= interno;
end behavioral;