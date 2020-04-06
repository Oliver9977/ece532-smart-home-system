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


// IP VLNV: xilinx.com:module_ref:drawing_controller_wrapper:1.0
// IP Revision: 1

(* X_CORE_INFO = "drawing_controller_wrapper,Vivado 2018.1" *)
(* CHECK_LICENSE_TYPE = "vga_block_drawing_controller_w_0_0,drawing_controller_wrapper,{}" *)
(* CORE_GENERATION_INFO = "vga_block_drawing_controller_w_0_0,drawing_controller_wrapper,{x_ipProduct=Vivado 2018.1,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=drawing_controller_wrapper,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=VERILOG,VGA_WIDTH=640,VGA_HEIGHT=480}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module vga_block_drawing_controller_w_0_0 (
  clk,
  reset,
  vga_clk,
  i_temperature_sensor_val,
  i_light_sensor_val,
  i_distance_sensor_val,
  i_weather_val,
  i_weather_temperature,
  i_climate_control,
  i_climate_control_temperature,
  i_open_door,
  i_enable_light,
  i_animate,
  i_vga_x,
  i_vga_y,
  o_foreground
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN vga_block_CLK100MHZ" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
input wire clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME reset, POLARITY ACTIVE_LOW" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset RST" *)
input wire reset;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME vga_clk, FREQ_HZ 25000000, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 vga_clk CLK" *)
input wire vga_clk;
input wire [15 : 0] i_temperature_sensor_val;
input wire [7 : 0] i_light_sensor_val;
input wire i_distance_sensor_val;
input wire [5 : 0] i_weather_val;
input wire [7 : 0] i_weather_temperature;
input wire [1 : 0] i_climate_control;
input wire [7 : 0] i_climate_control_temperature;
input wire i_open_door;
input wire [2 : 0] i_enable_light;
input wire i_animate;
input wire [9 : 0] i_vga_x;
input wire [8 : 0] i_vga_y;
output wire [15 : 0] o_foreground;

  drawing_controller_wrapper #(
    .VGA_WIDTH(640),
    .VGA_HEIGHT(480)
  ) inst (
    .clk(clk),
    .reset(reset),
    .vga_clk(vga_clk),
    .i_temperature_sensor_val(i_temperature_sensor_val),
    .i_light_sensor_val(i_light_sensor_val),
    .i_distance_sensor_val(i_distance_sensor_val),
    .i_weather_val(i_weather_val),
    .i_weather_temperature(i_weather_temperature),
    .i_climate_control(i_climate_control),
    .i_climate_control_temperature(i_climate_control_temperature),
    .i_open_door(i_open_door),
    .i_enable_light(i_enable_light),
    .i_animate(i_animate),
    .i_vga_x(i_vga_x),
    .i_vga_y(i_vga_y),
    .o_foreground(o_foreground)
  );
endmodule
