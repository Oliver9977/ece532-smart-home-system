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


// IP VLNV: utoronto.ca:user:driver_ip:1.0
// IP Revision: 3

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_driver_ip_0_1 (
  M_AXI_0_araddr,
  M_AXI_0_arready,
  M_AXI_0_arvalid,
  M_AXI_0_awaddr,
  M_AXI_0_awready,
  M_AXI_0_awvalid,
  M_AXI_0_bready,
  M_AXI_0_bresp,
  M_AXI_0_bvalid,
  M_AXI_0_rdata,
  M_AXI_0_rready,
  M_AXI_0_rresp,
  M_AXI_0_rvalid,
  M_AXI_0_wdata,
  M_AXI_0_wready,
  M_AXI_0_wstrb,
  M_AXI_0_wvalid,
  aclk,
  aresetn,
  range_status_0
);

(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 ARADDR" *)
output wire [31 : 0] M_AXI_0_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 ARREADY" *)
input wire M_AXI_0_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 ARVALID" *)
output wire M_AXI_0_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 AWADDR" *)
output wire [31 : 0] M_AXI_0_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 AWREADY" *)
input wire M_AXI_0_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 AWVALID" *)
output wire M_AXI_0_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 BREADY" *)
output wire M_AXI_0_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 BRESP" *)
input wire [1 : 0] M_AXI_0_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 BVALID" *)
input wire M_AXI_0_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 RDATA" *)
input wire [31 : 0] M_AXI_0_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 RREADY" *)
output wire M_AXI_0_rready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 RRESP" *)
input wire [1 : 0] M_AXI_0_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 RVALID" *)
input wire M_AXI_0_rvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 WDATA" *)
output wire [31 : 0] M_AXI_0_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 WREADY" *)
input wire M_AXI_0_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 WSTRB" *)
output wire [3 : 0] M_AXI_0_wstrb;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI_0, DATA_WIDTH 32, PROTOCOL AXI4LITE, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, FREQ_HZ 1000\
00000, PHASE 0.000, CLK_DOMAIN /clk_wiz_1_clk_out1" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 WVALID" *)
output wire M_AXI_0_wvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.ACLK, FREQ_HZ 100000000, PHASE 0.000, ASSOCIATED_BUSIF M_AXI_0, ASSOCIATED_RESET aresetn, CLK_DOMAIN /clk_wiz_1_clk_out1" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.ACLK CLK" *)
input wire aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.ARESETN, POLARITY ACTIVE_LOW" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.ARESETN RST" *)
input wire aresetn;
output wire range_status_0;

  driver_ip inst (
    .M_AXI_0_araddr(M_AXI_0_araddr),
    .M_AXI_0_arready(M_AXI_0_arready),
    .M_AXI_0_arvalid(M_AXI_0_arvalid),
    .M_AXI_0_awaddr(M_AXI_0_awaddr),
    .M_AXI_0_awready(M_AXI_0_awready),
    .M_AXI_0_awvalid(M_AXI_0_awvalid),
    .M_AXI_0_bready(M_AXI_0_bready),
    .M_AXI_0_bresp(M_AXI_0_bresp),
    .M_AXI_0_bvalid(M_AXI_0_bvalid),
    .M_AXI_0_rdata(M_AXI_0_rdata),
    .M_AXI_0_rready(M_AXI_0_rready),
    .M_AXI_0_rresp(M_AXI_0_rresp),
    .M_AXI_0_rvalid(M_AXI_0_rvalid),
    .M_AXI_0_wdata(M_AXI_0_wdata),
    .M_AXI_0_wready(M_AXI_0_wready),
    .M_AXI_0_wstrb(M_AXI_0_wstrb),
    .M_AXI_0_wvalid(M_AXI_0_wvalid),
    .aclk(aclk),
    .aresetn(aresetn),
    .o_background_0(),
    .o_bg_end_0(),
    .o_current_0(),
    .o_range_raw_0(),
    .o_sample_end_0(),
    .range_status_0(range_status_0)
  );
endmodule
