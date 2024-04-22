setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../../sv/conv/window.sv"
vlog -work work "../../sv/conv/conv.sv"
vlog -work work "../../sv/conv/conv_tb_img.sv"

vsim -voptargs=+acc +notimingchecks -L work work.conv_tb_img -wlf conv_tb_img.wlf

do conv_wave_img.do

run -all