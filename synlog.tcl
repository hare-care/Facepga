history clear
project -load /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -load /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/resize/resizer.prj
project -load /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/conv/conv.prj
project -load /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/fc/fc.prj
project -load /home/ted4152/Spring24/Facepga/MobileNet/hardware/sv/conv/conv.prj
project -new /home/ted4152/Spring24/Facepga/MobileNet/hardware/sv/conv/conv_1.prj
add_file conv.sv
add_file window.sv
add_file ../other_layers/fc.sv
add_file ../other_layers/resizer.sv
add_file ../other_layers/avg_pool/avg_pool.sv
add_file ../other_layers/avg_pool/div_synth.sv
add_file ../top/convolutional_layer.sv
add_file ../top/network_components.sv
add_file ../top/processing_state_controller.sv
set_option -top_module cnn
project -run  
set_option -top_module conv
project -run  
set_option -top_module resizer
project -run  
set_option -top_module processing_state_controller
project -run  
set_option -top_module network_components
design close d:1
project -run  
set_option -top_module fc
project -run  
set_option -top_module avg_pool
project -run  
set_option -top_module div_synth
project -run  
set_option -top_module div
project -run  
project -close /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/resize/resizer.prj
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/conv/conv.prj
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/fc/fc.prj
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/sv/conv/conv.prj
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/sv/conv/conv_1.prj
