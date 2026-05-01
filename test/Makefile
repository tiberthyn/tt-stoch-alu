# Makefile for Tiny Tapeout - Stochastic ALU
# Compatible with Icarus Verilog simulation

SIM ?= icarus
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../verilog/rtl
TB_DIR = $(PWD)/../testbench

# Project source files
PROJECT_SOURCES = user_proj.v

# Testbench source
TB_SOURCE = tb_stoch_alu.v

# Build directory
SIM_BUILD = sim_build

# Compilation flags
COMPILE_ARGS += -I$(SRC_DIR)
COMPILE_ARGS += -DRTL_SIM

all: rtl_sim

rtl_sim: $(SIM_BUILD)/sim.vvp
	@echo "RTL simulation ready. Run: vvp $(SIM_BUILD)/sim.vvp"

$(SIM_BUILD)/sim.vvp: $(TB_DIR)/$(TB_SOURCE) $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
	mkdir -p $(SIM_BUILD)
	iverilog -o $@ $(COMPILE_ARGS) \
		$(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES)) \
		$(TB_DIR)/$(TB_SOURCE)

clean:
	rm -rf $(SIM_BUILD) *.vcd *.fst sim

.PHONY: all rtl_sim clean
