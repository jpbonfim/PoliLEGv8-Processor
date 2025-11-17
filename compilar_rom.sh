ghdl -a rom.vhd
ghdl -a rom_tb.vhd
ghdl -e rom_tb   
ghdl -r rom_tb --vcd=rom_test.vcd