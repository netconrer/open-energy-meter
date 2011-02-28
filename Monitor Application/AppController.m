#import "AppController.h"
#import "AMSerialPortList.h"
#import "AMSerialPortAdditions.h"

@implementation AppController

@synthesize	port;
@synthesize serialPortConnected;
@synthesize channel0RMS;
@synthesize channel1RMS;
@synthesize channel0ADC;
@synthesize channel1ADC;
@synthesize kilowattHours;
@synthesize	voltAmps;




-(id)init
{
	speedArray = [[NSArray arrayWithObjects:@"600", @"1200", @"2400", @"4800", @"9600", @"19200", @"28800", @"38400", @"57600", @"115200", @"230400", nil] retain]; // this also needs to be moved to some user specifiable list of prefered data rates
	xbeeParser = [[XBeeAPIParser alloc] init];
	[xbeeParser setDelegate:self];
	return self;
}

- (void)awakeFromNib
{
	// register for port add/remove notification
	[mainWindow setFrameAutosaveName:@"MainWindowFrame"];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddPorts:) name:AMSerialPortListDidAddPortsNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemovePorts:) name:AMSerialPortListDidRemovePortsNotification object:nil];
	// register for notifications of user changing baud rade from the combo box
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectSpeed:) name:NSComboBoxSelectionDidChangeNotification object:speedComboBox];
	[AMSerialPortList sharedPortList]; // initialize port list to arm notifications
	[speedComboBox addItemsWithObjectValues:speedArray]; // currently uses this instead of data source, since I couldn't get the default spped selected in the combobox with usesDataSource. the following code was trying to select the default speed before the bonbo box was getting populated from the datasource, throwing an exception.
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"SerialSpeed"]) {
		[speedComboBox selectItemWithObjectValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"SerialSpeed"]];
	}
}




////////////////////////////////////////////////////////////////////////////////
//////////////////////////////                    //////////////////////////////
//////////////////////////////      Methods       //////////////////////////////
//////////////////////////////                    //////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Custom Methods

- (void)initPort	// experimental initPort methods, checks if there is a device selected from the combo box. As it is now, even if we just want to reopen a port we had oped before, it gets killed and a new port created. I'm not sure if that is bad or ugly, but I'd prefer to fix it up a little
{
	[connectionIndicator startAnimation:self]; // this indicator is hidded when it isn't active. currently it's jusrt right to the 'connect' button

	if ([deviceComboBox indexOfSelectedItem] > -1) {
		NSEnumerator *enumerator = [AMSerialPortList portEnumerator]; // these three lines could be combined into one line, but it would be ugly
		NSArray *portArray = [enumerator allObjects];
		NSString *deviceName = [[portArray objectAtIndex:[deviceComboBox indexOfSelectedItem]] bsdPath];
				
		[self setPort:[[[AMSerialPort alloc] init:deviceName withName:deviceName type:(NSString*)CFSTR(kIOSerialBSDModemType)] autorelease]];
		// register as self as delegate for port
		[port setDelegate:self];
		// open port - may take a few seconds ...
		if ([port open]) {
			[connectDisconnectButton setTitle:@"Disconnect"];
			if ([speedComboBox indexOfSelectedItem] > -1) {
				//[port setSpeed:[[speedArray objectAtIndex:[speedComboBox indexOfSelectedItem]] intValue]];
				[port setSpeed:[[speedComboBox objectValueOfSelectedItem] intValue]];
				[port commitChanges];
			} else {
				NSAlert *alert = [[[NSAlert alloc] init] autorelease];
				[alert addButtonWithTitle:@"OK"];
				[alert setMessageText:@"Please select a baud-rate"];
				[alert setAlertStyle:NSWarningAlertStyle];
				[alert runModal];
			}
			// listen for data in a separate thread
			[port readDataInBackground];
			[self setSerialPortConnected:YES];
		} else { // an error occured while creating port
			[self setPort:nil];
			NSAlert *alert = [[[NSAlert alloc] init] autorelease];
			[alert addButtonWithTitle:@"OK"];
			[alert setMessageText:@"Can't Connect"];
			[alert setInformativeText:@"Check if it's plugged in."];
			[alert setAlertStyle:NSWarningAlertStyle];
			[alert runModal];
			[connectDisconnectButton setTitle:@"Connect"];
		}
	} else {
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Please select a port"];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert runModal];
	}
	[connectionIndicator stopAnimation:self];
}

- (void)closePort
{
	[port close];
	[self setSerialPortConnected:NO];
	[connectDisconnectButton setTitle:@"Connect"];
}




////////////////////////////////////////////////////////////////////////////////
//////////////////////////////                    //////////////////////////////
//////////////////////////////     Delegates      //////////////////////////////
//////////////////////////////                    //////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Delegate Methods

