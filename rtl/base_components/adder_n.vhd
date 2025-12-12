library ieee;
use ieee.numeric_bit.all;

entity adder_n is
    generic (dataSize: natural := 64);
    port(
        in0  : in bit_vector(dataSize-1 downto 0);
        in1  : in bit_vector(dataSize-1 downto 0);
        sum  : out bit_vector(dataSize-1 downto 0);
        cOut : out bit
    );
end entity adder_n;

architecture behavioral of adder_n is
    -- Signal to hold the result with an extra bit for Carry Out
    signal full_sum : unsigned(dataSize downto 0);
begin
    -- Convert inputs to unsigned
    -- Resize them to (dataSize + 1) to accommodate potential overflow
    -- Perform addition
    full_sum <= resize(unsigned(in0), dataSize + 1) + resize(unsigned(in1), dataSize + 1);

    -- Assign the lower 'dataSize' bits to sum
    sum <= bit_vector(full_sum(dataSize-1 downto 0));

    -- Assign the Most Significant Bit (MSB) to carry out
    cOut <= bit(full_sum(dataSize));

end architecture behavioral;