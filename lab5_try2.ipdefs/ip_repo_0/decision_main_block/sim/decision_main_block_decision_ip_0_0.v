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


// IP VLNV: xilinx.com:module_ref:decision_ip:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module decision_main_block_decision_ip_0_0 (
  aclk,
  aresetn,
  light_sensor_rd_en,
  light_sensor_rd_vld,
  light_sensor_rd_data_0,
  light_sensor_rd_data_1,
  weather_data_in,
  range_status,
  o_light_sensor_val,
  o_distance_sensor_val,
  o_weather_val,
  light_sensor_rd_en_out
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aclk, ASSOCIATED_RESET aresetn, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN decision_main_block_aclk" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK" *)
input wire aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aresetn, POLARITY ACTIVE_LOW" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST" *)
input wire aresetn;
input wire light_sensor_rd_en;
input wire light_sensor_rd_vld;
input wire [7 : 0] light_sensor_rd_data_0;
input wire [7 : 0] light_sensor_rd_data_1;
input wire [5 : 0] weather_data_in;
input wire range_status;
output wire [7 : 0] o_light_sensor_val;
output wire o_distance_sensor_val;
output wire [5 : 0] o_weather_val;
output wire light_sensor_rd_en_out;

  decision_ip inst (
    .aclk(aclk),
    .aresetn(aresetn),
    .light_sensor_rd_en(light_sensor_rd_en),
    .light_sensor_rd_vld(light_sensor_rd_vld),
    .light_sensor_rd_data_0(light_sensor_rd_data_0),
    .light_sensor_rd_data_1(light_sensor_rd_data_1),
    .weather_data_in(weather_data_in),
    .range_status(range_status),
    .o_light_sensor_val(o_light_sensor_val),
    .o_distance_sensor_val(o_distance_sensor_val),
    .o_weather_val(o_weather_val),
    .light_sensor_rd_en_out(light_sensor_rd_en_out)
  );
endmodule
