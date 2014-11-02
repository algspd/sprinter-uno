//HUXLEY
#ifndef CONFIGURATION_H
#define CONFIGURATION_H

//// Calibration variables
// X, Y, Z, E steps per unit - Metric Prusa Mendel with Wade extruder:

float axis_steps_per_unit[] = {2560,2560,2560,700};

//// Endstop Settings
#define ENDSTOPPULLUPS 1 // Comment this out (using // at the start of the line) to disable the endstop pullup resistors
// The pullups are needed if you directly connect a mechanical endswitch between the signal and ground pins.
const bool ENDSTOPS_INVERTING = false; //set to true to invert the logic of the endstops
//If your axes are only moving in one direction, make sure the endstops are connected properly.
//If your axes move in one direction ONLY when the endstops are triggered, set ENDSTOPS_INVERTING to true here

// This determines the communication speed of the printer
#define BAUDRATE 115200

// For Inverting Stepper Enable Pins (Active Low) use 0, Non Inverting (Active High) use 1
#define Z_ENABLE_ON 0

// Inverting axis direction
const bool INVERT_Z_DIR = true;

//// ENDSTOP SETTINGS:
// Sets direction of endstops when homing; 1=MAX, -1=MIN
#define Z_HOME_DIR -1

const bool min_software_endstops = false; //If true, axis won't move to coordinates less than zero.
const bool max_software_endstops = true;  //If true, axis won't move to coordinates greater than the defined lengths below.
const int X_MAX_LENGTH = 200;
const int Y_MAX_LENGTH = 200;
const int Z_MAX_LENGTH = 300;

//// MOVEMENT SETTINGS
const int NUM_AXIS = 4; // The axis order in all axis related arrays is X, Y, Z, E
float max_feedrate[] = {8000, 8000, 160, 50000};
float homing_feedrate[] = {10000,10000,160};
bool axis_relative_modes[] = {false, false, false, false};

// Comment this to disable ramp acceleration
#define RAMP_ACCELERATION 1

//// Acceleration settings
#ifdef RAMP_ACCELERATION
// X, Y, Z, E maximum start speed for accelerated moves. E default values are good for skeinforge 40+, for older versions raise them a lot.
float max_start_speed_units_per_second[] = {20.0,20.0,0.2,30.0};
long max_acceleration_units_per_sq_second[] = {1000,1000,50,10000}; // X, Y, Z and E max acceleration in mm/s^2 for printing moves or retracts
long max_travel_acceleration_units_per_sq_second[] = {1000,1000,50,500}; // X, Y, Z max acceleration in mm/s^2 for travel moves
#endif

// Machine UUID
// This may be useful if you have multiple machines and wish to identify them by using the M115 command. 
// By default we set it to zeros.
char uuid[] = "00000000-0000-0000-0000-000000000000";

#endif
