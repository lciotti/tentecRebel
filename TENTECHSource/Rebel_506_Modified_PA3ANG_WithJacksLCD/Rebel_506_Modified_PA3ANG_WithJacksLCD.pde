/*
<Rebel_506_Alpha_Rev01, Basic Software to operate a 2 band QRP Transceiver.LCDFrequencyDisplay
             See PROJECT REBEL QRP below>
 This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.
 
This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.
 
You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/
//  http://groups.yahoo.com/group/TenTec506Rebel/
// !! Disclaimer !!  !! Disclaimer !!  !! Disclaimer !!  !! Disclaimer !!  !! Disclaimer !!
//  Attention ****  Ten-Tec Inc. is not responsile for any modification of Code 
//  below. If code modification is made, make a backup of the original code. 
//  If your new code does not work properly reload the factory code to start over again.
//  You are responsible for the code modifications you make yourself. And Ten-Tec Inc.
//  Assumes NO libility for code modification. Ten-Tec Inc. also cannot help you with any 
//  of your new code. There are several forums online to help with coding for the ChipKit UNO32.
//  If you have unexpected results after writing and programming of your modified code. 
//  Reload the factory code to see if the issues are still present. Before contacting Ten_Tec Inc.
//  Again Ten-Tec Inc. NOT RESPONSIBLE for modified code and cannot help with the rewriting of the 
//  factory code!
/*
/*********  PROJECT REBEL QRP  *****************************
  Program for the ChipKit Uno32
  This is a simple program to demonstrate a 2 band QRP Amateur Radio Transceiver
  Amateur Programmer Bill Curb (WA4CDM).
  This program will need to be cleaned up a bit!
  Compiled using the MPIDE for the ChipKit Uno32.

  Prog for ad9834
  Serial timming setup for AD9834 DDS
  start > Fsync is high (1), Sclk taken high (1), Data is stable (0, or 1),
  Fsync is taken low (0), Sclk is taken low (0), then high (1), data changes
  Sclk starts again.
  Control Register D15, D14 = 00, D13(B28) = 1, D12(HLB) = X,
  Reset goes high to set the internal reg to 0 and sets the output to midscale.
  Reset is then taken low to enable output. 
 ***************************************************   
 Notes: 11/29/2012  this works.     
        12/07/2012  TX and RX working.
        02/21/2013  Dual band and some other stuff working

  Need to add 100/1khz/10khz flash and the band edge stop to an led.
  DONE: LED to stay lit at band edges.
  Add RIT routine limits.
  RIT range +/- 500 hz. This is subject to change! Top center of RIT pot 
  will have a dead band area of around 24. Analog ADC 1024 -24 = 1000/2 = 500 
  DONE: Add Band stop limits. 40m ( 7.000 > 7.300 ), 20m ( 14.000 > 14.350 )
  Main tuning steps 100 hz ( DEFAULT ).
  Default to the calling frequency of 40m and 20m. 40 ( 7.030 ), 20m ( 14.060 )
  Comment out the lcd routine later used for eval.
  This is real basic code to get things working. 
  Lets add the LCD Routine to show the Ref freq and the output freq
 *****************************************************************
  * LCD RS pin to digital pin 26
  * LCD Enable pin to digital pin 27
  * LCD D4 pin to digital pin 28
  * LCD D5 pin to digital pin 29
  * LCD D6 pin to digital pin 30
  * LCD D7 pin to digital pin 31
  * LCD R/W pin to ground
  * 10K resistor:
  * ends to +5V and ground
  * wiper to LCD VO pin (pin 3)    analogWrite(Side_Tone, 127);
 *****************************************************************
  Ideas on the Function and Select buttons.
  DONE: FUNCTION button steps from BW ( green ) to STEP ( yellow ) to OTHER (red ).
    SELECT button steps from in 
    BW ( <Wide, green>, <Medium, yellow>, <Narrow, red> ).
    STEP ( <100 hz, green, <1Khz, yellow>, 10Khz, red> ).
    OTHER ( < , >, < , >, < , > ) OTHER has yet to be defined

  Default Band_width will be wide ( Green led lite ).
  When pressing the function button one of three leds will lite. 
  as explained above the select button will choose which setting will be used. 
  The Orange led in the Ten-Tec logo will flash to each step the STEP is set 
  too when tuning.  As it will also turn on when at the BAND edges.  
  Default frequency on power up will be the calling frequency of either the 
  40 meter or 20 meter band. Which is selected by the band shorting block. 
  Pins shorted 40M
  Calling Frequency for 40 meters is 7.030 mhz.
  Calling Frequency for 20 meters is 14.060 mhz.
  I.F. Frequency used is 9.0 mhz.
  DDS Range is: 
  40 meters will use HI side injection.
  9(I.F.) + 7(40m) = 16mhz.  9(I.F.) + 7.30 = 16.3 mhz.
  20 meters will use LO side injection.
  14(20m) - 9(I.F.) = 5mhz.  14.350(20m) - 9(I.F.) = 5.35 mhz.

  The Headphone jack can supply a headphone or speaker. The header pins(2) 
  if shorted will drive a speaker.
  Unshorted inserts 100 ohm resistors in series with the headphone to limit 
  the level to the headphones.

  The RIT knob will be at 0 offset in the Top Dead Center position. And will 
  go about -500 hz to +500 hz when turned to either extreme. Total range 
  about +/- 500 hz. This may change!

  The band jumpers should be relocated when changing bans the TX low pass are 
  to one side or the other.  And the Receive filters are the same.
  made so changes to the BW control lines. need to rewrite so BW will 
  cycle according to the Function/Select idea.

  Added the Band_Stop and Flash led to the Schematic, need to write code to 
  reflect this.

  Thinking about using switch/case routines for the Function/Select. Also the 
  previous settings from BW/STEP/OTHER should be remembered when cycling 
  through the Function/Select routine. If any of this makes sense!

  As the code looks now I have more than likely left out several items!
  RIT is missing. Flash/Band edge is missing. Function/Select is missing. Etc.
  Need to update lcd only when encoder moved or buttons are pressed.
  
  March 19, 2013 got the function/select routines working. Now to copy the 
  code to this main program and get everything intergrated. Whew!!!!
  
  March 20, 2013. First day of Spring. Got the function/select routines 
  intergrated into program! Works!  Had to tweek on the delays a bit.  Still 
  need to tackle the DDS failure to come on without the encoder having to be 
  turned.
  Also need to get a routine that saves the current settings when powered down. 
  The list goes on and on!

  April 07, 2013. (AC7FK) Added serialDump routine to send information to host
  via the serial port (115200 bps).  The serialDump function is called once 
  per second.  Added calculation for loops per second and loop execution time.  
  Commented out the splash_RX_freq() function call to reduce execution time of 
  the main loop.  Simplifed IF frequency math by changing the sign of the IF
  based on the selected band at boot time.  General cleanup of whitespace
  and comments.
  
  
  April 11, 2013. (WA4CDM) Got the band edge led and frequency stops working.
  The Rebel will not operate out of Band now on RX or TX.
  Also got the RIT control separated from the TX frequency register.
  The Step_Flash routine works. Whenever the encoder is turned the led will flash.
  This will help to calculate the operating frequency when in 100 hz, 1khz or 10khz.
  
  April 23, 2013. Rit was looked into to remove the scratchy sound when Rit pot
  was turned. See the "void UpdateFreq(long freq)" routine.
  
  April 26, 2013. Modified Setup so the TX_OUT (Default_Settings) will be set to
  zero on power up. And set Band_End_Flash_led to zero.
  
  The pwm (Side_Tone 3) call was removed and that port was made to be a logic level.
  It will be used to provide an on/off signal for the hardware sidetone osc.
  
  May 1, 2013. (WA4CDM) Swapped the key lines in software. 
   TX_Dah  32    now  33
   TX_Dit  33    now  32
  
  May 15, 2013. (WA4CDM) This Rev(01) for posting on Yahoo users group.
  
  Release Date to Production 7/15/2013
*/

/* September 15, 2013 (KD8FJO) Added Optional feature selection.  Under Optional features uncomment the features you need. 
   Paul - KD8FJO
  */

/* September 15, 2013. (K4JK) Added simple IAMBIC keyer. Code adapted from openqrp.org.
  Speed can be changed by changing the argument to the loadWPM() function in setup().
  Mode set to IAMBICB by default.
  For comments or questions please use the Ten Tec yahoo group or email k4jk@arrl.net
  
  You can also use a straight key. Just connect it at startup and keyer routine will use this mode.
  
  You can also hold down either paddle lever at startup to enter straight key mode. This will
  allow you to emulate a straight key with one of the paddle levers.
  
  73, James - K4JK
  */

