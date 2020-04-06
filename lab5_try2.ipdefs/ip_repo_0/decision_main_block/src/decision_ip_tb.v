`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2020 03:20:22 PM
// Design Name: 
// Module Name: decision_ip_tb
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


module decision_ip_tb();

reg aclk, aresetn;
initial begin
    aclk = 1'b0;
    forever aclk = #5 ~aclk;
end

initial begin
    aresetn = 1'b0;
    #20;
    aresetn = 1'b1;
end

reg range_status;
reg temperature_vld;
reg [15:0] temperature;
reg acc_vld;
reg signed [15:0] acc_x, acc_y, acc_z;
wire [7:0] light_sensor_rd_data_0, light_sensor_rd_data_1;
wire [7:0] o_light_sensor_val;
wire [5:0] o_weather_val;
reg [5:0] weather_data_in;
reg [31:0] sensor_intrpt_en, sensor_intrpt_rst;
wire [31:0] sensor_msg_intrpt;
wire [1:0] o_climate_control; //bit 1 is for heating, bit 0 is for cooling, 
wire [7:0] o_climate_control_temperature;
wire o_open_door; //1 while door is open, set back to 0 when door is closed
wire [2:0] o_enable_light; //bit 2 is for outdoor lights, bit 1 is for living room, bit 0 for bedroom lights

integer temp_max = 30;
integer temp_min = 15;
integer acc_max = 1.5*9.81;
integer ac_temp = 24; //air conditioner temperature, should be median of ac_high and ac_low
integer ac_high = 26; //turning cooling
integer ac_low 	= 22; //turn heating
integer light_dark = 8; //to trigger outdoor light if light sensor data is too low

    
decision_ip dut(
    .aclk(aclk),
    .aresetn(aresetn),
    
    //temperature sensor
    .temperature_vld(temperature_vld),
    .temperature(temperature),

    //accelerometer 
    .acc_vld(acc_vld),
    .acc_x(acc_x),
    .acc_y(acc_y),
    .acc_z(acc_z),
            
    
    ////with the light sensor driver
    //.light_sensor_rd_en(light_sensor_rd_en), //a pulse
    //.light_sensor_rd_vld(light_sensor_rd_vld),
    //.light_sensor_rd_data_0(light_sensor_rd_data_0),
    //.light_sensor_rd_data_1(light_sensor_rd_data_1),
    //.weather_data_in(weather_data_in),
    //
    ////with the range sensor
    .range_status(range_status),
    //
    //.o_light_sensor_val(o_light_sensor_val),
    //.o_distance_sensor_val(o_distance_sensor_val),
    //.o_weather_val(o_weather_val),
    
    .sensor_intrpt_en(sensor_intrpt_en), //needs to be set high for the duration of the interrupt
    .sensor_intrpt_rst(sensor_intrpt_rst),
    .sensor_msg_intrpt(sensor_msg_intrpt),
	
	.o_climate_control(o_climate_control), //bit 1 is for heating, bit 0 is for cooling, 
	.o_climate_control_temperature(o_climate_control_temperature), 
	.o_open_door(o_open_door), //1 while door is open, set back to 0 when door is closed
	.o_enable_light(o_enable_light), //bit 2 is for outdoor lights, bit 1 is for living room, bit 0 for bedroom lights
	
	.temp_max   (temp_max),
	.temp_min   (temp_min),
	.acc_max    (acc_max),
	.ac_temp    (ac_temp),
	.ac_high    (ac_high),
	.ac_low     (ac_low),
    .light_dark (light_dark)     
);

initial begin
	range_status 		= 0;
    temperature_vld     = 0;
    temperature         = 0;
    acc_vld             = 0;
    acc_x               = 0;
    acc_y               = 0;
    acc_z               = 0;
    sensor_intrpt_en    = 0;
    sensor_intrpt_rst   = 0;
    #40;
    
    @(negedge aclk);
    sensor_intrpt_en    = 32'hffffffff;

    temperature_vld     = 1;
    temperature         = 10;
    acc_vld             = 1;
    acc_x               = 20;
    acc_y               = 30;
    acc_z               = 40;
    
    @(negedge aclk);
    temperature_vld     = 0;
    acc_vld             = 0;
    
    #300;
	
	@(negedge aclk);
	range_status = 1'b1;
	temperature = 13'd27<<7; //*16 for sensor precision and <<3 for unused 3 LSB
	temperature_vld = 1'b1;
	@(negedge aclk);
	range_status = 1'b0;
	temperature_vld = 1'b0;
	
	@(negedge aclk);
	range_status = 1'b1;
	temperature = 13'd23<<7;
	temperature_vld = 1'b1;
	@(negedge aclk);
	@(negedge aclk);
	@(negedge aclk);
	@(negedge aclk);
	range_status = 1'b0;
	temperature_vld = 1'b0;
	
	@(negedge aclk);
	range_status = 1'b1;
	temperature = 13'd20<<7;
	temperature_vld = 1'b1;
	@(negedge aclk);
	range_status = 1'b0;
	temperature_vld = 1'b0;
	
	@(negedge aclk);
	@(negedge aclk);
	@(negedge aclk);
	@(negedge aclk);
	
    $stop();
end

always @ (posedge aclk) begin
    sensor_intrpt_rst[0] <= sensor_msg_intrpt[0];
    sensor_intrpt_rst[1] <= sensor_msg_intrpt[1];
    sensor_intrpt_rst[2] <= sensor_msg_intrpt[2];
end


endmodule
