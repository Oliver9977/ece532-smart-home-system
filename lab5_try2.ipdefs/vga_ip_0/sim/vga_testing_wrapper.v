`timescale 1ns / 1ps
//This wrapper should only be used for testing ans should be commented out when exporting the IP


module vga_top_wrapper #(
    parameter TESTING =0
)(
     input CLK100MHZ,
     input CPU_RESETN,
     output [15:0]LED,
     input [15:0]SW,
     
     //Comment these out for testing mode
     
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
    
     
     output [3:0]VGA_B,
     output [3:0]VGA_G,
     output VGA_HS,
     output [3:0]VGA_R,
     output VGA_VS
     
     

    );
    
    //Inputs (SW 15 and 14)
    //00 -- Temperature sensor
    //01 -- Light Sensor
    //10 -- Distance Sensor
    //11 -- Weather Display
    
    //Uncomment for testing mode
    /*
    //Sensor Values
    wire [15:0] i_temperature_sensor_val;
    wire [7:0] i_light_sensor_val;
    wire i_distance_sensor_val;
    wire [5:0] i_weather_val;
    wire [7:0] i_weather_temperature;
    
    //Decision IP values
    wire [1:0] i_climate_control;
    wire [7:0] i_climate_control_temperature;
    wire i_open_door;
    wire [2:0] i_enable_light;
    */
    
    //Testing registers
    reg [15:0] temperature_sensor_val;
    always @(posedge CLK100MHZ) begin
        if(!CPU_RESETN) temperature_sensor_val <= 15'd0;
        else begin
           if(TESTING == 1) temperature_sensor_val <= (SW[15:13] == 3'b000) ? {3'b000, SW[13:0]} : temperature_sensor_val;
           else temperature_sensor_val <= i_temperature_sensor_val;
        end
    end
    
    reg [7:0] light_sensor_val;
    always @(posedge CLK100MHZ) begin
        if(!CPU_RESETN) light_sensor_val <= 8'd0;
        else begin
            if(TESTING == 1) light_sensor_val <= (SW[15:13] == 3'b001) ? SW[7:0] : light_sensor_val;
            else light_sensor_val <= i_light_sensor_val;
        end
    end
    
    reg  distance_sensor_val;
    always @(posedge CLK100MHZ) begin
        if(!CPU_RESETN) distance_sensor_val <= 1'b0;
        else begin
            if(TESTING == 1) distance_sensor_val <= (SW[15:13] == 3'b010) ? SW[0] : distance_sensor_val;
            else distance_sensor_val <= i_distance_sensor_val;
        end
    end
    
    reg [5:0] weather_val;
    always @(posedge CLK100MHZ) begin
        if(!CPU_RESETN) weather_val <= 6'd0;
        else begin
            if(TESTING == 1) weather_val <= (SW[15:13] == 3'b011) ? SW[5:0] : weather_val;
            else weather_val <= i_weather_val;
        end
    end
    
    reg [7:0] weather_temperature;
    always @(posedge CLK100MHZ) begin
        if(!CPU_RESETN) weather_temperature <= 8'd0;
        else begin
            if(TESTING == 1) weather_temperature <= (SW[15:13] == 3'b100) ? SW[7:0] : weather_temperature;
            else weather_temperature <= i_weather_temperature;
        end
    end
    
    reg [1:0] climate_control;
    reg [7:0] climate_control_temperature;
    always @(posedge CLK100MHZ) begin
        if(!CPU_RESETN) begin
             climate_control <= 2'd0;
             climate_control_temperature <= 8'd0;
        end
        else begin
            if(TESTING == 1) begin
                climate_control_temperature <= (SW[15:13] == 3'b101) ? SW[7:0] : climate_control_temperature;
                climate_control <= (SW[15:13] == 3'b101) ? SW[9:8] : climate_control;
            end
            else begin
                climate_control_temperature <= i_climate_control_temperature;
                climate_control <= i_climate_control;
            end
        end
    end
    
    reg open_door;
    reg [2:0] enable_light;
     always @(posedge CLK100MHZ) begin
        if(!CPU_RESETN) begin
             open_door <= 1'd0;
             enable_light <= 3'd0;
        end
        else begin
            if(TESTING == 1) begin
                open_door <= (SW[15:13] == 3'b110) ? SW[3] : open_door;
                enable_light <= (SW[15:13] == 3'b110) ? SW[2:0] : enable_light;
            end
            else begin
                open_door <= i_open_door;
                enable_light <= i_enable_light;
            end
        end
    end   
    
    vga_block_wrapper wrapper_inst
       (.CLK100MHZ(CLK100MHZ),
        .CPU_RESETN(CPU_RESETN),
        .VGA_B(VGA_B),
        .VGA_G(VGA_G),
        .VGA_HS(VGA_HS),
        .VGA_R(VGA_R),
        .climate_control(climate_control),
        .climate_control_temperature(climate_control_temperature),
        .distance_sensor_val(distance_sensor_val),
        .enable_light(enable_light),
        .light_sensor_val(light_sensor_val),
        .open_door(open_door),
        .temperature_sensor_val(temperature_sensor_val),
        .weather_temperature(weather_temperature),
        .weather_val(weather_val),
        .VGA_VS(VGA_VS));
    
    
    
endmodule
