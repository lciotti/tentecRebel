/*
<Rebel_506_Alpha_Rev01, Basic Software to operate a 2 band QRP Transceiver.
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
//  Attention ****  Ten-Tec Inc. is not responsible for any modification of Code 
//  below. If code modification is made, make a backup of the original code. 
//  If your new code does not work properly reload the factory code to start over again.
//  You are responsible for the code modifications you make yourself. And Ten-Tec Inc.
//  Assumes NO liability for code modification. Ten-Tec Inc. also cannot help you with any 
//  of your new code. There are several forums online to help with coding for the ChipKit UNO32.
//  If you have unexpected results after writing and programming of your modified code. 
//  Reload the factory code to see if the issues are still present. Before contacting Ten-Tec Inc.
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
  Serial timing setup for AD9834 DDS
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

  Default Band_width will be wide ( Green led light ).
  When pressing the function button one of three leds will light. 
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
  code to this main program and get everything integrated. Whew!!!!
  
  March 20, 2013. First day of Spring. Got the function/select routines 
  integrated into program! Works!  Had to tweak on the delays a bit.  Still 
  need to tackle the DDS failure to come on without the encoder having to be 
  turned.
  Also need to get a routine that saves the current settings when powered down. 
  The list goes on and on!

  April 07, 2013. (AC7FK) Added serialDump routine to send information to host
  via the serial port (115200 bps).  The serialDump function is called once 
  per second.  Added calculation for loops per second and loop execution time.  
  Commented out the splash_RX_freq() function call to reduce execution time of 
  the main loop.  Simplified IF frequency math by changing the sign of the IF
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
  
  September 18, 2013. (AC0SR)
  I've made a bunch of changes; moving one time function calls into the main code,
  streamlining the AD9834 frequency and init functions at the end of the program, 
  changing "bit" defines to "pin" defines, eliminating unused variables, adding
  comments, etc. I also changed the band limit to 7.000-7.125 mHz for 40 meters and
  14.000-14.070 mHz for 20 meters. That's the range I use and it makes keeping track
  of where I am frequency-wise using the LED flashes easier. YMMV.
  
  You can find all my changes by date by searching for "PJB".
*/

// All through this program there may be some extra code that is not used
// or commented out. 
// It's left up to the programmer to rewrite this to suit their needs!

// Various defines:
// The suffix "bit" in the first four defines is actually something of a misnomer, since we're using
// hardware control "pins" rather than software control "bits". So I changed it. PJB-091713

#define SDATA_PIN                           10          //  keep!
#define SCLK_PIN                            8           //  keep!
#define FSYNC_PIN                           9           //  keep!
#define RESET_PIN                           11          //  keep!

#define FREQ_REGISTER_BIT                   12          //  keep!
#define AD9834_FREQ0_REGISTER_SELECT_BIT    0x4000      //  keep!
#define AD9834_FREQ1_REGISTER_SELECT_BIT    0x8000      //  keep!
//#define FREQ0_INIT_VALUE                    0x01320000  //  Don't need this for AD9834_init(). PJB-091813

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

const int RitReadPin        = A0;  // pin that the sensor is attached to used for a rit routine later.
int RitReadValue            = 0;
int RitFreqOffset           = 0;

const int SmeterReadPin     = A1;  // To give a realitive signal strength based on AGC voltage.
int SmeterReadValue         = 0;

const int BatteryReadPin    = A2;  // Reads 1/5 th or 0.20 of supply voltage.
int BatteryReadValue        = 0;

const int PowerOutReadPin   = A3;  // Reads RF out voltage at Antenna.
int PowerOutReadValue       = 0;

const int CodeReadPin       = A6;  // Can be used to decode CW. 
int CodeReadValue           = 0;

const int CWSpeedReadPin    = A7;  // To adjust CW speed for user written keyer.
int CWSpeedReadValue        = 0;            




#include <LiquidCrystal.h>    //  LCD Stuff

LiquidCrystal lcd(26, 27, 28, 29, 30, 31);      //  LCD Stuff

//LiquidCrystal lcd(12, 11, 5, 4, 3, 2);      //  LCD Stuff

