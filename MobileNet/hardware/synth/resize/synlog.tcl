history clear
project -load /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -new /home/ted4152/Spring24/Facepga/MobileNet/hardware/sv/other_layers/avg_pool.prj
add_file avg_pool.sv
project -run  
project -run  
project -load /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/resize/resizer.prj
project -run  
project -run  
project -run  
project -close /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/sv/other_layers/avg_pool.prj
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/resize/resizer.prj
