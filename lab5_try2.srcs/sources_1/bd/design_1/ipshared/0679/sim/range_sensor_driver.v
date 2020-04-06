
`timescale 1 ns / 1 ps

module range_sensor_driver #
(
    // Parameters of Axi Slave Bus Interface axi_reg
    parameter C_M_TARGET_SLAVE_BASE_ADDR	= 32'h00010000,
    parameter integer C_axi_reg_DATA_WIDTH	= 32,
    parameter integer C_axi_reg_ADDR_WIDTH	= 32,
    //needs power of 2s for ez shifting divisions
    parameter integer BG_CNT                = 4,
    parameter integer SAMPLE_CNT            = 4,
    //for comparing the current range and the background range
    //means to omit THRESHOLD bits
    //the threshold in cm is equivalent to 
    //    2^THRESHOLD/14700*2.54  
    parameter integer THRESHOLD             = 18, //45.3cm
    parameter integer DEBUG_MODE            = 1
)
(
    // Users to add ports here
      output [C_axi_reg_DATA_WIDTH-1:0] o_range_raw,
      //output [C_axi_reg_DATA_WIDTH-1:0] o_range,
      output [C_axi_reg_DATA_WIDTH-1:0] o_background,
      output [C_axi_reg_DATA_WIDTH-1:0] o_current,
      output o_bg_end,
      output o_sample_end,
      
	  
	  input aclk,
      input aresetn,
	  
	/*
    // AXI-Lite slave interface
      input [31:0]  S_AXI_AWADDR,
      input         S_AXI_AWVALID,
      output        S_AXI_AWREADY,
    
      input [31:0]  S_AXI_WDATA,
      input [3:0]   S_AXI_WSTRB,
      input         S_AXI_WVALID,
      output        S_AXI_WREADY,
    
      output [1:0]  S_AXI_BRESP,
      output        S_AXI_BVALID,
      input         S_AXI_BREADY,
    
      input [31:0]  S_AXI_ARADDR,
      input         S_AXI_ARVALID,
      output        S_AXI_ARREADY,
    
      output [31:0] S_AXI_RDATA,
      output [1:0]  S_AXI_RRESP,
      output        S_AXI_RVALID,
      input         S_AXI_RREADY,
    */
      // AXI-Lite master interface
      output reg [C_axi_reg_ADDR_WIDTH-1:0] M_AXI_AWADDR,
      output reg        M_AXI_AWVALID,
      input         	M_AXI_AWREADY,
    
      output reg [C_axi_reg_DATA_WIDTH-1:0] M_AXI_WDATA,
      output reg [3:0]  M_AXI_WSTRB,
      output reg        M_AXI_WVALID,
      input         	M_AXI_WREADY,
    
      input [1:0]   	M_AXI_BRESP,
      input         	M_AXI_BVALID,
      output reg    	M_AXI_BREADY,
		
	  output reg [C_axi_reg_ADDR_WIDTH-1:0] M_AXI_ARADDR,
      output reg        M_AXI_ARVALID,
      input	        	M_AXI_ARREADY,
						
      input [C_axi_reg_DATA_WIDTH-1:0] 		M_AXI_RDATA,
      input [1:0]	  	M_AXI_RRESP,
      input 	       	M_AXI_RVALID,
      output reg        M_AXI_RREADY,
    
      //to decision IP
      output reg range_status
);

//master write logic
//states for AXI-Lite Master write
localparam  I0  = 0, 
            I1  = 1,
            BG0 = 2,
            BG1 = 3,
            RD0 = 4,
            RD1 = 5,
            RD2 = 6,
            P0  = 7,
            P1  = 8;
      
reg [3:0] state, nextstate;
reg [1:0] rd_mode;
reg find_bg, find_p, store_bg, store_prev;
reg [C_axi_reg_DATA_WIDTH-1:0] range_pwm;
reg [C_axi_reg_DATA_WIDTH+$clog2(BG_CNT):0] sum;
reg [C_axi_reg_DATA_WIDTH-1:0] background;
reg [C_axi_reg_DATA_WIDTH-1:0] prev_dist;

//timer
reg [31:0] wait_time;
reg reset_timer;
reg [31:0] timer;
wire time_out;

//sample cnts
reg	[BG_CNT-1:0] sample_cnt;
reg sample_start;
wire bg_end, sample_end;

//redetect background after X number of person detect
reg [3:0] reset_cnt;


//================================DATAPATH
//sensor data
always @(posedge aclk) begin
    if (aresetn == 1'b0) range_pwm <= 0;
    else if (M_AXI_RVALID)
		range_pwm <= M_AXI_RDATA;
end

assign o_range_raw = range_pwm;
//assign o_range = o_range_raw / 14700;
assign o_background = background;
assign o_current = prev_dist;
assign o_bg_end = bg_end;
assign o_sample_end = sample_end;

//detecting number of samples based on the shifted bit
always @(posedge aclk) begin
    if (aresetn == 1'b0 | sample_start) sample_cnt <= 0;
    else if (M_AXI_RVALID) begin
        sample_cnt <= sample_cnt + 1'b1;
    end
end
assign sample_end = (sample_cnt == SAMPLE_CNT);
assign bg_end = (sample_cnt == BG_CNT);

//timer
always @(posedge aclk) begin
    if (aresetn == 1'b0 || reset_timer == 1'b1) timer <= 0;
    else timer <= timer + 1'b1;
end
//clk period 10ns, reading available every 49ms
assign time_out = (timer == 32'd4900000);

//sum of the samples
always @(posedge aclk) begin
    if (aresetn == 1'b0 || sample_start == 1'b1) sum <= 0;
    else if (M_AXI_RVALID) begin
        sum <= sum + M_AXI_RDATA;
    end
end

//records which register will the averaged reading be stored in
always @(posedge aclk) begin
    if (aresetn == 1'b0) rd_mode <= 0;
    else begin
        if (find_bg)
            rd_mode <= 2'd1;
        else if (find_p)
            rd_mode <= 2'd2;
    end
end

//reference registers
//bg stores the initial background distance
always @(posedge aclk) begin
    if (aresetn == 1'b0) begin
        background <= 0;
        prev_dist <= 0;
    end
    else begin
        if (store_bg)
            background <= (sum >> $clog2(BG_CNT));
        
        if (store_prev)
            prev_dist <= (sum >> $clog2(SAMPLE_CNT));
    end
end

//number of person detections
always @(posedge aclk) begin
    if (aresetn == 1'b0) reset_cnt <= 0;
    else if (find_p)
		reset_cnt <= reset_cnt + 1'b1;
end

//final status to decision IP
//0: person not present
//1: person present
always @(*) begin
    if (background[C_axi_reg_DATA_WIDTH-1:THRESHOLD] 
            == prev_dist[C_axi_reg_DATA_WIDTH-1:THRESHOLD])
        range_status = 1'b0;
    else
        range_status = 1'b1;
end

//================================FSM
always @(posedge aclk) begin
    if (aresetn == 1'b0) state <= I0;
    else state <= nextstate;
end

always @(*) begin
    nextstate = state;
    find_bg = 0;
    find_p = 0;
    store_bg = 0;
    store_prev = 0;
    
    //averaging
    reset_timer = 0;
    sample_start = 0;
        
	//master read
	M_AXI_ARADDR = C_M_TARGET_SLAVE_BASE_ADDR;
	M_AXI_ARVALID = 0;
	
	M_AXI_RREADY = 0;
	
	//master write, not used
    M_AXI_AWADDR  = C_M_TARGET_SLAVE_BASE_ADDR;
    M_AXI_AWVALID = 0;
    
    M_AXI_WDATA   = 0;
    M_AXI_WSTRB   = 4'hf;
    M_AXI_WVALID  = 0;
    
    M_AXI_BREADY  = 0;

    
    case (state)
        //I: waiting for the sensor to initialize and self-calibrate
        I0: begin
            reset_timer = 1'b1;
            nextstate = I1;   
        end
        
        I1: begin
            wait_time = 32'd40000000;//actual 399ms
            if (time_out)
                nextstate = BG0;
        end
        
        //BG states: finding the background distance
        BG0: begin
            find_bg = 1'b1;
            sample_start = 1'b1;
            nextstate = RD0;
        end
        
        BG1: begin
            store_bg = 1'b1;
            nextstate = P0;
        end
        
        //P states: detecting any person/object
        P0: begin
            find_p = 1'b1;
            sample_start = 1'b1;
            nextstate = RD0;
        end
        
        P1: begin
            store_prev = 1'b1;
            if (&reset_cnt)
                nextstate = BG0;
            else
                nextstate = P0;
        end
        
        //RD states: sending a read request
		//and waiting for slave to accept the address
        RD0: begin
			M_AXI_ARADDR = C_M_TARGET_SLAVE_BASE_ADDR + 32'd4; //PWM
			M_AXI_ARVALID  = 1'b1;
			M_AXI_RREADY  = 1'b1;
			if (M_AXI_ARREADY)
				nextstate = RD1;
        end
        
        //waiting for the read data
        RD1: begin
			M_AXI_RREADY  = 1'b1;
			if (M_AXI_RVALID) begin
			    reset_timer = 1'b1;
				nextstate = RD2;
			end
        end
        
        //waits every 49 ms
        RD2: begin
            wait_time = 32'd4900000;//49ms
            if (time_out) begin
                //finished average
                if (sample_end) begin
                    case(rd_mode)
                        2'd1: nextstate = BG1;
                        2'd2: nextstate = P1;
                        default: nextstate = I0;
                    endcase
                end
                //get the next sample
                else
                    nextstate = RD0;
            end
        end
    
        default: nextstate = I0;
    endcase
end


/*
// Instantiation of Axi Bus Interface axi_reg
axi_reg # ( 
    .C_S_AXI_DATA_WIDTH(C_axi_reg_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH(C_axi_reg_ADDR_WIDTH)
) axi_reg_inst (
    //added ports begin
	
	//added ports end
    .S_AXI_ACLK(aclk),
    .S_AXI_ARESETN(aresetn),
    .S_AXI_AWADDR(S_AXI_AWADDR),
    //.S_AXI_AWPROT(axi_reg_awprot),
    .S_AXI_AWVALID(S_AXI_AWVALID),
    .S_AXI_AWREADY(S_AXI_AWREADY),
    .S_AXI_WDATA(S_AXI_WDATA),
    .S_AXI_WSTRB(S_AXI_WSTRB),
    .S_AXI_WVALID(S_AXI_WVALID),
    .S_AXI_WREADY(S_AXI_WREADY),
    .S_AXI_BRESP(S_AXI_BRESP),
    .S_AXI_BVALID(S_AXI_BVALID),
    .S_AXI_BREADY(S_AXI_BREADY),
    .S_AXI_ARADDR(S_AXI_ARADDR),
    //.S_AXI_ARPROT(axi_reg_arprot),
    .S_AXI_ARVALID(S_AXI_ARVALID),
    .S_AXI_ARREADY(S_AXI_ARREADY),
    .S_AXI_RDATA(S_AXI_RDATA),
    .S_AXI_RRESP(S_AXI_RRESP),
    .S_AXI_RVALID(S_AXI_RVALID),
    .S_AXI_RREADY(S_AXI_RREADY)
);


//master write logic
always @(*) begin
    nextstate = state;
    
	//master read
	M_AXI_ARADDR = 0;
	M_AXI_ARVALID = 0;
	
	M_AXI_RREADY = 0;
	
	//master write
    M_AXI_AWADDR  = 0;
    M_AXI_AWVALID = 0;
    
    M_AXI_WDATA   = 0;
    M_AXI_WSTRB   = 4'hf;
    M_AXI_WVALID  = 0;
    
    M_AXI_BREADY  = 0;

    case (state)
        //waiting for a write request
        S0: begin
            if (init_write) begin
                M_AXI_AWVALID = 1'b1;
                M_AXI_WVALID  = 1'b1;
                M_AXI_BREADY  = 1'b1;
                nextstate = S1;
            end
        end
        
        //waiting for either address or write-data ready signals from the slave
        S1: begin
            M_AXI_BREADY  = 1'b1;
            M_AXI_AWVALID = 1'b1;
            M_AXI_WVALID  = 1'b1;
            
            //these ready signals could arrive at different time
            //thus we need intermediate states
            case({M_AXI_AWREADY, M_AXI_WREADY})
                2'b11: begin
                     nextstate = S4;
                end
                    
                2'b10: begin
                     nextstate = S2;        
                end
                
                2'b01: begin
                     nextstate = S3;                           
                end
                
                2'b00: begin
                     nextstate = S1;                                           
                end
                default: nextstate = S1;
            endcase
        end
        
        //intemediate state 1 waiting for write-data ready
        S2: begin
            M_AXI_BREADY  = 1'b1;
            M_AXI_WVALID  = 1'b1;
            if (M_AXI_WREADY)
                nextstate = S4;
        end
        
        //intemediate state 1 waiting for write-addr ready
        S3: begin
            M_AXI_BREADY  = 1'b1;
            M_AXI_AWVALID = 1'b1;
            if (M_AXI_AWREADY)
                nextstate = S4;
        end
        
        //wait for ack from the slave to complete the write request
        S4: begin
            M_AXI_BREADY  = 1'b1;
            if (M_AXI_BVALID & M_AXI_BRESP[1]==0)
                nextstate = S0;
                
            //slverr-currently not implemented 
            //as it is not specified in the handout on what to do
            if (M_AXI_BVALID & M_AXI_BRESP[1]==1)
                nextstate = S0;
        end
            
    
        default: nextstate = S0;
    endcase
end
*/

// User logic ends

endmodule
