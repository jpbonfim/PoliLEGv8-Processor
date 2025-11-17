ghdl -a mux.vhd
ghdl -a mux_tb.vhd
ghdl -e mux_tb   
ghdl -r mux_tb --vcd=mux_test.vcd