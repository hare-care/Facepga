setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../../sv/conv/window.sv"
vlog -work work "../../sv/conv/conv.sv"
vlog -work work "../../sv/conv/conv_tb_img_compress.sv"

vsim -voptargs=+acc +notimingchecks -L work work.conv_tb_img_compress -wlf conv_tb_img_compress.wlf

do conv_wave_compress.do

run -all