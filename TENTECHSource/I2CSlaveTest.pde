// RIO-EA I2C Slave Driver Test Code
// Read an analog input on the remote processor - Fubarino Mini in this case
// I2CSlaveTest.pde
// Created August 14, 2013 by James M. Lynes, Jr.
// Last Modified: 8/14/13 - Created a test version of the slave driver
//		  8/15/13 - Added PIN_LED1 as I2C activity indicator
//		  8/16/13 - Modified state machine

// I/O Expansion Processor(Fubarino Mini) Pin Definitions
// Pin 20 - AN12 - Analog pin 12    - 3.3v max only connected to 1K pot wiper
// Pin 26 - SDA1 - I2C Serial Data  - 5v tolerant - 2.2K pull-up to 3.3v YMMV
// Pin 25 - SCL1 - I2C Serial Clock - 5v tolerant - 2.2K pull-up to 3.3v YMMV

// Connect an I/O Expansion Processor to the Rebel 506 chipKIT UNO32 main processor
//	over an I2C Bus. Similar code on Arduino.cc. However, this version is highly expanded.

// An I/O Expansion Processor may be another chipKIT UNO32, a MAX32, a DP32, a Fubarino Mini,
//	a Fubarino SD, or a dsPIC33F Microstick(hopefully for DSP functionality).
//	All except the dsPIC can be programmed with MPIDE just like the Rebel main processor.

// A Process is a task that is run by the Remote I/O Expansion Processor
//	at the direction of the main Rebel processor. As simple as read/write
//	a digital pin or analog pin to as complex as interacting with a peripheral.

// A Remote Process call is a two step process on the slave:
//	First: receive a command packet, execute the command, and build
//		the response packet.
//	Second: receive a request to send a response packet, then send it.

// This implementation assumes that the command and response packet lengths can be defined
//	at compile time. Work-around: Define a packet length longer than you need
//	and include a length byte in the 2nd position as part of your specific process design.

// This code runs on a Rebel 506 slave processor. 

#include <Wire.h>				// I2C Library

// Function Prototypes
void I2C_Transmit_Packet();			// Modified - different from Master Version
void I2C_Receive_Packet();			// Modified - different from Master Version
void ReadAN12_Code();				// Real test case - read an analog pin
void Process2_Code();
void Process3_Code();
void Process4_Code();
void Process5_Code();

// Define the Process Table Structure		// Modified - different from Master Version
struct Process {				// Don't need I2C address in slave structure
  byte Process_Id;				// Process Id
  byte Tx_Length;				// Transmit Length
  byte * Tx_Buffer;				// Transmit Buffer Pointer
  byte Rx_Length;				// Receive Length
  byte * Rx_Buffer;				// Receive Buffer Pointer
};

// Define some dummy Process IDs - One for each Remote Process on an I/O Expansion Board
// These must start at 0 and go up by 1. These will be indexes into the Processes structure array
#define	ReadAN12  0
#define	Process2  1
#define	Process3  2
#define	Process4  3
#define	Process5  4
#define MaxProcesses 5

// Define some dummy I/O Buffers - Wire Library Max 32 characters(?)
// Each process can have it's own pair of buffers if desired.
byte Transmit_Buffer[32];
byte Receive_Buffer[32];
byte Temp_Buffer[32];				// Must read it before we know which process was called

// Define some dummy Buffer Pointers
// Each process can have it's own pair of buffer pointers if desired.
byte * Tx_Buffer_Ptr = Transmit_Buffer;
byte * Rx_Buffer_Ptr = Receive_Buffer; 

// Define some dummy Packet Lengths
// Each process can(will) have it's own pair of packet lengths
// Actual values may be hard coded in the struct or filled in by each Process# function.
byte Transmit_Length = 0;
byte Receive_Length = 0;

// Define the Application Specific Slave Process Table
// Your process structure goes here.
struct Process Processes[MaxProcesses] = {
  ReadAN12, 3, Tx_Buffer_Ptr, 1, Rx_Buffer_Ptr,
  Process2, Transmit_Length, Tx_Buffer_Ptr, Receive_Length, Rx_Buffer_Ptr,
  Process3, Transmit_Length, Tx_Buffer_Ptr, Receive_Length, Rx_Buffer_Ptr,
  Process4, Transmit_Length, Tx_Buffer_Ptr, Receive_Length, Rx_Buffer_Ptr,
  Process5, Transmit_Length, Tx_Buffer_Ptr, Receive_Length, Rx_Buffer_Ptr,
};

