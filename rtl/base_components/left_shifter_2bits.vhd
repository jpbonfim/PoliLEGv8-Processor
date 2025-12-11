entity two_left_shifts is
    generic (
        dataSize : natural := 64
    );
    port(
        input : in bit_vector(dataSize-1 downto 0);
        output : out bit_vector (dataSize-1 downto 0)
    );
end entity two_left_shifts;

architecture structural of two_left_shifts is
begin
    -- The 2 most significant bits of the input are discarded.
    -- The 2 least significant bits of the output are filled with '0'.
    output <= input(dataSize-3 downto 0) & "00";

end architecture structural;