setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../../../sv/conv/window.sv"
vlog -work work "../../../sv/conv/conv.sv"
vlog -work work "../../../sv/top/convolutional_layer.sv"
vlog -work work "../../../sv/top/network_components.sv"
vlog -work work "../../../sv/other_layers/resizer.sv"
vlog -work work "../../../sv/other_layers/fc.sv"
vlog -work work "../../../sv/other_layers/avg_pool/div_synth.sv"
vlog -work work "../../../sv/other_layers/avg_pool/avg_pool.sv"
vlog -work work "../../../sv/top/processing_state_controller.sv"
vlog -work work "../../../sv/top/top_tb.sv"

vsim -voptargs=+acc +notimingchecks -L work work.top_tb -wlf top_tb.wlf

do top_wave.do

run -all