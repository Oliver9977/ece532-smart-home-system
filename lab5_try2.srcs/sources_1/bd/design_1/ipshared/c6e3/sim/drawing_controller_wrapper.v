`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/15/2020 02:01:58 PM
// Design Name: 
// Module Name: drawing_controller_wrapper
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

//Wrapper since we can't insert systemverilog modules directly into block diagram
module drawing_controller_wrapper #(
	parameter VGA_WIDTH = 640,
    parameter VGA_HEIGHT = 480
)(
    input clk, reset,
    input vga_clk,
    
    //Sensor Values
    input [15:0] i_temperature_sensor_val,
    input [7:0] i_light_sensor_val,
    input i_distance_sensor_val,
    input [5:0] i_weather_val,
    input [7:0] i_weather_temperature, //Range is -128 to 128
    
    //Decision IP values
    input [1:0] i_climate_control, //bit 0 is for cooling sytem, bit 1 is for heating system
    input [7:0] i_climate_control_temperature, //More than enough bits to display temperature
    input i_open_door, //Set to 1 while door is open, set back to 0 when door should close
    input [2:0] i_enable_light, //bit 0 is for the bedroom lights (distance sensor), bit 1 is for the living room lights (distance sensor), bit 2 is for the outdoor lights (light sensor)
    
    
    input i_animate,
    
    input [9:0] i_vga_x,      // current pixel x position
    input [8:0] i_vga_y,       // current pixel y position
    output [15:0] o_foreground

    );


drawing_controller #(
	.VGA_WIDTH(VGA_WIDTH),
    .VGA_HEIGHT(VGA_HEIGHT)
)drawing_controller_inst(
    .clk(clk), .reset(reset),
    .vga_clk(vga_clk),
    
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



endmodule

//Combines background and object pixels based on transparency value
//To avoid doing messy division, we will only support 5 transparency values for now (0%, 25%, 50%, 75%, 100%)
module combine_background_and_objects(
    input [15:0] i_background,
    input [15:0] i_foreground,
    input o_active,
    output  [3:0] o_VGA_red,
    output  [3:0] o_VGA_green,
    output  [3:0] o_VGA_blue
);

reg [5:0] VGA_red, VGA_green, VGA_blue;

assign o_VGA_red = o_active ? VGA_red[3:0] : 4'd0;
assign o_VGA_green = o_active ? VGA_green[3:0]  : 4'd0;
assign o_VGA_blue = o_active ? VGA_blue[3:0]  : 4'd0;

always @(*) begin
    if(i_foreground[15:12] < 4'd3) begin //100% transparent
        VGA_red = i_background[11:8];
        VGA_green = i_background[7:4];
        VGA_blue = i_background[3:0];    
    end
    else if(i_foreground[15:12] < 4'd6) begin //75% transparent
        VGA_red = (i_background[11:8] + i_background[11:8] + i_background[11:8] + i_foreground[11:8])>>2;
        VGA_green = (i_background[7:4] + i_background[7:4] + i_background[7:4] + i_foreground[7:4])>>2;
        VGA_blue = (i_background[3:0] + i_background[3:0] + i_background[3:0] + i_foreground[3:0])>>2;    
    end
    else if (i_foreground[15:12] < 4'd10) begin //50% transparent
        VGA_red = (i_background[11:8] + i_foreground[11:8])>>1;
        VGA_green = (i_background[7:4] +  i_foreground[7:4])>>1;
         VGA_blue = (i_background[3:0] + i_foreground[3:0])>>1;   
    end
   else if (i_foreground[15:12] < 4'd13) begin //25% transparent
        VGA_red = (i_background[11:8] + i_foreground[11:8] + i_foreground[11:8] + i_foreground[11:8])>>2;
        VGA_green = (i_background[7:4] +  i_foreground[7:4] +  i_foreground[7:4] +  i_foreground[7:4])>>2;
         VGA_blue = (i_background[3:0] + i_foreground[3:0] + i_foreground[3:0] + i_foreground[3:0])>>2;   
    end
    else begin //0% transparent (solid colour)
        VGA_red = i_foreground[11:8];
        VGA_green = i_foreground[7:4];
        VGA_blue = i_foreground[3:0];
    end

end

endmodule