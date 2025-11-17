library ieee;
use ieee.numeric_bit.all;

entity mux is
    generic (dataSize : natural := 64);
    port(
        in0  : in bit_vector(dataSize-1 downto 0);
        in1  : in bit_vector(dataSize-1 downto 0);
        sel  : in bit;
        dOut : out bit_vector(dataSize-1 downto 0 )
       );
end entity mux;


architecture behavioral of mux is    

begin 
   dOut <= in0 when sel = '0' else
           in1 when sel = '1';

end behavioral;