const char txt3[8]          = "100 HZ ";
const char txt4[8]          = "1 KHZ  ";
const char txt5[8]          = "10 KHZ ";
const char txt52[5]         = " ";
const char txt57[6]         = "FREQ:" ;
const char txt60[6]         = "STEP:";
const char txt62[3]         = "RX";
const char txt64[4]         = "RIT";
const char txt65[5]         = "Band";
const char txt66[4]         = "20M";
const char txt67[4]         = "40M";

String stringFREQ;
String stringREF;
String stringfrequency_step;
String stringRIT;

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
long save_rec_frequency;
long frequency_step;
long frequency                  = 0;
long frequency_old              = 0;
long frequency_tune             = 0;
long frequency_default          = 0;
long frequency_word;
long IF                         = 9.00e6;          //  I.F. Frequency

//------------------------------------------------------------
// Debug Stuff
unsigned long  loopCount       = 0;
unsigned long  lastLoopCount   = 0;
unsigned long  loopsPerSecond  = 0;
unsigned int   printCount      = 0;

unsigned long  loopStartTime    = 0;
unsigned long  loopElapsedTime  = 0;
float          loopSpeed        = 0;

unsigned long  LastFreqWriteTime = 0;

void serialDump();


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
void Band_Splash();

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

//========================== Setup Loop ==============================
void setup() 
{
  // these pins are for the AD9834 control
  pinMode(SCLK_PIN,               OUTPUT);    // clock
  pinMode(FSYNC_PIN,              OUTPUT);    // fsync
  pinMode(SDATA_PIN,              OUTPUT);    // data
  pinMode(RESET_PIN,              OUTPUT);    // reset
  pinMode(FREQ_REGISTER_BIT,      OUTPUT);    // freq register select

  //---------------  Encoder ------------------------------------
  pinMode (encoder0PinA,          INPUT);     // using optical for now
  pinMode (encoder0PinB,          INPUT);     // using optical for now 

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

  //---------------------------------------------------------------
  pinMode (Band_Select,           INPUT);     // select

  //---------------------------------------------------------------
  //lcd.begin(16, 4);                           // 20 chars 4 lines
    lcd.begin(16, 2);                                          // or change to suit ones 
                                              // lcd display 

  //-----------------------Default Settings------------------------
  // Moved these from one time function call to here. PJB-091813
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
  digitalWrite(TX_OUT,                LOW);  

  digitalWrite(FREQ_REGISTER_BIT,     LOW);   // This is set to LOW so RX is not
                                              // dead on power on. PJB-091713
  digitalWrite(Band_End_Flash_led,    LOW);

  digitalWrite(Side_Tone,             LOW);
  
  //---------------------------------------------------------------
  // Initialize the AD9834 control register. PJB-091813
  AD9834_init();
  // Find out what our default frequency is going to be. This will also
  // set the receive and transmit frequency registers, freq0 and freq1.
  Band_Set_40_20M();

  //--------------------------------------------------------------
  Step_Size_1k();   // Changed to 1k Hz Step_Size. PJB-091713
  for (int i=0; i <= 5e4; i++);  // small delay

  // Uncomment the next line to prevent the startup frequency from changing
  // due to the last position of the encoder. PJB-091713.
  encoder0PinALast = digitalRead(encoder0PinA);
    
  //attachInterrupt(encoder0PinA, Encoder, CHANGE);
  //attachInterrupt(encoder0PinB, Encoder, CHANGE);
  attachCoreTimerService(TimerOverFlow);//See function at the bottom of the file.

  Serial.begin(115200);
  Serial.println("Rebel Ready:");

}  //  end of setup()

//======================= End of Setup Loop =========================


//========================== Main Loop ==============================
void loop()
{
  // Next two lines unnecessary.
  //digitalWrite(FSYNC_PIN,             HIGH);  // 
  //digitalWrite(SCLK_PIN,              HIGH);  //

  RIT_Read();

  Multi_Function(); 

  Encoder();

  frequency_tune  = frequency + RitFreqOffset;
  UpdateFreq(frequency_tune);
 // splash_RX_freq();   // this only needs to be updated when encoder changed.

  TX_routine();

  loopCount++;
  loopElapsedTime    = millis() - loopStartTime;

  // has 1000 milliseconds elasped?
  if( 1000 <= loopElapsedTime )
  {
    serialDump();    // comment this out to remove the one second tick
    LCDFrequencyDisplay();
//    Serial.print("A6 = ");
//    Serial.println(CodeReadPin);
  }

}  //  end loop

