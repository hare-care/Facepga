setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../../sv/other_layers/fc.sv"
vlog -work work "../../sv/other_layers/fc_tb.sv"

vsim -voptargs=+acc +notimingchecks -L work work.fc_tb -wlf fc_tb.wlf

do fc_wave.do

run -all