/* September 22, 2013. (PA3ANG) Added Beacon. Can be activated by entering U3 in USER menu. 
  Remember to adjust to the beacon frequency before.
  The beacon is activated by selecting U3 en leaving the USER menu!
  The beacon can be stopped by unselecting U3 during the delay.
  The speed and delay can be adjusted in the setup area.
  Make sure to change the beacon text before you compile.
  */
  
  
// various defines
#define SDATA_BIT                           10          //  keep!
#define SCLK_BIT                            8           //  keep!
#define FSYNC_BIT                           9           //  keep!
#define RESET_BIT                           11          //  keep!
#define FREQ_REGISTER_BIT                   12          //  keep!
#define AD9834_FREQ0_REGISTER_SELECT_BIT    0x4000      //  keep!
#define AD9834_FREQ1_REGISTER_SELECT_BIT    0x8000      //  keep!
#define FREQ0_INIT_VALUE                    0x01320000  //  ?

// flashes when button pressed  for testing  keep!
#define led                                 13   

#define Side_Tone                           3           // maybe to be changed to a logic control
                                                        // for a separate side tone gen
#define TX_Dah                              33          //  keep!
#define TX_Dit                              32          //  keep!
#define TX_OUT                              38          //  keep!

#define Band_End_Flash_led                  24          // // also this led will flash every 100/1khz/10khz is tuned
#define Band_Select                         41          // if shorting block on only one pin 20m(1) on both pins 40m(0)
#define Multi_Function_Button               2           //
#define Multi_function_Green                34          // For now assigned to BW (Band width)
#define Multi_function_Yellow               35          // For now assigned to STEP size
#define Multi_function_Red                  36          // For now assigned to USER

#define Select_Button                       5           // 
#define Select_Green                        37          // Wide/100/USER1
#define Select_Yellow                       39          // Medium/1K/USER2
#define Select_Red                          40          // Narrow/10K/USER3

#define Medium_A8                           22          // Hardware control of I.F. filter Bandwidth
#define Narrow_A9                           23          // Hardware control of I.F. filter Bandwidth

#define Wide_BW                             0           // About 2.1 KHZ
#define Medium_BW                           1           // About 1.7 KHZ
#define Narrow_BW                           2           // About 1 KHZ

#define Step_100_Hz                         0
#define Step_1000_hz                        1
#define Step_10000_hz                       2

#define  Other_1_user                       0           // 
#define  Other_2_user                       1           //
#define  Other_3_user                       2           //

//-------------------------------  SET OPTONAL FEATURES HERE  -------------------------------------------------------------
//#define FEATURE_DISPLAY              // LCD display support (include one of the interface and model options below)
//#define FEATURE_LCD_4BIT             // Classic LCD display using 4 I/O lines. **Working**
#define W9NMTW6DQ_DISPLAY 1            // Uses the Purdum-Kidder 2x16 LCD display
//#define FEATURE_I2C                  // I2C Support
//#define FEATURE_LCD_I2C_SSD1306      // If using an Adafruit 1306 I2C OLED Display. Use modified Adafruit libraries found here: github.com/pstyle/Tentec506/tree/master/lib/display  **Working**
//#define FEATURE_LCD_I2C_1602         // 1602 Display with I2C backpack interface. Mine required pull-up resistors (2.7k) on SDA/SCL **WORKING**
//#define FEATURE_CW_DECODER           // Not implemented yet.
#define FEATURE_KEYER                // Keyer based on code from OpenQRP.org. **Working**
#define FEATURE_BEACON               // Use USER Menu 3 to Activate.  Make sure to change the Beacon text below! **Working**
#define FEATURE_SERIAL               // Enables serial output.  Only used for debugging at this point.  **Working**
//#define FEATURE_BANDSWITCH           // Software based Band Switching.  Not implemented yet.
#define FEATURE_SPEEDCONTROL         //Analog speed control (uses onboard trimpot connected to A7) **Working**


const int RitReadPin        = A0;  // pin that the sensor is attached to used for a rit routine later.
int RitReadValue            = 0;
int RitFreqOffset           = 0;

const int SmeterReadPin     = A1;  // To give a realitive signal strength based on AGC voltage.
int SmeterReadValue         = 0;

const int BatteryReadPin    = A2;  // Reads 1/5 th or 0.20 of supply voltage.
float BatteryReadValue     = 0;
float BatteryVconvert      = 0.01707;  //callibrated on 13.8v ps

const int PowerOutReadPin   = A3;  // Reads RF out voltage at Antenna.
int PowerOutReadValue       = 0;

const int CodeReadPin       = A6;  // Can be used to decode CW. 
int CodeReadValue           = 0;

const int CWSpeedReadPin    = A7;  // To adjust CW speed for user written keyer.
int CWSpeedReadValue        = 0;            
unsigned long       ditTime;                    // No. milliseconds per dit

#ifdef FEATURE_BEACON
// Simple Arduino CW Beacon Keyer
// Written by Mark VandeWettering K6HX

#define     BEACON          ("PA3ANG/BEACON JO32AM")           // Beacon text 
#define     CW_SPEED        15                                 // Beacon Speed    
#define     BEACON_DELAY    10                                 // in seconds
#define     N_MORSE  (sizeof(morsetab)/sizeof(morsetab[0]))    // Morse Table
#define     DOTLEN   (1200/CW_SPEED)                           // No. milliseconds per dit
#define     DASHLEN  (3*(1200/CW_SPEED))                       // CW weight  3.5 / 1   !! was 3.5*

//========= Added by W9NMT
#define     WORDSPACE (7 * DOTLEN)
#define     LETTERSPACE (2 * DOTLEN)
#define     SPECIALCHARACTERSPACE (4 * DOTLEN)


unsigned long  beaconStartTime    = 0;
unsigned long  beaconElapsedTime  = 0;
/*
// Morse table
struct t_mtab { char c, pat; } ;
struct t_mtab morsetab[] = {
  	{'.', 106},
	{',', 115},
	{'?', 76},
	{'/', 41},
	{'A', 6},
	{'B', 17},
	{'C', 21},
	{'D', 9},
	{'E', 2},
	{'F', 20},
	{'G', 11},
	{'H', 16},
	{'I', 4},
	{'J', 30},
	{'K', 13},
	{'L', 18},
	{'M', 7},
	{'N', 5},
	{'O', 15},
	{'P', 22},
	{'Q', 27},
	{'R', 10},
	{'S', 8},
	{'T', 3},
	{'U', 12},
	{'V', 24},
	{'W', 14},
	{'X', 25},
	{'Y', 29},
	{'Z', 19},
	{'1', 62},
	{'2', 60},
	{'3', 56},
	{'4', 48},
	{'5', 32},
	{'6', 33},
	{'7', 35},
	{'8', 39},
	{'9', 47},
	{'0', 63}
} ;
*/
#endif  // FEATURE_BEACON


// This table and the subsequent code were modified from the original code by Mark VandeWettering, K6HX

char letterTable[] = {
  0b101,              // A
  0b11000,            // B 
  0b11010,            // C
  0b1100,             // D
  0b10,               // E
  0b10010,            // F
  0b1110,             // G
  0b10000,            // H
  0b100,              // I
  0b10111,            // J
  0b1101,             // K
  0b10100,            // L
  0b111,              // M
  0b110,              // N
  0b1111,             // O
  0b10110,            // P
  0b11101,            // Q
  0b1010,             // R
  0b1000,             // S
  0b11,               // T
  0b1001,             // U
  0b10001,            // V
  0b1011,             // W
  0b11001,            // X
  0b11011,            // Y
  0b11100             // Z
};

// The coded byte values for numbers. 

char numberTable[] = {
  0b111111,           // 0
  0b101111,           // 1
  0b100111,           // 2
  0b100011,           // 3
  0b100001,           // 4
  0b100000,           // 5
  0b110000,           // 6
  0b111000,           // 7
  0b111100,           // 8
  0b111110            // 9
};



#ifndef FEATURE_SPEEDCONTROL
//-----------############  SET CW SPEED HERE (If you dont use the analog control)  #######-------------
int ManualCWSpeed = 15; //  <---- SET MANUAL CW SPEED HERE
#endif

