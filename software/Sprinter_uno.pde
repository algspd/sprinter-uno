// Firmware based on Sprinter firmware.
// License: GPL

#include <Servo.h>

#include "fastio.h"
#include "Configuration.h"
#include "pins.h"
#include "Sprinter.h"

#include <IRremote.h>
//#include <IRremoteInt.h>

// look here for descriptions of gcodes: http://linuxcnc.org/handbook/gcode/g-code.html
// http://objects.reprap.org/wiki/Mendel_User_Manual:_RepRapGCodes

//Implemented Codes
//-------------------
// G0  -> G1
// G1  - Coordinated Movement X Y Z E
// G2  - Up-down movement. Takes 2 parameters, Overshoot and Layer thickness
// G4  - Dwell S<seconds> or P<milliseconds>
// G28 - Home all Axis
// G90 - Use Absolute Coordinates
// G91 - Use Relative Coordinates
// G92 - Set current position to cordinates given
// G93 - Open servo
// G94 - Close servo
// G95 - Send IR signal

//RepRap M Codes
// M114 - Display current position

//Custom M Codes
// M85  - Set inactivity shutdown timer with parameter S<seconds>. To disable set zero (default)
// M92  - Set axis_steps_per_unit - same syntax as G92
// M115	- Capabilities string
// M201 - Set max acceleration in units/s^2 for print moves (M201 X1000 Y1000)
// M202 - Set max acceleration in units/s^2 for travel moves (M202 X1000 Y1000)


//Stepper Movement Variables

char axis_codes[NUM_AXIS] = {'X', 'Y', 'Z', 'E'};
bool move_direction[NUM_AXIS];
unsigned long axis_previous_micros[NUM_AXIS];
unsigned long previous_micros = 0, previous_millis_heater, previous_millis_bed_heater;
unsigned long move_steps_to_take[NUM_AXIS];
#ifdef RAMP_ACCELERATION
unsigned long axis_max_interval[NUM_AXIS];
unsigned long axis_steps_per_sqr_second[NUM_AXIS];
unsigned long axis_travel_steps_per_sqr_second[NUM_AXIS];
unsigned long max_interval;
unsigned long steps_per_sqr_second, plateau_steps;  
#endif
boolean acceleration_enabled = false, accelerating = false;
unsigned long interval;
float destination[NUM_AXIS] = {0.0, 0.0, 0.0, 0.0};
float current_position[NUM_AXIS] = {0.0, 0.0, 0.0, 0.0};
unsigned long steps_taken[NUM_AXIS];
long axis_interval[NUM_AXIS]; // for speed delay
bool home_all_axis = true;
int feedrate = 1500, next_feedrate, saved_feedrate;
float time_for_move;
long gcode_N, gcode_LastN;
bool relative_mode = false;  //Determines Absolute or Relative Coordinates
bool relative_mode_e = false;  //Determines Absolute or Relative E Codes while in Absolute Coordinates mode. E is always relative in Relative Coordinates mode.
long timediff = 0;
//experimental feedrate calc
float d = 0;
float axis_diff[NUM_AXIS] = {0, 0, 0, 0};
#ifdef STEP_DELAY_RATIO
  long long_step_delay_ratio = STEP_DELAY_RATIO * 100;
#endif
float overshoot, layer_height;


// comm variables
#define MAX_CMD_SIZE 96
#define BUFSIZE 8
char cmdbuffer[BUFSIZE][MAX_CMD_SIZE];
bool fromsd[BUFSIZE];
int bufindr = 0;
int bufindw = 0;
int buflen = 0;
int i = 0;
char serial_char;
int serial_count = 0;
boolean comment_mode = false;
char *strchr_pointer; // just a pointer to find chars in the cmd string like X, Y, Z, E, etc

// Manage heater variables. For a thermistor or AD595 thermocouple, raw values refer to the 
// reading from the analog pin. For a MAX6675 thermocouple, the raw value is the temperature in 0.25 
// degree increments (i.e. 100=25 deg). 

int target_raw = 0;
int current_raw = 0;
int target_bed_raw = 0;
int current_bed_raw = 0;
int tt = 0, bt = 0;
        
//Inactivity shutdown variables
unsigned long previous_millis_cmd = 0;
unsigned long max_inactive_time = 0;
unsigned long stepper_inactive_time = 0;

