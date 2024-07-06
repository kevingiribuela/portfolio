## This file is a general .xdc for the ARTY Rev. B
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Reloj
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports {i_clk}];
set_property -dict { PACKAGE_PIN C2    IOSTANDARD LVCMOS33 } [get_ports { i_rst }]; #IO_L16P_T2_35 Sch=ck_rst