#ifdef FEATURE_KEYER
//  keyerControl bit definitions
//
#define     DIT_L      0x01     // Dit latch
#define     DAH_L      0x02     // Dah latch
#define     DIT_PROC   0x04     // Dit is being processed
#define     PDLSWAP    0x08     // 0 for normal, 1 for swap
#define     IAMBICB    0x10     // 0 for Iambic A, 1 for Iambic B
// 
//Keyer Variables

unsigned char       keyerControl;
unsigned char       keyerState;
int ST_key = 0;        //This variable tells TX routine whether to enter use straight key mode
enum KSTYPE {IDLE, CHK_DIT, CHK_DAH, KEYED_PREP, KEYED, INTER_ELEMENT };

#endif // FEATURE_KEYER

#ifdef FEATURE_DISPLAY

const char txt3[8]          = "100 HZ ";
const char txt4[8]          = "1 KHZ  ";
const char txt5[8]          = "10 KHZ ";
const char txt52[5]         = " ";
const char txt57[6]         = "FREQ:" ;
const char txt60[6]         = "STEP:";
const char txt62[4]         = "RX:";
const char txt64[5]         = "RIT:";
const char txt65[5]         = "Band";
const char txt66[4]         = "20M";
const char txt67[4]         = "40M";
const char txt68[4]         = "TX:";
const char txt69[3]         = "V:";
const char txt70[3]         = "S:";
const char txt71[5]         = "WPM:";
const char txt72[5]         = "PWR:";
const char txt73[7]         = "BEACON";
#endif  //FEATURE_DISPLAY

#ifdef FEATURE_LCD_4BIT
#include <LiquidCrystal.h>    //  Classic LCD Stuff
LiquidCrystal lcd(26, 27, 28, 29, 30, 31);      //  LCD Stuff
#endif //FEATURE_LCD_4BIT

#ifdef W9NMTW6DQ_DISPLAY

//#include <MorseEnDecoder.h>

#include <LiquidCrystal.h>    //  Classic LCD Stuff
//LiquidCrystal lcd(12, 11, 5, 4, 3, 2);          // Mapped to Jack & Dennis' LCD display
  LiquidCrystal lcd(26, 27, 28, 29, 30, 31);      //  LCD Stuff

#endif  // 16x2 display

#ifdef FEATURE_I2C
#include <Wire.h>  //I2C Library
#endif //FEATURE_I2C

#ifdef FEATURE_LCD_I2C_SSD1306  
#include <Adafruit_SSD1306.h>
#include <Adafruit_GFX.h>
#define OLED_RESET 4
Adafruit_SSD1306 display(OLED_RESET);
#endif //SSD1306

#ifdef FEATURE_LCD_I2C_1602  
#include <LiquidCrystal_I2C.h>
LiquidCrystal_I2C lcd(0x27,16,2);  // set the LCD address to 0x27 for a 16 chars and 2 line display
#endif //I2C_1602

int TX_key;

int band_sel;                               // select band 40 or 20 meter
int band_set;
int bsm;  

int Step_Select_Button          = 0;
int Step_Select_Button1         = 0;
int Step_Multi_Function_Button  = 0;
int Step_Multi_Function_Button1 = 0;

int Selected_BW                 = 0;    // current Band width 
                                        // 0= wide, 1 = medium, 2= narrow
int Selected_Step               = 0;    // Current Step
int Selected_Other              = 0;    // To be used for anything

//--------------------------------------------------------
// Encoder Stuff 
const int encoder0PinA          = 7;
const int encoder0PinB          = 6;

int val; 
int encoder0Pos                 = 0;
int encoder0PinALast            = LOW;
int n                           = LOW;

//------------------------------------------------------------
const long meter_40             = 16.03e6;      // IF + Band frequency, 
                                                // HI side injection 40 meter 
                                                // range 16 > 16.3 mhz
const long meter_20             = 5.06e6;       // Band frequency - IF, LOW 
                                                // side injection 20 meter 
                                                // range 5 > 5.35 mhz
const long Reference            = 49.99975e6;   // for ad9834 this may be 
                                                // tweaked in software to 
                                                // fine tune the Radio

long RIT_frequency;
long RX_frequency;
long TX_frequency;
long save_rec_frequency;
long frequency_step;
long frequency                  = 0;
long frequency_old              = 0;
long frequency_tune             = 0;
long frequency_default          = 0;
long fcalc;
long IF                         = 9.00e6;          //  I.F. Frequency


//------------------------------------------------------------
// Debug Stuff
unsigned long   loopCount       = 0;
unsigned long   lastLoopCount   = 0;
unsigned long   loopsPerSecond  = 0;
unsigned int    printCount      = 0;

unsigned long  loopStartTime    = 0;
unsigned long  loopElapsedTime  = 0;
float          loopSpeed        = 0;

unsigned long LastFreqWriteTime = 0;

#ifdef FEATURE_SERIAL
void    serialDump();
#endif //FEATURE_SERIAL

//------------------------------------------------------------
void Default_frequency();
void AD9834_init();
void AD9834_reset();
void program_freq0(long freq);
void program_freq1(long freq1);  // added 1 to freq
void UpdateFreq(long freq);

void led_on_off();

void Frequency_up();                        
void Frequency_down();                      
void TX_routine();
void RX_routine();
void Encoder();
void AD9834_reset_low();
void AD9834_reset_high();

void Band_Set_40M_20M();
void Band_40M_limits_led();
void Band_20M_limits_led();
void Step_Flash();
void RIT_Read();

void Multi_Function();          //
void Step_Selection();          // 
void Selection();               //
void Step_Multi_Function();     //

void MF_G();                    // Controls Function Green led
void MF_Y();                    // Controls Function Yellow led
void MF_R();                    // Controls Function Red led

void S_G();                     // Controls Selection Green led & 
                                // Band_Width wide, Step_Size 100, Other_1

void S_Y();                     // Controls Selection Green led & 
                                // Band_Width medium, Step_Size 1k, Other_2

void S_R();                     // Controls Selection Green led & 
                                // Band_Width narrow, Step_Size 10k, Other_3

void Band_Width_W();            //  A8+A9 low
void Band_Width_M();            //  A8 high, A9 low
void Band_Width_N();            //  A8 low, A9 high

void Step_Size_100();           //   100 hz step
void Step_Size_1k();            //   1 kilo-hz step
void Step_Size_10k();           //   10 kilo-hz step

void Other_1();                 //   user 1
void Other_2();                 //   user 2
void Other_3();                 //   user 3 


//-------------------------------------------------------------------- 
void clock_data_to_ad9834(unsigned int data_word);

//-------------------------------------------------------------------- 

/*
//********************************************* Jack Decoder Stuff ************

const int morseInPin = A6;
morseDecoder morseInput(morseInPin, MORSE_KEYER, MORSE_ACTIVE_LOW);
*/

