// (c) Copyright 1995-2020 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:user:vga_top_wrapper:1.0
// IP Revision: 3

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_vga_top_wrapper_0_0 (
  CLK100MHZ,
  CPU_RESETN,
  LED,
  SW,
  i_temperature_sensor_val,
  i_light_sensor_val,
  i_distance_sensor_val,
  i_weather_val,
  i_weather_temperature,
  i_climate_control,
  i_climate_control_temperature,
  i_open_door,
  i_enable_light,
  VGA_B,
  VGA_G,
  VGA_HS,
  VGA_R,
  VGA_VS
);

input wire CLK100MHZ;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CPU_RESETN, POLARITY ACTIVE_LOW" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 CPU_RESETN RST" *)
input wire CPU_RESETN;
output wire [15 : 0] LED;
input wire [15 : 0] SW;
input wire [15 : 0] i_temperature_sensor_val;
input wire [7 : 0] i_light_sensor_val;
input wire i_distance_sensor_val;
input wire [5 : 0] i_weather_val;
input wire [7 : 0] i_weather_temperature;
input wire [1 : 0] i_climate_control;
input wire [7 : 0] i_climate_control_temperature;
input wire i_open_door;
input wire [2 : 0] i_enable_light;
output wire [3 : 0] VGA_B;
output wire [3 : 0] VGA_G;
output wire VGA_HS;
output wire [3 : 0] VGA_R;
output wire VGA_VS;

  vga_top_wrapper #(
    .TESTING(0)
  ) inst (
    .CLK100MHZ(CLK100MHZ),
    .CPU_RESETN(CPU_RESETN),
    .LED(LED),
    .SW(SW),
    .i_temperature_sensor_val(i_temperature_sensor_val),
    .i_light_sensor_val(i_light_sensor_val),
    .i_distance_sensor_val(i_distance_sensor_val),
    .i_weather_val(i_weather_val),
    .i_weather_temperature(i_weather_temperature),
    .i_climate_control(i_climate_control),
    .i_climate_control_temperature(i_climate_control_temperature),
    .i_open_door(i_open_door),
    .i_enable_light(i_enable_light),
    .VGA_B(VGA_B),
    .VGA_G(VGA_G),
    .VGA_HS(VGA_HS),
    .VGA_R(VGA_R),
    .VGA_VS(VGA_VS)
  );
endmodule
