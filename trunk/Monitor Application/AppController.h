#define joulesToKWHours(x) (x/3600000)  // 1 Kilowatt Hour == 3.6 Megajoules
#define AMSerialDebug 1

#import <Cocoa/Cocoa.h>
#import "AMSerialPort.h"
#import "XBeeAPIParser.h"
#import "ConsoleController.h"
#import "PreferenceController.h"
#import "PlotsController.h"
#import "CorePlot/CorePlot.h"

@interface AppController : NSObject {
	IBOutlet NSTextView               *outputTextView;
	IBOutlet NSComboBox               *speedComboBox;
	IBOutlet NSComboBox               *deviceComboBox;
	IBOutlet NSButton                 *connectDisconnectButton;
	IBOutlet NSWindow                 *mainWindow;
	IBOutlet NSProgressIndicator      *connectionIndicator;
  IBOutlet NSButton                 *consoleWindowShowButton;
  IBOutlet PlotsController          *plotsController;

	AMSerialPort                      *port;
	NSArray                           *speedArray;
	XBeeAPIParser                     *xbeeParser;
  ConsoleController                 *consoleController;
  PreferenceController              *preferenceController;
  
	bool                              serialPortConnected;
	NSInteger                              loopbacksSent;
	NSInteger                              loopbacksReceived;
 float                            channel0RMS;
 float                            channel1RMS;
  NSInteger                              channel0ADC;  
  NSInteger                              channel1ADC;
 float                            kilowattHours;
 float                            voltAmps;
}

- (void)closePort;
- (IBAction)connectDisconnect:(id)sender;
- (IBAction)showConsoleWindow:(id)sender;
- (IBAction)showPreferencePanel:(id)sender;
- (void)explodeValuesPacket:(NSData *)packet;

@property           bool            serialPortConnected;
@property          float          channel0RMS;
@property          float          channel1RMS;
@property           NSInteger            channel0ADC;
@property           NSInteger            channel1ADC;
@property          float          kilowattHours;
@property          float          voltAmps;

@property (retain)  AMSerialPort    *port;


@end