void setup() 
{
    // these pins are for the AD9834 control
    pinMode(SCLK_BIT,               OUTPUT);    // clock
    pinMode(FSYNC_BIT,              OUTPUT);    // fsync
    pinMode(SDATA_BIT,              OUTPUT);    // data
    pinMode(RESET_BIT,              OUTPUT);    // reset
    pinMode(FREQ_REGISTER_BIT,      OUTPUT);    // freq register select

    //---------------  Encoder ------------------------------------
    pinMode (encoder0PinA,          INPUT);     // using optical for now
    pinMode (encoder0PinB,          INPUT);     // using optical for now 

    //---------------  Added by W9NMT ------------------------------------
    pinMode (CodeReadPin,           OUTPUT);    // Read A6
    
    //--------------------------------------------------------------
    pinMode (TX_Dit,                INPUT);     // Dit Key line 
    pinMode (TX_Dah,                INPUT);     // Dah Key line
    pinMode (TX_OUT,                OUTPUT);
    pinMode (Band_End_Flash_led,    OUTPUT);
    
    //-------------------------------------------------------------
    pinMode (Multi_function_Green,  OUTPUT);    // Band width
    pinMode (Multi_function_Yellow, OUTPUT);    // Step size
    pinMode (Multi_function_Red,    OUTPUT);    // Other
    pinMode (Multi_Function_Button, INPUT);     // Choose from Band width, Step size, Other

    //--------------------------------------------------------------
    pinMode (Select_Green,          OUTPUT);    //  BW wide, 100 hz step, other1
    pinMode (Select_Yellow,         OUTPUT);    //  BW medium, 1 khz step, other2
    pinMode (Select_Red,            OUTPUT);    //  BW narrow, 10 khz step, other3
    pinMode (Select_Button,         INPUT);     //  Selection form the above

    pinMode (Medium_A8,             OUTPUT);    // Hardware control of I.F. filter Bandwidth
    pinMode (Narrow_A9,             OUTPUT);    // Hardware control of I.F. filter Bandwidth
    
    pinMode (Side_Tone,             OUTPUT);    // sidetone enable

    Default_Settings();

    //---------------------------------------------------------------
#ifndef FEATURE_BANDSWITCH
    pinMode (Band_Select,           INPUT);     // Band select via Jumpers.
#endif

#ifdef FEATURE_BANDSWITCH
    pinMode (Band_Select,           OUTPUT);     // Used to control relays connected to fileter lines.
#endif

    AD9834_init();
    AD9834_reset();                             // low to high

    Band_Set_40_20M();
    //   Default_frequency();                   // what ever default is

    digitalWrite(TX_OUT,            LOW);       // turn off TX

    //--------------------------------------------------------------
    Step_Size_100();   // Change for other Step_Size default!
    for (int i=0; i <= 5e4; i++);  // small delay

    AD9834_init();
    AD9834_reset();

    encoder0PinALast = digitalRead(encoder0PinA);  
    //attachInterrupt(encoder0PinA, Encoder, CHANGE);
    //attachInterrupt(encoder0PinB, Encoder, CHANGE);
    attachCoreTimerService(TimerOverFlow);//See function at the bottom of the file.

#ifdef FEATURE_SERIAL
    Serial.begin(115200);
    Serial.println("Rebel Ready:");
#endif

#ifdef FEATURE_KEYER
    keyerState = IDLE;
    keyerControl = IAMBICB;      
    checkWPM();                 // Check CW Speed 
    
    //See if user wants to use a straight key
    if ((digitalRead(TX_Dah) == LOW) || (digitalRead(TX_Dit) == LOW)) {    //Is a lever pressed?
      ST_key = 1;      //If so, enter straight key mode
    }

#endif

#ifdef FEATURE_LCD_4BIT  //Initialize 4bit Display
//--------------------------------------------------------------
  lcd.begin(16, 4);                           // 20 chars 4 lines
                                              // or change to suit ones 
                                              // lcd display 
//--------------------------------------------------------------
#endif

#ifdef W9NMTW6DQ_DISPLAY
  lcd.begin(16, 2);    // Jack and Dennis display
  lcd.setCursor(4,0);
  lcd.print("TEN-TEC");
  lcd.setCursor(3,1);
  lcd.print("506 REBEL");
  delay(2000);
  lcd.clear();   // Clear Display
  
  //morseInput.setspeed(13);
#endif


#ifdef FEATURE_LCD_I2C_SSD1306	//Initialize SSD1306 Display
  // by default, we'll generate the high voltage from the 3.3v line internally! (neat!)
  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);  // initialize with the I2C addr 0x3C (for the 128x32)
  display.display(); // show splashscreen
  delay(2000);
  display.clearDisplay();   // clears the screen and buffer
#endif

#ifdef FEATURE_LCD_I2C_1602  //Initialize I2C 1602 Display
  lcd.init();                      // initialize the lcd 
  lcd.backlight();
  lcd.setCursor(4,0);
  lcd.print("TEN-TEC");
  lcd.setCursor(3,1);
  lcd.print("506 REBEL");
  delay(2000);
  lcd.clear();   // Clear Display
#endif

}   //    end of setup



//===================================================================
void Default_Settings()
{
    digitalWrite(Multi_function_Green,  HIGH);  // Band_Width
                                                // place control here

    digitalWrite(Multi_function_Yellow, LOW);   //
                                                // place control here

    digitalWrite(Multi_function_Red,    LOW);   //
                                                // place control here

    digitalWrite(Select_Green,          HIGH);  //  
    Band_Width_W();                             // place control here 

    digitalWrite(Select_Yellow,         LOW);   //
                                                // place control here

    digitalWrite(Select_Green,          LOW);   //
                                                // place control here
    digitalWrite (TX_OUT,               LOW);   

    digitalWrite(FREQ_REGISTER_BIT,     LOW);  //This is set to LOW so RX is not dead on power on        
                                                
    digitalWrite (Band_End_Flash_led,   LOW);

    digitalWrite (Side_Tone,            LOW);    
                                              

}

/*****
  This method uses the LCD display from Chapter 3 of the Purdum-Kidder book to
  display the Rebel receiving frequency. Jack Purdum, W9NMT/8, 9/20/2013
  
  Parameters:
    void
    
  Return value:
    void
*****/
void LCDFrequencyDisplay()
{
  char row1[17] = {'R', 'X', ':', ' '};
  char row2[17] = {'T', 'X', ':', ' '};
  char temp[17];
  char tail[] = {' ', 'M', 'h', 'z', '\0'};
  
  if (bsm == 1) {            // 20 meters
    row1[3] = '1';           // Display row 1
    row1[4] = '4';
    row1[5] = '.';          // Make sure we can treat as a string
    row1[6] = '\0';
    itoa((frequency_tune + IF), temp, 10);
    strcat(row1, &temp[2]);  
    strcat(row1, tail);    
    row2[3] = '1';           // Display row 1
    row2[4] = '4';
    row2[5] = '.';          // Make sure we can treat as a string
    row2[6] = '\0';
    itoa((frequency + IF), temp, 10);
    strcat(row2, &temp[2]);  
    strcat(row2, tail);    
  } else {                   // 40 meters
    row1[4] = '7';           // Display row 1
    row1[5] = '.';
    row1[6] = '\0';          // Make sure we can treat as a string
    itoa((frequency_tune + IF), temp, 10);
    strcat(row1, &temp[1]);  // Ignore the leading '7'
    strcat(row1, tail);    
    row2[4] = '7';           // Display row 2
    row2[5] = '.';
    row2[6] = '\0';          
    itoa((frequency + IF), temp, 10);
    strcat(row2, &temp[1]);  
    strcat(row2, tail);    
  }
  lcd.setCursor(0, 0);
  lcd.print(row1);  
  lcd.setCursor(0, 1);
  lcd.print(row2);
  //ST_key = 1;      // Uncomment for straight key
  
}
//======================= Main Part =================================
void loop()     // 
{

    digitalWrite(FSYNC_BIT,             HIGH);  // 
    digitalWrite(SCLK_BIT,              HIGH);  //

    RIT_Read();

    Multi_Function(); 

    Encoder();

    frequency_tune  = frequency + RitFreqOffset;
    UpdateFreq(frequency_tune);

    TX_routine();

    #ifdef FEATURE_BEACON
    if ( Selected_Other == 2 ) 
    {
      beaconElapsedTime = millis() - beaconStartTime; 
      if( (BEACON_DELAY *1000) <= beaconElapsedTime )
      {
        #ifdef FEATURE_LCD_4BIT
          TX_frequency = frequency + IF;
          lcd.setCursor(0,1);
          lcd.print(txt68); // TX
          lcd.setCursor(4,1);
          lcd.print(TX_frequency * 0.001);
          lcd.setCursor(14,1);
          lcd.print(txt81);
        #endif
        sendmsg(BEACON);
        beaconStartTime = millis();  //Reset the Timer for the beacon loop
        #ifdef FEATURE_LCD_4BIT
          lcd.setCursor(14,1);
          lcd.print(txt82);
        #endif
      }
    }
    #endif
    
    loopCount++;
    loopElapsedTime    = millis() - loopStartTime;    // comment this out to remove the one second tick
    
    // has 1000 milliseconds elasped?
    if( 1000 <= loopElapsedTime )
    {
        #ifdef FEATURE_KEYER
        checkWPM();
        #endif
      
        #ifdef FEATURE_SERIAL
        serialDump();
        #endif
        
        #ifdef FEATURE_DISPLAY
        Display_Refresh(); 
        #endif
        loopStartTime   = millis();
        
        #ifdef W9NMTW6DQ_DISPLAY
        LCDFrequencyDisplay();
        CodeReadValue = analogRead(A6);
        Serial.print("***************  CodeReadValue = ");
        Serial.println(CodeReadValue);
            Serial.print("ST-key = ");
    Serial.println(ST_key);

        #endif
    }
    /*
    morseInput.decode();
    if (morseInput.available()) {
      char receivedMorse = morseInput.read();
      Serial.print(receivedMorse);
    }
    */
}    //  END LOOP

