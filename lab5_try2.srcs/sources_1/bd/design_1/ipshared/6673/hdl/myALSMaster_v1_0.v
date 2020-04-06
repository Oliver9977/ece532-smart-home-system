`timescale 1 ns / 1 ps

	module myALSMaster_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line
		// Parameters of Axi Master Bus Interface MALS_AXI
		//parameter  C_MALS_AXI_START_DATA_VALUE	= 32'hAA000000,
		parameter integer DEBUG_MODE = 0,
		parameter TIMER = 32'h00FFFFFF,
		parameter  C_MALS_AXI_TARGET_SLAVE_BASE_ADDR = 32'h00010000,
		parameter integer C_MALS_AXI_ADDR_WIDTH	= 32,
		parameter integer C_MALS_AXI_DATA_WIDTH	= 32
		//parameter integer C_MALS_AXI_TRANSACTIONS_NUM	= 1
	)
	(
		// Users to add ports here
        output wire [1:0]read_data_index,
        output wire read_data_ready,
        output wire [1:0]write_data_index,
        output wire write_data_ready,
        //debug
        output wire [7:0]fsm,
        output wire [7:0]fsm_ns,
        output wire [7:0]fsm_phase,
        output wire [7:0]fsm_phase_ns,
        output wire [C_MALS_AXI_DATA_WIDTH-1 : 0]data_out,
        output wire [C_MALS_AXI_DATA_WIDTH-1 : 0]data_out_test,
        output wire [C_MALS_AXI_ADDR_WIDTH-1 : 0]addr_out_read,
        output wire [C_MALS_AXI_ADDR_WIDTH-1 : 0]addr_out_write,
        output wire error_out,
        output wire [C_MALS_AXI_ADDR_WIDTH-1 : 0]axi_awaddr_out,
        output wire [C_MALS_AXI_ADDR_WIDTH-1 : 0]axi_rdaddr_out,
        output wire [C_MALS_AXI_DATA_WIDTH/8-1 : 0] mals_axi_wstrb_test,
        output wire [7:0] result_0_test,
        output wire [7:0] result_1_test,
        output wire [7:0] result_2_test,
        //output wire done_test,
        //output wire [3:0] bust_count_test,
        output wire pmod_data_ready_out,
        output wire axi_arvalid_test,
        output wire last_read_test,
        output wire start_single_read_test, 
        output wire read_issued_test,
        output wire [15:0] delay_test,
        output wire [15:0] delay_2_test,
        output wire [15:0] delay_3_test,
		// User ports ends
		// Do not modify the ports beyond this line
		// Ports of Axi Master Bus Interface MALS_AXI
		input wire  mals_axi_init_axi_txn,
		output wire  mals_axi_error,
		output wire  mals_axi_txn_done,
		input wire  mals_axi_aclk,
		input wire  mals_axi_aresetn,
		output wire [C_MALS_AXI_ADDR_WIDTH-1 : 0] mals_axi_awaddr,
		output wire [2 : 0] mals_axi_awprot,
		output wire  mals_axi_awvalid,
		input wire  mals_axi_awready,
		output wire [C_MALS_AXI_DATA_WIDTH-1 : 0] mals_axi_wdata,
		output wire [C_MALS_AXI_DATA_WIDTH/8-1 : 0] mals_axi_wstrb,
		output wire  mals_axi_wvalid,
		input wire  mals_axi_wready,
		input wire [1 : 0] mals_axi_bresp,
		input wire  mals_axi_bvalid,
		output wire  mals_axi_bready,
		output wire [C_MALS_AXI_ADDR_WIDTH-1 : 0] mals_axi_araddr,
		output wire [2 : 0] mals_axi_arprot,
		output wire  mals_axi_arvalid,
		input wire  mals_axi_arready,
		input wire [C_MALS_AXI_DATA_WIDTH-1 : 0] mals_axi_rdata,
		input wire [1 : 0] mals_axi_rresp,
		input wire  mals_axi_rvalid,
		output wire  mals_axi_rready
	);
// Instantiation of Axi Bus Interface MALS_AXI
	myALSMaster_v1_0_MALS_AXI # ( 
		//.C_M_START_DATA_VALUE(C_MALS_AXI_START_DATA_VALUE),
		.C_M_TARGET_SLAVE_BASE_ADDR(C_MALS_AXI_TARGET_SLAVE_BASE_ADDR),
		.C_M_AXI_ADDR_WIDTH(C_MALS_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_MALS_AXI_DATA_WIDTH)
		//.C_M_TRANSACTIONS_NUM(C_MALS_AXI_TRANSACTIONS_NUM)
	) myALSMaster_v1_0_MALS_AXI_inst (
		.INIT_AXI_TXN(mals_axi_init_axi_txn),
		//.ERROR(mals_axi_error),
		//.TXN_DONE(mals_axi_txn_done),
		//debug
		.read_issued_test(read_issued_test),
		.start_single_read_test(start_single_read_test),
		.last_read_test(last_read_test),
		.axi_arvalid_test(axi_arvalid_test),
		.pmod_data_ready_out(pmod_data_ready_out),
		//.bust_count_test(bust_count_test),
		//.done_test(done_test),
		.delay_3_test(delay_3_test),
		.delay_test(delay_test),
		.delay_2_test(delay_2_test),
		.result_0_test(result_0_test),
		.result_1_test(result_1_test),
		.result_2_test(result_2_test),
		.axi_awaddr_out(axi_awaddr_out),
		.axi_rdaddr_out(axi_rdaddr_out),
		.addr_out_read(addr_out_read),
		.addr_out_write(addr_out_write),
		.data_out_test(data_out_test),
		.data_out(data_out),
		.error_out(error_out),
		.fsm(fsm),
		.fsm_ns(fsm_ns),
		.fsm_phase(fsm_phase),
		.fsm_phase_ns(fsm_phase_ns),
		.read_data_index(read_data_index),
		.read_data_ready(read_data_ready),
		.write_data_index(write_data_index),
        .write_data_ready(write_data_ready),
		.M_AXI_ACLK(mals_axi_aclk),
		.M_AXI_ARESETN(mals_axi_aresetn),
		.M_AXI_AWADDR(mals_axi_awaddr),
		.M_AXI_AWPROT(mals_axi_awprot),
		.M_AXI_AWVALID(mals_axi_awvalid),
		.M_AXI_AWREADY(mals_axi_awready),
		.M_AXI_WDATA(mals_axi_wdata),
		.M_AXI_WSTRB(mals_axi_wstrb),
		.M_AXI_WVALID(mals_axi_wvalid),
		.M_AXI_WREADY(mals_axi_wready),
		.M_AXI_BRESP(mals_axi_bresp),
		.M_AXI_BVALID(mals_axi_bvalid),
		.M_AXI_BREADY(mals_axi_bready),
		.M_AXI_ARADDR(mals_axi_araddr),
		.M_AXI_ARPROT(mals_axi_arprot),
		.M_AXI_ARVALID(mals_axi_arvalid),
		.M_AXI_ARREADY(mals_axi_arready),
		.M_AXI_RDATA(mals_axi_rdata),
		.M_AXI_RRESP(mals_axi_rresp),
		.M_AXI_RVALID(mals_axi_rvalid),
		.M_AXI_RREADY(mals_axi_rready)
	);

	// Add user logic here
    assign mals_axi_wstrb_test = mals_axi_wstrb;
	// User logic ends

	endmodule
