//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.1 (win64) Build 2188600 Wed Apr  4 18:40:38 MDT 2018
//Date        : Sat Mar 28 21:21:17 2020
//Host        : MSI running 64-bit major release  (build 9200)
//Command     : generate_target vga_block_wrapper.bd
//Design      : vga_block_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module vga_block_wrapper
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
  input CLK100MHZ;
  input CPU_RESETN;
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

  wire CLK100MHZ;
  wire CPU_RESETN;
  wire [3:0]VGA_B;
  wire [3:0]VGA_G;
  wire VGA_HS;
  wire [3:0]VGA_R;
  wire VGA_VS;
  wire [1:0]climate_control;
  wire [7:0]climate_control_temperature;
  wire distance_sensor_val;
  wire [2:0]enable_light;
  wire [7:0]light_sensor_val;
  wire open_door;
  wire [15:0]temperature_sensor_val;
  wire [7:0]weather_temperature;
  wire [5:0]weather_val;

  vga_block vga_block_i
       (.CLK100MHZ(CLK100MHZ),
        .CPU_RESETN(CPU_RESETN),
        .VGA_B(VGA_B),
        .VGA_G(VGA_G),
        .VGA_HS(VGA_HS),
        .VGA_R(VGA_R),
        .VGA_VS(VGA_VS),
        .climate_control(climate_control),
        .climate_control_temperature(climate_control_temperature),
        .distance_sensor_val(distance_sensor_val),
        .enable_light(enable_light),
        .light_sensor_val(light_sensor_val),
        .open_door(open_door),
        .temperature_sensor_val(temperature_sensor_val),
        .weather_temperature(weather_temperature),
        .weather_val(weather_val));
endmodule