#ifdef FEATURE_SERIAL
//===================================================================
//------------------ Debug data output ------------------------------
void    serialDump()
{
    loopsPerSecond  = loopCount - lastLoopCount;
    loopSpeed       = (float)1e6 / loopsPerSecond;
    lastLoopCount   = loopCount;

    Serial.print    ( "uptime: " );
    Serial.print    ( ++printCount );
    Serial.println  ( " seconds" );

    Serial.print    ( "loops per second:    " );
    Serial.println  ( loopsPerSecond );
    Serial.print    ( "loop execution time: " );
    Serial.print    ( loopSpeed, 3 );
    Serial.println  ( " uS" );

    Serial.print    ( "Freq Rx: " );
    Serial.println  ( frequency_tune + IF );
    Serial.print    ( "Freq Tx: " );
    Serial.println  ( frequency + IF );
    
    #ifdef FEATURE_KEYER
    Serial.print    ( "CW speed:" );
    Serial.println  ( CWSpeedReadValue );
    Serial.println  ();
    #endif
    
} // end serialDump()
#endif //FEATURE_SERIAL

#ifndef FEATURE_BANDSWITCH
//------------------ Band Select ------------------------------------
void Band_Set_40_20M()
{
    bsm = digitalRead(Band_Select); 

    //  select 40 or 20 meters 1 for 20 0 for 40
    if ( bsm == 1 ) 
    { 
        frequency_default = meter_20;
    }
    else 
    { 
        frequency_default = meter_40; 
        IF *= -1;               //  HI side injection
    }

    Default_frequency();
}

#endif

#ifdef FEATURE_BANDSWITCH
//------------------ Software Band Select ------------------------------------

void Band_Set_40_20M()
{
     

    //  select 40 or 20 meters 1 for 20 0 for 40
    if ( bsm == 1 ) 
    { 
        frequency_default = meter_20;
        digitalWrite(Band_Select,LOW);
    }
    else 
    { 
        frequency_default = meter_40; 
        IF *= -1;               //  HI side injection
        digitalWrite(Band_Select,HIGN);
    }

    Default_frequency();
}

#endif

//--------------------------- Encoder Routine ----------------------------  
void Encoder()
{  
    n = digitalRead(encoder0PinA);
    if ((encoder0PinALast == LOW) && (n == HIGH)) 
    {
        if (digitalRead(encoder0PinB) == LOW) 
        {
            Frequency_down();    //encoder0Pos--;
        } else 
        {
            Frequency_up();       //encoder0Pos++;
        }
    } 
    encoder0PinALast = n;
}
//----------------------------------------------------------------------
void Frequency_up()
{ 
    frequency = frequency + frequency_step;
    
    Step_Flash();
    
#ifndef FEATURE_BANDSWITCH
    bsm = digitalRead(Band_Select); 
#endif

     if ( bsm == 1 ) { Band_20_Limit_High(); }
     else if ( bsm == 0 ) {  Band_40_Limit_High(); }
 
}

//------------------------------------------------------------------------------  
void Frequency_down()
{ 
    frequency = frequency - frequency_step;
    
    Step_Flash();
    
#ifndef FEATURE_BANDSWITCH
    bsm = digitalRead(Band_Select); 
#endif

     if ( bsm == 1 ) { Band_20_Limit_Low(); }
     else if ( bsm == 0 ) {  Band_40_Limit_Low(); }
 
}
//-------------------------------------------------------------------------------
void UpdateFreq(long freq)
{
    long freq1;
//  some of this code affects the way to Rit responds to being turned
    if (LastFreqWriteTime != 0)
    { if ((millis() - LastFreqWriteTime) < 100) return; }
    LastFreqWriteTime = millis();

    if(freq == frequency_old) return;

    //Serial.print("Freq: ");
    //Serial.println(freq);

    program_freq0( freq  );
            
#ifndef FEATURE_BANDSWITCH
    bsm = digitalRead(Band_Select); 
#endif
    
    freq1 = freq - RitFreqOffset;  //  to get the TX freq

    program_freq1( freq1 + IF  );
  
    frequency_old = freq;
}


#ifndef FEATURE_KEYER
//---------------------  TX Routine  ------------------------------------------------  
void TX_routine()
{
    TX_key = digitalRead(TX_Dit);
    if ( TX_key == LOW)         // was high   
    {
        //   (FREQ_REGISTER_BIT, HIGH) is selected   
        do
        {
            digitalWrite(FREQ_REGISTER_BIT, HIGH);
            digitalWrite(TX_OUT, HIGH);
            digitalWrite(Side_Tone, HIGH);
            TX_key = digitalRead(TX_Dit);
        } while (TX_key == LOW);   // was high 
        //PowerOutReadValue = analogRead(PowerOutReadpin); 
        digitalWrite(TX_OUT, LOW);  // trun off TX
        for (int i=0; i <= 10e3; i++); // delay for maybe some decay on key release

        digitalWrite(FREQ_REGISTER_BIT, LOW);
        digitalWrite(Side_Tone, LOW);
    }
}
#endif

#ifdef FEATURE_KEYER
//---------------------  TX Routine  ------------------------------------------------  
// Will detect straight key at startup.
// James - K4JK

void TX_routine()
{

 if (ST_key == 1) { // is ST_Key is set to YES? Then use Straight key mode
 
   TX_key = digitalRead(TX_Dit);
    if ( TX_key == LOW)         // was high   
    {
        //   (FREQ_REGISTER_BIT, HIGH) is selected      
        
        do
        {
            digitalWrite(FREQ_REGISTER_BIT, HIGH);
            digitalWrite(TX_OUT, HIGH);
            digitalWrite(Side_Tone, HIGH);
            TX_key = digitalRead(TX_Dit);
        } while (TX_key == LOW);   // was high 

        digitalWrite(TX_OUT, LOW);  // turn off TX
        for (int i=0; i <= 10e3; i++); // delay for maybe some decay on key release
        digitalWrite(FREQ_REGISTER_BIT, LOW);
        digitalWrite(Side_Tone, LOW);
        loopStartTime = millis();//Reset the Timer for this loop
    }
 } 
   else {    //If ST_key is not 1, then use IAMBIC
  
  static long ktimer;
  
  // Basic Iambic Keyer
  // keyerControl contains processing flags and keyer mode bits
  // Supports Iambic A and B
  // State machine based, uses calls to millis() for timing.
  // Code adapted from openqrp.org
 
  switch (keyerState) {
    case IDLE:
        // Wait for direct or latched paddle press
        if ((digitalRead(TX_Dit) == LOW) ||
                (digitalRead(TX_Dah) == LOW) ||
                    (keyerControl & 0x03)) {
            update_PaddleLatch();
            keyerState = CHK_DIT;
        }
        break;

    case CHK_DIT:
        // See if the dit paddle was pressed
        if (keyerControl & DIT_L) {
            keyerControl |= DIT_PROC;
            ktimer = ditTime;
            keyerState = KEYED_PREP;
        }
        else {
            keyerState = CHK_DAH;
        }
        break;
        
    case CHK_DAH:
        // See if dah paddle was pressed
        if (keyerControl & DAH_L) {
            ktimer = ditTime*3;
            keyerState = KEYED_PREP;
        }
        else {
            keyerState = IDLE;
        }
        break;
        
    case KEYED_PREP:
        // Assert key down, start timing, state shared for dit or dah
        digitalWrite(FREQ_REGISTER_BIT, HIGH);
        digitalWrite(TX_OUT, HIGH);         // key the line
        digitalWrite(Side_Tone, HIGH);      // Tone
        ktimer += millis();                 // set ktimer to interval end time
        keyerControl &= ~(DIT_L + DAH_L);   // clear both paddle latch bits
        keyerState = KEYED;                 // next state
        break;
        
    case KEYED:
        // Wait for timer to expire
        if (millis() > ktimer) {            // are we at end of key down ?
            digitalWrite(TX_OUT, LOW);      // turn the key off
            for (int i=0; i <= 10e3; i++); // delay for maybe some decay on key release
            digitalWrite(FREQ_REGISTER_BIT, LOW);
            digitalWrite(Side_Tone, LOW);
            ktimer = millis() + ditTime;    // inter-element time
            keyerState = INTER_ELEMENT;     // next state
        }
        else if (keyerControl & IAMBICB) {
            update_PaddleLatch();           // early paddle latch in Iambic B mode
        }
        break; 
 
    case INTER_ELEMENT:
        // Insert time between dits/dahs
        update_PaddleLatch();               // latch paddle state
        if (millis() > ktimer) {            // are we at end of inter-space ?
            if (keyerControl & DIT_PROC) {             // was it a dit or dah ?
                keyerControl &= ~(DIT_L + DIT_PROC);   // clear two bits
                keyerState = CHK_DAH;                  // dit done, check for dah
            }
            else {
                keyerControl &= ~(DAH_L);              // clear dah latch
                keyerState = IDLE;                     // go idle
                loopStartTime = millis();//Reset the Timer for this loop
            }
        }
        break;
  }
 }

}

