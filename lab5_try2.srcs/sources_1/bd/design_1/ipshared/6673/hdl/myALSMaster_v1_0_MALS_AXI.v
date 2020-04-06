`timescale 1 ns / 1 ps

	module myALSMaster_v1_0_MALS_AXI #
	(
		// Users to add parameters here
        parameter ALS_CONFIG = 32'h0000019C,
        parameter ALS_CONFIG_2 = 32'h000001fe,
        parameter ALS_SLAVE_REG = 32'hFFFFFFFE,
        parameter XSP_SRR_RESET_MASK = 32'h0000000A,
        parameter XSP_CR_TXFIFO_RESET_MASK = 32'h00000020,
        parameter XSP_CR_RXFIFO_RESET_MASK = 32'h00000040,
        parameter TIMER = 32'h00FFFFFF,
        parameter DATA_WIDTH = 32'h8,
        parameter DATA_LENGTH = 32'h2,
        
        // reg map
        parameter XSP_DGIER_OFFSET = 8'h1C,	/**< Global Intr Enable Reg */
        parameter XSP_IISR_OFFSET = 8'h20,    /**< Interrupt status Reg */
        parameter XSP_IIER_OFFSET = 8'h28,    /**< Interrupt Enable Reg */
        parameter XSP_SRR_OFFSET = 8'h40,    /**< Software Reset register */
        parameter XSP_CR_OFFSET = 8'h60,    /**< Control register */
        parameter XSP_SR_OFFSET = 8'h64,    /**< Status Register */
        parameter XSP_DTR_OFFSET = 8'h68,    /**< Data transmit */
        parameter XSP_DRR_OFFSET = 8'h6C,    /**< Data receive */
        parameter XSP_SSR_OFFSET = 8'h70,    /**< 32-bit slave select */
        parameter XSP_TFO_OFFSET = 8'h74,    /**< Tx FIFO occupancy */
        parameter XSP_RFO_OFFSET = 8'h78,    /**< Rx FIFO occupancy */

        parameter XSP_SR_TX_FULL_MASK = 32'h00000008,
        parameter XSP_CR_TRANS_INHIBIT_MASK = 32'h00000100,
        parameter XSP_INTR_TX_EMPTY_MASK = 32'h00000004,
        parameter XSP_SR_RX_EMPTY_MASK = 32'h00000001,
        
		// User parameters ends
		// Do not modify the parameters beyond this line

		// The master will start generating data from the C_M_START_DATA_VALUE value
		//parameter  C_M_START_DATA_VALUE	= 32'hAA000000,
		// The master requires a target slave base address.
    // The master will initiate read and write transactions on the slave with base address specified here as a parameter.
		parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h00010000,
		// Width of M_AXI address bus. 
    // The master generates the read and write addresses of width specified as C_M_AXI_ADDR_WIDTH.
		parameter integer C_M_AXI_ADDR_WIDTH	= 32,
		// Width of M_AXI data bus. 
    // The master issues write data and accept read data where the width of the data bus is C_M_AXI_DATA_WIDTH
		parameter integer C_M_AXI_DATA_WIDTH	= 32
		// Transaction number is the number of write 
    // and read transactions the master will perform as a part of this example memory test.
		//parameter integer C_M_TRANSACTIONS_NUM	= 1
	)
	(
		// Users to add ports here
        output wire [1:0]read_data_index,
        output wire read_data_ready,
        //debug
        output wire [1:0]write_data_index,
        output wire write_data_ready,
        output wire [7:0]fsm,
        output wire [7:0]fsm_ns,
        output wire [7:0]fsm_phase,
        output wire [7:0]fsm_phase_ns,
        
        output wire [C_M_AXI_DATA_WIDTH-1 : 0] data_out,
        output wire [C_M_AXI_DATA_WIDTH-1 : 0] data_out_test,
        output wire [C_M_AXI_ADDR_WIDTH-1 : 0] addr_out_read,
        output wire [C_M_AXI_ADDR_WIDTH-1 : 0] addr_out_write,
        output wire error_out,
        output wire [C_M_AXI_ADDR_WIDTH-1 : 0] axi_awaddr_out,
        output wire [C_M_AXI_ADDR_WIDTH-1 : 0] axi_rdaddr_out,
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
        output wire [31:0] delay_test,
        output wire [31:0] delay_2_test,
        output wire [31:0] delay_3_test,
        
		// User ports ends
		// Do not modify the ports beyond this line

		// Initiate AXI transactions
		input wire  INIT_AXI_TXN, //input start control
		// Asserts when ERROR is detected
		//output reg  ERROR,
		// Asserts when AXI transactions is complete
		//output wire  TXN_DONE,
		// AXI clock signal
		input wire  M_AXI_ACLK,
		// AXI active low reset signal
		input wire  M_AXI_ARESETN,
		// Master Interface Write Address Channel ports. Write address (issued by master)
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
		// Write channel Protection type.
    // This signal indicates the privilege and security level of the transaction,
    // and whether the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_AWPROT,
		// Write address valid. 
    // This signal indicates that the master signaling valid write address and control information.
		output wire  M_AXI_AWVALID,
		// Write address ready. 
    // This signal indicates that the slave is ready to accept an address and associated control signals.
		input wire  M_AXI_AWREADY,
		// Master Interface Write Data Channel ports. Write data (issued by master)
		output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
		// Write strobes. 
    // This signal indicates which byte lanes hold valid data.
    // There is one write strobe bit for each eight bits of the write data bus.
		output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
		// Write valid. This signal indicates that valid write data and strobes are available.
		output wire  M_AXI_WVALID,
		// Write ready. This signal indicates that the slave can accept the write data.
		input wire  M_AXI_WREADY,
		// Master Interface Write Response Channel ports. 
    // This signal indicates the status of the write transaction.
		input wire [1 : 0] M_AXI_BRESP,
		// Write response valid. 
    // This signal indicates that the channel is signaling a valid write response
		input wire  M_AXI_BVALID,
		// Response ready. This signal indicates that the master can accept a write response.
		output wire  M_AXI_BREADY,
		// Master Interface Read Address Channel ports. Read address (issued by master)
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
		// Protection type. 
    // This signal indicates the privilege and security level of the transaction, 
    // and whether the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_ARPROT,
		// Read address valid. 
    // This signal indicates that the channel is signaling valid read address and control information.
		output wire  M_AXI_ARVALID,
		// Read address ready. 
    // This signal indicates that the slave is ready to accept an address and associated control signals.
		input wire  M_AXI_ARREADY,
		// Master Interface Read Data Channel ports. Read data (issued by slave)
		input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
		// Read response. This signal indicates the status of the read transfer.
		input wire [1 : 0] M_AXI_RRESP,
		// Read valid. This signal indicates that the channel is signaling the required read data.
		input wire  M_AXI_RVALID,
		// Read ready. This signal indicates that the master can accept the read data and response information.
		output wire  M_AXI_RREADY
	);

	// function called clogb2 that returns an integer which has the
	// value of the ceiling of the log base 2

	 function integer clogb2 (input integer bit_depth);
		 begin
		 for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
			 bit_depth = bit_depth >> 1;
		 end
	 endfunction

	// TRANS_NUM_BITS is the width of the index counter for 
	// number of write or read transaction.
	 //localparam integer TRANS_NUM_BITS = clogb2(C_M_TRANSACTIONS_NUM-1);

	// Example State machine to initialize counter, initialize write transactions, 
	// initialize read transactions and comparison of read data with the 
	// written data words.
	localparam [7:0] IDLE = 8'b00000000, // This state initiates AXI4Lite transaction 
			// after the state machine changes state to INIT_WRITE   
			// when there is 0 to 1 transition on INIT_AXI_TXN
		INIT_WRITE   = 8'b00000001, // This state initializes write transaction,
			// once writes are done, the state machine 
			// changes state to INIT_READ 
		INIT_READ = 8'b00000010, // This state initializes read transaction
			// once reads are done, the state machine 
			// changes state to INIT_COMPARE 
		//INIT_COMPARE = 3'b011, // This state issues the status of comparison 
			// of the written data with the read data
	    //SEND_CONFIG = 8'b00000011,
		SEND_CONFIG_2 = 8'b00000100, //possible to remove one of them
		SEND_DATA = 8'b00000101,
		CHECK_STATUS = 8'b00000110,
		GET_CONTROL = 8'b00000111,
		UNSET_INHIBIT = 8'b00001000,
		SET_SSR = 8'b00001001,
		GET_INTR = 8'b00001010,
		SET_INTR = 8'b00001011,
		SET_INHIBIT = 8'b00001100,
		CHECK_STATUS_READ = 8'b00001101,
		READ_DATA = 8'b00001110,
		INIT_ITR = 8'b00001111,
		GET_CONTROL_2 = 8'b00010000,
		GET_CONTROL_3 = 8'b00010001,
		SET_INHIBIT_2 = 8'b00010010,
		UNSET_SSR = 8'b00010011,
		INIT_DELAY = 8'b00010100,
		//RESET_FF = 8'b00010101,
		RESET_DEVICE = 8'b00010110,
		//RESET_GET_CONTROL = 8'b00010111,
		INIT_DELAY_2 = 8'b00011000,
		RESET_UNSET_SSR = 8'b00011001,
		INIT_DELAY_3 = 8'b00011010
		;
		

	 reg [7:0] mst_exec_state;
	 reg [7:0] mst_exec_state_ns;
	 reg [7:0] mst_exec_state_phase;
	 reg [7:0] mst_exec_state_phase_ns;
	 reg mst_exec_state_phase_complete;
	 reg mst_exec_state_phase_complete_ns;
	 reg axi_awaddr_new;
	 reg write_reset;
	 reg read_reset;
	 reg read_start;
	 reg write_start;
	 reg [1:0]write_counter;
	 reg [1:0]read_counter;
	 
	 reg [7:0]result_0;
     reg [7:0]result_1;
     reg [7:0]result_2;
     
     reg pmod_data_ready;
	 reg pmod_data_ready_ns;

	// AXI4LITE signals
	//write address valid
	reg  	axi_awvalid;
	//write data valid
	reg  	axi_wvalid;
	//read address valid
	reg  	axi_arvalid;
	//read data acceptance
	reg  	axi_rready;
	//write response acceptance
	reg  	axi_bready;
	//write address
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr_in;
	//write data
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata_in;
	//read addresss
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr_in;
	//read data
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_rdata;
	//Asserts when there is a write response error
	wire  	write_resp_error;
	//Asserts when there is a read response error
	wire  	read_resp_error;
	//A pulse to initiate a write transaction
	reg  	start_single_write;
	reg  	start_single_write_ns;
	//A pulse to initiate a read transaction
	reg  	start_single_read;
	reg     start_single_read_ns;
	//Asserts when a single beat write transaction is issued and remains asserted till the completion of write trasaction.
	reg  	write_issued;
	reg  	write_issued_ns;
	//Asserts when a single beat read transaction is issued and remains asserted till the completion of read trasaction.
	reg  	read_issued;
	reg     read_issued_ns;
	//flag that marks the completion of write trasactions. The number of write transaction is user selected by the parameter C_M_TRANSACTIONS_NUM.
	reg  	writes_done;
	//flag that marks the completion of read trasactions. The number of read transaction is user selected by the parameter C_M_TRANSACTIONS_NUM
	reg  	reads_done;
	//The error register is asserted when any of the write response error, read response error or the data mismatch flags are asserted.
	reg  	error_reg;
	//index counter to track the number of write transaction issued
	//reg [TRANS_NUM_BITS : 0] 	write_index;
	//index counter to track the number of read transaction issued
	//reg [TRANS_NUM_BITS : 0] 	read_index;
	//Expected read data used to compare with the read data.
	//reg [C_M_AXI_DATA_WIDTH-1 : 0] 	expected_rdata;
	//Flag marks the completion of comparison of the read data with the expected read data
	//reg  	compare_done;
	//This flag is asserted when there is a mismatch of the read data with the expected read data.
	//reg  	read_mismatch;
	//Flag is asserted when the write index reaches the last write transction number
	reg  	last_write;
	//Flag is asserted when the read index reaches the last read transction number
	reg  	last_read;
	reg  	init_txn_ff;
	reg  	init_txn_ff2;
	reg  	init_txn_edge;
	wire  	init_txn_pulse;
	
	reg [31:0] delay;
	reg [31:0] delay_2;
	reg [31:0] delay_3;
	
	//reg done;
	//wire set_done;
	//reg [3:0]bust_count;
	//reg reset_run;
    
    //reg [C_M_AXI_DATA_WIDTH/8-1 : 0] write_strb;
    
	// I/O Connections assignments

	//Adding the offset address to the base addr of the slave
	assign M_AXI_AWADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_awaddr;
	//AXI 4 write data
	assign M_AXI_WDATA	= axi_wdata;
	assign M_AXI_AWPROT	= 3'b000;
	assign M_AXI_AWVALID	= axi_awvalid;
	//Write Data(W)
	assign M_AXI_WVALID	= axi_wvalid;
	//Set all byte strobes in this example
	assign M_AXI_WSTRB	= 4'b1111;
	//assign M_AXI_WSTRB = write_strb;
	//Write Response (B)
	assign M_AXI_BREADY	= axi_bready;
	//Read Address (AR)
	assign M_AXI_ARADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_araddr;
	assign M_AXI_ARVALID	= axi_arvalid;
	assign M_AXI_ARPROT	= 3'b001;
	//Read and Read Response (R)
	assign M_AXI_RREADY	= axi_rready;
	//Example design I/O
	//assign TXN_DONE	= compare_done;
	assign init_txn_pulse	= (!init_txn_ff2) && init_txn_ff;
	
	
	assign read_data_index = read_counter;
	assign read_data_ready = read_reset;
	assign write_data_index = write_counter;
    assign write_data_ready = write_reset;
	assign data_out = axi_rdata;
	
	assign fsm = mst_exec_state;
    assign fsm_ns = mst_exec_state_ns;
    assign fsm_phase = mst_exec_state_phase;
    assign fsm_phase_ns = mst_exec_state_phase_ns;
    assign error_out = error_reg;
    assign data_out_test = M_AXI_RDATA;
    assign addr_out_read = M_AXI_ARADDR;
    assign addr_out_write = M_AXI_AWADDR;
    
    assign axi_awaddr_out = axi_awaddr;
    assign axi_rdaddr_out = axi_araddr;
    
    assign result_0_test = result_0;
    assign result_1_test = result_1;
    assign result_2_test = result_2;
    //assign done_test = done;
    //assign bust_count_test = bust_count;
    assign pmod_data_ready_out = pmod_data_ready;
    assign axi_arvalid_test = axi_arvalid;
    assign last_read_test = last_read;
    assign start_single_read_test = start_single_read; 
    assign read_issued_test = read_issued;
    
    assign delay_test = delay;
    assign delay_2_test = delay_2;
    assign delay_3_test = delay_3;
    
	//Generate a pulse to initiate AXI transaction.
	always @(posedge M_AXI_ACLK)										      
	  begin                                                                        
	    // Initiates AXI transaction delay    
	    if (M_AXI_ARESETN == 0 )                                                   
	      begin                                                                    
	        init_txn_ff <= 1'b0;                                                   
	        init_txn_ff2 <= 1'b0;                                                   
	      end                                                                               
	    else                                                                       
	      begin  
	        init_txn_ff <= INIT_AXI_TXN;
	        init_txn_ff2 <= init_txn_ff;                                                                 
	      end                                                                      
	  end     


	//--------------------
	//Write Address Channel
	//--------------------

	// The purpose of the write address channel is to request the address and 
	// command information for the entire transaction.  It is a single beat
	// of information.

	// Note for this example the axi_awvalid/axi_wvalid are asserted at the same
	// time, and then each is deasserted independent from each other.
	// This is a lower-performance, but simplier control scheme.

	// AXI VALID signals must be held active until accepted by the partner.

	// A data transfer is accepted by the slave when a master has
	// VALID data and the slave acknoledges it is also READY. While the master
	// is allowed to generated multiple, back-to-back requests by not 
	// deasserting VALID, this design will add rest cycle for
	// simplicity.

	// Since only one outstanding transaction is issued by the user design,
	// there will not be a collision between a new request and an accepted
	// request on the same clock cycle. 

	  always @(posedge M_AXI_ACLK)										      
	  begin                                                                        
	    //Only VALID signals must be deasserted during reset per AXI spec          
	    //Consider inverting then registering active-low reset for higher fmax     
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                   
	      begin                                                                    
	        axi_awvalid <= 1'b0;                                                   
	      end                                                                      
	      //Signal a new address/data command is available by user logic           
	    else                                                                       
	      begin                                                                    
	        if (start_single_write)                                                
	          begin                                                                
	            axi_awvalid <= 1'b1;                                               
	          end                                                                  
	     //Address accepted by interconnect/slave (issue of M_AXI_AWREADY by slave)
	        else if (M_AXI_AWREADY && axi_awvalid)                                 
	          begin                                                                
	            axi_awvalid <= 1'b0;                                               
	          end                                                                  
	      end                                                                      
	  end                                                                          
	                                                                               
	                                                                               
	  // start_single_write triggers a new write                                   
	  // transaction. write_index is a counter to                                  
	  // keep track with number of write transaction                               
	  // issued/initiated                                                          
//	  always @(posedge M_AXI_ACLK)                                                 
//	  begin                                                                        
//	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                   
//	      begin                                                                    
//	        write_index <= 0;                                                      
//	      end                                                                      
//	      // Signals a new write address/ write data is                            
//	      // available by user logic                                               
//	    else if (start_single_write)                                               
//	      begin                                                                    
//	        write_index <= write_index + 1;                                        
//	      end                                                                      
//	  end                                                                          


	//--------------------
	//Write Data Channel
	//--------------------

	//The write data channel is for transfering the actual data.
	//The data generation is speific to the example design, and 
	//so only the WVALID/WREADY handshake is shown here

	   always @(posedge M_AXI_ACLK)                                        
	   begin                                                                         
	     if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                    
	       begin                                                                     
	         axi_wvalid <= 1'b0;                                                     
	       end                                                                       
	     //Signal a new address/data command is available by user logic              
	     else if (start_single_write)                                                
	       begin                                                                     
	         axi_wvalid <= 1'b1;                                                     
	       end                                                                       
	     //Data accepted by interconnect/slave (issue of M_AXI_WREADY by slave)      
	     else if (M_AXI_WREADY && axi_wvalid)                                        
	       begin                                                                     
	        axi_wvalid <= 1'b0;                                                      
	       end                                                                       
	   end                                                                           


	//----------------------------
	//Write Response (B) Channel
	//----------------------------

	//The write response channel provides feedback that the write has committed
	//to memory. BREADY will occur after both the data and the write address
	//has arrived and been accepted by the slave, and can guarantee that no
	//other accesses launched afterwards will be able to be reordered before it.

	//The BRESP bit [1] is used indicate any errors from the interconnect or
	//slave for the entire write burst. This example will capture the error.

	//While not necessary per spec, it is advisable to reset READY signals in
	//case of differing reset latencies between master/slave.

	  always @(posedge M_AXI_ACLK)                                    
	  begin                                                                
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                           
	      begin                                                            
	        axi_bready <= 1'b0;                                            
	      end                                                              
	    // accept/acknowledge bresp with axi_bready by the master          
	    // when M_AXI_BVALID is asserted by slave                          
	    else if (M_AXI_BVALID && ~axi_bready)                              
	      begin                                                            
	        axi_bready <= 1'b1;                                            
	      end                                                              
	    // deassert after one clock cycle                                  
	    else if (axi_bready)                                               
	      begin                                                            
	        axi_bready <= 1'b0;                                            
	      end                                                              
	    // retain the previous value                                       
	    else                                                               
	      axi_bready <= axi_bready;                                        
	  end                                                                  
	                                                                       
	//Flag write errors                                                    
	assign write_resp_error = (axi_bready & M_AXI_BVALID & M_AXI_BRESP[1]);


	//----------------------------
	//Read Address Channel
	//----------------------------

	//start_single_read triggers a new read transaction. read_index is a counter to
	//keep track with number of read transaction issued/initiated

//	  always @(posedge M_AXI_ACLK)                                                     
//	  begin                                                                            
//	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                       
//	      begin                                                                        
//	        read_index <= 0;                                                           
//	      end                                                                          
//	    // Signals a new read address is                                               
//	    // available by user logic                                                     
//	    else if (start_single_read)                                                    
//	      begin                                                                        
//	        read_index <= read_index + 1;                                              
//	      end                                                                          
//	  end                                                                              
	                                                                                   
	  // A new axi_arvalid is asserted when there is a valid read address              
	  // available by the master. start_single_read triggers a new read                
	  // transaction                                                                   
	  always @(posedge M_AXI_ACLK)                                                     
	  begin                                                                            
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                       
	      begin                                                                        
	        axi_arvalid <= 1'b0;                                                       
	      end                                                                          
	    //Signal a new read address command is available by user logic                 
	    else if (start_single_read)                                                    
	      begin                                                                        
	        axi_arvalid <= 1'b1;                                                       
	      end                                                                          
	    //RAddress accepted by interconnect/slave (issue of M_AXI_ARREADY by slave)    
	    else if (M_AXI_ARREADY && axi_arvalid)                                         
	      begin                                                                        
	        axi_arvalid <= 1'b0;                                                       
	      end                                                                          
	    // retain the previous value                                                   
	  end                                                                              


	//--------------------------------
	//Read Data (and Response) Channel
	//--------------------------------

	//The Read Data channel returns the results of the read request 
	//The master will accept the read data by asserting axi_rready
	//when there is a valid read data available.
	//While not necessary per spec, it is advisable to reset READY signals in
	//case of differing reset latencies between master/slave.

	  always @(posedge M_AXI_ACLK)                                    
	  begin                                                                 
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                            
	      begin                                                             
	        axi_rready <= 1'b0;                                             
	      end                                                               
	    // accept/acknowledge rdata/rresp with axi_rready by the master     
	    // when M_AXI_RVALID is asserted by slave                           
	    else if (M_AXI_RVALID && ~axi_rready)                               
	      begin                                                             
	        axi_rready <= 1'b1;                                             
	      end                                                               
	    // deassert after one clock cycle                                   
	    else if (axi_rready)                                                
	      begin                                                             
	        axi_rready <= 1'b0;                                             
	      end                                                               
	    // retain the previous value                                        
	  end                                                                   
	                                                                        
	//Flag write errors                                                     
	assign read_resp_error = (axi_rready & M_AXI_RVALID & M_AXI_RRESP[1]);  


	//--------------------------------
	//User Logic
	//--------------------------------

	//Address/Data Stimulus

	//Address/data pairs for this example. The read and write values should
	//match.
	//Modify these as desired for different address patterns.

	  //Write Addresses                                        
	  always @(posedge M_AXI_ACLK)                                  
	      begin                                                     
	        if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                
	          begin                                                 
	            axi_awaddr <= 0;                                    
	          end                                                                              
	        else
	          begin                                                 
	            axi_awaddr <= axi_awaddr_in;                            
	          end                                                   
	      end                                                       
	                                                                
	  // Write data generation                                      
	  always @(posedge M_AXI_ACLK)                                  
	      begin                                                     
	        if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 )                                
	          begin                                                 
	            axi_wdata <= 0;                  
	          end                                                   
	        // Signals a new write address/ write data is           
	        // available by user logic                              
	        else
              begin                                                 
                axi_wdata <= axi_wdata_in;                            
              end                                                  
	        end          	                                       
	  
	                                                           
	  //Read Addresses                                              
	  always @(posedge M_AXI_ACLK)                                  
	      begin                                                     
	        if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                
	          begin                                                 
	            axi_araddr <= 0;                                    
	          end                                                   
	          // Signals a new write address/ write data is         
	          // available by user logic                            
	        else //if (M_AXI_ARREADY && axi_arvalid)                  
	          begin                                                 
	            axi_araddr <= axi_araddr_in;            
	          end                                                   
	      end                                                       
	                                                                
	                                                                
	                                                               
	  always @(posedge M_AXI_ACLK)                                  
	      begin                                                     
	        if (M_AXI_ARESETN == 0)                                
	          begin                                                 
	            mst_exec_state <= 0;
	            mst_exec_state_phase <= 0;
	            write_issued <= 0;
	            start_single_write <= 0;
	            read_issued <= 0;
                start_single_read <= 0;
	            mst_exec_state_phase_complete <=0;             
	          end                                                   
	          // Signals a new write address/ write data is         
	          // available by user logic                            
	        else                    
	          begin                                                 
	            mst_exec_state <= mst_exec_state_ns;
	            mst_exec_state_phase <= mst_exec_state_phase_ns;
	            write_issued <= write_issued_ns;
	            start_single_write <= start_single_write_ns;
	            read_issued <= read_issued_ns;
                start_single_read <= start_single_read_ns;
	            mst_exec_state_phase_complete <= mst_exec_state_phase_complete_ns;
	          end                                                   
	      end            

	  //implement master command interface state machine                         
	  always @ (*)                                                    
	  begin                                                                                                                             
	       begin
	         mst_exec_state_ns  = mst_exec_state;
             mst_exec_state_phase_ns = mst_exec_state_phase;
             write_issued_ns = write_issued;
             start_single_write_ns = start_single_write;
             read_issued_ns = read_issued;
             start_single_read_ns = start_single_read;
             axi_awaddr_in =  axi_awaddr;
             axi_araddr_in = axi_araddr; 
             axi_wdata_in = axi_wdata;
             mst_exec_state_phase_complete_ns = mst_exec_state_phase_complete;
             write_reset = 1'b0;
             read_reset = 1'b0;
             read_start = 1'b0;
             write_start = 1'b0;
             //reset_run = 1'b0;
             pmod_data_ready_ns = pmod_data_ready;
           end
           
	       // state transition                                                          
	        case (mst_exec_state)                                                       
	                                                                                    
	          IDLE:                                                             
	          // This state is responsible to initiate 
	          // AXI transaction when init_txn_pulse is asserted 
	            if ( init_txn_pulse == 1'b1 )                                     
	              begin                                                                 
	                mst_exec_state_ns  = RESET_UNSET_SSR; 
	                mst_exec_state_phase_ns = RESET_UNSET_SSR;
	              end
	          
	          RESET_UNSET_SSR:
                 begin
                 if (mst_exec_state_phase_complete == 1'b0)
                      begin
                      //set up and go to write
                      axi_awaddr_in = XSP_SSR_OFFSET;
                      axi_wdata_in = ~ALS_SLAVE_REG;
                      mst_exec_state_ns = INIT_WRITE;
                      end
                    else
                      begin                         
                      mst_exec_state_ns = RESET_DEVICE;
                      mst_exec_state_phase_ns = RESET_DEVICE;
                      mst_exec_state_phase_complete_ns = 1'b0;
                      write_reset = 1'b1;
                      end
                   end
	             
//	          RESET_GET_CONTROL:
//                   begin
//                   if (mst_exec_state_phase_complete == 1'b0)
//                    begin
//                    //set up and go to read
//                    axi_araddr_in = XSP_CR_OFFSET;
//                    mst_exec_state_ns = INIT_READ;
//                    end
//                   else
//                    begin                         
//                    mst_exec_state_ns = RESET_FF;
//                    mst_exec_state_phase_ns = RESET_FF;
//                    mst_exec_state_phase_complete_ns = 1'b0;
//                    read_reset = 1'b1;
//                    end
//                   end
	          
//	          RESET_FF:
//                   begin
//                     if (mst_exec_state_phase_complete == 1'b0)
//                         begin
//                          //set up and go to write
//                          axi_awaddr_in = XSP_CR_OFFSET;
//                          axi_wdata_in = axi_rdata | XSP_CR_TRANS_INHIBIT_MASK | XSP_CR_TXFIFO_RESET_MASK | XSP_CR_RXFIFO_RESET_MASK;
//                          mst_exec_state_ns = INIT_WRITE;
//                      end
//                  else
//                      begin
//                          mst_exec_state_ns = RESET_DEVICE;
//                          mst_exec_state_phase_ns = RESET_DEVICE;
//                          mst_exec_state_phase_complete_ns = 1'b0;
//                          write_reset = 1'b1;
//                      end
//                   end
	          
	          RESET_DEVICE:
	           begin
                 if (mst_exec_state_phase_complete == 1'b0)
                     begin
                         //set up and go to write
                         axi_awaddr_in = XSP_SRR_OFFSET;
                         axi_wdata_in = XSP_SRR_RESET_MASK;
                         mst_exec_state_ns = INIT_WRITE;
                     end
                 else
                     begin
                         mst_exec_state_ns = INIT_DELAY;
                         mst_exec_state_phase_ns = INIT_DELAY;
                         mst_exec_state_phase_complete_ns = 1'b0;
                         write_reset = 1'b1;
                     end
             end
	          
	          INIT_WRITE:                                                               
	            // This state is responsible to issue start_single_write pulse to       
	            // initiate a write transaction. Write transactions will be             
	            // issued until last_write signal is asserted.                          
	            // write controller                                                     
	            if (writes_done)                                                        
	              begin                                                                 
	                mst_exec_state_ns = mst_exec_state_phase; //go back to current phase
	                mst_exec_state_phase_complete_ns = 1'b1;
	              end                                                                   
	            else                                                                    
	              begin                                                                 
	                mst_exec_state_ns  = INIT_WRITE;                                                                    
	                  if (~axi_awvalid && ~axi_wvalid && ~M_AXI_BVALID && ~last_write && ~start_single_write && ~write_issued)
	                    begin                                                           
	                      start_single_write_ns = 1'b1;                                   
	                      write_issued_ns  = 1'b1;                                        
	                    end                                                             
	                  else if (axi_bready)                                              
	                    begin                                                           
	                      write_issued_ns  = 1'b0;                                        
	                    end                                                             
	                  else                                                              
	                    begin                                                           
	                      start_single_write_ns = 1'b0; //Negate to generate a pulse      
	                    end                                                             
	              end                                                                   
	          
	          INIT_READ:                                                                
	            // This state is responsible to issue start_single_read pulse to        
	            // initiate a read transaction. Read transactions will be               
	            // issued until last_read signal is asserted.                           
	             // read controller                                                     
	             if (reads_done)                                                        
	               begin                                                                
	                 mst_exec_state_ns = mst_exec_state_phase; //go back to current phase
	                 mst_exec_state_phase_complete_ns = 1'b1;
	               end                                                                  
	             else                                                                   
	               begin                                                                
	                 mst_exec_state_ns  = INIT_READ;                                      
	                                                                                    
	                 if (~axi_arvalid && ~M_AXI_RVALID && ~last_read && ~start_single_read && ~read_issued)
	                   begin                                                            
	                     start_single_read_ns = 1'b1;                                     
	                     read_issued_ns = 1'b1;                                          
	                   end                                                              
	                 else if (axi_rready)                                               
	                   begin                                                            
	                     read_issued_ns  = 1'b0;                                          
	                   end                                                              
	                 else                                                               
	                   begin                                                            
	                     start_single_read_ns = 1'b0; //Negate to generate a pulse        
	                   end                                                              
	               end                                                                  
	                                                                                    
//	          INIT_COMPARE:                                                            
//	             begin
//	                 // This state is responsible to issue the state of comparison          
//	                 // of written data with the read data. If no error flags are set,      
//	                 // compare_done signal will be asseted to indicate success.            
//	                 ERROR <= error_reg; 
//	                 mst_exec_state <= IDLE;                                    
//	                 //compare_done <= 1'b1;                                              
//	             end                                                                          
	
//	          SEND_CONFIG:
//	           begin
//	               if (mst_exec_state_phase_complete == 1'b0)
//	                   begin
//	                       //set up and go to write
//	                       axi_awaddr_in = XSP_CR_OFFSET;
//	                       axi_wdata_in = ALS_CONFIG;
//	                       mst_exec_state_ns = INIT_WRITE;
//	                   end
//	               else
//	                   begin
//	                       mst_exec_state_ns = INIT_DELAY;
//	                       mst_exec_state_phase_ns = INIT_DELAY;
//	                       mst_exec_state_phase_complete_ns = 1'b0;
//	                       write_reset = 1'b1;
//	                   end
//	           end
	
	         INIT_DELAY:
                 begin
                    if (delay == TIMER)
                        begin
                              mst_exec_state_ns = INIT_ITR; //setup ready
                              mst_exec_state_phase_ns = INIT_ITR;
                        end
                    else
                        begin
                             mst_exec_state_ns = INIT_DELAY; //setup ready
                             mst_exec_state_phase_ns = INIT_DELAY;
                        end
                    end
       
	           
	           INIT_ITR:
	           begin
                  if (mst_exec_state_phase_complete == 1'b0)
                      begin
                       //set up and go to write
                       axi_awaddr_in = XSP_IIER_OFFSET;
                       axi_wdata_in = 32'h202B;
                       mst_exec_state_ns = INIT_WRITE;
                      end
                  else
                       begin
                        mst_exec_state_ns = INIT_DELAY_2; //setup ready
                        mst_exec_state_phase_ns = INIT_DELAY_2;
                        mst_exec_state_phase_complete_ns = 1'b0;
                        write_reset = 1'b1;
                       end
                  end
    
             INIT_DELAY_2:
                    begin
                       if (delay_2 == TIMER)
                           begin
                                 mst_exec_state_ns = SEND_CONFIG_2; //setup ready
                                 mst_exec_state_phase_ns = SEND_CONFIG_2;
                           end
                       else
                           begin
                                mst_exec_state_ns = INIT_DELAY_2; //setup ready
                                mst_exec_state_phase_ns = INIT_DELAY_2;
                           end
                       end
          
    
	           SEND_CONFIG_2:
	            begin
	               if (mst_exec_state_phase_complete == 1'b0)
                       begin
                        //set up and go to write
                        axi_awaddr_in = XSP_CR_OFFSET;
                        axi_wdata_in = ALS_CONFIG_2;
                        mst_exec_state_ns = INIT_WRITE;
                       end
                   else
                        begin
                         mst_exec_state_ns = INIT_DELAY_3; //setup ready
                         mst_exec_state_phase_ns = INIT_DELAY_3;
                         mst_exec_state_phase_complete_ns = 1'b0;
                         write_reset = 1'b1;
                        end
                   end
         
                      INIT_DELAY_3:
                          begin
                             if (delay_3 == TIMER)
                                 begin
                                       mst_exec_state_ns = CHECK_STATUS; //setup ready
                                       mst_exec_state_phase_ns = CHECK_STATUS;
                                 end
                             else
                                 begin
                                      mst_exec_state_ns = INIT_DELAY_3; //setup ready
                                      mst_exec_state_phase_ns = INIT_DELAY_3;
                                 end
                             end
                
          
         
               CHECK_STATUS:
                  begin
                    if (mst_exec_state_phase_complete == 1'b0)
                        begin
                         //setup and go to read
                         axi_araddr_in = XSP_SR_OFFSET;
                         mst_exec_state_ns = INIT_READ;
                        end
                    else
                       begin
                        if ((axi_rdata & XSP_SR_TX_FULL_MASK) == 0)  //read response
                            begin
                              //state ready can send  
                              mst_exec_state_ns = SEND_DATA; //setup ready
                              mst_exec_state_phase_ns = SEND_DATA;
                              mst_exec_state_phase_complete_ns = 1'b0;
                              read_reset = 1'b1;
                            end
                        else //redo 
                          begin
                            //state ready can send
                            mst_exec_state_ns = CHECK_STATUS; //setup ready
                            mst_exec_state_phase_ns = CHECK_STATUS;
                            mst_exec_state_phase_complete_ns = 1'b0;
                            read_reset = 1'b1;
                          end
                       end
               end
                
                SEND_DATA:
                  begin
                    if (mst_exec_state_phase_complete == 1'b0)
                        begin
                            //set up and go to write
                            axi_awaddr_in = XSP_DTR_OFFSET;
                            axi_wdata_in = 32'b0; //This can be anything
                            mst_exec_state_ns = INIT_WRITE;
                            write_start = 1'b1;
                        end
                    else
                        begin
                         if (write_counter == DATA_LENGTH)
                             begin
                              mst_exec_state_ns = SET_SSR;
                              mst_exec_state_phase_ns = SET_SSR;
                              mst_exec_state_phase_complete_ns = 1'b0;
                              write_reset = 1'b1;
                             end
                         else
                          begin
                           mst_exec_state_ns = CHECK_STATUS; //check if buffer still have space
                           mst_exec_state_phase_ns = CHECK_STATUS;
                           mst_exec_state_phase_complete_ns = 1'b0;
                           write_reset = 1'b1;
                          end
                        end
                    end
                
                SET_SSR:
                    begin
                     if (mst_exec_state_phase_complete == 1'b0)
                       begin
                       //set up and go to write
                       axi_awaddr_in = XSP_SSR_OFFSET;
                       axi_wdata_in = ALS_SLAVE_REG;
                       mst_exec_state_ns = INIT_WRITE;
                       end
                     else
                       begin                         
                       mst_exec_state_ns = GET_CONTROL;
                       mst_exec_state_phase_ns = GET_CONTROL;
                       mst_exec_state_phase_complete_ns = 1'b0;
                       write_reset = 1'b1;
                       end
                    end
               
            GET_CONTROL:
              begin
              if (mst_exec_state_phase_complete == 1'b0)
               begin
               //set up and go to read
               axi_araddr_in = XSP_CR_OFFSET;
               mst_exec_state_ns = INIT_READ;
               end
              else
               begin                         
               mst_exec_state_ns = UNSET_INHIBIT;
               mst_exec_state_phase_ns = UNSET_INHIBIT;
               mst_exec_state_phase_complete_ns = 1'b0;
               read_reset = 1'b1;
               end
              end
 
               UNSET_INHIBIT: //start the transfer
                  begin
                   if (mst_exec_state_phase_complete == 1'b0)
                     begin
                       //set up and go to write
                       axi_awaddr_in = XSP_CR_OFFSET;
                       axi_wdata_in = (axi_rdata & (~ XSP_CR_TRANS_INHIBIT_MASK));
                       mst_exec_state_ns = INIT_WRITE;
                     end
                   else
                     begin                         
                       mst_exec_state_ns = GET_INTR;
                       mst_exec_state_phase_ns = GET_INTR;
                       mst_exec_state_phase_complete_ns = 1'b0;
                       write_reset = 1'b1;
                     end
                 end
                 
           GET_INTR:
                begin
                   if (mst_exec_state_phase_complete == 1'b0)
                     begin
                      //setup and go to read
                      axi_araddr_in = XSP_IISR_OFFSET;
                      mst_exec_state_ns = INIT_READ;
                     end
                   else
                     begin
                      if ((axi_rdata & XSP_INTR_TX_EMPTY_MASK) == 0)  //read response
                      begin
                       //redo  
                       mst_exec_state_ns = GET_INTR; //setup ready
                       mst_exec_state_phase_ns = GET_INTR;
                       mst_exec_state_phase_complete_ns = 1'b0;
                       read_reset = 1'b1;
                      end
                     else
                      begin
                       //reset intr
                       mst_exec_state_ns = SET_INTR;
                       mst_exec_state_phase_ns = SET_INTR;
                       mst_exec_state_phase_complete_ns = 1'b0;
                       read_reset = 1'b1;
                      end
                   end
                 end
            SET_INTR: //clear INTR
              begin
               if (mst_exec_state_phase_complete == 1'b0)
                 begin
                  //setup and go to write
                  axi_awaddr_in = XSP_IISR_OFFSET;
                  axi_wdata_in = (axi_rdata | XSP_INTR_TX_EMPTY_MASK);
                  mst_exec_state_ns = INIT_WRITE;
                 end
               else
                begin
                  //reset intr
                  mst_exec_state_ns = GET_CONTROL_2; //setup ready
                  mst_exec_state_phase_ns = GET_CONTROL_2;
                  mst_exec_state_phase_complete_ns = 1'b0;
                  read_reset = 1'b1;
                end
               end
             
             GET_CONTROL_2:
                   begin
                    if (mst_exec_state_phase_complete == 1'b0)
                      begin
                      //set up and go to read
                      axi_araddr_in = XSP_CR_OFFSET;
                      mst_exec_state_ns = INIT_READ;
                      end
                    else
                      begin                         
                      mst_exec_state_ns = SET_INHIBIT;
                      mst_exec_state_phase_ns = SET_INHIBIT;
                      mst_exec_state_phase_complete_ns = 1'b0;
                      read_reset = 1'b1;
                      end
                   end

               SET_INHIBIT: //start the transfer
                  begin
                   if (mst_exec_state_phase_complete == 1'b0)
                     begin
                       //set up and go to write
                       axi_awaddr_in = XSP_CR_OFFSET;
                       axi_wdata_in = (axi_rdata | XSP_CR_TRANS_INHIBIT_MASK);
                       mst_exec_state_ns = INIT_WRITE;
                     end
                   else
                     begin                         
                       mst_exec_state_ns = CHECK_STATUS_READ;
                       mst_exec_state_phase_ns = CHECK_STATUS_READ;
                       mst_exec_state_phase_complete_ns = 1'b0;
                       write_reset = 1'b1;
                       //reset_run = 1'b1;
                       pmod_data_ready_ns = 1'b0;
                     end
                 end

                CHECK_STATUS_READ:
                  begin
                    if (mst_exec_state_phase_complete == 1'b0)
                        begin
                         //setup and go to read
                         axi_araddr_in = XSP_SR_OFFSET;
                         mst_exec_state_ns = INIT_READ;
                        end
                    else
                       begin
                        if ((axi_rdata & XSP_SR_RX_EMPTY_MASK) == 0)  //read response
                            begin  
                              mst_exec_state_ns = READ_DATA;
                              mst_exec_state_phase_ns = READ_DATA;
                              mst_exec_state_phase_complete_ns = 1'b0;
                              read_reset = 1'b1;
                            end
                        else //finished 
                          begin
                            mst_exec_state_ns = GET_CONTROL_3;
                            mst_exec_state_phase_ns = GET_CONTROL_3;
                            mst_exec_state_phase_complete_ns = 1'b0;
                            read_reset = 1'b1;
                            pmod_data_ready_ns = 1'b1;
                          end
                       end
                  end

                READ_DATA:
                  begin
                    if (mst_exec_state_phase_complete == 1'b0)
                        begin
                            //set up and go to read
                            axi_araddr_in = XSP_DRR_OFFSET;
                            mst_exec_state_ns = INIT_READ;
                            read_start = 1'b1;
                        end
                    else
                          begin
                           mst_exec_state_ns = CHECK_STATUS_READ; //check if buffer still have space
                           mst_exec_state_phase_ns = CHECK_STATUS_READ;
                           mst_exec_state_phase_complete_ns = 1'b0;
                           read_reset = 1'b1;
                          end
                          
                        end
                            
              GET_CONTROL_3:
                begin
                 if (mst_exec_state_phase_complete == 1'b0)
                   begin
                   //set up and go to read
                   axi_araddr_in = XSP_CR_OFFSET;
                   mst_exec_state_ns = INIT_READ;
                   end
                 else
                   begin                         
                   mst_exec_state_ns = SET_INHIBIT_2;
                   mst_exec_state_phase_ns = SET_INHIBIT_2;
                   mst_exec_state_phase_complete_ns = 1'b0;
                   read_reset = 1'b1;
                   end
                end
                
                SET_INHIBIT_2: //start the transfer
                   begin
                    if (mst_exec_state_phase_complete == 1'b0)
                      begin
                        //set up and go to write
                        axi_awaddr_in = XSP_CR_OFFSET;
                        axi_wdata_in = (axi_rdata | XSP_CR_TRANS_INHIBIT_MASK);
                        mst_exec_state_ns = INIT_WRITE;
                      end
                    else
                      begin                         
                        mst_exec_state_ns = UNSET_SSR;
                        mst_exec_state_phase_ns = UNSET_SSR;
                        mst_exec_state_phase_complete_ns = 1'b0;
                        write_reset = 1'b1;
                      end
                  end
                  
                  
               UNSET_SSR:
                      begin
                      if (mst_exec_state_phase_complete == 1'b0)
                        begin
                        //set up and go to write
                        axi_awaddr_in = XSP_SSR_OFFSET;
                        axi_wdata_in = ~ALS_SLAVE_REG;
                        mst_exec_state_ns = INIT_WRITE;
                        end
                      else
                        begin                         
                        mst_exec_state_ns = CHECK_STATUS;
                        mst_exec_state_phase_ns = CHECK_STATUS;
                        mst_exec_state_phase_complete_ns = 1'b0;
                        write_reset = 1'b1;
                        end
                     end
                  
	        endcase                                                                     
	       //end of else block
	  end //MASTER_EXECUTION_PROC
	  
	  //wire debug_wire;
	  //assign debug_wire = (write_counter == DATA_LENGTH);
	  
	  //Terminal write count
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                         
	      last_write <= 1'b0;                                                           
	                                                                                    
	    //The last write should be associated with a write address ready response       
	    else if (M_AXI_AWREADY)
	    //else if ((write_index == C_M_TRANSACTIONS_NUM) && M_AXI_AWREADY)                
	      last_write <= 1'b1;
	    else if (write_reset)
          last_write <= 1'b0;                                                           
	    else                                                                            
	      last_write <= last_write;                                                     
	  end                                                                               
	                                                                                    
	  //Check for last write completion.                                                
	                                                                                    
	  //This logic is to qualify the last write count with the final write              
	  //response. This demonstrates how to confirm that a write has been                
	  //committed.                                                                      
	                                                                                    
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                         
	      writes_done <= 1'b0;                                                          
	                                                                                    
	      //The writes_done should be associated with a bready response                 
	    else if (last_write && M_AXI_BVALID && axi_bready)                              
	      writes_done <= 1'b1;
	    else if (write_reset)
	      writes_done <= 1'b0;                                       
	    else                                                                            
	      writes_done <= writes_done;                                                   
	  end                                                                               
	                                                                                    
	//------------------                                                                
	//Read example                                                                      
	//------------------                                                                
	                                                                                    
	//Terminal Read Count                                                               
	                                                                                    
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                         
	      last_read <= 1'b0;                                             
	    //The last read should be associated with a read address ready response         
	    else if (M_AXI_ARREADY)
	    //else if ((read_index == C_M_TRANSACTIONS_NUM) && (M_AXI_ARREADY) )              
	      last_read <= 1'b1;                                                            
	    else if (read_reset)
	       last_read <= 1'b0;
	    else                                                                            
	      last_read <= last_read;                                                       
	  end                                                                               
	                                                                                    
	/*                                                                                  
	 Check for last read completion.                                                    
	                                                                                    
	 This logic is to qualify the last read count with the final read                   
	 response/data.                                                                     
	 */                                                                                 
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                         
	      reads_done <= 1'b0;                                                           
	                                                                                    
	    //The reads_done should be associated with a read ready response                
	    else if (last_read && M_AXI_RVALID && axi_rready)                               
	      reads_done <= 1'b1;
	    else if (read_reset)
	      reads_done <= 1'b0;                                                           
	    else                                                                            
	      reads_done <= reads_done;                                                     
	    end                                                                             
	                                                                                    
	//-----------------------------                                                     
	//Example design error register                                                     
	//-----------------------------                                                     
                                                                             
	//Data Comparison
	//Clock in datain                   
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                         
	      axi_rdata <= 1'b0;                                                                                                              
	    //The read data when available (on axi_rready) is compared with the expected data
	    else if ((M_AXI_RVALID && axi_rready))         
	      axi_rdata <= M_AXI_RDATA;                                               
	  end                                                                               
	                                                                                    
	// Register and hold any data mismatches, or read/write interface errors            
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                         
	      error_reg <= 1'b0;                                                            
	                                                                                    
	    //Capture any error types                                                       
	    //else if (read_mismatch || write_resp_error || read_resp_error)
	    else if (write_resp_error || read_resp_error) //only check if response has error                  
	      error_reg <= 1'b1;                                                            
	    else                                                                            
	      error_reg <= error_reg;                                                       
	  end                                                                               
	// Add user logic here
    
    always @(posedge M_AXI_ACLK)
    begin
        if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                         
           read_counter <= 2'b00; 
        else if ((read_counter == DATA_LENGTH) && read_reset)
           read_counter <= 2'b00;
        else if (read_start)
           read_counter <= read_counter + 2'b01; 
    end
    
    always @(posedge M_AXI_ACLK)
    begin
        if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                         
           write_counter <= 2'b00; 
        else if ((write_counter == DATA_LENGTH) && write_reset)
           write_counter <= 2'b00;
        else if (write_start)
           write_counter <= write_counter + 2'b01; 
    end
    
//  always @(posedge M_AXI_ACLK)
//    begin
//        if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                         
//           write_strb <= 4'b1111; 
//        else if ((write_counter == DATA_LENGTH) && write_reset)
//           write_strb <= 4'b1111;
//        else if (write_start)
//           write_strb <= 4'b0001; 
//    end

//hotfix
always @(posedge M_AXI_ACLK)
    begin
        if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                         
           begin
            result_0 <= 8'h00;
            result_1 <= 8'h00;
            result_2 <= 8'h00;
           end
        else if ((M_AXI_RVALID && axi_rready && (~pmod_data_ready_out)))
           begin
             result_0 <= axi_rdata;
             result_1 <= result_0;
             result_2 <= result_1;
             
          end
    end
    
//    always @(posedge M_AXI_ACLK)
//        begin
//            if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                         
//               begin
//                done <= 1'b0;
//                end
//            else if (reset_run)
//                done <= 1'b0;
//            else
//               begin
//                done <= set_done;
//               end
//       end
    
//    always @(posedge M_AXI_ACLK)
//       begin
//           if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                         
//              bust_count <= 4'b0; 
//           else if (read_reset)
//              bust_count <= 4'b0;
//           else if (M_AXI_RVALID && axi_rready)
//              bust_count <= bust_count + 4'b1; 
//       end
    
//    assign set_done = ((bust_count == 4'd2) && (mst_exec_state_phase == READ_DATA)) ? 1 : done;
    always  @(posedge M_AXI_ACLK)
        begin
            if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                         
                  delay <= 32'h0;
            else if (mst_exec_state_phase == INIT_DELAY)
                delay <= delay + 32'h1;
        end
     
        always  @(posedge M_AXI_ACLK)
            begin
                if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                         
                      delay_2  <= 32'h0;
                else if (mst_exec_state_phase == INIT_DELAY_2)
                    delay_2 <= delay_2 + 32'h1;
            end
              
              
              always  @(posedge M_AXI_ACLK)
                begin
                    if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                         
                          delay_3  <= 32'h0;
                    else if (mst_exec_state_phase == INIT_DELAY_3)
                        delay_3 <= delay_3 + 32'h1;
                end
     
    always @(posedge M_AXI_ACLK)
           begin
               if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                         
                  pmod_data_ready <= 4'b0; 
               else 
                  pmod_data_ready <= pmod_data_ready_ns; 
           end
    
	// User logic ends
	endmodule
