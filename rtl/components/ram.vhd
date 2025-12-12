library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity memoriaDados is
    generic (
        addressSize : natural := 8;
        dataSize    : natural := 8;
        datFileName : string  := "memDados_conteudo_inicial.dat"
    );
    port (
        clock  : in bit;
        wr     : in bit; -- Write Enable
        addr   : in bit_vector(addressSize-1 downto 0);
        data_i : in bit_vector(dataSize-1 downto 0);
        data_o : out bit_vector(dataSize-1 downto 0)
    );
end entity memoriaDados;

architecture behavioral of memoriaDados is
    -- Define Memory Type
    constant DEPTH : natural := 2**addressSize;
    type mem_type is array (0 to DEPTH-1) of bit_vector(dataSize-1 downto 0);

    -- File Loading Function (Same logic as ROM)
    impure function init_mem(fileName : in string) return mem_type is
        file fl : text open read_mode is fileName;
        variable current_line : line;
        variable temp_bv : bit_vector(dataSize-1 downto 0);
        variable temp_mem : mem_type := (others => (others => '0'));
        variable v_valid : boolean;
    begin
        for i in 0 to DEPTH-1 loop
            if not endfile(fl) then
                readline(fl, current_line);
                read(current_line, temp_bv, v_valid);
                if v_valid then
                    temp_mem(i) := temp_bv;
                end if;
            end if;
        end loop;
        return temp_mem;
    end function;

    -- Declare and Initialize RAM Signal
    signal ram : mem_type := init_mem(datFileName);

begin

    -- Synchronous Write Process
    process(clock)
    begin
        if rising_edge(clock) then
            if wr = '1' then
                ram(to_integer(unsigned(addr))) <= data_i;
            end if;
        end if;
    end process;

    -- Asynchronous Read
    -- Reading do not depend on the clock 
    data_o <= ram(to_integer(unsigned(addr)));

end architecture behavioral;