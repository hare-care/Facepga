setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../../sv/conv/window.sv"
vlog -work work "../../sv/conv/window_tb.sv"

vsim -voptargs=+acc +notimingchecks -L work work.window_tb -wlf window_tb.wlf

do window_wave.do

run -all