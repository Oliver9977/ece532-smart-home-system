`timescale 1ns / 1ps


//Weather buffer
module weather_buffer #(
    parameter WEATHER_WIDTH = 50,
    parameter SCALING_FACTOR = 1, //Actual scaling factor is 2^SCALING_FACTOR
    parameter WEATHER_OFFSET = 3, //First weather object ID
    parameter NUM_WEATHER_TYPES = 9,
	parameter WEATHER_HEIGHT = 50
	) (
      input clk, reset,
      input i_read_en,
      input [5:0] weather_type,
      input [9:0] i_read_x,  
      input [8:0] i_read_y,
      output logic [15:0] o_read_val // {alpha[3:0], red[3:0], green[3:0], blue[3:0]}
	);
	
	//Since weather is actually 50x50 scale it by 2
	wire [9:0] read_x;
    wire [8:0] read_y;
    assign read_x = i_read_x >> SCALING_FACTOR;
	assign read_y = i_read_y >> SCALING_FACTOR;
	
	wire [NUM_WEATHER_TYPES-1:0][15:0] weather_read_val;
	
	genvar i;
    generate
    for (i=0; i<NUM_WEATHER_TYPES; i=i+1) begin: weather_gen
        object_buffer #(
              .OBJ_HEIGHT(50),
              .OBJ_WIDTH(50),
              .OBJECT(WEATHER_OFFSET + i) //Index for light sensor
              ) weather_obj_inst (
              .clk(clk), 
              .reset(reset),
              .i_read_en(i_read_en),            
              .i_read_x(read_x),  
              .i_read_y(read_y),
              .o_read_val(weather_read_val[i]) // {alpha[3:0], red[3:0], green[3:0], blue[3:0]}
               );
    
    end
    endgenerate
    
    always @(*) begin
        case(weather_type)
          6'd1   : o_read_val = weather_read_val[0];     
          6'd2   : o_read_val = weather_read_val[1];     
          6'd3   : o_read_val = weather_read_val[2];   
          6'd4   : o_read_val = weather_read_val[3];  
          6'd9   : o_read_val = weather_read_val[4];  
          6'd10   : o_read_val = weather_read_val[5];  
          6'd11   : o_read_val = weather_read_val[6];  
          6'd13   : o_read_val = weather_read_val[7];  
          6'd50   : o_read_val = weather_read_val[8];  
          default  : o_read_val = weather_read_val[0];     
        endcase
    
    end
	
endmodule

