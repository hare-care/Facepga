history clear
project -load /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -load /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/resize/resizer.prj
project -new /home/ted4152/Spring24/Facepga/MobileNet/hardware/sv/other_layers/avg_pool/div_synth.prj
add_file div_synth.sv
add_file avg_pool.sv
project -run  
design close d:0
project -run  
project -close /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/resize/resizer.prj
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/sv/other_layers/avg_pool/div_synth.prj
