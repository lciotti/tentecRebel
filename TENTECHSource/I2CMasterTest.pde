// RIO-EA I2C Master Driver Test Code
// Read an analog input from the remote processor - Fubarino Mini in this case
// I2CMasterTest.pde
// Created August 14, 2013 by James M. Lynes, Jr.
// Last Modified: 8/14/13 - Created a test version of the master driver
//		  8/15/13 - Add Led on PIN 13 as I2C Activity Indicator
//		  8/16/13 - Modify some delays

// Ten-Tec Rebel(UNO32) Pin Definitions
// Pin 18 SDA1 - I2C Serial Data  - J7-9  - 2.2K pull-up on Fubarino Mini breadboard
// Pin 19 SCL1 - I2C Serial Clock - J7-11 - 2.2K pull-up on Fubarino Mini breadboard

// Connect the Rebel 506 chipKIT UNO32 main processor to one or more
//	I/O Expansion Processors over an I2C Bus. Similar code on Arduino.cc.
//	However, this version is highly expanded.

// A Process is a task to be run on one of the remote I/O Expansion Processors
//	at the direction of the main Rebel processor. As simple as read/write
//	a digital pin or analog pin to as complex as interacting with a peripheral.

// A Remote Process call is a two step process:
//	First: send a command packet to tell the remote to do something and then build
//		a response packet.
//	Second: request the response packet be sent by the remote process.

// This implementation assumes that the command and response packet lengths can be defined
//	at compile time. Work-around: Define a packet length longer than you need
//	and include a length byte in the 2nd position as part of your specific process design.

// This code runs on the Rebel 506 chipKIT UNO32 master processor. 

#include <Wire.h>				// I2C Library
						// I2C Error Codes:
						// 0 - No Error, 1 - Data too long for xmit buffer
						// 2 - NACK on xmit address, 3 - NACK on xmit data
						// 4 - Other Error

// Function Prototypes
int  I2C_Transmit_Packet(byte);
void I2C_Receive_Packet(byte);
void ReadAN12_Code();
void Process2_Code();
void Process3_Code();
void Process4_Code();
void Process5_Code();

// Define the Process Table Structure
struct Process {
  byte Process_Id;				// Remote Process Id
  byte I2C_Address;				// Remote I2C Address
  byte Tx_Length;				// Transmit Length
  byte * Tx_Buffer;				// Transmit Buffer Pointer
  byte Rx_Length;				// Receive Length
  byte * Rx_Buffer;				// Receive Buffer Pointer
};

// Define some dummy Process IDs - One for each Remote Process on an I/O Expansion Board
// These must begin at 0 and increase by 1 as they are used as an index into the Processes structure array
#define	ReadAN12  0
#define	Process2  1
#define	Process3  2
#define	Process4  3
#define	Process5  4
#define MaxProcesses 5

// Define some dummy I2C Addresses - One for each I/O Expansion Board
#define	I2CAddr1  20
#define	I2CAddr2  40
#define MaxBoards 2

// Define some dummy I/O Buffers - Wire Library Max 32 characters(?)
// Each process can have it's own pair of buffers if desired.
byte Transmit_Buffer[32];
byte Receive_Buffer[32];

// Define some dummy Buffer Pointers
// Each process can have it's own pair of buffer pointers if desired.
byte * Tx_Buffer_Ptr = Transmit_Buffer;
byte * Rx_Buffer_Ptr = Receive_Buffer; 

// Define some dummy Packet Lengths
// Each process can(will) have it's own pair of packet lengths
// Actual values may be hard coded in the struct or filled in by each Process# function.
byte Transmit_Length = 0;
byte Receive_Length = 0;

// Define the Application Specific Process Table
// Your process structure goes here.
struct Process Processes[MaxProcesses] = {
  ReadAN12, I2CAddr1, 1, Tx_Buffer_Ptr, 3, Rx_Buffer_Ptr,
  Process2, I2CAddr1, Transmit_Length, Tx_Buffer_Ptr, Receive_Length, Rx_Buffer_Ptr,
  Process3, I2CAddr1, Transmit_Length, Tx_Buffer_Ptr, Receive_Length, Rx_Buffer_Ptr,
  Process4, I2CAddr2, Transmit_Length, Tx_Buffer_Ptr, Receive_Length, Rx_Buffer_Ptr,
  Process5, I2CAddr2, Transmit_Length, Tx_Buffer_Ptr, Receive_Length, Rx_Buffer_Ptr,
};

// Define a driver specific variable
byte Current_State = ReadAN12;				// Current state machine step & process ID			

void setup() {						// Blend code into Rebel main setup
  Wire.begin();						// Join I2C bus (address optional for master)
  Serial.begin(9600);					// Start serial for debug output
  pinMode(13, OUTPUT);					// I2C Activity Indicator
  digitalWrite(13, LOW);
}

void loop() {

// Process State Machine - this code would be blended into the Rebel main loop
// Five processes setup for demonstration purposes only. YMMV.
switch(Current_State) {
	case ReadAN12:
		ReadAN12_Code();			// Read an analog from a remote processor
		Current_State++;			// Cycle to the next process
		break;
	case Process2:
		Process2_Code();
		Current_State++;
		break;
	case Process3:
		Process3_Code();
		Current_State++;
		break;
	case Process4:
		Process4_Code();
		Current_State++;
		break;
	case Process5:
		Process5_Code();
		Current_State++;
		break;
	default: {Current_State = ReadAN12;}
	}
delay(40);						// Slow down to read the debug prints
}

// Transmit an I2C Command Packet to an I/O Expansion Board
int I2C_Transmit_Packet(byte process) {
	Wire.beginTransmission(Processes[process].I2C_Address);
	for(int i = 0; i < Processes[process].Tx_Length; i++) {
		Wire.send(Processes[process].Tx_Buffer[i]);
	}
	int result = Wire.endTransmission();
	digitalWrite(13, HIGH);					// Indicate I2C Packet Sent
        return result;                                          // Return the error code
}

// Receive an I2C Response Packet from an I/O Expansion Board
void I2C_Receive_Packet(byte process) {
	int i = 0;
	Wire.requestFrom(Processes[process].I2C_Address, Processes[process].Rx_Length);
	while(Wire.available()) {
		Processes[process].Rx_Buffer[i] = Wire.receive();
		i++;
	}
	digitalWrite(13, LOW);					// Indicate I2C Packet Received	
}

// Sample Remote Process Call Sequence
void ReadAN12_Code() {						// Send 1 byte, Receive 3 bytes
	Processes[ReadAN12].Tx_Buffer[0] = ReadAN12;		// Remote command ID to execute
	Processes[ReadAN12].Tx_Length = 1;			// Set command packet length
	Processes[ReadAN12].Rx_Length = 3;			// Set response packet length
                                                                // These can also be defined in the structure

	int result = I2C_Transmit_Packet(ReadAN12);		// Send command packet

	if(result > 0) {					// Test for transmission error
		Serial.print("Transmission Error: ");
		Serial.println(result);
	        for(int i = 0; i < Processes[ReadAN12].Rx_Length; i++) { // Clear the receive buffer
		        Processes[ReadAN12].Rx_Buffer[i] = 0;            // Or other error handling as you desire
                        // return                                        // Put this in when you pull the debug prints
                }
	}
	delay(1);						// Allow time for remote execution
	I2C_Receive_Packet(ReadAN12);				// Request response packet

	Serial.println("Received Packet: ");			// Print response packet for testing
	for(int i = 0; i < Processes[ReadAN12].Rx_Length; i++) {
		Serial.println((int)Processes[ReadAN12].Rx_Buffer[i]);
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

