EESchema Schematic File Version 2  date Sun 02 Nov 2014 06:03:45 PM CET
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
EELAYER 25  0
EELAYER END
$Descr A4 11700 8267
encoding utf-8
Sheet 1 1
Title ""
Date "23 apr 2014"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 5200 2600 0    60   Input ~ 0
GND
$Comp
L CONN_2 LCD1
U 1 1 5357E164
P 5550 2700
F 0 "LCD1" V 5500 2700 40  0000 C CNN
F 1 "CONN_2" V 5600 2700 40  0000 C CNN
	1    5550 2700
	1    0    0    -1  
$EndComp
Text GLabel 3250 4600 0    60   Input ~ 0
D10
Text GLabel 3250 4700 0    60   Input ~ 0
D11
Text GLabel 4350 3000 1    60   Input ~ 0
12V
Text GLabel 3950 3000 1    60   Input ~ 0
12V
Text GLabel 4350 3400 3    60   Input ~ 0
GND
Text GLabel 3950 3400 3    60   Input ~ 0
GND
$Comp
L CP1 C2
U 1 1 53277F3C
P 4350 3200
F 0 "C2" H 4400 3300 50  0000 L CNN
F 1 "100uF" H 4400 3100 50  0000 L CNN
	1    4350 3200
	1    0    0    -1  
$EndComp
$Comp
L CP1 C1
U 1 1 53277F2E
P 3950 3200
F 0 "C1" H 4000 3300 50  0000 L CNN
F 1 "100uF" H 4000 3100 50  0000 L CNN
	1    3950 3200
	1    0    0    -1  
$EndComp
$Comp
L CONN_2 FAN_1
U 1 1 53277C4F
P 5550 3100
F 0 "FAN_1" V 5500 3100 40  0000 C CNN
F 1 "CONN_2" V 5600 3100 40  0000 C CNN
	1    5550 3100
	1    0    0    -1  
$EndComp
Text GLabel 5200 3000 0    60   Input ~ 0
GND
Text GLabel 5200 3200 0    60   Input ~ 0
12V
Text GLabel 5200 2800 0    60   Input ~ 0
5V'
Text GLabel 6300 3500 0    60   Input ~ 0
5V'
Text GLabel 6300 3200 0    60   Input ~ 0
GND
$Comp
L USB_2 USB1
U 1 1 53277894
P 6500 3350
F 0 "USB1" H 6425 3600 60  0001 C CNN
F 1 "USB" H 6550 3050 60  0001 C CNN
F 4 "VCC" H 6825 3500 50  0001 C CNN "VCC"
F 5 "D+" H 6800 3400 50  0001 C CNN "Data+"
F 6 "D-" H 6800 3300 50  0001 C CNN "Data-"
F 7 "GND" H 6825 3200 50  0001 C CNN "Ground"
	1    6500 3350
	-1   0    0    1   
$EndComp
Text GLabel 4250 2550 2    60   Input ~ 0
5V'
$Comp
L CONN_3 SCREW1
U 1 1 53122DDD
P 3900 2450
F 0 "SCREW1" V 3850 2450 50  0000 C CNN
F 1 "CONN_3" V 3950 2450 40  0000 C CNN
	1    3900 2450
	-1   0    0    1   
$EndComp
Wire Wire Line
	5200 4500 5200 4400
Wire Wire Line
	3250 4500 3250 4400
$Comp
L CONN_8 POLOLU2_B1
U 1 1 53120C18
P 5850 4350
F 0 "POLOLU2_B1" V 5800 4350 60  0000 C CNN
F 1 "CONN_8" V 5900 4350 60  0000 C CNN
	1    5850 4350
	-1   0    0    1   
$EndComp
$Comp
L CONN_8 POLOLU2_A1
U 1 1 53120C10
P 5550 4350
F 0 "POLOLU2_A1" V 5500 4350 60  0000 C CNN
F 1 "CONN_8" V 5600 4350 60  0000 C CNN
	1    5550 4350
	1    0    0    -1  
