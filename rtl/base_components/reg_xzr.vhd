library ieee;
use ieee.numeric_bit.all;

entity reg_xzr is 
    generic (dataSize : natural := 64);
    port(
        clock  : in bit;
        reset  : in bit;
        enable : in bit;
        d      : in bit_vector(dataSize-1 downto 0);
        q      : out bit_vector(datasize-1 downto 0)
        );
end entity reg_xzr;

-- Register x31 (xZR)
-- Description: Always outputs zero, ignores load/clock/reset for storage.
architecture hardwired_zero of reg_xzr is
  signal data : bit_vector(dataSize-1 downto 0);
begin
    -- Hardwired to zero regardless of inputs
    q <= (others => '0');
end hardwired_zero;