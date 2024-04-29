setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../../sv/other_layers/resizer.sv"
vlog -work work "../../sv/other_layers/resizer_tb.sv"

vsim -voptargs=+acc +notimingchecks -L work work.resizer_tb -wlf resizer_tb.wlf

do resize_wave.do

run -all