$EndComp
$Comp
L CONN_8 POLOLU1_B1
U 1 1 53120C0B
P 3900 4350
F 0 "POLOLU1_B1" V 3850 4350 60  0000 C CNN
F 1 "CONN_8" V 3950 4350 60  0000 C CNN
	1    3900 4350
	-1   0    0    1   
$EndComp
$Comp
L CONN_8 POLOLU1_A1
U 1 1 53120BFF
P 3600 4350
F 0 "POLOLU1_A1" V 3550 4350 60  0000 C CNN
F 1 "CONN_8" V 3650 4350 60  0000 C CNN
	1    3600 4350
	1    0    0    -1  
$EndComp
Text GLabel 4250 2450 2    60   Input ~ 0
GND
Text GLabel 4250 2350 2    60   Input ~ 0
12V
Text GLabel 6200 2100 0    60   Input ~ 0
P1_1B
Text GLabel 6200 2000 0    60   Input ~ 0
P1_1A
Text GLabel 6200 1900 0    60   Input ~ 0
P1_2A
Text GLabel 6200 1800 0    60   Input ~ 0
P1_2B
Text GLabel 6200 2300 0    60   Input ~ 0
P2_2B
Text GLabel 6200 2400 0    60   Input ~ 0
P2_2A
Text GLabel 6200 2500 0    60   Input ~ 0
P2_1A
Text GLabel 6200 2600 0    60   Input ~ 0
P2_1B
Text GLabel 3250 4100 0    60   Input ~ 0
5V
Text GLabel 3250 4200 0    60   Input ~ 0
5V
Text GLabel 3250 4300 0    60   Input ~ 0
5V
Text GLabel 4250 4000 2    60   Input ~ 0
12V
Text GLabel 4250 4100 2    60   Input ~ 0
GND
Text GLabel 4250 4200 2    60   Input ~ 0
P1_2B
Text GLabel 4250 4300 2    60   Input ~ 0
P1_2A
Text GLabel 4250 4400 2    60   Input ~ 0
P1_1A
Text GLabel 4250 4500 2    60   Input ~ 0
P1_1B
Text GLabel 4250 4600 2    60   Input ~ 0
5V
Text GLabel 4250 4700 2    60   Input ~ 0
GND
Text GLabel 6200 4700 2    60   Input ~ 0
GND
Text GLabel 6200 4600 2    60   Input ~ 0
5V
Text GLabel 6200 4500 2    60   Input ~ 0
P2_1B
Text GLabel 6200 4400 2    60   Input ~ 0
P2_1A
Text GLabel 6200 4300 2    60   Input ~ 0
P2_2A
Text GLabel 6200 4200 2    60   Input ~ 0
P2_2B
Text GLabel 6200 4100 2    60   Input ~ 0
GND
Text GLabel 6200 4000 2    60   Input ~ 0
12V
Text GLabel 5200 4700 0    60   Input ~ 0
D11
Text GLabel 5200 4600 0    60   Input ~ 0
D10
Text GLabel 5200 4300 0    60   Input ~ 0
5V
Text GLabel 5200 4200 0    60   Input ~ 0
5V
Text GLabel 5200 4100 0    60   Input ~ 0
5V
Text GLabel 5200 3400 0    60   Input ~ 0
D5
Text GLabel 6200 2800 0    60   Input ~ 0
GND
Text GLabel 6200 3000 0    60   Input ~ 0
D3
Text GLabel 5200 2350 0    60   Input ~ 0
D6
Text GLabel 5200 2000 0    60   Input ~ 0
D7
$Comp
L CONN_2 IR_LED1
U 1 1 5311FB98
P 6550 2900
F 0 "IR_LED1" V 6500 2900 40  0000 C CNN
F 1 "CONN_2" V 6600 2900 40  0000 C CNN
	1    6550 2900
	1    0    0    -1  
$EndComp
$Comp
L CONN_4 P2_M1
U 1 1 5311FB51
P 6550 2450
F 0 "P2_M1" V 6500 2450 50  0000 C CNN
F 1 "CONN_4" V 6600 2450 50  0000 C CNN
	1    6550 2450
	1    0    0    -1  