///////////////////////////////////////////////////////////////////////////////
//
//    Latch dit and/or dah press
//
//    Called by keyer routine
//
///////////////////////////////////////////////////////////////////////////////
 
void update_PaddleLatch()
{
    if (digitalRead(TX_Dit) == LOW) {
        keyerControl |= DIT_L;
    }
    if (digitalRead(TX_Dah) == LOW) {
        keyerControl |= DAH_L;
    }
}
 
///////////////////////////////////////////////////////////////////////////////
//
//    Calculate new time constants based on wpm value
//
///////////////////////////////////////////////////////////////////////////////
#endif

void loadWPM(int wpm)
{
    ditTime = 1200/wpm;
}

#ifdef FEATURE_SPEEDCONTROL
void checkWPM() //Checks the Keyer speed Pot and updates value
{
   CWSpeedReadValue = analogRead(CWSpeedReadPin);
   CWSpeedReadValue = map(CWSpeedReadValue, 0, 1024, 5, 45);
   loadWPM(CWSpeedReadValue);
}
#endif

#ifndef FEATURE_SPEEDCONTROL
void checkWPM() //Assign Speed manually
{
  CWSpeedReadValue =  ManualCWSpeed;
  loadWPM(CWSpeedReadValue);
}
#endif

#ifdef FEATURE_BEACON

// CW generation routines for Beacon and Memory 
void key(int LENGTH) {
  digitalWrite(FREQ_REGISTER_BIT, HIGH);
  digitalWrite(TX_OUT, HIGH);          // key the line
  digitalWrite(Side_Tone, HIGH);       // Tone
  delay(LENGTH);
  digitalWrite(TX_OUT, LOW);           // turn the key off
  //for (int i=0; i <= 10e3; i++);       // delay for maybe some decay on key release
  digitalWrite(FREQ_REGISTER_BIT, LOW);
  digitalWrite(Side_Tone, LOW);
  delay(DOTLEN) ;
}
/*
void send(char c) {
  int i ;
  if (c == ' ') {
//    delay(7*DOTLEN) ;    // Word length
    delay(WORDSPACE);
    return ;
  }
  if (c == '+') {
    //delay(4*DOTLEN) ; 
    delay(SPECIALCHARACTERSPACE);
    key(DOTLEN);
    key(DASHLEN);
    key(DOTLEN);
    key(DASHLEN);
    key(DOTLEN);
    //delay(4*DOTLEN) ; 
    delay(SPECIALCHARACTERSPACE);
    return ;
  }    
    
  for (i=0; i<N_MORSE; i++) {              // Looks through Morse table; brute force
    if (morsetab[i].c == c) {              // If match...
      unsigned char p = morsetab[i].pat ;  
      while (p != 1) {                     // while p isn't one...
          if (p & 1)                       // AND the bits
            key(DASHLEN) ;
          else
            key(DOTLEN) ;
          p = p / 2 ;                      // Why not shift right 1 position?
          }
      //delay(2*DOTLEN) ;                    // Letter pause
      delay(LETTERSPACE);
      return ;
      }
  }
}
*/
void sendmsg(char *str) {
  while (*str)
    send(*str++) ;
}
#endif FEATURE_BEACON
//************************** ORIGIANL CODE ***********************

//--------------------------------- New Code W9NMT ------------------------------
/*****
 * This method translates and sends the character.
 * 
 * Parameters:
 * char ch      the character to be translated and sent
 * 
 * Return value:
 * void
 *****/

void send(char ch)
{
  int index;

  if (isalpha(ch)) {
    index = toupper(ch) - 'A';     // Calculate an index into the letter array if a letter...
    sendcode(letterTable[index]);
  } 
  else if (isdigit(ch))
    sendcode(numberTable[ch-'0']);        // Calculate an index into the numbers table if a number...
  else if (ch == ' ' || ch == '\r' || ch == '\n')
    space();
  else {
    switch (ch) {                  // Punctuation and special characters
    case '.':
      sendcode(0b1010101);
      break;
    case ',':
      sendcode(0b1110011);
      break;
    case  '!':
      sendcode(0b1101011);
      break;
    case  '?':
      sendcode(0b1001100);
      break;
    case  '/':
      sendcode(0b110010);
      break;
    case  '+':
      sendcode(0b101010);
      break;
    case  '-':
      sendcode(0b1100001);
      break;
    case  '=':
      sendcode(0b110001);
      break;
    case  '@':               
      sendcode(0b1011010);
      break;
    default:
      break;
    }
  }
}


/*****
 * This method generates the necessary dits and dahs for a particular code.
 * 
 * Parameters:
 * char code    the byte code for the letter or number to be sent as take from the ltab[] or ntab[] arrays.
 * 
 * Return value:
 * void
 *****/
 
void sendcode(char code)
{
  int i;

  for (i=7; i>= 0; i--) {    // This loop searches for the first 1 bit, starting with the high bit
    if (code & (1 << i))
      break;
  }
  for (i--; i>= 0; i--) {    // What follows the high bit is the dits (0) and dahs (1) for each character
    if (code & (1 << i))
      key(DASHLEN);
    else
      key(DOTLEN);
  }
  key(LETTERSPACE);
}


/*****
 * This method generates a delay that separates words in Morse Code.
 * 
 * Parameters:
 * void
 * 
 * Return value:
 * void
 *****/
 
void space()
{
  key(SPECIALCHARACTERSPACE);  // 4 * dit length

}

//----------------------------------------- End W9NMT Code --------------

//*************************************************************************/


//----------------------------------------------------------------------------
void RIT_Read()
{
    int RitReadValueNew =0 ;


    RitReadValueNew = analogRead(RitReadPin);
    RitReadValue = (RitReadValueNew + (7 * RitReadValue))/8;//Lowpass filter

    if(RitReadValue < 500) 
        RitFreqOffset = RitReadValue-500;
    else if(RitReadValue < 523) 
        RitFreqOffset = 0;//Deadband in middle of pot
    else 
        RitFreqOffset = RitReadValue - 523;

}

//-------------------------------------------------------------------------------

 void  Band_40_Limit_High()
    {
         if ( frequency < 16.3e6 )
    { 
         stop_led_off();
    } 
    
    else if ( frequency >= 16.3e6 )
    { 
       frequency = 16.3e6;
         stop_led_on();    
    }
    }
//-------------------------------------------------------    
 void  Band_40_Limit_Low()
    {
        if ( frequency <= 16.0e6 )  
    { 
        frequency = 16.0e6;
        stop_led_on();
    } 
    
    else if ( frequency > 16.0e6 )
    { 
       stop_led_off();
    } 
    }
//---------------------------------------------------------    
 void  Band_20_Limit_High()
    {
         if ( frequency < 5.35e6 )
    { 
         stop_led_off();
    } 
    
    else if ( frequency >= 5.35e6 )
    { 
       frequency = 5.35e6;
         stop_led_on();    
    }
    }
//-------------------------------------------------------    
 void  Band_20_Limit_Low()
    {
        if ( frequency <= 5.0e6 )  
    { 
        frequency = 5.0e6;
        stop_led_on();
    } 
    
    else if ( frequency > 5.0e6 )
    { 
        stop_led_off();
    } 
    }

//--------------------Default Frequency-----------------------------------------
void Default_frequency()
{
    frequency = frequency_default;
    UpdateFreq(frequency);

    //*************************************************************************
}   //  end   Default_frequency


#ifdef FEATURE_LCD_4BIT
//------------------------Display Stuff below-----------------------------------

