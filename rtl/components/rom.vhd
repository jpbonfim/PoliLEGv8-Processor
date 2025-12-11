library ieee;
use ieee.numeric_bit.ALL;
use std.textio.all;

entity rom is 
    generic(
        addressSize : natural := 8;
        dataSize    : natural := 8;
        datFileName : String  := "rom.dat"
        );
    port(
        addr : in bit_vector(addressSize-1 downto 0);
        data : out bit_vector(dataSize-1 downto 0)
        );
end rom;
 
architecture behavioral of rom is 
  constant depth : natural := 256; --2**addressSize;
  type mem is array (0 to depth-1) of bit_vector(dataSize-1 downto 0); 

    impure function init_mem(file_name : in string) return mem is 
        file arquivo      : text open read_mode is file_name;
        variable linha    : line;
        variable temp_bv  : bit_vector(dataSize-1 downto 0);
        variable temp_mem : mem;
    begin 
        for i in mem'range loop
            readline(arquivo, linha);
            read(linha, temp_bv);
            temp_mem(i) := temp_bv;
        end loop;
        file_close(arquivo);
        return temp_mem;
    end;       
constant rom_i : mem := init_mem(datFileName);
begin
    data <= rom_i(to_integer(unsigned(addr)));
end behavioral;