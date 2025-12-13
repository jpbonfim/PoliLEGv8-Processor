library ieee;
use ieee.numeric_bit.all;

package regfile_pkg is
    -- Defines the width of the data path (64 bits for PoliLEGv8)
    constant dataSize : natural := 64;
    
    -- Array type to hold outputs of all 32 registers
    type reg_array_t is array (0 to 31) of bit_vector(dataSize-1 downto 0);
end package regfile_pkg;