void Display_Refresh()  //LCD_4Bit Version - Cleaned up, added more Info and tested. - K4JK
{
#ifndef FEATURE_BANDSWITCH
    bsm = digitalRead(Band_Select); 
#endif
//BAND Info top line
    if ( bsm == 1 ) 
    {
        lcd.setCursor(17, 0);
        lcd.print(txt66);
    }
    else 
    {
        lcd.setCursor(17, 0);
        lcd.print(txt67);
    } 
//QSX    
    RX_frequency = frequency_tune + IF;
    TX_frequency = frequency + IF;
    //lcd.clear();   // Clear Display
    lcd.setCursor(0,1);
    lcd.print(txt62); // RX
    lcd.setCursor(4,1);
    lcd.print(RX_frequency * 0.001);
//RIT
    lcd.setCursor(14, 1);
    lcd.print("     ");
    if (RitFreqOffset < 0) {
      lcd.setCursor(14, 1);
    } else {
      lcd.setCursor(15, 1);
    }      
    lcd.print(RitFreqOffset);
//QRG
    //lcd.setCursor(0,1);	
    //lcd.print(txt68); // TX
    //lcd.setCursor(4,1);
    //lcd.print(TX_frequency * 0.001);
// DC Volts In
    lcd.setCursor(0,2);
    lcd.print(txt69); // V
    BatteryReadValue = analogRead(BatteryReadPin)* BatteryVconvert;
    lcd.setCursor(4,2);
    lcd.print(BatteryReadValue);
//S Meter 
    lcd.setCursor(0,3);
    lcd.print(txt70); // S
    SmeterReadValue = analogRead(SmeterReadPin);
    SmeterReadValue = map(SmeterReadValue, 0, 180, 0, 9);
    lcd.setCursor(4,3);
    lcd.print(SmeterReadValue);
// CW Speed - Moved this over past the S meter on the fourth line
    #ifdef FEATURE_KEYER //Did user enable keyer function?
      if(ST_key == 0) {  //Did they also plug a paddle in? (or at least NOT plug in a straight key?)
      lcd.setCursor(11,3);	
      lcd.print(txt71); // WPM
      lcd.setCursor(15,3);
      lcd.print(CWSpeedReadValue);
      }
    #endif
 
 }

#endif //FEATURE_LCD_4BIT

#ifdef FEATURE_LCD_I2C_SSD1306  
//------------------------Display Stuff below-----------------------------------
void Display_Refresh()  //SSD1306 I2C OLED Version
{
#ifndef FEATURE_BANDSWITCH
    bsm = digitalRead(Band_Select); 
#endif
     
    RX_frequency = frequency_tune + IF;
    TX_frequency = frequency + IF;
    display.clearDisplay();   // clears the screen and buffer
    display.setTextSize(1);
    display.setTextColor(WHITE);
    display.setCursor(3,3);
    display.print(txt62); // RX
    display.setCursor(20,3);
    display.print(RX_frequency * 0.001);

    display.setCursor(3,12);	
    display.print(txt68); // TX
    display.setCursor(20,12);
    display.print(TX_frequency * 0.001);
      
    display.setCursor(75,12);
    display.print(txt69); // V
    BatteryReadValue = analogRead(BatteryReadPin)* BatteryVconvert;
    display.setCursor(88,12);
    display.print(BatteryReadValue);

    display.setCursor(75,3);
    display.print(txt70); // S
    SmeterReadValue = analogRead(SmeterReadPin);
    SmeterReadValue = map(SmeterReadValue, 0, 180, 0, 9);
    display.setCursor(88,3);
    display.print(SmeterReadValue);
    
    display.drawRect(0, 0, display.width(), display.height(), WHITE);
    
    #ifdef FEATURE_KEYER  //Did user enable keyer function?
      if(ST_key == 0) {   //Did they also plug a paddle in? (or at least NOT plug in a straight key?)
    display.setCursor(3,21);
    display.print(txt71); // WPM
    display.setCursor(30,21);
    display.print(CWSpeedReadValue);
      }
    #endif

  //  display.setCursor(45,21);	
  //  display.print(txt72); // PWR
  //  display.setCursor(70,21);
  //  display.print(PowerOutReadValue);
    
    display.display();
 }
#endif

#ifdef FEATURE_LCD_I2C_1602

//------------------------Display Stuff below-----------------------------------

void Display_Refresh()  //LCD_I2C_1602 version
{
#ifndef FEATURE_BANDSWITCH
    bsm = digitalRead(Band_Select); 
#endif
//QSX    
    RX_frequency = frequency_tune + IF;
    TX_frequency = frequency + IF;
    //lcd.clear();   // Clear Display
    lcd.setCursor(0,0);
    lcd.print("R:"); // RX
    lcd.setCursor(2,0);
    lcd.print(RX_frequency * 0.001);
//QRG
    lcd.setCursor(0,1);	
    lcd.print("T:"); // TX
    lcd.setCursor(2,1);
    lcd.print(TX_frequency * 0.001);
// DC Volts In
    lcd.setCursor(10,0);
    lcd.print(txt69); // V
    BatteryReadValue = analogRead(BatteryReadPin)* BatteryVconvert;
    lcd.setCursor(12,0);
    lcd.print(BatteryReadValue);
//S Meter 
    lcd.setCursor(10,1);
    lcd.print("S"); // S
    SmeterReadValue = analogRead(SmeterReadPin);
    SmeterReadValue = map(SmeterReadValue, 0, 180, 0, 9);
    lcd.setCursor(11,1);
    lcd.print(SmeterReadValue);
// CW Speed - Moved this over past the S meter on the 2nd line
    #ifdef FEATURE_KEYER //Did user enable keyer function?
      if(ST_key == 0) {  //Did they also plug a paddle in? (or at least NOT plug in a straight key?)
      lcd.setCursor(13,1);	
      lcd.print("W"); // WPM
      lcd.setCursor(14,1);
      lcd.print(CWSpeedReadValue);
      }
    #endif
 
 }
#endif //FEATURE_LCD_I2C_1602

//--------------------------------------------------------------------------  

void Step_Flash()
{
    stop_led_on();
    
    for (int i=0; i <= 25e3; i++); // short delay 
    
    stop_led_off();   
}

//-----------------------------------------------------------------------------
void stop_led_on()
{
    digitalWrite(Band_End_Flash_led, HIGH);
}

//-----------------------------------------------------------------------------
void stop_led_off()
{
    digitalWrite(Band_End_Flash_led, LOW);
}

//===================================================================
void Multi_Function() // The right most pushbutton for BW, Step, Other
{
    Step_Multi_Function_Button = digitalRead(Multi_Function_Button);
    if (Step_Multi_Function_Button == HIGH) 
    {   
       while( digitalRead(Multi_Function_Button) == HIGH ){ }  // added for testing
        for (int i=0; i <= 150e3; i++); // short delay

        Step_Multi_Function_Button1 = Step_Multi_Function_Button1++;
        if (Step_Multi_Function_Button1 > 2 ) 
        { 
            Step_Multi_Function_Button1 = 0; 
        }
    }
    Step_Function();
}


//-------------------------------------------------------------  
void Step_Function()
{
    switch ( Step_Multi_Function_Button1 )
    {
        case 0:
            MF_G();
            Step_Select_Button1 = Selected_BW; // 
            Step_Select(); //
            Selection();
            for (int i=0; i <= 255; i++); // short delay

            break;   //

        case 1:
            MF_Y();
            Step_Select_Button1 = Selected_Step; //
            Step_Select(); //
            Selection();
            for (int i=0; i <= 255; i++); // short delay

            break;   //

        case 2: 
            MF_R();
            Step_Select_Button1 = Selected_Other; //
            Step_Select(); //
            Selection();
            for (int i=0; i <= 255; i++); // short delay

            break;   //  
    }
}


//===================================================================
void  Selection()
{
    Step_Select_Button = digitalRead(Select_Button);
    if (Step_Select_Button == HIGH) 
    {   
       while( digitalRead(Select_Button) == HIGH ){ }  // added for testing
        for (int i=0; i <= 150e3; i++); // short delay

        Step_Select_Button1 = Step_Select_Button1++;
        if (Step_Select_Button1 > 2 ) 
        { 
            Step_Select_Button1 = 0; 
        }
    }
    Step_Select(); 
}


//-----------------------------------------------------------------------  
void Step_Select()
{
    switch ( Step_Select_Button1 )
    {
        case 0: //   Select_Green   could place the S_G() routine here!
            S_G();
            break;

        case 1: //   Select_Yellow  could place the S_Y() routine here!
            S_Y();
            break; 

        case 2: //   Select_Red    could place the S_R() routine here!
            S_R();
            break;     
    }
}



//----------------------------------------------------------- 
void MF_G()    //  Multi-function Green 
{
    digitalWrite(Multi_function_Green, HIGH);    
    digitalWrite(Multi_function_Yellow, LOW);  // 
    digitalWrite(Multi_function_Red, LOW);  //
    for (int i=0; i <= 255; i++); // short delay   
}



