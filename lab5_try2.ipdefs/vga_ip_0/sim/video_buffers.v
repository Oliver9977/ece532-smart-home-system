`timescale 1ns / 1ps
//Video pixel buffers using block RAMs
//Note that it takes 1 cycle for any read or write, but this should be fine since the VGA clock is 4 times slower than the memory clock

module video_buffers #(
	parameter VGA_WIDTH = 640,
	parameter VGA_HEIGHT = 480
)(
    input clk, reset,

    input [9:0] i_write_x,  
    input [8:0] i_write_y,
    input i_write_en,
    input [15:0] i_write_val, // {alpha[3:0], red[3:0], green[3:0], blue[3:0]}

     input [9:0] i_read_x,  
     input [8:0] i_read_y,
     output reg [15:0] o_read_val // {alpha[3:0], red[3:0], green[3:0], blue[3:0]}
     

    );
    
    //Misc. wire definitions
    wire [$clog2(VGA_WIDTH*VGA_HEIGHT)-1:0]  write_addr, read_addr;
    wire [15:0] actual_write_val;
    wire [$clog2(VGA_WIDTH*VGA_HEIGHT)-1:0] actual_write_address;
    
    //Reset logic. Basically we want to write 0s (black) to all memory locations
    reg [$clog2(VGA_WIDTH*VGA_HEIGHT)-1:0] reset_addr;
    wire reset_done;
    assign reset_done = (reset_addr == (VGA_WIDTH*VGA_HEIGHT+1));
    always @(posedge clk) begin
        if(!reset) reset_addr <= 0;
        else begin
            reset_addr <= (reset_done) ? reset_addr : reset_addr + 1'b1;
        end
    end
    assign actual_write_val = reset_done ? i_write_val : 12'd0;
    assign actual_write_address = reset_done ? write_addr : reset_addr;
    
    
    //The actual buffers. For 640x480, each buffer uses 10 block RAMs
    reg [15:0] vga_buff0 [0:(VGA_WIDTH*VGA_HEIGHT)];
    //Calculate addresses; this will require 2 DSP blocks
    assign write_addr = i_write_y*VGA_WIDTH + i_write_x;
    assign read_addr = i_read_y*VGA_WIDTH + i_read_x;
    
    always @ (posedge clk) begin
            if (i_write_en) begin
                vga_buff0[actual_write_address] <= actual_write_val;                
            end
            
            o_read_val <= vga_buff0[read_addr];
    end
    
endmodule

//Object buffer
module object_buffer #(
    parameter OBJ_WIDTH = 100,
    parameter OBJECT = 0,
	parameter OBJ_HEIGHT = 127
	) (
      input clk, reset,
      input i_read_en,
      input [9:0] i_read_x,  
      input [8:0] i_read_y,
      output [15:0] o_read_val // {alpha[3:0], red[3:0], green[3:0], blue[3:0]}
	);
	
	wire [$clog2(OBJ_WIDTH*OBJ_HEIGHT)-1:0] read_addr;
    //Pipeline inputs for timing
    reg [9:0] reg_x;  
    reg [8:0] reg_y;
    always @(posedge clk) begin
        if(!reset) begin
            reg_x <= 0;
            reg_y <= 0;
        end
        else begin
            reg_x <= i_read_x;
            reg_y <= i_read_y;
        end
    end	
	
	assign read_addr = reg_y  *(OBJ_WIDTH) + reg_x;
	
	reg [15:0] object_mem [0:OBJ_WIDTH*OBJ_HEIGHT];

initial
begin
    if(OBJECT == 1) $readmemb("light.mem", object_mem); 
    else if(OBJECT == 2) $readmemb("person.mem", object_mem); 
    else if(OBJECT == 3) $readmemb("01d.mem", object_mem); 
    else if(OBJECT == 4) $readmemb("02d.mem", object_mem); 
    else if(OBJECT == 5) $readmemb("03d.mem", object_mem); 
    else if(OBJECT == 6) $readmemb("04d.mem", object_mem); 
    else if(OBJECT == 7) $readmemb("09d.mem", object_mem); 
    else if(OBJECT == 8) $readmemb("10d.mem", object_mem); 
    else if(OBJECT == 9) $readmemb("11d.mem", object_mem); 
    else if(OBJECT == 10) $readmemb("13d.mem", object_mem); 
    else if(OBJECT == 11) $readmemb("50d.mem", object_mem); 
    else if(OBJECT == 12) $readmemb("heating.mem", object_mem); 
    else if(OBJECT == 13) $readmemb("cooling.mem", object_mem); 
    else if(OBJECT == 14) $readmemb("light_off.mem", object_mem); 
    else if(OBJECT == 15) $readmemb("light_on.mem", object_mem); 
    else $readmemb("object.mem", object_mem); 
end
	
	reg [15:0] read_val;
	 always @ (posedge clk) begin
           read_val <= object_mem[read_addr];
     end
     assign o_read_val = i_read_en ? read_val : 16'd0;
	
endmodule


//For now this is 320x240 due to on board memory limitations
module background_buffer #(
    parameter VGA_WIDTH = 320,
	parameter VGA_HEIGHT = 240
	) (
      input clk, reset,
      input [9:0] i_read_x,  
      input [8:0] i_read_y,
      output reg [15:0] o_read_val // {alpha[3:0], red[3:0], green[3:0], blue[3:0]}
	);
	
	//For now just have a solid background colour to save space
	 always @ (posedge clk) begin
	   if(reset) o_read_val <= 16'd0;
	   else o_read_val <= {4'b1111, 12'd0};
	 end

	
	/*
	
	wire [$clog2(VGA_WIDTH*VGA_HEIGHT)-1:0] read_addr;
	assign read_addr = ((i_read_y >> 1) *(VGA_WIDTH) + (i_read_x >> 1));
	
	reg [15:0] background_mem [0:VGA_WIDTH*VGA_HEIGHT];

initial
begin
	$readmemb("background.mem", background_mem); //background.mem must be added to the Vivado project
end
	
	 always @ (posedge clk) begin
           o_read_val <= background_mem[read_addr];
     end
     */
	
endmodule