Servo servo;

void setup()
{ 
  //cli();
  //TIMER_DISABLE_PWM;
  //TIMER_DISABLE_INTR;

 
  Serial.begin(BAUDRATE);
  Serial.println("start");
  
  servo.attach(SERVO);
  servo.write(70);
  
  for(int i = 0; i < BUFSIZE; i++){
      fromsd[i] = false;
  }

  //Initialize Dir Pins
  SET_OUTPUT(Z_DIR_PIN);
  SET_INPUT(Z_MIN_PIN); 
  SET_INPUT(Z_MAX_PIN); 
  SET_OUTPUT(Z_STEP_PIN);

  #ifdef RAMP_ACCELERATION
  for(int i=0; i < NUM_AXIS; i++){
        axis_max_interval[i] = 100000000.0 / (max_start_speed_units_per_second[i] * axis_steps_per_unit[i]);
        axis_steps_per_sqr_second[i] = max_acceleration_units_per_sq_second[i] * axis_steps_per_unit[i];
        axis_travel_steps_per_sqr_second[i] = max_travel_acceleration_units_per_sq_second[i] * axis_steps_per_unit[i];
    }
  #endif

}


void loop()
{
  if(buflen<3)
	get_command();
  
  if(buflen){
    process_commands();
    buflen = (buflen-1);
    bufindr = (bufindr + 1)%BUFSIZE;
    }
      manage_inactivity(1);
  }


inline void get_command() 
{ 
  while( Serial.available() > 0  && buflen < BUFSIZE) {
    serial_char = Serial.read();
    if(serial_char == '\n' || serial_char == '\r' || serial_char == ':' || serial_count >= (MAX_CMD_SIZE - 1) ) 
    {
      if(!serial_count) return; //if empty line
      cmdbuffer[bufindw][serial_count] = 0; //terminate string
      if(!comment_mode){
    fromsd[bufindw] = false;
  if(strstr(cmdbuffer[bufindw], "N") != NULL)
  {
    strchr_pointer = strchr(cmdbuffer[bufindw], 'N');
    gcode_N = (strtol(&cmdbuffer[bufindw][strchr_pointer - cmdbuffer[bufindw] + 1], NULL, 10));
    if(gcode_N != gcode_LastN+1 && (strstr(cmdbuffer[bufindw], "M110") == NULL) ) {
      Serial.print("Serial Error: Line Number is not Last Line Number+1, Last Line:");
      Serial.println(gcode_LastN);
      //Serial.println(gcode_N);
      FlushSerialRequestResend();
      serial_count = 0;
      return;
    }
    
    if(strstr(cmdbuffer[bufindw], "*") != NULL)
    {
      byte checksum = 0;
      byte count = 0;
      while(cmdbuffer[bufindw][count] != '*') checksum = checksum^cmdbuffer[bufindw][count++];
      strchr_pointer = strchr(cmdbuffer[bufindw], '*');
  
      if( (int)(strtod(&cmdbuffer[bufindw][strchr_pointer - cmdbuffer[bufindw] + 1], NULL)) != checksum) {
        Serial.print("Error: checksum mismatch, Last Line:");
        Serial.println(gcode_LastN);
        FlushSerialRequestResend();
        serial_count = 0;
        return;
      }
      //if no errors, continue parsing
    }
    else 
    {
      Serial.print("Error: No Checksum with line number, Last Line:");
      Serial.println(gcode_LastN);
      FlushSerialRequestResend();
      serial_count = 0;
      return;
    }
    
    gcode_LastN = gcode_N;
    //if no errors, continue parsing
  }
  else  // if we don't receive 'N' but still see '*'
  {
    if((strstr(cmdbuffer[bufindw], "*") != NULL))
    {
      Serial.print("Error: No Line Number with checksum, Last Line:");
      Serial.println(gcode_LastN);
      serial_count = 0;
      return;
    }
  }
	if((strstr(cmdbuffer[bufindw], "G") != NULL)){
		strchr_pointer = strchr(cmdbuffer[bufindw], 'G');
		switch((int)((strtod(&cmdbuffer[bufindw][strchr_pointer - cmdbuffer[bufindw] + 1], NULL)))){
		case 0:
		case 1:
			  Serial.println("ok"); 
			  break;
		default:
			break;
		}

	}
        bufindw = (bufindw + 1)%BUFSIZE;
        buflen += 1;
        
      }
      comment_mode = false; //for new command
      serial_count = 0; //clear buffer
    }
    else
    {
      if(serial_char == ';') comment_mode = true;
      if(!comment_mode) cmdbuffer[bufindw][serial_count++] = serial_char;
    }
  }
}


