ghdl -a registrador.vhd
ghdl -a registrador_tb.vhd
ghdl -e registrador_tb   
ghdl -r registrador_tb --vcd=reg_test.vcd