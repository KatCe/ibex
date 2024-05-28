all: run_questa

run_questa:
	vsim -64 -vopt -do sim.tcl $(CMD_FLAG)

run_questa_cmd: CMD_FLAG:= -c
run_questa_cmd: run_questa