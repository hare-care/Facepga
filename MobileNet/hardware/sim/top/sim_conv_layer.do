setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../../sv/conv/window.sv"
vlog -work work "../../sv/conv/conv.sv"
vlog -work work "../../sv/top/convolutional_layer.sv"
vlog -work work "../../sv/top/convolutional_layer_tb.sv"

vsim -voptargs=+acc +notimingchecks -L work work.convolutional_layer_tb -wlf convolutional_layer_tb.wlf

do conv_layer_wave.do

run -all