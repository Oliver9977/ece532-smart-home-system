onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+design_1 -L xilinx_vip -L xil_defaultlib -L xpm -L microblaze_v10_0_6 -L axi_lite_ipif_v3_0_4 -L axi_intc_v4_1_10 -L xlconcat_v2_1_1 -L mdm_v3_2_13 -L lib_cdc_v1_0_2 -L proc_sys_reset_v5_0_12 -L mii_to_rmii_v2_0_18 -L lib_pkg_v1_0_2 -L lib_srl_fifo_v1_0_2 -L axi_uartlite_v2_0_20 -L axi_timer_v2_0_18 -L blk_mem_gen_v8_4_1 -L lib_bmg_v1_0_10 -L fifo_generator_v13_2_2 -L lib_fifo_v1_0_11 -L axi_ethernetlite_v3_0_14 -L smartconnect_v1_0 -L xlconstant_v1_1_4 -L generic_baseblocks_v2_1_0 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_16 -L axi_data_fifo_v2_1_15 -L axi_crossbar_v2_1_17 -L lmb_v10_v3_0_9 -L lmb_bram_if_cntlr_v4_0_14 -L dist_mem_gen_v8_0_12 -L interrupt_control_v3_1_4 -L axi_quad_spi_v3_2_15 -L xlslice_v1_0_1 -L xbip_utils_v3_0_9 -L c_reg_fd_v12_0_5 -L xbip_dsp48_wrapper_v3_0_4 -L xbip_pipe_v3_0_5 -L xbip_dsp48_addsub_v3_0_5 -L xbip_addsub_v3_0_5 -L c_addsub_v12_0_12 -L xbip_bram18k_v3_0_5 -L mult_gen_v12_0_14 -L axi_utils_v2_0_5 -L cordic_v6_0_14 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.design_1 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {design_1.udo}

run -all

endsim

quit -force
