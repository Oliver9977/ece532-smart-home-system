#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2018.1 (64-bit)
#
# Filename    : elaborate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for elaborating the compiled design
#
# Generated by Vivado on Thu Feb 20 14:40:36 EST 2020
# SW Build 2188600 on Wed Apr  4 18:39:19 MDT 2018
#
# Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
#
# usage: elaborate.sh
#
# ****************************************************************************
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep xelab -wto d174e89801e341b5b8b237abeb6dbf7d --incr --debug typical --relax --mt 8 -L microblaze_v10_0_6 -L xil_defaultlib -L axi_lite_ipif_v3_0_4 -L axi_intc_v4_1_10 -L xlconcat_v2_1_1 -L mdm_v3_2_13 -L lib_cdc_v1_0_2 -L proc_sys_reset_v5_0_12 -L mii_to_rmii_v2_0_18 -L lib_pkg_v1_0_2 -L lib_srl_fifo_v1_0_2 -L axi_uartlite_v2_0_20 -L axi_timer_v2_0_18 -L blk_mem_gen_v8_4_1 -L lib_bmg_v1_0_10 -L fifo_generator_v13_2_2 -L lib_fifo_v1_0_11 -L axi_ethernetlite_v3_0_14 -L smartconnect_v1_0 -L xlconstant_v1_1_4 -L generic_baseblocks_v2_1_0 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_16 -L axi_data_fifo_v2_1_15 -L axi_crossbar_v2_1_17 -L lmb_v10_v3_0_9 -L lmb_bram_if_cntlr_v4_0_14 -L interrupt_control_v3_1_4 -L axi_gpio_v2_0_18 -L axi_iic_v2_0_19 -L dist_mem_gen_v8_0_12 -L axi_quad_spi_v3_2_15 -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot design_1_wrapper_behav xil_defaultlib.design_1_wrapper xil_defaultlib.glbl -log elaborate.log