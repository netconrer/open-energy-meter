#define toDeg(x) (x*57.2957795131)  // *180/pi

#import <Cocoa/Cocoa.h>
#import "AMSerialPort.h"
#import <Quartz/Quartz.h>
#import "XBeeAPIParser.h"
//#import <CorePlot/CorePlot.h>
#import "ConsoleWindowController.h"


@interface AppController : NSObject {
	IBOutlet NSTextView               *outputTextView;
	IBOutlet NSComboBox               *speedComboBox;
	IBOutlet NSComboBox               *deviceComboBox;
	IBOutlet NSButton                 *connectDisconnectButton;
	IBOutlet NSWindow                 *mainWindow;
	IBOutlet NSProgressIndicator      *connectionIndicator;
  IBOutlet NSButton                 *consoleWindowShowButton;

	AMSerialPort                      *port;
	NSArray                           *speedArray;
	XBeeAPIParser                     *xbeeParser;
  ConsoleWindowController           *consoleWindowController;

  
  float                             proportionalGain;
  float                             integralGain;
  float                             derivativeGain;  
  
	bool                              serialPortConnected;
	int                               loopbacksSent;
	int                               loopbacksReceived;
  float                             channel0RMS;
  float                             channel1RMS;
  int                               channel0ADC;  
  int                               channel1ADC;
}

- (void)closePort;
- (IBAction)connectDisconnect:(id)sender;
- (IBAction)consoleWindowShow:(id)sender;
- (void)explodeValuesPacket:(NSData *)packet;

@property           bool            serialPortConnected;
@property           float           channel0RMS;
@property           float           channel1RMS;
@property           int             channel0ADC;
@property           int             channel1ADC;

@property (retain)  AMSerialPort    *port;


@end