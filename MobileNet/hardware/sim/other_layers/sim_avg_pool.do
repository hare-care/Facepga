setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../../sv/other_layers/avg_pool/div.sv"
vlog -work work "../../sv/other_layers/avg_pool/avg_pool.sv"
vlog -work work "../../sv/other_layers/avg_pool/avg_pool_tb.sv"

vsim -voptargs=+acc +notimingchecks -L work work.avg_pool_tb -wlf avg_pool_tb.wlf

do avg_pool_wave.do

run -all