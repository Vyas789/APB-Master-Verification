# --- Configuration Variables ---
# Update this path if your source file is named differently
TOP_FILE = apb_master_top.sv
# Update this if your top-level module name inside top.sv is different
TOP_MODULE = top
# Default Test Name
TEST ?= apb_master_test
# Default Verbosity
V ?= UVM_MEDIUM

# Tools and Paths
QUESTA := /home/share/questa
SHELL := /bin/bash
COV_DB_NAME = apb_coverage.ucdb
REPORT_DIR = covReport

.ONESHELL:

# --- Main Targets ---

all:
	source $(QUESTA)
	make compile
	make simulate
	# Generate HTML coverage report after simulation
	vcover report -html $(COV_DB_NAME) -htmldir $(REPORT_DIR) -details

# --- Clean Up ---
clean:
	-rm -rf work/ transcript vsim.wlf dump.vcd vsim_stacktrace.vstf
	-rm -rf $(REPORT_DIR) $(COV_DB_NAME)
	-rm -f apb.log simulation.log
	-rm -f *.ucdb
	clear

# --- Compilation ---
compile:
	make clean
	@echo -e "\n\t\t\t\t...............................COMPILING APB PROJECT.............................."
	source $(QUESTA)
	# +acc enables visibility for waveforms
	# +cover +fcover enables code and functional coverage
	vlog -sv +acc +cover +fcover -l apb.log $(TOP_FILE)

# --- Waveform Viewing (GUI Mode) ---
wave:
	source $(QUESTA)
	make compile
	@echo -e "\n\t\t\t\t\t...............OPENING WAVEFORM FOR TEST = $(TEST)..............."
	# Runs vsim without -c to open the GUI
	# -voptargs=+acc ensures signals are visible for debugging
	vsim -voptargs=+acc work.$(TOP_MODULE) +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(V) -do "add wave -r /*; run -all"

# --- Batch Simulation (No GUI) ---
simulate:
	source $(QUESTA)
	@echo -e "\n\t\t\t\t...........................SIMULATING TEST = $(TEST) WITH VERBOSITY = $(V)..........................."
	# -c runs in command line mode (faster)
	# -coverage enables coverage collection
	vsim +define+UVM_REG_NO_INDIVIDUAL_FIELD_ACCESS \
	-vopt work.$(TOP_MODULE) \
	-voptargs=+acc=npr \
	-assertdebug \
	-l simulation.log \
	-coverage \
	-c \
	-do "coverage save -onexit -assert -directive -cvg -codeAll $(COV_DB_NAME); run -all; exit" \
	+UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(V)

# --- View Coverage Report ---
view:
	@echo -e "\n\t\t\t\t...............OPENING COVERAGE REPORT..............."
	firefox ./$(REPORT_DIR)/index.html &
