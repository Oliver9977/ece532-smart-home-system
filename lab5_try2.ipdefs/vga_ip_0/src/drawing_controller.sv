`timescale 1ns / 1ps


//Draws foreground objects on screen and animates them
module drawing_controller #(
	parameter VGA_WIDTH = 640,
    parameter VGA_HEIGHT = 480
)(
    input clk, reset,
    input vga_clk,
    
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
    output reg [15:0] o_foreground

    );


//==============================================================================================================================
//  Temperature and Humidity Sensor Drawing Logic
//==============================================================================================================================

   reg [15:0] temperature_sensor_val;    
   always @(posedge clk) begin
        if(!reset) temperature_sensor_val <= 16'd0;
        else temperature_sensor_val <= i_animate ? i_temperature_sensor_val : temperature_sensor_val; 
    end

    
    wire [15:0]  char_colour;
    wire enable_char_pixel;
    
    
    localparam UPSCALING_SIZE = 2;
    localparam NUM_CHARS = 95;
    localparam BUFFER_SIZE = 7;
    
    logic [BUFFER_SIZE-1:0][7:0] temperature_char;
    
        convert_hex_to_decimal hex_to_dec_inst(
            .clk(clk), 
            .reset(reset),
            
            .done(), //Not needed
        
            .hex_number(temperature_sensor_val),
            .decimal_number(temperature_char) //Max number is 0xffff = 65535
            
        );
        
        localparam TEMP_SENSOR_START_Y = VGA_HEIGHT/8 -15;
        
        text_buffer #(
        .VGA_WIDTH(VGA_WIDTH),
        .VGA_HEIGHT(VGA_HEIGHT),
        .BUFFER_SIZE(BUFFER_SIZE-2), //Don't need upper two 0s, temperature should never go that high
        .LETTER_Y_START(TEMP_SENSOR_START_Y),
        .LETTER_X_START(VGA_WIDTH/2 + VGA_WIDTH/4),
        .UPSCALING_SIZE(UPSCALING_SIZE),
        .NUM_CHARS(NUM_CHARS)
            )text_buf_inst(
            .clk(clk),
            .vga_clk(vga_clk), //25 MHz
            .reset(reset),
            
            .i_vga_x(i_vga_x),      
            .i_vga_y(i_vga_y),       

            .character(temperature_char[BUFFER_SIZE-1:2]), //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
            .enable_char_pixel(enable_char_pixel),
            .pixel(char_colour)
            
            );
 
//==============================================================================================================================
//  HVAC System Drawing Logic
//==============================================================================================================================   

    reg [1:0] climate_control; //bit 0 is for cooling sytem, bit 1 is for heating system
    reg [7:0] climate_control_temperature; //More than enough bits to display temperature
   always @(posedge clk) begin
         if(!reset) begin
            climate_control <= 2'd0;
            climate_control_temperature <= 8'd0;
         end
         else begin
             climate_control <= i_animate ? i_climate_control : climate_control; 
             climate_control_temperature <= i_animate ? i_climate_control_temperature : climate_control_temperature; 
         end
     end


    logic [15:0] hvac_object_colour;
    wire [15:0] heating_object_mem_val, cooling_object_mem_val;
      localparam HEATING_OBJ_ID = 12;
      localparam COOLING_OBJ_ID = 13;
      localparam HVAC_OBJ_WIDTH = 50;
      localparam HVAC_OBJ_HEIGHT = 50;
      localparam HVAC_START_X = 97;
      

      wire hvac_obj_en;
      wire [9:0] hvac_obj_x, hvac_max_x, hvac_start_x;
      wire [8:0] hvac_obj_y, hvac_max_y, hvac_start_y;
  
        localparam HVAC_START_Y = VGA_HEIGHT/6 - 34;
      assign hvac_start_y = HVAC_START_Y;
      assign hvac_start_x = HVAC_START_X;
      
      assign hvac_max_x = hvac_start_x + HVAC_OBJ_WIDTH;
      assign hvac_max_y = hvac_start_y + HVAC_OBJ_HEIGHT;
  
      //Enable foreground pixels if we are in range, otherwise set it to a black 100% transparent pixel
      assign  hvac_obj_en = (i_vga_x > hvac_start_x && i_vga_x < hvac_max_x) && (i_vga_y > hvac_start_y && i_vga_y < hvac_max_y);
      
      assign hvac_obj_x = i_vga_x - hvac_start_x;
      assign hvac_obj_y = i_vga_y - hvac_start_y;
      //Light sensor object memory
      //Load an object from block memory. We may want to either upscale this from a lower resolution to save on space in the future
        object_buffer #(
        .OBJ_HEIGHT(HVAC_OBJ_HEIGHT),
        .OBJ_WIDTH(HVAC_OBJ_WIDTH),
        .OBJECT(HEATING_OBJ_ID) //Index for light sensor
        ) heating_system (
        .clk(clk), 
        .reset(reset),
        .i_read_en(hvac_obj_en),            
        .i_read_x(hvac_obj_x),  
        .i_read_y(hvac_obj_y),
        .o_read_val(heating_object_mem_val) // {alpha[3:0], red[3:0], green[3:0], blue[3:0]}
         );
         object_buffer #(
          .OBJ_HEIGHT(HVAC_OBJ_HEIGHT),
          .OBJ_WIDTH(HVAC_OBJ_WIDTH),
          .OBJECT(COOLING_OBJ_ID) //Index for light sensor
          ) cooling_system (
          .clk(clk), 
          .reset(reset),
          .i_read_en(hvac_obj_en),            
          .i_read_x(hvac_obj_x),  
          .i_read_y(hvac_obj_y),
          .o_read_val(cooling_object_mem_val) // {alpha[3:0], red[3:0], green[3:0], blue[3:0]}
           );
           
           
           
           
           logic [9:0][7:0] hvac_string;
           wire enable_hvac_char_pixel;
           wire [15:0] hvac_char_pixel;
 //Select HVAC status depending on input
           always @(*) begin
               case(climate_control)
                              2'b01 : begin
                                   hvac_object_colour = cooling_object_mem_val;
                                   hvac_string = {8'd46, 8'd47, 8'd0, 8'd39, 8'd46, 8'd41, 8'd44, 8'd47, 8'd47, 8'd35 }; //COOLING ON
                              end
                              2'b10 : begin
                                  hvac_object_colour = heating_object_mem_val;
                                  hvac_string = {8'd46, 8'd47, 8'd0, 8'd39, 8'd46, 8'd41, 8'd52, 8'd33, 8'd37, 8'd40}; //HEATING ON
                              end
                              default: begin
                                  hvac_object_colour = 16'd0;
                                hvac_string = {8'd0, 8'd0, 8'd38, 8'd38, 8'd47, 8'd0, 8'd35, 8'd33, 8'd54, 8'd40}; //HVAC OFF
                              end
                          endcase
                     end
                     

              //Text buffer for HVAC status                
              text_buffer #(
                .VGA_WIDTH(VGA_WIDTH),
                .VGA_HEIGHT(VGA_HEIGHT),
                .BUFFER_SIZE(10),
                .LETTER_Y_START(HVAC_START_Y + HVAC_OBJ_HEIGHT + 2),
                .LETTER_X_START(HVAC_START_X + 10),
                .UPSCALING_SIZE(1),
                .NUM_CHARS(NUM_CHARS)
                    )text_buf_inst3(
                    .clk(clk),
                    .vga_clk(vga_clk), //25 MHz
                    .reset(reset),
                    
                    .i_vga_x(i_vga_x),      
                    .i_vga_y(i_vga_y),       

                    .character(hvac_string), //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
                    .enable_char_pixel(enable_hvac_char_pixel),
                    .pixel(hvac_char_pixel)
                    
                    );
                    
                    
             //Text buffer for HVAC temperature
            logic [6:0][7:0] hvac_temperature_char;
       
           convert_hex_to_decimal hex_to_dec_inst3(
               .clk(clk), 
               .reset(reset),
               
               .done(), //Not needed
           
               .hex_number({8'd0, climate_control_temperature}),
               .decimal_number(hvac_temperature_char) //Max number is 0xffff = 65535
               
           );
           wire enable_hvac_temp_char_pixel;
           wire [15:0] hvac_temp_char_colour_tmp, hvac_temp_char_colour;
           text_buffer #(
           .VGA_WIDTH(VGA_WIDTH),
           .VGA_HEIGHT(VGA_HEIGHT),
           .LETTER_Y_START(HVAC_START_Y + HVAC_OBJ_HEIGHT/2 - 15),
           .LETTER_X_START(HVAC_START_X + HVAC_OBJ_WIDTH + 2),
           .BUFFER_SIZE(4),
           .UPSCALING_SIZE(2),
           .NUM_CHARS(NUM_CHARS)
               )text_buf_inst4(
               .clk(clk),
               .vga_clk(vga_clk), //25 MHz
               .reset(reset),
               
               .i_vga_x(i_vga_x),      
               .i_vga_y(i_vga_y),       

               .character(hvac_temperature_char[6:3]), //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
               .enable_char_pixel(enable_hvac_temp_char_pixel),
               .pixel(hvac_temp_char_colour_tmp)
               
               );  
               assign hvac_temp_char_colour =  (climate_control == 2'b01 || climate_control == 2'b10)? hvac_temp_char_colour_tmp : 16'd0;
             
    
 //==============================================================================================================================
//  Animation Counters
//==============================================================================================================================   

    //Counter 1 is to anmate every 1 sec, counter 2 is 0.5s
    wire counter_done, counter2_done;
    reg [5:0] counter;
    reg [5:0] counter2;
    assign counter_done = (counter == 6'd60);
    assign counter2_done = (counter2 == 6'd30);
    always @(posedge clk) begin
        if (!reset) begin
            counter <= 0;
            counter2 <= 0;
        end
        else begin
            counter <= i_animate ? (counter_done ? 0 : counter + 1'b1) : counter;
            counter2 <= i_animate ? (counter2_done ? 0 : counter2 + 1'b1) : counter2;
            
        end
    end
    

//==============================================================================================================================
//  Light Sensor Drawing Logic
//==============================================================================================================================
    localparam LIGHT_OBJ_ID = 1;
    localparam LIGHT_OBJ_WIDTH = 100;
    localparam LIGHT_OBJ_HEIGHT = 100;
    
    wire [15:0] light_sensor_obj_colour, light_object_colour;
    wire light_sensor_obj_en;
    wire [9:0] light_obj_x, light_max_x, light_start_x;
    wire [8:0] light_obj_y, light_max_y, light_start_y;


    localparam LIGHT_SENSOR_START_Y = VGA_HEIGHT/4 + VGA_HEIGHT/8 - LIGHT_OBJ_HEIGHT/2;
     localparam LIGHT_SENSOR_START_X = 3*(VGA_WIDTH/4);

    assign light_start_y = LIGHT_SENSOR_START_Y;
    assign light_start_x = LIGHT_SENSOR_START_X;
    
    assign light_max_x = light_start_x + LIGHT_OBJ_WIDTH;
    assign light_max_y = light_start_y + LIGHT_OBJ_HEIGHT;

    //Enable foreground pixels if we are in range, otherwise set it to a black 100% transparent pixel
    assign  light_sensor_obj_en = (i_vga_x > light_start_x && i_vga_x < light_max_x) && (i_vga_y > light_start_y && i_vga_y < light_max_y);
    
    assign light_obj_x = i_vga_x - light_start_x;
    assign light_obj_y = i_vga_y - light_start_y;
    //Light sensor object memory
    //Load an object from block memory. We may want to either upscale this from a lower resolution to save on space in the future
      object_buffer #(
      .OBJ_HEIGHT(LIGHT_OBJ_HEIGHT),
      .OBJ_WIDTH(LIGHT_OBJ_WIDTH),
      .OBJECT(LIGHT_OBJ_ID) //Index for light sensor
      ) light_sensor (
      .clk(clk), 
      .reset(reset),
      .i_read_en(light_sensor_obj_en),            
      .i_read_x(light_obj_x),  
      .i_read_y(light_obj_y),
      .o_read_val(light_sensor_obj_colour) // {alpha[3:0], red[3:0], green[3:0], blue[3:0]}
       );
       
       // Only update the register at the end of the vga animation period
      
       reg [3:0] mod_light_sensor_value;
       reg [7:0] light_sensor_val;
       always @(posedge clk) begin
            if(!reset) begin
                mod_light_sensor_value = 4'd0;
                light_sensor_val <= 8'd0;
            end
            else begin
                mod_light_sensor_value <= i_animate ? (i_light_sensor_val >> 4) : mod_light_sensor_value; //Modify light sensor value so its the same width as the pixels
                light_sensor_val <= counter_done ? i_light_sensor_val : light_sensor_val; //Only update every 1s
            end
       end
       
       //Kepp only alpha value from light image, set the rest using grayscale light sensor value
       assign light_object_colour = {light_sensor_obj_colour[15:12], mod_light_sensor_value, mod_light_sensor_value, mod_light_sensor_value};
       
       
           //Text buffer for light sensor value
               logic [6:0][7:0] light_sensor_char;
          
              convert_hex_to_decimal hex_to_dec_inst5(
                  .clk(clk), 
                  .reset(reset),
                  
                  .done(), //Not needed
              
                  .hex_number({8'd0, light_sensor_val}),
                  .decimal_number(light_sensor_char) //Max number is 0xffff = 65535
                  
              );
              wire enable_light_sensor_char_pixel;
              wire [15:0] light_sensor_char_colour;
              text_buffer #(
              .VGA_WIDTH(VGA_WIDTH),
              .VGA_HEIGHT(VGA_HEIGHT),
              .LETTER_Y_START(VGA_HEIGHT/4 + VGA_HEIGHT/8 + 2),
              .LETTER_X_START(VGA_WIDTH/2 + 20 + 69 + 3), //Based on LIGHT VALUE: label in the label module
              .BUFFER_SIZE(3),
              .UPSCALING_SIZE(1),
              .NUM_CHARS(NUM_CHARS)
                  )text_buf_inst6(
                  .clk(clk),
                  .vga_clk(vga_clk), //25 MHz
                  .reset(reset),
                  
                  .i_vga_x(i_vga_x),      
                  .i_vga_y(i_vga_y),       
   
                  .character(light_sensor_char[4:2]),
                  .enable_char_pixel(enable_light_sensor_char_pixel),
                  .pixel(light_sensor_char_colour)
                  
                  );  
                  
       
       
       
//==============================================================================================================================
//  Light decision drawing logic
//==============================================================================================================================       
 
 wire [15:0] light_status_pixel;
 wire draw_light_status;
 
 light_status_drawing #(
.VGA_WIDTH(VGA_WIDTH),
.VGA_HEIGHT(VGA_HEIGHT),
.START_X(25),
.START_Y(VGA_HEIGHT/6 + (VGA_HEIGHT)/3 - 38)

) light_draw_inst (

  .clk(clk),
  .vga_clk(vga_clk), //25 MHz
  .reset(reset),
    
  .i_enable_light(i_enable_light),
    
  .i_vga_x(i_vga_x),      // current pixel x position
  .i_vga_y(i_vga_y),       // current pixel y position
  .i_animate(i_animate),

    .o_enable_drawing(draw_light_status),
    .o_cur_pixel(light_status_pixel)

);      
       
       
//==============================================================================================================================
//  Distance Sensor Drawing Logic
//==============================================================================================================================
    wire [15:0] dist_object_colour, dist_object_mem_val;
      localparam DIST_OBJ_ID = 2;
      localparam DIST_OBJ_WIDTH = 94;
      localparam DIST_OBJ_HEIGHT = 100;
      

      wire dist_sensor_obj_en;
      wire [9:0] dist_obj_x, dist_max_x, dist_start_x;
      wire [8:0] dist_obj_y, dist_max_y, dist_start_y;
  
      assign dist_start_y = 9'd250;
      assign dist_start_x = 3*(VGA_WIDTH/4);
      
      assign dist_max_x = dist_start_x + DIST_OBJ_WIDTH;
      assign dist_max_y = dist_start_y + DIST_OBJ_HEIGHT;
  
      //Enable foreground pixels if we are in range, otherwise set it to a black 100% transparent pixel
      assign  dist_sensor_obj_en = (i_vga_x > dist_start_x && i_vga_x < dist_max_x) && (i_vga_y > dist_start_y && i_vga_y < dist_max_y);
      
      assign dist_obj_x = i_vga_x - dist_start_x;
      assign dist_obj_y = i_vga_y - dist_start_y;
      //Light sensor object memory
      //Load an object from block memory. We may want to either upscale this from a lower resolution to save on space in the future
        object_buffer #(
        .OBJ_HEIGHT(DIST_OBJ_HEIGHT),
        .OBJ_WIDTH(DIST_OBJ_WIDTH),
        .OBJECT(DIST_OBJ_ID) //Index for light sensor
        ) dist_sensor (
        .clk(clk), 
        .reset(reset),
        .i_read_en(dist_sensor_obj_en),            
        .i_read_x(dist_obj_x),  
        .i_read_y(dist_obj_y),
        .o_read_val(dist_object_mem_val) // {alpha[3:0], red[3:0], green[3:0], blue[3:0]}
         );
    
    // Only update the register at the end of the vga animation period
    reg  distance_sensor_val;
    always @(posedge clk) begin
         if(!reset) distance_sensor_val = 1'd0;
         else distance_sensor_val <= i_animate ? i_distance_sensor_val : distance_sensor_val; 
    end
    assign dist_object_colour = (distance_sensor_val == 1'b1)? dist_object_mem_val : 16'd0;
 
 //==============================================================================================================================
//  Door Drawing Logic
//==============================================================================================================================   
 
    reg open_door;
    always @(posedge clk) begin
      if(!reset) begin
         open_door <= 1'd0;
      end
      else begin
          open_door <= i_animate ? i_open_door : open_door; 
      end
  end
  
   logic [10:0][7:0] door_string;
         wire enable_door_char_pixel;
         wire [15:0] door_char_pixel;
         
 always @(*) begin
     case(open_door)
        1'b0 : begin
             door_string = {8'd36, 8'd37, 8'd51, 8'd47, 8'd44, 8'd35, 8'd0, 8'd50, 8'd47, 8'd47, 8'd36}; //DOOR CLOSED
        end
        1'b1 : begin
            door_string = { 8'd0, 8'd0, 8'd46, 8'd37, 8'd48, 8'd47, 8'd0, 8'd50, 8'd47, 8'd47, 8'd36}; //DOOR OPEN
        end
    endcase
end
                          
    text_buffer #(
      .VGA_WIDTH(VGA_WIDTH),
      .VGA_HEIGHT(VGA_HEIGHT),
      .BUFFER_SIZE(11),
      .LETTER_Y_START( VGA_HEIGHT/6 + (2*VGA_HEIGHT)/3 - 8 ),
      .LETTER_X_START(10'd57),
      .UPSCALING_SIZE(2),
      .NUM_CHARS(NUM_CHARS)
          )text_buf_inst5(
          .clk(clk),
          .vga_clk(vga_clk), //25 MHz
          .reset(reset),
          
          .i_vga_x(i_vga_x),      
          .i_vga_y(i_vga_y),       

          .character(door_string), //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
          .enable_char_pixel(enable_door_char_pixel),
          .pixel(door_char_pixel)
          
          );
                  
 
  
//==============================================================================================================================
//  Weather Drawing Logic
//==============================================================================================================================
        wire [15:0] weather_object_colour;
          localparam WEATHER_OBJ_ID = 3;
          localparam WEATHER_OBJ_WIDTH = 100;
          localparam WEATHER_OBJ_HEIGHT = 100;
          localparam WEATHER_SCALING_FACTOR = 1; //Actual scaling factor is 2^SCALING_FACTOR (weather icons are 50x50 so make sure height/width above match scaling factor)
          
    
          wire weather_obj_en;
          wire [9:0] weather_obj_x, weather_max_x, weather_start_x;
          wire [8:0] weather_obj_y, weather_max_y, weather_start_y;
      
          localparam WEATHER_START_Y = 9'd375;
           localparam WEATHER_START_X = 3*(VGA_WIDTH/4);
      
          assign weather_start_y = WEATHER_START_Y;
          assign weather_start_x = WEATHER_START_X;
          
          assign weather_max_x = weather_start_x + WEATHER_OBJ_WIDTH;
          assign weather_max_y = weather_start_y + WEATHER_OBJ_HEIGHT;
      
          //Enable foreground pixels if we are in range, otherwise set it to a black 100% transparent pixel
          assign  weather_obj_en = (i_vga_x > weather_start_x && i_vga_x < weather_max_x) && (i_vga_y > weather_start_y && i_vga_y < weather_max_y);
          
          assign weather_obj_x = i_vga_x - weather_start_x;
          assign weather_obj_y = i_vga_y - weather_start_y;
          
          
            // Only update the register at the end of the vga animation period
            reg [5:0] weather_val;    
            reg [7:0] weather_temperature;
            reg negative_temp;
                always @(posedge clk) begin
                     if(!reset) begin
                         weather_val = 6'd0;
                         weather_temperature = 8'd0;
                         negative_temp  = 1'd0;
                      end
                     else begin
                        weather_val <= i_animate ? i_weather_val : weather_val; 
                        weather_temperature <= i_animate ? (i_weather_temperature[7] ? (-i_weather_temperature) : i_weather_temperature ) : weather_temperature;
                        negative_temp <= i_animate ? i_weather_temperature[7] : negative_temp;
                     end
                end
                
           wire [7:0] minus_char;
           assign minus_char = negative_temp ? 8'd13 : 8'd0;
                
          //Light sensor object memory
          //Load an object from block memory. We may want to either upscale this from a lower resolution to save on space in the future
           weather_buffer #(
              .WEATHER_WIDTH(WEATHER_OBJ_WIDTH),
              .SCALING_FACTOR(WEATHER_SCALING_FACTOR),
              .WEATHER_OFFSET(WEATHER_OBJ_ID), //First weather object ID
              .WEATHER_HEIGHT(WEATHER_OBJ_HEIGHT)
              ) weather_buf_inst(
                 .clk(clk), 
                .reset(reset),
                .i_read_en(weather_obj_en),
                .weather_type(weather_val),
                .i_read_x(weather_obj_x),  
                .i_read_y(weather_obj_y),
                .o_read_val(weather_object_colour) // {alpha[3:0], red[3:0], green[3:0], blue[3:0]}
              );
        
        
              localparam WEATHER_TEXT_UPSCALING_SIZE = 1;
              localparam WEATHER_TEXT_BUFFER_SIZE = 5;
              
              logic [6:0][7:0] weather_temperature_char;
              
              
              
                  convert_hex_to_decimal hex_to_dec_inst2(
                      .clk(clk), 
                      .reset(reset),
                      
                      .done(), //Not needed
                  
                      .hex_number(weather_temperature),
                      .decimal_number(weather_temperature_char) //Max number is 0xffff = 65535
                      
                  );
                  wire enable_weather_char_pixel;
                  wire [15:0] weather_char_colour;
                  text_buffer #(
                  .VGA_WIDTH(VGA_WIDTH),
                  .VGA_HEIGHT(VGA_HEIGHT),
                  .LETTER_Y_START(WEATHER_START_Y + WEATHER_OBJ_HEIGHT/2),
                  .LETTER_X_START(WEATHER_START_X + WEATHER_OBJ_WIDTH),
                  .BUFFER_SIZE(WEATHER_TEXT_BUFFER_SIZE),
                  .UPSCALING_SIZE(WEATHER_TEXT_UPSCALING_SIZE),
                  .NUM_CHARS(NUM_CHARS)
                      )text_buf_inst2(
                      .clk(clk),
                      .vga_clk(vga_clk), //25 MHz
                      .reset(reset),
                      
                      .i_vga_x(i_vga_x),      
                      .i_vga_y(i_vga_y),       

                      .character({weather_temperature_char[6:3], minus_char}), //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
                      .enable_char_pixel(enable_weather_char_pixel),
                      .pixel(weather_char_colour)
                      
                      ); 



//==============================================================================================================================
//  Sensor Labels
//==============================================================================================================================

wire enable_sensor_label;
wire [15:0] sensor_label_pixel;

sensor_labels #(
.VGA_WIDTH(VGA_WIDTH),
.VGA_HEIGHT(VGA_HEIGHT)

) sensor_label_inst(
 .clk(clk),
.vga_clk(vga_clk), //25 MHz
.reset(reset),
 .i_vga_x(i_vga_x),      // current pixel x position
  .i_vga_y(i_vga_y),       // current pixel y position

  .enable_sensor_label(enable_sensor_label),
  .sensor_label_pixel(sensor_label_pixel)

);

//==============================================================================================================================
//  Line drawing 
//==============================================================================================================================

wire [15:0] lda_pixel;
wire enable_lda;

line_drawing_algorithm #(
    .VGA_WIDTH(VGA_WIDTH),
    .VGA_HEIGHT(VGA_HEIGHT)

) lda_inst (
 .clk(clk),
 .vga_clk(vga_clk), //25 MHz
 .reset(reset),
.i_vga_x(i_vga_x),      // current pixel x position
.i_vga_y(i_vga_y),       // current pixel y position

.enable_lda(enable_lda),
.lda_pixel(lda_pixel)
);
    
//==============================================================================================================================
//  Output Pixel Selection
//==============================================================================================================================    
    
    
    //Select proper output pixel

    always @(*) begin
    
    casex({enable_sensor_label, enable_light_sensor_char_pixel, enable_lda, draw_light_status, enable_door_char_pixel, enable_hvac_temp_char_pixel, enable_hvac_char_pixel, hvac_obj_en, enable_weather_char_pixel, weather_obj_en, dist_sensor_obj_en, light_sensor_obj_en, enable_char_pixel})
          13'b0000000000001    : o_foreground = char_colour;     
          13'b0000000000010    : o_foreground = light_object_colour;      
          13'b0000000000100    : o_foreground = dist_object_colour;    
          13'b0000000001000   : o_foreground = weather_object_colour;
          13'b0000000010000   : o_foreground = weather_char_colour;
          13'b0000000100000   : o_foreground = hvac_object_colour;
          13'b0000001000000   : o_foreground = hvac_char_pixel;
          13'b0000010000000   : o_foreground = hvac_temp_char_colour;
          13'b0000100000000   : o_foreground = door_char_pixel;
          13'b0001000000000   : o_foreground = light_status_pixel;
          13'bxx1xxxxxxxxxx   : o_foreground = lda_pixel; //lda takes priority
          13'b0100000000000   : o_foreground = light_sensor_char_colour;
          13'b1000000000000   : o_foreground = sensor_label_pixel;
          default  : o_foreground = 16'd0;     
        endcase
    end

    
endmodule


module line_drawing_algorithm #(
    parameter VGA_WIDTH = 640,
    parameter VGA_HEIGHT = 480

) (
 input clk,
   input vga_clk, //25 MHz
   input reset,
  input [9:0] i_vga_x,      // current pixel x position
    input [8:0] i_vga_y,       // current pixel y position

    output logic enable_lda,
    output logic [15:0] lda_pixel
);

wire v_line1, v_line2, v_line3;
wire h_line1, h_line2, h_line3, h_line4, h_line5, h_line6, h_line7;
wire enable;

//Veritcal lines with thickness 3
assign v_line1 = (i_vga_x >= (VGA_WIDTH/2 - 1) && i_vga_x <= (VGA_WIDTH/2 + 1) );
assign v_line2 = (i_vga_x >= 0 && i_vga_x <= 2 );
assign v_line3 = (i_vga_x >= (VGA_WIDTH-3) && i_vga_x <= (VGA_WIDTH-1) );

//horizontal lines on left side with thickness 1
assign h_line1 = (i_vga_y == VGA_HEIGHT/3 && i_vga_x < VGA_WIDTH/2);
assign h_line2 = (i_vga_y == ((2*VGA_HEIGHT)/3) && i_vga_x < VGA_WIDTH/2);

//horizontal lines on right side with thickness 1
assign h_line3 = ( i_vga_x >= VGA_WIDTH/2 && i_vga_y == VGA_HEIGHT/4);
assign h_line4 = ( i_vga_x >= VGA_WIDTH/2 && i_vga_y == VGA_HEIGHT/2);
assign h_line5 = ( i_vga_x >= VGA_WIDTH/2 && i_vga_y == (3*VGA_HEIGHT)/4);

//top/bottom
assign h_line6 = (i_vga_y >= 0 && i_vga_y <= 2);
assign h_line7 = (i_vga_y >= (VGA_HEIGHT-3) && i_vga_y <= (VGA_HEIGHT-1));

assign enable = v_line1 || v_line2 || v_line3 || h_line1 || h_line2  || h_line3 || h_line4 || h_line5 || h_line6 || h_line7;

always @(posedge clk) begin
    if (!reset) begin
        enable_lda <= 1'b0;
        lda_pixel <= 16'd0;
    end
    else begin
        enable_lda <= enable;
        lda_pixel <= (enable) ? 16'hFFFF : 16'd0;
    end

end


endmodule

//Sensor labels are in a seperate module just to make the main module less messy
module sensor_labels #(
parameter VGA_WIDTH = 640,
parameter VGA_HEIGHT = 480

) (
 input clk,
  input vga_clk, //25 MHz
  input reset,
 input [9:0] i_vga_x,      // current pixel x position
   input [8:0] i_vga_y,       // current pixel y position

   output  logic enable_sensor_label,
   output logic [15:0] sensor_label_pixel

);

localparam FONT_X_START = VGA_WIDTH/2 + 20; //Result lags by 1 cycle so start is -1
localparam FONT_HEIGHT = 15;

//Wire definitions
wire enable_temp_label, enable_temp_label_2, enable_light_label, enable_light_label_2, enable_dist_label, enable_dist_label_2, enable_weather_label, enable_weather_label_2;
wire [15:0] temp_label_pixel, temp_label_pixel_2, light_label_pixel, light_label_pixel_2, dist_label_pixel, dist_label_pixel_2, weather_label_pixel, weather_label_pixel_2;

//Strings
wire [10:0][7:0] temp_string;
wire [5:0][7:0] sensor_string;
assign temp_string = {8'd37, 8'd50, 8'd53, 8'd52, 8'd33, 8'd50, 8'd37, 8'd48, 8'd45, 8'd37, 8'd52}; //TEMPERATURE
assign sensor_string = {8'd50, 8'd47, 8'd51, 8'd46, 8'd37, 8'd51}; //SENSOR

wire [11:0][7:0] light_string;
wire [5:0][7:0] value_string;

assign light_string = {8'd50, 8'd47, 8'd51, 8'd46, 8'd37, 8'd51, 8'd0, 8'd52, 8'd40, 8'd39, 8'd41, 8'd44}; //LIGHT SENSOR
assign value_string = {8'd26, 8'd37, 8'd53, 8'd44, 8'd33, 8'd54}; //VALUE:

wire [7:0][7:0] distance_string;
assign distance_string = {8'd37, 8'd35, 8'd46, 8'd33, 8'd52, 8'd51, 8'd41, 8'd36}; //DISTANCE

wire [7:0][7:0] weather_string;
wire [7:0][7:0] current_string;

assign current_string = {8'd52, 8'd46, 8'd37, 8'd50, 8'd50, 8'd53, 8'd35}; //CURRENT
assign weather_string = {8'd50, 8'd37, 8'd40, 8'd52, 8'd33, 8'd37, 8'd55}; //WEATHER

//Character modules
//Temperature sensor
text_buffer #(
  .VGA_WIDTH(VGA_WIDTH),
  .VGA_HEIGHT(VGA_HEIGHT),
  .BUFFER_SIZE(11),
  .LETTER_Y_START(VGA_HEIGHT/8 - FONT_HEIGHT - 2),
  .LETTER_X_START(FONT_X_START),
  .UPSCALING_SIZE(1)
      )temp_label_buff(
      .clk(clk),
      .vga_clk(vga_clk), //25 MHz
      .reset(reset),
      
      .i_vga_x(i_vga_x),      
      .i_vga_y(i_vga_y),       

      .character(temp_string), //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
      .enable_char_pixel(enable_temp_label),
      .pixel(temp_label_pixel)
      );

text_buffer #(
  .VGA_WIDTH(VGA_WIDTH),
  .VGA_HEIGHT(VGA_HEIGHT),
  .BUFFER_SIZE(6),
  .LETTER_Y_START(VGA_HEIGHT/8 + 2),
  .LETTER_X_START(FONT_X_START),
  .UPSCALING_SIZE(1)
      )temp_label_buff_2(
      .clk(clk),
      .vga_clk(vga_clk), //25 MHz
      .reset(reset),
      
      .i_vga_x(i_vga_x),      
      .i_vga_y(i_vga_y),       

      .character(sensor_string), //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
      .enable_char_pixel(enable_temp_label_2),
      .pixel(temp_label_pixel_2)    
      ); 

//light sensor
text_buffer #(
  .VGA_WIDTH(VGA_WIDTH),
  .VGA_HEIGHT(VGA_HEIGHT),
  .BUFFER_SIZE(12),
  .LETTER_Y_START(VGA_HEIGHT/4 + VGA_HEIGHT/8 - FONT_HEIGHT - 2),
  .LETTER_X_START(FONT_X_START),
  .UPSCALING_SIZE(1)
      )light_label_buff(
      .clk(clk),
      .vga_clk(vga_clk), //25 MHz
      .reset(reset),
      
      .i_vga_x(i_vga_x),      
      .i_vga_y(i_vga_y),       

      .character(light_string), //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
      .enable_char_pixel(enable_light_label),
      .pixel(light_label_pixel)
      );

text_buffer #(
  .VGA_WIDTH(VGA_WIDTH),
  .VGA_HEIGHT(VGA_HEIGHT),
  .BUFFER_SIZE(6),
  .LETTER_Y_START(VGA_HEIGHT/4 + VGA_HEIGHT/8 + 2),
  .LETTER_X_START(FONT_X_START),
  .UPSCALING_SIZE(1)
      )light_label_buff_2(
      .clk(clk),
      .vga_clk(vga_clk), //25 MHz
      .reset(reset),
      
      .i_vga_x(i_vga_x),      
      .i_vga_y(i_vga_y),       

      .character(value_string), //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
      .enable_char_pixel(enable_light_label_2),
      .pixel(light_label_pixel_2)    
      ); 
      
   //distance sensor   
      
 text_buffer #(
     .VGA_WIDTH(VGA_WIDTH),
     .VGA_HEIGHT(VGA_HEIGHT),
     .BUFFER_SIZE(8),
     .LETTER_Y_START(VGA_HEIGHT/2 + VGA_HEIGHT/8 - FONT_HEIGHT - 2),
     .LETTER_X_START(FONT_X_START),
     .UPSCALING_SIZE(1)
         )dist_label_buff(
         .clk(clk),
         .vga_clk(vga_clk), //25 MHz
         .reset(reset),
         
         .i_vga_x(i_vga_x),      
         .i_vga_y(i_vga_y),       
   
         .character(distance_string), //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
         .enable_char_pixel(enable_dist_label),
         .pixel(dist_label_pixel)
         );
   
   text_buffer #(
     .VGA_WIDTH(VGA_WIDTH),
     .VGA_HEIGHT(VGA_HEIGHT),
     .BUFFER_SIZE(6),
     .LETTER_Y_START(VGA_HEIGHT/2 + VGA_HEIGHT/8 + 2),
     .LETTER_X_START(FONT_X_START),
     .UPSCALING_SIZE(1)
         )dist_label_buff_2(
         .clk(clk),
         .vga_clk(vga_clk), //25 MHz
         .reset(reset),
         
         .i_vga_x(i_vga_x),      
         .i_vga_y(i_vga_y),       
   
         .character(sensor_string), //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
         .enable_char_pixel(enable_dist_label_2),
         .pixel(dist_label_pixel_2)    
         );      
      
    //weather  
            
       text_buffer #(
           .VGA_WIDTH(VGA_WIDTH),
           .VGA_HEIGHT(VGA_HEIGHT),
           .BUFFER_SIZE(8),
           .LETTER_Y_START(3*(VGA_HEIGHT/4) + VGA_HEIGHT/8 - FONT_HEIGHT - 2),
           .LETTER_X_START(FONT_X_START),
           .UPSCALING_SIZE(1)
               )weather_label_buff(
               .clk(clk),
               .vga_clk(vga_clk), //25 MHz
               .reset(reset),
               
               .i_vga_x(i_vga_x),      
               .i_vga_y(i_vga_y),       
         
               .character(current_string), //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
               .enable_char_pixel(enable_weather_label),
               .pixel(weather_label_pixel)
               );
         
         text_buffer #(
           .VGA_WIDTH(VGA_WIDTH),
           .VGA_HEIGHT(VGA_HEIGHT),
           .BUFFER_SIZE(8),
           .LETTER_Y_START(3*(VGA_HEIGHT/4) + VGA_HEIGHT/8 + 2),
           .LETTER_X_START(FONT_X_START),
           .UPSCALING_SIZE(1)
               )weather_label_buff_2(
               .clk(clk),
               .vga_clk(vga_clk), //25 MHz
               .reset(reset),
               
               .i_vga_x(i_vga_x),      
               .i_vga_y(i_vga_y),       
         
               .character(weather_string), //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
               .enable_char_pixel(enable_weather_label_2),
               .pixel(weather_label_pixel_2)    
               );       
      
//Pixel and enable selection

        wire [7:0] enable;
        assign enable = {enable_weather_label_2, enable_weather_label, enable_dist_label_2, enable_dist_label, enable_light_label_2, enable_light_label, enable_temp_label_2, enable_temp_label};

      logic [15:0] cur_pixel;
      always @(*) begin
        case (enable)
            8'b00000001 : cur_pixel = temp_label_pixel;
            8'b00000010 : cur_pixel = temp_label_pixel_2;
            8'b00000100 : cur_pixel = light_label_pixel;
            8'b00001000 : cur_pixel = light_label_pixel_2;
            8'b00010000 : cur_pixel = dist_label_pixel;
            8'b00100000 : cur_pixel = dist_label_pixel_2;
            8'b01000000 : cur_pixel = weather_label_pixel;
            8'b10000000 : cur_pixel = weather_label_pixel_2;
            default : cur_pixel = 16'd0;
        endcase
      end
      
      
      
 //Timing fix
 /*
 always @(posedge clk) begin
    if (!reset) begin
        sensor_label_pixel <= 16'd0;
        enable_sensor_label <= 1'd0;
    end
    else begin
        sensor_label_pixel <= cur_pixel;
        enable_sensor_label <= | enable;
    end
 
 end
 */
 
assign sensor_label_pixel = cur_pixel;
assign enable_sensor_label = | enable;
      

endmodule



module light_status_drawing #(
parameter VGA_WIDTH = 640,
parameter VGA_HEIGHT = 480,
parameter START_X  = 20,
parameter START_Y = VGA_HEIGHT/2

) (

  input clk,
    input vga_clk, //25 MHz
    input reset,
    
    input [2:0] i_enable_light,
    
    input [9:0] i_vga_x,      // current pixel x position
    input [8:0] i_vga_y,       // current pixel y position
    input i_animate,

    output o_enable_drawing,
    output  logic [15:0] o_cur_pixel

);

localparam IMAGE_HEIGHT = 58;
localparam IMAGE_WIDTH = 50;
localparam SPACE_BETWEEN_IMAGES = 10;
localparam FONT_WIDTH = 8;
localparam BUFFER_SIZE = 7;
localparam SPACE_BETWEEN_LETTERS = 3;
localparam TOTAL_BUFFER_SIZE = FONT_WIDTH * BUFFER_SIZE + SPACE_BETWEEN_LETTERS*(BUFFER_SIZE-1); 

reg [2:0] enable_light;
always @(posedge clk) begin
    if(!reset) enable_light <= 3'd0;
    else begin
        enable_light <= i_animate ? i_enable_light : enable_light;
    end
end

//Light image buffers and selection

wire [2:0] light_off_read_en;
wire [2:0][9:0] light_off_x;
logic  actual_light_off_read_en;
logic [9:0] actual_light_off_x;
logic [8:0] actual_light_off_y;
wire [15:0] light_on_read_val, light_off_read_val;
logic [15:0] light_read_val;

localparam BEDROOM_START_X = START_X + 10; //Note, the last offset is to center image with text, make sure to update text buffers if you change it
localparam LIVING_START_X = BEDROOM_START_X + TOTAL_BUFFER_SIZE + SPACE_BETWEEN_IMAGES + 15; 
localparam OUTSIDE_START_X = LIVING_START_X + TOTAL_BUFFER_SIZE + SPACE_BETWEEN_IMAGES;

assign actual_light_off_y =  i_vga_y - START_Y;
assign light_off_x[0] = i_vga_x - BEDROOM_START_X;
assign light_off_x[1] = i_vga_x - LIVING_START_X;
assign light_off_x[2] = i_vga_x - OUTSIDE_START_X;

assign light_off_read_en[0] = (i_vga_x > BEDROOM_START_X && i_vga_x < (BEDROOM_START_X + IMAGE_WIDTH)) && (i_vga_y > START_Y && i_vga_y < (START_Y + IMAGE_HEIGHT));
assign light_off_read_en[1] = (i_vga_x > LIVING_START_X && i_vga_x < (LIVING_START_X + IMAGE_WIDTH)) && (i_vga_y > START_Y && i_vga_y < (START_Y + IMAGE_HEIGHT));
assign light_off_read_en[2] = (i_vga_x > OUTSIDE_START_X && i_vga_x < (OUTSIDE_START_X + IMAGE_WIDTH)) && (i_vga_y > START_Y && i_vga_y < (START_Y + IMAGE_HEIGHT));

assign actual_light_off_read_en = | light_off_read_en;
always @(*) begin
    case(light_off_read_en) 
    3'b001 : begin
        actual_light_off_x = light_off_x[0];
        light_read_val = enable_light[0] ? light_on_read_val : light_off_read_val;
    end
    3'b010 : begin
        actual_light_off_x = light_off_x[1];
        light_read_val = enable_light[1] ? light_on_read_val : light_off_read_val;
    end
    3'b100 : begin
        actual_light_off_x = light_off_x[2];
        light_read_val = enable_light[2] ? light_on_read_val : light_off_read_val;
    end
    default : begin
        actual_light_off_x = 10'd0;
        light_read_val = 16'd0;
    end
    endcase
end

object_buffer #(
    .OBJ_WIDTH(50),
    .OBJECT(14),
	.OBJ_HEIGHT(58)
	) light_off_inst (
      .clk(clk), 
      .reset(reset),
      .i_read_en(actual_light_off_read_en),
      .i_read_x(actual_light_off_x),  
      .i_read_y(actual_light_off_y),
      .o_read_val(light_off_read_val)
	);

object_buffer #(
    .OBJ_WIDTH(50),
    .OBJECT(15),
	.OBJ_HEIGHT(58)
	) light_on_inst (
      .clk(clk), 
      .reset(reset),
      .i_read_en(actual_light_off_read_en), //Note that the read_en, x and y signals are the same for both buffers
      .i_read_x(actual_light_off_x),  
      .i_read_y(actual_light_off_y),
      .o_read_val(light_on_read_val)
	);




//Bedroom light

   logic [6:0][7:0] bedroom_string;
         wire enable_bedroom_char_pixel;
         wire [15:0] bedroom_char_pixel;
         assign bedroom_string = {8'd45, 8'd47, 8'd47, 8'd50, 8'd36, 8'd37, 8'd34}; //BEDROOM
                 
text_buffer #(
  .VGA_WIDTH(VGA_WIDTH),
  .VGA_HEIGHT(VGA_HEIGHT),
  .BUFFER_SIZE(7),
  .LETTER_Y_START(START_Y + IMAGE_HEIGHT + 2),
  .LETTER_X_START(BEDROOM_START_X - 10),
  .UPSCALING_SIZE(1)
      )text_buf_inst1(
      .clk(clk),
      .vga_clk(vga_clk), //25 MHz
      .reset(reset),
      
      .i_vga_x(i_vga_x),      
      .i_vga_y(i_vga_y),       

      .character(bedroom_string), //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
      .enable_char_pixel(enable_bedroom_char_pixel),
      .pixel(bedroom_char_pixel)
      
      );

//Livingroom light

   logic [6:0][7:0] living_string;
         wire enable_living_char_pixel;
         wire [15:0] living_char_pixel;
         assign living_string = {8'd0, 8'd39, 8'd46, 8'd41, 8'd54, 8'd41, 8'd44}; //LIVING 
              
text_buffer #(
  .VGA_WIDTH(VGA_WIDTH),
  .VGA_HEIGHT(VGA_HEIGHT),
  .BUFFER_SIZE(7),
  .LETTER_Y_START(START_Y + IMAGE_HEIGHT + 2),
  .LETTER_X_START(LIVING_START_X - 10),
  .UPSCALING_SIZE(1)
      )text_buf_inst2(
      .clk(clk),
      .vga_clk(vga_clk), //25 MHz
      .reset(reset),
      
      .i_vga_x(i_vga_x),      
      .i_vga_y(i_vga_y),       

      .character(living_string), //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
      .enable_char_pixel(enable_living_char_pixel),
      .pixel(living_char_pixel)
      
      );

//Outside light

   logic [6:0][7:0] outside_string;
         wire enable_outside_char_pixel;
         wire [15:0] outside_char_pixel;
         assign outside_string = {8'd37, 8'd36, 8'd41, 8'd51, 8'd52, 8'd53, 8'd47}; //OUTSIDE
               
text_buffer #(
  .VGA_WIDTH(VGA_WIDTH),
  .VGA_HEIGHT(VGA_HEIGHT),
  .BUFFER_SIZE(7),
  .LETTER_Y_START(START_Y + IMAGE_HEIGHT + 2),
  .LETTER_X_START(OUTSIDE_START_X - 10),
  .UPSCALING_SIZE(1)
      )text_buf_inst3(
      .clk(clk),
      .vga_clk(vga_clk), //25 MHz
      .reset(reset),
      
      .i_vga_x(i_vga_x),      
      .i_vga_y(i_vga_y),       

      .character(outside_string), //Note this is NOT ASCII, see clacon_font.png (examples: 0-9 is 16-25, A-Z is 33-58, a-z is 65-90)
      .enable_char_pixel(enable_outside_char_pixel),
      .pixel(outside_char_pixel)
      
      );
      
      logic [15:0] cur_pixel;
      always @(*) begin
        case ({actual_light_off_read_en, enable_outside_char_pixel, enable_living_char_pixel, enable_bedroom_char_pixel})
            4'b0001 : cur_pixel = bedroom_char_pixel;
            4'b0010 : cur_pixel = living_char_pixel;
            4'b0100 : cur_pixel = outside_char_pixel;
            4'b1000 : cur_pixel = light_read_val;
            default : cur_pixel = 16'd0;
        endcase
      end
      
      //Timing Fix
      /*
      always @(posedge clk) begin
        if(!reset) o_cur_pixel = 16'd0;
        else o_cur_pixel <= cur_pixel;
      end
      */
      assign o_cur_pixel = cur_pixel;
      
      //Make sure to update this as well
      assign o_enable_drawing = enable_outside_char_pixel || enable_living_char_pixel || enable_bedroom_char_pixel || actual_light_off_read_en;


endmodule