void MF_Y()   //  Multi-function Yellow
{
    digitalWrite(Multi_function_Green, LOW);    
    digitalWrite(Multi_function_Yellow, HIGH);  // 
    digitalWrite(Multi_function_Red, LOW);  //
    for (int i=0; i <= 255; i++); // short delay 
}



void MF_R()   //  Multi-function Red
{
    digitalWrite(Multi_function_Green, LOW);
    digitalWrite(Multi_function_Yellow, LOW);  // 
    digitalWrite(Multi_function_Red, HIGH);
    for (int i=0; i <= 255; i++); // short delay  
}


//============================================================  
void S_G()  // Select Green 
{
    digitalWrite(Select_Green, HIGH); 
    digitalWrite(Select_Yellow, LOW);  // 
    digitalWrite(Select_Red, LOW);  //
    if (Step_Multi_Function_Button1 == 0)  
        Band_Width_W(); 
    else if (Step_Multi_Function_Button1 == 1)  
        Step_Size_100(); 
    else if (Step_Multi_Function_Button1 == 2)  
        Other_1(); 

    for (int i=0; i <= 255; i++); // short delay   
}



void S_Y()  // Select Yellow
{
    digitalWrite(Select_Green, LOW); 
    digitalWrite(Select_Yellow, HIGH);  // 
    digitalWrite(Select_Red, LOW);  //
    if (Step_Multi_Function_Button1 == 0) 
    {
        Band_Width_M();
    } 
    else if (Step_Multi_Function_Button1 == 1) 
    {
        Step_Size_1k(); 
    }
    else if (Step_Multi_Function_Button1 == 2) 
    {
        Other_2();
    }

    for (int i=0; i <= 255; i++); // short delay   
}



void S_R()  // Select Red
{
    digitalWrite(Select_Green, LOW);   //
    digitalWrite(Select_Yellow, LOW);  // 
    digitalWrite(Select_Red, HIGH);    //
    if (Step_Multi_Function_Button1 == 0) 
    {
        Band_Width_N();
    } 
    else if (Step_Multi_Function_Button1 == 1) 
    {
        Step_Size_10k(); 
    }
    else if (Step_Multi_Function_Button1 == 2) 
    {
        Other_3(); 
    }

    for (int i=0; i <= 255; i++); // short delay
}

//----------------------------------------------------------------------------------
void Band_Width_W()
{
    digitalWrite( Medium_A8, LOW);   // Hardware control of I.F. filter shape
    digitalWrite( Narrow_A9, LOW);   // Hardware control of I.F. filter shape
    Selected_BW = Wide_BW; 
}


//----------------------------------------------------------------------------------  
void Band_Width_M()
{
    digitalWrite( Medium_A8, HIGH);  // Hardware control of I.F. filter shape
    digitalWrite( Narrow_A9, LOW);   // Hardware control of I.F. filter shape
    Selected_BW = Medium_BW;  
}


//----------------------------------------------------------------------------------  
void Band_Width_N()
{
    digitalWrite( Medium_A8, LOW);   // Hardware control of I.F. filter shape
    digitalWrite( Narrow_A9, HIGH);  // Hardware control of I.F. filter shape
    Selected_BW = Narrow_BW; 
}


//---------------------------------------------------------------------------------- 
void Step_Size_100()      // Encoder Step Size 
{
    frequency_step = 100;   //  Can change this whatever step size one wants
    Selected_Step = Step_100_Hz; 
}


//----------------------------------------------------------------------------------  
void Step_Size_1k()       // Encoder Step Size 
{
    frequency_step = 1e3;   //  Can change this whatever step size one wants
    Selected_Step = Step_1000_hz; 
}


//----------------------------------------------------------------------------------  
void Step_Size_10k()      // Encoder Step Size 
{
    frequency_step = 10e3;    //  Can change this whatever step size one wants
    Selected_Step = Step_10000_hz; 
}


//---------------------------------------------------------------------------------- 
void Other_1()      //  User Defined Control Software 
{
    Selected_Other = Other_1_user; 
}


//----------------------------------------------------------------------------------  
void Other_2()      //  User Defined Control Software
{
    Selected_Other = Other_2_user; 
}

//----------------------------------------------------------------------------------  
void Other_3()       //  User Defined Control Software
{
    #ifdef FEATURE_BEACON
	// Place Rebel into BEACON mode
    beaconStartTime = millis() - ((BEACON_DELAY-2)*1000);  //Start Beacon after 2 seconds leaving the USER menu
	#endif

	Selected_Other = Other_3_user;
}

//-----------------------------------------------------------------------------
uint32_t TimerOverFlow(uint32_t currentTime)
{

    return (currentTime + CORE_TICK_RATE*(1));//the Core Tick Rate is 1ms

}

//-----------------------------------------------------------------------------
// ****************  Dont bother the code below  ******************************
// \/  \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/
//-----------------------------------------------------------------------------
void program_freq0(long frequency)
{
    AD9834_reset_high();  
    int flow,fhigh;
    fcalc = frequency*(268.435456e6 / Reference );    // 2^28 =
    flow = fcalc&0x3fff;              //  49.99975mhz  
    fhigh = (fcalc>>14)&0x3fff;
    digitalWrite(FSYNC_BIT, LOW);  //
    clock_data_to_ad9834(flow|AD9834_FREQ0_REGISTER_SELECT_BIT);
    clock_data_to_ad9834(fhigh|AD9834_FREQ0_REGISTER_SELECT_BIT);
    digitalWrite(FSYNC_BIT, HIGH);
    AD9834_reset_low();
}    // end   program_freq0

//|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  
void program_freq1(long frequency)
{
    AD9834_reset_high(); 
    int flow,fhigh;
    fcalc = frequency*(268.435456e6 / Reference );    // 2^28 =
    flow = fcalc&0x3fff;              //  use for 49.99975mhz   
    fhigh = (fcalc>>14)&0x3fff;
    digitalWrite(FSYNC_BIT, LOW);  
    clock_data_to_ad9834(flow|AD9834_FREQ1_REGISTER_SELECT_BIT);
    clock_data_to_ad9834(fhigh|AD9834_FREQ1_REGISTER_SELECT_BIT);
    digitalWrite(FSYNC_BIT, HIGH);  
    AD9834_reset_low();
}  

//------------------------------------------------------------------------------
void clock_data_to_ad9834(unsigned int data_word)
{
    char bcount;
    unsigned int iData;
    iData=data_word;
    digitalWrite(SCLK_BIT, HIGH);  //portb.SCLK_BIT = 1;  
    // make sure clock high - only chnage data when high
    for(bcount=0;bcount<16;bcount++)
    {
        if((iData & 0x8000)) digitalWrite(SDATA_BIT, HIGH);  //portb.SDATA_BIT = 1; 
        // test and set data bits
        else  digitalWrite(SDATA_BIT, LOW);  
        digitalWrite(SCLK_BIT, LOW);  
        digitalWrite(SCLK_BIT, HIGH);     
        // set clock high - only change data when high
        iData = iData<<1; // shift the word 1 bit to the left
    }  // end for
}  // end  clock_data_to_ad9834

//-----------------------------------------------------------------------------
void AD9834_init()      // set up registers
{
    AD9834_reset_high(); 
    digitalWrite(FSYNC_BIT, LOW);
    clock_data_to_ad9834(0x2300);  // Reset goes high to 0 the registers and enable the output to mid scale.
    clock_data_to_ad9834((FREQ0_INIT_VALUE&0x3fff)|AD9834_FREQ0_REGISTER_SELECT_BIT);
    clock_data_to_ad9834(((FREQ0_INIT_VALUE>>14)&0x3fff)|AD9834_FREQ0_REGISTER_SELECT_BIT);
    clock_data_to_ad9834(0x2200); // reset goes low to enable the output.
    AD9834_reset_low();
    digitalWrite(FSYNC_BIT, HIGH);  
}  //  end   init_AD9834()

//----------------------------------------------------------------------------   
void AD9834_reset()
{
    digitalWrite(RESET_BIT, HIGH);  // hardware connection
    for (int i=0; i <= 2048; i++);  // small delay

    digitalWrite(RESET_BIT, LOW);   // hardware connection
}

//-----------------------------------------------------------------------------
void AD9834_reset_low()
{
    digitalWrite(RESET_BIT, LOW);
}

//..............................................................................     
void AD9834_reset_high()
{  
    digitalWrite(RESET_BIT, HIGH);
}
//^^^^^^^^^^^^^^^^^^^^^^^^^  DON'T BOTHER CODE ABOVE  ^^^^^^^^^^^^^^^^^^^^^^^^^ 
//=============================================================================
