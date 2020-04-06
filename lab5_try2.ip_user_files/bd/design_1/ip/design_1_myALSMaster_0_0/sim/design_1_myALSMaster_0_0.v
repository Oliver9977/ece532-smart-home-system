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


// IP VLNV: user.org:user:myALSMaster:1.0
// IP Revision: 137

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_myALSMaster_0_0 (
  error_out,
  result_0_test,
  result_1_test,
  result_2_test,
  pmod_data_ready_out,
  mals_axi_awaddr,
  mals_axi_awprot,
  mals_axi_awvalid,
  mals_axi_awready,
  mals_axi_wdata,
  mals_axi_wstrb,
  mals_axi_wvalid,
  mals_axi_wready,
  mals_axi_bresp,
  mals_axi_bvalid,
  mals_axi_bready,
  mals_axi_araddr,
  mals_axi_arprot,
  mals_axi_arvalid,
  mals_axi_arready,
  mals_axi_rdata,
  mals_axi_rresp,
  mals_axi_rvalid,
  mals_axi_rready,
  mals_axi_aclk,
  mals_axi_aresetn,
  mals_axi_init_axi_txn,
  mals_axi_error,
  mals_axi_txn_done
);

output wire error_out;
output wire [7 : 0] result_0_test;
output wire [7 : 0] result_1_test;
output wire [7 : 0] result_2_test;
output wire pmod_data_ready_out;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI AWADDR" *)
output wire [31 : 0] mals_axi_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI AWPROT" *)
output wire [2 : 0] mals_axi_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI AWVALID" *)
output wire mals_axi_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI AWREADY" *)
input wire mals_axi_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI WDATA" *)
output wire [31 : 0] mals_axi_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI WSTRB" *)
output wire [3 : 0] mals_axi_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI WVALID" *)
output wire mals_axi_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI WREADY" *)
input wire mals_axi_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI BRESP" *)
input wire [1 : 0] mals_axi_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI BVALID" *)
input wire mals_axi_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI BREADY" *)
output wire mals_axi_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI ARADDR" *)
output wire [31 : 0] mals_axi_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI ARPROT" *)
output wire [2 : 0] mals_axi_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI ARVALID" *)
output wire mals_axi_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI ARREADY" *)
input wire mals_axi_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI RDATA" *)
input wire [31 : 0] mals_axi_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI RRESP" *)
input wire [1 : 0] mals_axi_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI RVALID" *)
input wire mals_axi_rvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME MALS_AXI, WIZ_DATA_WIDTH 32, SUPPORTS_NARROW_BURST 0, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN /clk_wiz_1_clk_out1, NUM_READ_THREADS \
1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 MALS_AXI RREADY" *)
output wire mals_axi_rready;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME MALS_AXI_CLK, ASSOCIATED_BUSIF MALS_AXI, ASSOCIATED_RESET mals_axi_aresetn, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN /clk_wiz_1_clk_out1" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 MALS_AXI_CLK CLK" *)
input wire mals_axi_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME MALS_AXI_RST, POLARITY ACTIVE_LOW" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 MALS_AXI_RST RST" *)
input wire mals_axi_aresetn;
input wire mals_axi_init_axi_txn;
output wire mals_axi_error;
output wire mals_axi_txn_done;

  myALSMaster_v1_0 #(
    .C_MALS_AXI_TARGET_SLAVE_BASE_ADDR(32'H00010000),  // The master requires a target slave base address.
    // The master will initiate read and write transactions on the slave with base address specified here as a parameter.
    .C_MALS_AXI_ADDR_WIDTH(32),  // Width of M_AXI address bus. 
    // The master generates the read and write addresses of width specified as C_M_AXI_ADDR_WIDTH.
    .C_MALS_AXI_DATA_WIDTH(32),  // Width of M_AXI data bus. 
    // The master issues write data and accept read data where the width of the data bus is C_M_AXI_DATA_WIDTH
    .DEBUG_MODE(1'B0),
    .TIMER(32'H00FFFFFF)
  ) inst (
    .read_data_index(),
    .read_data_ready(),
    .write_data_index(),
    .write_data_ready(),
    .data_out(),
    .fsm(),
    .fsm_ns(),
    .fsm_phase(),
    .fsm_phase_ns(),
    .data_out_test(),
    .addr_out_read(),
    .addr_out_write(),
    .error_out(error_out),
    .axi_awaddr_out(),
    .axi_rdaddr_out(),
    .mals_axi_wstrb_test(),
    .result_0_test(result_0_test),
    .result_1_test(result_1_test),
    .result_2_test(result_2_test),
    .pmod_data_ready_out(pmod_data_ready_out),
    .axi_arvalid_test(),
    .last_read_test(),
    .start_single_read_test(),
    .read_issued_test(),
    .delay_test(),
    .delay_2_test(),
    .delay_3_test(),
    .mals_axi_awaddr(mals_axi_awaddr),
    .mals_axi_awprot(mals_axi_awprot),
    .mals_axi_awvalid(mals_axi_awvalid),
    .mals_axi_awready(mals_axi_awready),
    .mals_axi_wdata(mals_axi_wdata),
    .mals_axi_wstrb(mals_axi_wstrb),
    .mals_axi_wvalid(mals_axi_wvalid),
    .mals_axi_wready(mals_axi_wready),
    .mals_axi_bresp(mals_axi_bresp),
    .mals_axi_bvalid(mals_axi_bvalid),
    .mals_axi_bready(mals_axi_bready),
    .mals_axi_araddr(mals_axi_araddr),
    .mals_axi_arprot(mals_axi_arprot),
    .mals_axi_arvalid(mals_axi_arvalid),
    .mals_axi_arready(mals_axi_arready),
    .mals_axi_rdata(mals_axi_rdata),
    .mals_axi_rresp(mals_axi_rresp),
    .mals_axi_rvalid(mals_axi_rvalid),
    .mals_axi_rready(mals_axi_rready),
    .mals_axi_aclk(mals_axi_aclk),
    .mals_axi_aresetn(mals_axi_aresetn),
    .mals_axi_init_axi_txn(mals_axi_init_axi_txn),
    .mals_axi_error(mals_axi_error),
    .mals_axi_txn_done(mals_axi_txn_done)
  );
endmodule
