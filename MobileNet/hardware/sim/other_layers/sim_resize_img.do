setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../../sv/other_layers/resizer.sv"
vlog -work work "../../sv/other_layers/resizer_tb_img.sv"

vsim -voptargs=+acc +notimingchecks -L work work.resizer_tb_img -wlf resizer_tb_img.wlf

do resize_wave_img.do

run -all