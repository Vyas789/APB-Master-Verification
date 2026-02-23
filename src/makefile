QUESTA := /home/share/questa
TEST ?= master_new_test
V ?= UVM_MEDIUM
SHELL := /bin/bash

.ONESHELL:
all:
	source $(QUESTA)
	make clean
	make compile
	make simulate
	vcover report -html apb_master_coverage.ucdb -htmldir covReport -details

clean:
	-rm -rf work/ transcript vsim.wlf wave.vcd vsim_stacktrace.vstf
	-rm -rf covReport apb_master_coverage.ucdb
	-rm apb.log simulation.log
	-rm apb_coverage.ucdb
	clear
	clear
	clear

compile:
	@echo -e "\t\t\t\t...............................COMPILING CODE.............................."
	source $(QUESTA)
	vlog -sv +acc +cover +fcover -l apb.log apb_master_top.sv 

wave:
	source $(QUESTA)
	make compile
	@echo -e "\t\t\t\t\t...............GENERATING WAVEFORM FOR TEST = $(TEST)..............."
	vsim -novopt work.top +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(V)

simulate:
	@echo -e "\t\t\t\t...........................SIMULATING TEST = $(TEST) WITH VERBOSITY = $(V)..........................."
	vsim -vopt work.top -voptargs=+acc=npr -assertdebug -l simulation.log -coverage -c -do "coverage save -onexit -assert -directive -cvg -codeAll apb_master_coverage.ucdb; run -all; exit" +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(V)
	awk ' \
		/ERROR/   { print "\033[0;91m" $$0 "\033[0m"; next } \
		/WARNING/ { print "\033[0;93m" $$0 "\033[0m"; next } \
		/INFO/    { print "\033[0;94m" $$0 "\033[0m"; next } \
		/FATAL/   { print "\033[1;31m" $$0 "\033[0m"; next } \
		{ print "\033[1;37m" $$0 "\033[0m" } \
		' simulation.log > sim.tmp && mv sim.tmp simulation.log

view:
	firefox ./covReport/index.html
