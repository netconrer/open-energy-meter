//
//  XBeeAPIParser.h
//  PropStream
//
//  Created by Jay Kickliter on 3/2/09.
//  Copyright 2009 KarmaLabs. All rights reserved.
//

/*-----------------------------------------------------------------------
 --------------------------------┌───────────┐----------------------------
 --------------------------------│ init      │----------------------------
 --------------------------------└───────────┘----------------------------
 -------------------------------------------------------------------------
 Action:      Initialized class and returns self
 Parameters:  None
 Results:     None
 +Reads/Uses: None
 +Writes:     Initializes bufferIndex to 0
 Calls:       None
 -----------------------------------------------------------------------*/

/*------------------------------------------------------------------------
 --------------------------------┌───────────┐----------------------------
 --------------------------------│ delegate  │----------------------------
 --------------------------------└───────────┘----------------------------
 -------------------------------------------------------------------------
 Action:      Return a pointer to the the delegate
 Parameters:  None
 Results:     A pointer to delegate
 +Reads/Uses: None
 +Writes:     None
 Calls:       None
 -----------------------------------------------------------------------*/

/*------------------------------------------------------------------------
 --------------------------------┌───────────┐----------------------------
 --------------------------------│setDelegate│----------------------------
 --------------------------------└───────────┘----------------------------
 -------------------------------------------------------------------------
 Action:      Set's the objects delegate, and checks if that delegate 
                implements the method xbeePacketReceived:
 Parameters:  A pointer to the new delegate
 Results:     None
 +Reads/Uses: None
 +Writes:     (BOOL) delegateAcceptsParsedXbeePackets
              (ID) delegate
 Calls:       None
 -----------------------------------------------------------------------*/

/*------------------------------------------------------------------------
 ---------------------┌─────────────────────────────────┐-----------------
 ---------------------│ - (void)addData:(NSData *)data  │-----------------
 ---------------------└─────────────────────────────────┘-----------------
 -------------------------------------------------------------------------
 Action:      Since this class does't actually do any serial port 
              communications on its own, the programmer has to add
              provide this class with any data coming in over a serial line.
              This may change in the future, but for now this works.
              Basically, it doesn't matter how you access the serial port,
              I use the open-source AMSerialPort class. However you get that
              incoming data, package it up when you can in an NSData object,
              and call addData, the code here will do all the parsing and
              return anything complete XBee packets to the delegate object
 Parameters:  A pointer to an NSData obejct
 Results:     None
 +Reads/Uses: (unsigned char *) incomingBuffer[]
 +Writes:     (unsigned char *) incomingBuffer[]
 Calls:       - (void)parsePacket:(unsigned char *)packet length:(int)length
 -----------------------------------------------------------------------*/

/*------------------------------------------------------------------------
 --┌─────────────────────────────────────────────────────────────────┐----
 --│ - (void)parsePacket:(unsigned char *)packet length:(int)length  │----
 --└─────────────────────────────────────────────────────────────────┘----
 -------------------------------------------------------------------------
 Action:      Whenever - (void)addData:(NSData *)data detects a XBee 
              start character 0x7E, it calls this method and passes
              a pointer to the buffer and the integer length, which
              is how much of the buffer to use. The length is important,
              since our data might contain, and the function strlen() 
              might detect a false lenght of our data
 Parameters:  (unsigned char *)packet - A pointer ot a c array
               (int)length - How many bytes of that array to use
 Results:     None
 +Reads/Uses: 
 +Writes:     
 Calls:       [delegate xbeePacketReceived:(NSDictionary *)packetDictionary]
              will call other methos when more functionality is added
 -----------------------------------------------------------------------*/

/*------------------------------------------------------------------------
 ┌─────────────────────────────────────────────────────────────────┐------
 │ - (NSData *)formXbeePacketFromBytes:(unsigned char *)bytes      │------
 │                              length:(unsigned int)length        │------
 └─────────────────────────────────────────────────────────────────┘------
 -------------------------------------------------------------------------
 Action:      Takes a pre-formatted XBee packet, and addes the delemiter
              character, adds the two length bytes, calculates checksum
              and escapes any necessary bytes
 Parameters:  (unsigned char *)bytes - A pointer ot a c array
              (int)length - How many bytes of that array to use
 Results:     Returns a ready-to transmit XBee packet in the form of
              an NSData object
 +Reads/Uses: 
 +Writes:     
 Calls:       
 -----------------------------------------------------------------------*/

/*--------------------------------------------------------------------------
 --┌─────────────────────────────────────────────────────────────────┐------
 --│ - (NSData *)xbeeApiPacketWithData:(NSData *)data                │------
 --│                upper32AddressBits:(unsigned long)upper32        │------
 --│                lower32AddressBits:(unsigned long)lower32        │------
 --│                    networkAddress:(unsigned int)netAddress      │------
 --│                           frameId:(unsigned char)frameId        │------
 --└─────────────────────────────────────────────────────────────────┘------
 ---------------------------------------------------------------------------
 Action:      Form a tansmit request packet. This is a specific type of
              packet, and the most common one to use.
 Parameters:  (NSData *)data - The actual data you want to send to the other unit
              (unsigned long)upper32 - The upper 32 bits of the remote XBee's
                64 bit address
              (unsigned long)lower32 - The lower 32 bits of the remote XBee's
                64 bit address
              (unsigned int)netAddress - The 16 bit network address
              (unsigned char)frameId   - A frame ID, can be arbitary, since this
                code doesn't use ack's
 Results:     Returns a ready-to transmit XBee transmit request packet in the form of
                an NSData object
 +Reads/Uses: 
 +Writes:     
 Calls:       - (NSData *)formXbeePacketFromBytes:(unsigned char *)bytes length:(unsigned int)length
 -----------------------------------------------------------------------*/

#import <Cocoa/Cocoa.h>

#define XBeeDelimiterCharacter              0x7e
#define XBeeEscapeCharacter                 0x7d
#define XBeeChecksumValue                   0xFF
#define XBeeModemStatusFrame                0x8A
#define XBeeATCommandFrame                  0x08
#define XBeeATCommandQueueFrame             0x09
#define XBeeParameteValueFrame              0x09
#define XBeeATCommandResponseFrame          0x88
#define XBeeRemoteCommandRequestFrame       0x17 
#define XBeeRemoteCommandResponseFrame      0x97 
#define XBeeTransmitRequestFrame            0x10 
#define XBeeExplicitAddressingCommandFrame  0x11 
#define XBeeTransmitStatusFrame             0x8B 
#define XBeeReceivePacketFrame              0x90 
#define XBeeExplicitReceivePacketFrame      0x91 


@interface NSObject (XBeeAPIDelegate)
- (void)xbeePacketReceived:(NSDictionary *)packetDictionary;
@end

@interface XBeeAPIParser : NSObject {
  unsigned char                 buffer[500];
  unsigned char                 incomingBuffer[500];
  unsigned int                  bufferIndex;
  id                            delegate;
  bool                          delegateAcceptsParsedXbeePackets;
}

@property (retain) id delegate;

- (void)addData:(NSData *)data;
- (void)parsePacket:(unsigned char *)packet length:(int)length;
//- (id)delegate;
//- (void)setDelegate:(id)newDelegate;
- (NSData *)xbeeApiPacketWithData:(NSData *)data upper32AddressBits:(unsigned long)upper32 lower32AddressBits:(unsigned long)lower32 networkAddress:(unsigned int)netAddress frameId:(unsigned char)frameId;

@end