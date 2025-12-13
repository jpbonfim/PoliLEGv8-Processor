library ieee;
use ieee.numeric_bit.all;

entity ram_wrapper_8x8 is
    generic (
        addressSize : natural := 7;
        dataSize    : natural := 8; -- Physical size of the base memory word (1 byte)
        datFileName : string  := "memDadosInicialPolilegv8.dat"
    );
    port (
        clock   : in bit;
        wr      : in bit;
        addr    : in bit_vector(addressSize-1 downto 0); -- Base Address
        data_i  : in bit_vector(63 downto 0);            -- 64-bit data for writing
        data_o  : out bit_vector(63 downto 0)            -- 64-bit data read
    );
end entity ram_wrapper_8x8;

architecture structural of ram_wrapper_8x8 is

    -- Signal for address arithmetic
    signal s_base_addr : unsigned(addressSize-1 downto 0);

    -- Original Data Memory Component
    component memoriaDados is
        generic (
            addressSize : natural;
            dataSize    : natural;
            datFileName : string
        );
        port (
            clock  : in bit;
            wr     : in bit;
            addr   : in bit_vector (addressSize-1 downto 0);
            data_i : in bit_vector (dataSize-1 downto 0);
            data_o : out bit_vector (dataSize-1 downto 0)
        );
    end component;

begin
    -- Converts bit vector to unsigned to sum the bank offset.
    s_base_addr <= unsigned(addr);

    -- Instantiation of the 8 components (Big Endian)
    -- Component 0: Base Address + 0 -> Bits [63-56] (Most Significant Byte)
    RAM_BANK_0: entity work.memoriaDados
        generic map (addressSize => addressSize, dataSize => dataSize, datFileName => datFileName)
        port map (
            clock  => clock,
            wr     => wr,
            addr   => bit_vector(s_base_addr), -- Address X
            data_i => data_i(63 downto 56),
            data_o => data_o(63 downto 56)
        );

    -- Component 1: Address Base + 1 -> Bits [55-48]
    RAM_BANK_1: entity work.memoriaDados
        generic map (addressSize => addressSize, dataSize => dataSize, datFileName => datFileName)
        port map (
            clock  => clock,
            wr     => wr,
            addr   => bit_vector(s_base_addr + 1),
            data_i => data_i(55 downto 48),
            data_o => data_o(55 downto 48)
        );

    -- Component 2: Address Base + 2 -> Bits [47-40]
    RAM_BANK_2: entity work.memoriaDados
        generic map (addressSize => addressSize, dataSize => dataSize, datFileName => datFileName)
        port map (
            clock  => clock,
            wr     => wr,
            addr   => bit_vector(s_base_addr + 2),
            data_i => data_i(47 downto 40),
            data_o => data_o(47 downto 40)
        );

    -- Component 3: Address Base + 3 -> Bits [39-32]
    RAM_BANK_3: entity work.memoriaDados
        generic map (addressSize => addressSize, dataSize => dataSize, datFileName => datFileName)
        port map (
            clock  => clock,
            wr     => wr,
            addr   => bit_vector(s_base_addr + 3),
            data_i => data_i(39 downto 32),
            data_o => data_o(39 downto 32)
        );

    -- Component 4: Address Base + 4 -> Bits [31-24]
    RAM_BANK_4: entity work.memoriaDados
        generic map (addressSize => addressSize, dataSize => dataSize, datFileName => datFileName)
        port map (
            clock  => clock,
            wr     => wr,
            addr   => bit_vector(s_base_addr + 4),
            data_i => data_i(31 downto 24),
            data_o => data_o(31 downto 24)
        );

    -- Component 5: Address Base + 5 -> Bits [23-16]
    RAM_BANK_5: entity work.memoriaDados
        generic map (addressSize => addressSize, dataSize => dataSize, datFileName => datFileName)
        port map (
            clock  => clock,
            wr     => wr,
            addr   => bit_vector(s_base_addr + 5),
            data_i => data_i(23 downto 16),
            data_o => data_o(23 downto 16)
        );

    -- Component 6: Address Base + 6 -> Bits [15-8]
    RAM_BANK_6: entity work.memoriaDados
        generic map (addressSize => addressSize, dataSize => dataSize, datFileName => datFileName)
        port map (
            clock  => clock,
            wr     => wr,
            addr   => bit_vector(s_base_addr + 6),
            data_i => data_i(15 downto 8),
            data_o => data_o(15 downto 8)
        );

    -- Component 7: Address Base + 7 -> Bits [7-0] (Least Significant Byte)
    RAM_BANK_7: entity work.memoriaDados
        generic map (addressSize => addressSize, dataSize => dataSize, datFileName => datFileName)
        port map (
            clock  => clock,
            wr     => wr,
            addr   => bit_vector(s_base_addr + 7),
            data_i => data_i(7 downto 0),
            data_o => data_o(7 downto 0)
        );

end architecture structural;