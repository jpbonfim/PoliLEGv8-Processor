--Testbench registrador
--Grupo T2G06

library ieee;
use ieee.numeric_bit.all;

entity mux_tb is 
  generic (dataSize : natural := 6);
end entity mux_tb;

architecture behavioral of mux_tb is
  -- Componente a ser testado (Device Under Test -- DUT)
  component mux
     generic (dataSize : natural := 6);
    port(
        in0  : in bit_vector(dataSize-1 downto 0);
        in1  : in bit_vector(dataSize-1 downto 0);
        sel  : in bit;
        dOut : out bit_vector(dataSize-1 downto 0)
        );
  end component;
  
  -- Declaração de sinais para conectar o componente
  signal s_in0   : bit_vector(dataSize-1 downto 0);
  signal s_in1   : bit_vector(dataSize-1 downto 0);
  signal s_sel   : bit;
  signal s_dOut  : bit_vector(dataSize-1 downto 0);
  -- Configurações do clock
  --signal keep_simulating: bit := '0'; -- delimita o tempo de geração do clock
  --constant clockPeriod : time := 1 ns;
  
begin
  -- clk_in <= (not clk_in) and keep_simulating after clockPeriod/2; 
  
  -- Conecta DUT (Device Under Test)
  DUT: mux
    port map(in0  => s_in0,
             in1  => s_in1,
             sel  => s_sel,
             dOut => s_dOut
            );
  
  gerador_estimulos: process is
	  type pattern_type is record
	     -- Entradas
		  D0: bit_vector(dataSize-1 downto 0);
      D1: bit_vector(dataSize-1 downto 0);
      S : bit; -- 0 seleciona D0, 1 seleciona D1
       -- Saídas
		  Q: bit_vector(dataSize-1 downto 0);
	  end record;
	  
	  type pattern_array is array (natural range <>) of pattern_type;
	  constant patterns: pattern_array :=
        -- formato dos vetores de dados (sinal D0 - entrada, sinal D1 - entrada, S sel, Q saida)
        (("000010", "000011", '1',"000011"),
         ("001111", "000111", '0',"000111"),
         ("100100", "100000", '0',"100100"),
         ("000001", "001111", '1',"001111"),
         ("101000", "000000", '0',"000000"));  -- erro forçado (saída esperada errada)
   
   begin
     
     --keep_simulating <= '1';
     assert false report "simulation start" severity note;
     --teste das entradas
     assert false report "Início dos testes de entradas e saídas" severity note;
     for i in patterns'range loop
        -- Injeta as entradas
        s_sel <= patterns(i).S;
        s_in0 <= patterns(i).D0;
        s_in1 <= patterns(i).D1;
        wait for 1 ns;
        assert false report "Seletor em " & bit'image((patterns(i).S)) &
        ", Entrada D0: " & integer'image(to_integer(unsigned(patterns(i).D0))) &
        ", Entrada D1: " & integer'image(to_integer(unsigned(patterns(i).D1))) &
        ", Saída: " & integer'image(to_integer(unsigned(s_dOut))) & ", Saída esperada: " & integer'image(to_integer(unsigned(patterns(i).Q))) severity note; 
        assert s_dOut = patterns(i).Q report "ERRO, sinal da saída diferente da esperada" severity error;
        assert false report " --------- Fim do teste " & integer'image(i) & " ------------------- " severity note;
       end loop;
	  -- Informa fim do teste
	  assert false report "Testes concluídos." severity note;
     --keep_simulating <= '0';	  
	  wait;  -- pára a execução do simulador, caso contrário este process é reexecutado indefinidamente.
   end process;
   

end architecture behavioral;
