library ieee;
use ieee.numeric_bit.all;
use work.regfile_pkg.all;

entity mux_regs is
    generic (
        dataSize : natural := 64
    );
    port (
        -- Inputs: Array of 32 vectors
        inputs : in reg_array_t;
        -- Select: 5 bits to choose from 0 to 31
        sel    : in bit_vector(4 downto 0);
        -- Output: Selected vector
        dOut   : out bit_vector(dataSize-1 downto 0)
    );
end entity mux_regs;

architecture behavioral of mux_regs is
begin
    -- Asynchronous selection logic
    -- Converts the 5-bit selector to an integer index
    dOut <= inputs(to_integer(unsigned(sel)));
end architecture behavioral;