inline float code_value() { return (strtod(&cmdbuffer[bufindr][strchr_pointer - cmdbuffer[bufindr] + 1], NULL)); }
inline long code_value_long() { return (strtol(&cmdbuffer[bufindr][strchr_pointer - cmdbuffer[bufindr] + 1], NULL, 10)); }
inline bool code_seen(char code_string[]) { return (strstr(cmdbuffer[bufindr], code_string) != NULL); }  //Return True if the string was found

inline bool code_seen(char code)
{
  strchr_pointer = strchr(cmdbuffer[bufindr], code);
  return (strchr_pointer != NULL);  //Return True if a character was found
}

inline void process_commands()
{
  unsigned long codenum; //throw away variable
  char *starpos = NULL;

  if(code_seen('G'))
  {
    switch((int)code_value())
    {
      case 0: // G0 -> G1
      case 1: // G1
        get_coordinates(); // For X Y Z E F
        prepare_move();
        previous_millis_cmd = millis();
        //ClearToSend();
        return;
        //break;
                
      case 2: // G2 O2 L0.05 -> O=overshoot L=Layer
        get_overshoot(); //sets overshoot and layer_height
        // Set destination
        relative_mode = true;

        destination[2]=(float)overshoot + (axis_relative_modes[2] || relative_mode)*current_position[2];
        feedrate = 160;        
        prepare_move();
        
        destination[2]=-(float)overshoot +(float)layer_height + (axis_relative_modes[2] || relative_mode)*current_position[2];
        feedrate = 160;
        prepare_move();
        
        return;
        //break;
        
      case 4: // G4 dwell
        codenum = 0;
        if(code_seen('P')) codenum = code_value(); // milliseconds to wait
        if(code_seen('S')) codenum = code_value() * 1000; // seconds to wait
        codenum += millis();  // keep track of when we started waiting
        break;
      case 28: //G28 Home all Axis one at a time
        saved_feedrate = feedrate;
        for(int i=0; i < NUM_AXIS; i++) {
          destination[i] = current_position[i];
        }
        feedrate = 0;

        home_all_axis = !((code_seen(axis_codes[0])) || (code_seen(axis_codes[1])) || (code_seen(axis_codes[2])));
       
        if((home_all_axis) || (code_seen(axis_codes[2]))) {
          if ((Z_MIN_PIN > -1 && Z_HOME_DIR==-1) || (Z_MAX_PIN > -1 && Z_HOME_DIR==1)){
            current_position[2] = 0;
            destination[2] = 1.5 * Z_MAX_LENGTH * Z_HOME_DIR;
            feedrate = homing_feedrate[2];
            prepare_move();
          
            current_position[2] = 0;
            destination[2] = -2 * Z_HOME_DIR;
            prepare_move();
          
            destination[2] = 10 * Z_HOME_DIR;
            prepare_move();
          
            current_position[2] = (Z_HOME_DIR == -1) ? 0 : Z_MAX_LENGTH;
            destination[2] = current_position[2];
            feedrate = 0;
          
        }
        }
        
        feedrate = saved_feedrate;
        previous_millis_cmd = millis();
        break;
      case 90: // G90
        relative_mode = false;
        break;
      case 91: // G91
        relative_mode = true;
        break;
      case 92: // G92
        for(int i=0; i < NUM_AXIS; i++) {
          if(code_seen(axis_codes[i])) current_position[i] = code_value();  
        }
        break;
      case 93: // G93 open servo
        servo.write(160);
        break;
      case 94: //G94 close servo
        servo.write(70);
        break;
      case 95: //G95 IR signal
        ;
        IRsend irsend;
        // Adapt this to your projector
        irsend.sendNEC(281600286, 32);
        //break;
    }
  }

  else if(code_seen('M'))
  {    
    switch( (int)code_value() ) 
    {
      case 85: // M85
        code_seen('S');
        max_inactive_time = code_value() * 1000; 
        break;
      case 92: // M92
        for(int i=0; i < NUM_AXIS; i++) {
          if(code_seen(axis_codes[i])) axis_steps_per_unit[i] = code_value();
        }
        
        //Update start speed intervals and axis order. TODO: refactor axis_max_interval[] calculation into a function, as it
        // should also be used in setup() as well
        #ifdef RAMP_ACCELERATION
          long temp_max_intervals[NUM_AXIS];
          for(int i=0; i < NUM_AXIS; i++) {
            axis_max_interval[i] = 100000000.0 / (max_start_speed_units_per_second[i] * axis_steps_per_unit[i]);//TODO: do this for
                  // all steps_per_unit related variables
          }
        #endif
        break;
      case 115: // M115
        Serial.print("FIRMWARE_NAME:Sprinter FIRMWARE_URL:http%%3A/github.com/kliment/Sprinter/ PROTOCOL_VERSION:1.0 MACHINE_TYPE:Mendel EXTRUDER_COUNT:1 UUID:");
        Serial.println(uuid);
        break;
      case 114: // M114
	Serial.print("X:");
        Serial.print(current_position[0]);
	Serial.print("Y:");
        Serial.print(current_position[1]);
	Serial.print("Z:");
        Serial.print(current_position[2]);
	Serial.print("E:");
        Serial.println(current_position[3]);
        break;
      case 119: // M119
      	#if (Z_MIN_PIN > -1)
      	Serial.print("z_min:");
        Serial.print((READ(Z_MIN_PIN)^ENDSTOPS_INVERTING)?"H ":"L ");
      	#endif
      	#if (Z_MAX_PIN > -1)
      	Serial.print("z_max:");
        Serial.print((READ(Z_MAX_PIN)^ENDSTOPS_INVERTING)?"H ":"L ");
      	#endif
        Serial.println("");
      	break;
      #ifdef RAMP_ACCELERATION
      //TODO: update for all axis, use for loop
      case 201: // M201
        for(int i=0; i < NUM_AXIS; i++) {
          if(code_seen(axis_codes[i])) axis_steps_per_sqr_second[i] = code_value() * axis_steps_per_unit[i];
        }
        break;
      case 202: // M202
        for(int i=0; i < NUM_AXIS; i++) {
          if(code_seen(axis_codes[i])) axis_travel_steps_per_sqr_second[i] = code_value() * axis_steps_per_unit[i];
        }
        break;
      #endif
    }
    
  }
  else{
      Serial.println("Unknown command:");
      Serial.println(cmdbuffer[bufindr]);
  }
  
  ClearToSend();
      
}