// Define some driver specific variables
byte My_I2C_Address = 20;				// This I/O Expansion Processor's I2C Address
byte Current_State = ReadAN12;				// Current state machine step & Process ID
							// Actual value unknown until a packet is received
boolean dataReady;					// Got some data flag			

void setup() {						// Initialize the slave processor
  Wire.begin(My_I2C_Address);				// Join I2C bus with this slave address
  dataReady = false;					// No data received yet
  Wire.onRequest(I2C_Transmit_Packet);			// I2C Request handler - Register Event
  Wire.onReceive(I2C_Receive_Packet);			// I2C receive handler - Register Event
  Serial.begin(9600);					// Start serial for debug output
  pinMode(PIN_LED1, OUTPUT);				// I2C activity indicator
  digitalWrite(PIN_LED1, LOW);
}

void loop() {

// Any housekeeping code goes here - i.e. prescan inputs and peripherals if needed

	if(dataReady) {					// Wait for a packet to arrive					 
		switch(Current_State) {			// Process State Machine
			case ReadAN12:
				ReadAN12_Code();	// Read AN12 Example
				break;
			case Process2:
				Process2_Code();
				break;
			case Process3:
				Process3_Code();
				break;
			case Process4:
				Process4_Code();
				break;
			case Process5:
				Process5_Code();
				break;
			default: {}
		}
	}
	dataReady = false;					// Reset for next request
}

// Transmit an I2C Response Packet to the Rebel main processor - Event Triggered
void I2C_Transmit_Packet() {	
        digitalWrite(PIN_LED1, LOW);				// Indicate Packet Sent
  	Wire.send(Processes[Current_State].Tx_Buffer, Processes[Current_State].Tx_Length);	
}

// Receive an I2C Command Packet from the Rebel main processor - Event Triggered
void I2C_Receive_Packet(int howMany) {
  	int i = 0;
	while(Wire.available()) {
		Temp_Buffer[i] = Wire.receive();		// Receive into a temp buffer
		i++;						// Because we don't know the process ID
								// Until we receive the command
								// ID will be in the 1st byte received
	}

	Serial.println("Received Packet: ");			// Print received packet for testing
	for(int i = 0; i < Processes[Temp_Buffer[0]].Rx_Length; i++) { // Copy packet into Process buffer
		Processes[Temp_Buffer[0]].Rx_Buffer[i] = Temp_Buffer[i];
		Serial.println((int)Processes[Temp_Buffer[0]].Rx_Buffer[i]);
	}

	dataReady = true;					// Signal a command was received
	Current_State = Temp_Buffer[0];				// Set state to ID received	
        digitalWrite(PIN_LED1, HIGH);				// Indicate Packet Received
}

// Sample Remote Process Call Sequence
// Execute the required process code then build the response packet
void ReadAN12_Code() {						// Receive 1 bytes, Send 3 bytes
	int aval = analogRead(A12);				// Read analog 12 on Pin 20
	int low_byte = aval & 0xFF;				// Isolate low byte
	int high_byte = (aval>>8) & 0xFF;			// Isolate high byte
	Processes[ReadAN12].Tx_Buffer[0] = ReadAN12;		// Echo ID back to master
	Processes[ReadAN12].Tx_Buffer[1] = (byte)low_byte;	// Send low byte
	Processes[ReadAN12].Tx_Buffer[2] = (byte)high_byte;	// Send high byte
	Processes[ReadAN12].Tx_Length = 3;			// Set response packet length

	Serial.println("Response Packet: ");			// Print response packet for testing
	for(int i = 0; i < Processes[ReadAN12].Tx_Length; i++) {
		Serial.println((int)Processes[ReadAN12].Tx_Buffer[i]);
	}
}

//
void Process2_Code() {
// Duplicate code above
}

//
void Process3_Code() {
// Duplicate code above
}

//
void Process4_Code() {
// Duplicate code above
}

//
void Process5_Code() {
// Duplicate code above
}

