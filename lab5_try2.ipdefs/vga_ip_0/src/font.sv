`timescale 1ns / 1ps

module text_buffer #(
parameter VGA_WIDTH = 640,
parameter VGA_HEIGHT = 480,
    parameter FONT_WIDTH = 8,
    parameter FONT_HEIGHT = 15,
    parameter BUFFER_SIZE = 4, //Must be 12 or lower
    parameter UPSCALING_SIZE = 1,
    parameter NUM_CHARS = 95,
    parameter LETTER_Y_START = 9'd75,
    parameter LETTER_X_START = VGA_WIDTH/2,
    parameter FONT_MEM_LINES = FONT_HEIGHT*NUM_CHARS
	)(
    input clk,
    input vga_clk, //25 MHz
    input reset,
    
    input [9:0] i_vga_x,      // current pixel x position
    input [8:0] i_vga_y,       // current pixel y position
    //Current Max buffer size is 4
    input [BUFFER_SIZE-1:0][7:0] character, //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
    output enable_char_pixel,
    output  [15:0] pixel
    
    );
    
      localparam MAX_BUFFER_SIZE = 12;
      //Character module. Draw a character in the middle of the screen
      wire [MAX_BUFFER_SIZE-1:0] load_char_pixel;
      wire [MAX_BUFFER_SIZE-1:0][$clog2(FONT_HEIGHT)-1:0] row_addr;
      wire [MAX_BUFFER_SIZE-1:0][$clog2(FONT_WIDTH)-1:0] col_addr;
       wire [MAX_BUFFER_SIZE-1:0][7:0] temp_char;
       wire [MAX_BUFFER_SIZE-1:0] temp_first_row_pixel;
      
    assign enable_char_pixel = | load_char_pixel; //reduction OR
    
    
    //Timing Fix. Delays char pixel by 1 cycle but it shouldnt; matter as VGA clock is 4x slower
    reg [9:0] vga_x_reg;    
    reg [8:0] vga_y_reg;
    always_ff @(posedge clk) begin
        if(!reset) begin
            vga_x_reg <= 10'd0;
            vga_y_reg <= 9'd0;
        end
        else begin
            vga_x_reg <= i_vga_x;
            vga_y_reg <= i_vga_y;      
        end
    end


      localparam TOTAL_X_FONT_SIZE = FONT_WIDTH * UPSCALING_SIZE;
      localparam TOTAL_Y_FONT_SIZE = FONT_HEIGHT * UPSCALING_SIZE;
      localparam SPACE_BETWEEN_LETTERS = 3;
      localparam TOTAL_BUFFER_SIZE = TOTAL_X_FONT_SIZE * BUFFER_SIZE + SPACE_BETWEEN_LETTERS*(BUFFER_SIZE-1); //Space inbetwee
      //Same for all letters
     
     localparam LETTER_Y_END = LETTER_Y_START + TOTAL_Y_FONT_SIZE;
      
      

    //Generate enable signals and modules for each letter
    //Note that Space is added inbetween letters on the X axis and the Y limits are identical for each letter
      genvar i;
      generate
      for(i = 0; i < MAX_BUFFER_SIZE; i = i+1) begin
            if(i >= BUFFER_SIZE) begin
            //Set remaining values to 0 if we want a smaller buffer
                assign load_char_pixel[i] = 1'b0;
                assign temp_char[i] = 8'd0;
                assign row_addr[i] = 0;
                assign col_addr[i] = 0;
                assign temp_first_row_pixel[i] = 0;
            end
            else begin
                assign load_char_pixel[i] = (vga_y_reg >=  LETTER_Y_START && vga_x_reg >= (LETTER_X_START + i*(TOTAL_X_FONT_SIZE + SPACE_BETWEEN_LETTERS)) && vga_y_reg <  LETTER_Y_END && vga_x_reg < (LETTER_X_START + i*(TOTAL_X_FONT_SIZE + SPACE_BETWEEN_LETTERS) + TOTAL_X_FONT_SIZE));
                assign temp_char[i] = character[i];
                
                char_drawing_controller   #(
                   .FONT_WIDTH(FONT_WIDTH),
                   .FONT_HEIGHT(FONT_HEIGHT),
                   .UPSCALING_SIZE(UPSCALING_SIZE)
                   ) char_draw_inst(
                     .clk(clk),
                     .vga_clk(vga_clk),
                     .reset(reset),
                     .first_row_pixel(temp_first_row_pixel[i]),
                     .load_pixel(load_char_pixel[i]),
                     .row_addr(row_addr[i]),
                     .col_addr(col_addr[i])
                     );
        end
      end
      endgenerate
  
          //Not sure how to do this in generate
          logic [7:0] current_char, current_char_reg;
          logic first_row_pixel;
          logic [$clog2(FONT_HEIGHT)-1:0] current_row_addr, current_row_addr_reg;
          logic [$clog2(FONT_WIDTH)-1:0] current_col_addr, current_col_addr_reg;
          always @(*) begin
            case(load_char_pixel) 
                12'b000000000001 : begin
                    current_char = temp_char[0]; current_row_addr = row_addr[0]; current_col_addr = col_addr[0];
                    first_row_pixel = temp_first_row_pixel[0];
                end
                12'b000000000010 : begin
                    current_char = temp_char[1]; current_row_addr = row_addr[1]; current_col_addr = col_addr[1];  
                    first_row_pixel = temp_first_row_pixel[1];       
                end
                12'b000000000100 : begin
                    current_char = temp_char[2]; current_row_addr = row_addr[2]; current_col_addr = col_addr[2]; 
                    first_row_pixel = temp_first_row_pixel[2];  
                end
                12'b000000001000 : begin
                    current_char = temp_char[3]; current_row_addr = row_addr[3]; current_col_addr = col_addr[3];
                    first_row_pixel = temp_first_row_pixel[3];   
                end
                12'b000000010000 : begin
                    current_char = temp_char[4]; current_row_addr = row_addr[4]; current_col_addr = col_addr[4];   
                    first_row_pixel = temp_first_row_pixel[4];
                end
                12'b000000100000 : begin
                    current_char = temp_char[5]; current_row_addr = row_addr[5]; current_col_addr = col_addr[5]; 
                    first_row_pixel = temp_first_row_pixel[5];  
                end
                12'b000001000000 : begin
                    current_char = temp_char[6]; current_row_addr = row_addr[6]; current_col_addr = col_addr[6];   
                    first_row_pixel = temp_first_row_pixel[6];
                end
                12'b000010000000 : begin
                    current_char = temp_char[7]; current_row_addr = row_addr[7]; current_col_addr = col_addr[7];  
                    first_row_pixel = temp_first_row_pixel[7]; 
                end
                12'b000100000000 : begin
                    current_char = temp_char[8]; current_row_addr = row_addr[8]; current_col_addr = col_addr[8];  
                    first_row_pixel = temp_first_row_pixel[8]; 
                end
                12'b001000000000 : begin
                    current_char = temp_char[9]; current_row_addr = row_addr[9]; current_col_addr = col_addr[9];  
                    first_row_pixel = temp_first_row_pixel[9]; 
                end   
                12'b010000000000 : begin
                    current_char = temp_char[10]; current_row_addr = row_addr[10]; current_col_addr = col_addr[10];  
                    first_row_pixel = temp_first_row_pixel[10]; 
                end              
                12'b100000000000 : begin
                    current_char = temp_char[11]; current_row_addr = row_addr[11]; current_col_addr = col_addr[11];  
                    first_row_pixel = temp_first_row_pixel[11]; 
                end                                         
                default : begin
                    current_char = 8'd0;  
                    current_row_addr = 0;
                     current_col_addr =0;
                    first_row_pixel = 1'b1;
                end
            endcase
          end
          
          wire [15:0] temp_pixel;
            char_mem #(
                .FONT_WIDTH(FONT_WIDTH),
                .FONT_HEIGHT(FONT_HEIGHT),
                .NUM_CHARS(NUM_CHARS),
                .FONT_MEM_LINES(FONT_MEM_LINES)
            ) char_mem_inst (
                .clk(clk),
                .row_addr(current_row_addr_reg), 
                .col_addr(current_col_addr_reg),
                .character(current_char_reg),
                
                .pixel(temp_pixel)
            );
    
    assign pixel = (current_char == 8'd0 || first_row_pixel == 1'b1) ? 16'd0 : temp_pixel;
    
    //Timing fix

    always @(posedge clk) begin
        if(!reset) begin
           current_char_reg <= 8'd0;
           current_row_addr_reg <= 0;
           current_col_addr_reg <= 0;
        end
        else begin
           current_char_reg <= current_char;
           current_row_addr_reg <= current_row_addr;
           current_col_addr_reg <= current_col_addr;
        end
    end

    
endmodule

//Single memory block for font. This should only be instantiated once per buffer or ideally once for the entire screen
module char_mem #(
    parameter FONT_WIDTH = 8,
    parameter FONT_HEIGHT = 15,
    parameter NUM_CHARS = 95,
    parameter FONT_MEM_LINES = FONT_HEIGHT*NUM_CHARS
) (
    input clk,
    input [$clog2(FONT_HEIGHT)-1:0] row_addr, 
    input [$clog2(FONT_WIDTH)-1:0] col_addr,
    input [7:0] character, //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
    
    output [15:0] pixel
);

    reg [FONT_WIDTH-1:0] font_mem [0:FONT_MEM_LINES-1];
    wire [$clog2(FONT_MEM_LINES)-1:0] read_addr;
    
    assign read_addr = (character * FONT_HEIGHT) + row_addr;
    
    initial
    begin
        $readmemb("clacon_font.mem", font_mem); //clacon_font.mem must be added to the Vivado project
    end
    
    reg [FONT_WIDTH-1:0] font_read_val;
    
     always @ (posedge clk) begin
          font_read_val <= font_mem[read_addr];
    end
    
    //Select appropriate bit and extend it to form white pixel
    wire black_or_white;
    assign black_or_white = font_read_val[col_addr];
    assign pixel = {16{black_or_white}};



endmodule

//Drawing controller takes care of upscaling and keeps track of the current row/col pixel we need to draw next
//The font memory itself is a central memory outside this module
module char_drawing_controller  #(
    parameter FONT_WIDTH = 8,
    parameter FONT_HEIGHT = 15,
    parameter UPSCALING_SIZE = 1,
    parameter NUM_CHARS = 95,
    parameter FONT_MEM_LINES = FONT_HEIGHT*NUM_CHARS
	)(
    input clk,
    input vga_clk, //25 MHz
    input reset,
    
    input load_pixel,
    
    output first_row_pixel, //For bug fix, we are on first pixel for each row
    output [$clog2(FONT_HEIGHT)-1:0] row_addr, 
    output [$clog2(FONT_WIDTH)-1:0] col_addr
    
    );
    
    
    //Counters for drawing letter
    reg [$clog2(FONT_HEIGHT)-1:0] row_counter;
    reg [$clog2(FONT_WIDTH)-1:0] col_counter;
    wire row_counter_done, col_counter_done;
    assign col_counter_done = (col_counter == FONT_WIDTH-1);
    assign row_counter_done = (row_counter == FONT_HEIGHT-1);
    
    //Upscaling counter: only advance letter pixel once upsaling factor is reached
    reg [$clog2(UPSCALING_SIZE)-1:0] upscaling_col_reg, upscaling_row_reg;
    wire col_upscale_limit_reached, row_upscale_limit_reached;
    assign col_upscale_limit_reached = (upscaling_col_reg == UPSCALING_SIZE-1);
    assign row_upscale_limit_reached = (upscaling_row_reg == UPSCALING_SIZE-1);
    always_ff @(posedge vga_clk) begin
        if (!reset) begin
            upscaling_col_reg <= 0;
            upscaling_row_reg <= 0;
        end
        else begin
            if (!col_upscale_limit_reached) upscaling_col_reg <= load_pixel ? upscaling_col_reg + 1'b1 : upscaling_col_reg;
            else upscaling_col_reg <=  0 ;
            
            //Row upscale must only be activated once column upscalse has been activated once for every column
            if (!row_upscale_limit_reached) upscaling_row_reg <= (load_pixel && col_upscale_limit_reached && col_counter_done) ? upscaling_row_reg + 1'b1 : upscaling_row_reg;
            else upscaling_row_reg <= ( col_upscale_limit_reached && col_counter_done) ? 0 : upscaling_row_reg;
        end
    end
    
    
   // assign first_row_pixel = (col_counter_done);
   assign first_row_pixel = 1'b0; //Above doesn't fix the issue
    
    //Row and column counters for current pixel
    //They should only be increased when the appropriate upscale counters have saturated
    always_ff @(posedge vga_clk) begin
        if(!reset) begin
            row_counter <= 0;
            col_counter <= 0;
        end
        else begin
            if(col_upscale_limit_reached && load_pixel) col_counter <= (col_counter_done)? 0 : col_counter + 1'b1;
            else col_counter <= col_counter;
            
            if(row_upscale_limit_reached && load_pixel && col_upscale_limit_reached && col_counter_done) row_counter <= row_counter_done ? 0 : row_counter + 1'b1;
            else row_counter <= row_counter;   
        end
    end
    
    assign row_addr = row_counter;
    assign col_addr = col_counter;

    
endmodule





//Converts a 16 bit hex number to decimal. This will take a number of cycles and it will only update the output register once the value is ready
//Note that we use modulo to do this: a % b = a - (b * int(a/b))
//Division is implemented as fixed point multiplication

module convert_hex_to_decimal (
    input clk, reset,
    
    output logic done, //Only use if needed

    input [15:0] hex_number,
    output logic [6:0][7:0] decimal_number //Max number is 0xffff = 65535 , also add °C
    
);

//We will use 32 bit fixed point (16 bit int, 16 bit decimal, no negative numbers)

// 1/10
localparam DIVISION_VALUE = 6554;
localparam MULTIPLICATION_VALUE = 655360;
logic store_result, go, enable_division, update_reg, increment_counter;
reg [2:0] counter;
wire [15:0] new_hex_from_dsp;

//Last hex number, only activate FSM when it changes
reg [15:0] last_hex, cur_hex, cur_hex_pipelined, last_hex_pipelined;

always_ff @(posedge clk) begin
    if(!reset) begin
        last_hex <= 15'd0;
        last_hex_pipelined <= 15'd0;
        cur_hex <= 15'd0;
        cur_hex_pipelined <= 15'd0;

    end
    else begin
        last_hex <= hex_number;
        last_hex_pipelined <= last_hex;
        cur_hex <= go ? hex_number : (update_reg ? new_hex_from_dsp : cur_hex );
        cur_hex_pipelined <= cur_hex;

    end
end

assign go =  (last_hex != hex_number) || (last_hex_pipelined != hex_number); //Sometimes new value might come close to clock edge

//FSM

enum int unsigned
	{
		S_IDLE, 
		S_DIVISION,
		S_MULT_ADD,
		S_UPDATE_RESULT,
		S_STORE,
		S_DONE

	} state, nextstate;

	always_ff @ (posedge clk) begin
		if (!reset) state <= S_IDLE; 
		else state <= nextstate;
	end

	always_comb begin
		// Set default values for signals here, to avoid having to explicitly
		// set a value for every possible control path through this always block
		nextstate = state;
		store_result = 1'b0;
		enable_division = 1'b0;
		update_reg = 1'b0;
		increment_counter = 1'b0;
		done = 1'b0;

		
		case (state)
			S_IDLE: begin
				if (go) nextstate = S_DIVISION;
			end
			
			
			S_DIVISION: begin
                enable_division = 1'b1;
				nextstate = S_MULT_ADD;
			end
			
			S_MULT_ADD: begin
                update_reg = 1'b1;
                nextstate = S_UPDATE_RESULT;
            end
                      
            S_UPDATE_RESULT: begin
                increment_counter = 1'b1;
                nextstate = (counter == 3'd4) ? S_STORE : S_DIVISION ;
            end
			
			//Store the result before asserting the done signal
			S_STORE: begin
				store_result = 1'b1;
				nextstate = S_DONE;
			end
			
			S_DONE: begin
			     done = 1'b1;
				if (!go) nextstate = S_IDLE;
			end
			
		endcase
	end
	
	//There are potentially 5 different digits we need to extract
	always_ff @(posedge clk) begin
	   if(!reset) counter <= 0;
	   else counter <= increment_counter ? (counter == 3'd4 ? 3'd0 : counter + 1'b1) : counter;
	end
	
	//Convert integer to fixed point
	wire [31:0] fp_hex_val;
	assign fp_hex_val = {hex_number, 16'd0};
	
	//Perform multiplication or division
	reg [63:0] dsp_result;
	wire [31:0] mult_factor_1, mult_factor_2, truncated_number;
	assign mult_factor_1 = enable_division ? cur_hex : truncated_number;
	assign mult_factor_2 = enable_division ? DIVISION_VALUE : MULTIPLICATION_VALUE;
	always_ff @(posedge clk)begin
	   if(!reset) dsp_result <= 64'd0;
	   else begin
	       dsp_result <= mult_factor_1 * mult_factor_2;
	   end
	end
	
	//Truncate multiplication result
	assign truncated_number = dsp_result[47:16];
    assign new_hex_from_dsp = truncated_number[15:0];
    
    //Finish taking the modulus
    wire [15:0] modulo_res;
    assign modulo_res = cur_hex_pipelined - new_hex_from_dsp;
    
    //Convert result to font index
    wire [7:0] font_res;
    hex_to_font hex_to_font_dec_inst(.hex_val(modulo_res[3:0]),.font_val(font_res) );

    //Final result
     reg [4:0][7:0] temp_decimal_number;
     always_ff @(posedge clk) begin
        if(!reset) begin
            //This is '0' in the char mem
            temp_decimal_number = {8'd16, 8'd16, 8'd16, 8'd16, 8'd16};
            decimal_number =  {8'd35, 8'd2, 8'd16, 8'd16, 8'd16, 8'd16, 8'd16};
        end
        else begin
            //Temperature must come out backwards since we write text from left to right
            temp_decimal_number[0] <= (counter  == 3'd4 && increment_counter) ? font_res : temp_decimal_number[0];
            temp_decimal_number[1] <= (counter  == 3'd3 && increment_counter) ? font_res : temp_decimal_number[1];
            temp_decimal_number[2] <= (counter  == 3'd2 && increment_counter) ? font_res : temp_decimal_number[2];
            temp_decimal_number[3] <= (counter  == 3'd1 && increment_counter) ? font_res : temp_decimal_number[3];
            temp_decimal_number[4] <= (counter  == 3'd0 && increment_counter) ? font_res : temp_decimal_number[4];
            decimal_number[4:0] <= store_result ? temp_decimal_number : decimal_number[4:0]; //Only store at the end so value is stable
        end
     end

endmodule

module hex_to_font (
    input [3:0] hex_val,
    output  [7:0] font_val


);

wire [7:0] offset_val, mod_hex_val;
assign mod_hex_val = {4'd0, hex_val};
assign offset_val = (hex_val < 4'd10) ? 8'd16 : (8'd33 - 8'd10);
assign font_val = offset_val + mod_hex_val;

endmodule



//Font Reference
/*

A - 33
B - 34
C - 35
D - 36
E - 37
F - 38
G - 39
H - 40
I - 41
J - 42
K - 43
L - 44
M - 45
N - 46
O - 47
P - 48
Q - 49
R - 50
S - 51
T - 52
U - 53
V - 54
W - 55
X - 56
Y - 57
Z - 58






*/
