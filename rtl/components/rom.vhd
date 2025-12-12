library ieee;
use ieee.numeric_bit.all;
use std.textio.all; -- Required for file reading

entity memoriaInstrucoes is
    generic (
        addressSize : natural := 8;   -- Address bus size
        dataSize    : natural := 8;  -- Data word size (Width)
        datFileName : string  := "memInstr_conteudo.dat" -- File to load
    );
    port (
        addr : in bit_vector(addressSize-1 downto 0);
        data : out bit_vector(dataSize-1 downto 0)
    );
end entity memoriaInstrucoes;

architecture behavioral of memoriaInstrucoes is
    -- Define the memory array type
    -- The depth is determined by 2^addressSize.
    constant DEPTH : natural := 2**addressSize;
    type mem_type is array (0 to DEPTH-1) of bit_vector(dataSize-1 downto 0);

    -- Function to initialize memory from a file
    -- This function runs once at the start of the simulation.
    impure function init_mem(fileName : in string) return mem_type is
        file     fl       : text open read_mode is fileName;
        variable temp_mem : mem_type := (others => (others => '0'));
        variable current_line : line;
        variable temp_bv  : bit_vector(dataSize-1 downto 0);
        variable v_valid  : boolean; -- To check if read was successful
    begin
        -- Read file line by line
        for i in 0 to DEPTH-1 loop
            if not endfile(fl) then
                readline(fl, current_line);
                -- Attempt to read a binary string into the bit_vector
                read(current_line, temp_bv, v_valid);
                if v_valid then
                    temp_mem(i) := temp_bv;
                end if;
            else
                exit; -- Stop if end of file is reached before filling memory
            end if;
        end loop;
        return temp_mem;
    end function;

    -- 3. Declare the memory signal and initialize it
    signal mem : mem_type := init_mem(datFileName);

begin

    -- Asynchronous Read Operation
    -- The output 'data' is updated immediately when 'addr' changes.
    data <= mem(to_integer(unsigned(addr)));

end architecture behavioral;