# Copyright (C) 2018  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details.

# Quartus Prime Version 18.1.0 Build 625 09/12/2018 SJ Standard Edition
# File: D:\intelFPGAProject\cmos_sdram_vga\tcl\cmos_sdram_vga.tcl
# Generated on: Tue Jul 05 19:20:39 2022

package require ::quartus::project

set_location_assignment PIN_E1 -to clk
set_location_assignment PIN_E15 -to rst_n
set_location_assignment PIN_F6 -to cmos_vsync
set_location_assignment PIN_D1 -to cmos_href
set_location_assignment PIN_F5 -to cmos_din[0]
set_location_assignment PIN_G5 -to cmos_din[1]
set_location_assignment PIN_D4 -to cmos_din[2]
set_location_assignment PIN_M1 -to cmos_din[3]
set_location_assignment PIN_F3 -to cmos_din[4]
set_location_assignment PIN_F2 -to cmos_din[5]
set_location_assignment PIN_E5 -to cmos_din[6]
set_location_assignment PIN_C3 -to cmos_din[7]
set_location_assignment PIN_D5 -to cmos_pclk
set_location_assignment PIN_D3 -to cmos_xclk
set_location_assignment PIN_G2 -to cmos_pwdn
set_location_assignment PIN_F1 -to cmos_reset
set_location_assignment PIN_C6 -to cmos_scl
set_location_assignment PIN_D6 -to cmos_sda
set_location_assignment PIN_T8 -to sdram_addr[0]
set_location_assignment PIN_P9 -to sdram_addr[1]
set_location_assignment PIN_T9 -to sdram_addr[2]
set_location_assignment PIN_R9 -to sdram_addr[3]
set_location_assignment PIN_L16 -to sdram_addr[4]
set_location_assignment PIN_L15 -to sdram_addr[5]
set_location_assignment PIN_N16 -to sdram_addr[6]
set_location_assignment PIN_N15 -to sdram_addr[7]
set_location_assignment PIN_P16 -to sdram_addr[8]
set_location_assignment PIN_P15 -to sdram_addr[9]
set_location_assignment PIN_R8 -to sdram_addr[10]
set_location_assignment PIN_R16 -to sdram_addr[11]
set_location_assignment PIN_T15 -to sdram_addr[12]
set_location_assignment PIN_R5 -to sdram_dq[0]
set_location_assignment PIN_T4 -to sdram_dq[1]
set_location_assignment PIN_T3 -to sdram_dq[2]
set_location_assignment PIN_R3 -to sdram_dq[3]
set_location_assignment PIN_T2 -to sdram_dq[4]
set_location_assignment PIN_R1 -to sdram_dq[5]
set_location_assignment PIN_P2 -to sdram_dq[6]
set_location_assignment PIN_P1 -to sdram_dq[7]
set_location_assignment PIN_R13 -to sdram_dq[8]
set_location_assignment PIN_T13 -to sdram_dq[9]
set_location_assignment PIN_R12 -to sdram_dq[10]
set_location_assignment PIN_T12 -to sdram_dq[11]
set_location_assignment PIN_T10 -to sdram_dq[12]
set_location_assignment PIN_R10 -to sdram_dq[13]
set_location_assignment PIN_T11 -to sdram_dq[14]
set_location_assignment PIN_R11 -to sdram_dq[15]
set_location_assignment PIN_R7 -to sdram_bank[0]
set_location_assignment PIN_T7 -to sdram_bank[1]
set_location_assignment PIN_N2 -to sdram_dqm[0]
set_location_assignment PIN_T14 -to sdram_dqm[1]
set_location_assignment PIN_R4 -to sdram_clk
set_location_assignment PIN_R14 -to sdram_cke
set_location_assignment PIN_T6 -to sdram_csn
set_location_assignment PIN_R6 -to sdram_rasn
set_location_assignment PIN_T5 -to sdram_casn
set_location_assignment PIN_N1 -to sdram_wen
set_location_assignment PIN_C15 -to vga_rgb[0]
set_location_assignment PIN_B16 -to vga_rgb[1]
set_location_assignment PIN_A15 -to vga_rgb[2]
set_location_assignment PIN_B14 -to vga_rgb[3]
set_location_assignment PIN_A14 -to vga_rgb[4]
set_location_assignment PIN_B13 -to vga_rgb[5]
set_location_assignment PIN_A13 -to vga_rgb[6]
set_location_assignment PIN_B12 -to vga_rgb[7]
set_location_assignment PIN_A12 -to vga_rgb[8]
set_location_assignment PIN_B11 -to vga_rgb[9]
set_location_assignment PIN_A11 -to vga_rgb[10]
set_location_assignment PIN_B10 -to vga_rgb[11]
set_location_assignment PIN_A10 -to vga_rgb[12]
set_location_assignment PIN_B9 -to vga_rgb[13]
set_location_assignment PIN_A9 -to vga_rgb[14]
set_location_assignment PIN_C8 -to vga_rgb[15]
set_location_assignment PIN_C16 -to vga_hsync
set_location_assignment PIN_D15 -to vga_vsync
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq[15]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq[14]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq[11]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq[6]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq[2]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq[0]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq[8]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq[13]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq[9]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq[7]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq[12]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq[10]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq[3]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq[1]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq[4]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq[5]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sdram_dq
