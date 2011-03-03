#define joulesToKWHours(x) (x/3600000)  // 1 Kilowatt Hour == 3.6 Megajoules

#import <Cocoa/Cocoa.h>
#import "AMSerialPort.h"
#import "XBeeAPIParser.h"
#import "ConsoleController.h"
#import "PreferenceController.h"
#import "WaveformWindowController.h"

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
  ConsoleController                 *consoleController;
  PreferenceController              *preferenceController;
  WaveformWindowController          *waveformWindowController;

  
	bool                              serialPortConnected;
	int                               loopbacksSent;
	int                               loopbacksReceived;
  float                             channel0RMS;
  float                             channel1RMS;
  int                               channel0ADC;  
  int                               channel1ADC;
  float                             kilowattHours;
  float                             voltAmps;
}

- (void)closePort;
- (IBAction)connectDisconnect:(id)sender;
- (IBAction)showConsoleWindow:(id)sender;
- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)showWaveformWIndow:(id)sender;
- (void)explodeValuesPacket:(NSData *)packet;

@property           bool            serialPortConnected;
@property           float           channel0RMS;
@property           float           channel1RMS;
@property           int             channel0ADC;
@property           int             channel1ADC;
@property           float           kilowattHours;
@property           float           voltAmps;

@property (retain)  AMSerialPort    *port;


@end