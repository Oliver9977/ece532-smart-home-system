//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.1 (lin64) Build 2188600 Wed Apr  4 18:39:19 MDT 2018
//Date        : Sun Mar  8 18:25:59 2020
//Host        : oliver-ThinkPad-L440 running 64-bit Ubuntu 18.04.3 LTS
//Command     : generate_target decision_main_block.bd
//Design      : decision_main_block
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "decision_main_block,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=decision_main_block,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=1,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "decision_main_block.hwdef" *) 
module decision_main_block
   (aclk,
    aresetn,
    light_sensor_rd_data_0,
    light_sensor_rd_data_1,
    light_sensor_rd_en,
    light_sensor_rd_en_out,
    light_sensor_rd_vld,
    o_distance_sensor_val,
    o_light_sensor_val,
    o_weather_val,
    range_status,
    weather_data_in_0);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.ACLK, ASSOCIATED_RESET aresetn, CLK_DOMAIN decision_main_block_aclk, FREQ_HZ 100000000, PHASE 0.000" *) input aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.ARESETN, POLARITY ACTIVE_LOW" *) input aresetn;
  input [7:0]light_sensor_rd_data_0;
  input [7:0]light_sensor_rd_data_1;
  input light_sensor_rd_en;
  output light_sensor_rd_en_out;
  input light_sensor_rd_vld;
  output o_distance_sensor_val;
  output [7:0]o_light_sensor_val;
  output [5:0]o_weather_val;
  input range_status;
  input [5:0]weather_data_in_0;

  wire aclk_0_1;
  wire aresetn_0_1;
  wire decision_ip_0_light_sensor_rd_en_out;
  wire decision_ip_0_o_distance_sensor_val;
  wire [7:0]decision_ip_0_o_light_sensor_val;
  wire [5:0]decision_ip_0_o_weather_val;
  wire [7:0]light_sensor_rd_data_0_0_1;
  wire [7:0]light_sensor_rd_data_1_0_1;
  wire light_sensor_rd_en_0_1;
  wire light_sensor_rd_vld_0_1;
  wire range_status_0_1;
  wire [5:0]weather_data_in_0_1;

  assign aclk_0_1 = aclk;
  assign aresetn_0_1 = aresetn;
  assign light_sensor_rd_data_0_0_1 = light_sensor_rd_data_0[7:0];
  assign light_sensor_rd_data_1_0_1 = light_sensor_rd_data_1[7:0];
  assign light_sensor_rd_en_0_1 = light_sensor_rd_en;
  assign light_sensor_rd_en_out = decision_ip_0_light_sensor_rd_en_out;
  assign light_sensor_rd_vld_0_1 = light_sensor_rd_vld;
  assign o_distance_sensor_val = decision_ip_0_o_distance_sensor_val;
  assign o_light_sensor_val[7:0] = decision_ip_0_o_light_sensor_val;
  assign o_weather_val[5:0] = decision_ip_0_o_weather_val;
  assign range_status_0_1 = range_status;
  assign weather_data_in_0_1 = weather_data_in_0[5:0];
  decision_main_block_decision_ip_0_0 decision_ip_0
       (.aclk(aclk_0_1),
        .aresetn(aresetn_0_1),
        .light_sensor_rd_data_0(light_sensor_rd_data_0_0_1),
        .light_sensor_rd_data_1(light_sensor_rd_data_1_0_1),
        .light_sensor_rd_en(light_sensor_rd_en_0_1),
        .light_sensor_rd_en_out(decision_ip_0_light_sensor_rd_en_out),
        .light_sensor_rd_vld(light_sensor_rd_vld_0_1),
        .o_distance_sensor_val(decision_ip_0_o_distance_sensor_val),
        .o_light_sensor_val(decision_ip_0_o_light_sensor_val),
        .o_weather_val(decision_ip_0_o_weather_val),
        .range_status(range_status_0_1),
        .weather_data_in(weather_data_in_0_1));
endmodule
