//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.1 (win64) Build 2188600 Wed Apr  4 18:40:38 MDT 2018
//Date        : Sun Mar  8 17:38:42 2020
//Host        : BA3135WS08 running 64-bit major release  (build 9200)
//Command     : generate_target driver_ip.bd
//Design      : driver_ip
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "driver_ip,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=driver_ip,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=1,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "driver_ip.hwdef" *) 
module driver_ip
   (M_AXI_0_araddr,
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
    o_background_0,
    o_bg_end_0,
    o_current_0,
    o_range_raw_0,
    o_sample_end_0,
    range_status_0);
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI_0, ADDR_WIDTH 32, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN driver_ip_aclk, DATA_WIDTH 32, FREQ_HZ 100000000, HAS_BRESP 1, HAS_BURST 0, HAS_CACHE 0, HAS_LOCK 0, HAS_PROT 0, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, MAX_BURST_LENGTH 1, NUM_READ_OUTSTANDING 1, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 1, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) output [31:0]M_AXI_0_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 ARREADY" *) input M_AXI_0_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 ARVALID" *) output M_AXI_0_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 AWADDR" *) output [31:0]M_AXI_0_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 AWREADY" *) input M_AXI_0_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 AWVALID" *) output M_AXI_0_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 BREADY" *) output M_AXI_0_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 BRESP" *) input [1:0]M_AXI_0_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 BVALID" *) input M_AXI_0_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 RDATA" *) input [31:0]M_AXI_0_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 RREADY" *) output M_AXI_0_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 RRESP" *) input [1:0]M_AXI_0_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 RVALID" *) input M_AXI_0_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 WDATA" *) output [31:0]M_AXI_0_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 WREADY" *) input M_AXI_0_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 WSTRB" *) output [3:0]M_AXI_0_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_0 WVALID" *) output M_AXI_0_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.ACLK, ASSOCIATED_BUSIF M_AXI_0, ASSOCIATED_RESET aresetn, CLK_DOMAIN driver_ip_aclk, FREQ_HZ 100000000, PHASE 0.000" *) input aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.ARESETN, POLARITY ACTIVE_LOW" *) input aresetn;
  output [31:0]o_background_0;
  output o_bg_end_0;
  output [31:0]o_current_0;
  output [31:0]o_range_raw_0;
  output o_sample_end_0;
  output range_status_0;

  wire aclk_0_1;
  wire aresetn_0_1;
  wire [31:0]range_sensor_driver_0_M_AXI_ARADDR;
  wire range_sensor_driver_0_M_AXI_ARREADY;
  wire range_sensor_driver_0_M_AXI_ARVALID;
  wire [31:0]range_sensor_driver_0_M_AXI_AWADDR;
  wire range_sensor_driver_0_M_AXI_AWREADY;
  wire range_sensor_driver_0_M_AXI_AWVALID;
  wire range_sensor_driver_0_M_AXI_BREADY;
  wire [1:0]range_sensor_driver_0_M_AXI_BRESP;
  wire range_sensor_driver_0_M_AXI_BVALID;
  wire [31:0]range_sensor_driver_0_M_AXI_RDATA;
  wire range_sensor_driver_0_M_AXI_RREADY;
  wire [1:0]range_sensor_driver_0_M_AXI_RRESP;
  wire range_sensor_driver_0_M_AXI_RVALID;
  wire [31:0]range_sensor_driver_0_M_AXI_WDATA;
  wire range_sensor_driver_0_M_AXI_WREADY;
  wire [3:0]range_sensor_driver_0_M_AXI_WSTRB;
  wire range_sensor_driver_0_M_AXI_WVALID;
  wire [31:0]range_sensor_driver_0_o_background;
  wire range_sensor_driver_0_o_bg_end;
  wire [31:0]range_sensor_driver_0_o_current;
  wire [31:0]range_sensor_driver_0_o_range_raw;
  wire range_sensor_driver_0_o_sample_end;
  wire range_sensor_driver_0_range_status;

  assign M_AXI_0_araddr[31:0] = range_sensor_driver_0_M_AXI_ARADDR;
  assign M_AXI_0_arvalid = range_sensor_driver_0_M_AXI_ARVALID;
  assign M_AXI_0_awaddr[31:0] = range_sensor_driver_0_M_AXI_AWADDR;
  assign M_AXI_0_awvalid = range_sensor_driver_0_M_AXI_AWVALID;
  assign M_AXI_0_bready = range_sensor_driver_0_M_AXI_BREADY;
  assign M_AXI_0_rready = range_sensor_driver_0_M_AXI_RREADY;
  assign M_AXI_0_wdata[31:0] = range_sensor_driver_0_M_AXI_WDATA;
  assign M_AXI_0_wstrb[3:0] = range_sensor_driver_0_M_AXI_WSTRB;
  assign M_AXI_0_wvalid = range_sensor_driver_0_M_AXI_WVALID;
  assign aclk_0_1 = aclk;
  assign aresetn_0_1 = aresetn;
  assign o_background_0[31:0] = range_sensor_driver_0_o_background;
  assign o_bg_end_0 = range_sensor_driver_0_o_bg_end;
  assign o_current_0[31:0] = range_sensor_driver_0_o_current;
  assign o_range_raw_0[31:0] = range_sensor_driver_0_o_range_raw;
  assign o_sample_end_0 = range_sensor_driver_0_o_sample_end;
  assign range_sensor_driver_0_M_AXI_ARREADY = M_AXI_0_arready;
  assign range_sensor_driver_0_M_AXI_AWREADY = M_AXI_0_awready;
  assign range_sensor_driver_0_M_AXI_BRESP = M_AXI_0_bresp[1:0];
  assign range_sensor_driver_0_M_AXI_BVALID = M_AXI_0_bvalid;
  assign range_sensor_driver_0_M_AXI_RDATA = M_AXI_0_rdata[31:0];
  assign range_sensor_driver_0_M_AXI_RRESP = M_AXI_0_rresp[1:0];
  assign range_sensor_driver_0_M_AXI_RVALID = M_AXI_0_rvalid;
  assign range_sensor_driver_0_M_AXI_WREADY = M_AXI_0_wready;
  assign range_status_0 = range_sensor_driver_0_range_status;
  driver_ip_range_sensor_driver_0_0 range_sensor_driver_0
       (.M_AXI_ARADDR(range_sensor_driver_0_M_AXI_ARADDR),
        .M_AXI_ARREADY(range_sensor_driver_0_M_AXI_ARREADY),
        .M_AXI_ARVALID(range_sensor_driver_0_M_AXI_ARVALID),
        .M_AXI_AWADDR(range_sensor_driver_0_M_AXI_AWADDR),
        .M_AXI_AWREADY(range_sensor_driver_0_M_AXI_AWREADY),
        .M_AXI_AWVALID(range_sensor_driver_0_M_AXI_AWVALID),
        .M_AXI_BREADY(range_sensor_driver_0_M_AXI_BREADY),
        .M_AXI_BRESP(range_sensor_driver_0_M_AXI_BRESP),
        .M_AXI_BVALID(range_sensor_driver_0_M_AXI_BVALID),
        .M_AXI_RDATA(range_sensor_driver_0_M_AXI_RDATA),
        .M_AXI_RREADY(range_sensor_driver_0_M_AXI_RREADY),
        .M_AXI_RRESP(range_sensor_driver_0_M_AXI_RRESP),
        .M_AXI_RVALID(range_sensor_driver_0_M_AXI_RVALID),
        .M_AXI_WDATA(range_sensor_driver_0_M_AXI_WDATA),
        .M_AXI_WREADY(range_sensor_driver_0_M_AXI_WREADY),
        .M_AXI_WSTRB(range_sensor_driver_0_M_AXI_WSTRB),
        .M_AXI_WVALID(range_sensor_driver_0_M_AXI_WVALID),
        .aclk(aclk_0_1),
        .aresetn(aresetn_0_1),
        .o_background(range_sensor_driver_0_o_background),
        .o_bg_end(range_sensor_driver_0_o_bg_end),
        .o_current(range_sensor_driver_0_o_current),
        .o_range_raw(range_sensor_driver_0_o_range_raw),
        .o_sample_end(range_sensor_driver_0_o_sample_end),
        .range_status(range_sensor_driver_0_range_status));
endmodule