//========================= End of Main Loop =========================

/*****
  This method uses the LCD display from Chapter 3 of the Purdum-Kidder book to
  display the Rebel receiving frequency.
  
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
  char tail[] = {' ', 'M', 'H', 'z', '\0'};
 
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
 
}

//------------------------ Debug data output -------------------------
void    serialDump()
{
    loopStartTime   = millis();
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
    Serial.println  ();

} // end serialDump()

//-------------------------- Band Select ---------------------------------
void Band_Set_40_20M()
{
  bsm = digitalRead(Band_Select); 
  //  Band select info from shorting block; "1" for 20 meters, "0" for 40.
  if ( bsm == 1 ) 
  { 
    frequency_default = meter_20;
    Band_Splash(); 
  }
  else 
  { 
    frequency_default = meter_40; 
    Band_Splash();

    IF *= -1;               //  High side injection for 40M.
  }
  // Folded one time call to Default_frequency() into here. Since THIS function
  // is only called once I could move the whole thing to setup(). Maybe later. PJB-091813
  frequency = frequency_default;
  UpdateFreq(frequency);
}

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
    
    bsm = digitalRead(Band_Select); 
     if ( bsm == 1 ) { Band_20_Limit_High(); }
     else if ( bsm == 0 ) {  Band_40_Limit_High(); }
 
}

//------------------------------------------------------------------------------  
void Frequency_down()
{ 
    frequency = frequency - frequency_step;
    
    Step_Flash();
    
    bsm = digitalRead(Band_Select); 
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
            
    bsm = digitalRead(Band_Select); 
    
    freq1 = freq - RitFreqOffset;  //  to get the TX freq

    program_freq1( freq1 + IF  );
  
    frequency_old = freq;
}




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

        digitalWrite(TX_OUT, LOW);  // trun off TX
        for (int i=0; i <= 10e3; i++); // delay for maybe some decay on key release

        digitalWrite(FREQ_REGISTER_BIT, LOW);
        digitalWrite(Side_Tone, LOW);
    }
}



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
void  Band_40_Limit_High()      //  Ham band limits. Modified for usable CW band. PJB-091713
{
    //if ( frequency < 16.3e6 )
    if ( frequency < 16.125e6 )
    { 
        stop_led_off();
    } 
   
    //else if ( frequency >= 16.3e6 )
    else if ( frequency >= 16.125e6 )
    { 
        //frequency = 16.3e6;
        frequency = 16.125e6;
        stop_led_on();    
    }
}
//-------------------------------------------------------    
void  Band_40_Limit_Low()       //  Ham band limits
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
void  Band_20_Limit_High()      //  Ham band limits. Modified for usable CW band. PJB-091713
{
    //if ( frequency < 5.35e6 )
    if ( frequency < 5.07e6 )
    { 
        stop_led_off();
    } 
   
    //else if ( frequency >= 5.35e6 )
    else if ( frequency >= 5.07e6 )
    { 
        //frequency = 5.35e6;
        frequency = 5.07e6;
        stop_led_on();    
    }
}
//-------------------------------------------------------    
void  Band_20_Limit_Low()      //  Ham band limits
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
//------------------------------------------------------------------------------  

void led_test()    // used for testing delete when done
{
    digitalWrite(13, HIGH);     // set the LED on
    delay(100);                 // wait for a moment

    digitalWrite(13, LOW);      // set the LED off
    delay(100);                 // wait for a moment
}

//------------------------Display Stuff below-----------------------------------
//------------------- Splash RIT -----------------------------------------------  
void splash_RIT()      // not used
{ 
    // lcd.clear();                         // Clear display
    lcd.setCursor(0, 0);
    lcd.print(txt64);                       //  RIT
    lcd.setCursor(5, 0);
    stringRIT = String(RitReadValue, DEC);
    lcd.print(stringRIT);

}
//------------------------------------------------------------------------------
void splash_RX_freq()
{
    bsm = digitalRead(Band_Select); 
     
      RX_frequency = frequency + IF;

      lcd.setCursor(0, 1);
    lcd.print(txt62); // RX
    lcd.setCursor(6, 1);
    stringFREQ = String(RX_frequency, DEC);
    lcd.print(stringFREQ);
 }

//-----------------------------------------------------------------
void Band_Splash()
{
    if ( bsm == 1 ) 
    {
        lcd.setCursor(0, 3);
        lcd.print(txt65); 
        lcd.setCursor(6, 3);
        lcd.print(txt66);
    }
    else 
    {
        lcd.setCursor(6, 3);
        lcd.print(txt67);
    } 
}   


//---------------------------------------------------------------------------------
//stuff above is for testing using the Display Comment out if not needed  
//-----------------------------------------------------------------------------  
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
    Selected_Other = Other_3_user; 
}

//-----------------------------------------------------------------------------
uint32_t TimerOverFlow(uint32_t currentTime)
{

    return (currentTime + CORE_TICK_RATE*(1));//the Core Tick Rate is 1ms

}


//-----------------------------------------------------------------------------
// ****************  Dont bother the code below  ******************************
// But I did. Changed some variable names to be more descriptive, rearranged
// parameter lists, eliminated some function calls with one line commands,
// and removed software reset and frequency code from AD9834_init().
// PJB-091813.
//-----------------------------------------------------------------------------
void program_freq0(long frequency)  // Receive frequency register, freq0.
{
  int frequency_word_LSBs, frequency_word_MSBs;
  frequency_word = frequency * (268.435456e6 / Reference );    // (2^28 / reference frequency)
  frequency_word_LSBs = frequency_word & 0x3fff;               // = frequency word
  frequency_word_MSBs = (frequency_word >> 14) & 0x3fff;
  digitalWrite(RESET_PIN, HIGH);
  digitalWrite(FSYNC_PIN, LOW);
  clock_data_to_ad9834(AD9834_FREQ0_REGISTER_SELECT_BIT | frequency_word_LSBs);
  clock_data_to_ad9834(AD9834_FREQ0_REGISTER_SELECT_BIT | frequency_word_MSBs);
  digitalWrite(FSYNC_PIN, HIGH);
  digitalWrite(RESET_PIN, LOW);
}  // end program_freq0()

//-----------------------------------------------------------------------------  
void program_freq1(long frequency)  // Transmit frequency register, freq1
{
  int frequency_word_LSBs, frequency_word_MSBs;
  frequency_word = frequency * (268.435456e6 / Reference );    // (2^28 / reference frequency)
  frequency_word_LSBs = frequency_word & 0x3fff;               // = frequency word  
  frequency_word_MSBs = (frequency_word >> 14) & 0x3fff;
  digitalWrite(RESET_PIN, HIGH);
  digitalWrite(FSYNC_PIN, LOW);  
  clock_data_to_ad9834(AD9834_FREQ1_REGISTER_SELECT_BIT | frequency_word_LSBs);
  clock_data_to_ad9834(AD9834_FREQ1_REGISTER_SELECT_BIT | frequency_word_MSBs);
  digitalWrite(FSYNC_PIN, HIGH);  
  digitalWrite(RESET_PIN, LOW);
}  // end program_freq1()

//------------------------------------------------------------------------------
void clock_data_to_ad9834(unsigned int data_word)  // Does what it says.
{
  //int bcount;
  unsigned int iData = data_word;
  //iData = data_word;
  // make sure the serial clock is high - only change the data when it's high.
  digitalWrite(SCLK_PIN, HIGH);
  for(int i=0; i<16; i++)
  {
    // Test and set/clear the data bit...
    if((iData & 0x8000))
    {
      digitalWrite(SDATA_PIN, HIGH);
    }
    else
    {
      digitalWrite(SDATA_PIN, LOW);
    }
    // ...then clock the bit through.
    digitalWrite(SCLK_PIN, LOW);
    digitalWrite(SCLK_PIN, HIGH);     
    // Shift the idata word 1 bit to the left...
    iData = iData << 1;
    // ...and do it again until all 16 bits have been shifted into the register.
  }
}  // end clock_data_to_ad9834()

//-----------------------------------------------------------------------------
void AD9834_init()  // set up control register.
{
  digitalWrite(RESET_PIN, HIGH);
  digitalWrite(FSYNC_PIN, LOW);
  // Set up the control register for 2 writes to frequency registers (LSB's then MSB's) and
  // pin (hardware) control of frequency register selection.
  clock_data_to_ad9834(0x2200);
  digitalWrite(FSYNC_PIN, HIGH);
  digitalWrite(RESET_PIN, LOW);
}  // end init_AD9834()

//----------------------------------------------------------------------------   

