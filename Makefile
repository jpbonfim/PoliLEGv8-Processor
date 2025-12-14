GHDL = ghdl
FLAGS = --std=08 --ieee=synopsys
WORKDIR = ./sim/ghdl_workdir
WAVEDIR = ./sim/waves

RTL_DIR = ./rtl
TB_DIR = ./tb
QUARTUS_DIR = ./quartus/components
MODEL_SIM_DIR = ./model_sim
FIRMWARE_DIR = ./firmware

FILES = $(shell find $(RTL_DIR) $(TB_DIR) -name "*.vhd")

SIM_TOP = polilegv8_tb

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


######################        Quartus        ######################

# Copy VHDL files to Quartus project structure
add-to-quartus:
	@echo "--- Copying RTL files to Quartus ---"
	@mkdir -p $(QUARTUS_DIR)/rtl
	@find $(RTL_DIR) -name "*.vhd" -exec cp {} $(QUARTUS_DIR)/rtl/ \;
	@echo "--- Copying TB files to Quartus ---"
	@mkdir -p $(QUARTUS_DIR)/tb
	@find $(TB_DIR) -name "*.vhd" -exec cp {} $(QUARTUS_DIR)/tb/ \;
	@echo "--- Files copied successfully ---"

# Remove Quartus components folder
clean-quartus:
	@echo "--- Removing Quartus components ---"
	@rm -rf $(QUARTUS_DIR)/
	@echo "--- Quartus components removed ---"


######################       Model Sim       ######################

# Copy VHDL files to Model sim project structure
add-to-modelsim:
	@echo "--- Copying RTL files to Model Sim ---"
	@mkdir -p $(MODEL_SIM_DIR)/
	@find $(RTL_DIR) -name "*.vhd" -exec cp {} $(MODEL_SIM_DIR)/ \;
	@echo "--- Copying TB files to Model Sim ---"
	@find $(TB_DIR) -name "*.vhd" -exec cp {} $(MODEL_SIM_DIR)/ \;
	@echo "--- Copying FIRMWARE/MEMORY files to Model Sim ---"
	@find $(FIRMWARE_DIR) -name "*.dat" -exec cp {} $(MODEL_SIM_DIR)/ \;
	@echo "--- Files copied successfully ---"

clean-modelsim:
	@echo "--- Removing Model Sim components ---"
	@rm -rf $(MODEL_SIM_DIR)/
	@echo "--- Model Sim components removed ---"

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

.PHONY: all compile run compile-tb run-tb test-tb add-to-quartus clean-quartus clean clean-waves clean-workdir add-to-modelsim clean-modelsim