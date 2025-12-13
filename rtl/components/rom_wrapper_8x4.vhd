library ieee;
use ieee.numeric_bit.all;

entity rom_wrapper_8x4 is
    generic (
        addressSize : natural := 7;
        dataSize    : natural := 8;
        datFileName : string  := "memInstrPolilegv8.dat"
    );
    port (
        addr : in bit_vector(addressSize-1 downto 0);
        data : out bit_vector(31 downto 0) -- Output is 4 * dataSize = 4 * 8 = 32 bits (instruction size)
    );
end entity rom_wrapper_8x4;

architecture structural of rom_wrapper_8x4 is

    -- Internal signal for address arithmetic
    signal s_base_addr : unsigned(addressSize-1 downto 0);
    
    -- Outputs from each memory bank
    signal s_byte0 : bit_vector(dataSize-1 downto 0);
    signal s_byte1 : bit_vector(dataSize-1 downto 0);
    signal s_byte2 : bit_vector(dataSize-1 downto 0);
    signal s_byte3 : bit_vector(dataSize-1 downto 0);

    -- Declaration of the original 8-bit memory component
    component memoriaInstrucoes is
        generic (
            addressSize : natural;
            dataSize    : natural;
            datFileName : string
        );
        port (
            addr : in bit_vector (addressSize-1 downto 0);
            data : out bit_vector (dataSize-1 downto 0)
        );
    end component;

begin
    -- Convert input vector to unsigned for arithmetic
    s_base_addr <= unsigned(addr);

    -- Bank 0: Reads address X (Most Significant Byte - Big Endian)
    ROM_BANK_0: memoriaInstrucoes
        generic map (
            addressSize => addressSize,
            dataSize    => dataSize,
            datFileName => datFileName
        )
        port map (
            addr => bit_vector(s_base_addr), 
            data => s_byte0
        );

    -- Bank 1: Reads address X + 1
    ROM_BANK_1: memoriaInstrucoes
        generic map (
            addressSize => addressSize,
            dataSize    => dataSize,
            datFileName => datFileName
        )
        port map (
            addr => bit_vector(s_base_addr + 1),
            data => s_byte1
        );

    -- Bank 2: Reads address X + 2
    ROM_BANK_2: memoriaInstrucoes
        generic map (
            addressSize => addressSize,
            dataSize    => dataSize,
            datFileName => datFileName
        )
        port map (
            addr => bit_vector(s_base_addr + 2),
            data => s_byte2
        );

    -- Bank 3: Reads address X + 3 (Least Significant Byte)
    ROM_BANK_3: memoriaInstrucoes
        generic map (
            addressSize => addressSize,
            dataSize    => dataSize,
            datFileName => datFileName
        )
        port map (
            addr => bit_vector(s_base_addr + 3),
            data => s_byte3
        );

    -- Concatenate bytes to form 32-bit instruction (Big Endian)
    data <= s_byte0 & s_byte1 & s_byte2 & s_byte3;

end architecture structural;