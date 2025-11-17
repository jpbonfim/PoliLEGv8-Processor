--Testbench memoria rom de instruções
--Grupo T2G06

library ieee;
use ieee.numeric_bit.ALL;
use std.textio.all;

entity rom_tb is 
  generic(
        addressSize : natural := 8;
        dataSize    : natural := 8
        );
end entity rom_tb;

architecture behavioral of rom_tb is
  -- Componente a ser testado (Device Under Test -- DUT)
  component rom
     generic(
        addressSize : natural := 8;
        dataSize    : natural := 8;
        datFileName : String  := "rom.dat"
        );
    port(
        addr : in bit_vector(addressSize-1 downto 0);
        data : out bit_vector(dataSize-1 downto 0)
        );
  end component;
  
  -- Declaração de sinais para conectar o componente
  signal s_addr  : bit_vector(addressSize-1 downto 0);
  signal s_data  : bit_vector(dataSize-1 downto 0);
  -- Configurações do clock
  --signal keep_simulating: bit := '0'; -- delimita o tempo de geração do clock
  --constant clockPeriod : time := 1 ns;
  
begin
  --clk_in <= (not clk_in) and keep_simulating after clockPeriod/2; 
  
  -- Conecta DUT (Device Under Test)
  DUT: rom
    port map(addr  => s_addr,
             data  => s_data
            );
   
  gerador_estimulos: process is
      
	  file tb_file : text open read_mode is "rom_estimulo_tb.dat";
	  variable tb_line : line;
    variable space   : character;
	  variable addr    : bit_vector(addressSize-1 downto 0); 
    variable data    : bit_vector(dataSize-1 downto 0);
	     
   begin
     -- LEITURA DO ARQUIVO GERADOR DE ESTÍMULOS "rom_estimulo_tb.dat"
      while not endfile(tb_file) loop  -- Enquanto não chegar no final do arquivo ...
         readline(tb_file, tb_line);  -- Lê a próxima linha
         read(tb_line, addr);   -- Da linha que foi lida, lê o primeiro parâmetro (endereço do dado procurado)
         read(tb_line, space); -- Lê o espaço após o primeiro parâmetro (separador)
         read(tb_line, data); -- Da linha que foi lida, lê o segundo parâmetro (dados esperados)
		 -- Agora que já lemos o caso de teste (par estímulo/saída esperada), vamos aplicar os sinais.
		 s_addr <= addr;
		 wait for 5 ns; -- Aguarda a produção das saídas
         --  Verifica os sinal do endereço e o dado lido, os proximos dois asserts sempre aparecem em caso de funcionamento normal
         assert s_addr /= addr report "Endereço " & integer'image(to_integer(unsigned(addr))) & " acessado pela ROM " severity note;
         assert s_data /= data report "tem armazenado o seguinte dado: " & integer'image(to_integer(unsigned(s_data))) & " => teste OK" severity note;
         
         -- a mensagem abaixo só ira aparecer em caso de erro, se o dado esperado for diferente do lido na memoria
         assert s_data = data report "com o dado " & integer'image(to_integer(unsigned(s_data))) & " que é diferente do valor " 
         & integer'image(to_integer(unsigned(data))) & " esperado pelo testbench" severity error; 
         assert false report "--------------- Endereço lido e dado entregue ------------------- " severity note;
       end loop;
      file_close(tb_file);

	  -- Informa fim do teste
	  assert false report "Teste concluido." severity note;	  
	  wait;  -- pára a execução do simulador, caso contrário este process é reexecutado indefinidamente.
   end process;   

end architecture behavioral;
