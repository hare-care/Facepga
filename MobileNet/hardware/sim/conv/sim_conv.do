setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../../sv/conv/window.sv"
vlog -work work "../../sv/conv/conv.sv"
vlog -work work "../../sv/conv/conv_tb.sv"

vsim -voptargs=+acc +notimingchecks -L work work.conv_tb -wlf conv_tb.wlf

do conv_wave.do

run -all