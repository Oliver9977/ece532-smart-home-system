`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2020 06:32:01 PM
// Design Name: 
// Module Name: decision_ip
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


module decision_ip 
/*
#(
    parameter integer TEMP_MAX = 30,
    parameter integer TEMP_MIN = 15,
	//parameter integer ACC_MAX = 1.5*9.81,
	
	parameter integer ac_temp = 24, //A/C temp, should be median of AC_HIGH and AC_LOW
    parameter integer AC_HIGH = 26, //above this temp, turn cooling
    parameter integer AC_LOW = 22, //below this temp, turn heating
	parameter integer LIGHT_DARK = 8
)
*/
(
    input aclk,
    input aresetn,
    
    //temperature sensor
    input temperature_vld,
    input [15:0] temperature,
    output [15:0] o_temperature_val,
    
    //accelerometer 
    input acc_vld,
    input signed [11:0] acc_x,
    input signed [11:0] acc_y,
    input signed [11:0] acc_z,
        
    //with the light sensor driver
    input light_sensor_rd_en,
    input light_sensor_rd_vld,
    input [7:0] light_sensor_rd_data_0,
    input [7:0] light_sensor_rd_data_1,
    input [5:0] weather_data_in,
    
    //with the range sensor
    input range_status,
    
    output [7:0] o_light_sensor_val,
    output o_distance_sensor_val,
    output [5:0] o_weather_val,
    output wire light_sensor_rd_en_out,
    
    //message interrupts
    input [31:0] sensor_intrpt_en, //needs to be set high for the duration of the interrupt
    input [31:0] sensor_intrpt_rst,
    output reg [31:0] sensor_msg_intrpt,
    
	//home control to vga
	output [1:0] o_climate_control, //bit 1 is for heating, bit 0 is for cooling, 
	output [7:0] o_climate_control_temperature, 
	output o_open_door, //1 while door is open, set back to 0 when door is closed
	output [2:0] o_enable_light, //bit 2 is for outdoor lights, bit 1 is for living room, bit 0 for bedroom lights
	
    //debug
    output wire [25:0] xyz_sum_test,
    output wire [15:0] acc_mag_test,
    output wire acc_mag_vld_test,
    
	//parameters, for default values check commented code at the top
	input signed [31:0] temp_max,
    input signed [31:0] temp_min,
    input signed [31:0] acc_max,
	input signed [31:0] ac_temp, //air conditioner temperature, should be median of ac_high and ac_low
	input signed [31:0] ac_high, //turning cooling
	input signed [31:0] ac_low, //turn heating
	input signed [31:0] light_dark //to trigger outdoor light if light sensor data is too low
	
    );
	
	reg [1:0] climate_control;
	reg [7:0] climate_control_temperature;
	reg open_door;
	reg [1:0] indoor_light;
	reg outdoor_light;
	
	reg range_status_prev; 
	wire range_status_toggle;
	
    reg [23:0] x_mag, y_mag, z_mag;
    reg acc_vld1, acc_vld2;
    reg [25:0] xyz_sum;
    wire [15:0] acc_mag;
    wire acc_mag_vld;
        
    reg [7:0] decoded_light_data;
    reg signed [12:0] raw_temp_data; //13 bit raw temp data
    reg signed [8:0] decoded_temp_data; //decoded temp data, rounded to nearest integer
    assign o_weather_val = weather_data_in;
    assign light_sensor_rd_en_out = light_sensor_rd_en;
    assign xyz_sum_test = xyz_sum;
    assign acc_mag_test = acc_mag;
    assign acc_mag_vld_test = acc_mag_vld;
    
    
    //light register
    always @(posedge aclk) begin
        if (aresetn == 1'b0) begin
            decoded_light_data <= 0;
        end
        else begin
            if (light_sensor_rd_vld)
                decoded_light_data <= (light_sensor_rd_data_0 << 3) | (light_sensor_rd_data_1 >> 5);
        end
    end 
    
    //temp reg
    always @(posedge aclk) begin
		if (aresetn == 1'b0) begin
			raw_temp_data <= 0;
			decoded_temp_data <= 0;
		end
		else if (temperature_vld) begin
			raw_temp_data <= temperature[15:3]; //13 bit mode
			decoded_temp_data <= temperature[15:7]; //signed temp in integer
			
		end
     end
    
    assign o_light_sensor_val = decoded_light_data;
    assign o_distance_sensor_val = range_status;
    assign o_temperature_val = {{7{decoded_temp_data[8]}}, decoded_temp_data}; //sign extend for the 15 bit output to vga
    
    //accelerometer - calculating the magnitude
    always @(posedge aclk) begin
        if (aresetn == 1'b0) begin
            acc_vld1 <= 0;
            acc_vld2 <= 0;
        end
        else begin
            acc_vld1 <= acc_vld;
            acc_vld2 <= acc_vld1;
        end
    end 
        
    always @(posedge aclk) begin
        x_mag <= acc_x * acc_x;
        y_mag <= acc_y * acc_y;
        z_mag <= acc_z * acc_z;
        
        xyz_sum <= x_mag + y_mag + z_mag;
    end
    
    cordic_0 sqrt_inst (
      .aclk(aclk),                                        // input wire aclk
      .s_axis_cartesian_tvalid(acc_vld2),  // input wire s_axis_cartesian_tvalid
      .s_axis_cartesian_tdata(xyz_sum),    // input wire [31 : 0] s_axis_cartesian_tdata
      .m_axis_dout_tvalid(acc_mag_vld),            // output wire m_axis_dout_tvalid
      .m_axis_dout_tdata(acc_mag)              // output wire [31 : 0] m_axis_dout_tdata
    );
        
    //detection of abnormalties
    wire temp_too_low = decoded_temp_data < temp_min;
    wire temp_too_high = decoded_temp_data > temp_max;
    wire acc_too_high = acc_mag_vld ? acc_mag > acc_max :1'b0;
    
    
    //interrupt line
    always @(posedge aclk) begin
        if (aresetn == 1'b0) begin
            sensor_msg_intrpt <= 0;
        end
        else begin
            //[0] temperature too low
            if (sensor_intrpt_rst[0])
                sensor_msg_intrpt[0] <= 1'b0;
            else if (sensor_intrpt_en[0] & temp_too_low) 
                sensor_msg_intrpt[0] <= 1'b1;
                
            //[1] temperature too high
            if (sensor_intrpt_rst[1])
                sensor_msg_intrpt[1] <= 1'b0;
            else if (sensor_intrpt_en[1] & temp_too_high) 
                sensor_msg_intrpt[1] <= 1'b1;
                
            //[2] acceleration too high
            if (sensor_intrpt_rst[2])
                sensor_msg_intrpt[2] <= 1'b0;
            else if (sensor_intrpt_en[2] & acc_too_high) 
                sensor_msg_intrpt[2] <= 1'b1;
        end
    end
	
	
	//checks for the toggle of range status
	always @(posedge aclk) begin
        if (aresetn == 1'b0) begin
            range_status_prev <= 2'b01;
        end
        else begin
			range_status_prev <= range_status;
        end
    end
	assign range_status_toggle = ~range_status_prev & range_status; //positive edge
	
	
	//home control to vga
	always @(*) begin
		climate_control_temperature = ac_temp[7:0];
		
		if (decoded_temp_data < ac_low) begin
			climate_control = 2'b10; //heating
		end
		else if (decoded_temp_data > ac_high) begin
			climate_control = 2'b01; //cooling
		end
		//if (decoded_temp_data == ac_temp) begin
		else begin
			climate_control = 2'b00;
		end
		
		outdoor_light = decoded_light_data <= light_dark;
	end
	
	always @(posedge aclk) begin
        if (aresetn == 1'b0) begin
			//the person starts off in the bedroom
            indoor_light <= 2'b01;
			open_door <= 1'b0;
        end
        else if (range_status_toggle) begin
			
			indoor_light <= ~indoor_light;
			open_door <= ~open_door;
			
        end
    end
	
	
	assign o_climate_control = climate_control;
	assign o_climate_control_temperature = climate_control_temperature;
	assign o_open_door = open_door;
	assign o_enable_light = {outdoor_light, indoor_light};

endmodule
