--Testbench registrador
--Grupo T2G06

library ieee;
use ieee.numeric_bit.all;


entity registrador_tb is 
  generic (dataSize : natural := 6);

end entity registrador_tb;

architecture behavioral of registrador_tb is
  -- Componente a ser testado (Device Under Test -- DUT)
  component registrador
    generic (dataSize : natural := 6);
    port(
        clock  : in bit;
        reset  : in bit;
        enable : in bit;
        d      : in bit_vector(dataSize-1 downto 0);
        q      : out bit_vector(dataSize-1 downto 0)
        );
  end component;
  
  -- Declaração de sinais para conectar o componente
  signal clk_in    : bit;
  signal rst_in    : bit;
  signal enable_in : bit;
  signal d_in      : bit_vector(dataSize-1 downto 0);
  signal q_out     : bit_vector(dataSize-1 downto 0);

  
  -- Configurações do clock
  signal keep_simulating: bit := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 1 ns;
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;
  
  ---- O código abaixo, sem o "keep_simulating", faria com que o clock executasse
  ---- indefinidamente, de modo que a simulação teria que ser interrompida manualmente
  -- clk_in <= (not clk_in) after clockPeriod/2; 
  
  -- Conecta DUT (Device Under Test)
  DUT: registrador
    port map(clock =>   clk_in,
             reset =>   rst_in,
             enable =>  enable_in,
             d =>       d_in,
             q =>       q_out
            );
  
  gerador_estimulos: process is
	  type pattern_type is record
	     -- Entradas
		   D:    bit_vector(dataSize-1 downto 0);
       -- Saídas
		   Q: bit_vector(dataSize-1 downto 0);
	  end record;
	  
	  type pattern_array is array (natural range <>) of pattern_type;
	  constant patterns: pattern_array :=
        -- formato dos vetores de dados (sinal D - entrada, sinal Q - saida esperada)
        (("000010", "000010"),
         ("100000", "100000"),
         ("000001", "000011"));  -- erro forçado (saída esperada errada)
   
   begin
     
     keep_simulating <= '1';
     assert false report "simulation start" severity note;
     rst_in <= '1';
     wait for clockPeriod;
     rst_in <= '0';
     enable_in <= '1';
     --teste do reset
     assert false report "Inicio do teste do reset" severity note;
     for i in patterns'range loop
      -- Injeta as entradas
        d_in <= patterns(i).D;
       wait for clockPeriod;
       enable_in <= '0';
       rst_in <= '0';
       wait for 1 ns;
     end loop;
     rst_in <= '0';
     assert rst_in /= '1' report "reset ativado, o valor de saida eh: " & integer'image(to_integer(unsigned(q_out))) severity note;
     assert rst_in = '1' report "Erro no reset, o valor de saida eh: " & integer'image(to_integer(unsigned(q_out))) severity error;
     
     enable_in <= '1';
     wait for clockPeriod;
     --teste das entradas
     assert false report "Inicio do teste de entradas e saidas" severity note;
     for i in patterns'range loop
         -- Injeta as entradas
           d_in <= patterns(i).D;
        wait for clockPeriod;
        assert d_in /= patterns(i).D report "o valor de entrada eh: " & integer'image(to_integer(unsigned(patterns(i).D))) severity note; 
        assert q_out /= patterns(i).Q report "o valor de saida foi: " & integer'image(to_integer(unsigned(patterns(i).Q))) severity note; 
        assert q_out = patterns(i).Q report "ERRO na saída dos dados, a saida esperada eh: " & integer'image(to_integer(unsigned(patterns(i).Q))) & " a saida obtida foi " & integer'image(to_integer(unsigned(q_out)))  severity error;  
        assert q_out /= patterns(i).Q report "OK " & integer'image(to_integer(unsigned(patterns(i).Q))) severity note;
       end loop;
     enable_in <= '0';
	  -- Informa fim do teste
	  assert false report "Teste concluido." severity note;
     keep_simulating <= '0';	  
	  wait;  -- para a execução do simulador, caso contrário este process é reexecutado indefinidamente.
   end process;
   

end architecture behavioral;
