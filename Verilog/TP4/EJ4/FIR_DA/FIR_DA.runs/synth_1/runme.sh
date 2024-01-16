#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
# Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/mnt/sda1/Xilinx/Vitis/2023.1/bin:/mnt/sda1/Xilinx/Vivado/2023.1/ids_lite/ISE/bin/lin64:/mnt/sda1/Xilinx/Vivado/2023.1/bin
else
  PATH=/mnt/sda1/Xilinx/Vitis/2023.1/bin:/mnt/sda1/Xilinx/Vivado/2023.1/ids_lite/ISE/bin/lin64:/mnt/sda1/Xilinx/Vivado/2023.1/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/mnt/sda1/Cursos/DDA/Practica/TP4/EJ4/FIR_DA/FIR_DA.runs/synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log fir_DA_folded.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source fir_DA_folded.tcl
