//
//  KLConsoleWindow.h
//  PropStream
//
//  Created by Jay Kickliter on 3/19/09.
//  Copyright 2009 Karmalounge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KLConsoleWindowController : NSWindowController {
	IBOutlet NSTextView *outputTextView;
	IBOutlet NSButton		*clearButton;
}

- (IBAction)clearOutputTextView:(id)sender;
- (void)appendXbeePacketText:(NSString *)packetText;

@end
