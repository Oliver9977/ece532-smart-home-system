`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2020 04:54:45 PM
// Design Name: 
// Module Name: sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//Simulation to test character module
module tb();
	logic reset;
	logic clk, clk2;
	initial clk = '0;
	initial clk2 = '0;
	always #5 clk = ~clk;
	always #20 clk2 = ~clk2;
	
	task reset_design();
		reset = '0;
		@(posedge clk2);
		@(posedge clk2);
		reset = '1;
	endtask
	
	    localparam FONT_SIZE = 5; 
    localparam UPSCALING_SIZE = 4; 
    
    //Sensor Values
    logic [15:0] i_temperature_sensor_val;
    logic [7:0] i_light_sensor_val;
    logic i_distance_sensor_val;
    logic [5:0] i_weather_val;
    logic [7:0] i_weather_temperature; //Range is -128 to 128
    
    //Decision IP values
    logic [1:0] i_climate_control; //bit 0 is for cooling sytem, bit 1 is for heating system
    logic [7:0] i_climate_control_temperature; //More than enough bits to display temperature
    logic i_open_door; //Set to 1 while door is open, set back to 0 when door should close
    logic [2:0] i_enable_light; //bit 0 is for the bedroom lights (distance sensor), bit 1 is for the living room lights (distance sensor), bit 2 is for the outdoor lights (light sensor)
    
    
    logic i_animate;
    
    logic [9:0] i_vga_x;      // current pixel x position
    logic [8:0] i_vga_y;       // current pixel y position
    logic [15:0] o_foreground;
	
drawing_controller #(
             .VGA_WIDTH(640),
             .VGA_HEIGHT(480)
         )drawing_controller_inst(
             .clk(clk), .reset(reset),
             .vga_clk(clk2),
             
             .i_temperature_sensor_val(i_temperature_sensor_val),
             .i_light_sensor_val(i_light_sensor_val),
             .i_distance_sensor_val(i_distance_sensor_val),
             .i_weather_val(i_weather_val),
             .i_weather_temperature(i_weather_temperature),
             
             //Decision IP values
             .i_climate_control(i_climate_control), 
             .i_climate_control_temperature(i_climate_control_temperature), 
             .i_open_door(i_open_door), 
             .i_enable_light(i_enable_light), 
             
             .i_animate(i_animate),
             
             .i_vga_x(i_vga_x),      // current pixel x position
             .i_vga_y(i_vga_y),       // current pixel y position
             .o_foreground(o_foreground)
         
             );
           
    int row, col;       
 // This block drives the simulation
	initial begin
    i_temperature_sensor_val = 16'd0;
    i_light_sensor_val =8'd0;
     i_distance_sensor_val = 1'd0;
     i_weather_val = 6'd0;
    i_weather_temperature = 8'd0; //Range is -128 to 128
    
    //Decision IP values
    i_climate_control = 2'd0;
     i_climate_control_temperature = 8'd0;
    i_open_door = 1'd0;
    i_enable_light = 3'd0;
    
    
   i_animate = 1'd0;

    i_vga_x = 10'd0;   // current pixel x position
    i_vga_y = 9'd0;       // current pixel y position
		
		reset_design();
		@(posedge clk2);
        @(negedge clk2); 
        
        i_animate = 1'd1;
        i_climate_control = 2'b01;
        i_climate_control_temperature = 8'd30;
        i_enable_light = 3'b111;
        
        @(posedge clk2);
        @(negedge clk2); 
        
        for(row = 240; row < 250; row = row + 1) begin
            for(col = 20; col < 40; col = col + 1) begin
                i_vga_x = col;
                i_vga_y = row;
                        
                 @(posedge clk2);
                @(negedge clk2); 
            
             end
        
        end
        
      
		$display("Test passed!");
		$stop();	
		
	end
endmodule
