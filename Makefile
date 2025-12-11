GHDL = ghdl
FLAGS = --std=08 --ieee=synopsys
WORKDIR = ./sim/ghdl_workdir
WAVEDIR = ./sim/waves

RTL_DIR = ./rtl
TB_DIR = ./tb

FILES = $(shell find $(RTL_DIR) $(TB_DIR) -name "*.vhd")

SIM_TOP = tb_processador

all: compile run

###################### Test top level entity ######################

# Analysis and Import
compile: | $(WORKDIR)
	@echo "--- Importing files ---"
	$(GHDL) -i $(FLAGS) --workdir=$(WORKDIR) $(FILES)

	@echo "--- Analyzing and Elaborating $(SIM_TOP) ---"
	# The -m command resolves the dependency tree automatically
	$(GHDL) -m $(FLAGS) --workdir=$(WORKDIR) $(SIM_TOP)

# Execution (ghdl -r)
run: | $(WORKDIR) $(WAVEDIR)
	@echo "--- Running Simulation ---"
	# Runs and saves the waves in sim/waves/
	$(GHDL) -r $(FLAGS) --workdir=$(WORKDIR) $(SIM_TOP) --wave=$(WAVEDIR)/wave_$(SIM_TOP).ghw --stop-time=20us


###################### Test specific entity #######################

# Usage: make compile-tb TB=mux_tb
compile-tb: | $(WORKDIR)
	@if [ -z "$(TB)" ]; then \
		echo "Error: Specify the testbench with TB=tb_name"; \
		exit 1; \
	fi
	@echo "--- Compilando $(TB) ---"
	$(GHDL) -i $(FLAGS) --workdir=$(WORKDIR) $(FILES)
	$(GHDL) -m $(FLAGS) --workdir=$(WORKDIR) $(TB)

run-tb: | $(WORKDIR) $(WAVEDIR)
	@if [ -z "$(TB)" ]; then \
		echo "Error: Specify the testbench with TB=tb_name"; \
		exit 1; \
	fi
	@echo "--- Rodando $(TB) ---"
	$(GHDL) -r $(FLAGS) --workdir=$(WORKDIR) $(TB) --wave=$(WAVEDIR)/wave_$(TB).ghw --stop-time=20us

# Usage: make test TB=mux_tb
test-tb: compile-tb run-tb


######################        Cleanup        ######################

# Clean only wave files
clean-waves:
	@echo "--- Cleaning wave files ---"
	rm -rf $(WAVEDIR)/*.ghw

# Clean only workdir
clean-workdir:
	@echo "--- Cleaning workdir ---"
	$(GHDL) --clean --workdir=$(WORKDIR)
	rm -rf $(WORKDIR)

# Clean everything
clean: clean-waves clean-workdir
	@echo "--- Cleanup complete ---"

# Create directories if they don't exist
$(WORKDIR):
	mkdir -p $(WORKDIR)

$(WAVEDIR):
	mkdir -p $(WAVEDIR)

.PHONY: all compile run compile-tb run-tb test-tb clean clean-waves clean-workdir