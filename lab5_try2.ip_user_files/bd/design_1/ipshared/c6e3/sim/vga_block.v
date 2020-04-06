//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.1 (win64) Build 2188600 Wed Apr  4 18:40:38 MDT 2018
//Date        : Sat Mar 28 21:21:17 2020
//Host        : MSI running 64-bit major release  (build 9200)
//Command     : generate_target vga_block.bd
//Design      : vga_block
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "vga_block,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=vga_block,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=6,numReposBlks=6,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=5,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "vga_block.hwdef" *) 
module vga_block
   (CLK100MHZ,
    CPU_RESETN,
    VGA_B,
    VGA_G,
    VGA_HS,
    VGA_R,
    VGA_VS,
    climate_control,
    climate_control_temperature,
    distance_sensor_val,
    enable_light,
    light_sensor_val,
    open_door,
    temperature_sensor_val,
    weather_temperature,
    weather_val);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK100MHZ CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK100MHZ, CLK_DOMAIN vga_block_CLK100MHZ, FREQ_HZ 100000000, PHASE 0.000" *) input CLK100MHZ;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.CPU_RESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.CPU_RESETN, POLARITY ACTIVE_LOW" *) input CPU_RESETN;
  output [3:0]VGA_B;
  output [3:0]VGA_G;
  output VGA_HS;
  output [3:0]VGA_R;
  output VGA_VS;
  input [1:0]climate_control;
  input [7:0]climate_control_temperature;
  input distance_sensor_val;
  input [2:0]enable_light;
  input [7:0]light_sensor_val;
  input open_door;
  input [15:0]temperature_sensor_val;
  input [7:0]weather_temperature;
  input [5:0]weather_val;

  wire CLK100MHZ_1;
  wire CPU_RESETN_1;
  wire [15:0]background_buffer_0_o_read_val;
  wire [1:0]climate_control_1;
  wire [7:0]climate_control_temperature_1;
  wire clk_wiz_0_clk_out1;
  wire clk_wiz_0_locked;
  wire [3:0]combine_background_a_0_o_VGA_blue;
  wire [3:0]combine_background_a_0_o_VGA_green;
  wire [3:0]combine_background_a_0_o_VGA_red;
  wire distance_sensor_val_1;
  wire [15:0]drawing_controller_w_0_o_foreground;
  wire [2:0]enable_light_1;
  wire [7:0]light_sensor_val_1;
  wire open_door_1;
  wire reset_block_0_reset;
  wire [15:0]temperature_sensor_val_1;
  wire vga_0_o_active;
  wire vga_0_o_animate;
  wire vga_0_o_hs;
  wire vga_0_o_vs;
  wire [9:0]vga_0_o_x;
  wire [8:0]vga_0_o_y;
  wire [7:0]weather_temperature_1;
  wire [5:0]weather_val_1;

  assign CLK100MHZ_1 = CLK100MHZ;
  assign CPU_RESETN_1 = CPU_RESETN;
  assign VGA_B[3:0] = combine_background_a_0_o_VGA_blue;
  assign VGA_G[3:0] = combine_background_a_0_o_VGA_green;
  assign VGA_HS = vga_0_o_hs;
  assign VGA_R[3:0] = combine_background_a_0_o_VGA_red;
  assign VGA_VS = vga_0_o_vs;
  assign climate_control_1 = climate_control[1:0];
  assign climate_control_temperature_1 = climate_control_temperature[7:0];
  assign distance_sensor_val_1 = distance_sensor_val;
  assign enable_light_1 = enable_light[2:0];
  assign light_sensor_val_1 = light_sensor_val[7:0];
  assign open_door_1 = open_door;
  assign temperature_sensor_val_1 = temperature_sensor_val[15:0];
  assign weather_temperature_1 = weather_temperature[7:0];
  assign weather_val_1 = weather_val[5:0];
  vga_block_background_buffer_0_0 background_buffer_0
       (.clk(CLK100MHZ_1),
        .i_read_x(vga_0_o_x),
        .i_read_y(vga_0_o_y),
        .o_read_val(background_buffer_0_o_read_val),
        .reset(reset_block_0_reset));
  vga_block_clk_wiz_0_0 clk_wiz_0
       (.clk_in1(CLK100MHZ_1),
        .clk_out1(clk_wiz_0_clk_out1),
        .locked(clk_wiz_0_locked),
        .resetn(CPU_RESETN_1));
  vga_block_combine_background_a_0_0 combine_background_a_0
       (.i_background(background_buffer_0_o_read_val),
        .i_foreground(drawing_controller_w_0_o_foreground),
        .o_VGA_blue(combine_background_a_0_o_VGA_blue),
        .o_VGA_green(combine_background_a_0_o_VGA_green),
        .o_VGA_red(combine_background_a_0_o_VGA_red),
        .o_active(vga_0_o_active));
  vga_block_drawing_controller_w_0_0 drawing_controller_w_0
       (.clk(CLK100MHZ_1),
        .i_animate(vga_0_o_animate),
        .i_climate_control(climate_control_1),
        .i_climate_control_temperature(climate_control_temperature_1),
        .i_distance_sensor_val(distance_sensor_val_1),
        .i_enable_light(enable_light_1),
        .i_light_sensor_val(light_sensor_val_1),
        .i_open_door(open_door_1),
        .i_temperature_sensor_val(temperature_sensor_val_1),
        .i_vga_x(vga_0_o_x),
        .i_vga_y(vga_0_o_y),
        .i_weather_temperature(weather_temperature_1),
        .i_weather_val(weather_val_1),
        .o_foreground(drawing_controller_w_0_o_foreground),
        .reset(reset_block_0_reset),
        .vga_clk(clk_wiz_0_clk_out1));
  vga_block_reset_block_0_0 reset_block_0
       (.locked(clk_wiz_0_locked),
        .reset(reset_block_0_reset),
        .resetn(CPU_RESETN_1));
  vga_block_vga_0_0 vga_0
       (.i_clk(CLK100MHZ_1),
        .i_rst(reset_block_0_reset),
        .i_vga_clk(clk_wiz_0_clk_out1),
        .o_active(vga_0_o_active),
        .o_animate(vga_0_o_animate),
        .o_hs(vga_0_o_hs),
        .o_vs(vga_0_o_vs),
        .o_x(vga_0_o_x),
        .o_y(vga_0_o_y));
endmodule