void FlushSerialRequestResend()
{
  //char cmdbuffer[bufindr][100]="Resend:";
  Serial.flush();
  Serial.print("Resend:");
  Serial.println(gcode_LastN + 1);
  ClearToSend();
}

void ClearToSend()
{
  previous_millis_cmd = millis();
  Serial.println("ok"); 
}

inline void get_coordinates()
{
  for(int i=0; i < NUM_AXIS; i++) {
    if(code_seen(axis_codes[i])) destination[i] = (float)code_value() + (axis_relative_modes[i] || relative_mode)*current_position[i];
    else destination[i] = current_position[i];                                                       //Are these else lines really needed?
  }
  if(code_seen('F')) {
    next_feedrate = code_value();
    if(next_feedrate > 0.0) feedrate = next_feedrate;
  }
}

inline void get_overshoot()
{
  if(code_seen('O')) {
    overshoot = code_value();
  }
  if(code_seen('L')) {
    layer_height = code_value();
  }
}

void prepare_move()
{
  //Find direction
  for(int i=0; i < NUM_AXIS; i++) {
    if(destination[i] >= current_position[i]) move_direction[i] = 1;
    else move_direction[i] = 0;
  }
  
  
  if (min_software_endstops) {
    if (destination[0] < 0) destination[0] = 0.0;
    if (destination[1] < 0) destination[1] = 0.0;
    if (destination[2] < 0) destination[2] = 0.0;
  }

  if (max_software_endstops) {
    if (destination[0] > X_MAX_LENGTH) destination[0] = X_MAX_LENGTH;
    if (destination[1] > Y_MAX_LENGTH) destination[1] = Y_MAX_LENGTH;
    if (destination[2] > Z_MAX_LENGTH) destination[2] = Z_MAX_LENGTH;
  }

  for(int i=0; i < NUM_AXIS; i++) {
    axis_diff[i] = destination[i] - current_position[i];
    move_steps_to_take[i] = abs(axis_diff[i]) * axis_steps_per_unit[i];
  }
  if(feedrate < 10)
      feedrate = 10;
  
  //Feedrate calc based on XYZ travel distance
  float xy_d;
  //Check for cases where only one axis is moving - handle those without float sqrt
  if(abs(axis_diff[0]) > 0 && abs(axis_diff[1]) == 0 && abs(axis_diff[2])==0)
    d=abs(axis_diff[0]);
  else if(abs(axis_diff[0]) == 0 && abs(axis_diff[1]) > 0 && abs(axis_diff[2])==0)
    d=abs(axis_diff[1]);
  else if(abs(axis_diff[0]) == 0 && abs(axis_diff[1]) == 0 && abs(axis_diff[2])>0)
    d=abs(axis_diff[2]);
  //two or three XYZ axes moving
  else if(abs(axis_diff[0]) > 0 || abs(axis_diff[1]) > 0) { //X or Y or both
    xy_d = sqrt(axis_diff[0] * axis_diff[0] + axis_diff[1] * axis_diff[1]);
    //check if Z involved - if so interpolate that too
    d = (abs(axis_diff[2]>0))?sqrt(xy_d * xy_d + axis_diff[2] * axis_diff[2]):xy_d;
  }
  else if(abs(axis_diff[3]) > 0)
    d = abs(axis_diff[3]);
  else{ //zero length move
    return;
    }
  time_for_move = (d / (feedrate / 60000000.0) );
  //Check max feedrate for each axis is not violated, update time_for_move if necessary
  for(int i = 0; i < NUM_AXIS; i++) {
    if(move_steps_to_take[i] && abs(axis_diff[i]) / (time_for_move / 60000000.0) > max_feedrate[i]) {
      time_for_move = time_for_move / max_feedrate[i] * (abs(axis_diff[i]) / (time_for_move / 60000000.0));
    }
  }
  //Calculate the full speed stepper interval for each axis
  for(int i=0; i < NUM_AXIS; i++) {
    if(move_steps_to_take[i]) axis_interval[i] = time_for_move / move_steps_to_take[i] * 100;
  }

  unsigned long move_steps[NUM_AXIS];
  for(int i=0; i < NUM_AXIS; i++)
    move_steps[i] = move_steps_to_take[i];
  linear_move(move_steps); // make the move
}