- (void)serialPortReadData:(NSDictionary *)dataDictionary // this is the guts of this application.
{
	AMSerialPort *sendPort = [dataDictionary objectForKey:@"serialPort"]; // we need this so we can tell the port to continue listening for incoming data after we're done processing data that
	NSData *data = [dataDictionary objectForKey:@"data"];
	int dataLength = [data length];
	if (dataLength > 0) // at a minimum all data received is inputted into the outputTextView
	{
		[xbeeParser addData:data];
		[sendPort readDataInBackground];
	} else {
		[self setSerialPortConnected:NO];
		[connectDisconnectButton setTitle:@"Connect"]; // Port Closed
	}	
}

- (void)serialPortWriteProgress:(NSDictionary *)aDictionary
{
	
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
	if (aComboBox == speedComboBox) {
		return [speedArray objectAtIndex:index];
	} else if (aComboBox == deviceComboBox) {
		NSEnumerator *enumerator = [AMSerialPortList portEnumerator];
		NSArray *portArray = [enumerator allObjects];
		return [[portArray objectAtIndex:index] name];
	}
	return nil;
}

- (int)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
	if (aComboBox == speedComboBox) {
		return [speedArray count];
	} else if (aComboBox == deviceComboBox) {
		NSEnumerator *enumerator = [AMSerialPortList portEnumerator];
		NSArray *portArray = [enumerator allObjects];
		return [portArray count];
	}
	return 0;
}

- (void)xbeePacketReceived:(NSDictionary *)dataDictionary
{
	NSMutableString *stringToPrint = [NSMutableString new];
	NSData *packetData = [dataDictionary objectForKey:@"data"];
	const unsigned char *packetBytes = [packetData bytes];
	unsigned i;
	for (i=0; i<[packetData length]; i++) {
		[stringToPrint appendFormat:@"%02X ", packetBytes[i]];
	}
	[stringToPrint appendFormat:@"\n"];
	[consoleWindowController appendConsoleText:stringToPrint];
	
	switch (packetBytes[0]) {
		case 0x72:
			[self explodeValuesPacket:packetData];
			break;
		default:
			NSLog(@"Unknown packet type");
			break;
	}
}


- (void)explodeValuesPacket:(NSData *)packet
{
	int tempInt;
	float tempFloat;
  
  [packet getBytes:&tempInt range: NSMakeRange(1,4)];
	[self setChannel0ADC:tempInt];
  [packet getBytes:&tempInt range: NSMakeRange(5,4)];
	[self setChannel1ADC:tempInt];
  [packet getBytes:&tempFloat range: NSMakeRange(9,4)];
	[self setChannel0RMS:tempFloat];
  [packet getBytes:&tempFloat range: NSMakeRange(13,4)];
	[self setChannel1RMS:tempFloat];
	[packet getBytes:&tempFloat range: NSMakeRange(17,4)];
	[self setKilowattHours:joulesToKWHours(tempFloat)];
	[packet getBytes:&tempFloat range: NSMakeRange(21,4)];
	[self setVoltAmps:tempFloat];
}




////////////////////////////////////////////////////////////////////////////////
//////////////////////////////                    //////////////////////////////
//////////////////////////////   Notifications    //////////////////////////////
//////////////////////////////                    //////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Notifications

- (void)didAddPorts:(NSNotification *)theNotification // need to update deviceComboBox
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:@"Added Port"];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert runModal];
}

- (void)didRemovePorts:(NSNotification *)theNotification // Need to update deviceComboBox
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:@"Lost Port"];
	//	[alert setInformativeText:@""];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert runModal];
}

- (void)didSelectSpeed:(NSNotification *)theNotification  // called when user selects a new baud rate
{
	if ([NSUserDefaults standardUserDefaults]) {
		[[NSUserDefaults standardUserDefaults] setObject:[speedArray objectAtIndex:[speedComboBox indexOfSelectedItem]] forKey:@"SerialSpeed"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	if ([port isOpen]) {
		[port setSpeed:[[speedArray objectAtIndex:[speedComboBox indexOfSelectedItem]] intValue]];
		[port commitChanges];
	}
}




////////////////////////////////////////////////////////////////////////////////
//////////////////////////////                    //////////////////////////////
//////////////////////////////     IBActions      //////////////////////////////
//////////////////////////////                    //////////////////////////////
////////////////////////////////////////////////////////////////////////////////


#pragma mark -
#pragma mark IBActions

- (IBAction)connectDisconnect:(id)sender	
{
	if (![port isOpen])  {
		[self initPort];
	} else {
		[port close];
		[connectDisconnectButton setTitle:@"Connect"];
	}
}

- (IBAction)consoleWindowShow:(id)sender 
{
	if (!consoleWindowController) {
		consoleWindowController = [[ConsoleWindowController alloc] init];
	}
	[consoleWindowController showWindow:self];
}

@end