$EndComp
$Comp
L CONN_4 P1_M1
U 1 1 5311FB3B
P 6550 1950
F 0 "P1_M1" V 6500 1950 50  0000 C CNN
F 1 "CONN_4" V 6600 1950 50  0000 C CNN
	1    6550 1950
	1    0    0    -1  
$EndComp
Text GLabel 5200 3600 0    60   Input ~ 0
GND
Text GLabel 5200 3500 0    60   Input ~ 0
5V'
$Comp
L CONN_3 SERVO1
U 1 1 5311F9C8
P 5550 3500
F 0 "SERVO1" V 5500 3500 50  0000 C CNN
F 1 "CONN_3" V 5600 3500 40  0000 C CNN
	1    5550 3500
	1    0    0    -1  
$EndComp
Text GLabel 5200 2250 0    60   Input ~ 0
GND
Text GLabel 5200 1900 0    60   Input ~ 0
GND
Text GLabel 5200 2150 0    60   Input ~ 0
5V
Text GLabel 5200 1800 0    60   Input ~ 0
5V
$Comp
L CONN_3 Z1-MIN1
U 1 1 5311F925
P 5550 2250
F 0 "Z1-MIN1" V 5500 2250 50  0000 C CNN
F 1 "CONN_3" V 5600 2250 40  0000 C CNN
	1    5550 2250
	1    0    0    -1  
$EndComp
$Comp
L CONN_3 Z1-MAX1
U 1 1 5311F915
P 5550 1900
F 0 "Z1-MAX1" V 5500 1900 50  0000 C CNN
F 1 "CONN_3" V 5600 1900 40  0000 C CNN
	1    5550 1900
	1    0    0    -1  
$EndComp
Text GLabel 3150 1650 2    60   Input ~ 0
AREF
Text GLabel 3150 1750 2    60   Input ~ 0
GND
Text GLabel 3150 1850 2    60   Input ~ 0
D13
Text GLabel 3150 1950 2    60   Input ~ 0
D12
Text GLabel 3150 2050 2    60   Input ~ 0
D11
Text GLabel 3150 2150 2    60   Input ~ 0
D10
Text GLabel 3150 2250 2    60   Input ~ 0
D9
Text GLabel 3150 2350 2    60   Input ~ 0
D8
Text GLabel 3150 2550 2    60   Input ~ 0
D7
Text GLabel 3150 2650 2    60   Input ~ 0
D6
Text GLabel 3150 2750 2    60   Input ~ 0
D5
Text GLabel 3150 2850 2    60   Input ~ 0
D4
Text GLabel 3150 2950 2    60   Input ~ 0
D3
Text GLabel 3150 3050 2    60   Input ~ 0
D2
Text GLabel 3150 3150 2    60   Input ~ 0
D1
Text GLabel 3150 3250 2    60   Input ~ 0
D0
Text GLabel 4250 1650 2    60   Input ~ 0
Reset
Text GLabel 4250 2150 2    60   Input ~ 0
Vin
Text GLabel 4250 2050 2    60   Input ~ 0
GND
Text GLabel 4250 1950 2    60   Input ~ 0
GND
Text GLabel 4250 1850 2    60   Input ~ 0
5V
Text GLabel 4250 1750 2    60   Input ~ 0
3.3V
$Comp
L CONN_6 POWER1
U 1 1 53110C0A
P 3900 1900
F 0 "POWER1" V 3850 1900 60  0000 C CNN
F 1 "CONN_6" V 3950 1900 60  0000 C CNN
	1    3900 1900
	-1   0    0    1   
$EndComp
$Comp
L CONN_8 DIGITAL2
U 1 1 53110BE0
P 2800 2900
F 0 "DIGITAL2" V 2750 2900 60  0000 C CNN
F 1 "CONN_8" V 2850 2900 60  0000 C CNN
	1    2800 2900
	-1   0    0    1   
$EndComp
$Comp
L CONN_8 DIGITAL1
U 1 1 53110A98
P 2800 2000
F 0 "DIGITAL1" V 2750 2000 60  0000 C CNN
F 1 "CONN_8" V 2850 2000 60  0000 C CNN
	1    2800 2000
	-1   0    0    1   
$EndComp
$EndSCHEMATC