inline void linear_move(unsigned long axis_steps_remaining[]) // make linear move with preset speeds and destinations, see G0 and G1
{
  //Determine direction of movement
  if (destination[2] > current_position[2]) WRITE(Z_DIR_PIN,!INVERT_Z_DIR);
  else WRITE(Z_DIR_PIN,INVERT_Z_DIR);
  movereset:
  #if (Z_MIN_PIN > -1) 
    if(!move_direction[2]) if(READ(Z_MIN_PIN) != ENDSTOPS_INVERTING) axis_steps_remaining[2]=0;
  #endif
  # if(Z_MAX_PIN > -1) 
    if(move_direction[2]) if(READ(Z_MAX_PIN) != ENDSTOPS_INVERTING) axis_steps_remaining[2]=0;
  #endif

    //Define variables that are needed for the Bresenham algorithm. Please note that  Z is not currently included in the Bresenham algorithm.
  unsigned long delta[] = {axis_steps_remaining[0], axis_steps_remaining[1], axis_steps_remaining[2], axis_steps_remaining[3]}; //TODO: implement a "for" to support N axes
  long axis_error[NUM_AXIS];
  int primary_axis;
  if(delta[1] > delta[0] && delta[1] > delta[2] && delta[1] > delta[3]) primary_axis = 1;
  else if (delta[0] >= delta[1] && delta[0] > delta[2] && delta[0] > delta[3]) primary_axis = 0;
  else if (delta[2] >= delta[0] && delta[2] >= delta[1] && delta[2] > delta[3]) primary_axis = 2;
  else primary_axis = 3;
  unsigned long steps_remaining = delta[primary_axis];
  unsigned long steps_to_take = steps_remaining;
  for(int i=0; i < NUM_AXIS; i++){
       if(i != primary_axis) axis_error[i] = delta[primary_axis] / 2;
       steps_taken[i]=0;
    }
  interval = axis_interval[primary_axis];
  bool is_print_move = delta[3] > 0;

  //If acceleration is enabled, do some Bresenham calculations depending on which axis will lead it.
  #ifdef RAMP_ACCELERATION
    long max_speed_steps_per_second;
    long min_speed_steps_per_second;
    max_interval = axis_max_interval[primary_axis];
    unsigned long new_axis_max_intervals[NUM_AXIS];
    max_speed_steps_per_second = 100000000 / interval;
    min_speed_steps_per_second = 100000000 / max_interval; //TODO: can this be deleted?
    //Calculate start speeds based on moving axes max start speed constraints.
    int slowest_start_axis = primary_axis;
    unsigned long slowest_start_axis_max_interval = max_interval;
    for(int i = 0; i < NUM_AXIS; i++)
      if (axis_steps_remaining[i] >0 && 
            i != primary_axis && 
            axis_max_interval[i] * axis_steps_remaining[i]/ axis_steps_remaining[slowest_start_axis] > slowest_start_axis_max_interval) {
        slowest_start_axis = i;
        slowest_start_axis_max_interval = axis_max_interval[i];
      }
    for(int i = 0; i < NUM_AXIS; i++)
      if(axis_steps_remaining[i] >0) {
        // multiplying slowest_start_axis_max_interval by axis_steps_remaining[slowest_start_axis]
        // could lead to overflows when we have long distance moves (say, 390625*390625 > sizeof(unsigned long))
        float steps_remaining_ratio = (float) axis_steps_remaining[slowest_start_axis] / axis_steps_remaining[i];
        new_axis_max_intervals[i] = slowest_start_axis_max_interval * steps_remaining_ratio;
        
        if(i == primary_axis) {
          max_interval = new_axis_max_intervals[i];
          min_speed_steps_per_second = 100000000 / max_interval;
        }
      }
    //Calculate slowest axis plateau time
    float slowest_axis_plateau_time = 0;
    for(int i=0; i < NUM_AXIS ; i++) {
      if(axis_steps_remaining[i] > 0) {
        if(is_print_move && axis_steps_remaining[i] > 0) slowest_axis_plateau_time = max(slowest_axis_plateau_time,
              (100000000.0 / axis_interval[i] - 100000000.0 / new_axis_max_intervals[i]) / (float) axis_steps_per_sqr_second[i]);
        else if(axis_steps_remaining[i] > 0) slowest_axis_plateau_time = max(slowest_axis_plateau_time,
              (100000000.0 / axis_interval[i] - 100000000.0 / new_axis_max_intervals[i]) / (float) axis_travel_steps_per_sqr_second[i]);
      }
    }
    //Now we can calculate the new primary axis acceleration, so that the slowest axis max acceleration is not violated
    steps_per_sqr_second = (100000000.0 / axis_interval[primary_axis] - 100000000.0 / new_axis_max_intervals[primary_axis]) / slowest_axis_plateau_time;
    plateau_steps = (long) ((steps_per_sqr_second / 2.0 * slowest_axis_plateau_time + min_speed_steps_per_second) * slowest_axis_plateau_time);
  #endif
  
  unsigned long steps_done = 0;
  #ifdef RAMP_ACCELERATION
  plateau_steps *= 1.01; // This is to compensate we use discrete intervals
  acceleration_enabled = true;
  unsigned long full_interval = interval;
  if(interval > max_interval) acceleration_enabled = false;
  boolean decelerating = false;
  #endif
  
  unsigned long start_move_micros = micros();
  for(int i = 0; i < NUM_AXIS; i++) {
    axis_previous_micros[i] = start_move_micros * 100;
  }
  
  //move until no more steps remain 
  while(axis_steps_remaining[0] + axis_steps_remaining[1] + axis_steps_remaining[2] + axis_steps_remaining[3] > 0) {
    #ifdef RAMP_ACCELERATION
    //If acceleration is enabled on this move and we are in the acceleration segment, calculate the current interval
    if (acceleration_enabled && steps_done == 0) {
        interval = max_interval;
    } else if (acceleration_enabled && steps_done <= plateau_steps) {
        long current_speed = (long) ((((long) steps_per_sqr_second) / 10000)
	    * ((micros() - start_move_micros)  / 100) + (long) min_speed_steps_per_second);
	    interval = 100000000 / current_speed;
      if (interval < full_interval) {
        accelerating = false;
      	interval = full_interval;
      }
      if (steps_done >= steps_to_take / 2) {
	plateau_steps = steps_done;
	max_speed_steps_per_second = 100000000 / interval;
	accelerating = false;
      }
    } else if (acceleration_enabled && steps_remaining <= plateau_steps) { //(interval > minInterval * 100) {
      if (!accelerating) {
        start_move_micros = micros();
        accelerating = true;
        decelerating = true;
      }				
      long current_speed = (long) ((long) max_speed_steps_per_second - ((((long) steps_per_sqr_second) / 10000)
          * ((micros() - start_move_micros) / 100)));
      interval = 100000000 / current_speed;
      if (interval > max_interval)
	interval = max_interval;
    } else {
      //Else, we are just use the full speed interval as current interval
      interval = full_interval;
      accelerating = false;
    }
    #endif

    //If there are x or y steps remaining, perform Bresenham algorithm
    if(axis_steps_remaining[primary_axis]) {
      #if (Z_MIN_PIN > -1) 
        if(!move_direction[2]) if(READ(Z_MIN_PIN) != ENDSTOPS_INVERTING) if(primary_axis==2) break; else if(axis_steps_remaining[2]) axis_steps_remaining[2]=0;
      #endif
      #if (Z_MAX_PIN > -1) 
        if(move_direction[2]) if(READ(Z_MAX_PIN) != ENDSTOPS_INVERTING) if(primary_axis==2) break; else if(axis_steps_remaining[2]) axis_steps_remaining[2]=0;
      #endif
      timediff = micros() * 100 - axis_previous_micros[primary_axis];
      if(timediff<0){//check for overflow
        axis_previous_micros[primary_axis]=micros()*100;
        timediff=interval/2; //approximation
      }
      while(((unsigned long)timediff) >= interval && axis_steps_remaining[primary_axis] > 0) {
        steps_done++;
        steps_remaining--;
        axis_steps_remaining[primary_axis]--; timediff -= interval;
        do_step(primary_axis);
        axis_previous_micros[primary_axis] += interval;
        for(int i=0; i < NUM_AXIS; i++) if(i != primary_axis && axis_steps_remaining[i] > 0) {
          axis_error[i] = axis_error[i] - delta[i];
          if(axis_error[i] < 0) {
            do_step(i); axis_steps_remaining[i]--;
            axis_error[i] = axis_error[i] + delta[primary_axis];
          }
        }
        #ifdef STEP_DELAY_RATIO
        if(timediff >= interval) delayMicroseconds(long_step_delay_ratio * interval / 10000);
        #endif
        #ifdef STEP_DELAY_MICROS
        if(timediff >= interval) delayMicroseconds(STEP_DELAY_MICROS);
        #endif
      }
    }
  }
  
  // Update current position partly based on direction, we probably can combine this with the direction code above...
  for(int i=0; i < NUM_AXIS; i++) {
    if (destination[i] > current_position[i]) current_position[i] = current_position[i] + steps_taken[i] /  axis_steps_per_unit[i];
    else current_position[i] = current_position[i] - steps_taken[i] / axis_steps_per_unit[i];
  }
}

void do_step(int axis) {
  switch(axis){
  case 2:
    WRITE(Z_STEP_PIN, HIGH);
    break;
  }
  steps_taken[axis]+=1;
  WRITE(Z_STEP_PIN, LOW);
}



inline void kill()
{
}

inline void manage_inactivity(byte debug) { 
if( (millis()-previous_millis_cmd) >  max_inactive_time ) if(max_inactive_time) kill(); 
if( (millis()-previous_millis_cmd) >  stepper_inactive_time ) if(stepper_inactive_time) { }
}


